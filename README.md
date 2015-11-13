How many distinct closed λ-calculus expressions are there of a given length, assuming [standard notational conventions](https://en.wikipedia.org/wiki/Lambda_calculus#Notation)?

```
> ruby lambda_terms.rb
Counts:
{1=>0, 2=>0, 3=>0, 4=>1, 5=>3, 6=>8, 7=>22, 8=>68, 9=>235, 10=>893}
Terms:
{1=>[],
 2=>[],
 3=>[],
 4=>["λa.a"],
 5=>["λa.aa", "λab.a", "λab.b"],
 6=>
  ["λa.aaa",
   "λab.aa",
   "λab.ab",
   "λab.ba",
   "λab.bb",
   "λabc.a",
   "λabc.b",
   "λabc.c"],
 7=>
  ...
  ...
  ...
```

_Disclaimer:_ This is pretty rough code. It seems to match my back-of-envelope calculations for 1<=N<=10, but I wouldn't trust it much past that, because subtleties of bound variables, parentheses simplification rules, etc. aren't captured exactly correctly. If you can even manage to get it to run much past N=10 (exponential time, yuck) ...