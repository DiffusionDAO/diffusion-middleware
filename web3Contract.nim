import web3
import chronos, nimcrypto, options, json, stint, parseutils, strutils, strformat, times
import eth/keys

contract(StarLight):
  proc tokenURI(tokenId: Uint256): string {.view.}
  proc totalSupply(): Uint256 {.view.}
  proc ownerOf(id: Uint256): Address {.view.}
  proc name(): string {.view.}
  

const startLightAddress* = "0x5984BE31fA3A9bFace8b0946ea780a5D347034E0"
var web3Client = waitFor newWeb3("https://data-seed-prebsc-1-s1.binance.org:8545/")
let starlight = web3Client.contractSender(StarLight, Address.fromHex startLightAddress)

proc getTokenURI*(tokenId: int): string  = 
  result = waitFor starlight.tokenURI(tokenId.u256).call()

proc getName*(): string  = 
  result = waitFor starlight.name().call()

proc getTotalSupply*(): UInt256  = 
  result = waitFor starlight.totalSupply().call()

proc getOwner*(tokenId: int): string =
  result = $(waitFor starlight.ownerOf(tokenId.u256).call())
  
when isMainModule:
  # var account = Address.fromHex "0x657eEfd3e1712d152430bc3D35e9c40Db474e9b6"
  # var client = waitFor newWeb3("https://icy-weathered-violet.bsc.quiknode.pro/0617462be53bb10061e99025fa2cd12893fb6efb/")
  # var balance = waitFor client.provider.eth_getBalance(account, "latest")
  # echo balance
  var ts = getTotalSupply().toInt()
  echo "totalSupply:", ts