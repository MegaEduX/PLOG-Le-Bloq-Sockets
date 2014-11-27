getListObjectAtIndex([First | _], 0, First) :-
	!.

getListObjectAtIndex([_ | Others], Row, First) :-
	Row2 is Row - 1,
	
	getListObjectAtIndex(Others, Row2, First).

%
%	Shamelessly stolen from http://stackoverflow.com/questions/8519203/prolog-replace-an-element-in-a-list-at-a-specified-index
%	+List, +Index, +Value, -NewList
%

replace([_|T], 0, X, [X|T]).

replace([H|T], I, X, [H|R]):- 
	I > -1, 
	NI is I-1, 
	replace(T, NI, X, R), 
	!.

replace(L, _, _, L).