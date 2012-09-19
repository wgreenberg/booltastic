parser = require("../src/bool_parser")

class exports.Expression
  
  constructor: (expr) ->
    if typeof(expr)== "string"
      @expr_string = expr
      @expr_tree = Expression.toTree expr
    if typeof(expr)== "object"
      @expr_tree = expr
      @expr_string = Expression.toString expr

  get_string: () ->
    @expr_string

  get_tree: () ->
    @expr_tree

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
    else if treeForm.length == 2 # NOT form
      lp + "NOT " + Expression.toStringHelper(treeForm[1]) + rp
    else # p OP p form
      lp + Expression.toStringHelper(treeForm[1]) + sp + treeForm[0] + sp + Expression.toStringHelper(treeForm[2]) + rp
    
  @toTree: (stringForm) ->
    parser.parse(stringForm)

  subExpression: (prefix) ->
    directions = prefix.split("").map((c) -> parseInt(c, 10)).reverse()
    tree = @expr_tree

    until directions.length == 0
      tree = tree[1 + directions.pop()] 

    new Expression(tree)
