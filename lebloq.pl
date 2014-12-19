:- ensure_loaded(['utilities.pl', 'printing.pl', 'lists.pl', 'board.pl', 'sockets.pl']).
:- use_module(library(random)).

%
%	Main Run Loop
%

runMainLoop(Board, BoardSizeX, BoardSizeY, PlayCount, CurrentPlayer, PlayerOnHold) :-
	nl,
	
	printBoard(Board),
	
	nl,
	
	promptForPlay(Board, BoardSizeX, BoardSizeY, PlayCount, CurrentPlayer, NewBoard),
	
	writeln('[Scoring] Calculating and filling score... (This may take a while for big boards...)'),
	
	ScoringPlayer is CurrentPlayer + 3,
	
	fillBoardWithScoring(NewBoard, BoardSizeX, BoardSizeY, 0, 0, ScoringPlayer, ScoredBoard),
	
	(
		(
			checkForAvailableTurns(ScoredBoard, BoardSizeX, BoardSizeY),
			
			AvailableTurns is 1,
			
			NewPlayCount is (PlayCount + 1),
			
			runMainLoop(ScoredBoard, BoardSizeX, BoardSizeY, NewPlayCount, PlayerOnHold, CurrentPlayer)
		);
		
		(
			AvailableTurns is 0,
			
			nl,
			
			printBoard(ScoredBoard),
			
			nl,
			
			congratulateWinner(ScoredBoard, BoardSizeX, BoardSizeY),
			
			writeln('Game Over!')
		)
	).

runMainLoopAIvsAI(Board, BoardSizeX, BoardSizeY, PlayCount, CurrentPlayer, PlayerOnHold) :-
	nl,
	
	printBoard(Board),
	
	nl,
	
	%	Player 1 difficulty is 1
	%	Player 2 difficulty is 2
	
	playComputerino(Board, CurrentPlayer, BoardSizeX, BoardSizeY, PlayCount, CurrentPlayer, NewBoard),
	
	writeln('[Scoring] Calculating and filling score... (This may take a while for big boards...)'),
	
	ScoringPlayer is CurrentPlayer + 3,
	
	fillBoardWithScoring(NewBoard, BoardSizeX, BoardSizeY, 0, 0, ScoringPlayer, ScoredBoard),
	
	(
		(
			checkForAvailableTurns(ScoredBoard, BoardSizeX, BoardSizeY),
			
			AvailableTurns is 1,
			
			NewPlayCount is (PlayCount + 1),
			
			runMainLoopAIvsAI(ScoredBoard, BoardSizeX, BoardSizeY, NewPlayCount, PlayerOnHold, CurrentPlayer)
		);
		
		(
			AvailableTurns is 0,
			
			nl,
			
			printBoard(ScoredBoard),
			
			nl,
			
			congratulateWinner(ScoredBoard, BoardSizeX, BoardSizeY),
			
			writeln('Game Over!')
		)
	).

runMainLoopPlayerVsAI(Board, Difficulty, BoardSizeX, BoardSizeY, PlayCount, CurrentPlayer, PlayerOnHold) :-
	nl,
	
	printBoard(Board),
	
	nl,
	
	(
		(
			CurrentPlayer is 1,
			promptForPlay(Board, BoardSizeX, BoardSizeY, PlayCount, CurrentPlayer, NewBoard)
			
		);
		
		(
			CurrentPlayer is 2,
			playComputerino(Board, Difficulty, BoardSizeX, BoardSizeY, PlayCount, CurrentPlayer, NewBoard)
		)
	),
	
	writeln('[Scoring] Calculating and filling score... (This may take a while for big boards...)'),
	
	ScoringPlayer is CurrentPlayer + 3,
	
	fillBoardWithScoring(NewBoard, BoardSizeX, BoardSizeY, 0, 0, ScoringPlayer, ScoredBoard),
	
	(
		(
			checkForAvailableTurns(ScoredBoard, BoardSizeX, BoardSizeY),
			
			AvailableTurns is 1,
			
			NewPlayCount is (PlayCount + 1),
			
			runMainLoopPlayerVsAI(ScoredBoard, Difficulty, BoardSizeX, BoardSizeY, NewPlayCount, PlayerOnHold, CurrentPlayer)
		);
		
		(
			AvailableTurns is 0,
			
			nl,
			
			printBoard(ScoredBoard),
			
			nl,
			
			congratulateWinner(ScoredBoard, BoardSizeX, BoardSizeY),
			
			writeln('Game Over!')
		)
	).

readPieceType(RetVal) :-
	readInteger(RetVal),
	
	RetVal > 0,
	RetVal < 4,
	
	!.

readPieceType(RetVal) :-
	writeln('You need to choose one value from 1/2/3.'),
	readPieceType(RetVal).

readPieceOrientation(RetVal) :-
	read(RetVal),
	
	(RetVal == 'v'; RetVal == 'h'),
	
	!.

readPieceOrientation(RetVal) :-
	writeln('You need to type either "v" or "h".'),
	readPieceOrientation(RetVal).

%
%	Validation
%

checkForBlankSpaces(_, 0) :-
	!.

checkForBlankSpaces([_ | Tail], NumberOfSpaces) :-
	Tail is 0,
	
	NewNumber is (NumberOfSpaces - 1),
	
	checkForBlankSpaces(Tail, NewNumber).

getPieceWidthAndHeight(PieceType, PieceOrientation, WidthReturn, HeightReturn) :-

	(
		(PieceType == 1),
		
		(
			(PieceOrientation == 'v', WidthReturn is 2, HeightReturn is 3);
			(PieceOrientation == 'h', WidthReturn is 3, HeightReturn is 2)
		)
	);
	
	(
		(PieceType == 2),
		
		(
			(PieceOrientation == 'v', WidthReturn is 2, HeightReturn is 4);
			(PieceOrientation == 'h', WidthReturn is 4, HeightReturn is 2)
		)
	);
	
	(
		(PieceType == 3),
		
		(
			(PieceOrientation == 'v', WidthReturn is 3, HeightReturn is 4);
			(PieceOrientation == 'h', WidthReturn is 4, HeightReturn is 3)
		)
	)
	
	.

checkHorizontalAvailability(_, _, 0) :-
	!.

checkHorizontalAvailability(Row, Index, Length) :-
	getListObjectAtIndex(Row, Index, RetVal),
	
	RetVal is 0,
	
	NewIndex is Index + 1,
	NewLength is Length - 1,
	
	!,
	
	checkHorizontalAvailability(Row, NewIndex, NewLength).

%
%	Piece Positioning Checks
%

checkRectangularAvailability(_, _, _, _, 0) :-
	!.

checkRectangularAvailability(_, _, _, 0, _) :-
	!.

checkRectangularAvailability(Board, FirstX, FirstY, LengthX, LengthY) :-
	getListObjectAtIndex(Board, FirstY, Row),
	
	checkHorizontalAvailability(Row, FirstX, LengthX),
	
	NextY is FirstY + 1,
	NewLengthY is LengthY - 1,
	
	checkRectangularAvailability(Board, FirstX, NextY, LengthX, NewLengthY).

pieceHasFreeSpace(Board, PieceType, PieceOrientation, PieceX, PieceY) :-
	getPieceWidthAndHeight(PieceType, PieceOrientation, Width, Height),
	
	checkRectangularAvailability(Board, PieceX, PieceY, Width, Height).

%
%	Check Line for Block Existance
%

checkLineForBlockExistance(_, _, 0) :-
	!,
	
	fail.

checkLineForBlockExistance(Line, Index, _) :-
	getListObjectAtIndex(Line, Index, Object),
	
	(Object \== 0),
	
	!.

checkLineForBlockExistance(Line, Index, Length) :-
	%	404 Piece Not Found.
	
	NewIndex is Index + 1,
	NewLength is Length - 1,
	
	checkLineForBlockExistance(Line, NewIndex, NewLength).

%
%	Check Column for Block Existance
%

checkColumnForBlockExistance(_, _, _, 0) :-
	!,
	
	fail.

checkColumnForBlockExistance(Board, Column, X, _) :-
	getListObjectAtIndex(Board, Column, RetLine),
	getListObjectAtIndex(RetLine, X, RetObject),
	
	(RetObject \== 0),
	
	!.

checkColumnForBlockExistance(Board, Column, X, Length) :-
	%	404 Piece Not Found.
	
	NewCol is Column + 1,
	NewLen is Length - 1,
	
	checkColumnForBlockExistance(Board, NewCol, X, NewLen).

%
%	Check Line for Block Occurence
%

checkLineForBlockOccurence(_, _, _, 0) :-
	!,
	
	fail.

checkLineForBlockOccurence(Line, Match, Index, _) :-
	getListObjectAtIndex(Line, Index, Object),
	
	(Object == Match),
	
	!.

checkLineForBlockOccurence(Line, Match, Index, Length) :-
	%	404 Piece Not Found.
	
	NewIndex is Index + 1,
	NewLength is Length - 1,
	
	checkLineForBlockOccurence(Line, Match, NewIndex, NewLength).

%
%	Check Column for Block Occurence
%

checkColumnForBlockOccurence(_, _, _, _, 0) :-
	!,
	
	fail.

checkColumnForBlockOccurence(Board, Match, Column, X, _) :-
	getListObjectAtIndex(Board, Column, RetLine),
	getListObjectAtIndex(RetLine, X, RetObject),
	
	(RetObject == Match),
	
	!.

checkColumnForBlockOccurence(Block, Match, Column, X, Length) :-
	%	404 Piece Not Found
	
	NewColumn is Column + 1,
	NewLength is Length - 1,
	
	checkColumnForBlockOccurence(Block, Match, NewColumn, X, NewLength).
	

%
%	Adjacent Block Check
%

pieceHasAdjacentBlock(Board, PieceType, PieceOrientation, PieceX, PieceY) :-
	getPieceWidthAndHeight(PieceType, PieceOrientation, PieceWidth, PieceHeight),
	
	(
		%	Top Line
		
		(
			TopY is PieceY - 1,
			
			getListObjectAtIndex(Board, TopY, ReturnLineTop),
			checkLineForBlockExistance(ReturnLineTop, PieceX, PieceWidth)
		);
		
		
		%	Bottom Line
		
		(
			BottomY is PieceY + PieceHeight,
			
			getListObjectAtIndex(Board, BottomY, ReturnLineBottom),
			checkLineForBlockExistance(ReturnLineBottom, PieceX, PieceWidth)	
		);
		
		%	Left Column
		
		(
			LeftX is PieceX - 1,
			
			checkColumnForBlockExistance(Board, PieceY, LeftX, PieceHeight)
		);
		
		
		%	Right Column
		
		(
			RightX is PieceX + PieceWidth,
			
			checkColumnForBlockExistance(Board, PieceY, RightX, PieceHeight)
		)
		
	).

pieceHasNoAdjacentSameBlock(Board, PieceType, PieceOrientation, PieceX, PieceY) :-
	getPieceWidthAndHeight(PieceType, PieceOrientation, PieceWidth, PieceHeight),
	
	(
		%	Top Line
		
		(
			TopY is PieceY - 1,
			
			(
				not(getListObjectAtIndex(Board, TopY, ReturnLineTop));
				
				(
					getListObjectAtIndex(Board, TopY, ReturnLineTop),
					not(checkLineForBlockOccurence(ReturnLineTop, PieceType, PieceX, PieceWidth))
				)
			)
		),
		
		%	Bottom Line
		
		(
			BottomY is PieceY + PieceHeight,
			
			(
				not(getListObjectAtIndex(Board, BottomY, ReturnLineBottom));
				
				(
					getListObjectAtIndex(Board, BottomY, ReturnLineBottom),
					not(checkLineForBlockOccurence(ReturnLineBottom, PieceType, PieceX, PieceWidth))
				)
			)
		),
		
		%	Left Column
		
		(
			LeftX is PieceX - 1,
			
			not(checkColumnForBlockOccurence(Board, PieceType, PieceY, LeftX, PieceHeight))
		),
		
		%	Right Column
		
		(
			RightX is PieceX + PieceWidth,
			
			not(checkColumnForBlockOccurence(Board, PieceType, PieceY, RightX, PieceHeight))
		)
	).
	
%
%	Line Fill
%

lineFill(Line, _, 0, _, Line) :-
	!.

lineFill(Line, PieceType, Width, X, NewLine) :-
	replace(Line, X, PieceType, ReturnedLine),
	
	NewWidth is Width - 1,
	NewX is X + 1,
	
	lineFill(ReturnedLine, PieceType, NewWidth, NewX, NewLine).

%
%	Board Fill
%

boardFill(Board, _, _, 0, _, _, Board) :-
	!.

boardFill(Board, PieceType, Width, Height, X, Y, NewBoard) :-
	write('[bF] Filling... ('), write(Width), write(', '), write(Height), write(', '), write(X), write(', '), write(Y), writeln(')'), 
	
	getListObjectAtIndex(Board, Y, Line),
	
	lineFill(Line, PieceType, Width, X, NewLine),
	replace(Board, Y, NewLine, ReturnedBoard),
	
	NewHeight is Height - 1,
	NewY is Y + 1,
	
	boardFill(ReturnedBoard, PieceType, Width, NewHeight, X, NewY, NewBoard).

fillBoardWithNewBlock(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard) :-
	writeln('[Fill Board] Starting...'),

	getPieceWidthAndHeight(PieceType, PieceOrientation, PieceWidth, PieceHeight),
	
	write('[Fill Board] Filling... ('), write(PieceX), write(', '), write(PieceY), write(', '), write(PieceWidth), write(', '), write(PieceHeight), writeln(')'), 
	
	boardFill(Board, PieceType, PieceWidth, PieceHeight, PieceX, PieceY, NewBoard),
	
	writeln('[Fill Board] Done!').

%
%	Turn Validation
%

validateTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard) :-
	nl,
	
	writeln('[Turn Validation] Checking for free space...'),
	pieceHasFreeSpace(Board, PieceType, PieceOrientation, PieceX, PieceY),
	
	writeln('[Turn Validation] Checking for adjacent blocks of the same type...'),
	pieceHasNoAdjacentSameBlock(Board, PieceType, PieceOrientation, PieceX, PieceY),
	
	writeln('[Turn Validation] Checking for at least a block nearby...'),
	pieceHasAdjacentBlock(Board, PieceType, PieceOrientation, PieceX, PieceY),
	
	%	And after all validations...
	
	writeln('[Turn Validation] Filling board...'),
	
	fillBoardWithNewBlock(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard),
	
	!.

validateTurn(_, _, _, _, _, _) :-
	writeln('Turn validation failed.'),
	
	fail.

validateTurnSilent(Board, PieceType, PieceOrientation, PieceX, PieceY) :-
	pieceHasFreeSpace(Board, PieceType, PieceOrientation, PieceX, PieceY),
	pieceHasNoAdjacentSameBlock(Board, PieceType, PieceOrientation, PieceX, PieceY),
	pieceHasAdjacentBlock(Board, PieceType, PieceOrientation, PieceX, PieceY).
	
	%	write('[Debug] Piece '), write(PieceType), write(' / '), write(PieceOrientation), write(' - '), write(PieceX), write(', '), write(PieceY), writeln(' can be placed.').

validateFirstTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard) :-
	nl,
	
	%	writeln('[Turn Validation] Checking for free space...'),
	
	pieceHasFreeSpace(Board, PieceType, PieceOrientation, PieceX, PieceY),
	
	%	writeln('[Turn Validation] Filling board...'),
	
	fillBoardWithNewBlock(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard),
	
	!.

validateFirstTurn(_, _, _, _, _, _) :-
	writeln('Turn validation failed.'),
	
	fail.

%
%	Check for Available Turns
%

iterateThroughBoard(Board, PieceType, PieceOrientation, _, _, CurrentX, CurrentY) :-
	validateTurnSilent(Board, PieceType, PieceOrientation, CurrentX, CurrentY),
	
	!.

iterateThroughBoard(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, CurrentX, CurrentY) :-
	(	
		CurrentX is BoardSizeX - 1,
		not(CurrentY is BoardSizeY - 1),
		
		NewX is 0,
		NewY is CurrentY + 1,
		
		iterateThroughBoard(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, NewX, NewY)
	);
	
	%	End of everything...
	
	(	
		CurrentY is BoardSizeY - 1,
		CurrentX is BoardSizeX - 1,
		
		fail
		
		%	Return True! Or something.
	);
	
	%	Normal case...
	
	(	
		not(CurrentX is BoardSizeX - 1),
		
		NewX is CurrentX + 1,
		
		iterateThroughBoard(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, NewX, CurrentY)
	).

checkForAvailableTurns(Board, BoardSizeX, BoardSizeY) :-
	writeln('[Logic] Checking for endgame condition...'),
	
	(
		iterateThroughBoard(Board, 1, 'v', BoardSizeX, BoardSizeY, 0, 0);
		iterateThroughBoard(Board, 1, 'h', BoardSizeX, BoardSizeY, 0, 0);
		iterateThroughBoard(Board, 2, 'v', BoardSizeX, BoardSizeY, 0, 0);
		iterateThroughBoard(Board, 2, 'h', BoardSizeX, BoardSizeY, 0, 0);
		iterateThroughBoard(Board, 3, 'v', BoardSizeX, BoardSizeY, 0, 0);
		iterateThroughBoard(Board, 3, 'h', BoardSizeX, BoardSizeY, 0, 0)
	).

%
%	Count Available Turns
%

cAvailableTurn(_, _, _, _, SizeY, _, SizeY, Count, RetVal) :-
	unify_with_occurs_check(Count, RetVal),
	
	!.

cAvailableTurn(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, CurrentX, CurrentY, CurrentCount, RetVal) :-
	(
		(
			validateTurnSilent(Board, PieceType, PieceOrientation, CurrentX, CurrentY),
			NewCount is CurrentCount + 1
		);
		
		(
			NewCount is CurrentCount
		)
		
	),
	
	(
		(	
			CurrentX is BoardSizeX - 1,
			not(CurrentY is BoardSizeY - 1),
		
			NewX is 0,
			NewY is CurrentY + 1,
		
			cAvailableTurn(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, NewX, NewY, NewCount, RetVal)
		);
		
		%	End of everything...
		
		(	
			CurrentY is BoardSizeY - 1,
			CurrentX is BoardSizeX - 1,
			
			cAvailableTurn(_, _, _, _, BoardSizeY, _, BoardSizeY, NewCount, RetVal)
		);
		
		%	Normal case...
		
		(	
			not(CurrentX is BoardSizeX - 1),
		
			NewX is CurrentX + 1,
		
			cAvailableTurn(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, NewX, CurrentY, NewCount, RetVal)
		)
	).

countAvailableTurns(Board, BoardSizeX, BoardSizeY, ReturnValue) :-
	cAvailableTurn(Board, 1, 'v', BoardSizeX, BoardSizeY, 0, 0, 0, Sum),
	cAvailableTurn(Board, 1, 'h', BoardSizeX, BoardSizeY, 0, 0, Sum, Sum2),
	cAvailableTurn(Board, 2, 'v', BoardSizeX, BoardSizeY, 0, 0, Sum2, Sum3),
	cAvailableTurn(Board, 2, 'h', BoardSizeX, BoardSizeY, 0, 0, Sum3, Sum4),
	cAvailableTurn(Board, 3, 'v', BoardSizeX, BoardSizeY, 0, 0, Sum4, Sum5),
	cAvailableTurn(Board, 3, 'h', BoardSizeX, BoardSizeY, 0, 0, Sum5, ReturnValue).
	
%
%	Get an Available Turn
%

itbAvailableTurn(Board, PieceType, PieceOrientation, _, _, CurrentX, CurrentY, RetX, RetY) :-
	validateTurnSilent(Board, PieceType, PieceOrientation, CurrentX, CurrentY),
	
	unify_with_occurs_check(RetX, CurrentX),
	unify_with_occurs_check(RetY, CurrentY),

	!.

itbAvailableTurn(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, CurrentX, CurrentY, RetX, RetY) :-
	(	
		CurrentX is BoardSizeX - 1,
		not(CurrentY is BoardSizeY - 1),

		NewX is 0,
		NewY is CurrentY + 1,

		itbAvailableTurn(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, NewX, NewY, RetX, RetY)
	);

	%	End of everything...

	(	
		CurrentY is BoardSizeY - 1,
		CurrentX is BoardSizeX - 1,

		fail

		%	Return True! Or something.
	);

	%	Normal case...

	(	
		not(CurrentX is BoardSizeX - 1),

		NewX is CurrentX + 1,

		itbAvailableTurn(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, NewX, CurrentY, RetX, RetY)
	).

getAnAvailableTurn(Board, BoardSizeX, BoardSizeY, RetX, RetY, RetType, RetOrientation) :-
	(
		(
			itbAvailableTurn(Board, 1, 'v', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
			
			RetType is 1,
			
			unify_with_occurs_check(RetOrientation, 'v')
		);
		
		(
			itbAvailableTurn(Board, 1, 'h', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
			
			RetType is 1,
			
			unify_with_occurs_check(RetOrientation, 'h')
		);
		
		(
			itbAvailableTurn(Board, 2, 'v', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
			
			RetType is 2,
			
			unify_with_occurs_check(RetOrientation, 'v')
		);
		
		(
			itbAvailableTurn(Board, 2, 'h', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
			
			RetType is 2,
			
			unify_with_occurs_check(RetOrientation, 'h')
		);
		
		(
			itbAvailableTurn(Board, 3, 'v', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
			
			RetType is 3,
			
			unify_with_occurs_check(RetOrientation, 'v')
		);
		
		(
			itbAvailableTurn(Board, 3, 'h', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
			
			RetType is 3,
			
			unify_with_occurs_check(RetOrientation, 'h')
		)
	).

%
%	Get Available Turn at Index
%

gatAtIndex(_, _, _, _, SizeY, _, SizeY, Count, RetVal) :-
	unify_with_occurs_check(Count, RetVal),

	!.

gatAtIndex(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, CurrentX, CurrentY, CurrentCount, RetVal) :-
	(
		(
			validateTurnSilent(Board, PieceType, PieceOrientation, CurrentX, CurrentY),
			NewCount is CurrentCount + 1
		);

		(
			NewCount is CurrentCount
		)

	),

	(
		(	
			CurrentX is BoardSizeX - 1,
			not(CurrentY is BoardSizeY - 1),

			NewX is 0,
			NewY is CurrentY + 1,

			cAvailableTurn(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, NewX, NewY, NewCount, RetVal)
		);

		%	End of everything...

		(	
			CurrentY is BoardSizeY - 1,
			CurrentX is BoardSizeX - 1,

			cAvailableTurn(_, _, _, _, BoardSizeY, _, BoardSizeY, NewCount, RetVal)
		);

		%	Normal case...

		(	
			not(CurrentX is BoardSizeX - 1),

			NewX is CurrentX + 1,

			cAvailableTurn(Board, PieceType, PieceOrientation, BoardSizeX, BoardSizeY, NewX, CurrentY, NewCount, RetVal)
		)
	).

getAvailableTurnAtIndex(Board, BoardSizeX, BoardSizeY, Index, RetX, RetY, RetType, RetOrientation) :-
	writeln('[Logic] Counting Available Turns...'),

	(
		cAvailableTurn(Board, 1, 'v', BoardSizeX, BoardSizeY, 0, 0, 0, Sum),
		
		(
			(
				Sum >= Index,
				
				itbAvailableTurn(Board, 1, 'v', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
				
				RetType is 1,
				
				unify_with_occurs_check(RetOrientation, 'v')
			);
			
			(
				Index > Sum,
				
				cAvailableTurn(Board, 1, 'h', BoardSizeX, BoardSizeY, 0, 0, Sum, Sum2),
				
				(
					(
						Sum2 >= Index,
						
						itbAvailableTurn(Board, 1, 'h', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
						
						RetType is 1,
						
						unify_with_occurs_check(RetOrientation, 'h')
					);
					
					(
						Index > Sum2,
						
						cAvailableTurn(Board, 2, 'v', BoardSizeX, BoardSizeY, 0, 0, Sum2, Sum3),
						
						(
							(
								Sum3 >= Index, 
								
								itbAvailableTurn(Board, 2, 'v', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
								
								RetType is 2,
								
								unify_with_occurs_check(RetOrientation, 'v')
							);
							
							(
								Index > Sum3,
								
								cAvailableTurn(Board, 2, 'h', BoardSizeX, BoardSizeY, 0, 0, Sum3, Sum4),
								
								(
									(
										Sum4 >= Index,
										
										itbAvailableTurn(Board, 2, 'h', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
										
										RetType is 2,
										
										unify_with_occurs_check(RetOrientation, 'h')
									);
									
									(
										Index > Sum4,
										
										cAvailableTurn(Board, 3, 'v', BoardSizeX, BoardSizeY, 0, 0, Sum4, Sum5),
										
										(
											(
												Sum5 >= Index,
												
												itbAvailableTurn(Board, 3, 'v', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
												
												RetType is 3,
												
												unify_with_occurs_check(RetOrientation, 'v')
											);
											
											(
												Index > Sum5,
												
												cAvailableTurn(Board, 3, 'h', BoardSizeX, BoardSizeY, 0, 0, Sum5, ReturnValue),
												
												(
													ReturnValue >= Index,
													
													itbAvailableTurn(Board, 3, 'h', BoardSizeX, BoardSizeY, 0, 0, RetX, RetY),
													
													RetType is 3,
													
													unify_with_occurs_check(RetOrientation, 'h')
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
	).

%
%	Calculate Scoring
%

%	Propagate Scoring Up

propagateScoringUp(Board, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player, NewBoard) :-
	UpPosY is CurrentPosY - 1,
	
	not(UpPosY is -1),
	
	getListObjectAtIndex(Board, UpPosY, Row),
	getListObjectAtIndex(Row, CurrentPosX, UpperObject),
	
	(
		(
			UpperObject is 0,
			
			replace(Row, CurrentPosX, Player, NewRow),
			replace(Board, UpPosY, NewRow, Board1),
			
			propagateScoringUp(Board1, BoardSizeX, BoardSizeY, CurrentPosX, UpPosY, Player, Board2),
			propagateScoringLeft(Board2, BoardSizeX, BoardSizeY, CurrentPosX, UpPosY, Player, Board3),
			propagateScoringRight(Board3, BoardSizeX, BoardSizeY, CurrentPosX, UpPosY, Player, Board4),
			
			unify_with_occurs_check(NewBoard, Board4)
		);
		
		(
			not(UpperObject is 0),
			
			unify_with_occurs_check(NewBoard, Board)
		)
	).

%	Propagate Scoring Down

propagateScoringDown(Board, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player, NewBoard) :-
	DownPosY is CurrentPosY + 1,

	not(DownPosY is BoardSizeY),

	getListObjectAtIndex(Board, DownPosY, Row),
	getListObjectAtIndex(Row, CurrentPosX, LowerObject),

	(
		(
			LowerObject is 0,
		
			replace(Row, CurrentPosX, Player, NewRow),
			replace(Board, DownPosY, NewRow, Board1),
		
			propagateScoringDown(Board1, BoardSizeX, BoardSizeY, CurrentPosX, DownPosY, Player, Board2),
			propagateScoringLeft(Board2, BoardSizeX, BoardSizeY, CurrentPosX, DownPosY, Player, Board3),
			propagateScoringRight(Board3, BoardSizeX, BoardSizeY, CurrentPosX, DownPosY, Player, Board4),
			
			unify_with_occurs_check(NewBoard, Board4)
		);
	
		(
			not(LowerObject is 0),
			
			unify_with_occurs_check(NewBoard, Board)
		)
	).

%	Propagate Scoring Left

propagateScoringLeft(Board, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player, NewBoard) :-
	LeftPosX is CurrentPosX - 1,
	
	not(LeftPosX is -1),
	
	getListObjectAtIndex(Board, CurrentPosY, Row),
	getListObjectAtIndex(Row, LeftPosX, LeftObject),
	
	(
		(
			LeftObject is 0,
			
			replace(Row, LeftPosX, Player, NewRow),
			replace(Board, CurrentPosY, NewRow, Board1),
			
			propagateScoringUp(Board1, BoardSizeX, BoardSizeY, LeftPosX, CurrentPosY, Player, Board2),
			propagateScoringDown(Board2, BoardSizeX, BoardSizeY, LeftPosX, CurrentPosY, Player, Board3),
			propagateScoringLeft(Board3, BoardSizeX, BoardSizeY, LeftPosX, CurrentPosY, Player, Board4),
			
			unify_with_occurs_check(NewBoard, Board4)
		);
		
		(
			not(LeftObject is 0),
			
			unify_with_occurs_check(NewBoard, Board)
		)
	).
	
%	Propagate Scoring Right

propagateScoringRight(Board, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player, NewBoard) :-
	RightPosX is CurrentPosX + 1,
	
	not(RightPosX is BoardSizeX),
	
	getListObjectAtIndex(Board, CurrentPosY, Row),
	getListObjectAtIndex(Row, RightPosX, RightObject),
	
	(
		(
			RightObject is 0,
			
			replace(Row, RightPosX, Player, NewRow),
			replace(Board, CurrentPosY, NewRow, Board1),
			
			propagateScoringUp(Board1, BoardSizeX, BoardSizeY, RightPosX, CurrentPosY, Player, Board2),
			propagateScoringDown(Board2, BoardSizeX, BoardSizeY, RightPosX, CurrentPosY, Player, Board3),
			propagateScoringRight(Board3, BoardSizeX, BoardSizeY, RightPosX, CurrentPosY, Player, Board4),
			
			unify_with_occurs_check(NewBoard, Board4)
		);
		
		(
			not(RightObject is 0),
			
			unify_with_occurs_check(NewBoard, Board)
		)
	).

fillBoardWithScoring(Board, BoardSizeX, BoardSizeY, BoardSizeX, CurrentPosY, Player, NewBoard) :-	%	BoardSizeX == CurrentPosX && EOB
	NewPosX is 0,
	NewPosY is CurrentPosY + 1,
	
	(
		(
			NewPosY is BoardSizeY,
			
			unify_with_occurs_check(Board, NewBoard)
		);
		
		(
			not(NewPosY is BoardSizeY),
			fillBoardWithScoring(Board, BoardSizeX, BoardSizeY, NewPosX, NewPosY, Player, NewBoard)
		)
	).

fillBoardWithScoring(Board, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player, NewBoard) :-
	getListObjectAtIndex(Board, CurrentPosY, Row),
	getListObjectAtIndex(Row, CurrentPosX, Object),
	
	Object is 0,
	
	replace(Row, CurrentPosX, Player, NewRow),
	replace(Board, CurrentPosY, NewRow, TemporaryBoard),
	
	propagateScoringUp(TemporaryBoard, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player, BoardUp),
	propagateScoringDown(BoardUp, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player, BoardDown),
	propagateScoringRight(BoardDown, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player, BoardRight),
	propagateScoringLeft(BoardRight, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player, NewBoard),
	
	!.

fillBoardWithScoring(Board, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player, NewBoard) :-
	NewPosX is CurrentPosX + 1,
	
	fillBoardWithScoring(Board, BoardSizeX, BoardSizeY, NewPosX, CurrentPosY, Player, NewBoard).

%
%	Check who's the Winner
%

checkForWinner(_, _, BoardSizeY, _, BoardSizeY, Player1Points, Player2Points, Winner) :-
	write('[Score] Player 1: '), writeln(Player1Points),
	write('[Score] Player 2: '), writeln(Player2Points),
	
	(
		(
			Player1Points > Player2Points,
			
			unify_with_occurs_check(Winner, 1)
		);
		
		(
			Player2Points > Player1Points,
			unify_with_occurs_check(Winner, 2)
		);
		
		(
			Player1Points is Player2Points,
			unify_with_occurs_check(Winner, 3)	%	3 means tie!
		)
	),
	
	!.

checkForWinner(Board, BoardSizeX, BoardSizeY, CurrentPosX, CurrentPosY, Player1Points, Player2Points, Winner) :-
	%	write('X: '), write(CurrentPosX), write(' | Y: '), writeln(CurrentPosY),
	
	getListObjectAtIndex(Board, CurrentPosY, Row),
	getListObjectAtIndex(Row, CurrentPosX, Object),
	
	NewPosX is CurrentPosX + 1,
	
	(
		(
			not(NewPosX is BoardSizeX),
			ConfirmedNewPosX is NewPosX,
			NewPosY is CurrentPosY
		);
		
		(
			NewPosX is BoardSizeX,
			ConfirmedNewPosX is 0,
			NewPosY is CurrentPosY + 1
		)
	),
	
	(
		(
			Object is 4,
			NewPlayer1Points is Player1Points + 1,
			NewPlayer2Points is Player2Points
		);
		
		(
			Object is 5,
			NewPlayer1Points is Player1Points,
			NewPlayer2Points is Player2Points + 1
		);
		
		(
			not(Object is 4),
			not(Object is 5),
			
			NewPlayer1Points is Player1Points,
			NewPlayer2Points is Player2Points
		)
	),
	
	checkForWinner(Board, BoardSizeX, BoardSizeY, ConfirmedNewPosX, NewPosY, NewPlayer1Points, NewPlayer2Points, Winner).

congratulateWinner(Board, BoardSizeX, BoardSizeY) :-
	checkForWinner(Board, BoardSizeX, BoardSizeY, 0, 0, 0, 0, Winner),
	
	(
		(
			Winner is 1,
			
			writeln('Congratulations Player 1, you won!')
		);
		
		(
			Winner is 2,
			
			writeln('Congratulations Player 2, you won!')
		);
		
		(
			Winner is 3,
			
			writeln('It\'s a tie!')
		)
	).

%
%	Game Prompts
%

promptForCoordinates(Player, PieceX, PieceY, BoardSizeX, BoardSizeY) :-
	write('Player '), write(Player), write(', please choose an X coordinate: '),
	readInteger(PieceX),
	
	PieceX >= 0,
	BoardSizeX >= PieceX,
	
	write('Player '), write(Player), write(', please choose an Y coordinate: '),
	readInteger(PieceY),
	
	PieceY >= 0,
	BoardSizeY >= PieceY,
	
	!.

promptForCoordinates(Player, PieceX, PieceY, BoardSizeX, BoardSizeY) :-
	write('Invalid coordinates! Please try again.'),
	promptForCoordinates(Player, PieceX, PieceY, BoardSizeX, BoardSizeY).

promptForPlay(Board, BoardSizeX, BoardSizeY, PlayCount, Player, NewBoard) :-
	write('Player '), write(Player), write(', please choose a piece type (1/2/3): '),
	readPieceType(PieceType),
	
	write('Player '), write(Player), write(', please choose an orientation ([v]ertical/[h]orizontal): '),
	readPieceOrientation(PieceOrientation),
	
	promptForCoordinates(Player, PieceX, PieceY, BoardSizeX, BoardSizeY),
	
	(
		(
			PlayCount is 0,
			validateFirstTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard)
		);
		
		(
			not(PlayCount is 0),
			validateTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard)
		)
	),
	
	!.

promptForPlay(Board, BoardSizeX, BoardSizeY, PlayCount, Player, NewBoard) :-
	writeln('You messed up. Try again! :)'),
	
	promptForPlay(Board, BoardSizeX, BoardSizeY, PlayCount, Player, NewBoard).

playComputerino(Board, Difficulty, BoardSizeX, BoardSizeY, PlayCount, _, NewBoard) :-
	(
		PlayCount is 0,
		
		validateFirstTurn(Board, 1, 'h', 0, 0, NewBoard)
	);
	
	(
		not(PlayCount is 0),
		
		(
			(
				Difficulty is 1,
				
				getAnAvailableTurn(Board, BoardSizeX, BoardSizeY, RetX, RetY, RetType, RetOrientation),
				
				validateTurn(Board, RetType, RetOrientation, RetX, RetY, NewBoard)
			);
			
			(
				Difficulty is 2,
				
				countAvailableTurns(Board, BoardSizeX, BoardSizeY, ATCount),
				
				Max is ATCount + 1,
				
				random(1, Max, OutputNumber),
				
				getAvailableTurnAtIndex(Board, BoardSizeX, BoardSizeY, OutputNumber, RetX, RetY, RetType, RetOrientation),
				
				validateTurn(Board, RetType, RetOrientation, RetX, RetY, NewBoard)
			)
		)
	).
	
promptForBoardSize(BoardSizeX, BoardSizeY) :-
	write('Please choose a width value (5-20): '),
	readInteger(BoardSizeX),

	BoardSizeX >= 5,
	20 >= BoardSizeX,

	write('Please choose a height value (5-20): '),
	readInteger(BoardSizeY),
	
	BoardSizeY >= 5,
	20 >= BoardSizeY,

	!.

promptForBoardSize(BoardSizeX, BoardSizeY) :-
	writeln('Unexpected values. Please retry.'),
	
	promptForBoardSize(BoardSizeX, BoardSizeY).

promptForBoardSize(BoardSizeX, BoardSizeY) :-
	write('Invalid size! Please try again.'),
	promptForCoordinates(BoardSizeX, BoardSizeY).

promptForComputerDifficulty(Difficulty) :-
	write('Please choose the AI difficulty (1-2): '),
	readInteger(Difficulty),
	
	(
		Difficulty is 1;
		Difficulty is 2
	),
	
	!.

promptForComputerDifficulty(Difficulty) :-
	writeln('Invalid choice. Please try again.'),
	
	promptForComputerDifficulty(Difficulty).

startGamePlayerVsPlayer :-
	nl, writeln('Welcome to Le Bloq, Prolog Edition!'), nl,
	
	writeln('Running in Player vs Player mode.'), nl,
	
	promptForBoardSize(SizeX, SizeY),
	
	createBoard(SizeX, SizeY, X),
	
	runMainLoop(X, SizeX, SizeY, 0, 1, 2).

startGamePlayerVsComputer :-
	nl, writeln('Welcome to Le Bloq, Prolog Edition!'), nl,
	
	writeln('Running in Player vs AI mode.'), nl,
	
	promptForBoardSize(SizeX, SizeY),
	
	promptForComputerDifficulty(Difficulty),
	
	createBoard(SizeX, SizeY, X),
	
	runMainLoopPlayerVsAI(X, Difficulty, SizeX, SizeY, 0, 1, 2).
	
startGameComputerVsComputer :-
	nl, writeln('Welcome to Le Bloq, Prolog Edition!'), nl,
	
	writeln('Running in AI vs AI mode.'), nl,
	
	promptForBoardSize(SizeX, SizeY),
	
	createBoard(SizeX, SizeY, X),
	
	runMainLoopAIvsAI(X, SizeX, SizeY, 0, 1, 2).

startGame :-
	startGamePlayerVsPlayer.	
