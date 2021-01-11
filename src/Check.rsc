module Check

import AST;
import Resolve;
import Message;

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

alias TEnv = rel[loc def, str name, str label, Type \type];

Type getType(AType::\boolean()) = tbool();
Type getType(AType::\integer()) = tint();
Type getType(AType::\string()) = tstr();
Type getType(AType::_) = tunknown();

TEnv collect(AForm f) {
  TEnv env = {};
  env += {<r.src, r.name, r.content, getType(r.ansType)> | /r:regQuestion(_,_,_) := f};
  env += {<c.src, c.name, c.content, getType(c.ansType)> | /c:calcQuestion(_,_,_,_) := f};
  return env;
}

set[Message] check(AForm f, TEnv tenv, UseDef useDef) =
  ( {} | it + check(q, tenv, useDef) | /AQuestion q <- f.questions );

set[Message] check(r:regQuestion(str content, str name, AType ansType, src = loc l), TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  msgs += { error("Same name already exists with different type.", l) | t <- tenv, t.name == name, t.\type != getType(ansType) };
  msgs += { warning("This label has been used before.", l) | t <- tenv, t.label == content, t.def != l };
  return msgs; 
}

set[Message] check(c:calcQuestion(str content, str name, AType ansType, AExpr expr, src = loc l), TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  msgs += { error("Same name already exists with different type.", l) | t <- tenv, t.name == name, t.\type != getType(ansType) };
  if (typeOf(expr, tenv, useDef) != getType(ansType)) {
    msgs += error("Type of expression does not match specified type. Given: <getType(ansType)>, Actual: <typeOf(expr, tenv, useDef)>", expr.src);
  }
  msgs += { warning("This label has been used before.", l) | t <- tenv, t.label == content, t.def != l };
  msgs += check(expr, tenv, useDef);
  return msgs; 
}

set[Message] check(i:ifStat(AExpr guard, list[AQuestion] condQuestions), TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  msgs += { error("Guards must be of type tbool(). Is of type: <typeOf(guard, tenv, useDef)>", guard.src) | typeOf(guard, tenv, useDef) != tbool() };
  msgs += ( {} | it + check(q, tenv, useDef) | /AQuestion q <- condQuestions);
  return msgs; 
}

set[Message] check(ie:ifElseStat(AExpr guard, list[AQuestion] condQuestions, list[AQuestion] altQuestions), TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  msgs += { error("Guards must be of type tbool(). Is of type: <typeOf(guard, tenv, useDef)>", guard.src) | typeOf(guard, tenv, useDef) != tbool() };
  msgs += ( {} | it + check(q, tenv, useDef) | /AQuestion q <- condQuestions);
  msgs += ( {} | it + check(q, tenv, useDef) | /AQuestion q <- altQuestions);
  return msgs; 
}

set[Message] check(AQuestion q, _, _) {
  throw "Not a question: <q>";
}

set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };
    default:
      msgs += { error("The type of the expression is unclear. Is of type: <typeOf(e, tenv, useDef)>", e.src) | typeOf(e, tenv, useDef) == tunknown() };
  }
  return msgs; 
}


bool sameType(AExpr lhs, AExpr rhs, Type t, TEnv tenv, UseDef useDef) {
  if (typeOf(lhs, tenv, useDef) == typeOf(rhs, tenv, useDef)) {
    if (t == typeOf(lhs, tenv, useDef)) {
  	  return true;
  	}
  }
  return false;
}

Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) {
  if (<u, loc d> <- useDef, <d, _, _, Type t> <- tenv) {
    return t;
  }
  return tunknown();
}

Type typeOf(\int(_), TEnv tenv, UseDef useDef) 				  	   = tint();
Type typeOf(\bool(_), TEnv tenv, UseDef useDef) 				   = tbool();
Type typeOf(\str(_), TEnv tenv, UseDef useDef) 				       = tstr();
Type typeOf(\not( AExpr e),              TEnv tenv, UseDef useDef) = typeOf(e, tenv, useDef) == tbool() 		? tbool() : tunknown();
Type typeOf(\mul( AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = sameType(lhs, rhs, tint(),  tenv, useDef)  ? tint()  : tunknown();
Type typeOf(\div( AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = sameType(lhs, rhs, tint(),  tenv, useDef)	? tint()  : tunknown();
Type typeOf(\add( AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = sameType(lhs, rhs, tint(),  tenv, useDef)	? tint()  : tunknown();
Type typeOf(\sub( AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = sameType(lhs, rhs, tint(),  tenv, useDef)	? tint()  : tunknown();
Type typeOf(\less(AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = sameType(lhs, rhs, tint(),  tenv, useDef)	? tbool() : tunknown();
Type typeOf(\leq( AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = sameType(lhs, rhs, tint(),  tenv, useDef)	? tbool() : tunknown();
Type typeOf(\gt(  AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = sameType(lhs, rhs, tint(),  tenv, useDef)	? tbool() : tunknown();
Type typeOf(\geq( AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = sameType(lhs, rhs, tint(),  tenv, useDef)	? tbool() : tunknown();
Type typeOf(\and( AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = sameType(lhs, rhs, tbool(), tenv, useDef)	? tbool() : tunknown();
Type typeOf(\or(  AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = sameType(lhs, rhs, tbool(), tenv, useDef)	? tbool() : tunknown();
Type typeOf(\equ(  AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tbool();
Type typeOf(\neq( AExpr lhs, AExpr rhs), TEnv tenv, UseDef useDef) = tbool();
default Type typeOf(AExpr _, TEnv _, UseDef _) 					   = tunknown();