% Base cases for the interpreter.
solve(true, []).
solve((A, B), Trace) :-
    solve(A, TraceA),
    solve(B, TraceB),
    append(TraceA, TraceB, Trace).

% General case to process a clause from the knowledge base.
solve(Goal, [(Goal, Unification, Substitution) | Trace]) :-
    clause(Goal, Body),
    copy_term((Goal, Body), (NewGoal, NewBody)),
    NewGoal = Goal,
    unification_trace(Body, NewBody, Unification),
    solve(NewBody, Trace),
    findall((Var, Value), (member(Var, Goal), Var = Value), Substitution).

unification_trace(A, B, []) :- var(A), var(B), !.
unification_trace((A, C), (B, D), [(A, B) | Trace]) :-
    !,
    unification_trace(C, D, Trace).
unification_trace(A, B, [(A, B)]).

% Print the trace to the console.
trace(Goal) :-
    solve(Goal, Trace),
    write_trace(Trace).

write_trace([]) :-
    write('End of trace.'), nl.

write_trace([(Goal, Unification, Substitution) | Rest]) :-
    write('Goal: '), write(Goal), nl,
    write('Unification: '), nl,
    write_unifications(Unification),
    write('Substitutions: '), write(Substitution), nl,
    nl,
    write_trace(Rest).

write_unifications([]).
write_unifications([(Original, Unified) | Rest]) :-
    write('Original: '), write(Original), nl,
    write('Becomes: '), write(Unified), nl,
    write_unifications(Rest).


parent(anne, bob).
parent(bob, carol).
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).

% trace(ancestor(anne, carol)).