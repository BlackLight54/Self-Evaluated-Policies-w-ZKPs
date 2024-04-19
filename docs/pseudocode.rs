struct ProofTree {
    goal: Predicate,
    unification: Vec<Term>
    children: Vec<ProofTree>
}
enum Term {
    Atom,
    Var,
    Predicate
}

struct Predicate {
    name: String,
    args: Vec<Term>
}

struct Atom {
    value: String
}

struct Var {
    name: String
}

struct Clause {
    head: Predicate,
    body: Vec<Predicate>
}

struct Program {
    clauses: Vec<Clause>
}
// check if a proof tree node is valid, by matching it up with the program
/*Example
Let’s take our previous example Prolog program about the ancestors of bob and carol,
and assume that our goal is to prove that anne is the ancestor of carol. In the root of
the proof tree for this statement, we will see our goal and its unifications. In this node,
we need to ensure that all the variables are filled in with the same parameters as in its
definition. This process is demonstrated in figure 5.2. Essentially, we need to make sure
that if the first parameter of the goal is anne, then the first parameter in the first part of
the unification body is also anne, and so on.
*/
fn checkProofTreeNode(ProofTree root, Program program){
    let clause = program.clauses
    .filter(
        |clause|
        // check if clause head is in the program
        head = clause.head 
        if head.name != root.goal.name
            return false
        if head.args.len() != root.goal.args.len()
            return false 
    )
    .filter(
        |clause|
        // check if clause body can be unified
        body = clause.body
        for i in 0..body.len(){
            if (body[i].name != root.unification[i].name){
                return false;
            }
            if (body[i].args.len() != root.unification[i].args.len()){
                return false;
            }
        }        
    )
    .filter(
        |clause|
        // check variables in head, if their names match in the program, then their values should match in the proof tree
        for i in 0..root.goal.args.len(){
            for j in 0..clause.body.len(){
                for k in 0..clause.body[j].args.len(){
                    if (clause.head.args[i] is Var &&
                        clause.body[j].args[k] is Var &&                    
                        clause.head.args[i].name == clause.body[j].args[k].name){
                       if (root.goal.args[i].value != root.unification[j].args[k].value){
                           return false;
                       }  
                    }
                }
            }
        }
    )
    .filter(
        |clause|
        // check variables in body
        for i in 0..root.body.len(){
            for j in i..clause.body.len(){
                for k in 0..root.body[i].args.len(){
                    for l in 0..clause.body[j].args.len(){
                        if (clause.body[i].args[k] is Var &&
                            clause.body[j].args[l] is Var &&
                            clause.body[i].args[k].name == clause.body[j].args[l].name){
                            if (root.unification[i].args[k].value != root.unification[j].args[l].value){
                                return false;
                            }
                        }
                    }
                }
            }
        }      
    );
    if (clause == None){
        return false;
    }
}

fn checkTransition(ProofTree root){
    unification = root.unification
    children = root.children
    // check if they have the same name and argcount 
    for i in 0..children.len(){
        if (children[i].goal.name != unification[i].name){
            return false;
        }
        if (children[i].goal.args.len() != unification[i].args.len()){
            return false;
        }
        for j in children[i].goal.args{
            if (children[i].goal.args[j] != unification[i].args[j]){
                return false;
            }
        }
    }
    return true;   

}

fn checkRecursively(ProofTree root, Program program){
    if checkProofTreeNode(root, program) == false{
        return false;
    }
    if checkTransition(root) == false{
        return false;
    }
    for i in 0..root.children.len(){
        if checkRecursively(root.children[i], program) == false{
            return false;
        }
    }
}