
globalvar wordToGuess = w"FANNNYF"

globalvar test1 = wordToGuess.split("")
globalvar test2 = wordToGuess.split(w"N")
globalvar test3 = wordToGuess.split(w"O")


globalvar maxGuesses = 7
globalvar nbLetters = 7

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

playervar currentGuess = ""
playervar i
globalvar undefined

#!include "keyboard.opy"
#!include "words.opy"
#!include "settings.opy"

#!suppressWarnings w_not_total_fullwidth

rule "skip assemble heroes":
    @Condition isAssemblingHeroes()
    setMatchTime(0)

rule "":
    wait(5)
    createDummy(Hero.ANA, Team.ALL, 2, null, null)

rule "init":
    @Event eachPlayer
    
rule "create hud text":

    @Condition isGameInProgress()
    wait(1)
    
    #current line - black bg with gray outline
    createProgressBarInWorldText(localPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
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
    
    createProgressBarInWorldText(localPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
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
        createProgressBarInWorldText(localPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
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
        createProgressBarInWorldText(localPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
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
        createProgressBarInWorldText(localPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
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
        createProgressBarInWorldText(localPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n{}{}{}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
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
        createProgressBarInWorldText(localPlayer, 10, " \n\n\n\n\n\n\n\n\n\n\n\n\n{}{}  {}  {}  {}{}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
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
    hudSubtext(localPlayer, " \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, -8, Color.RED, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    #hudText(localPlayer, "", " ", " ", HudPosition.TOP, 999 if localPlayer.errorMsg else -9, Color.RED, null, null, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
    #createProgressBarInWorldText(localPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n\n\n\n\n", updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection() * 100), 999, Clip.NONE, rgba(0,0,0,0), Color.GREEN, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)


