import os, re, jester, asyncdispatch, htmlgen, asyncnet, httpclient
import ipfs, followers

import std/json


routes:
  post "/resend":
    var client = newHttpClient()
    let cid = request.params["cid"]
    discard uploadNFTPicture(client, cid)
    client.close()
    redirect("/")

  get "/api/v0/concentration":
    let number = getFollowerNumber()
    var code = 200
    if number.twitter == 0 or number.discord == 0 or
        number.telegram == 0 or number.medium == 0:
      code = 401
    let data = $(%*{"code": code, "data": number})
    resp data, "application/json"

runForever()
