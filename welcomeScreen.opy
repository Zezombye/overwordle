#!mainFile "main.opy"

playervar welcomeScreenHold

#!define sortedPlayersByScore() (sorted(getAllPlayers(), lambda x: -x.displayedScore))

rule "display tutorial & end of round hud":

    #hudSubtext(localPlayer if gameStatus == GameStatus.DISPLAY_SCORES and localPlayer.hasPassedWelcomeScreen else [], " \n\n\n\n\n\n\n\n", HudPosition.TOP, -750, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    /*hudHeader(localPlayer if gameStatus == GameStatus.DISPLAY_SCORES and localPlayer.hasPassedWelcomeScreen else [], "Final Rankings" if currentRound >= nbRounds-1 else "Rankings so far", HudPosition.TOP, -740, rgb(
        128 + 127 * cosDeg(getTotalTimeElapsed() * 100),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 120),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 240)
    ) if currentRound >= nbRounds-1 else Color.SKY_BLUE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)*/
    #hudSubtext(localPlayer if gameStatus == GameStatus.DISPLAY_SCORES and localPlayer.hasPassedWelcomeScreen else [], " \n", HudPosition.TOP, -730, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)

    /*for i in range(12):        
        hudSubtext(localPlayer if gameStatus == GameStatus.DISPLAY_SCORES and localPlayer.hasPassedWelcomeScreen and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore), HudPosition.TOP, evalOnce(i)-500, Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)*/


    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES else null, " \n\n\n" if not localPlayer.hasPassedWelcomeScreen else " \n\n\n\n\n\n\n\n", HudPosition.TOP, -100.5 if not localPlayer.hasPassedWelcomeScreen else -750, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    hudHeader(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES else null, "Welcome to OverWordle!" if not localPlayer.hasPassedWelcomeScreen else "Final Rankings" if currentRound >= nbRounds-1 else "Rankings so far", HudPosition.TOP, -100 if not localPlayer.hasPassedWelcomeScreen else -740, Color.PURPLE if not localPlayer.hasPassedWelcomeScreen else rgb(
        128 + 127 * cosDeg(getTotalTimeElapsed() * 100),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 120),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 240)
    ) if currentRound >= nbRounds-1 else Color.SKY_BLUE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES else null, " \n\n" if not localPlayer.hasPassedWelcomeScreen else " \n", HudPosition.TOP, -99.5 if not localPlayer.hasPassedWelcomeScreen else -730, Color.RED, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    i = 0
    hudText(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, "You must guess the wordle in {} tries.\nEach guess must be a valid {} letter word.\nHit the enter button to submit.".format(maxGuesses, nbLetters) if not localPlayer.hasPassedWelcomeScreen else "", null, "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore) if localPlayer.hasPassedWelcomeScreen else "", HudPosition.TOP, -99 if not localPlayer.hasPassedWelcomeScreen else evalOnce(i)-500, Color.WHITE, null, Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    i = 1
    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, " \n\n" if not localPlayer.hasPassedWelcomeScreen else "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore), HudPosition.TOP, -98.5 if not localPlayer.hasPassedWelcomeScreen else evalOnce(i)-500, Color.RED if not localPlayer.hasPassedWelcomeScreen else Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    i = 2
    hudText(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, "The color of the tiles indicate how close your guess is:" if not localPlayer.hasPassedWelcomeScreen else "", null, "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore) if localPlayer.hasPassedWelcomeScreen else "", HudPosition.TOP, -98 if not localPlayer.hasPassedWelcomeScreen else evalOnce(i)-500, Color.ORANGE, null, Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    i = 3
    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, " " if not localPlayer.hasPassedWelcomeScreen else "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore), HudPosition.TOP, -97.5 if not localPlayer.hasPassedWelcomeScreen else evalOnce(i)-500, Color.RED if not localPlayer.hasPassedWelcomeScreen else Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)
    
    i = 4
    hudText(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, "› green ‹ means the letter is in the word at the right place." if not localPlayer.hasPassedWelcomeScreen else "", null, "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore) if localPlayer.hasPassedWelcomeScreen else "", HudPosition.TOP, -97 if not localPlayer.hasPassedWelcomeScreen else evalOnce(i)-500, Color.KB_GREEN, null, Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    i = 5
    hudText(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, "› yellow ‹ means the letter is in the word but at the wrong place." if not localPlayer.hasPassedWelcomeScreen else "", null, "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore) if localPlayer.hasPassedWelcomeScreen else "", HudPosition.TOP, -96 if not localPlayer.hasPassedWelcomeScreen else evalOnce(i)-500, Color.KB_YELLOW, null, Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    i = 6
    hudText(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, "› gray ‹ means the letter is not in the word." if not localPlayer.hasPassedWelcomeScreen else "", null, "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore) if localPlayer.hasPassedWelcomeScreen else "", HudPosition.TOP, -95 if not localPlayer.hasPassedWelcomeScreen else evalOnce(i)-500, Color.GRAY, null, Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    i = 7
    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, " \n\n" if not localPlayer.hasPassedWelcomeScreen else "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore), HudPosition.TOP, -94.5 if not localPlayer.hasPassedWelcomeScreen else evalOnce(i)-500, Color.RED if not localPlayer.hasPassedWelcomeScreen else Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    i = 8
    hudText(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, "The word is the same for everyone each round. Good luck!" if not localPlayer.hasPassedWelcomeScreen else "", null, "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore) if localPlayer.hasPassedWelcomeScreen else "", HudPosition.TOP, -94 if not localPlayer.hasPassedWelcomeScreen else evalOnce(i)-500, Color.BLUE, null, Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    i = 9
    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen or gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, " \n\n" if not localPlayer.hasPassedWelcomeScreen else "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore), HudPosition.TOP, -93.5 if not localPlayer.hasPassedWelcomeScreen else evalOnce(i)-500, Color.RED if not localPlayer.hasPassedWelcomeScreen else Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.NEVER)

    progressBarHud(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, localPlayer.welcomeScreenHold*100, "Hold {} to join the game".format("[{}]".format(buttonString(Button.JUMP)) if strContains("ABCDEFGHIJKLMNOPQRSTUVWXYZ", buttonString(Button.JUMP).charAt(0)) else buttonString(Button.JUMP)), HudPosition.TOP, -93, Color.ORANGE, Color.ORANGE, ProgressHudReeval.VISIBILITY_AND_VALUES, SpecVisibility.NEVER)

    i = 10
    hudSubtext(localPlayer if gameStatus == GameStatus.DISPLAY_SCORES and localPlayer.hasPassedWelcomeScreen and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore), HudPosition.TOP, evalOnce(i)-500, Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)

    i = 11
    hudSubtext(localPlayer if gameStatus == GameStatus.DISPLAY_SCORES and localPlayer.hasPassedWelcomeScreen and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore), HudPosition.TOP, evalOnce(i)-500, Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    


rule "tutorial camera":
    @Event eachPlayer
    @Condition not eventPlayer.hasPassedWelcomeScreen
    eventPlayer.startCamera(vect(0, 500, 0), vect(0, 600, 0), 0)
    eventPlayer.disableHeroHUD()

rule "hold to skip tutorial":
    @Event eachPlayer
    @Condition not eventPlayer.hasPassedWelcomeScreen
    @Condition eventPlayer.isHoldingButton(Button.JUMP)
    chase(eventPlayer.welcomeScreenHold, 9999, rate=1, ChaseReeval.NONE)

rule "don't hold anymore to skip tutorial":
    @Event eachPlayer
    @Condition not eventPlayer.hasPassedWelcomeScreen
    @Condition not eventPlayer.isHoldingButton(Button.JUMP)
    stopChasingVariable(eventPlayer.welcomeScreenHold)
    eventPlayer.welcomeScreenHold = 0

rule "skip tutorial":
    @Event eachPlayer
    @Condition eventPlayer.welcomeScreenHold >= 1
    stopChasingVariable(eventPlayer.welcomeScreenHold)
    eventPlayer.hasPassedWelcomeScreen = true
    eventPlayer.stopCamera()
    eventPlayer.enableHeroHud()
