% from https://www.youtube.com/watch?v=nmBkU-l1zyc

% natnum example program 
% ?- natnum(s(s(0))). -> true
:- dynamic natnum/1.
natnum(0).
natnum(s(X)) :- natnum(X).

% ancestor example program
% ?- ancestor(anne, carol). -> true
parent(anne, bob).
parent(bob, carol).
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).

% vanilla meta-interpreter % mi(natnum(s(s(0)))). -> true
mi(true).
mi((A, B)) :- mi(A), mi(B).
mi(G) :- 
    G \= true,
    G \= (_,_),
    clause(G, B),
    mi(B).

% meta-circular : reify \=
mi_circ(true).
mi_circ((A, B)) :- mi_circ(A), mi_circ(B).
mi_circ(A \= B) :- A \= B.
mi_circ(G) :- 
    G \= true,
    G \= (_,_),
    G \= (_\=_),
    clause(G, B),
    mi_circ(B).

% clean representation !have to change program, add + before goals 
mi_clean(true).
mi_clean((A, B)) :- mi_clean(A), mi_clean(B).
mi_clean(+G)           :- mi_clean_clause(G, B), mi_clean(B).

mi_clean_clause(G, Body) :-
    clause(G, B),
    defaulty_better(B, Body).

defaulty_better(true, true).
defaulty_better((A,B), (BA,BB)) :-
    defaulty_better(A, BA),
    defaulty_better(B, BB).
defaulty_better(G, +G) :-
    G \= true,
    G \= (_,_),
    G \= (_\=_).

% Proof tree
% ?- mi_proof_tree(ancestor(anne,carol),T). 
% T = ((true=>parent(anne, bob), (true=>parent(bob, carol))=>ancestor(bob, carol))=>ancestor(anne, carol)) 
:- op(750, xfy, =>).

mi_proof_tree(true, true).
mi_proof_tree((A, B), (TreeA, TreeB)) :-
    mi_proof_tree(A, TreeA),
    mi_proof_tree(B, TreeB).
mi_proof_tree(G, Tree => G) :-
    G \= true,
    G \= (_,_),
    G \= (_\=_),
    clause(G, B),
    mi_proof_tree(B, Tree).

% Perform unification with occurs check
:- op(750, xfy, =>).

mi_proof_u_oc(true, true).
mi_proof_u_oc((A, B), (TreeA, TreeB)) :-
    mi_proof_u_oc(A, TreeA),
    mi_proof_u_oc(B, TreeB).
mi_proof_u_oc(G, Tree => G) :-
    G \= true,
    G \= (_,_),
    G \= (_\=_),
    clause(G0, B),
    unify_with_occurs_check(G0, G),
    mi_proof_u_oc(B, Tree).
    
