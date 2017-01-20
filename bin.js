#!/usr/bin/env node

const fs = require('fs')
const parser = require('./grammar.js')
const generate = require('./index.js')

if (process.argv[2] === '--help') {
  console.log('')
  console.log('  Generate solidity from the given sourcefile:')
  console.log('')
  console.log('    $ functional-solidity-language [sourcefile]')
  console.log('')
  console.log('  Generate just the parsed AST:')
  console.log('')
  console.log('    $ functional-solidity-language --parse [sourcefile]')
  console.log('')
  process.exit(0)
}

filename = process.argv[process.argv.length-1]
const src = fs.readFileSync(filename, 'utf-8')
let result

try {
  ast = parser.parse(src)
}
catch (e) {
  if (e.location) {
    console.log(`Line ${e.location.start.line} Column ${e.location.start.column}: ` + e.message)
  }
  else {
    console.log(e.message)
  }
  process.exit(1)
}

// print the AST

if (process.argv[2] === '--parse') {
  const prettyAst = JSON.stringify(ast, null, 2)
    .replace(/,?\n *null/g, '')
  console.log(prettyAst)
  console.log('')
}
else {
  // print the generated Solidity source
  const solidity = generate(ast)
  console.log(solidity)
}

