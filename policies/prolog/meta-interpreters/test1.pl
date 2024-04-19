solve(fact, fact).
solve((A, B), Derivation) :-
    solve(A, DerivationA),
    solve(B, DerivationB),
    Derivation = (DerivationA, DerivationB).

solve(Goal, Derivation) :-
    clause(Goal, Body),
    replace_true_with_fact(Body, FactBody),
    solve(FactBody, BodyDerivation),
    Derivation = (Goal, BodyDerivation).

replace_true_with_fact(true, fact) :- !.
replace_true_with_fact((Head, true), (Head, fact)) :- !.
replace_true_with_fact(Body, Body).

trace(Goal) :-
    solve(Goal, Trace),
    write_trace(Trace).

write_trace(fact) :-
    write('fact'), nl.

write_trace((Goal, fact)) :-
    write(Goal), write(' :- fact.'), nl.

write_trace((Goal, Derivation)) :-
    write(Goal), write(' :-'), nl,
    write_derivation(Derivation, 1).

write_derivation((DerivationA, DerivationB), Depth) :-
    !,
    write_derivation(DerivationA, Depth),
    write_derivation(DerivationB, Depth).

write_derivation(fact, Depth) :-
    tab(Depth), write('fact'), nl.

write_derivation((Goal, fact), Depth) :-
    tab(Depth), write(Goal), write(' :- fact.'), nl.

write_derivation((Goal, Derivation), Depth) :-
    tab(Depth), write(Goal), write(' :-'), nl,
    NewDepth is Depth + 1,
    write_derivation(Derivation, NewDepth).

tab(N) :-
    N > 0,
    write('  '),
    N1 is N - 1,
    tab(N1).
tab(0).



parent(anne, bob).
parent(bob, carol).
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
