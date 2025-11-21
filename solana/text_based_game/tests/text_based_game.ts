import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { expect } from "chai";
import { TextBasedGame } from "../target/types/text_based_game";
import { PublicKey, Connection, Keypair, SystemProgram } from "@solana/web3.js";
import type { AnchorError } from "@coral-xyz/anchor";
const { LAMPORTS_PER_SOL } = anchor.web3;

const userInitializeTest = "User Initialize Test";
const userNameTooShortTest = "User Name Too Short Test";
const userNameTooLongTest = "User Name Too Long Test";

describe("initialize instruction test", () => {
  let program: Program<TextBasedGame>;
  let provider: anchor.AnchorProvider;
  let connection: Connection;

  // Set up the provider and program before tests
  before(async () => {
    connection = new Connection("http://localhost:8899", "finalized");
    const wallet = anchor.Wallet.local();
    provider = new anchor.AnchorProvider(
      connection,
      wallet,
      { preflightCommitment: "finalized" }
    );
    anchor.setProvider(provider);
    program = anchor.workspace.TextBasedGame as Program<TextBasedGame>;
  });

  async function createTestEnvironment(step: string = "") {
    // 1. Create a new signer
    const signer = Keypair.generate();
    console.log("******************************************************************************");
    console.log(`Step: ${step} => Signer address:`, signer.publicKey.toString());
    console.log("******************************************************************************");

    // 2. Request airdrop for current signer
    const airdropTx = await connection.requestAirdrop(
      signer.publicKey,
      2 * LAMPORTS_PER_SOL
    );

    // 3. Confirm the airdrop transaction
    await connection.confirmTransaction(
      {
        signature: airdropTx,
        blockhash: (await connection.getLatestBlockhash("finalized")).blockhash,
        lastValidBlockHeight: (await connection.getLatestBlockhash("finalized")).lastValidBlockHeight,
      },
      "finalized"
    );

    // 4. Derive the PDA and bump for the signer
    const [userPda, expectedBump] = PublicKey.findProgramAddressSync(
      [Buffer.from("user"), signer.publicKey.toBuffer()],
      program.programId
    );
    console.log("******************************************************************************");
    console.log(`Step: ${step} => PDA address:`, userPda.toString());
    console.log(`Step: ${step} => PDA bump:`, expectedBump.toString());
    console.log("******************************************************************************");

    return { signer, userPda, expectedBump };
  }

  function formattedLog(log: string) {
      console.log("*************************************************************************************************");
      console.log(log);
      console.log("*************************************************************************************************");
  }

  it(userInitializeTest, async () => {
    const { signer, userPda, expectedBump } = await createTestEnvironment(userInitializeTest);

    const validName = "kilin";
    const tx = await program.methods
      .initialize(validName)
      .accountsStrict({
        signer: signer.publicKey,
        pda: userPda,
        systemProgram: SystemProgram.programId,
      })
      .signers([signer])
      .rpc();
    await provider.connection.confirmTransaction(tx, "confirmed");

    // Fetch and verify PDA account data
    const userAccount = await program.account.user.fetch(userPda);
    expect(userAccount.name).to.equal(validName);
    expect(userAccount.gold).to.equal(0);
    expect(userAccount.exp).to.equal(0);
    expect(userAccount.bump).to.equal(expectedBump);
    expect(userAccount.authority.toString()).to.equal(signer.publicKey.toString());
    formattedLog(`Step: ${userInitializeTest} => successfully`);
  });
 
  it(userNameTooShortTest, async () => {
    const { signer, userPda } = await createTestEnvironment(userNameTooShortTest);
    const shortName = "A";
    try {
      await program.methods
        .initialize(shortName)
        .accountsStrict({
          signer: signer.publicKey,
          pda: userPda,
          systemProgram: SystemProgram.programId,
        })
        .signers([signer])
        .rpc();
      expect.fail("Transaction should have failed with UserNameTooShort");
    } catch (err) {
      // Print the full error  
      formattedLog(`Step: ${userNameTooShortTest} => Full error: ${JSON.stringify(err, null, 2)}`);
      // print on-chain logs
      if ("logs" in err && err.logs) {
        console.log("On-chain logs:", err.logs.join("\n"));
      }
      expect(err).to.be.instanceOf(anchor.AnchorError, "Expected an AnchorError");
      const anchorErr = err as AnchorError;
      formattedLog(`Step: ${userNameTooShortTest} => Expected error caught: ${{
        programId: anchorErr.program.toString(),
        errorCode: anchorErr.error.errorCode,
        errorMsg: anchorErr.error.errorMessage,
      }}`);
      expect("UserNameTooShort").to.equal(anchorErr.error.errorCode.code, "Error code should match UserNameTooShort");
      expect("User name is too short.").to.equal(anchorErr.error.errorMessage, "Error message should match");
      formattedLog(`Step: ${userNameTooShortTest} successfully`);
    }
  });

  it(userNameTooLongTest, async () => {
    const { signer, userPda } = await createTestEnvironment(userNameTooLongTest);
    const longName = "ThisNameIsWayTooLongForTheUserAccount";
    try {
      await program.methods
        .initialize(longName)
        .accountsStrict({
          signer: signer.publicKey,
          pda: userPda,
          systemProgram: SystemProgram.programId,
        })
        .signers([signer])
        .rpc();
      expect.fail("Transaction should have failed with UserNameTooLong");
    } catch (err) {
      // Print the full error  
      formattedLog(`Step: ${userNameTooLongTest} => Full error: ${JSON.stringify(err, null, 2)}`);
      // print on-chain logs
      if ("logs" in err && err.logs) {
        console.log("On-chain logs:", err.logs.join("\n"));
      }
      expect(err).to.be.instanceOf(anchor.AnchorError, "Expected an AnchorError");
      const anchorErr = err as AnchorError;
      formattedLog(`Step: ${userNameTooLongTest} => Expected error caught: ${{
        programId: anchorErr.program.toString(),
        errorCode: anchorErr.error.errorCode,
        errorMsg: anchorErr.error.errorMessage,
      }}`);
      expect("UserNameTooLong").to.equal(anchorErr.error.errorCode.code, "Error code should match UserNameTooLong");
      expect("User name is too long.").to.equal(anchorErr.error.errorMessage, "Error message should match");
      formattedLog(`Step: ${userNameTooLongTest} successfully`);
    }
  });
});
