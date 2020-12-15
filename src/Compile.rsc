module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM; // see standard library

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTML5Node type and the `str toString(HTML5Node x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions
 */


void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, toString(form2html(f)));
}

str getInputType(\boolean()) = "checkbox";
str getInputType(\integer()) = "number";
str getInputType(\string())  = "text";

str getInput(AType aType, str name, bool disabled) = "\<input type=\"<getInputType(aType)>\" id=<name> name=<name>" + "<disabled ? " value=\"3\" disabled" : "">" + "\>";

str question2html(regQuestion(str content, str name, AType ansType))
  = "\<label for=\"<name>\"\><content>\</label\>\</br\>
   	'<getInput(ansType, name, false)>\</br\>\</br\>";

str question2html(calcQuestion(str content, str name, AType ansType, AExpr exp))
  = "\<label for=\"<name>\"\><content>\</label\>\</br\>
   	'<getInput(ansType, name, true)>\</br\>\</br\>";
   	
str question2html(ifStat(AExpr guard, list[AQuestion] condQuestions))
  = "";

str question2html(ifElseStat(AExpr guard, list[AQuestion] condQuestions, list[AQuestion] altQuestions))
  = "";

str question2html(AQuestion _) = "";

HTML5Node form2html(AForm f) {
  return html("
  '  \<head\>\</head\>
  '  \<body\>
  '    \<h1\><f.name>\</h1\>
  '    \<form\>
  '      <for (AQuestion q <- f.questions) {>
  '        <question2html(q)>
  '      <}>
  '    \</form\>
  '  \</body\>
  '"
  );
}

str form2js(AForm _) {
  return "";
}
