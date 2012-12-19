/* Game Stats */
quest('Kill The General', kill, 10, 100, [general]).

npc(general,	bunker).
npc(rebel,		hideout).

questGiver(rebel, 'Kill The General').

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
	npc(TargetName, TargetPosition),
	goTo(QGiverLocation, TargetPosition),
	kill(TargetName),
	goTo(TargetPosition, QGiverLocation),
	collectReward(QGiverName),
	doNewQuest(player(QGiverLocation, XP + XPGain, Health, Gold + GoldReward, Inventory)).
	
goTo(P1, P2) :-
	writef('%w%w%w%w', ['Going from ', P1, ' to ',  P2]),nl.

spy(Name) :-
	writef('%w%w', ['Spying on ',  Name]),nl.
 
kill(Name) :-
 	writef('%w%w', ['Killed the ',  Name]),nl.
	
collectReward(Name) :-
  	writef('%w%w', ['Collect reward from ',  Name]),nl.
 
 start :- doNewQuest(player(hideout, 0, 100, 0, [])).