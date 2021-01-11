module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;

AForm cst2ast(start[Form] startForm) {
  Form f = startForm.top;
  return form("<f.name>", [cst2ast(question) | question <- f.questions], src=f@\loc);
}

AQuestion cst2ast(Question question) {
  switch(question) {
    case q:(Question)`<Str content> <Id name> : <Type ansType>`:
      return regQuestion("<content>", cst2ast(name), cst2ast(ansType), src=q@\loc);
    case q:(Question)`<Str content> <Id name> : <Type ansType> = <Expr expr>`:
      return calcQuestion("<content>", cst2ast(name), cst2ast(ansType), cst2ast(expr), src=q@\loc);
    case q:(Question)`if (<Expr guard>) { <Question* condQuestions> }`:
      return ifStat(cst2ast(guard), [cst2ast(question) | Question question <- condQuestions], src=q@\loc);
    case q:(Question)`if (<Expr guard>) { <Question* condQuestions> } else { <Question* altQuestions> }`:
      return ifElseStat(cst2ast(guard), [cst2ast(question) | Question question <- condQuestions], [cst2ast(question) | Question question <- altQuestions], src=q@\loc);
    default:
      throw "Not a question: <question>";
  }
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case e:(Expr)`<Id x>`  				  	 : return ref(id("<x>", src=x@\loc));
    case e:(Expr)`<Int x>` 				  	 : return \int(toInt("<x>"), src=e@\loc);
    case e:(Expr)`<Bool b>`				  	 : return \bool("<b>" := "true" ,src=b@\loc);
    case e:(Expr)`<Str s>`				  	 : return \str("<s>" ,src=s@\loc);
    case e:(Expr)`(<Expr ex>)` 			 	 : return cst2ast(ex);
    case e:(Expr)`!<Expr ex>`			  	 : return \not(cst2ast(ex), src=e@\loc);
    case e:(Expr)`<Expr lhs> * <Expr rhs>`	 : return \mul(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> / <Expr rhs>`   : return \div(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> + <Expr rhs>`   : return \add(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> - <Expr rhs>`   : return \sub(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> \< <Expr rhs>`  : return \less(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> \<= <Expr rhs>` : return \leq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> \> <Expr rhs>`  : return \gt(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> \>= <Expr rhs>` : return \geq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> == <Expr rhs>`  : return \equ(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> != <Expr rhs>`  : return \neq(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> && <Expr rhs>`  : return \and(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    case e:(Expr)`<Expr lhs> || <Expr rhs>`  : return \or(cst2ast(lhs), cst2ast(rhs), src=e@\loc);
    default									 : throw "Not an expression: <e>";
  }
}

AId cst2ast(Id name) = id("<name>", src=name@\loc);

AType cst2ast(Type t) {
  switch (t) {
  	case t: (Type)`boolean` : return \boolean(src=t@\loc);
  	case t: (Type)`integer` : return \integer(src=t@\loc);
  	case t: (Type)`string`  : return \string(src=t@\loc);
  	default				    : throw "Not a type: <t>";
  }
}