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
    var code = 200
    if number.twitter == 0 or number.discord == 0 or
        number.telegram == 0 or number.medium == 0:
      code = 401
    let data = $(%*{"code": code, "concentration": number})
    resp data
    
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
        var address = @"address"
        var tokenId = parseInt @"tokenId"
        echo address, " ", tokenId
        var nfts = parseFile("nft.json")
        var token = nfts[address]["tokens"][tokenId]
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



runForever()
