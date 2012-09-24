parser = require("../src/bool_parser")

class exports.Expression
  
  constructor: (expr) ->
    if typeof(expr)== "string"
      @expr_string = expr
      @expr_tree = Expression.toTree expr
    else if typeof(expr)== "object"
      @expr_tree = expr
      @expr_string = Expression.toString expr
    else if expr == undefined
      @expr_string = undefined
      @expr_tree = undefined

  get_string: () ->
    @expr_string

  get_tree: () ->
    @expr_tree

  isDefined: (epxr) ->
    @get_tree() != undefined

  subExpression: (prefix) ->
    directions = prefix.split("").map((c) -> parseInt(c, 10)).reverse()
    tree = @expr_tree

    until directions.length == 0
      if tree == undefined
        return new Expression(undefined)
      if tree.length == 2 # unary form, so consider (op ele) its own element
        tree = tree[1]
      tree = tree[1+directions.pop()]

    new Expression(tree)
    
  commute: (root) ->
    op = @subExpression(root).get_tree()[0]
    a = @subExpression(root + "0").get_tree()
    b = @subExpression(root + "1").get_tree()
    allDefined = ([a, b].filter (x) -> x == undefined).length == 0
    
    if allDefined
      newExp = Expression.treeReplace(@, root, [op, b, a])
      return new Expression(newExp)
    return new Expression(undefined)

  doubleNegation1: (root) ->
    not1 = @subExpression(root).get_tree()[0]
    not2 = @subExpression(root).get_tree()[1][0]
    expr = @subExpression(root + "0")

    if(not1 == "NOT" && not2 == "NOT" && expr.isDefined())
      newExp = Expression.treeReplace(@, root, expr.get_tree())
      return new Expression(newExp)
    return new Expression(undefined)

  doubleNegation2: (root) ->
    expr = @subExpression(root).get_tree()

    if(expr != undefined)
      newExp = Expression.treeReplace(@, root, ["NOT", ["NOT", expr]])
      return new Expression(newExp)
    return new Expression(undefined)

  deMorgan1: (root) ->
    shouldBeNot = @subExpression(root).get_tree()[0]
    expr = @subExpression(root).get_tree()
    op = expr[1][0]
    a = @subExpression(root + "0").get_tree()
    b = @subExpression(root + "1").get_tree()
    allDefined = ([expr, op, a, b].filter (x) -> x == undefined).length == 0
    
    if(allDefined && shouldBeNot == "NOT")
      newOp = if op == "AND" then "OR" else "AND"
      newExp = Expression.treeReplace(@, root, [newOp, ["NOT", a], ["NOT", b]])
      return new Expression(newExp)
    
    return new Expression(undefined)
  
  deMorgan2: (root) ->
    expr = @subExpression(root).get_tree()
    op = expr[0]
    a = @subExpression(root + "0").get_tree()
    b = @subExpression(root + "1").get_tree()
    allDefined = ([expr, op, a, b].filter (x) -> x == undefined).length == 0
    
    if(allDefined)
      newOp = if op == "AND" then "OR" else "AND"
      newExp = Expression.treeReplace(@, root, ["NOT", [newOp, ["NOT", a], ["NOT", b]]])
      return new Expression(newExp)
 
    return new Expression(undefined)
    
  right_associate: (root) ->
    op1 = @subExpression(root).get_tree()[0]
    op2 = @subExpression(root + "1").get_tree()[0]
    a = @subExpression(root + "0").get_tree()
    b = @subExpression(root + "10").get_tree()
    c = @subExpression(root + "11").get_tree()
    allDefined = ([op1, op2, a, b, c].filter (x) -> x == undefined).length == 0

    if(allDefined && op1 == op2)
      newExp = Expression.treeReplace(@, root, [op1, [op2, a, b], c])
      return new Expression(newExp)

    return new Expression(undefined)


  left_associate: (root) ->
    op1 = @subExpression(root).get_tree()[0]
    op2 = @subExpression(root + "0").get_tree()[0]
    a = @subExpression(root + "00").get_tree()
    b = @subExpression(root + "01").get_tree()
    c = @subExpression(root + "1").get_tree()
    allDefined = ([op1, op2, a, b, c].filter (x) -> x == undefined).length == 0

    if(allDefined && op1 == op2)
      newExp = Expression.treeReplace(@, root, [op1, a, [op2, b, c]])
      return new Expression(newExp)

    return new Expression(undefined)

  @treeReplace: (exp, prefix, subexp) ->
    if prefix == ""
      return subexp

    directions = prefix.split("").map((c) -> parseInt(c, 10)).reverse()
    orig_tree = JSON.parse(JSON.stringify(exp.get_tree()))

    tree = orig_tree

    until directions.length == 1
      if tree == undefined
        return new Expression(undefined)
      if tree.length == 2
        tree = tree[1]
      tree = tree[1+directions.pop()]
    tree[1+directions.pop()] = subexp

    orig_tree

  @equals: (e1, e2) ->
    e1.get_string() == e2.get_string()
    
  @toString: (treeForm) ->
    str = Expression.toStringHelper(treeForm)
    ln = str.length - 1
    str[1...ln]
 
  @toStringHelper: (treeForm) ->
    [lp, rp, sp] = ['(', ')', ' ']
    if typeof(treeForm) == "string"
      treeForm
    else if treeForm.length == 2 # unary (NOT) form
      lp + treeForm[0] + sp + Expression.toStringHelper(treeForm[1]) + rp
    else # p OP p form
      lp + Expression.toStringHelper(treeForm[1]) + sp + treeForm[0] + sp + Expression.toStringHelper(treeForm[2]) + rp
    
  @toTree: (stringForm) ->
    parser.parse(stringForm)


