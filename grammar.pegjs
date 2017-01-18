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
      name: 'typedec',
      value: { id: id.value, definition }
    }
  }

type 'type'
  = function
  / call
  / id
  / [^\n]+ { return { UNKNOWN_TYPE: text() } }

function 'function'
  = from:fvalue _+ '->' _+ to:fvalue {
    return {
      type: 'function',
      value: { from, to }
    }
  }

fvalue 'fvalue'
  = call
  / id
  / namedParam
  / '(' content:fvalue ')' { return content }

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
  / id
  / number
  / UNKNOWN_VALUE

contract 'contract'
  = 'Contract' _+ body:contractItem* {
    return body
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
    return params.map(p => p[1])
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
  = '{ ' records:(recordDefAssignment/id) ' }' {
    return {
      type: 'recordDef',
      value: { records: [records] }
    }
  }

recordDefAssignment
  = id:id _+ '=' _+ value:value {
    return { id: id.value, value }
  }
