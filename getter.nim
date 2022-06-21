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
import asyncfile
import asyncdispatch


proc getter() {.async.} = 
    while true:
        try:
            var nft = parseFile("nft.json")
            var keys = nft.keys().toSeq()
            var name = getName()
            var time = now().toTime().format("yyyy/MM/dd HH:mm")
            for collection, data in nft:
                var data = data["data"][0]
                var avatar = &"public/nfts/{collection}/avatar"
                if not fileExists avatar:
                    var req = puppy.Request(
                        url: parseUrl(fmt"""http://127.0.0.1:5001/api/v0/cat?arg={data["avatar"].getStr}"""),
                        verb: "post"
                    )
                    writeFile(avatar, fetch(req).body)

                var small = &"public/nfts/{collection}/small"
                if not fileExists small:
                    var req = puppy.Request(
                        url: parseUrl(fmt"""http://127.0.0.1:5001/api/v0/cat?arg={data["banner"]["small"].getStr}"""),
                        verb: "post"
                    )
                    writeFile(small, fetch(req).body)

                var large = &"public/nfts/{collection}/large"
                if not fileExists large:
                    var req = puppy.Request(
                        url: parseUrl(fmt"""http://127.0.0.1:5001/api/v0/cat?arg={data["banner"]["large"].getStr}"""),
                        verb: "post"
                    )
                    writeFile(large, fetch(req).body)

                var dir = &"public/nfts/{collection}"
                if not dirExists dir:
                    echo "createDir: ", dir
                    createDir  dir

                var totalSupply = getTotalSupply().toInt()
                echo "totalSupply:", totalSupply
                
                for i in 0..totalSupply - 1:
                    var path = &"public/nfts/{collection}/{i}"
                    if not fileExists path:
                        var owner = getOwner(i)
                        var data = getTokenURI(i)
                        var length = fromHex[int] data[64 .. 127]
                        var tokenURI = data[128 .. 128 + length*2 - 1].parseHexStr
                        var client = newHttpClient()
                        defer: client.close()
                        var response = client.post(fmt"http://127.0.0.1:5001/api/v0/cat?arg={tokenURI}")
                        var body = response.body()
                        writeFile(path, body)
                        nft[collection]["tokens"].add %*{"tokenId": $i,
                                            "name": name,
                                            "description": name,
                                            "collectionName": name,
                                            "collectionAddress": collection,
                                            "image": {
                                                "original": "string",
                                                "thumbnail": $i
                                            },
                                            "attributes": [
                                                {
                                                    "traitType": "",
                                                    "value": 0,
                                                    "displayType": ""
                                                }
                                            ],
                                            "createdAt": time,
                                            "updatedAt": time,
                                            "location": "For Sale",
                                            "marketData": {
                                                "tokenId": $i,
                                                "collection": {
                                                    "id": $i
                                                },
                                                "currentAskPrice": "",
                                                "currentSeller": owner,
                                                "isTradable": true
                                            }}
                if nft[collection]["total"].getInt != totalSupply :
                    nft[collection]["total"] = %totalSupply
                    writeFile("nft.json", $nft)
            sleep(1000)
        except:
            echo getCurrentExceptionMsg()

waitFor getter()