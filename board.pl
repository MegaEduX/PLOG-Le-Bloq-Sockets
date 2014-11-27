fillList(RetList, _, Index, Index, RetList) :-
	!.

fillList(List, Element, CurrentIndex, ListSize, RetList) :-
	replace(List, CurrentIndex, Element, Filled),
	
	NewIndex is CurrentIndex + 1,
	
	fillList(Filled, Element, NewIndex, ListSize, RetList).

createBoard(Width, Height, ReturnBoard) :-
	length(Row, Width),
	fillList(Row, 0, 0, Width, FilledRow),
	
	length(Board, Height),
	fillList(Board, FilledRow, 0, Height, ReturnBoard).
