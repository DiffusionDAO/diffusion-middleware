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
import tables

const dfsNFT = {"0":"QmbQRKqW6DvZ5CEB5B5jQk4iCsFkBzCjwo316aJJkUn7CR",
                "1":"QmTjm418fc4EC9dKn51JpwD5Krf9jciCBNTC94s9ZsnPaA",
                "2":"QmXp68doo1udaESHf15btes95MAmHWkcJE6BS6gGPuurdE",
                "3":"QmaQjNDQJAkJKdt7ZjgMY4dFkLpykEPTuhTJjKNJsj91nT",
                "4":"QmS61LbSk5AHEi38z7PHXWWnqZdtbgEYPW4DeXN6QtTyLR",
                "5":"Qma6WTrZMfs9pUvv44vhcP2Vrnau1FuSpLwiuwBFigLhdM",
                "6":"QmTxwFXhfFxTtuMFBhbBoysHLjrbQ1f8WcdjViZWTN6qKr"}.toOrderedTable

const dfsName = {"0":"Lord fragment","1":"Lord","2":"Golden Lord","3":"General","4":"Golden General","5":"Congressman","6":"Golden Congressman"}.toOrderedTable
const greeceNumber = {"0":"I","1":"II","2":"III","3":"IV","4":"V","5":"VI","6":"VII"}.toOrderedTable

template `[]=`(arr: JsonNode, i:int, j:JsonNode):untyped {.dirty.} =
    var json = arr[i]


proc getter() {.async.} = 
    while true:
        try:
            var nft = parseFile("nft.json")
            var keys = nft.keys().toSeq()
            var time = now().toTime().format("yyyy/MM/dd HH:mm")
            var client = newHttpClient()
            for collection, data in nft:
                var name = getName(collection)
                var dir = &"public/nfts/{collection}"
                if not dirExists dir:
                    echo "createDir: ", dir
                    createDir  dir
                var totalSupply = getTotalSupply(collection).toInt()
                # echo "totalSupply:", totalSupply
                var data = data["data"][0]
                var avatar = &"public/nfts/{collection}/avatar"
                if not fileExists avatar:
                    var response = client.post(fmt"""http://127.0.0.1:5001/api/v0/cat?arg={data["avatar"].getStr}""")
                    var body = response.body()
                    writeFile(avatar, body)

                var small = &"public/nfts/{collection}/small"
                if not fileExists small:
                    var response = client.post(fmt"""http://127.0.0.1:5001/api/v0/cat?arg={data["banner"]["small"].getStr}""")
                    var body = response.body()
                    writeFile(small, body)

                var large = &"public/nfts/{collection}/large"
                if not fileExists large:
                    var response = client.post(fmt"""http://127.0.0.1:5001/api/v0/cat?arg={data["banner"]["large"].getStr}""")
                    var body = response.body()
                    writeFile(large, body)
                
                var tokens = newJArray()
                var total = nft[collection]["tokens"].len
                # var tokenIds = nft[collection]["tokens"].toSeq.mapIt(it["tokenId"].getInt)
                var marketItems = getMarketItems()
                for i in 0..totalSupply - 1:
                    var tokenId = getTokenByIndex(collection, i)
                    var path = &"public/nfts/{collection}/{tokenId}"
                    var level: string
                    var tokenURI = getTokenURI(collection, tokenId)
                    if tokenURI == $tokenId:
                        level = getItems(collection, tokenId)
                        tokenURI = dfsNFT[level]
                        name = dfsName[level]
                    if not fileExists path:
                        var url = fmt"http://127.0.0.1:5001/api/v0/cat?arg={tokenURI}"
                        var response = client.post(url)
                        var body = response.body()
                        writeFile(path, body)
                    var owner = getOwnerOf(collection, tokenId)

                    var token = %*{"tokenId": $tokenId,
                                    "name": if collection == dfsNFTAddress: greeceNumber[level] else: name,
                                    "description": name,
                                    "collectionName": name,
                                    "collectionAddress": collection,
                                    "image": {
                                        "original": "string",
                                        "thumbnail": $tokenId
                                    },
                                    "attributes": [
                                        {
                                            "traitType": "",
                                            "value": level,
                                            "displayType": ""
                                        }
                                    ],
                                    "createdAt": "",
                                    "updatedAt": "",
                                    "location": "For Sale",
                                    "marketData": {
                                        "tokenId": $tokenId,
                                        "collection": {
                                            "id": $tokenId
                                        },
                                        "currentAskPrice": "",
                                        "currentSeller": owner,
                                        "isTradable": true
                                    }}
                    for item in marketItems:
                        if item.tokenId.toInt() == tokenId:
                            token["marketData"]["currentAskPrice"] = %item.price.toString()
                            if $item.seller != zeroAddress:
                                token["marketData"]["currentSeller"] = % $item.seller
                            break
                    for t in nft[collection]["tokens"]:
                        if t["tokenId"].getStr == $tokenId:
                            if t["createdAt"].getStr == "" :
                                token["createdAt"] = %time
                            else:
                                token["createdAt"] = t["createdAt"]
                            if t["updatedAt"].getStr == "":
                                token["updatedAt"] = %time
                            else:
                                token["updatedAt"] = t["updatedAt"]
                            break
                    tokens.add token
                if nft[collection]["tokens"] != tokens:
                    nft[collection]["tokens"] = tokens
                    nft[collection]["total"] = %totalSupply
                    nft[collection]["data"][0]["totalSupply"] = %totalSupply
                    writeFile("nft.json", $nft)
            client.close()
            sleep(1000)
        except:
            echo getCurrentExceptionMsg()

waitFor getter()