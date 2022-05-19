import web3
import chronos, nimcrypto, options, json, stint, parseutils, strutils, strformat, times
import eth/keys

contract(ERC20):
  proc approve(spender:Address, amount:Uint256)
  proc balanceOf(owner: Address): Uint256 {.view.}

contract(PancakeRouter):
  proc WETH():Address
  proc getAmountOut(number: Uint256, to: Address): seq[Uint]
  proc removeLiquidityETHSupportingFeeOnTransferTokens(token:Address, liquidity: Uint, amountTokenMin,amountEthMin:Uint256, to:Address, deadLine: Uint): Uint {.view.}
  # proc swapExactTokensForTokens(amountIn: Uint256, amountOutMin: Uint256, path: openArray[Address] , to: Address, deadLine:Uint256)

type Participants = ref object
  addresses: seq[Address]
  
contract(PMLS):
    proc balanceOf(user: Address): Uint256 {.view.}
    proc getParticipants(): seq[Address] {.view.}

const target = "0x2e2c4c8288AE9143135EA04Ef432267F7daF62ae"
const pancakeRouterAddress = "0x10ED43C718714eb63d5aA57B78B54704E256024E" #mainnet
const mebAddress = "0x7268B479eb7CE8D1B37Ef1FFc3b82d7383A1162d" #mainnet
const eggAddress = "0x093a48153ba159D3c3A87C91448b99e77C72eaf5" #mainnet
const pancakePair = "0xeFc38B0A941AAA2958CD79765E9a5376182548B3" #mainnet
# const usdtAddress = "0xc362B3ed5039447dB7a06F0a3d0bd9238E74d57c"
const usdtAddress = "0x55d398326f99059fF775485246999027B3197955" #mainnet
# const pmlsAddress = "0xdaBeF048B7DaB6f10638f59Debde38B1c35bB1B0" #mainnet
const pmlsAddress = "0x89e0ca90Fd8a3CAeF18c915A8E9b3afa591Ea075" #testnet

const UINT256MAX = ("115792089237316195423570985008687907853269984665640564039457584007913129639935").u256
# 0000000000000000000000000000000000000000000000000000000000000020
# 00000000000000000000000000000000000000000000000000000000000000b6
# 0000000000000000000000002f727804856c51b6dd4b53e155957b731eb004d2000000000000000000000000b89d6f2b612703882e3f13c7a177b72fbb77d167000000000000000000000000132b1956f03e4dfffde793840544fb7494f79a13000000000000000000000000e10e296cbc7fe6e798143a72ddbba8541140a65f000000000000000000000000bf1fed8fdee08fe70e880ec14d20a71bdd45505600000000000000000000000082e315f3fdb4babbf80ad7ddb3cdcd4fe37ae4810000000000000000000000005378e3c540652d640e53a12ee5389ee07593f329000000000000000000000000abc531ec81bd78af78f4f45c361cf743a662dd7a000000000000000000000000381e2f9c49d6d5fc90ee7ace6c1b6c5b5bc6022b0000000000000000000000008ac126ee3a83d89b37afa72839b11372f5486c810000000000000000000000000b23934dfec73e7e3244f1f156764428dff3427e0000000000000000000000009d22e0dbdeb1e49175311e87411b307b108efc340000000000000000000000005992b6733d91a72dffbb770d1072bb8460716e3f000000000000000000000000799dde6159fe318b02ac9a64f8fbb30345f40c06000000000000000000000000a17a1d8c535561bbf801757149c1e3ff6a8a7138000000000000000000000000e564c1994aedad4a23ed0fd1599a3d316d48b2c0000000000000000000000000966480092aaed57512cb10d9f70e898fa9f666ee0000000000000000000000002182ace58b916315a92cb7d85703f2672775967f0000000000000000000000002b006ea6a242f132b3ee9d46db109367d467dac30000000000000000000000000f67922eea396d29c7df33b2858e605ec8637c8a000000000000000000000000030460788dd86e354ef579683e757a0cf59608c400000000000000000000000018cd8a6ba4a0072afbd79d12031e7ce0ea47ce38000000000000000000000000ed97069cb849ea57a4cdb8b125b431d30db0d87400000000000000000000000041600dbfd9099e791801fd2c609c45325c8e098b0000000000000000000000003cddd7b1a3bde92798a7068a3285fafaa40e09b1000000000000000000000000b7a57dfbe9e77253e975f0a9342bb07b8388f509000000000000000000000000a605f4751aee74208a91c0a2049305ee54d8b0420000000000000000000000007dda47e2abc563b1406602ab63e78f66d21be7e6000000000000000000000000ddf3a3e257fd47d191f7ae0a5a4bc16bf44406670000000000000000000000005ea722d4a59deb4750b5dbf385157b682e21ed41000000000000000000000000a462b14bc592d79ae3eb740d9117b5ca230be858000000000000000000000000e61bd966838b88cfaeb922e8d0b2a746aaebe8e000000000000000000000000089448bd778e2430ed52673cab3dd8ddc581817c90000000000000000000000000646e920c8c72f4563afe430e69ef3cb0d22cd700000000000000000000000009735385358d4ca82a3a057cafa2f9f14906556350000000000000000000000002d13c1126db006163b9207b54cbaee055abb3d0500000000000000000000000050fcf3b8647c0e81d271abd3cf84032993cf000c000000000000000000000000e50c7e4b64d2008c8ef6dbdcaddb1d5a7fa2217400000000000000000000000004029a92a9f3cc0c37e1365dbb1d0d403187b087000000000000000000000000d0b851131f7210b0c311d3378203fcfdd65dc97300000000000000000000000074e5fe1bcb983b53d482e19aae397166f9e5d6ab00000000000000000000000082492dcb4c9773217329f0db3a9f1a8b02b466420000000000000000000000000f88d5129be4a2eaf7b04b3006b5fd464c83c6d8000000000000000000000000c77f86fdf3505861dea5ae45da76d46efdb07baf000000000000000000000000110c729c9e1ba09cb407f447c823ef69e5d4c70e000000000000000000000000ad51ca3aed53fba06ff610801a60d28a0706ead1000000000000000000000000e1cea30da351a5bd743ff200e0e5608b93d56a990000000000000000000000001c07c4382cc2b57f37d621b2c5333684a94560860000000000000000000000008ea2566fa2a23ee6714dcf5661f9cdc41e25dd610000000000000000000000009ac1cd3b21800986ffba8dd4221adb377b037d020000000000000000000000002689ae2abfb33c57ac879592231294cef79eb2c4000000000000000000000000f54ff7a7d2d33a2f8102322fcba530caf964d6ce000000000000000000000000fac2fc9b59ece130bda0dd40c8c44a81301b2dc9000000000000000000000000f18c0881b5e0c0114852e634db29bbea5e772e3800000000000000000000000003814855ece4a9420e9781767268ea2161b25cb0000000000000000000000000cb277ddbbaef02a7b65f8963c3c4586e52d06e50000000000000000000000000994b73debee9d24599fa36c25f810a51bd2a80fe0000000000000000000000006d07e765917f0060bbdb711032fb0435ac3f3ffb000000000000000000000000f11f4fb5ce8c36818c0f31145d2684fcff076619000000000000000000000000229e037ebf3c862e648cc2c7334fad0e9a8312ca000000000000000000000000b470270fb527ba21f0bc70461037121cd0217fa00000000000000000000000008ca3a279b80bec249a8c84c147768a4137bebf170000000000000000000000002102cdeafa4d0e5e67d71a391c8ee13c6528b0d2000000000000000000000000dc070f29edd3ff58d54bb67e258e2e272f57cfa30000000000000000000000009d3e8b799bda01d0af90e802b1dd4fa332299d1e0000000000000000000000009a12285b5756c73ff74c2b7e6cee485c98efe3f40000000000000000000000000eb911f120bc2a06049d82b2941a2504ec614d56000000000000000000000000d0c639e43fca8d9ed2ffa7fe76133237974c6c5800000000000000000000000082fa9d779d8b9388cbe992ff292ac0041e5e21780000000000000000000000002f7d756a9aeeb69241a84f4b9ca7d34f2bb6a8c7000000000000000000000000944f0eaf65282bad0e6a90b2041bbb0577123a120000000000000000000000004dc5e762979e1c63187a1b8d12c90182b89848e20000000000000000000000002bbe9cdabab471c3b25c8f68c1c4decebcf313280000000000000000000000002f7c378434b8327e872ec06f54dafea32bb39c17000000000000000000000000b28db1ec49f50a332243b404acbfe045ee94e3910000000000000000000000001db9687ab7fb31d8c8909aab9a74eb55a9e2596c000000000000000000000000029fdf7f2e409cbc08449126035efb58f518153400000000000000000000000061debe098dc37ff71c199dd69b314a88b60817ca000000000000000000000000fd1737033b4cb816cfc50363705074030e94f5f00000000000000000000000002ea99c4accf4b84e8825855bf5f1527d1dc3f990000000000000000000000000038a109dd605656234f46f2190e0b93d8c70c56c000000000000000000000000d0349bbc6ce94b6b684616746dbb7b25caabb09c000000000000000000000000d4fabb371df174fc5d9e7c77c90a3231afb0ba27000000000000000000000000ce3af71a5827de951cb98aea260ec891317248310000000000000000000000006d67bb35f178622bebcb349d9dba79d7566dd4890000000000000000000000002386676db49c3baa2a84239b77ba424dd12d212b0000000000000000000000004d8eaff3d295c0f4f8003be37327b31afb227c9100000000000000000000000090ebf7ee7c850662e0e584536c2a8907f0e1b94000000000000000000000000016eb7879c4d80ecb694bd48731ff0acfbb381fd8000000000000000000000000761e7cd1b140e9334ecc73ca5b22dad8277dc9fd0000000000000000000000008d7b7c13265ddbd1be56327bf214f929cf0c995900000000000000000000000071ce140e3e428d5f640aaf3a128188f1af80cb2a00000000000000000000000042e66f70bd4255a05fbfb08f9c3011d9813a2d1b0000000000000000000000003cf4826d95830e1852ba34a940804cd2250176d50000000000000000000000001ef17012a964049cd058188de8429cb89c7b1358000000000000000000000000ff490f8fe7bc7272c588234a4e6b22ab53f0e7850000000000000000000000003d5c32c354487bd18bbbd3d420d56a74b9952efe0000000000000000000000001ff76eb3aef1b557182d8f36ed2b26db36cd7d5e00000000000000000000000024ec3c89e08145707be7455eea3b6c3ca155702000000000000000000000000030f0287796362f659e341edd24b2bbc23f2b14f3000000000000000000000000bcfbf0429d68342c69a0978fbde91b4e1094ffbc0000000000000000000000005bbc09a55885c9f1ee56dd9c71a4ea74a987cdbd0000000000000000000000003afa0c729a439751beb812a44f902405d621ff7e000000000000000000000000d2e514235538b1f3eef308c76d4347551f763be3000000000000000000000000970c0d5f0eb76ba449b29827ccb9abf413cdbbc0000000000000000000000000116b5a7b86f37c653f6f8995fc773525279999af0000000000000000000000005cc953709edb30e693a711f34656d1e25a61fb9a000000000000000000000000d97ccc9d342b5bc78503881bb93f11c7f50f4ff80000000000000000000000009778ca76011efb9babd4f3d2b038a9da7e2ecbbf0000000000000000000000000df49793e8e9f810694db08d80ca3ebebb743a7b000000000000000000000000d91fb5db426b72adec2320d2fc02006ab8194c4c000000000000000000000000a4c5e122ddd75d1d2a2b1ec10e7f53896d3262840000000000000000000000004fc960f95ac39be8b66d62a253347aea3c8ea834000000000000000000000000351317285a05261a82dc22c6bb22e8a3d702e887000000000000000000000000c1ffe039496654a7d054af10ba85ea204655f2ce0000000000000000000000003af185098400f17ae0b70a2e2fc4625cb59cbc7b000000000000000000000000debc54376f04c69fbbae1597f9aa1b5ee14dd58300000000000000000000000015b732103f267f74c2e960630b9f045a6cdbdfda000000000000000000000000ce17d70663a6cf82f760c350c2119816921c4610000000000000000000000000af84b825aff7e7ef45db23218a9fe654bd5e30fa0000000000000000000000003a4ac3585530aaf4c9c1f63581c482a95ebb5e0300000000000000000000000038ce24d1266b316aed1aea340a4f04f1e44ea1bb0000000000000000000000003e4d0169cfb32b76d5fe07a56b605d52ed106b1f0000000000000000000000000c675150922d9cb1a63b26e01f58c04208223a07000000000000000000000000fcfa1e649d2bbf66a782a16b440de47cd2bfd02a0000000000000000000000003955c8586931ca52fbc79d6ffc655beed22f222100000000000000000000000008611b652d1e4375899e0199dfe5bf4d1eeeb86200000000000000000000000080c33d3b8e9eda16a511bd3d7dfdb1b86e86e99100000000000000000000000038be8b32fae60ab871b1ff99ea662c781d7db024000000000000000000000000eb368a7b69efe534a0b25d632ec04f4e2fd786280000000000000000000000009e4590b30ec3ca82a9bd940690b5a41cf1181f310000000000000000000000007728a5b72f3e3c67a2056ebcaed2347071de49b600000000000000000000000045711147208e420060a1c769ed3f4c11e84a44e7000000000000000000000000986df6417f43f98434253cd67aa339ee30d6f7a70000000000000000000000003213d84bfdab433b7674ac7d9768f6c5363a1335000000000000000000000000c9513c23578ee613cb0c700691edc062b36d67c20000000000000000000000006a615ef4b980a6597dc2aa8b7179d7e6c60db8630000000000000000000000002a40e9ce411aadabf29333b929462c1d91f5bff6000000000000000000000000d3562152ce1744ae2f04ea71b543d6757e4833e10000000000000000000000007191cf857e827bea2a05d820bb795b89ad3d8ec9000000000000000000000000d6c9ecea8abef43639338f458dac5241a57b62b9000000000000000000000000fc31af21cf9cb279815e00e9382c5777bc478878000000000000000000000000a2078b9a286a9da12c32036f96737b0f84d461d00000000000000000000000006d7bae88a13f27414298781cc734c93cc78f1aca0000000000000000000000007a673f7fd457375e29a4db48f93d55cc00ee3af600000000000000000000000052cc083fbdeb01e6592ee0a987bb978c81a2fdfe0000000000000000000000001e83c135d83b5c17066eb9998dc2040627eac3c7000000000000000000000000426581fc8e1a8f8e5478961b02fc4f280fca6f3d0000000000000000000000004b69dbdf25dad9b5d325110c99546c0fd4b42e4400000000000000000000000062c702a5432e36b15f522ce601cab087fd353e2a0000000000000000000000006c8bf330536ce7accff164be71f8ebe3e6da1287000000000000000000000000a713f0bf19d20a1cfcbe404362309495af961a3a0000000000000000000000001c520e428f9a4c6173492e797ac2aa763cb465afcc9e427d100000000000000000000000013a5bd32dd8e3d99cf715d5a19d9ddc4a54e550800000000000000000000000067113a4a7a7ee9b7653d817f723bd6dfde04d658
# 0000000000000000000000006e80ff2e175a1244673fdc7e1caf1d2dfdcdc4cf000000000000000000000000fc830a033786eb61460ecc00006f8f87c7a9a62d0000000000000000000000000cc416837f7aec7ada3c16cd4a20a6b3edb7d978000000000000000000000000f5a0b6a233314d829836cbe08f279b972d4f432d0000000000000000000000008fc1560db6fdcf74c40145e3e2fd673978b107a6000000000000000000000000cbbe2ae7454394d37c5635549a0fb6689b86365800000000000000000000000028badf90a76dc288cc2bc9cfd1c04950ef8c64b2000000000000000000000000ed361da8b461bff3c819b46ff41b38155fc0aa8d00000000000000000000000089ae929dbd9647c64fd8287a75ab2c61dc73bcf6

proc asynctest {.async.} =
    var web3 = await newWeb3("https://data-seed-prebsc-1-s1.binance.org:8545/")
    # var web3 = await newWeb3("https://icy-weathered-violet.bsc.quiknode.pro/0617462be53bb10061e99025fa2cd12893fb6efb/")

    let pmls = web3.contractSender(PMLS, Address.fromHex pmlsAddress)
    let router = web3.contractSender(PancakeRouter, Address.fromHex pancakeRouterAddress)
    # let egg = web3.contractSender(ERC20, Address.fromHex eggAddress)
    # let meb = web3.contractSender(ERC20, Address.fromHex mebAddress)
    # let usdt = web3.contractSender(ERC20, Address.fromHex usdtAddress)
    web3.defaultAccount = Address.fromHex "0x389c5D2064Ec4e2408b414f286F1580F60E69089"
    web3.privateKey = some PrivateKey.fromHex("51c7ef5ba734e02951394185482789099524de5eea69111e381e60c7be11b1f8").tryGet()
    var pmlsBalance = await pmls.balanceOf(web3.defaultAccount).call()
    echo pmlsBalance
    var participants = await pmls.getParticipants().call()
    echo participants
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


waitFor asynctest()
