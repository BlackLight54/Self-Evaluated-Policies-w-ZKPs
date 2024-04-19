% Base cases for the interpreter.
solve(true, N, []).
solve((A, B), N, Trace) :-
    solve(A, N, TraceA),
    length(TraceA, L),
    M is N + L, 
    solve(B, M, TraceB),
    append(TraceA, TraceB, Trace).

% General case to process a clause from the knowledge base.
solve(Goal, N, [(N, Goal, Unification, Substitution) | Trace]) :-
    clause(Goal, Body),
    copy_term((Goal, Body), (NewGoal, NewBody)),
    NewGoal = Goal,
    unification_trace(Body, NewBody, Unification),
    M is N + 1,
    solve(NewBody, M, Trace),
    findall((Var, Value), (member(Var, Goal), Var = Value), Substitution).

unification_trace(A, B, []) :- var(A), var(B), !.
unification_trace((A, C), (B, D), [(A, B) | Trace]) :-
    !,
    unification_trace(C, D, Trace).
unification_trace(A, B, [(A, B)]).

% Print the trace to the console.
trace(Goal) :-
    solve(Goal, 1, Trace),
    write_trace(Trace).

write_trace([]) :-
    write('End of trace.'), nl.

write_trace([(N, Goal, Unification, Substitution) | Rest]) :-
    format("Step ~w:\n", [N]),
    write('Goal: '), write(Goal), nl,
    write('Unification: '), nl,
    write_unifications(Unification),
    write('Substitutions: '), nl,
    write_substitutions(Substitution),
    nl,
    write_trace(Rest).

write_unifications([]).
write_unifications([(Original, Unified) | Rest]) :-
    write('Original: '), write(Original), nl,
    write('Becomes: '), write(Unified), nl,
    write_unifications(Rest).

write_substitutions([]).
write_substitutions([(Var, Value) | Rest]) :-
    write(Var), write(' = '), write(Value), nl,
    write_substitutions(Rest).

parent(anne, bob).
parent(bob, carol).
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
