
globalvar wordToGuess = w"AAAAA"

globalvar maxGuesses = 6
globalvar nbLetters = 5

enum Color:
    WORDLE_GREEN = rgba(0, 80, 0, 200),
    WORDLE_YELLOW = rgba(100, 100, 0, 200),
    WORDLE_GRAY = rgba(20, 20, 20, 200),
    WORDLE_OUTLINE_EMPTY = rgba(100, 100, 100, 100),
    WORDLE_OUTLINE = rgba(100, 100, 100, 200),
    WORDLE_OUTLINE_LAST = rgba(100, 0, 0, 200),
    WORDLE_BLACK = rgba(0, 0, 0, 200),
    KB_GREEN = Color.GREEN,
    KB_YELLOW = rgb(200, 200, 0),
    KB_WHITE = Color.WHITE,
    KB_GRAY = rgb(50, 50, 50),
    KB_SELECTION = Color.BLUE,


#!define VERSION "1.0"
#!define CODE "FX999"

#!define LETTER_A 0
#!define LETTER_B 1
#!define LETTER_C 2
#!define LETTER_D 3
#!define LETTER_E 4
#!define LETTER_F 5
#!define LETTER_G 6
#!define LETTER_H 7
#!define LETTER_I 8
#!define LETTER_J 9
#!define LETTER_K 10
#!define LETTER_L 11
#!define LETTER_M 12
#!define LETTER_N 13
#!define LETTER_O 14
#!define LETTER_P 15
#!define LETTER_Q 16
#!define LETTER_R 17
#!define LETTER_S 18
#!define LETTER_T 19
#!define LETTER_U 20
#!define LETTER_V 21
#!define LETTER_W 22
#!define LETTER_X 23
#!define LETTER_Y 24
#!define LETTER_Z 25

playervar guesses = [
    /*w"ABCDEFGHI",
    w"ABCDEFGHI",
    w"ABCDEFGHI",*/
]

globalvar vibrationSpaces = [
    "",
    " ",
    " ",
    " ",
    " ",
    "  ",
    "  ",
    "  ",
    "  ",
    "   ",
    "   ",
]
globalvar vibrationLetterSpaces = [
    "",
    "  ",
    "  ",
    "  ",
    "  ",
    "    ",
    "    ",
    "    ",
    "    ",
    "      ",
    "      ",
]
globalvar i
playervar vibrationLeft = 0
playervar vibrationRight = 0

playervar errorMsg

enum GuessResult:
    BAD = 1,
    WRONG_PLACE,
    GOOD

playervar guessResults = []
playervar hasGuessedWord = false
playervar displayedScore

playervar currentGuess = ""
playervar i
playervar hasPassedWelcomeScreen = false
playervar mercyRegenChase = 0

globalvar currentRound = 0
globalvar nbRounds = 5
globalvar roundDuration = 30

enum GameStatus:
    WAITING_FOR_PLAYERS,
    ROUND_IN_PROGRESS,
    ROUND_ENDED,
    DISPLAY_SCORES,

globalvar gameStatus

#!include "keyboard.opy"
#!include "words.opy"
#!include "settings.opy"
#!include "welcomeScreen.opy"

#!suppressWarnings w_not_total_fullwidth

rule "skip assemble heroes":
    @Condition isAssemblingHeroes()
    setMatchTime(0)

rule "":
    disableGamemodeCompletion()
    wait(5)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)
    createDummy(Hero.ANA, Team.ALL, -1, null, null)


rule "init player":
    @Event eachPlayer
    @Condition isGameInProgress()
    @Condition eventPlayer.hasSpawned()
    eventPlayer.setStatusEffect(null, Status.UNKILLABLE, 9999)
    chase(eventPlayer.mercyRegenChase, 9999, rate=1, ChaseReeval.DESTINATION_AND_RATE)

rule "regen":
    @Event eachPlayer
    @Condition eventPlayer.mercyRegenChase > 1
    eventPlayer.startHoT(null, 9999, 50)
    
rule "stop regen":
    @Event eachPlayer
    @Condition eventPlayer.mercyRegenChase < 1
    eventPlayer.stopAllHoT()
    
rule "stop hot on dmg":
    @Event playerTookDamage
    victim.mercyRegenChase = 0

rule "":
    @Condition isGameInProgress()
    while currentRound < nbRounds:
        gameStatus = GameStatus.ROUND_IN_PROGRESS
        getAllPlayers().guesses = []
        getAllPlayers().guessResults = []
        getAllPlayers().currentGuess = ""
        getAllPlayers().hasGuessedWord = false
        getAllPlayers().kbKeysGuesses = []
        bigMessage(getAllPlayers(), "Round {}/{}".format(currentRound+1, nbRounds) if currentRound+1 < nbRounds else "Final round!")
        setMatchTime(roundDuration)
        disableAnnouncer()
        wait(roundDuration-15)
        setMatchTime(15)
        enableAnnouncer()
        wait(15)
        gameStatus = GameStatus.ROUND_ENDED
        bigMessage(getAllPlayers(), "Round over")
        wait(4)
        gameStatus = GameStatus.DISPLAY_SCORES
        wait(8)
        currentRound++
    declarePlayerVictory(sorted(getAllPlayers(), lambda p: -p.displayedScore)[0])

rule "increment scores":
    @Event eachPlayer
    @Condition gameStatus == GameStatus.DISPLAY_SCORES
    wait(1)
    #floor((L-X)/(L-1) * 100)
    chase(eventPlayer.displayedScore, eventPlayer.getScore(), duration=1.5, ChaseReeval.NONE)
    wait(2)
    stopChasingVariable(eventPlayer.displayedScore)



#!define sortedPlayersByScore() (sorted(getAllPlayers(), lambda x: -x.displayedScore))

rule "end of round huds":
    
    hudSubtext(getAllPlayers() if gameStatus == GameStatus.DISPLAY_SCORES else [], " \n\n\n\n\n\n\n\n", HudPosition.TOP, -750, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    hudHeader(getAllPlayers() if gameStatus == GameStatus.DISPLAY_SCORES else [], "Final Rankings" if currentRound >= nbRounds-1 else "Rankings so far", HudPosition.TOP, -740, rgb(
        128 + 127 * cosDeg(getTotalTimeElapsed() * 100),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 120),
        128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 240)
    ) if currentRound >= nbRounds-1 else Color.SKY_BLUE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers() if gameStatus == GameStatus.DISPLAY_SCORES else [], " \n", HudPosition.TOP, -730, Color.WHITE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)

    for i in range(12):        
        hudSubtext(getAllPlayers() if gameStatus == GameStatus.DISPLAY_SCORES and getNumberOfPlayers(Team.ALL)-1 >= evalOnce(i) else null, "{}: {}".format(sortedPlayersByScore()[evalOnce(i)], sortedPlayersByScore()[evalOnce(i)].displayedScore), HudPosition.TOP, evalOnce(i)-500, Color.PURPLE if sortedPlayersByScore()[evalOnce(i)] == localPlayer else Color.ORANGE, HudReeval.VISIBILITY_SORT_ORDER_STRING_AND_COLOR, SpecVisibility.DEFAULT)

    
rule "create wordle hud text":

    @Condition isGameInProgress()
    
    #current line - black bg with gray outline
    createProgressBarInWorldText(localPlayer if gameStatus == GameStatus.ROUND_IN_PROGRESS or gameStatus == GameStatus.ROUND_ENDED else [], 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
        vibrationSpaces[localPlayer.vibrationLeft],
        "" if nbLetters < 1 else "■" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+0] else "    " ,
        "" if nbLetters < 2 else "■" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+1] else "    " ,
        "" if nbLetters < 3 else "■" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+2] else "    " ,
        "" if nbLetters < 4 else "■" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+3] else "    " ,
        "" if nbLetters < 5 else "■" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+4] else "    " ,
        "" if nbLetters < 6 else "■" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+5] else "    " ,
        "" if nbLetters < 7 else "■" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+6] else "    " ,
        "" if nbLetters < 8 else "■" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+7] else "    " ,
        "" if nbLetters < 9 else "■" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+8] else "    " ,
        vibrationSpaces[localPlayer.vibrationRight]
    ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * len(localPlayer.guesses)), 4, Clip.NONE, null, Color.WORDLE_BLACK, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
    
    createProgressBarInWorldText(localPlayer if gameStatus == GameStatus.ROUND_IN_PROGRESS or gameStatus == GameStatus.ROUND_ENDED else [], 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
        vibrationSpaces[localPlayer.vibrationLeft],
        "" if nbLetters < 1 else "□" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+0] else "    " ,
        "" if nbLetters < 2 else "□" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+1] else "    " ,
        "" if nbLetters < 3 else "□" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+2] else "    " ,
        "" if nbLetters < 4 else "□" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+3] else "    " ,
        "" if nbLetters < 5 else "□" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+4] else "    " ,
        "" if nbLetters < 6 else "□" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+5] else "    " ,
        "" if nbLetters < 7 else "□" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+6] else "    " ,
        "" if nbLetters < 8 else "□" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+7] else "    " ,
        "" if nbLetters < 9 else "□" if len(localPlayer.guesses) < maxGuesses and not localPlayer.guessResults[len(localPlayer.guesses)*nbLetters+8] else "    " ,
        vibrationSpaces[localPlayer.vibrationRight]
    ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * len(localPlayer.guesses)), 4, Clip.NONE, null, Color.WORDLE_OUTLINE if len(localPlayer.guesses) < maxGuesses-1 else Color.WORDLE_OUTLINE_LAST, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)

    for i in range(maxGuesses):

        #empty - transparent gray outline
        createProgressBarInWorldText(localPlayer if gameStatus == GameStatus.ROUND_IN_PROGRESS or gameStatus == GameStatus.ROUND_ENDED else [], 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
            "" if nbLetters < 1 else "□" if len(localPlayer.guesses) < evalOnce(i) and not localPlayer.guessResults[evalOnce(i)*nbLetters+0] else "    " ,
            "" if nbLetters < 2 else "□" if len(localPlayer.guesses) < evalOnce(i) and not localPlayer.guessResults[evalOnce(i)*nbLetters+1] else "    " ,
            "" if nbLetters < 3 else "□" if len(localPlayer.guesses) < evalOnce(i) and not localPlayer.guessResults[evalOnce(i)*nbLetters+2] else "    " ,
            "" if nbLetters < 4 else "□" if len(localPlayer.guesses) < evalOnce(i) and not localPlayer.guessResults[evalOnce(i)*nbLetters+3] else "    " ,
            "" if nbLetters < 5 else "□" if len(localPlayer.guesses) < evalOnce(i) and not localPlayer.guessResults[evalOnce(i)*nbLetters+4] else "    " ,
            "" if nbLetters < 6 else "□" if len(localPlayer.guesses) < evalOnce(i) and not localPlayer.guessResults[evalOnce(i)*nbLetters+5] else "    " ,
            "" if nbLetters < 7 else "□" if len(localPlayer.guesses) < evalOnce(i) and not localPlayer.guessResults[evalOnce(i)*nbLetters+6] else "    " ,
            "" if nbLetters < 8 else "□" if len(localPlayer.guesses) < evalOnce(i) and not localPlayer.guessResults[evalOnce(i)*nbLetters+7] else "    " ,
            "" if nbLetters < 9 else "□" if len(localPlayer.guesses) < evalOnce(i) and not localPlayer.guessResults[evalOnce(i)*nbLetters+8] else "    " 
        ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(i)), 4, Clip.NONE, null, Color.WORDLE_OUTLINE_EMPTY, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        
        #Good = green
        createProgressBarInWorldText(localPlayer if gameStatus == GameStatus.ROUND_IN_PROGRESS or gameStatus == GameStatus.ROUND_ENDED else [], 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
            "" if nbLetters < 1 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+0] == GuessResult.GOOD else "    " ,
            "" if nbLetters < 2 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+1] == GuessResult.GOOD else "    " ,
            "" if nbLetters < 3 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+2] == GuessResult.GOOD else "    " ,
            "" if nbLetters < 4 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+3] == GuessResult.GOOD else "    " ,
            "" if nbLetters < 5 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+4] == GuessResult.GOOD else "    " ,
            "" if nbLetters < 6 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+5] == GuessResult.GOOD else "    " ,
            "" if nbLetters < 7 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+6] == GuessResult.GOOD else "    " ,
            "" if nbLetters < 8 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+7] == GuessResult.GOOD else "    " ,
            "" if nbLetters < 9 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+8] == GuessResult.GOOD else "    " 
        ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(i)), 4, Clip.NONE, null, Color.WORDLE_GREEN, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        
        #Bad = gray
        createProgressBarInWorldText(localPlayer if gameStatus == GameStatus.ROUND_IN_PROGRESS or gameStatus == GameStatus.ROUND_ENDED else [], 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
            "" if nbLetters < 1 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+0] == GuessResult.BAD else "    " ,
            "" if nbLetters < 2 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+1] == GuessResult.BAD else "    " ,
            "" if nbLetters < 3 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+2] == GuessResult.BAD else "    " ,
            "" if nbLetters < 4 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+3] == GuessResult.BAD else "    " ,
            "" if nbLetters < 5 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+4] == GuessResult.BAD else "    " ,
            "" if nbLetters < 6 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+5] == GuessResult.BAD else "    " ,
            "" if nbLetters < 7 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+6] == GuessResult.BAD else "    " ,
            "" if nbLetters < 8 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+7] == GuessResult.BAD else "    " ,
            "" if nbLetters < 9 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+8] == GuessResult.BAD else "    " 
        ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(i)), 4, Clip.NONE, null, Color.WORDLE_GRAY, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        
        #Wrong place = yellow
        createProgressBarInWorldText(localPlayer if gameStatus == GameStatus.ROUND_IN_PROGRESS or gameStatus == GameStatus.ROUND_ENDED else [], 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
            "" if nbLetters < 1 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+0] == GuessResult.WRONG_PLACE else "    " ,
            "" if nbLetters < 2 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+1] == GuessResult.WRONG_PLACE else "    " ,
            "" if nbLetters < 3 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+2] == GuessResult.WRONG_PLACE else "    " ,
            "" if nbLetters < 4 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+3] == GuessResult.WRONG_PLACE else "    " ,
            "" if nbLetters < 5 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+4] == GuessResult.WRONG_PLACE else "    " ,
            "" if nbLetters < 6 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+5] == GuessResult.WRONG_PLACE else "    " ,
            "" if nbLetters < 7 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+6] == GuessResult.WRONG_PLACE else "    " ,
            "" if nbLetters < 8 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+7] == GuessResult.WRONG_PLACE else "    " ,
            "" if nbLetters < 9 else "■" if localPlayer.guessResults[evalOnce(i)*nbLetters+8] == GuessResult.WRONG_PLACE else "    " 
        ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(i)), 4, Clip.NONE, null, Color.WORDLE_YELLOW, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)

        wait()
        createProgressBarInWorldText(localPlayer if gameStatus == GameStatus.ROUND_IN_PROGRESS or gameStatus == GameStatus.ROUND_ENDED else [], 10, " \n\n\n\n\n\n\n\n\n\n\n\n\n{}{}  {}  {}  {}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
            vibrationLetterSpaces[localPlayer.vibrationLeft] if len(localPlayer.guesses) == evalOnce(i) else "",
            "\&fullwidth_space;" if len(localPlayer.guesses) < evalOnce(i) else localPlayer.guesses[evalOnce(i)].charAt(0) if len(localPlayer.guesses) > evalOnce(i) else ([localPlayer.currentGuess.charAt(0)] or ["\&fullwidth_space;"]),
            "\&fullwidth_space;" if len(localPlayer.guesses) < evalOnce(i) else localPlayer.guesses[evalOnce(i)].charAt(1) if len(localPlayer.guesses) > evalOnce(i) else ([localPlayer.currentGuess.charAt(1)] or ["\&fullwidth_space;"]),
            "\&fullwidth_space;" if len(localPlayer.guesses) < evalOnce(i) else localPlayer.guesses[evalOnce(i)].charAt(2) if len(localPlayer.guesses) > evalOnce(i) else ([localPlayer.currentGuess.charAt(2)] or ["\&fullwidth_space;"]),
            "\&fullwidth_space;" if len(localPlayer.guesses) < evalOnce(i) else localPlayer.guesses[evalOnce(i)].charAt(3) if len(localPlayer.guesses) > evalOnce(i) else ([localPlayer.currentGuess.charAt(3)] or ["\&fullwidth_space;"]),
            "" if nbLetters < 5 else "\u2004\u2004{}".format("\&fullwidth_space;" if len(localPlayer.guesses) < evalOnce(i) else localPlayer.guesses[evalOnce(i)].charAt(4) if len(localPlayer.guesses) > evalOnce(i) else ([localPlayer.currentGuess.charAt(4)] or ["\&fullwidth_space;"])),
            "" if nbLetters < 6 else "\u2004\u2004{}".format("\&fullwidth_space;" if len(localPlayer.guesses) < evalOnce(i) else localPlayer.guesses[evalOnce(i)].charAt(5) if len(localPlayer.guesses) > evalOnce(i) else ([localPlayer.currentGuess.charAt(5)] or ["\&fullwidth_space;"])),
            "" if nbLetters < 7 else "\u2004\u2004{}".format("\&fullwidth_space;" if len(localPlayer.guesses) < evalOnce(i) else localPlayer.guesses[evalOnce(i)].charAt(6) if len(localPlayer.guesses) > evalOnce(i) else ([localPlayer.currentGuess.charAt(6)] or ["\&fullwidth_space;"])),
            "" if nbLetters < 8 else "\u2004\u2004{}".format("\&fullwidth_space;" if len(localPlayer.guesses) < evalOnce(i) else localPlayer.guesses[evalOnce(i)].charAt(7) if len(localPlayer.guesses) > evalOnce(i) else ([localPlayer.currentGuess.charAt(7)] or ["\&fullwidth_space;"])),
            "" if nbLetters < 9 else "\u2004\u2004{}".format("\&fullwidth_space;" if len(localPlayer.guesses) < evalOnce(i) else localPlayer.guesses[evalOnce(i)].charAt(8) if len(localPlayer.guesses) > evalOnce(i) else ([localPlayer.currentGuess.charAt(8)] or ["\&fullwidth_space;"])),
            vibrationLetterSpaces[localPlayer.vibrationRight] if len(localPlayer.guesses) == evalOnce(i) else ""
        ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(i)), 2, Clip.NONE, rgba(0,0,0,0), rgb(0xd7+0, 0xda+0, 0xdc+0), ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        wait()
    

    #error message

    hudText(localPlayer, localPlayer.errorMsg or [""], "\z", "\z", HudPosition.TOP, -10, Color.RED, null, null, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(localPlayer, " \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, -8, Color.RED, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudText(localPlayer, "Press {} to enter/exit keyboard".format("[{}]".format(buttonString(Button.INTERACT)) if strContains("ABCDEFGHIJKLMNOPQRSTUVWXYZ", buttonString(Button.INTERACT).charAt(0)) else buttonString(Button.INTERACT)) if not localPlayer.hasKeyboardOpened and not localPlayer.hasGuessedWord and len(localPlayer.guesses) < maxGuesses and gameStatus == GameStatus.ROUND_IN_PROGRESS else "", "\z", "\z", HudPosition.TOP, -7, Color.RED, null, null, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(localPlayer, " \n\n\n\n\n\n\n", HudPosition.TOP, -6, Color.RED, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)

    #top left instructions
    hudHeader(localPlayer.hasPassedWelcomeScreen, "   Overwordle   \n\n\n", HudPosition.LEFT, -10, Color.PURPLE, HudReeval.VISIBILITY, SpecVisibility.DEFAULT)
    #hudText(localPlayer.hasPassedWelcomeScreen, "Overwordle", null, "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               ", HudPosition.RIGHT, -10, Color.PURPLE, null, null, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(localPlayer.hasPassedWelcomeScreen, "ѝ"VERSION" | discord.gg/YP544CH | code: "CODE, HudPosition.RIGHT, -10, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(localPlayer.hasPassedWelcomeScreen, "", " ", " • Green = right place                                                                                                                                                              ", HudPosition.RIGHT, -9, null, null, Color.KB_GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(localPlayer.hasPassedWelcomeScreen, "", null, " • Yellow = wrong place                                                                                                                                                              ", HudPosition.RIGHT, -8, null, null, Color.KB_YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(localPlayer.hasPassedWelcomeScreen, "", null, " • Gray = wrong letter                                                                                                                                                              ", HudPosition.RIGHT, -7, null, null, Color.GRAY, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    #hudText(localPlayer, "", " ", " ", HudPosition.TOP, 999 if localPlayer.errorMsg else -9, Color.RED, null, null, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    #createProgressBarInWorldText(localPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n\n\n\n\n", updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection() * 100), 999, Clip.NONE, rgba(0,0,0,0), Color.GREEN, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)


