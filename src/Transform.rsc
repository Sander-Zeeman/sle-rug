module Transform

import Syntax;
import Resolve;
import AST;

import ParseTree;

AQuestion flatten(q:regQuestion(str _, AId _, AType _), AExpr ongoingExpr)
  = ifStat(ongoingExpr, [q]);

AQuestion flatten(q:calcQuestion(str _, AId _, AType _, AExpr _), AExpr ongoingExpr)
  = ifStat(ongoingExpr, [q]);
  
list[AQuestion] flatten(ifStat(AExpr guard, list[AQuestion] condQuestions), AExpr ongoingExpr)
  = [*flatten(q, \and(ongoingExpr, guard)) | q <- condQuestions];
 
list[AQuestion] flatten(ifElseStat(AExpr guard, list[AQuestion] condQuestions, list[AQuestion] altQuestions), AExpr ongoingExpr)
  = [*flatten(q, \and(ongoingExpr, guard)) | q <- condQuestions]
  + [*flatten(q, \and(ongoingExpr, \not(guard))) | q <- altQuestions];

AQuestion flatten(AQuestion _, AExpr _) {
  throw "Test";
}
 
AForm flatten(AForm f) {
  list[AQuestion] questions = [*flatten(q, \bool(true)) | q <- f.questions];
  return form(f.name, questions);
}

start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
   set[loc] toRename = {useOrDef};
   if (useOrDef in useDef.use, <useOrDef, loc d> <- useDef) {
     toRename += {d} + {u | <loc u, d> <- useDef};
   }
   if (useOrDef in useDef.def) {
     toRename += {u | <loc u, useOrDef> <- useDef};
   }
   
   return visit(f) {
     case (Question)`<Str s> <Id name> : <Type t>` 
       => (Question)`<Str s> <Id new> : <Type t>`
         when name@\loc in toRename,
         Id new := [Id]newName
         
     case (Question)`<Str s> <Id name> : <Type t> = <Expr e>` 
       => (Question)`<Str s> <Id new> : <Type t> = <Expr e>`
         when name@\loc in toRename,
         Id new := [Id]newName
       
     case (Expr)`<Id name>`
       => (Expr)`<Id new>`
         when name@\loc in toRename,
         Id new := [Id]newName  
   }
 } 