#!include "keyboard.opy"
#!include "words.opy"

globalvar wordToGuess = "hanzo"
globalvar maxGuesses = 6

playervar guesses = [
    ["a", "b", "c", "d", "e"],
    ["a", "b", "c", "d", "e"],
    ["a", "b", "c", "d", "e"],
    ["a", "b", "c", "d", "e"],
    ["a", "b", "c", "d", "e"],
    ["a", "b", "c", "d", "e"],
]

#!suppressWarnings w_not_total_fullwidth

globalvar fullwidth = w"ABCDEFGHIJKLMNOPQRSTUVWXYZ OwO"

playervar i

rule "init":
    @Event eachPlayer

rule "display hud text":
    @Event eachPlayer
    for eventPlayer.i in range(maxGuesses):
        createProgressBarInWorldText(eventPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n■■■■■\n\n\n\n\n\n\n\n\n\n", updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(eventPlayer.i)), 4, Clip.NONE, rgba(0,0,0,0), rgb(0, 80, 0), ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        wait(1)
        createProgressBarInWorldText(eventPlayer, 10, " \n\n\n\n\n\n\n\n\n\n\n\n\n{}  {}  {}  {}  {}\n\n\n\n\n\n\n\n\n\n".format(
            fullwidth.charAt(evalOnce(eventPlayer.i)*5),
            fullwidth.charAt(evalOnce(eventPlayer.i)*5+1),
            fullwidth.charAt(evalOnce(eventPlayer.i)*5+2),
            fullwidth.charAt(evalOnce(eventPlayer.i)*5+3),
            fullwidth.charAt(evalOnce(eventPlayer.i)*5+4)
        ), updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection()  + angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) + 90) * 0.095 * evalOnce(eventPlayer.i)), 2, Clip.NONE, rgba(0,0,0,0), rgb(0xd7+0, 0xda+0, 0xdc+0), ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
        wait(1)
    
    #createProgressBarInWorldText(eventPlayer, 10, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n■■■■■\n\n\n\n\n", updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100), 999, Clip.NONE, rgba(0,0,0,0), Color.GREEN, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)


