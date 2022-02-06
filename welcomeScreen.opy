#!mainFile "main.opy"

playervar welcomeScreenHold

rule "display tutorial":
    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, " \n\n\n", HudPosition.TOP, -100.5, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, "Welcome to OverWordle!", HudPosition.TOP, -100, Color.PURPLE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, " \n\n", HudPosition.TOP, -99.5, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, "You must guess the wordle in {} tries.\nEach guess must be a valid {} letter word.\nHit the enter button to submit.".format(maxGuesses, nbLetters), HudPosition.TOP, -99, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, " \n\n", HudPosition.TOP, -98.5, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, "The color of the tiles indicate how close your guess is:", HudPosition.TOP, -98, Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, " ", HudPosition.TOP, -97.5, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, "› green ‹ means the letter is in the word at the right place.", HudPosition.TOP, -97, Color.KB_GREEN, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, "› yellow ‹ means the letter is in the word but at the wrong place.", HudPosition.TOP, -96, Color.KB_YELLOW, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, "› gray ‹ means the letter is not in the word.", HudPosition.TOP, -95, Color.GRAY, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, " \n\n", HudPosition.TOP, -94.5, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, "The word is the same for everyone each round. Good luck!", HudPosition.TOP, -94, Color.BLUE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, " \n\n", HudPosition.TOP, -93.5, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    progressBarHud(localPlayer if not localPlayer.hasPassedWelcomeScreen else null, localPlayer.welcomeScreenHold*100, "Hold {} to join the game".format("[{}]".format(buttonString(Button.JUMP)) if strContains("ABCDEFGHIJKLMNOPQRSTUVWXYZ", buttonString(Button.JUMP).charAt(0)) else buttonString(Button.JUMP)), HudPosition.TOP, -93, Color.ORANGE, Color.ORANGE, ProgressHudReeval.VISIBILITY_AND_VALUES, SpecVisibility.DEFAULT)

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
