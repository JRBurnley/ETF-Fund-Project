# Adventure-Token, Luna Swap

> Repo for the Adventure Token (TWA) and Luna Swap

## Token Testing

This project utilizes [Truffle Suite](https://www.trufflesuite.com/) to automate testing.

You will need to install [Truffle](https://www.trufflesuite.com/truffle):

```
npm install truffle -g
```

and [Ganache CLI](https://github.com/trufflesuite/ganache-cli):

```
npm install -g ganache-cli
```

Once installed, run Ganache CLI in a terminal:

```
My-Comp:~ johndoe$ ganache-cli
```

Then, from the root of this project, run the tests:

```
truffle test
```

## Luna Swap Testing

You can test Luna Swap contract by forking mainnet into local.
You will need to copy `start.sh.example` to `start.sh` in root directory.
And please add your infura id and mnemonic.

Then, from the root of this project, run the tests:

```
sh ./start.hs
```

```
truffle test
```
or

```
truffle test ./test/LunaSwap.test.js
```