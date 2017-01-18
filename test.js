const fs = require('fs')
const parser = require('./grammar.js')
const src = fs.readFileSync('sample.src', 'utf-8')
let result

try {
  result = parser.parse(src)
}
catch (e) {
  if(e.location) {
    console.log(`Line ${e.location.start.line} Column ${e.location.start.column}: ` + e.message)
  }
  else {
    console.log(e.message)
  }

  process.exit(1)
}

const pretty = JSON.stringify(result, null, 2)
  .replace(/,?\n *null/g, '')
console.log(pretty)
