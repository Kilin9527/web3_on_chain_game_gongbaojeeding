import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { PublicKey, Connection, Keypair, SystemProgram } from "@solana/web3.js";
import { TextBasedGame } from "../../target/types/text_based_game";
import { formattedLog } from "./helper";
import * as chai from "chai";
import chaiAsPromised from "chai-as-promised";

chai.use(chaiAsPromised);
export const expect = chai.expect;

const { LAMPORTS_PER_SOL } = anchor.web3;
const TEST_AIRDROP_AMOUNT = 2 * LAMPORTS_PER_SOL;

export interface TestContext {
    provider: anchor.AnchorProvider;
    program: Program<TextBasedGame>;
    signer: Keypair;
    userPda: PublicKey;
    connection: Connection;
}

export async function setupTest(programId?: PublicKey): Promise<TestContext> {
    // 1. Create a connection
    const connection = new Connection(
        process.env.SOLANA_RPC_URL || "http://localhost:8899",
        "finalized"
    );

    // 2. Create a signer and airdrop SOL
    const signer = Keypair.generate();
    formattedLog(`create signer ${signer.publicKey.toString()}`);
    const airdropTx = await connection.requestAirdrop(
        signer.publicKey,
        TEST_AIRDROP_AMOUNT
    );
    await connection.confirmTransaction(airdropTx, "finalized");

    // 3. Set up the Provider
    const wallet = new anchor.Wallet(signer);
    const provider = new anchor.AnchorProvider(
        connection,
        wallet,
        { preflightCommitment: "finalized" }
    );
    anchor.setProvider(provider);

    // 4. Get the Program instance
    const program = anchor.workspace.TextBasedGame as Program<TextBasedGame>;
    formattedLog(`program instance for ${program.programId.toString()}`);

    // 5. Derive the PDA
    const [userPda, bump] = PublicKey.findProgramAddressSync(
        [Buffer.from("user"), signer.publicKey.toBuffer()],
        program.programId
    );
    formattedLog(`derived user PDA: ${userPda.toString()}`);
    formattedLog(`derived user bump: ${bump.toString()}`);

    return {
        provider,
        program,
        signer,
        userPda,
        connection,
    };
}

export function getInitializeAccounts(context: TestContext) {
    return {
        signer: context.signer.publicKey,
        pda: context.userPda,
        systemProgram: SystemProgram.programId,
    }
}