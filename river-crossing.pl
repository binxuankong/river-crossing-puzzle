'''
A state describes the situation immediately before or after a journey. It is
represented in the form of North-South
- North is a list of the items currently on the north bank
- South is a list of the items currently on the south bank
The items are the figures in the puzzle: the farmer, fox, goose and beans
The initial state is
	[farmer, fox, goose, beans]-[]
representing the start of the puzzle
'''

% Check if the bank is safe
% safe(+Bank)
safe(Bank) :-
    nonmember(farmer, Bank),
    memberchk(fox, Bank),
    memberchk(goose, Bank), !,
    fail.
safe(Bank) :-
    nonmember(farmer, Bank),
    memberchk(goose, Bank),
    memberchk(beans, Bank), !,
    fail. 
safe(_).


% Check if two states are equivalent, ie, they have the same number of each item in 
% their north banks and the same number of each item in their south banks
% equivalent(+State1, +State2)
equivalent(North1-South1, North2-South2) :-
    length(North1, _X),
    length(North2, _X),
    length(South1, _Y),
    length(South2, _Y),
    list_equiv(North1, North2),
    list_equiv(South1, South2).

% Check if two (unordered) lists are equivalent
% list_equivalent(+List1, +List2)
list_equivalent([], []).
list_equivalent([H1|T1], List2) :-
    list_equivalent(T1, Remaining),
    remove(H1, List2, Remaining).

% Remove an element from a list
% remove(+Element, +List, -ListWithoutElement)
remove(X, [X|T], T).
remove(X, [H|T], [H|R]) :-
    remove(X, T, R).


% Succeeds if a state is a goal state, ie, there are no items on the north bank and
% all other items are present on the south bank
% goal(+State)
goal(North-South) :-
    equivalent(North-South, []-[farmer, fox, goose, beans])


% Holds when the state is equivalent to some member of the sequence
% visited(+State, +Sequence)
visited(State, [H|_]) :-
    equivalent(State, H).
visited(State, [_|Sequence]) :-
    visited(State, Sequence).


% Given a bank, returns a list of either one item or two items (including the farmer)
% such that the other bank with the remainder left behind would be safe
% choose(-Items, +Bank)
choose(Items, Bank) :-
    member(farmer, Bank),
    remove(farmer, Bank, Remaining),
    check_safe(Items, Remaining, Remaining).

check_safe([farmer], [], Bank) :-
    safe(Bank).
check_safe([farmer, H], [H|_], Bank) :-
    remove(H, Bank, Left),
    safe(Left).
check_safe(Item, [_|T], Bank) :-
    check_safe(Item, T, Bank).


% Return the results from a possible safe journey from a given state 
% journey(+State1, -State2)
% As only the farmer can move, check which bank is the farmer at first
journey(North1-South1, North2-South2) :-
    member(f, North1),
    choose(Items, North1),
    remove_list(North1, Items, North2),
    append(Items, South1, South2).
journey(North1-South1, North2-South2) :-
    member(f, South1),
    choose(Items, South1),
    remove_list(South1, Items, South2),
    append(Items, North1, North2).

% Remove items in a list from another list
remove_list([], _, []).
remove_list([H|T], L2, Result) :-
    member(H, L2), !,
    remove_list(T, L2, Result). 
remove_list([H|T], L2, [H|Result]) :-
    remove_list(T, L2, Result).


% Returns the solution of the puzzle, ie, a sequence that starts with an initial
% state, ends with a goal state, and is such that each state is obtained from its
% predecessor by a safe journey
% succeeds(-Sequence)
succeeds(Sequence) :-
    extend([ [farmer, fox, goose, beans]-[] ], Sequence).

extend([LastState|VisitedSeq], Sequence) :-
    goal(LastState),
    reverse_sequence([LastState|VisitedSeq], [], Sequence).
extend([LastState|VisitedSeq], Sequence) :-
    \+ goal(LastState),
    journey(LastState, PossibleState),
    \+ visited(PossibleState, [LastState|VisitedSeq]),
    extend([PossibleState,LastState|VisitedSeq], Sequence).

% Reverse the order of a sequence
reverse_sequence([], Acc, Acc).
reverse_sequence([H|T], Acc, Result) :-
    reverse_sequence(T, [H|Acc], Result).

