import std/[json, strutils]
import puppy


const telegramLink = "https://api.telegram.org/bot5334696884:AAHzLTcSxbmnzHZUBNfCBN2SjXAyaT06hQo/getChatMembersCount?chat_id=@DiffusionDAO"
const discordLink = "https://discord.com/api/invite/XYKQdqmuTe?with_counts=true"
const twitterLink = "https://cdn.syndication.twimg.com/widgets/followbutton/info.json?screen_names=DFSDIFFUSION"
const mediumLink = "https://medium.com/@getdiffusion?format=json"

const JSON_HIJACKING_PREFIX = "])}while(1);</x>"

type
  FollowerNumber* = object
    telegram*, discord*, twitter*, medium*: int

proc getFollowerNumber*(): FollowerNumber =
  try: result.telegram = parseJson(fetch(telegramLink))["result"].getInt
  except: discard

  try: result.discord = parseJson(fetch(discordLink))["approximate_member_count"].getInt
  except: discard

  try: result.twitter = parseJson(fetch(twitterLink))[0]["followers_count"].getInt
  except: discard

  try:
    let raw = fetch(mediumLink)
    let data = parseJson(raw.replace(JSON_HIJACKING_PREFIX, ""))
    let userId = data["payload"]["user"]["userId"].getStr
    result.medium = data["payload"]["references"]["SocialStats"][userId]["usersFollowedByCount"].getInt
  except: discard

echo getFollowerNumber()