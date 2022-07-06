import web3, web3Contract
import options, stint, parseutils, strutils, strformat, times, sequtils
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
  port = Port(80)

# const host = "http://localhost:5000"  
const host = "https://middle.diffusiondao.org" 
routes:
  get "/api/v0/dashboard":
    let number = getFollowerNumber()
    echo "followers:",number
    var code = 200
    if number.twitter == 0 or number.discord == 0 or
        number.telegram == 0 or number.medium == 0:
      code = 401
    let data = $(%*{"code": code, "concentration": number})
    resp Http200, {"Access-Control-Allow-Origin":"*"}, data
    
  get "/nfts/collections":
    {.gcsafe.}:
      var nft = parseFile("nft.json")
      for collection, data in nft:
        var data = data["data"][0]
        data["avatar"] = % &"{host}/nfts/{collection}/avatar"
        data["banner"]["small"] = % &"{host}/nfts/{collection}/small"
        data["banner"]["large"] = % &"{host}/nfts/{collection}/large"
        for item in nft[collection]["tokens"]:
          var thumbnail = item["image"]["thumbnail"].getStr
          item["image"]["thumbnail"] = % &"{host}/nfts/{collection}/{thumbnail}"
      resp Http200, {"Access-Control-Allow-Origin":"*"}, $nft

  get "/nfts/collections/@address/tokens/@tokenId":
    {.gcsafe.}:
        var address = @"address"
        var tokenId = @"tokenId"
        echo address, " ", tokenId
        var nfts = parseFile("nft.json")

        var token : JsonNode
        for t in nfts[address]["tokens"]:
          if t["tokenId"].getStr == tokenId:
            token = t
            break

        token["image"]["thumbnail"] = % &"{host}/nfts/{address}/{tokenId}"
        resp Http200, {"Access-Control-Allow-Origin":"*"}, $token

  get "/nfts/collections/@address":
        var address = @"address"
        var nft = parseFile("nft.json")
        for collection, data in nft:
          var data = data["data"][0]
          data["avatar"] = % &"{host}/nfts/{collection}/avatar"
          data["banner"]["small"] = % &"{host}/nfts/{collection}/small"
          data["banner"]["large"] = % &"{host}/nfts/{collection}/large"
        for item in nft[address]["tokens"]:
          if item["collectionAddress"].getStr == address:
            var thumbnail = item["image"]["thumbnail"].getStr
            item["image"]["thumbnail"] = % &"{host}/nfts/{address}/{thumbnail}"
        resp Http200, {"Access-Control-Allow-Origin":"*"}, $nft

  # patch "/nfts/collections/@address":
  #   var address = @"address"
  #   var newNft = parseJson request.body
  #   var nft = parseFile("nft.json")
  #   nft[address] = newNft
  #   writeFile("nft.json", $nft)
  #   resp Http200, {"Access-Control-Allow-Origin":"*"}, $nft

runForever()
