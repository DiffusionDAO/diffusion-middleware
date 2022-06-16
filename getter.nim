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
import asyncfile
import asyncdispatch


proc getter() {.async.} = 
    while true:
        try:
            var dir = &"public/nfts/{startLightAddress}"
            if not dirExists dir:
                echo "createDir: ", dir
                createDir  dir

            var totalSupply = getTotalSupply().toInt()
            echo "totalSupply:", totalSupply
            for i in 0..totalSupply - 1:
                var path = &"public/nfts/{startLightAddress}/{i}"
                if not fileExists path:
                    var data = getTokenURI(i)
                    var length = fromHex[int] data[64 .. 127]
                    var tokenURI = data[128 .. 128 + length*2 - 1].parseHexStr
                    var client = newHttpClient()
                    defer: client.close()
                    var response = client.post(fmt"http://207.148.117.14:5002/api/v0/cat?arg={tokenURI}")
                    var body = response.body()
                    writeFile(path, body)
            sleep(1000)
        except:
            echo getCurrentExceptionMsg()

waitFor getter()