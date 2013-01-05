/* Game Stats */

/* Quests */
quest('Kill The General', rebel, kill, 10, 100, [], [general]).
quest('Kill The Military', rebel, kill, 10, 100, [], [exMilitary]).


/* Locations */
location(town, [forest, city, river]).
location(city, [hideout, town]).
location(forest, [town, bunker]).
location(bunker, [forest]).
location(hideout, [city]).
location(river, [town, city]).

/* NPC's */
npc(general,	bunker).
npc(rebel,		hideout).
npc(exMilitary, town).

/* Knowledge Tree */
knownNPCs(player, 		[rebel, exMilitary]).
knownNPCs(exMilitary, 	[general]).
knownNPCs(rebel,		[]).

play:-
	b_getval(playerXp,			XP),
	XP =:= 20,
	writef('%w%w%w', ['Achieved xp of: ', XP, '. We\'re done!']),nl.
	
play:-
	b_getval(playerLocation, Location),
	npc(NPCName, Location),
	b_getval(playerCompletedQuests, CompletedQuests),
	quest(QuestName, NPCName, QuestType, XPGain, GoldReward, ItemRewardList,  List),
	\+ member(QuestName, CompletedQuests),
	Quest =.. [QuestType, QuestName, NPCName, XPGain, GoldReward, ItemRewardList,  List],
	call(Quest),
	append(CompletedQuests, QuestName, NewQuestList),
	b_setval(playerCompletedQuests, NewQuestList),
	play.

play:-
	b_getval(playerLocation, Location),
	closestQuest([Location], QuestName),
	quest(QuestName, NPCName, _, _, _, _,  _),
	npc(NPCName, NPCLocation),
	goTo(NPCLocation),
	play.
	
	

/* Quests */
kill(QuestName, QGiverName, XPGain, GoldReward, ItemRewardList, [TargetName]) :- 
	writef('%w%w%w%w%w%w%w%w%w%w', ['Accepted a kill quest named: ', QuestName, ', Going to kill ', TargetName, ' for ', GoldReward, ' gold, ', XPGain, ' XP gain and these items:', ItemRewardList]),nl,
	findPerson([player], TargetName),nl,
	npc(TargetName, TargetLocation),
	b_getval(playerLocation, Location),
	goTo(TargetLocation),
	kill(TargetName),
	goTo(Location),
	collectReward(QGiverName, XPGain, GoldReward, ItemRewardList).
	
/* Consult tree's */
findPerson([Informant|_], Person) :-
	knownNPCs(Informant, List),
	member(Person, List),
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
		
closestQuest([FromLocation|_], QuestName) :-
	npc(NPCName, FromLocation),
	quest(QuestName, NPCName, _, _, _, _,  _),
	b_getval(playerCompletedQuests, CompletedQuests),
	\+ member(QuestName, CompletedQuests).
	
closestQuest([FromLocation|Others], QuestName) :-
	location(FromLocation, NeighborList),
	append(Others, NeighborList, NewList),
	list_to_set(NewList, Set),
	closestQuest(Set, QuestName).
	
/* Actions */	
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
	NewXP is XP + XPGain,
	b_setval(playerXp, 			NewXP),
	NewGold is Gold + GoldReward,
	b_setval(playerGold,		NewGold),
	append(ItemRewardList, InventoryList, TotalList),
	b_setval(playerInventory, 	TotalList).
	

/* Some handy methods */
isNotMember(List, Item) :- 
	member(Item, List), !, fail.
	
isNotMember(List, Item).

 
start :- 
	b_setval(playerLocation, 			town),
	b_setval(playerHp,					100),
	b_setval(playerXp, 					0),
	b_setval(playerGold,				0),
	b_setval(playerInventory, 			[sword]),
	b_setval(playerCompletedQuests, 	[]),
	play.
	