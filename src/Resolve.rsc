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
  Use g = {<i.src, i.name> | /AId i := f};
  return g;
}

Def defs(AForm f) {
  Def g = {};
  visit (f) {
    case regQuestion(_, str name, _, src = loc l):
      g = g + <name, l>;
    case calcQuestion(_, str name, _, _, src = loc l):
      g = g + <name, l>;
  }
  return g;
}