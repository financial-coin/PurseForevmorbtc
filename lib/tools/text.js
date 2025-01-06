// 导入需要的 ethers.js 库组件
const { Contract, Wallet, JsonRpcProvider, parseUnits, Interface } = require('ethers');
// 导入智能合约 ABI 和部署信息
const Entry = require('../ignition/deployments/chain-80002/artifacts/V1#Entry.json');  // 入口合约 ABI
const Fund = require('../ignition/deployments/chain-80002/artifacts/V1#FundTest.json'); // 基金合约 ABI
const Address = require('../ignition/deployments/chain-80002/deployed_addresses.json'); // 合约地址配置

// 网络配置
const chainId = 80002;  // Mumbai 测试网的 chainId
const rpcUrl = 'https://rpc-amoy.polygon.technology';  // RPC 节点地址

// 账户私钥配置
// 注意：这个账户需要有足够的 MATIC 支付 gas 费用
// 对应的钱包地址是：0xCDbEf108c920BD4334Bb035bb05EbF3dE34f8f87
const prvKey = '0x28ab5768e28c32870efea2c225148c2d346a133228dc846452a2a8c7df728052';

// 创建 Provider 实例，用于连接区块链网络
const provider = new JsonRpcProvider(rpcUrl);

// 使用私钥创建钱包实例
const signer = new Wallet(prvKey, provider);

// 创建合约实例
const entry = new Contract(Address['V1#Entry'], Entry.abi, signer);  // 入口合约实例
const fund = new Contract(Address['V1#FundTest'], Fund.abi, signer); // 基金合约实例

// 主函数
(async () => {
    // 获取代币合约地址
    const [tokenAddr] = await fund.getProperty();
    // 创建代币合约实例，只包含 approve 方法的接口
    const token = new Contract(tokenAddr, new Interface(["function approve(address spender, uint256 value)"]), signer);

    {
        // 构建 EIP-712 类型数据用于签名
        // domain 用于区分不同的合约和链
        const domain = { 
            name: 'entry',           // 合约名称
            version: '1',            // 版本号
            chainId: chainId,        // 链 ID
            verifyingContract: entry.target  // 验证合约地址
        };

        // 定义 SwapETH 的数据结构
        const types = {
            SwapETH: [
                { name: 'owner', type: 'address' },      // 拥有者地址
                { name: 'token', type: 'address' },      // 代币地址
                { name: 'amountIn', type: 'uint256' },   // 输入金额
                { name: 'amountOut', type: 'uint256' },  // 输出金额
                { name: 'nonce', type: 'uint256' },      // 交易序号
                { name: 'deadline', type: 'uint256' },   // 截止时间
            ],
        };

        // 准备签名数据
        const amountIn = parseUnits('24', 6);    // 输入金额：24 个 6 位精度的代币
        const amountOut = parseUnits('0.002', 18); // 输出金额：0.002 个 18 位精度的代币
        const nonce = await entry.nonces(signer.address); // 获取当前 nonce
        const deadline = Math.floor(new Date().getTime() / 1000) + 3600; // 设置 1 小时后的截止时间

        // 构建待签名的数据
        const value = {
            owner: signer.address,   // 拥有者地址
            token: token.target,     // 代币合约地址
            amountIn,               // 输入金额
            amountOut,              // 输出金额
            nonce,                  // nonce
            deadline,               // 截止时间
        };

        // 使用 EIP-712 签名数据
        const signature = await signer.signTypedData(domain, types, value);
        console.log(value);        // 打印签名数据
        console.log(signature);    // 打印签名结果
    }

})();