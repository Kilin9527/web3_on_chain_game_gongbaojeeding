import * as anchor from "@coral-xyz/anchor";
import { getInitializeAccounts, setupTest, TestContext, expect } from "./utils/setup";
import { beforeEach } from "mocha";

const VALID_NAME = "kilin";
const USER_NAME_TOO_SHORT_TEST = "a";
const USER_NAME_TOO_LONG_TEST = "ThisNameIsWayTooLongForTheUserAccount";

describe("initialize instruction test", () => {
    let context: TestContext;

    beforeEach(async () => {
        context = await setupTest();
    });

  it("should successfully initialize user account", async () => {
    const tx = await context.program.methods
      .initialize(VALID_NAME)
      .accountsStrict(getInitializeAccounts(context))
      .signers([context.signer])
      .rpc();
    await context.provider.connection.confirmTransaction(tx, "confirmed");

    const userAccount = await context.program.account.user.fetch(context.userPda);
    expect(userAccount.name).to.equal(VALID_NAME);
    expect(userAccount.gold).to.equal(0);
    expect(userAccount.exp).to.equal(0);
    expect(userAccount.authority.toString()).to.equal(context.signer.publicKey.toString());
  });
 
  it("should fail to initialize user account with a name that is too short", async () => {
    const transaction = context.program.methods
        .initialize(USER_NAME_TOO_SHORT_TEST)
        .accountsStrict(getInitializeAccounts(context))
        .signers([context.signer])
        .rpc();

    await expect(transaction).to.be.rejectedWith(/UserNameTooShort/);
  });

  it("should fail to initialize user account with a name that is too long", async () => {
    const transaction = context.program.methods
        .initialize(USER_NAME_TOO_LONG_TEST)
        .accountsStrict(getInitializeAccounts(context))
        .signers([context.signer])
        .rpc();

    await expect(transaction).to.be.rejectedWith(/UserNameTooLong/);
  });
});
