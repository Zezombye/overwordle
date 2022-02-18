
##!obfuscate noStringObfuscation noInspectorObfuscation noConstantObfuscation

#!include "warning.opy"

#!define VERSION "1.1.1"
#!define CODE "FX999"

globalvar wordToGuess = w""
globalvar wordToGuessNormal = ""

globalvar fullwidthAlphabet = w"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
globalvar normalAlphabet = "󠁁󠁂󠁃󠁄󠁅󠁆󠁇󠁈󠁉󠁊󠁋󠁌󠁍󠁎󠁏󠁐󠁑󠁒󠁓󠁔󠁕󠁖󠁗󠁘󠁙󠁚"
globalvar compressionAlphabet = "&~,#'([-|`_^@)]+=}$*%!:;.?"
globalvar ordinals = ["1st", "2nd", "3rd", "4th", "5th"]

playervar forceKeyboardValidation = false

#!define WORKSHOP_SETTING_CATEGORY "OverWordle "VERSION" by Zezombye | code: "CODE"\nJoin the discord for feedback: discord.gg/YP544CH\nEnjoy the game :)\n"

globalvar maxGuesses = createWorkshopSetting(int[4:7], WORKSHOP_SETTING_CATEGORY, "Number of guesses", 6, 0)
globalvar nbRounds = createWorkshopSetting(int[1:20], WORKSHOP_SETTING_CATEGORY, "Number of rounds", 5, 1)
globalvar roundDuration = createWorkshopSetting(int[60:600], WORKSHOP_SETTING_CATEGORY, "Round duration (in seconds)", 180, 2)
globalvar isHardModeEnabled = createWorkshopSetting(bool, WORKSHOP_SETTING_CATEGORY, "Enable hard mode (revealed hints must be used)", false, 3)
globalvar startWithLastRoundWord = createWorkshopSetting(bool, WORKSHOP_SETTING_CATEGORY, "Start round with last round's word", false, 3)
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

playervar isPlayer = true #to check if player is spec
playervar guessResults = []
playervar hasGuessedWord = false
playervar displayedScore
playervar validLetterBools = []

playervar currentGuess = ""
playervar i
playervar j
playervar hasPassedWelcomeScreen = false
playervar mercyRegenChase = 0

globalvar currentRound = 0

enum GameStatus:
    WAITING_FOR_PLAYERS,
    ROUND_IN_PROGRESS,
    ROUND_ENDED,
    DISPLAY_SCORES,

globalvar gameStatus

#!include "words.opy"
#!include "keyboard.opy"
#!include "settings.opy"
#!include "welcomeScreen.opy"

#!suppressWarnings w_not_total_fullwidth

rule "skip assemble heroes":
    @Condition isAssemblingHeroes()
    setMatchTime(10)

    
rule "enough players - start game":
    @Condition isWaitingForPlayers()
    @Condition getNumberOfPlayers(Team.ALL) >= 4
    startGamemode()

rule "":
    #print(getNumberOfTextIds())
    /*print("Word to guess: {}".format(wordToGuessNormal))
    print("charat0 index: {}".format(fullwidthAlphabet.strIndex(hostPlayer.currentGuess.charAt(0))))
    print("charat1 index: {}".format(fullwidthAlphabet.strIndex(hostPlayer.currentGuess.charAt(1))))
    print("string validwords: {}".format(validWords[fullwidthAlphabet.strIndex(hostPlayer.currentGuess.charAt(0))][fullwidthAlphabet.strIndex(hostPlayer.currentGuess.charAt(1))][hostPlayer.i]))
    print("validword char: {}".format(validWords[fullwidthAlphabet.strIndex(hostPlayer.currentGuess.charAt(0))][fullwidthAlphabet.strIndex(hostPlayer.currentGuess.charAt(1))][hostPlayer.i].charAt(hostPlayer.j*3+0)))
    print("guess char: {}".format(compressionAlphabet.charAt(fullwidthAlphabet.strIndex(hostPlayer.currentGuess.charAt(2)))))*/
    disableGamemodeCompletion()
    disableScoring()
    disableInspector()
    hudHeader(getAllPlayers() if isWaitingForPlayers() else null, "Waiting for players to start ({}/{})".format(getNumberOfPlayers(Team.ALL), 4) if getNumberOfPlayers(Team.ALL) < 4 else "Starting the game...", HudPosition.TOP, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    wait(5)
    /*for i in range(12):
        createDummy(getAllHeroes()[i], Team.ALL, i, null, null)*/


rule "init player":
    @Event eachPlayer
    @Condition isGameInProgress()
    @Condition eventPlayer.hasSpawned()
    eventPlayer.setStatusEffect(null, Status.UNKILLABLE, 9999)
    chase(eventPlayer.mercyRegenChase, 9999, rate=1, ChaseReeval.DESTINATION_AND_RATE)

    for eventPlayer.i in range(GuessResult.BAD, GuessResult.GOOD+1):
        createInWorldText(getAllPlayers(), "{}{}{}{}{}{}{}".format(
            "" if len(eventPlayer.guesses) <= 0 else "{}{}{}{}{}".format(
                "■" if eventPlayer.guessResults[0*nbLetters+0] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[0*nbLetters+1] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[0*nbLetters+2] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[0*nbLetters+3] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[0*nbLetters+4] == evalOnce(eventPlayer.i) else "    "
            ),
            "" if len(eventPlayer.guesses) <= 1 else "\n{}{}{}{}{}".format(
                "■" if eventPlayer.guessResults[1*nbLetters+0] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[1*nbLetters+1] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[1*nbLetters+2] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[1*nbLetters+3] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[1*nbLetters+4] == evalOnce(eventPlayer.i) else "    "
            ),
            "" if len(eventPlayer.guesses) <= 2 else "\n{}{}{}{}{}".format(
                "■" if eventPlayer.guessResults[2*nbLetters+0] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[2*nbLetters+1] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[2*nbLetters+2] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[2*nbLetters+3] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[2*nbLetters+4] == evalOnce(eventPlayer.i) else "    "
            ),
            "" if len(eventPlayer.guesses) <= 3 else "\n{}{}{}{}{}".format(
                "■" if eventPlayer.guessResults[3*nbLetters+0] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[3*nbLetters+1] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[3*nbLetters+2] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[3*nbLetters+3] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[3*nbLetters+4] == evalOnce(eventPlayer.i) else "    "
            ),
            "" if len(eventPlayer.guesses) <= 4 else "\n{}{}{}{}{}".format(
                "■" if eventPlayer.guessResults[4*nbLetters+0] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[4*nbLetters+1] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[4*nbLetters+2] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[4*nbLetters+3] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[4*nbLetters+4] == evalOnce(eventPlayer.i) else "    "
            ),
            "" if len(eventPlayer.guesses) <= 5 else "\n{}{}{}{}{}".format(
                "■" if eventPlayer.guessResults[5*nbLetters+0] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[5*nbLetters+1] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[5*nbLetters+2] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[5*nbLetters+3] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[5*nbLetters+4] == evalOnce(eventPlayer.i) else "    "
            ),
            "" if len(eventPlayer.guesses) <= 6 else "\n{}{}{}{}{}".format(
                "■" if eventPlayer.guessResults[6*nbLetters+0] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[6*nbLetters+1] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[6*nbLetters+2] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[6*nbLetters+3] == evalOnce(eventPlayer.i) else "    ",
                "■" if eventPlayer.guessResults[6*nbLetters+4] == evalOnce(eventPlayer.i) else "    "
            )
        ), eventPlayer, 2, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, [Color.WORDLE_GRAY, Color.WORDLE_YELLOW, Color.WORDLE_GREEN][evalOnce(eventPlayer.i)-1], SpecVisibility.NEVER)

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
        getAllPlayers().validLetterBools = []
        if startWithLastRoundWord and currentRound > 0:
            getAllPlayers().currentGuess = wordToGuess
            getAllPlayers().forceKeyboardValidation = true
            getAllPlayers().selectedKeyboardKey = 31
        else:
            getAllPlayers().currentGuess = ""
        wordToGuess = possibleTargetWords[random.randint(0, 2)][random.randint(0, 774)]
        wordToGuessNormal = "{}{}{}{}{}".format(
            normalAlphabet.charAt(floor(wordToGuess%((26**5)/2)/((26**4)/2))),
            normalAlphabet.charAt(floor(wordToGuess%((26**4)/2)/((26**3)/2))),
            normalAlphabet.charAt(floor(wordToGuess%((26**3)/2)/((26**2)/2))),
            normalAlphabet.charAt(floor(wordToGuess%((26**2)/2)/((26**1)/2))),
            normalAlphabet.charAt(floor(wordToGuess%((26**1)/2)/((26**0)/2)))
        )
        wordToGuess = "{}{}{}{}{}".format(
            fullwidthAlphabet.charAt(floor(wordToGuess%((26**5)/2)/((26**4)/2))),
            fullwidthAlphabet.charAt(floor(wordToGuess%((26**4)/2)/((26**3)/2))),
            fullwidthAlphabet.charAt(floor(wordToGuess%((26**3)/2)/((26**2)/2))),
            fullwidthAlphabet.charAt(floor(wordToGuess%((26**2)/2)/((26**1)/2))),
            fullwidthAlphabet.charAt(floor(wordToGuess%((26**1)/2)/((26**0)/2)))
        )
        getAllPlayers().hasGuessedWord = false
        getAllPlayers().kbKeysGuesses = []
        wait()
        bigMessage(getAllPlayers(), "Round {}/{}".format(currentRound+1, nbRounds) if currentRound+1 < nbRounds else "Final round!")
        setMatchTime(roundDuration)
        disableAnnouncer()
        wait()
        waitUntil(getMatchTime() <= 15, roundDuration-15)
        setMatchTime(15)
        enableAnnouncer()
        waitUntil(getMatchTime() == 0, 15)
        gameStatus = GameStatus.ROUND_ENDED
        if any([not p.hasGuessedWord for p in getAllPlayers() if p.hasPassedWelcomeScreen]):
            bigMessage(getAllPlayers(), "Round over! The word was: {}".format(wordToGuessNormal))
        else:
            bigMessage(getAllPlayers(), "Everyone guessed the word!")
        /*for i in range(12):
            getAllPlayers()[i].addToScore(random.randint(1, 30))*/
        wait(4)
        gameStatus = GameStatus.DISPLAY_SCORES
        wait(8)
        currentRound++
    declarePlayerVictory(sorted(getAllPlayers(), lambda p: -p.displayedScore)[0])

rule "end round early if all players finished":
    @Condition gameStatus == GameStatus.ROUND_IN_PROGRESS
    @Condition getMatchTime() > 15
    @Condition len([p for p in getAllPlayers() if p.hasPassedWelcomeScreen]) > 0
    @Condition all([p.hasGuessedWord or len(p.guesses) >= maxGuesses for p in getAllPlayers() if p.hasPassedWelcomeScreen])
    setMatchTime(15)

rule "increment scores":
    @Event eachPlayer
    @Condition gameStatus == GameStatus.DISPLAY_SCORES
    wait(1)
    #floor((L-X)/(L-1) * 100)
    chase(eventPlayer.displayedScore, eventPlayer.getScore(), duration=1.5, ChaseReeval.NONE)
    wait(2)
    stopChasingVariable(eventPlayer.displayedScore)


rule "create wordle hud text":
    
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
    ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * len(localPlayer.guesses)), 4, Clip.NONE, null, Color.WORDLE_BLACK, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
    
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
    ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * len(localPlayer.guesses)), 4, Clip.NONE, null, Color.WORDLE_OUTLINE if len(localPlayer.guesses) < maxGuesses-1 or localPlayer.hasGuessedWord else Color.WORDLE_OUTLINE_LAST, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)

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
        ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(i)), 4, Clip.NONE, null, Color.WORDLE_OUTLINE_EMPTY, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
        
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
        ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(i)), 4, Clip.NONE, null, Color.WORDLE_GREEN, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
        
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
        ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(i)), 4, Clip.NONE, null, Color.WORDLE_GRAY, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
        
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
        ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(i)), 4, Clip.NONE, null, Color.WORDLE_YELLOW, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)

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
        ), updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(i)), 2, Clip.NONE, rgba(0,0,0,0), rgb(0xd7+0, 0xda+0, 0xdc+0), ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)
        wait()
    

    #error message

    hudText([true], localPlayer.errorMsg if localPlayer.errorMsg else "Sorry, this gamemode does not support spectating." if not localPlayer.isPlayer else "", "\z", "\z", HudPosition.TOP, -10 if localPlayer.isPlayer else -1000, Color.RED, null, null, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.ALWAYS)
    hudSubtext(localPlayer, " \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, -8, Color.RED, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)
    hudText(localPlayer, "Press {} to enter/exit keyboard".format("[{}]".format(buttonString(Button.INTERACT)) if strContains("ABCDEFGHIJKLMNOPQRSTUVWXYZ", buttonString(Button.INTERACT).charAt(0)) else buttonString(Button.INTERACT)) if not localPlayer.hasKeyboardOpened and not localPlayer.hasGuessedWord and len(localPlayer.guesses) < maxGuesses and gameStatus == GameStatus.ROUND_IN_PROGRESS else "", "\z", "\z", HudPosition.TOP, -7, Color.RED, null, null, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)
    hudSubtext(localPlayer, " \n\n\n\n\n\n\n", HudPosition.TOP, -6, Color.RED, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)

    #top left instructions
    hudText(localPlayer.hasPassedWelcomeScreen, "   Overwordle   \n\n\n", null, "by Zezombye", HudPosition.LEFT, -10, Color.PURPLE, Color.PURPLE, Color.AQUA, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudSubtext(localPlayer.hasPassedWelcomeScreen, "Hard mode is on.\nRevealed hints must be used" if isHardModeEnabled else "", HudPosition.LEFT, -9, Color.ROSE, HudReeval.VISIBILITY, SpecVisibility.NEVER)
    hudSubtext(localPlayer.hasPassedWelcomeScreen, "ѝ"VERSION" | discord.gg/YP544CH | code: "CODE, HudPosition.RIGHT, -10, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudText(localPlayer.hasPassedWelcomeScreen, "", " ", " • Green = right place                                                                                                                                                              ", HudPosition.RIGHT, -9, null, null, Color.KB_GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudText(localPlayer.hasPassedWelcomeScreen, "", null, " • Yellow = wrong place                                                                                                                                                              ", HudPosition.RIGHT, -8, null, null, Color.KB_YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
    hudText(localPlayer.hasPassedWelcomeScreen, "", null, " • Gray = wrong letter                                                                                                                                                              ", HudPosition.RIGHT, -7, null, null, Color.GRAY, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)

    #hudText(localPlayer, "", " ", " ", HudPosition.TOP, 999 if localPlayer.errorMsg else -9, Color.RED, null, null, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.NEVER)
    #createProgressBarInWorldText(localPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n\n\n\n\n", updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection() * 100), 999, Clip.NONE, rgba(0,0,0,0), Color.GREEN, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.NEVER)


