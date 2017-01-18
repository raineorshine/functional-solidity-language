start
  = toplevel*

toplevel 'toplevel'
  = comment
  / typedec
  / def
  / _

comment 'comment'
  = '//' text:[^\n]* '\n' {
    return null
  }

typedec 'typedec'
  = id:id _+ ':' _+ definition:type {
    return {
      type: 'typedec',
      value: { id: id.value, definition }
    }
  }

type 'type'
  = function
  / call
  / id
  / [^\n]+ { return { UNKNOWN_TYPE: text() } }

function 'function'
  = param:fvalue _+ '->' _+ returns:(function/fvalue) {
    return {
      type: 'function',
      value: { param, returns }
    }
  }

fvalue 'fvalue'
  = call
  / id
  / namedParam
  / fvaluetuple
  / '(' content:fvalue ')' { return content }

// TODO: unify this with tuple
fvaluetuple 'fvaluetuple'
  = '(' items:fvalueTupleItems ')' {
    return {
      type: 'tuple',
      value: items
    }
  }

fvalueTupleItems 'fvalueTupleItems'
  = head:fvalue tail:(',' _* fvalueTupleItems)? {
    return [head].concat(tail ? tail[2] : [])
  }

namedParam
  = '(' id:id _+ ':' _+ definition:fvalue ')' {
    return {
      type: 'namedParam',
      value: {
        id: id.value,
        definition
      }
    }
  }

def 'def'
  = id:id params:params? _+ '=' _+ body:value {
    return {
      type: 'def',
      value: { id: id.value, params: params || [], body }
    }
  }

id 'id'
  = [a-zA-Z]+ {
    return {
      type: 'id',
      value: text()
    }
  }

number 'number'
  = [0-9]+ { return parseInt(text(), 10) }

value 'value'
  = contract
  / function
  / call
  / tuple
  / l:(id/number) _+ op:infix _+ r:(id/number) {
    return { l, r, op }
  }
  / id
  / number
  / UNKNOWN_VALUE

infix 'infix'
  = [+\-*/]
  / '&&'
  / '||'

contract 'contract'
  = 'Contract' _+ body:contractItem* {
    return {
      type: 'contract',
      value: body
    }
  }

contractItem 'contractItem'
  = comment
  / typedec
  / def
  / _

UNKNOWN_VALUE 'UNKNOWN_VALUE'
  = [a-zA-Z ]+ {
    return {
      UNKNOWN_VALUE: text()
    }
  }

params 'params'
  = params:(_+ id)+ {
    return params.map(p => p[1].value)
  }

_ 'whitespace'
  = [ \t\n\r] { return null }

tuple 'tuple'
  = '(' items:tupleItems ')' {
    return {
      type: 'tuple',
      value: items
    }
  }
  //= '(' contents:.* ')' {
  //  return contents.split(/\w*,\w*/)
  //}

tupleItems 'tupleItems'
  = head:value tail:(',' _* tupleItems)? {
    return [head].concat(tail ? tail[2] : [])
  }

call 'call'
  = id:id args:args {
    return {
      type: 'call',
      value: { id: id.value, args }
    }
  }

args 'args'
  = args:(' '+ (value/recordDef))+ {
    return args.map(p => p[1])
  }

recordDef 'recordDef'
  // TODO: separate out record types in parameters from record constructors
  = '{ ' records:(recordDefAssignment/recordType/id) ' }' {
    return {
      type: 'recordDef',
      value: { records: [records] }
    }
  }

recordType 'recordType'
  = id:id ' '+ ':' ' '+ value:id {
    return { id: id.value, value }
  }

recordDefAssignment 'recordDefAssignment'
  = id:id _+ '=' _+ value:value {
    return { id: id.value, value }
  }
