
globalvar wordToGuess = "hanzo"
globalvar maxGuesses = 7
globalvar nbLetters = 9

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
    w"ABCDEFGHI",
    w"ABCDEFGHI",
    w"ABCDEFGHI",
]

playervar currentGuess = ""

#!include "keyboard.opy"
#!include "words.opy"

#!suppressWarnings w_not_total_fullwidth

playervar i

rule "init":
    @Event eachPlayer

    
rule "display hud text":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    for eventPlayer.i in range(maxGuesses):
        createProgressBarInWorldText(eventPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n■■■■■■■■■\n\n\n\n\n\n\n\n\n\n", updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(eventPlayer.i)), 4, Clip.NONE, rgba(0,0,0,0), rgba(0, 80, 0, 200) if evalOnce(eventPlayer.i) < 2 else rgb(50, 50, 50), ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        createProgressBarInWorldText(eventPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n□□□□□□□□□\n\n\n\n\n\n\n\n\n\n", updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(eventPlayer.i)), 4, Clip.NONE, rgba(0,0,0,0), rgb(50, 50, 50), ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        wait(0.1)
        createProgressBarInWorldText(eventPlayer, 10, " \n\n\n\n\n\n\n\n\n\n\n\n\n{}  {}  {}  {}{}{}{}{}{}\n\n\n\n\n\n\n\n\n\n".format(
            "\&fullwidth_space;" if len(eventPlayer.guesses) < evalOnce(eventPlayer.i) else eventPlayer.guesses[evalOnce(eventPlayer.i)].charAt(0) if len(eventPlayer.guesses) > evalOnce(eventPlayer.i) else ([eventPlayer.currentGuess.charAt(0)] or ["\&fullwidth_space;"]),
            "\&fullwidth_space;" if len(eventPlayer.guesses) < evalOnce(eventPlayer.i) else eventPlayer.guesses[evalOnce(eventPlayer.i)].charAt(1) if len(eventPlayer.guesses) > evalOnce(eventPlayer.i) else ([eventPlayer.currentGuess.charAt(1)] or ["\&fullwidth_space;"]),
            "\&fullwidth_space;" if len(eventPlayer.guesses) < evalOnce(eventPlayer.i) else eventPlayer.guesses[evalOnce(eventPlayer.i)].charAt(2) if len(eventPlayer.guesses) > evalOnce(eventPlayer.i) else ([eventPlayer.currentGuess.charAt(2)] or ["\&fullwidth_space;"]),
            "\&fullwidth_space;" if len(eventPlayer.guesses) < evalOnce(eventPlayer.i) else eventPlayer.guesses[evalOnce(eventPlayer.i)].charAt(3) if len(eventPlayer.guesses) > evalOnce(eventPlayer.i) else ([eventPlayer.currentGuess.charAt(3)] or ["\&fullwidth_space;"]),
            "" if maxGuesses <= evalOnce(eventPlayer.i) else "\u2004\u2004{}".format("\&fullwidth_space;" if len(eventPlayer.guesses) < evalOnce(eventPlayer.i) else eventPlayer.guesses[evalOnce(eventPlayer.i)].charAt(4) if len(eventPlayer.guesses) > evalOnce(eventPlayer.i) else ([eventPlayer.currentGuess.charAt(4)] or ["\&fullwidth_space;"])),
            "" if maxGuesses <= evalOnce(eventPlayer.i) else "\u2004\u2004{}".format("\&fullwidth_space;" if len(eventPlayer.guesses) < evalOnce(eventPlayer.i) else eventPlayer.guesses[evalOnce(eventPlayer.i)].charAt(5) if len(eventPlayer.guesses) > evalOnce(eventPlayer.i) else ([eventPlayer.currentGuess.charAt(5)] or ["\&fullwidth_space;"])),
            "" if maxGuesses <= evalOnce(eventPlayer.i) else "\u2004\u2004{}".format("\&fullwidth_space;" if len(eventPlayer.guesses) < evalOnce(eventPlayer.i) else eventPlayer.guesses[evalOnce(eventPlayer.i)].charAt(6) if len(eventPlayer.guesses) > evalOnce(eventPlayer.i) else ([eventPlayer.currentGuess.charAt(6)] or ["\&fullwidth_space;"])),
            "" if maxGuesses <= evalOnce(eventPlayer.i) else "\u2004\u2004{}".format("\&fullwidth_space;" if len(eventPlayer.guesses) < evalOnce(eventPlayer.i) else eventPlayer.guesses[evalOnce(eventPlayer.i)].charAt(7) if len(eventPlayer.guesses) > evalOnce(eventPlayer.i) else ([eventPlayer.currentGuess.charAt(7)] or ["\&fullwidth_space;"])),
            "" if maxGuesses <= evalOnce(eventPlayer.i) else "\u2004\u2004{}".format("\&fullwidth_space;" if len(eventPlayer.guesses) < evalOnce(eventPlayer.i) else eventPlayer.guesses[evalOnce(eventPlayer.i)].charAt(8) if len(eventPlayer.guesses) > evalOnce(eventPlayer.i) else ([eventPlayer.currentGuess.charAt(8)] or ["\&fullwidth_space;"]))
        ), updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(eventPlayer.i)), 2, Clip.NONE, rgba(0,0,0,0), rgb(0xd7+0, 0xda+0, 0xdc+0), ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        wait(0.1)
    
    #createProgressBarInWorldText(eventPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n\n\n\n\n", updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100), 999, Clip.NONE, rgba(0,0,0,0), Color.GREEN, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)


