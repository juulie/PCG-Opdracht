/* Game Stats */
quest('Kill The General', rebel, kill, 10, 100, [], [general]).

npc(general,	bunker).
npc(rebel,		hideout).
npc(exMilitary, town).

/*Knowledge Tree*/
knownNPCs(player, 		[rebel, exMilitary]).
knownNPCs(exMilitary, 	[general]).
knownNPCs(rebel,		[]).

play:-
	b_getval(playerXp,			XP),
	XP =:= 10,
	writef('%w%w%w%w%w%w%w%w%w', ['Achieved xp of: ', XP, '. We\'re done!']),nl.
	
play:-
	b_getval(playerLocation, Location),
	npc(NPCName, Location),
	quest(QuestName, NPCName, QuestType, XPGain, GoldReward, ItemRewardList,  List),
	Quest =.. [QuestType, QuestName, NPCName, XPGain, GoldReward, ItemRewardList,  List],
	call(Quest),
	play.

play:-
	b_getval(playerLocation, Location),
	goTo(OtherLocation),
	play.
	
	

/* Kill Quest */
kill(QuestName, QGiverName, XPGain, GoldReward, ItemRewardList, [TargetName]) :- 
	writef('%w%w%w%w%w%w%w%w%w%w', ['Accepted a kill quest named: ', QuestName, ', Going to kill ', TargetName, ' for ', GoldReward, ' gold, ', XPGain, ' XP gain and these items:', ItemRewardList]),nl,
	findPerson([player], TargetName),nl,
	npc(TargetName, TargetLocation),
	b_getval(playerLocation, Location),
	goTo(TargetLocation),
	kill(TargetName),
	goTo(Location),
	collectReward(QGiverName, XPGain, GoldReward, ItemRewardList).
	
	
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
	
	
goTo(P2) :-
	writef('%w%w', ['Going to ', P2]),nl,
	b_setval(playerLocation, 	P2).

spy(Name) :-
	writef('%w%w', ['Spying on ',  Name]),nl.
 
kill(Name) :-
 	writef('%w%w', ['Killed the ',  Name]),nl.
	
collectReward(Name, XPGain, GoldReward, ItemRewardList) :-
  	writef('%w%w', ['Collect reward from ',  Name]),nl,
	b_getval(playerXp,			XP),
	b_getval(playerGold,		Gold),
	b_getval(playerInventory, 	InventoryList),
	b_setval(playerXp, 			XP + XPGain),
	b_setval(playerGold,		Gold + GoldReward),
	append(ItemRewardList, InventoryList, TotalList),
	b_setval(playerInventory, 	TotalList).
	

/* Some handy methods */

listContainsItem([Item|_], Item).

listContainsItem([_|Tail], Item) :-
	listContainsItem(Tail, Item).

 
start :- 
	b_setval(playerLocation, 	town),
	b_setval(playerHp,			100),
	b_setval(playerXp, 			0),
	b_setval(playerGold,		0),
	b_setval(playerInventory, 	[sword]),
 	play.