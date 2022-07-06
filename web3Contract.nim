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
  proc tokenByIndex(tokenId: Uint256): Uint {.view.}

type MarketItem* = object
  amount*: Uint256
  isItem1155*: Bool
  iserc20*: Bool
  itemId*: Uint
  nftContract*: Address
  tokenId*: Uint256
  seller*: Address
  owner*: Address
  price*: Uint256
  sold*: Bool

contract(NFTMarket):
  proc fetchMarketItems():seq[MarketItem] {.view.}
  
const marketAddress* = "0xc96729d613Bd2F201CC387678Cf3D08eE53184e2"
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

proc getOwnerOf*(address:string, tokenId: int): string =
  let nft = web3Client.contractSender(StarLight, Address.fromHex address)
  result = $(waitFor nft.ownerOf(tokenId.u256).call())
  
proc getItems*(address:string, tokenId: int): string =
  let nft = web3Client.contractSender(DFSNFT, Address.fromHex address)
  result = $(waitFor nft.getItems(tokenId.u256).call())

proc getTokenByIndex*(address:string, index: int): int =
  let nft = web3Client.contractSender(DFSNFT, Address.fromHex address)
  result = toInt waitFor nft.tokenByIndex(index.u256).call()

proc getMarketItems*(): seq[MarketItem] =
  let nft = web3Client.contractSender(NFTMarket, Address.fromHex marketAddress)
  result = waitFor nft.fetchMarketItems().call()

# 0000000000000000000000000000000000000000000000000000000000000020
# 0000000000000000000000000000000000000000000000000000000000000004
# 0000000000000000000000000000000000000000000000000000000000000001 amount
# 0000000000000000000000000000000000000000000000000000000000000000 isItem1155
# 0000000000000000000000000000000000000000000000000000000000000001 iserc20
# 0000000000000000000000000000000000000000000000000000000000000001 itemId
# 00000000000000000000000088ebfd7841d131bceab3e7149217aa8e36985a40 nftContract
# 0000000000000000000000000000000000000000000000000000000000000000 tokenId
# 0000000000000000000000000a24f5df83b3baa3982ace21d051f525f02c5de1 seller
# 0000000000000000000000000000000000000000000000000000000000000000 owner
# 0000000000000000000000000000000000000000000000000000000000000001 price
# 0000000000000000000000000000000000000000000000000000000000000000 sold
# 0000000000000000000000000000000000000000000000000000000000000001
# 0000000000000000000000000000000000000000000000000000000000000000
# 0000000000000000000000000000000000000000000000000000000000000001
# 0000000000000000000000000000000000000000000000000000000000000002
# 00000000000000000000000088ebfd7841d131bceab3e7149217aa8e36985a40
# 0000000000000000000000000000000000000000000000000000000000000005
# 0000000000000000000000003ae89fe2934e89c5e7d9b21ed80c6c3c665fb5bd
# 0000000000000000000000000000000000000000000000000000000000000000
# 0000000000000000000000000000000000000000000000000000000000000001
# 0000000000000000000000000000000000000000000000000000000000000000
# 0000000000000000000000000000000000000000000000000000000000000001
# 0000000000000000000000000000000000000000000000000000000000000000
# 0000000000000000000000000000000000000000000000000000000000000001
# 0000000000000000000000000000000000000000000000000000000000000003
# 00000000000000000000000088ebfd7841d131bceab3e7149217aa8e36985a40
# 0000000000000000000000000000000000000000000000000000000000000006
# 0000000000000000000000003ae89fe2934e89c5e7d9b21ed80c6c3c665fb5bd
# 0000000000000000000000000000000000000000000000000000000000000000
# 0000000000000000000000000000000000000000000000000de0b6b3a7640000
# 0000000000000000000000000000000000000000000000000000000000000000
# 0000000000000000000000000000000000000000000000000000000000000001
# 0000000000000000000000000000000000000000000000000000000000000000
# 0000000000000000000000000000000000000000000000000000000000000001
# 0000000000000000000000000000000000000000000000000000000000000004
# 00000000000000000000000088ebfd7841d131bceab3e7149217aa8e36985a40
# 0000000000000000000000000000000000000000000000000000000000000008
# 0000000000000000000000003ae89fe2934e89c5e7d9b21ed80c6c3c665fb5bd
# 0000000000000000000000000000000000000000000000000000000000000000
# 0000000000000000000000000000000000000000000000000de0b6b3a7640000
# 0000000000000000000000000000000000000000000000000000000000000000
when isMainModule:
  # var account = Address.fromHex "0x657eEfd3e1712d152430bc3D35e9c40Db474e9b6"
  # var client = waitFor newWeb3("https://icy-weathered-violet.bsc.quiknode.pro/0617462be53bb10061e99025fa2cd12893fb6efb/")
  # var balance = waitFor client.provider.eth_getBalance(account, "latest")
  # echo balance
  # var ts = getTotalSupply(startLightAddress).toInt()
  # var owner = getOwnerOf(startLightAddress,0)
  # var uri = getTokenURI(startLightAddress,0)
  
  # var item = getItems(dfsNFTAddress, 0)
  var marketItems= getMarketItems()
  echo marketItems
