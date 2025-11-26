import { getInitializeAccounts, setupTest, TestContext, expect } from "./utils/setup";
import { beforeEach } from "mocha";

const GOLD_MAX_I32 = 2147483647;
const GOLD_NEGATIVE = -1;
const GOLD_NORMAL = 100;

describe("update gold instruction test", () => {
    let context: TestContext;

    beforeEach(async () => {
        context = await setupTest();
        const validName = "kilin";
        const tx = await context.program.methods
            .initialize(validName)
            .accountsStrict(getInitializeAccounts(context))
            .signers([context.signer])
            .rpc();
        await context.provider.connection.confirmTransaction(tx, "confirmed");
    });

    it("should successfully update the gold when updateGold is called with 100", async () => {
        await context.program.methods
            .updateGold(GOLD_NORMAL)
            .accountsStrict(getInitializeAccounts(context))
            .signers([context.signer])
            .rpc();
        const updatedAccount = await context.program.account.user.fetch(context.userPda);
        expect(updatedAccount.gold).to.equal(GOLD_NORMAL, "Gold should be updated to 100");
    });

    it("should throw GoldOverflow error when updateGold exceeds i32 max", async () => {
        await context.program.methods
            .updateGold(GOLD_NORMAL)
            .accountsStrict(getInitializeAccounts(context))
            .signers([context.signer])
            .rpc();

        const overflowTransaction = context.program.methods
            .updateGold(GOLD_MAX_I32)
            .accountsStrict(getInitializeAccounts(context))
            .signers([context.signer])
            .rpc();

        await expect(overflowTransaction).to.be.rejectedWith(/GoldOverflow/);
    });

    it("should throw GoldNotEnough error when updateGold is less than 0", async () => {
        const transaction = context.program.methods
            .updateGold(GOLD_NEGATIVE)
            .accountsStrict(getInitializeAccounts(context))
            .signers([context.signer])
            .rpc();

        await expect(transaction).to.be.rejectedWith(/GoldNotEnough/);
    });
});