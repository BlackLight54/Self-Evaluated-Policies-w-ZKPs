% Base cases for the interpreter.
solve(true, N, []).
solve((A, B), N, Trace) :-
    solve(A, N, TraceA),
    length(TraceA, L),
    M is N + L, 
    solve(B, M, TraceB),
    append(TraceA, TraceB, Trace).

solve(findall(Var, Predicate, Result), N, Trace) :-
    solve(Predicate, N, SubTrace),
    findall(Var, Predicate, Result),
    append(SubTrace, [(N, Predicate, [], [])], Trace).

% General case to process a clause from the knowledge base.
solve(Goal, N, [(N, Goal, Unification, Substitution) | Trace]) :-
    non_internal_predicate(Goal),
    clause(Goal, Body),
    copy_term((Goal, Body), (NewGoal, NewBody)),
    NewGoal = Goal,
    unification_trace(Body, NewBody, Unification),
    M is N + 1,
    solve(NewBody, M, Trace),
    findall((Var, Value), (member(Var, Goal), Var = Value), Substitution).

non_internal_predicate(Goal) :-
    \+ member(Goal, [sig_atomic(_), findall(_, _, _)]).  % Add more predicates here if needed.


unification_trace(A, B, []) :- var(A), var(B), !.
unification_trace((A, C), (B, D), [(A, B), (C, D)]) :- !.
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
write_unifications([(Original1, Unified1), (Original2, Unified2) | Rest]) :-
    write('Original: '), write(Original1), write(','), write(Original2), nl,
    write('Becomes: '), write(Unified1), write(','), write(Unified2), nl,
    write_unifications(Rest).
write_unifications([(Original, Unified) | Rest]) :-
    write('Original: '), write(Original), nl,
    write('Becomes: '), write(Unified), nl,
    write_unifications(Rest).

write_substitutions([]).
write_substitutions([(Var, Value) | Rest]) :-
    write(Var), write(' = '), write(Value), nl,
    write_substitutions(Rest).
% Pretty print the trace.
print_trace([]).
print_trace([(N, Goal, Unification, Substitution) | T]) :-
    format("Step ~w:~n", [N]),
    format("Goal: ~w~n", [Goal]),
    format("Unification: ~nOriginal: ~w~nBecomes: ~w~n", Unification),
    format("Substitutions: ~w~n", [Substitution]),
    print_trace(T).


    :- include('./input.pl').
:- include('./matrix.pl').

% Flow: 
% 1. sum individual past consumptions
% 2. calculate rolling consumption
% 3. classify using rolling consumpiton
% 4. classify using currently saved amount compared to rollingconsumption
% 5. apply savings based support to base payement
% 6. apply social credential based support 

% === 1. Aggregate past consumptions ===
monthly_consumptions(Monthly_consumptions) :- findall((Month,Amount), monthly_consumption(Month,Amount), Monthly_consumptions).

% sum op monthly_consumptions
sum_of_monthly_consumptions([],0).
sum_of_monthly_consumptions([(_,Amount)|T], Sum) :-
    sum_of_monthly_consumptions(T, Rest),
    Sum is Amount + Rest.

% === 2. Calculate rolling consumption ===
rolling_consumption(Consumptions, Result):- 
    sum_of_monthly_consumptions(Consumptions,Sum),
    Result is Sum / 12.

% === 3. classify using rolling consumption ===
consumptionClass(Consumptions, Class):-
    rolling_consumption(Consumptions, Rolling_consumption),
    calcConsumptionClass(Rolling_consumption, Class).
    
calcConsumptionClass(Rolling_consumption,Class):-
    rolling_treshold('high',Treshold),
    Rolling_consumption >= Treshold,
    Class = 'high';
    rolling_treshold('mid',Treshold),
    Rolling_consumption >= Treshold,
    Class = 'mid';
    Class = 'low'.

% === 4. classify using savings ===
savingsClass(Class,Consumptions):-
    currentConsumption(Consumption),
    rolling_consumption(Consumptions, Rolling_consumption),
    calcSavingsClass(Rolling_consumption,Consumption,Class).

calcSavingsClass(Rolling_consumption,Consumption,Class):-
    savings_treshold('high',Treshold),
    CurrentSaving is Rolling_consumption - Consumption,
    CurrentSaving > Treshold,
    Class = 'high';
    savings_treshold('mid',Treshold),
    CurrentSaving is Rolling_consumption - Consumption,
    CurrentSaving > Treshold,
    Class = 'mid';
    savings_treshold('low',Treshold),
    CurrentSaving is Rolling_consumption - Consumption,
    CurrentSaving > Treshold,
    Class = 'low';
    Class = 'none'.

% === 5. Apply savings based support ===
paymentBase(Payment):-
    currentConsumption(Amount),
    currentPrice(Price,'HUF'),
    Payment is Price * Amount.

applySupport(Input, 'nominal', Value, Output):-
    Output is Input - Value.
applySupport(Input, 'percent', Value, Output):-
    AmountToBeSubtracted is Input * Value div 100,
    Output is Input - AmountToBeSubtracted.

applySavingsSupport(Input, RollingClass, SavingsClass, Output):-
    support_matrix(RollingClass, SavingsClass, Type, Value),
    applySupport(Input, Type, Value, Output).

% === 6. Apply social standing based support ===
socialCreds(Creds) :- findall((CredType,SupportType,SupportValue), social_suport(CredType,SupportType,SupportValue), Creds).

applySocialSupports(Input,[], Input).
applySocialSupports(Input,[(_,SupportType,SupportValue)|CredsTail],Result):-
    applySupport(Input, SupportType, SupportValue,Output),
    applySocialSupports(Output,CredsTail,Result).

calculatedPayment(PaymentAfterSocialSupports):-
    monthly_consumptions(Consumptions),
    consumptionClass(Consumptions,RollingClass),
    write('ConsumptionClass: '),
    writeln(RollingClass),
    savingsClass(SavingsClass,Consumptions),
    write('Savings class: '),
    writeln(SavingsClass),
    paymentBase(BasePayment),
    write('Base payment : '),
    writeln(BasePayment),
    applySavingsSupport(BasePayment,RollingClass,SavingsClass, PaymentAfterSavings),
    write('Payment after savings: '),
    writeln(PaymentAfterSavings),
    socialCreds(SocialCreds),
    write('SocialCreds:'),
    writeln(SocialCreds),
    applySocialSupports(PaymentAfterSavings,SocialCreds,PaymentAfterSocialSupports),
    write('Payment after Social supports: '),
    writeln(PaymentAfterSocialSupports).

inputPaymentOk:-
    calculatedPayment(Payment),
    inputPayment(Payment).

start:- 
    calculatedPayment(_),
    inputPaymentOk,
    writeln('Input payment and calcualted payment match!'),
    halt(0).



