/*
 * Made for use with the fantastic PEG.js: http://pegjs.majda.cz/
 */

start
  = and

and
  = left:or " AND " right:and { return ["AND", left, right]; }
  / or

or
  = left:primary " OR " right:or { return ["OR", left, right]; }
  / primary

primary
  = terminal
  / "(" and:and ")" { return and; }
  / not p:primary { return ["NOT", p] }

not
  = "NOT "

terminal "terminal"
  = [a-z]
