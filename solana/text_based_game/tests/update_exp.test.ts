import { getInitializeAccounts, setupTest, TestContext, expect } from "./utils/setup";
import { beforeEach } from "mocha";

const EXP_MAX_U32 = 4294967295;
const EXP_NORMAL = 88;

describe("update exp instruction test", () => {
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

    it("should successfully update the exp when updateExp is called with 100", async () => {
        await context.program.methods
            .updateExp(EXP_NORMAL)
            .accountsStrict(getInitializeAccounts(context))
            .signers([context.signer])
            .rpc();
        const updatedAccount = await context.program.account.user.fetch(context.userPda);
        expect(updatedAccount.exp).to.equal(EXP_NORMAL, "Exp should be updated to 100");
    });

    it("should throw ExpOverflow error when updateExp exceeds u32 max", async () => {
        await context.program.methods
            .updateExp(EXP_NORMAL)
            .accountsStrict(getInitializeAccounts(context))
            .signers([context.signer])
            .rpc();

        const overflowTransaction = context.program.methods
            .updateExp(EXP_MAX_U32)
            .accountsStrict(getInitializeAccounts(context))
            .signers([context.signer])
            .rpc();

        await expect(overflowTransaction).to.be.rejectedWith(/ExpOverflow/);
    });
});