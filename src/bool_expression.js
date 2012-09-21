// Generated by CoffeeScript 1.3.3
(function() {
  var parser;

  parser = require("../src/bool_parser");

  exports.Expression = (function() {

    function Expression(expr) {
      if (typeof expr === "string") {
        this.expr_string = expr;
        this.expr_tree = Expression.toTree(expr);
      } else if (typeof expr === "object") {
        this.expr_tree = expr;
        this.expr_string = Expression.toString(expr);
      } else if (expr === void 0) {
        this.expr_string = void 0;
        this.expr_tree = void 0;
      }
    }

    Expression.prototype.get_string = function() {
      return this.expr_string;
    };

    Expression.prototype.get_tree = function() {
      return this.expr_tree;
    };

    Expression.prototype.isDefined = function(epxr) {
      return this.get_tree() !== void 0;
    };

    Expression.prototype.subExpression = function(prefix) {
      var directions, tree;
      directions = prefix.split("").map(function(c) {
        return parseInt(c, 10);
      }).reverse();
      tree = this.expr_tree;
      while (directions.length !== 0) {
        if (tree === void 0) {
          return new Expression(void 0);
        }
        if (tree.length === 2) {
          tree = tree[1];
        }
        tree = tree[1 + directions.pop()];
      }
      return new Expression(tree);
    };

    Expression.prototype.left_associate = function(root) {
      var a, allDefined, b, c, newExp, op1, op2;
      op1 = this.subExpression(root).get_tree()[0];
      op2 = this.subExpression(root + "0").get_tree()[0];
      a = this.subExpression(root + "00").get_tree();
      b = this.subExpression(root + "01").get_tree();
      c = this.subExpression(root + "1").get_tree();
      allDefined = ([op1, op2, a, b, c].filter(function(x) {
        return x === void 0;
      })).length === 0;
      console.log(allDefined);
      console.log(op1 + " " + op2);
      if (allDefined && op1 === op2) {
        newExp = Expression.treeReplace(this, root, [op1, a, [op2, b, c]]);
        return new Expression(newExp);
      }
      return new Expression(void 0);
    };

    Expression.treeReplace = function(exp, prefix, subexp) {
      var directions, orig_tree, tree;
      if (prefix === "") {
        return subexp;
      }
      directions = prefix.split("").map(function(c) {
        return parseInt(c, 10);
      }).reverse();
      orig_tree = exp.get_tree().slice(0);
      tree = orig_tree;
      while (directions.length !== 1) {
        if (tree === void 0) {
          return new Expression(void 0);
        }
        if (tree.length === 2) {
          tree = tree[1];
        }
        tree = tree[1 + directions.pop()];
      }
      tree[1 + directions.pop()] = subexp;
      return orig_tree;
    };

    Expression.equals = function(e1, e2) {
      return e1.get_string() === e2.get_string();
    };

    Expression.toString = function(treeForm) {
      var ln, str;
      str = Expression.toStringHelper(treeForm);
      ln = str.length - 1;
      return str.slice(1, ln);
    };

    Expression.toStringHelper = function(treeForm) {
      var lp, rp, sp, _ref;
      _ref = ['(', ')', ' '], lp = _ref[0], rp = _ref[1], sp = _ref[2];
      if (typeof treeForm === "string") {
        return treeForm;
      } else if (treeForm.length === 2) {
        return lp + treeForm[0] + sp + Expression.toStringHelper(treeForm[1]) + rp;
      } else {
        return lp + Expression.toStringHelper(treeForm[1]) + sp + treeForm[0] + sp + Expression.toStringHelper(treeForm[2]) + rp;
      }
    };

    Expression.toTree = function(stringForm) {
      return parser.parse(stringForm);
    };

    return Expression;

  })();

}).call(this);
