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
import asyncfile

settings:
  reusePort = true

const host = "http://localhost:5000"  
# const host = "http://154.210.13.181:5000"  
routes:
  get "/api/v0/concentration":
    let number = getFollowerNumber()
    var code = 200
    if number.twitter == 0 or number.discord == 0 or
        number.telegram == 0 or number.medium == 0:
      code = 401
    let data = $(%*{"code": code, "data": number})
    resp data

  get "/nfts/collections":
    {.gcsafe.}:
      var nft = parseFile("nft.json")
      var data = nft["data"][0]

      if not fileExists "public/nfts/avatar":
        var req = puppy.Request(
          url: parseUrl(fmt"""https://ipfs.infura.io:5001/api/v0/cat?arg={data["avatar"].getStr}"""),
          verb: "post"
        )
        writeFile("public/nfts/avatar", fetch(req).body)
      data["avatar"] = % &"{host}/nfts/avatar"

      if not fileExists "public/nfts/small":
        var req = puppy.Request(
          url: parseUrl(fmt"""https://ipfs.infura.io:5001/api/v0/cat?arg={data["banner"]["small"].getStr}"""),
          verb: "post"
        )
        writeFile("public/nfts/small", fetch(req).body)
      data["banner"]["small"] = % &"{host}/nfts/small"

      if not fileExists "public/nfts/large":
        var req = puppy.Request(
          url: parseUrl(fmt"""https://ipfs.infura.io:5001/api/v0/cat?arg={data["banner"]["large"].getStr}"""),
          verb: "post"
        )
        writeFile("public/nfts/large", fetch(req).body)
      data["banner"]["large"] = % &"{host}/nfts/large"
      resp Http200, {"Access-Control-Allow-Origin":"*"}, $nft

  get "/nfts/collections/@address/tokens/@tokenId":
        var address = @"address"
        var tokenId = parseInt @"tokenId"
        echo address, " ", tokenId
        var nfts = parseFile("nft.json")
        var nft = nfts[address][tokenId]
        resp Http200, {"Access-Control-Allow-Origin":"*"}, $nft

  get "/nfts/collections/@address":
        var address = @"address"
        var id = 0
        var nft = parseFile("nft.json")
        var nfts = nft[address]
        for item in nfts:
          if item["collectionAddress"].getStr == address:
              item["image"]["thumbnail"] = % &"{host}/nfts/{address}/{id}"
              id.inc
        # writeFile("nft.json", $nft)
        resp Http200, {"Access-Control-Allow-Origin":"*"}, $nft


runForever()
