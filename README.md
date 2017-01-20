This project is purely an imagining of what it would be like to write Ethereum smart contracts in a typed, functional programming language. It is not yet implemented beyond an extremely rough PEGJS parser and a demo code generator.

---

A simple smart contract:

```idris
MyContractState : State { balance : Uint }

// declare a contract with a specific state type
MyContract : Contract MyContractState
MyContract = Contract

  // all contract methods take the contract state and return a new contract state
  deposit : MyContractState -> MsgValue -> MyContractState
  deposit state msgValue = MyContractState { balance = balance + msgValue }

  // dependent types can be imagined as a way to enforce constraints on effects
  // e.g. in order to send ether you must prove that there is enough ether to send
  send : MyContractState -> (amount : MsgValue) -> (to : Address) -> (MyContractState, EtherTransfer amount to balance)

  // descriptions of side effects are returned in a tuple with the new state.
  // it is a purely functional language
  send state amount to = (state, EtherTransfer amount to balance)
  ```

Equivalent contract in Solidity:

* <i>Yes, this was actually produced by the demo compiler with the above input.</i>
* <i>It doesn't do any type-checking and will break on almost any other input. Really it's just a proof-of-concept.</i>

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
