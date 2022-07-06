import std/[json, strutils]
import puppy
import times
import os
import htmlparser
import xmltree

const telegramLink = "https://api.telegram.org/bot5334696884:AAHzLTcSxbmnzHZUBNfCBN2SjXAyaT06hQo/getChatMembersCount?chat_id=@DiffusionDAO"
const discordLink = "https://discord.com/api/invite/XYKQdqmuTe?with_counts=true"
const twitterLink = "https://cdn.syndication.twimg.com/widgets/followbutton/info.json?screen_names=DFSDIFFUSION"
const mediumLink = "https://medium.com/@getdiffusion?format=json"

const JSON_HIJACKING_PREFIX = "])}while(1);</x>"

type
  FollowerNumber* = object
    telegram*, discord*, twitter*, medium*: int

proc getFollowerNumber*(): FollowerNumber =
  var timestamp = now().toTime().toUnix()
  if not fileExists("followers.json"):
    writeFile("followers.json", $ %*{"time": timestamp, "concentration": result})
  var followers = parseFile("followers.json")
  result = followers["concentration"].to(FollowerNumber)
  var time = followers["time"].getInt
  if timestamp - time >= 3600 or timestamp == time:
    try: 
      result.telegram = parseJson(fetch(telegramLink))["result"].getInt
    except: 
      echo getCurrentExceptionMsg()

    try: 
      var fetched = fetch(discordLink)
      var parsed = parseJson(fetched)
      result.discord = parsed["approximate_member_count"].getInt
    except: 
      var message = getCurrentExceptionMsg()
      var xmlnode = parseHtml(message)
      echo xmlnode[10][3][1]
      # for i in 0.. xmlnode[10][3].len - 1:
      #   if xmlnode[10][3][i].kind == xnElement:
      #     echo i, " ", xmlnode[10][3][i]

    try: result.twitter = parseJson(fetch(twitterLink))[0]["followers_count"].getInt
    except: 
      echo getCurrentExceptionMsg()

    try:
      let raw = fetch(mediumLink)
      let data = parseJson(raw.replace(JSON_HIJACKING_PREFIX, ""))
      let userId = data["payload"]["user"]["userId"].getStr
      result.medium = data["payload"]["references"]["SocialStats"][userId]["usersFollowedByCount"].getInt
    except: 
      echo getCurrentExceptionMsg()
    followers["time"] = %timestamp
    followers["concentration"] = %result
    writeFile("followers.json", $followers)

when isMainModule:
  let number = getFollowerNumber()
  var code = 200
  if number.twitter == 0 or number.discord == 0 or
      number.telegram == 0 or number.medium == 0:
    code = 401
  let data = $(%*{"code": code, "data": number})
  echo data
