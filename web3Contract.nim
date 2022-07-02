import web3
import chronos, nimcrypto, options, json, stint, parseutils, strutils, strformat, times
import eth/keys

contract(StarLight):
  proc tokenURI(tokenId: Uint256): string {.view.}
  proc totalSupply(): Uint256 {.view.}
  proc ownerOf(id: Uint256): Address {.view.}
  proc name(): string {.view.}
  
contract(DFSNFT):
  proc tokenURI(tokenId: Uint256): string {.view.}
  proc totalSupply(): Uint256 {.view.}
  proc ownerOf(id: Uint256): Address {.view.}
  proc name(): string {.view.}
  proc getItems(tokenId: Uint256): Uint {.view.}

const startLightAddress* = "0x88eBFd7841D131BCeab3e7149217aa8e36985a40"
const dfsNFTAddress* = "0x11C75500cfe0862e3Ef9F5061C297Ddc099F1116"
var web3Client = waitFor newWeb3("https://data-seed-prebsc-1-s1.binance.org:8545/")
let starlight = web3Client.contractSender(StarLight, Address.fromHex startLightAddress)

proc getTokenURI*(address:string, tokenId: int): string  = 
  let nft = web3Client.contractSender(StarLight, Address.fromHex address)
  var data = waitFor nft.tokenURI(tokenId.u256).call()
  var length = strutils.fromHex[int](data[64 .. 127])
  result = data[128 .. 128 + length*2 - 1].parseHexStr

proc getName*(address:string): string  = 
  let nft = web3Client.contractSender(StarLight, Address.fromHex address)
  var data = waitFor nft.name().call()
  var length = strutils.fromHex[int](data[64 .. 127])
  result = data[128 .. 128 + length*2 - 1].parseHexStr

proc getTotalSupply*(address:string): UInt256  = 
  let nft = web3Client.contractSender(StarLight, Address.fromHex address)
  result = waitFor nft.totalSupply().call()

proc getOwner*(address:string, tokenId: int): string =
  let nft = web3Client.contractSender(StarLight, Address.fromHex address)
  result = $(waitFor nft.ownerOf(tokenId.u256).call())
  
proc getItems*(address:string, tokenId: int): string =
  let nft = web3Client.contractSender(DFSNFT, Address.fromHex address)
  result = $(waitFor nft.getItems(tokenId.u256).call())

when isMainModule:
  # var account = Address.fromHex "0x657eEfd3e1712d152430bc3D35e9c40Db474e9b6"
  # var client = waitFor newWeb3("https://icy-weathered-violet.bsc.quiknode.pro/0617462be53bb10061e99025fa2cd12893fb6efb/")
  # var balance = waitFor client.provider.eth_getBalance(account, "latest")
  # echo balance
  var ts = getTotalSupply(startLightAddress).toInt()
  var owner = getOwner(startLightAddress,0)
  var uri = getTokenURI(startLightAddress,0)
  
  var item = getItems(dfsNFTAddress, 0)

  echo item
