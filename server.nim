import os, re, jester, asyncdispatch, htmlgen, asyncnet, httpclient
import ipfs


routes:
  post "/resend":
    var client = newHttpClient()
    let cid = request.params["cid"]
    discard uploadNFTPicture(client, cid)
    client.close()
    redirect("/")
runForever()
