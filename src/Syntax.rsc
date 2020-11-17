module Syntax

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form = "form" Id name Block block; //Starting point

syntax Block = "{" Statement* statements "}"; //A block => 0 or more statements

syntax Statement
  = Question q				//Question
  | Question q "=" Expr ex  //Computed Question
  | If if					//If-Then
  | If if Else else			//If-Then-Else
  ;

syntax Question = Str string Id name ":" Type type;

syntax If = "if" "(" Expr ex ")" Block block;

syntax Else = "else" Block block;

syntax Expr
  = Id name \ "true" \ "false" //true/false are reserved keywords.
  | (Int | Bool)
  > left "(" Expr ")"
  > right "!" Expr
  > left (Expr "*" Expr | Expr "/" Expr)
  > left (Expr "+" Expr | Expr "-" Expr)
  > left (Expr "\<" Expr | Expr "\<=" Expr | Expr "\>" Expr | Expr "\>=" Expr)
  > left (Expr "==" Expr | Expr "!=" Expr)
  > left (Expr "&&" Expr | Expr "||" Expr)
  ;

lexical Int
  = [\-]? [1-9][0-9]* ([.] [0-9]+)?
  | [\-]? [0] ([.] [0-9]+)?
  ;

lexical Bool = "true" | "false";

lexical Str = [\"] ![\"]* [\"];

syntax Type
  = "boolean"
  | "integer"
  | "string"
  ;