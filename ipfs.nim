import std/strformat
import std/httpclient
import std/json
import std/uri

import puppy


proc uploadNFTPicture*(client: HttpClient, file: string): string =
  try:
    var data = newMultipartData()
    data.addFiles({"uploaded_file": file})
    # todo check status code
    let res = client.request("http://207.148.117.14:5001/api/v0/add",
            httpMethod = HttpPost,
            multipart = data)
    echo res.body
    let jsonData = parseJson(res.body)
    result = jsonData["Hash"].getStr
  except Exception:
    discard

proc showNFTPicture*(arg: string): string =
  # todo check status code

  let website = fmt"http://207.148.117.14/api/v0/cat?arg={arg}"
  let req = Request(
  url: parseUrl(website),
  verb: "post"
  )
  result = fetch(req).body

when isMainModule:
  import std/[os, strutils]
  var client = newHttpClient()

  for file in walkDir("GIF"):
    if file.path.endsWith("gif"):
      discard client.uploadNFTPicture(file.path)