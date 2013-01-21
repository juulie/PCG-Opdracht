/* Game Stats */

/* Quests */
/* Quests are dynamic, that is, that they are removed from the database after they are completed*/
:- dynamic quest/5.

quest('Spy on the General', rebel, spy, [10, 100, [gun]], [general]).
quest('Kill the General', rebel, kill, [10, 100, []], [general]).
quest('Kill the Military', rebel, kill, [10, 100, []], [exMilitary]).
quest('Protect crops', farmer, protect, [7, 150, []], [plague]).
quest('Escort crops delivery', farmer, escort, [15, 200, []], [crops, town]).
quest('Deliver package', salesman, deliver, [8, 40, []], [healthPotion, oldMan]).
quest('Escort rich guy', richGuy, escort, [15, 200, []], [richGuy, city]).
quest('Deliver rich guy\'s package ', richGuy, deliver, [15, 200, []], [package, farmer]).

/* Locations and their neighbors*/
location(town, [forest, city, river]).
location(city, [hideout, town]).
location(forest, [town, bunker]).
location(bunker, [forest]).
location(hideout, [city]).
location(river, [town, city]).

/* NPC's and their location, these are also dynamic, as NPC's can get killed*/
:- dynamic npc/2.
npc(general,	bunker).
npc(rebel,		hideout).
npc(exMilitary, town).
npc(farmer,		forest).
npc(salesman,	town).
npc(oldMan,		town).
npc(oldLady,	town).
npc(richGuy,	town).
npc(corporal,	bunker).

/* Knowledge Tree, dynamic because this information changes overtime */
:- dynamic knownNPCs/2.
knownNPCs(player, 		[oldMan, rebel, exMilitary]).
knownNPCs(exMilitary, 	[corporal]).
knownNPCs(corporal, 	[general]).
knownNPCs(rebel,		[]).
knownNPCs(richGuy,		[salesman, farmer]).
knownNPCs(salesman,		[oldMan, farmer, richGuy]).
knownNPCs(oldMan,		[oldLady, farmer]).
knownNPCs(oldLady,		[]).
knownNPCs(farmer,		[]).

play:-
	b_getval(playerXp,			XP),
	XP >= 75,
	writef('%w%w%w', ['Achieved xp of: ', XP, '. We\'re done!']),nl.
	
play:-
	b_getval(playerLocation, Location),
	npc(NPCName, Location),
	quest(QuestName, NPCName, QuestType, [XPGain, GoldReward, ItemRewardList],  List),
	QuestCall =.. [QuestType, QuestName, NPCName, XPGain, GoldReward, ItemRewardList,  List],
	call(QuestCall),
	nl,
	retract(quest(QuestName, NPCName, QuestType, [XPGain, GoldReward, ItemRewardList],  List)),
	play.

play:-
	b_getval(playerLocation, Location),
	closestQuest([Location], QuestName),
	quest(QuestName, NPCName, _, _, _),
	npc(NPCName, NPCLocation),
	goTo(NPCLocation),nl,
	play.
	
	

/* Quests */
kill(QuestName, QGiverName, XPGain, GoldReward, ItemRewardList, [TargetName]) :- 
	writef('%w%w%w%w%w%w%w%w%w%w%w%w', ['Accepted a kill quest named: ', QuestName, ' from ', QGiverName,'. Going to kill ', TargetName, ' for ', GoldReward, ' gold, ', XPGain, ' XP gain and these items:', ItemRewardList]),nl,
	findPerson(TargetName),
	npc(TargetName, TargetLocation),
	b_getval(playerLocation, Location),
	goTo(TargetLocation),
	kill(TargetName),
	goTo(Location),
	collectReward(QGiverName, XPGain, GoldReward, ItemRewardList).
	
spy(QuestName, QGiverName, XPGain, GoldReward, ItemRewardList, [TargetName]) :-
	writef('%w%w%w%w%w%w%w%w%w%w%w%w', ['Accepted a spy quest named: ', QuestName, ' from ', QGiverName,'. Going to spy on ', TargetName, ' for ', GoldReward, ' gold, ', XPGain, ' XP gain and these items:', ItemRewardList]),nl,
	findPerson(TargetName),
	npc(TargetName, TargetLocation),
	b_getval(playerLocation, Location),
	goTo(TargetLocation),
	spyOn(TargetName),
	goTo(Location),
	collectReward(QGiverName, XPGain, GoldReward, ItemRewardList).

protect(QuestName, QGiverName, XPGain, GoldReward, ItemRewardList, [Danger]) :-
	writef('%w%w%w%w%w%w%w%w%w%w%w%w', ['Accepted a protect quest named: ', QuestName, ' from ', QGiverName,'. Have to protect him from ', Danger, '. We do this for ', GoldReward, ' gold, ', XPGain, ' XP gain and these items:', ItemRewardList]),nl,
	protect(QGiverName, Danger),
	collectReward(QGiverName, XPGain, GoldReward, ItemRewardList).

escort(QuestName, QGiverName, XPGain, GoldReward, ItemRewardList, [Escortee, Destination]) :-
	npc(Escortee, EscorteeLocation),
	writef('%w%w%w%w%w%w%w%w%w%w%w%w%w%w', ['Accepted an escort quest named: ', QuestName, ' from ', QGiverName,'. Going to escort ', Escortee, ' to ', Destination, ' for ', GoldReward, ' gold, ', XPGain, ' XP gain and these items:', ItemRewardList]),nl,
	goTo(Destination),
	retract(npc(Escortee, EscorteeLocation)),
	asserta(npc(Escortee, Destination)),
	collectReward(QGiverName, XPGain, GoldReward, ItemRewardList).
	
escort(QuestName, QGiverName, XPGain, GoldReward, ItemRewardList, [Escortee, Destination]) :-
	writef('%w%w%w%w%w%w%w%w%w%w%w%w%w%w', ['Accepted an escort quest named: ', QuestName, ' from ', QGiverName,'. Going to escort ', Escortee, ' to ', Destination, ' for ', GoldReward, ' gold, ', XPGain, ' XP gain and these items:', ItemRewardList]),nl,
	goTo(Destination),
	collectReward(QGiverName, XPGain, GoldReward, ItemRewardList).
	
deliver(QuestName, QGiverName, XPGain, GoldReward, ItemRewardList, [Package, Receiver]) :-
	writef('%w%w%w%w%w%w%w%w%w%w%w%w%w%w', ['Accepted a delivery quest named: ', QuestName, ' from ', QGiverName,'. Going to deliver ', Package, ' to ', Receiver, ' for ', GoldReward, ' gold, ', XPGain, ' XP gain and these items:', ItemRewardList]),nl,
	npc(Receiver, ReceiverLocation),
	goTo(ReceiverLocation),
	collectReward(QGiverName, XPGain, GoldReward, ItemRewardList).
	
/* Consult tree's, these do a breath first search in a specific tree */
/*findPerson([Informant|_], Person) :-
	knownNPCs(Informant, List),
	member(Person, List),
	writef('%w%w%w', [Informant, ' knows whereabouts of ', Person]),
	(Informant \== player ->
		nl,writef('%w%w', ['We know ', Informant]);true).

findPerson([Informant|Others], Person) :-
	knownNPCs(Informant, List),
	append(Others, List, NewList),
	list_to_set(NewList, Set),
	findPerson([Connection|Set], Person),
	(Informant \== player ->
		writef('%w%w', [' via ', Connection]),nl,
		writef('%w%w', ['We know ', Connection]); true).*/
		
findPerson(Person, Path, Length) :-
	Person == player,
	Length is 0,
	Path = [].
		
findPerson(Person, Path, Length) :-
	knownNPCs(Informant, List),
	member(Person, List),
	!,
	findPerson(Informant, NewPath, NewLength),
	Length is NewLength + 1,
	Path = [Person | NewPath].

findPerson(Person) :-
	findall([Path, Length], findPerson(Person, Path, Length), PathList),
	predsort(pathComparison, PathList, [[ReversedShortestPath | _]|_]),
	reverse(ReversedShortestPath, ShortestPath),
	writePathToPerson(ShortestPath),
	retract(knownNPCs(player, KnowledgeList)),
	append(KnowledgeList, ReversedShortestPath, NewKnowledgeList),
	list_to_set(NewKnowledgeList, Set),
	asserta(knownNPCs(player, Set)).
	

writePathToPerson([_]).

writePathToPerson([Current, Next|Rest]) :-
	(Current \== player ->
		writef('%w%w%w%w', ['We know ', Next, ' via ', Current]),nl;
		writef('%w%w', ['We know ', Next]),nl),
	writePathToPerson([Next|Rest]).


pathComparison(Delta, [_, Length1], [_, Length2]) :-
	compare(Delta, Length1, Length2).
		
closestQuest([FromLocation|_], QuestName) :-
	npc(NPCName, FromLocation),
	quest(QuestName, NPCName, _, _, _).
	
closestQuest([FromLocation|Others], QuestName) :-
	location(FromLocation, NeighborList),
	append(Others, NeighborList, NewList),
	list_to_set(NewList, Set),
	closestQuest(Set, QuestName).
	
/* Actions */	
goTo(P2) :-
	writef('%w%w', ['Going to ', P2]),nl,
	b_getval(playerXp, XP),
	random_between(0, XP, RandomValue),
	(RandomValue >= 40 ->
		writef('Encountered enemies on the road'),nl;true),
	b_setval(playerLocation, 	P2).

spyOn(Name) :-
	writef('%w%w', ['Spying on ',  Name]),nl.
 
kill(Name) :-
 	writef('%w%w', ['Killed the ',  Name]),nl,
	retract(npc(Name, _)).
	
protect(Name, Danger) :-
 	writef('%w%w%w%w', ['Protecting ',  Name, ' from ', Danger]),nl.
	
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

setDefaultPlayer :-
	writef('We start at town'),nl,
	b_setval(playerLocation, 			town),
	b_setval(playerHp,					100),
	b_setval(playerXp, 					0),
	b_setval(playerGold,				0),
	b_setval(playerInventory, 			[]),
	b_setval(playerCompletedQuests, 	[]). 

start :- 
	setDefaultPlayer,
	play,
	abolish(knownNPCs/2),
	abolish(quest/5).
	