This project is purely an imagining of what it would be like to write Ethereum smart contracts in a typed, functional programming language. It is not yet implemented beyond an extremely rough PEGJS parser and a demo code generator.

---

A simple smart contract:

```js
MyContractState : State { balance : Uint }

MyContract : Contract MyContractState
MyContract = Contract

  deposit : MyContractState -> MsgValue -> MyContractState
  deposit state msgValue = MyContractState { balance = balance + msgValue }

  send : MyContractState -> (amount : MsgValue) -> (to : Address) -> (MyContractState, EtherTransfer amount to balance)
  send state amount to = (state, EtherTransfer amount to balance)
  ```

Equivalent contract in Solidity:

```js
contract {
  public uint balance;

  function deposit(msg.value)  {
    balance = balance + msg.value;
  }

  function send(amount, to)  {
    if(!to.value(amount).call()) throw;
  }
}
```

## Usage

Generate solidity from the given sourcefile:

```sh
$ functional-solidity-language [sourcefile]
```

Generate just the AST:

```sh
$ functional-solidity-language --ast [sourcefile]
```

## Status

- [x] Proof-of-concept parser
- [x] Proof-of-concept code generator
- [ ] 1st gen parser
- [ ] 1st gen code generator

## License

ISC © [Raine Revere](http://raine.tech)
