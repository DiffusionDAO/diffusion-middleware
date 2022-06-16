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
                var client = newAsyncHttpClient()
                defer: client.close()
                var response = await client.post(fmt"http://207.148.117.14:5002/api/v0/cat?arg={tokenURI}")
                var body = await response.body()
                var asyncfd = openAsync(path, fmReadWrite)
                defer: asyncfd.close()
                await asyncfd.write(body)
        await sleepAsync(1000)

waitFor getter()