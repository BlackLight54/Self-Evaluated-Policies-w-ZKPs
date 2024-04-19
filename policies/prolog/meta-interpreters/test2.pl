solve(true, true).
solve((A, B), Path) :-
    solve(A, PathA),
    solve(B, PathB),
    Path = (PathA, PathB).

solve(Goal, (Goal, DerivedFrom)) :-
    clause(Goal, Body),
    copy_term((Goal, Body), (NewGoal, NewBody)),
    NewGoal = Goal,
    solve(NewBody, DerivedFrom).

trace(Goal, Path) :-
    solve(Goal, Path).

print_trace(true) :-
    write('true'), nl.

print_trace((Goal, true)) :-
    write(Goal), write(' derived from fact.'), nl.

print_trace((Goal, DerivedFrom)) :-
    write(Goal), write(' derived from:'), nl,
    print_subtrace(DerivedFrom, 2).

print_subtrace(true, Indent) :-
    print_indent(Indent),
    write('true'), nl.

print_subtrace((Goal, true), Indent) :-
    print_indent(Indent),
    write(Goal), write(' derived from fact.'), nl.

print_subtrace((Goal, DerivedFrom), Indent) :-
    print_indent(Indent),
    write(Goal), write(' derived from:'), nl,
    NewIndent is Indent + 2,
    print_subtrace(DerivedFrom, NewIndent).

print_subtrace((A, B), Indent) :-
    print_subtrace(A, Indent),
    print_subtrace(B, Indent).

print_indent(0).
print_indent(N) :-
    N > 0,
    write('  '),
    N1 is N - 1,
    print_indent(N1).


parent(anne, bob).
parent(bob, carol).
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
