start
  = and

and
  = left:or " AND " right:and { return [left, "AND", right]; }
  / or

or
  = left:primary " OR " right:or { return [left, "OR", right]; }
  / primary

primary
  = terminal
  / "(" and:and ")" { return and; }
  / not terminal

not
  = "NOT " {return "NOT";}

terminal "terminal"
  = [a-z]
