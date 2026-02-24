import React, { useMemo } from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';
import { ConnectionProvider, WalletProvider } from '@solana/wallet-adapter-react';
import { WalletAdapterNetwork } from '@solana/wallet-adapter-base';
import { PhantomWalletAdapter } from '@solana/wallet-adapter-wallets';
import { WalletModalProvider } from '@solana/wallet-adapter-react-ui';
import { clusterApiUrl } from '@solana/web3.js';

// 引入默认样式
import '@solana/wallet-adapter-react-ui/styles.css';
import './index.css';

const Root = () => {
    // 设置网络：'devnet', 'testnet', 或 'mainnet-beta'
    // 如果你已经上线主网，这里改成 WalletAdapterNetwork.Mainnet
    const network = WalletAdapterNetwork.Devnet;

    // 获取节点链接
    const endpoint = useMemo(() => clusterApiUrl(network), [network]);

    // 配置钱包（这里只配置了 Phantom）
    const wallets = useMemo(
        () => [
            new PhantomWalletAdapter(),
        ],
        [network]
    );

    return (
        <ConnectionProvider endpoint={endpoint}>
            <WalletProvider wallets={wallets} autoConnect>
                <WalletModalProvider>
                    <App />
                </WalletModalProvider>
            </WalletProvider>
        </ConnectionProvider>
    );
};

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <Root />
    </React.StrictMode>,
);