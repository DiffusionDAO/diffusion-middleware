import web3, web3Contract
import options, stint, parseutils, strutils, strformat, times
import eth/keys
import ipfs, followers
import strutils
import std/json
import std/strformat
import std/httpclient
import std/uri
import puppy, re, os
import jester

settings:
  reusePort = true

# const host = "http://localhost:5000"  
const host = "http://154.210.13.181:5000"  
routes:
  get "/api/v0/concentration":
    let number = getFollowerNumber()
    var code = 200
    if number.twitter == 0 or number.discord == 0 or
        number.telegram == 0 or number.medium == 0:
      code = 401
    let data = $(%*{"code": code, "data": number})
    resp data

  get re"/collections":
    var nft = parseFile("nft.json")
    var data = nft["data"][0]
    var req = puppy.Request(
      url: parseUrl(fmt"""https://ipfs.infura.io:5001/api/v0/cat?arg={data["avatar"].getStr}"""),
      verb: "post"
    )
    if not fileExists "public/nfts/avatar":
      writeFile("public/nfts/avatar", fetch(req).body)
    data["avatar"] = % &"{host}/nfts/avatar"

    req = puppy.Request(
      url: parseUrl(fmt"""https://ipfs.infura.io:5001/api/v0/cat?arg={data["banner"]["small"].getStr}"""),
      verb: "post"
    )
    if not fileExists "public/nfts/small":
      writeFile("public/nfts/small", fetch(req).body)
    data["banner"]["small"] = % &"{host}/nfts/small"

    req = puppy.Request(
      url: parseUrl(fmt"""https://ipfs.infura.io:5001/api/v0/cat?arg={data["banner"]["large"].getStr}"""),
      verb: "post"
    )
    if not fileExists "public/nfts/large":
      writeFile("public/nfts/large", fetch(req).body)
    data["banner"]["large"] = % &"{host}/nfts/large"

    resp Http200, {"Access-Control-Allow-Origin":"*"}, $nft

  get "/collection/@address":
    var address = @"address"
    echo "address: ", address
    if address == "undefined": return
    var dir = &"public/nfts/{address}"
    if not dirExists dir:
      echo "createDir: ", dir
      createDir  dir

    var totalSupply = getTotalSupply().toInt()
    echo "totalSupply:", totalSupply
    for i in 0..totalSupply - 1:
      if not fileExists &"public/nfts/{address}/{i}":
        var data = getTokenURI(i)
        var length = fromHex[int] data[64 .. 127]
        var tokenURI = data[128 .. 128 + length*2 - 1].parseHexStr
        var client = newAsyncHttpClient()
        defer: client.close()
        var response = await client.post(fmt"http://207.148.117.14:5002/api/v0/cat?arg={tokenUri}")
        var body = await response.body()
        writeFile(&"public/nfts/{address}/{i}", body)

    var id = 0
    var nft = parseFile("nft.json")
    for item in nft["nft"]:
      if item["collectionAddress"].getStr == address:
          item["image"]["thumbnail"] = % &"{host}/nfts/{address}/{id}"
          id.inc

    resp Http200, {"Access-Control-Allow-Origin":"*"}, $nft

runForever()
