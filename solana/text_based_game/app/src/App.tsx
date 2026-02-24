import { useState } from 'react';
import { useAnchorWallet, useConnection } from '@solana/wallet-adapter-react';
import { WalletMultiButton } from '@solana/wallet-adapter-react-ui';
import { Program, AnchorProvider, web3 } from '@coral-xyz/anchor';
import idl from './text_based_game.json';

const PROGRAM_ID_STRING = import.meta.env.VITE_PROGRAM_ID || "";
console.log("使用的 PROGRAM_ID:", PROGRAM_ID_STRING);
const PROGRAM_ID = new web3.PublicKey(PROGRAM_ID_STRING);
const GATEWAY_BASE = import.meta.env.VITE_GATEWAY_URL || "https://gateway.pinata.cloud";

interface ConfigAccount {
  admin: web3.PublicKey;
  pendingAdmin: web3.PublicKey | null;
  configCid: string;
}

function App() {
  const { connection } = useConnection();
  const wallet = useAnchorWallet();
  const [cid, setCid] = useState<string>("");
  const [configData, setConfigData] = useState<any>(null);
  const [status, setStatus] = useState("");

  const getProgram = () => {
    if (!wallet) return null;
    const provider = new AnchorProvider(connection, wallet, {
      preflightCommitment: 'processed',
    });

    return new Program(idl as any, provider);
  };

  const handleInitialize = async () => {
    if (!wallet) {
      setStatus("请先连接钱包！");
      return;
    }

    const program = getProgram();
    if (!program) return;

    try {
      setStatus("正在交易中...");

      const SEED_PREFIX = "Config";
      const [configPDA, _] = await web3.PublicKey.findProgramAddressSync(
        [Buffer.from(SEED_PREFIX)],
        PROGRAM_ID
      );
      console.log("找到 Config PDA 地址:", configPDA.toString());

      const configCid = "bafkreihlgy32wabo2plxgr3hkqk2efupg5xg4cv25iophyu6p23pqoygoa";

      const instruction: any = program.idl.instructions.find(i => i.name === 'initializeConfig');
      console.log("需要的账户列表:", instruction.accounts);

      const tx = await program.methods
        .initializeConfig(configCid)
        .accounts({
          config: configPDA,
          admin: wallet.publicKey,
          systemProgram: web3.SystemProgram.programId,
        })
        .rpc();

      console.log("交易成功，签名:", tx);
      setStatus(`初始化成功! 交易哈希: ${tx}`);
    } catch (error: any) {
      console.error(error);
      setStatus(`失败: ${error.message}`);
    }
  };

  const fetchConfig = async () => {
    const program = getProgram();
    if (!program) {
      setStatus("请先连接钱包");
      return;
    }

    try {
      setStatus("正在读取链上数据...");

      const [configPDA] = web3.PublicKey.findProgramAddressSync(
        [Buffer.from("Config")],
        PROGRAM_ID
      );
      console.log("读取 PDA 地址:", configPDA.toString());

      const account = await program.account.config.fetch(configPDA) as ConfigAccount;

      console.log("链上账户数据:", account);

      const ipfsCid = account.configCid;
      setCid(ipfsCid);
      setStatus(`链上读取成功，CID: ${ipfsCid}。正在请求 IPFS...`);

      if (ipfsCid) {
        const gatewayUrl = `${GATEWAY_BASE}/ipfs/${ipfsCid}`;

        const response = await fetch(gatewayUrl);
        if (!response.ok) {
          throw new Error(`IPFS 请求失败: ${response.statusText}`);
        }

        const jsonContent = await response.json();
        console.log("IPFS 文件内容:", jsonContent);
        setConfigData(jsonContent);
        setStatus("配置文件读取完成！");
      } else {
        setStatus("链上 CID 为空");
      }

    } catch (error: any) {
      console.error(error);
      setStatus(`读取失败: ${error.message}`);
    }
  };

  return (
    <div style={{ padding: '50px', textAlign: 'center' }}>
      <h1>Solana初始化后台</h1>

      {/* 钱包连接按钮 */}
      <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '20px' }}>
        <WalletMultiButton />
      </div>

      <div style={{ marginTop: '20px' }}>
        <button
          onClick={handleInitialize}
          disabled={!wallet}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            cursor: wallet ? 'pointer' : 'not-allowed'
          }}
        >
          执行初始化 (Initialize)
        </button>
      </div>

      <p style={{ marginTop: '20px', color: 'blue' }}>{status}</p>

      <h2>读取配置测试</h2>
      <button onClick={fetchConfig} disabled={!wallet}>
        读取 Config (Read)
      </button>

      <div style={{ marginTop: '10px' }}>
        <p><strong>状态:</strong> {status}</p>
        <p><strong>链上 CID:</strong> {cid}</p>

        {configData && (
          <div style={{ textAlign: 'left', background: '#f0f0f0', padding: '10px' }}>
            <strong>文件内容预览:</strong>
            <pre>{JSON.stringify(configData, null, 2)}</pre>
          </div>
        )}
      </div>
    </div>
  );
}

export default App;