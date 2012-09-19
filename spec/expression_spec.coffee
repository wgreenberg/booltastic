e = require("../src/expression")

describe "Boolean expressions", ->
  beforeEach ->
    @expr = new e.Expression "(a AND b) OR ((NOT a) AND b)"

  it "should know Truth", ->
    expect(1).toBe(1);
    
  it "should know its string form", ->
    expect(@expr.toString()).toBe "(a AND b) OR ((NOT a) AND b)"
    
  it "should parse its string form", ->
    expected_tree = [["a", "AND", "b"],
                     "OR",
                     [["NOT", "a"], "AND", "b"]]
    expect(JSON.stringify(expected_tree) == JSON.stringify(@expr.toTree())).toBe true
