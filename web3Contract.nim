import web3
import chronos, nimcrypto, options, json, stint, parseutils, strutils, strformat, times
import eth/keys

contract(StarLight):
  proc tokenURI(tokenId: Uint256): string {.view.}
  proc totalSupply(): Uint256 {.view.}
  
# contract(ERC20):
#   proc approve(spender:Address, amount:Uint256)
#   proc balanceOf(owner: Address): Uint256 {.view.}

# contract(PancakeRouter):
#   proc WETH():Address
#   proc getAmountOut(number: Uint256, to: Address): seq[Uint]
#   proc removeLiquidityETHSupportingFeeOnTransferTokens(token:Address, liquidity: Uint, amountTokenMin,amountEthMin:Uint256, to:Address, deadLine: Uint): Uint {.view.}
#   # proc swapExactTokensForTokens(amountIn: Uint256, amountOutMin: Uint256, path: openArray[Address] , to: Address, deadLine:Uint256)

# type Participants = ref object
#   addresses: seq[Address]
  
# contract(PMLS):
#     proc balanceOf(user: Address): Uint256 {.view.}
#     proc getParticipants(): seq[Address] {.view.}

# const target = "0x2e2c4c8288AE9143135EA04Ef432267F7daF62ae"
# const pancakeRouterAddress = "0x10ED43C718714eb63d5aA57B78B54704E256024E" #mainnet
# const mebAddress = "0x7268B479eb7CE8D1B37Ef1FFc3b82d7383A1162d" #mainnet
# const eggAddress = "0x093a48153ba159D3c3A87C91448b99e77C72eaf5" #mainnet
# const pancakePair = "0xeFc38B0A941AAA2958CD79765E9a5376182548B3" #mainnet
# # const usdtAddress = "0xc362B3ed5039447dB7a06F0a3d0bd9238E74d57c"
# const usdtAddress = "0x55d398326f99059fF775485246999027B3197955" #mainnet
# # const pmlsAddress = "0xdaBeF048B7DaB6f10638f59Debde38B1c35bB1B0" #mainnet
# const pmlsAddress = "0x89e0ca90Fd8a3CAeF18c915A8E9b3afa591Ea075" #testnet

# const UINT256MAX = ("115792089237316195423570985008687907853269984665640564039457584007913129639935").u256
# 
# proc asynctest {.async.} =
#     var web3 = await newWeb3("https://data-seed-prebsc-1-s1.binance.org:8545/")
#     # var web3 = await newWeb3("https://icy-weathered-violet.bsc.quiknode.pro/0617462be53bb10061e99025fa2cd12893fb6efb/")

#     let pmls = web3.contractSender(PMLS, Address.fromHex pmlsAddress)
#     let router = web3.contractSender(PancakeRouter, Address.fromHex pancakeRouterAddress)
#     # let egg = web3.contractSender(ERC20, Address.fromHex eggAddress)
#     # let meb = web3.contractSender(ERC20, Address.fromHex mebAddress)
#     # let usdt = web3.contractSender(ERC20, Address.fromHex usdtAddress)
#     web3.defaultAccount = Address.fromHex "0x389c5D2064Ec4e2408b414f286F1580F60E69089"
#     web3.privateKey = some PrivateKey.fromHex("51c7ef5ba734e02951394185482789099524de5eea69111e381e60c7be11b1f8").tryGet()
#     var pmlsBalance = await pmls.balanceOf(web3.defaultAccount).call()
#     echo pmlsBalance
#     var participants = await pmls.getParticipants().call()
#     echo participants
    # for p in participants:
    #     var usdtBalance = pmls.getBalance(p)
    #     var pmlsBalance = pmls.balances(p)
        
    # var now = getTime().toUnix + 60
    # echo now
    # discard await usdt.approve(Address.fromHex pancakeRouterAddress, UINT256MAX).send(gas = 210000, gasPrice = 1000000000)
    
    # discard await egg.approve(Address.fromHex pancakeRouterAddress, UINT256MAX).send(gas = 210000, gasPrice = 1000000000)
    # discard await meb.approve(Address.fromHex pancakeRouterAddress, UINT256MAX).send(gas = 210000, gasPrice = 1000000000)

    # echo await pancakeRouter.swapExactTokensForTokens(UINT256MAX,UINT256MAX,[usdtAddress, mebAddress],  web3.defaultAccount, now).send(gas = 210000, gasPrice = 1000000000)
    # echo await pancakeRouter.swapExactTokensForTokens(UINT256MAX,UINT256MAX,[mebAddress, eggAddress], web3.defaultAccount, now).send(gas = 210000, gasPrice = 1000000000)

    # echo await pancakeRouter.swapExactTokensForTokens(UINT256MAX,UINT256MAX,[eggAddress, mebAddress], web3.defaultAccount, now).send(gas = 210000, gasPrice = 1000000000)
    # echo await pancakeRouter.swapExactTokensForTokens(UINT256MAX,UINT256MAX,[mebAddress, usdtAddress], web3.defaultAccount, now).send(gas = 210000, gasPrice = 1000000000)

const startLightAddress* = "0x69E01E8AdA552DFd66028D7201147288Ea6470de"
var web3Client = waitFor newWeb3("https://data-seed-prebsc-1-s1.binance.org:8545/")
let starlight = web3Client.contractSender(StarLight, Address.fromHex startLightAddress)

proc getTokenURI*(tokenId: int): string  = 
  result = waitFor starlight.tokenURI(tokenId.u256).call()

proc getTotalSupply*(): UInt256  = 
  result = waitFor starlight.totalSupply().call()

when isMainModule:
  # var account = Address.fromHex "0x657eEfd3e1712d152430bc3D35e9c40Db474e9b6"
  # var client = waitFor newWeb3("https://icy-weathered-violet.bsc.quiknode.pro/0617462be53bb10061e99025fa2cd12893fb6efb/")
  # var balance = waitFor client.provider.eth_getBalance(account, "latest")
  # echo balance
  var ts = getTotalSupply().toInt()
  echo "totalSupply:", ts