parser = require("../src/bool_parser")

class exports.Expression
  
  constructor: (expr_str) ->
    @expr_str = expr_str
    
  toString: ->
    @expr_str
    
  toTree: ->
    parser.parse(@expr_str)
