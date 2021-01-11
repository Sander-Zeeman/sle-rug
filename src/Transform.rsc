module Transform

import Syntax;
import Resolve;
import AST;

import ParseTree;

/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(AForm f) {
  return f; 
}

/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
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