module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM;

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, toString(form2html(f)));
}

str getStyle() =
"#comp {
'  margin-top: 20px;
'  margin-bottom: 20px;
'  margin-right: 150px;
'  margin-left: 80px;
'}
'
'#msg {
'  font-size: large;
'}";


//---------------HTML------------------------


str getFilename(AForm f) = f.src.path[10..-5] + ".js";

HTML5Node form2html(AForm f) = html(
  head(
    meta(
      charset("UTF-8")
    ),
    style(
      <getStyle()>
    )
  ),
  body(
    h2(
      f.name
    ),
    div(
      id(
        "form"
      )
    ),
    script(
      src(
        "https://unpkg.com/react@17/umd/react.production.min.js"
      )
    ),
    script(
      src(
        "https://unpkg.com/react-dom@17/umd/react-dom.production.min.js"
      )
    ),
    script(
      src(
        "https://unpkg.com/@material-ui/core@latest/umd/material-ui.development.js"
      )
    ),
    script(
      src(
        getFilename(f)
      )
    )
  )
);

//---------------------JS-----------------------

str getStandardExpr(/boolean()) = "new Expr(
								  '  \"false\",
								  '  null,
								  '  \"bool\",
								  '  null,
								  ')";
								  
str getStandardExpr(/integer()) = "new Expr(
								  '  \"0\",
								  '  null,
								  '  \"int\",
								  '  null,
								  ')";
								  
str getStandardExpr(/string())  = "new Expr(
								  '  \"\",
								  '  null,
								  '  \"string\",
								  '  null,
								  ')";
								  
str getStandardExpr(AType _) = "";


str expr2js(ref(id(str name)))         = "new Expr(
										 '  \"<name>\",
										 '  null,
										 '  \"id\",
										 '  this.getVar
										 ')";
										 
str expr2js(\int(int x))               = "new Expr(
										 '  \"<x>\",
										 '  null,
										 '  \"int\",
										 '  null,
										 ')";
										 
str expr2js(\bool(bool b))             = "new Expr(
										 '  \"<b>\",
										 '  null,
										 '  \"bool\",
										 '  null,
										 ')";
										 
str expr2js(\str(str s))               = "new Expr(
										 '  <s>,
										 '  null,
										 '  \"string\",
										 '  null,
										 ')";
										 
str expr2js(\not(AExpr e))             = "new Expr(
										 '  <expr2js(e)>,
										 '  null,
										 '  \"!\",
										 '  null,
										 ')";
										 
str expr2js(\mul(AExpr e1, AExpr e2))  = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"*\",
										 '  null,
										 ')";
										 
str expr2js(\div(AExpr e1, AExpr e2))  = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"/\",
										 '  null,
										 ')";
										 
str expr2js(\add(AExpr e1, AExpr e2))  = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"+\",
										 '  null,
										 ')";
										 
str expr2js(\sub(AExpr e1, AExpr e2))  = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"-\",
										 '  null,
										 ')";
										 
str expr2js(\less(AExpr e1, AExpr e2)) = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"\<\",
										 '  null,
										 ')";
										 
str expr2js(\leq(AExpr e1, AExpr e2))  = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"\<=\",
										 '  null,
										 ')";
										 
str expr2js(\gt(AExpr e1, AExpr e2))   = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"\>\",
										 '  null,
										 ')";
										 
str expr2js(\geq(AExpr e1, AExpr e2))  = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"\>=\",
										 '  null,
										 ')";
										 
str expr2js(\equ(AExpr e1, AExpr e2))  = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"==\",
										 '  null,
										 ')";
										 
str expr2js(\neq(AExpr e1, AExpr e2))  = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"!=\",
										 '  null,
										 ')";
										 
str expr2js(\and(AExpr e1, AExpr e2))  = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"&&\",
										 '  null,
										 ')";
										 
str expr2js(\or(AExpr e1, AExpr e2))   = "new Expr(
										 '  <expr2js(e1)>,
										 '  <expr2js(e2)>,
										 '  \"||\",
										 '  null,
										 ')";
										
str expr2js(AExpr _) = "";

str question2state(regQuestion(content, name, ansType)) =
"this.state.vars.push({
'  name: \"<name.name>\",
'  val: <getStandardExpr(ansType)>,
'});";

str question2state(calcQuestion(content, name, ansType, expr)) =
"this.state.vars.push({
'  name: \"<name.name>\",
'  val: <expr2js(expr)>,
'});";

str question2state(ifStat(guard, condQuestions)) =
"<for ((AQuestion) q <- condQuestions) {>
'<question2state(q)>
'<}>";

str question2state(ifElseStat(guard, condQuestions, altQuestions)) =
"<for ((AQuestion) q <- condQuestions) {>
'<question2state(q)>
'<}>
'<for ((AQuestion) q <- altQuestions) {>
'<question2state(q)>
'<}>";

str question2state(AQuestion _) =
"";

str fillVars(AForm f) =
"<for ((AQuestion) q <- f.questions) {>
'<question2state(q)>
'<}>";

str buildExprClass() =
"class Expr {
'  constructor(e1, e2, operation, get) {
'    this.e1 = e1;
'    this.e2 = e2;
'    this.op = operation;
'    this.get = get;
'  }
'
'  eval = () =\> {
'    switch (this.op) {
'      case \"id\":
'        return this.get(this.e1).eval();
'      case \"bool\":
'        return this.e1 === \"true\";
'      case \"int\":
'        return parseInt(this.e1);
'      case \"string\":
'        return this.e1.valueOf();
'      case \"+\":
'        return this.e1.eval() + this.e2.eval();
'      case \"-\":
'        return this.e1.eval() - this.e2.eval();
'      case \"*\":
'        return this.e1.eval() * this.e2.eval();
'      case \"/\":
'        return this.e1.eval() / this.e2.eval();
'      case \"!\":
'        return !this.e1.eval();
'      case \"&&\":
'        return this.e1.eval() && this.e2.eval();
'      case \"||\":
'        return this.e1.eval() || this.e2.eval();
'      case \"\<\":
'        return this.e1.eval() \< this.e2.eval();
'      case \"\<=\":
'        return this.e1.eval() \<= this.e2.eval();
'      case \"==\":
'        return this.e1.eval() === this.e2.eval();
'      case \"!=\":
'        return this.e1.eval() !== this.e2.eval();
'      case \"\>=\":
'        return this.e1.eval() \>= this.e2.eval();
'      case \"\>\":
'        return this.e1.eval() \> this.e2.eval();
'      default: throw \"Not implemented\";
'    }
'  }
'}
";

str buildBoolClass() =
"class BooleanQuestion extends React.Component {
'  constructor(props) {
'    super(props);
'    this.state = {
'      name: props.name,
'      message: props.message,
'      enabled: props.enabled,
'      get: props.get,
'      update: props.update
'    };
'  }
'
'  changed = () =\> {
'    let obj = {
'      name: this.state.name,
'      val: new Expr(
'        `${!this.state.get(this.state.name).eval()}`,
'        null,
'        \"bool\",
'        null
'      )
'    }
'    this.state.update(this.state.name, obj);
'  };
'
'  render() {
'    let val = this.state.get(this.state.name);
'    return  e(
'      \'div\',
'      { id: \'comp\'},
'      e(
'        Checkbox,
'        {
'          checked: val ? val.eval() : false,
'          disabled: !this.state.enabled,
'          onChange: this.changed
'        }, 
'        null
'      ),
'      e(
'        \'label\',
'        { id: \'msg\'},
'        this.state.message
'      )
'    );
'  }
'}
";

str buildTextClass() =
"class TextQuestion extends React.Component {
'  constructor(props) {
'    super(props);
'    this.state = {
'      name: props.name,
'      message: props.message,
'      enabled: props.enabled,
'      type: props.type,
'      get: props.get,
'      update: props.update
'    };
'  }
'
'  changed = (event) =\> {
'    let obj = {
'      name: this.state.name,
'      val: new Expr(
'        `${event.target.value}`,
'        null,
'        this.state.type === \"number\" ? \"int\" : \"string\",
'        null
'      )
'    }
'    this.state.update(this.state.name, obj);
'  };
'
'  render() {
'    let val = this.state.get(this.state.name);
'    return  e(
'      \'div\',
'      { id: \'comp\'},
'      e(
'        \'label\',
'        { id: \'msg\'},
'        this.state.message
'      ),
'      e(\'br\'),
'      e(
'        OutlinedInput,
'        {
'          disabled: !this.state.enabled,
'          onChange: this.changed,
'          type: this.state.type,
'          value: val ? val.eval() : (this.state.type === \"number\" ? 0 : \'\')
'        }, 
'        null
'      ),
'    );
'  }
'}
";

str addFunctionProps() =
"get    : this.getVar,
'update : this.updateVar";

str aquestion2class(regQuestion(content, name, \boolean())) = 
"e(
'  BooleanQuestion,
'  {
'    message: <content>,
'    name   : \"<name.name>\",
'    enabled: true,
'    <addFunctionProps()>
'  },
'  null
'),";

str aquestion2class(regQuestion(content, name, \integer())) = 
"e(
'  TextQuestion,
'  {
'    message: <content>,
'    name   : \"<name.name>\",
'    enabled: true,
'    type   : \'number\',
'    <addFunctionProps()>
'  },
'  null
'),";

str aquestion2class(regQuestion(content, name, \string())) = 
"e(
'  TextQuestion,
'  {
'    message: <content>,
'    name   : \"<name.name>\",
'    enabled: true,
'    type   : \'text\',
'    <addFunctionProps()>
'  },
'  null
'),";

str aquestion2class(calcQuestion(content, name, \boolean(), expr)) =
"e(
'  BooleanQuestion,
'  {
'    message: <content>,
'    name   : \"<name.name>\",
'    enabled: false,
'    <addFunctionProps()>
'  },
'  null
'),";

str aquestion2class(calcQuestion(content, name, \integer(), expr)) =
"e(
'  TextQuestion,
'  {
'    message: <content>,
'    name   : \"<name.name>\",
'    enabled: false,
'    type   : \'number\',
'    <addFunctionProps()>
'  },
'  null
'),";

str aquestion2class(calcQuestion(content, name, \string(), expr)) =
"e(
'  TextQuestion,
'  {
'    message: <content>,
'    name   : \"<name.name>\",
'    enabled: false,
'    type   : \'text\',
'    <addFunctionProps()>
'  },
'  null
'),";

str aquestion2class(ifStat(guard, condQuestions)) =
"e(
'  \'div\',
'  null,
'  <expr2js(guard)>.eval() && 
'      [
'        <for ((AQuestion) q <- condQuestions) {>
'        <aquestion2class(q)>
'        <}>
'      ]
'),";

str aquestion2class(ifElseStat(guard, condQuestions, altQuestions)) =
"e(
'  \'div\',
'  null,
'  <expr2js(guard)>.eval() && 
'      [
'        <for ((AQuestion) q <- condQuestions) {>
'        <aquestion2class(q)>
'        <}>
'      ]
'),
'e(        /* Ugly hack, but React wouldn\'t rerender with a ternary. So be it. */
'  \'div\',
'  null,
'  !<expr2js(guard)>.eval() && 
'      [
'        <for ((AQuestion) q <- altQuestions) {>
'        <aquestion2class(q)>
'        <}>
'      ]
'),";

str aquestion2class(AQuestion _) = "";

str form2classes(AForm f) =
"<for ((AQuestion) q <- f.questions) {>
'<aquestion2class(q)>
'<}>";

str buildWebPage(AForm f) =
"class App extends React.Component {
'  constructor(props) {
'    super(props);
'    this.state = {
'      vars: [],
'    }
'	 <fillVars(f)>
'  }
'
'  getVar = (name) =\> {
'    let foundObj = this.state.vars.find(object =\> object.name === name);
'    if (foundObj === undefined) {
'      return null;
'    } else {
'      return foundObj.val;
'    }
'  }
'
'  updateVar = (name, obj) =\> {
'    let index = this.state.vars.findIndex(object =\> object.name === name);
'    this.setState(currState =\> {
'      currState.vars[index] = obj;
'      return currState;
'    });
'  }
'
'  render() {
'    return e(
'      \'div\',
'      null,
'      <form2classes(f)>
'    );
'  }
'}
'
'const domContainer = document.querySelector(\'#form\');
'ReactDOM.render(e(App), domContainer);";

str form2js(AForm f) =
"const e = React.createElement;
'const { Checkbox, OutlinedInput } = MaterialUI;
'
'<buildExprClass()>
'<buildBoolClass()>
'<buildTextClass()>
'<buildWebPage(f)>
";
