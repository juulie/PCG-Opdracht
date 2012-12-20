/* Game Stats */
quest('Kill The General', kill, 10, 100, [general]).

npc(general,	bunker).
npc(rebel,		hideout).
npc(exMilitary, bar).
npc(secondInCommand, compound).

questGiver(rebel, 'Kill The General').

/*Knowledge Tree*/
knownNPCs(player, 		[rebel, exMilitary]).
knownNPCs(exMilitary, 	[secondInCommand]).
knownNPCs(rebel,		[]).
knownNPCs(secondInCommand, 	[general]).

/* Do new Quest, be done when we reach xp of 10 */
doNewQuest(player(_, XP, _, _, _)) :-
	XP =:= 10.

doNewQuest(player(Location, XP, Health, Gold, Inventory)) :-
	npc(Name, Location),
	QGiver = questGiver(Name, QuestName),
	quest(QuestName, QuestType, XPGain, GoldReward, List),
	Quest =.. [QuestType| [QGiver, player(Location, XP, Health, Gold, Inventory), XPGain, GoldReward, List]],
	call(Quest).
	

/* Kill Quest */
kill(questGiver(QGiverName, QuestName), player(QGiverLocation, XP, Health, Gold, Inventory), XPGain, GoldReward, [TargetName]) :- 
	writef('%w%w%w%w%w%w%w%w%w', ['Accepted a kill quest named: ', QuestName, ', Going to kill ', TargetName, ' for ', Gold, ' gold and ', XPGain, ' XP gain.']),nl,
	findPerson([player], TargetName),nl,
	npc(TargetName, TargetLocation),
	goTo(QGiverLocation, TargetLocation),
	kill(TargetName),
	goTo(TargetLocation, QGiverLocation),
	collectReward(QGiverName),
	doNewQuest(player(QGiverLocation, XP + XPGain, Health, Gold + GoldReward, Inventory)).
	
findPerson([Informant|_], Person) :-
	knownNPCs(Informant, List),
	listContainsItem(List, Person),
	writef('%w%w%w', [Informant, ' knows whereabouts of ', Person]),nl,
	(Informant \== player ->
		writef('%w%w', ['We know ', Informant]);true).

findPerson([Informant|Others], Person) :-
	knownNPCs(Informant, List),
	append(Others, List, NewList),
	findPerson(NewList, Person),
	(Informant \== player ->
		writef('%w%w', [' via ', Informant]),nl,
		writef('%w%w', ['We know ', Informant]); true).
	
	
	
goTo(P1, P2) :-
	writef('%w%w%w%w', ['Going from ', P1, ' to ',  P2]),nl.

spy(Name) :-
	writef('%w%w', ['Spying on ',  Name]),nl.
 
kill(Name) :-
 	writef('%w%w', ['Killed the ',  Name]),nl.
	
collectReward(Name) :-
  	writef('%w%w', ['Collect reward from ',  Name]),nl.
	

/* Some handy methods */

listContainsItem([Item|_], Item).

listContainsItem([_|Tail], Item) :-
	listContainsItem(Tail, Item).

 
 start :- doNewQuest(player(hideout, 0, 100, 0, [])).