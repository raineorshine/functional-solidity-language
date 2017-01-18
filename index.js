const renderer = {}

function findType(types, id) {
  const type = types.find(t => t.id === id)
  if(!type) {
    throw new Error('Cannot find type of: ' + id)
  }
  return type.definition
}

/** Extracts types from all given typedecs */
function extractTypes(objects) {
  return objects
    .filter(obj => obj && obj.type === 'typedec')
    .map(obj => obj.value)
}

/** Recursively get the return type from a curried function. */
function getReturnType(obj) {
  return obj.type === 'function' ? getReturnType(obj.value.returns) :
    obj.type === 'tuple' ? getReturnType(obj.value[0]) :
    obj.type === 'id' ? obj.value :
    ['INVALID_RETURN_TYPE', obj]
}

// produces metadata, not source code
renderer.typedec = (types, value) => {
  return null
}

renderer.call = (types, value) => {
  return value.id === 'EtherTransfer' ? renderEtherTransfer(value) :
    value.args[0].value.records
      .map(record => record.id + ' = ' + renderPrimitive(record.value)) + ';'
}

renderer.def = (types, value, contractType) => {
  return value.body.type === 'contract' ? renderer.contract(types, value.body, value.id) :
    value.params.length ? renderContractMethod(types, contractType, value.id, value.params, value.body) :
    render(types)(value)
}

renderer.tuple = (types, value) => {
  if(value[0].value !== 'state') {
    throw new Error('Invalid use of tuple')
  }
  return render(types)(value[1])
}

// NOTE: id must be passed explicitly since it is defined one level up as part of def
renderer.contract = (types, value, id) => {

  // extract and add types
  const moreTypes = types.concat(extractTypes(value.value))

  // get contractStateType
  const contractType = findType(types, id)
  const contractStateTypeName = contractType.value.args[0].value

  const contractStateType = findType(types, contractStateTypeName)
  const members = contractStateType.value.args[0].value.records
    .map(record => `  public ${record.value.value.toLowerCase()} ${record.id};` + '\n')
    .join('')

  const contractBody = value.value
    .map(x => render(moreTypes)(x, contractStateTypeName))
    .filter(x => x)
    .map(x => '  ' + x + '\n')
    .join('\n')
  return `contract {\n${members}\n${contractBody}}`
}

function renderContractMethod(types, contractStateType, id, params, body) {

  // get method type
  const methodType = findType(types, id)
  const methodReturns = getReturnType(methodType)

  // type check method's returned state type against contract state type
  if(methodReturns !== contractStateType) {
    // TODO: print line number
    console.log(`Type Error: ${id} method was expected to return ${contractStateType}, but instead got ${methodReturns}.`)
    // throw new Error(`Type Error: ${id} method was expected to return ${contractStateType}, but instead got ${methodReturns}.`)
  }

  const paramsStr = params
    .filter(param => param !== 'state' && param !== 'eth')
    .join(', ')

  const modifiers = [
    // payable
    params.includes('eth') ? 'payable' : null
  ]
    .filter(x => x)
    .join(' ')

  const bodyStr = render(types)(body)

  return `function ${id}(${paramsStr}) ${modifiers} {\n    ${bodyStr}\n  }`
}

function renderEtherTransfer(obj) {
  const amount = obj.args[0].value
  const to = amount.args[0].value
  return `if(!${to.id}.value(${amount.id}).call()) throw;`
}

const render = types => (obj, ...args) => {
  return !obj ? null :
    obj.type in renderer ? renderer[obj.type](types, obj.value, ...args) :
    ['UNKNOWN OBJ: ' + JSON.stringify(obj, null, 2)]
}

const renderPrimitive = value => {
  return value.op ? `${value.l.value} ${value.op} ${value.r.value}` :
    value
}

function renderAst(ast) {

  // extract top level types
  const types = extractTypes(ast)

  const output = ast
    .map(render(types))
    .filter(x => x)

  return output.join('\n')

    // TODO: Implement built-in object substitutions correctly
    .replace(/msgValue/g, 'msg.value')
}

module.exports = renderAst