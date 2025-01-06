// 移除 require，因为我们在浏览器环境中
// const ethers = require('ethers');

async function signSwapTransaction(params) {
    try {
        const {
            privateKey,
            tokenAddress,
            amountIn,
            amountOut,
            entryAddress,
            chainId = 80002
        } = params;

        // 创建钱包实例
        const wallet = new ethers.Wallet(privateKey);
        
        // 获取当前时间戳（1小时后过期）
        const deadline = Math.floor(Date.now() / 1000) + 3600;

        // 构建 EIP-712 类型数据
        const domain = {
            name: 'entry',
            version: '1',
            chainId: chainId,
            verifyingContract: entryAddress
        };

        const types = {
            SwapETH: [
                { name: 'owner', type: 'address' },
                { name: 'token', type: 'address' },
                { name: 'amountIn', type: 'uint256' },
                { name: 'amountOut', type: 'uint256' },
                { name: 'nonce', type: 'uint256' },
                { name: 'deadline', type: 'uint256' },
            ],
        };

        // 构建待签名的数据
        const value = {
            owner: wallet.address,
            token: tokenAddress,
            amountIn: amountIn,
            amountOut: amountOut,
            nonce: '1', // 这里需要从合约获取实际的 nonce
            deadline: deadline.toString(),
        };

        // 使用 EIP-712 签名数据
        const signature = await wallet._signTypedData(domain, types, value);
        
        return {
            success: true,
            signature: signature,
            data: {
                domain,
                types,
                value
            }
        };
    } catch (error) {
        console.error('Signing error:', error);
        return {
            success: false,
            error: error.message || error.toString()
        };
    }
}

// 不需要 module.exports，因为我们在浏览器环境中 