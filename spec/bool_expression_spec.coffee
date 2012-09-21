e = require("../src/bool_expression")

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
    prefixes = ["", "0", "1", "10", "00", "01", "100", "000", "0000", "1111010101010"]
    subexp[pfx] = @expr.subExpression(pfx).get_tree() for pfx in prefixes
    expected[""] = @expr.get_tree()
    expected["0"] = ["AND", "a", "b"]
    expected["1"] = ["AND", ["NOT", "a"], "b"]
    expected["10"] = ["NOT", "a"]
    expected["00"] = "a"
    expected["01"] = "b"
    expected["100"] = undefined
    expected["000"] = undefined
    expected["0000"] = undefined
    expected["1111010101010"] = undefined

    expect(strfy(subexp[pfx])).toBe(strfy(expected[pfx])) for pfx in prefixes

  it "should construct based on tree data", ->
    newExp = new e.Expression ["AND", "a", "b"]

    expect(newExp.get_string()).toBe "a AND b"
    expect(@expr.get_string()).toBe (new
	    e.Expression(@expr.get_tree())).get_string()

  it "should know if it's defined", ->
    exp1 = new e.Expression("a AND b")

    expect(exp1.isDefined()).toBe(true)
    expect(exp1.subExpression("000").isDefined()).toBe(false)

  it "should be able to replace arbitrary subexpressions", ->
    replacement = "p"
    
    expect(e.Expression.toString(e.Expression.treeReplace(@expr, "0", replacement))).toBe("p OR ((NOT a) AND b)")
    expect(e.Expression.toString(e.Expression.treeReplace(@expr, "1", replacement))).toBe("(a AND b) OR p")
    expect(e.Expression.toString(e.Expression.treeReplace(@expr, "10", replacement))).toBe("(a AND b) OR (p AND b)")

  it "should show equality by left-association", ->
    exp1 = new e.Expression "(a AND b) AND c"
    exp2 = new e.Expression "a AND (b AND c)"

    exp4 = new e.Expression "(a AND (b AND c)) AND (d AND e)"
    exp5 = new e.Expression "a AND ((b AND c) AND (d AND e))"
    exp6 = new e.Expression "a AND (b AND (c AND (d AND e)))"
    
    expect(strfy(exp1.left_associate("").get_tree())).toBe(strfy(exp2.get_tree()))
    expect(strfy(exp4.left_associate("").get_tree())).toBe(strfy(exp5.get_tree()))
    expect(strfy(exp5.left_associate("1").get_tree())).toBe(strfy(exp6.get_tree()))
