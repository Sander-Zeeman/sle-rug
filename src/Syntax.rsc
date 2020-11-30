module Syntax

extend lang::std::Layout;
extend lang::std::Id;

start syntax Form
  = "form" Id name "{" Question* questions "}"
  ;

syntax Question
  = Str content Id name ":" Type type														//Question
  | Str content Id name ":" Type type "=" Expr ex  											//Computed Question
  | "if" "(" Expr guard ")" "{" Question* questions "}"									   	//If-Then
  | "if" "(" Expr guard ")" "{" Question* questions "}" "else" "{" Question* questions "}" 	//If-Then-Else
  ;

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
  | [\-]? [0]         ([.] [0-9]+)?
  ;

lexical Bool
  = "true" | "false"
  ;

lexical Str
  = [\"] ![\"]* [\"]
  ;

syntax Type
  = "boolean"
  | "integer"
  | "string"
  ;