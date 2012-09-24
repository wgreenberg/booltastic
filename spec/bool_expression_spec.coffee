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
    replaceLeftWithP = e.Expression.treeReplace(@expr, "0", replacement)
    replaceRightWithP = e.Expression.treeReplace(@expr, "1", replacement)
    replaceRightLeftWithP = e.Expression.treeReplace(@expr, "10", replacement)
    expect(e.Expression.toString(replaceLeftWithP)).toBe("p OR ((NOT a) AND b)")
    expect(e.Expression.toString(replaceRightWithP)).toBe("(a AND b) OR p")
    expect(e.Expression.toString(replaceRightLeftWithP)).toBe("(a AND b) OR (p AND b)")

  it "should show equality by left-association", ->
    exp1 = new e.Expression "(a AND b) AND c"
    exp2 = new e.Expression "a AND (b AND c)"

    exp4 = new e.Expression "(a AND (b AND c)) AND (d AND e)"
    exp5 = new e.Expression "a AND ((b AND c) AND (d AND e))"
    exp6 = new e.Expression "a AND (b AND (c AND (d AND e)))"
    
    expect(strfy(exp1.left_associate("").get_tree())).toBe(strfy(exp2.get_tree()))
    expect(strfy(exp4.left_associate("").get_tree())).toBe(strfy(exp5.get_tree()))
    expect(strfy(exp5.left_associate("1").get_tree())).toBe(strfy(exp6.get_tree()))
    
  it "should show equality by right-association", ->
    exp1 = new e.Expression "(a AND b) AND c"
    exp2 = new e.Expression "a AND (b AND c)"

    exp4 = new e.Expression "(a AND (b AND c)) AND (d AND e)"
    exp5 = new e.Expression "a AND ((b AND c) AND (d AND e))"
    exp6 = new e.Expression "a AND (b AND (c AND (d AND e)))"

    expect(strfy(exp2.right_associate("").get_tree())).toBe(strfy(exp1.get_tree()))
    expect(strfy(exp5.right_associate("").get_tree())).toBe(strfy(exp4.get_tree()))
    expect(strfy(exp6.right_associate("1").get_tree())).toBe(strfy(exp5.get_tree()))
    
  it "should show equality by commutivity", ->
    exp1 = new e.Expression "a AND b"
    exp2 = new e.Expression "b AND a"
    
    exp3 = new e.Expression "(a AND b) AND c"
    exp4 = new e.Expression "(b AND a) AND c"
    exp5 = new e.Expression "c AND (b AND a)"

    expect(strfy(exp2.commute("").get_tree())).toBe(strfy(exp1.get_tree()))
    expect(strfy(exp1.commute("").get_tree())).toBe(strfy(exp2.get_tree()))
    expect(strfy(exp3.commute("0").get_tree())).toBe(strfy(exp4.get_tree()))
    expect(strfy(exp4.commute("").get_tree())).toBe(strfy(exp5.get_tree()))
    
  it "should show equality by DeMorgan's law type 1", ->
    # ~(a and b) => ~a or ~b
    exp1 = new e.Expression "NOT (a AND b)"
    exp2 = new e.Expression "(NOT a) OR (NOT b)"
    
    exp3 = new e.Expression "NOT ((NOT a) OR (b AND c))"
    exp4 = new e.Expression "(NOT (NOT a)) AND (NOT (b AND c))"

    expect(strfy(exp1.deMorgan1("").get_tree())).toBe(strfy(exp2.get_tree()))
    expect(strfy(exp3.deMorgan1("").get_tree())).toBe(strfy(exp4.get_tree()))
    
  it "should show equality by DeMorgan's law type 2", ->
    # ~a or ~b => ~(a and b) 
    exp2 = new e.Expression "(NOT a) OR (NOT b)"
    exp1 = new e.Expression "NOT (a AND b)"
    
    exp4 = new e.Expression "(NOT (NOT a)) AND (NOT (b AND c))"
    exp3 = new e.Expression "NOT ((NOT a) OR (b AND c))"
    
    expect(strfy(exp2.deMorgan2("").get_tree())).toBe(strfy(exp1.get_tree()))
    expect(strfy(exp4.deMorgan2("").get_tree())).toBe(strfy(exp3.get_tree()))
