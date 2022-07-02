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

const dfsNFT = {"0":"QmSAkwfQa4thS1cg1cFkULydT1P9aoquRKiv7KCuTYvqak",
                "1":"Qmba4Q7reUoUXbkXRG8h8DSZ8wUdbm6CsXDHgkL8h6jr19",
                "2":"QmRmH7Mk8mG6AhLTw3caaAfRk32BPVFci5peX9ukmmv9Ja",
                "3":"QmQRPivxPhW6yk92wwe5nWbuPooT6WBz3pFtrQfMsxEd8a",
                "4":"QmQn5dSDzq3jBcLek5R7HCqePnKApnr1Z3MoNreEP31vUs",
                "5":"QmaPUTRNt9WT8H69z2fW89we7kudXDRFY7HrMG7PZRtghz",
                "6":"QmW2cgHfp4TxUZBbTCNy6eM2VzxEpFE2NEbB8thB4mr9i7"}.toOrderedTable

const dfsName = {"0":"Lord fragment","1":"Lord","2":"Gloden Lord","3":"General","4":"Gloden General","5":"Congressman","6":"Gloden Congressman"}.toOrderedTable

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
                echo "totalSupply:", totalSupply
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

                var total = nft[collection]["total"].getInt
                if total != totalSupply :
                    for i in total..totalSupply - 1:
                        var path = &"public/nfts/{collection}/{i}"
                        var owner = getOwner(collection, i)
                        var level: string
                        if not fileExists path:
                            var tokenURI = getTokenURI(collection, i)
                            if tokenURI == $i:
                                level = getItems(collection, i)
                                tokenURI = dfsNFT[level]
                                name = dfsName[level]
                                echo name
                            var url = fmt"http://127.0.0.1:5001/api/v0/cat?arg={tokenURI}"
                            var response = client.post(url)
                            var body = response.body()
                            writeFile(path, body)
                        if nft[collection]["tokens"].len < i:
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
                                                        "value": level,
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
                    nft[collection]["total"] = %totalSupply
                    nft[collection]["data"][0]["totalSupply"] = %totalSupply
                    writeFile("nft.json", $nft)
            client.close()
            sleep(1000)
        except:
            echo getCurrentExceptionMsg()

waitFor getter()