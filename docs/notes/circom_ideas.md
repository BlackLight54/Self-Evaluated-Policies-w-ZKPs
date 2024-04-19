# Respresent elements
We code elents either by enumeration or hashing

- anne = 1
- bob = 2
- carl = 3

------

- parent = 4
- ancestor = 5


# How do we check if the proof tree is correct?
We check it iteratively
- if a node is a fact(leaf), we simply look it up from the knowledge base(possible representation: parent(anne,bob)) = [4,1,2]
- if a node is a rule, we check if the unification and substitution are correct for its immediate children

This is an inductive checking, meaning that if the facts are correct, and the rules we appilied are valid, then the answer must be valid too.

# Reprensenting unifications
from circuitree, we pass an array of possible predicates and arguments

`goal_ancestor(unified_preds: int[10], unified_args: int[10][10], goal_args: int[10])`

# Psuedo-code

code for checking a single clause, here the ancesetor/2 for the following program :
    
```prolog
parent(anne, bob).
parent(bob, carol).
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
```
```
goal_ancestor(unified_preds: int[10], unified_args: int[10][10], goal_args: int[10]) {
    // first disjunctrtion    
    if (unified_pred s[0] == 4 && unified_preds[1] == 0 && ... //conjunction ) {
        // substitution
        goal_args[0] === unified_args[0][0];
        goal_args[1] === unified_args[0][1]
    }
    // second disjunctrtion
    if (unified_preds[0] == 5 && unified_preds[1] == 4 && unified_preds[2] == 0 && ...) {
        goal_args[0] === unified_args[0][0];
        unified_args[0][1] === unified_args[1][0];
        goal_args[1] === unified_args[1][1]
    }
    return false
}
```
