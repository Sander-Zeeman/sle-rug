module Resolve

import AST;

alias Def = rel[str name, loc def];

alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

alias RefGraph = tuple[
  Use uses,
  Def defs,
  UseDef useDef
];

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
  Use g = {<id.src, id.name> | /AExpr expr := f, ref(AId id) := expr};
  return g;
}

Def defs(AForm f) {
  Def g = {};
  visit (f) {
    case regQuestion(_, AId name, _):
      g = g + <name.name, name.src>;
    case calcQuestion(_, AId name, _, _):
      g = g + <name.name, name.src>;
  }
  return g;
}