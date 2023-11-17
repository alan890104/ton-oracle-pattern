import { Blockchain, SandboxContract, prettyLogTransactions, printTransactionFees } from '@ton-community/sandbox';
import { toNano } from 'ton-core';
import { PriceOracle } from '../wrappers/Oracle';
import '@ton-community/test-utils';
import { Caller } from '../wrappers/Caller';

describe('Oracle', () => {
    let blockchain: Blockchain;
    let oracle: SandboxContract<PriceOracle>;
    let callerContract: SandboxContract<Caller>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        oracle = blockchain.openContract(await PriceOracle.fromInit());

        const deployer = await blockchain.treasury('deployer');

        const deployResult = await oracle.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: oracle.address,
            deploy: true,
            success: true,
        });

        callerContract = blockchain.openContract(await Caller.fromInit(oracle.address));

        const callerDeployResult = await callerContract.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(callerDeployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: callerContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and oracle are ready to use
    });

    it('Should multiply price 2000 by 2', async () => {
        const user = await blockchain.treasury('user');
        const result = await callerContract.send(
            user.getSender(),
            {
                value: toNano('0.03'),
            },
            'call'
        );
        
        prettyLogTransactions(result.transactions);
        printTransactionFees(result.transactions);

        expect(result.transactions).toHaveTransaction({
            from: user.address,
            to: callerContract.address,
            success: true,
        });

        expect(result.transactions).toHaveTransaction({
            from: callerContract.address,
            to: oracle.address,
            success: true,
        });

        expect(result.transactions).toHaveTransaction({
            from: oracle.address,
            to: callerContract.address,
            success: true,
        });

        const number = await callerContract.getNumber();
        expect(number).toEqual(BigInt(4000n));
    });
});
