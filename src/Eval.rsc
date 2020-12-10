module Eval

import AST;
import Resolve;

data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

alias VEnv = map[str name, Value \value];

data Input
  = input(str question, Value \value);
  
Value defaultValue(\boolean()) = vbool(false);
Value defaultValue(\integer()) = vint(0);
Value defaultValue(\string())  = vstr("");

VEnv initialEnv(AForm f) = (name : defaultValue(\type) | /regQuestion(_,str name, AType \type) := f);

VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {
  for (/AQuestion q := f) {
  	venv = eval(q, inp, venv);
  }
  return venv;
}

VEnv eval(regQuestion(_, str name, _), input(str question, Value \value), VEnv venv) {
  if (name == question) {
  	venv += (name: \value);
  }
  return venv;
}

VEnv eval(calcQuestion(_, str name, _, AExpr expr), Input inp, VEnv venv) = venv + (name: eval(expr, venv));

VEnv eval(ifStat(AExpr guard, list[AQuestion] questions), Input inp, VEnv venv) {
  if (eval(guard, venv) == vbool(true)) {
  	for (AQuestion q <- questions) {
  	  venv = eval(q, inp, venv);
  	}
  }
  return venv;
}

VEnv eval(ifElseStat(AExpr guard, list[AQuestion] questions, list[AQuestion] altQuestions), Input inp, VEnv venv) {
  if (eval(guard, venv) == vbool(true)) {
  	for (AQuestion q <- questions) {
  	  venv = eval(q, inp, venv);
  	}
  } else {
  	for (AQuestion q <- altQuestions) {
  	  venv = eval(q, inp, venv);
  	}
  }
  return venv;
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {
  throw "Not a valid question: <q>";
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(x))    				 : return venv["<x>"];
    case \int(int x)   				 : return vint(x);
    case \bool(bool b) 				 : return vbool(b);
    case \not(AExpr e) 			     : return "<eval(e, venv)>" := "vbool(true)" ? vbool(false) : vbool(true) ;
    case \mul(AExpr lhs, AExpr rhs)  : return vint( eval(lhs, venv).n *  eval(rhs, venv).n);
    case \div(AExpr lhs, AExpr rhs)  : return vint( eval(lhs, venv).n /  eval(rhs, venv).n);
    case \add(AExpr lhs, AExpr rhs)  : return vint( eval(lhs, venv).n +  eval(rhs, venv).n);
    case \sub(AExpr lhs, AExpr rhs)  : return vint( eval(lhs, venv).n -  eval(rhs, venv).n);
    case \and(AExpr lhs, AExpr rhs)  : return vbool(eval(lhs, venv).b && eval(rhs, venv).b);
    case \or(AExpr lhs, AExpr rhs)   : return vbool(eval(lhs, venv).b || eval(rhs, venv).b);
    case \less(AExpr lhs, AExpr rhs) : return vbool(eval(lhs, venv).n <  eval(rhs, venv).n);
    case \leq(AExpr lhs, AExpr rhs)  : return vbool(eval(lhs, venv).n <= eval(rhs, venv).n);
    case \eq(AExpr lhs, AExpr rhs)   : return vbool(eval(lhs, venv)   == eval(rhs, venv)  );
    case \neq(AExpr lhs, AExpr rhs)  : return vbool(eval(lhs, venv)   != eval(rhs, venv)  );
    case \geq(AExpr lhs, AExpr rhs)  : return vbool(eval(lhs, venv).n >= eval(rhs, venv).n);
    case \gt(AExpr lhs, AExpr rhs)   : return vbool(eval(lhs, venv).n >  eval(rhs, venv).n);
    default: throw "Unsupported expression <e>";
  }
}