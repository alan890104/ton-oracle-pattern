import { CompilerConfig } from '@ton-community/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/caller.tact',
    options: {
        debug: true,
        experimental: {
            inline: true,
        },
    },
};
