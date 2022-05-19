import std/strformat
import std/httpclient
import std/json
import std/uri

import puppy


proc uploadNFTPicture(client: HttpClient, file: string): string =
  var data = newMultipartData()
  data.addFiles({"uploaded_file": file})
  # todo check status code
  let res = client.request("http://207.148.117.14:5001/api/v0/add",
          httpMethod = HttpPost,
          multipart = data)
  let jsonData = parseJson(res.body)
  result = jsonData["Hash"].getStr

proc showNFTPicture(client: HttpClient, arg: string): string =
  # todo check status code

  let website = fmt"http://207.148.117.14:5001/api/v0/cat?arg={arg}"
  let req = Request(
  url: parseUrl(website),
  verb: "post"
  )
  result = fetch(req).body


import std/tempfiles

var client = newHttpClient()
let code = uploadNFTPicture(client, "test.jpg")
echo "code:\n", code
echo "------------------------------------------"
# echo "content:\n",
let data = showNFTPicture(client, code)
let (cfile, path) = createTempFile("tmpprefix_", "_end.tmp.jpg")
cfile.write(data)
echo path
