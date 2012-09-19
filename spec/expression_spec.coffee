e = require("../src/expression")

describe "Boolean expressions", ->
  beforeEach ->
    @expr = new e.Expression "(a AND b) OR ((NOT a) AND b)"
   
  arrEq = (arr1, arr2) ->
    JSON.stringify(arr1) == JSON.stringify(arr2)

  strfy = (arr) ->
    JSON.stringify(arr)

  it "should know its string form", ->
    expect(@expr.get_string()).toBe "(a AND b) OR ((NOT a) AND b)"
    
  it "should parse its string form", ->
    expected_tree = ["OR",
                     ["AND", "a", "b"],
                     ["AND", ["NOT", "a"], "b"]]
    expect(strfy(expected_tree)).toBe(strfy(@expr.expr_tree))

  it "should uniquely identify subexpressions", ->
    # 0 means left, 1 means right
    [subexp, expected] = [{}, {}]
    subexp[pfx] = @expr.subExpression(pfx).get_tree() for pfx in ["0", "1", "00", "01"]
    expected["0"] = ["AND", "a", "b"]
    expected["1"] = ["AND", ["NOT", "a"], "b"]
    expected["00"] = "a"
    expected["01"] = "b"

    expect(strfy(subexp[pfx])).toBe(strfy(expected[pfx])) for pfx in ["0", "1", "00", "01"]

  it "should construct based on tree data", ->
    newExp = new e.Expression ["AND", "a", "b"]

    expect(newExp.get_string()).toBe "a AND b"
    expect(@expr.get_string()).toBe (new
	    e.Expression(@expr.get_tree())).get_string()
