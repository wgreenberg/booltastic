// Generated by CoffeeScript 1.3.3
(function() {
  var e;

  e = require("../src/bool_expression");

  describe("Boolean expressions", function() {
    var arrEq, strfy;
    beforeEach(function() {
      return this.expr = new e.Expression("(a AND b) OR ((NOT a) AND b)");
    });
    arrEq = function(arr1, arr2) {
      return JSON.stringify(arr1) === JSON.stringify(arr2);
    };
    strfy = function(arr) {
      return JSON.stringify(arr);
    };
    it("should know its string form", function() {
      return expect(this.expr.get_string()).toBe("(a AND b) OR ((NOT a) AND b)");
    });
    it("should parse its string form", function() {
      var expected_tree;
      expected_tree = ["OR", ["AND", "a", "b"], ["AND", ["NOT", "a"], "b"]];
      return expect(strfy(expected_tree)).toBe(strfy(this.expr.expr_tree));
    });
    it("should uniquely identify subexpressions", function() {
      var expected, pfx, prefixes, subexp, _i, _j, _len, _len1, _ref, _results;
      _ref = [{}, {}], subexp = _ref[0], expected = _ref[1];
      prefixes = ["", "0", "1", "10", "00", "01", "100", "000", "0000", "1111010101010"];
      for (_i = 0, _len = prefixes.length; _i < _len; _i++) {
        pfx = prefixes[_i];
        subexp[pfx] = this.expr.subExpression(pfx).get_tree();
      }
      expected[""] = this.expr.get_tree();
      expected["0"] = ["AND", "a", "b"];
      expected["1"] = ["AND", ["NOT", "a"], "b"];
      expected["10"] = ["NOT", "a"];
      expected["00"] = "a";
      expected["01"] = "b";
      expected["100"] = void 0;
      expected["000"] = void 0;
      expected["0000"] = void 0;
      expected["1111010101010"] = void 0;
      _results = [];
      for (_j = 0, _len1 = prefixes.length; _j < _len1; _j++) {
        pfx = prefixes[_j];
        _results.push(expect(strfy(subexp[pfx])).toBe(strfy(expected[pfx])));
      }
      return _results;
    });
    it("should construct based on tree data", function() {
      var newExp;
      newExp = new e.Expression(["AND", "a", "b"]);
      expect(newExp.get_string()).toBe("a AND b");
      return expect(this.expr.get_string()).toBe((new e.Expression(this.expr.get_tree())).get_string());
    });
    it("should know if it's defined", function() {
      var exp1;
      exp1 = new e.Expression("a AND b");
      expect(exp1.isDefined()).toBe(true);
      return expect(exp1.subExpression("000").isDefined()).toBe(false);
    });
    it("should be able to replace arbitrary subexpressions", function() {
      var replacement;
      replacement = "p";
      expect(e.Expression.toString(e.Expression.treeReplace(this.expr, "0", replacement))).toBe("p OR ((NOT a) AND b)");
      expect(e.Expression.toString(e.Expression.treeReplace(this.expr, "1", replacement))).toBe("(a AND b) OR p");
      return expect(e.Expression.toString(e.Expression.treeReplace(this.expr, "10", replacement))).toBe("(a AND b) OR (p AND b)");
    });
    return it("should show equality by left-association", function() {
      var exp1, exp2, exp4, exp5, exp6;
      exp1 = new e.Expression("(a AND b) AND c");
      exp2 = new e.Expression("a AND (b AND c)");
      exp4 = new e.Expression("(a AND (b AND c)) AND (d AND e)");
      exp5 = new e.Expression("a AND ((b AND c) AND (d AND e))");
      exp6 = new e.Expression("a AND (b AND (c AND (d AND e)))");
      expect(strfy(exp1.left_associate("").get_tree())).toBe(strfy(exp2.get_tree()));
      console.log(1);
      expect(strfy(exp4.left_associate("").get_tree())).toBe(strfy(exp5.get_tree()));
      console.log(2);
      return expect(strfy(exp5.left_associate("1").get_tree())).toBe(strfy(exp6.get_tree()));
    });
  });

}).call(this);