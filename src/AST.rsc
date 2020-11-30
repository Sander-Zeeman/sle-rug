module AST

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ;

data AQuestion(loc src = |tmp:///|)
  = regQuestion(str content, str name, AType ansType)
  | calcQuestion(str content, str name, AType ansType, AExpr expr)
  | ifStat(AExpr guard, list[AQuestion] condQuestions)
  | ifElseStat(AExpr guard, list[AQuestion] condQuestions, list[AQuestion] altQuestions)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | \int(int x)
  | \bool(bool b)
  | \not(AExpr e)
  | \mul(AExpr e1, AExpr e2)
  | \div(AExpr e1, AExpr e2)
  | \add(AExpr e1, AExpr e2)
  | \sub(AExpr e1, AExpr e2)
  | \less(AExpr e1, AExpr e2)
  | \leq(AExpr e1, AExpr e2)
  | \gt(AExpr e1, AExpr e2)
  | \geq(AExpr e1, AExpr e2)
  | \eq(AExpr e1, AExpr e2)
  | \neq(AExpr e1, AExpr e2)
  | \and(AExpr e1, AExpr e2)
  | \or(AExpr e1, AExpr e2)
  ;

data AId(loc src = |tmp:///|)
  = id(str name)
  ;

data AType(loc src = |tmp:///|)
  = absType(str ansType)
  ;