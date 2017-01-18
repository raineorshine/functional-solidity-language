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
  = id:id _+ ':' _+ type:type {
    return {
      name: 'typedec',
      value: { id, type }
    }
  }

type 'type'
  = [^\n]+ { return text() }

def 'def'
  = id:id params:params? _* '=' _+ body:value {
    return {
      type: 'def',
      value: { id, params: params || [], body }
    }
  }

id 'id'
  = [a-zA-Z]+ { return text() }

number 'number'
  = [0-9]+ { return parseInt(text(), 10) }

value 'value'
  = contract
  / tuple
  / call
  / id
  / number
  / UNKNOWN_VALUE

contract 'contract'
  = 'Contract' _+ body:item* {
    return body
  }

item 'item'
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
/*
  = id:id _+ params:params _+ '=' _+ value:[^\n]+ {
    return {
      type: 'function',
      value: {
        id,
        value
      }
    }
  }
*/

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
  = id:id args:args+ {
    return {
      type: 'call',
      value: { id, args }
    }
  }

args 'args'
  = args:(' '+ (value/recordDef))+ {
    return args.map(p => p[1])
  }

recordDef 'recordDef'
  = '{ ' records:recordDefAssignment ' }' {
    return {
      type: 'recordDef',
      value: { records: [records] }
    }
  }

recordDefAssignment
  = id:id _+ '=' _+ value:value {
    return { id, value }
  }
