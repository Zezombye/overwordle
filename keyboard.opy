#!mainFile "main.opy"


#Global variables

globalvar CHAR_ARRAY 0
globalvar XpositionARRAY 1
globalvar YpositionARRAY 2
globalvar TestIndex 3
globalvar CharSize 4


#Player variables

playervar originalFacingDir
playervar hasKeyboardOpened

playervar kbFirstRow
playervar kbSecondRow
playervar kbThirdRow

#!define SENSIVITY 0.2
#!define KEYBOARD_INDENT 0.06
#!define KEYBOARD_TOP_LEFT_X -1.42
#!define KEYBOARD_TOP_LEFT_Y 0.84
#!define HORIZONTAL_KEY_DISTANCE 0.27111111
#!define VERTICAL_KEY_DISTANCE 0.3
#!define KEY_SIDE_LENGTH 0.24
#!define CURSOR_X ((angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.originalFacingDir)) * SENSIVITY) - eventPlayer.additionalXOffset)
#!define CURSOR_Y ((-angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.originalFacingDir)) * SENSIVITY) - eventPlayer.additionalYOffset)
#!define CURSOR_X_LOCAL ((angleDifference(horizontalAngleOfDirection(localPlayer.getFacingDirection()), horizontalAngleOfDirection(localPlayer.originalFacingDir)) * SENSIVITY) - localPlayer.additionalXOffset)
#!define CURSOR_Y_LOCAL ((-angleDifference(verticalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.originalFacingDir)) * SENSIVITY) - localPlayer.additionalYOffset)


#!define ENTER_TOP_LEFT_X -1.42
#!define ENTER_TOP_LEFT_Y 1.72
#!define ENTER_BOTTOM_RIGHT_X -0.74
#!define ENTER_BOTTOM_RIGHT_Y 1.97

#!define BACKSPACE_TOP_LEFT_X 0.66
#!define BACKSPACE_TOP_LEFT_Y 1.74
#!define BACKSPACE_BOTTOM_RIGHT_X 1.34
#!define BACKSPACE_BOTTOM_RIGHT_Y 1.97

#!define BORDER_TOP_LEFT_X -1.71
#!define BORDER_TOP_LEFT_Y 0.64
#!define BORDER_BOTTOM_RIGHT_X 1.53
#!define BORDER_BOTTOM_RIGHT_Y 2.13

#!define getKeyboardSelectedKey() updateEveryTick((\
    [1,2,3,4,5,6,7,8,9,10][(floor((CURSOR_X-KEYBOARD_TOP_LEFT_X)/HORIZONTAL_KEY_DISTANCE))] if KEYBOARD_TOP_LEFT_Y <= CURSOR_Y and CURSOR_Y <= KEYBOARD_TOP_LEFT_Y+KEY_SIDE_LENGTH and (CURSOR_X-KEYBOARD_TOP_LEFT_X)%HORIZONTAL_KEY_DISTANCE <= HORIZONTAL_KEY_DISTANCE else\
    [11,12,13,14,15,16,17,18,19,20][(floor((CURSOR_X-KEYBOARD_TOP_LEFT_X-KEYBOARD_INDENT)/HORIZONTAL_KEY_DISTANCE))] if KEYBOARD_TOP_LEFT_Y+VERTICAL_KEY_DISTANCE <= CURSOR_Y and CURSOR_Y <= KEYBOARD_TOP_LEFT_Y+VERTICAL_KEY_DISTANCE+KEY_SIDE_LENGTH and (CURSOR_X-KEYBOARD_TOP_LEFT_X-KEYBOARD_INDENT)%HORIZONTAL_KEY_DISTANCE <= HORIZONTAL_KEY_DISTANCE else\
    [21,22,23,24,25,26,27][(floor((CURSOR_X-KEYBOARD_TOP_LEFT_X-KEYBOARD_INDENT*2)/HORIZONTAL_KEY_DISTANCE))] if KEYBOARD_TOP_LEFT_Y+VERTICAL_KEY_DISTANCE*2 <= CURSOR_Y and CURSOR_Y <= KEYBOARD_TOP_LEFT_Y+VERTICAL_KEY_DISTANCE*2+KEY_SIDE_LENGTH and (CURSOR_X-KEYBOARD_TOP_LEFT_X-KEYBOARD_INDENT*2)%HORIZONTAL_KEY_DISTANCE <= HORIZONTAL_KEY_DISTANCE else\
    31 if CURSOR_X >= ENTER_TOP_LEFT_X and CURSOR_Y >= ENTER_TOP_LEFT_Y and CURSOR_X <= ENTER_BOTTOM_RIGHT_X and CURSOR_Y <= ENTER_BOTTOM_RIGHT_Y else\
    32 if CURSOR_X >= BACKSPACE_TOP_LEFT_X and CURSOR_Y >= BACKSPACE_TOP_LEFT_Y and CURSOR_X <= BACKSPACE_BOTTOM_RIGHT_X and CURSOR_Y <= BACKSPACE_BOTTOM_RIGHT_Y else\
     null\
) or [""])

#!define isValueBetween(x, min, max) (((max)-(min))/2 >= abs((x) - ((max)+(min))/2))

#!define KB_KEY_ROW_1 1
#!define KB_KEY_ROW_2 11
#!define KB_KEY_ROW_3 21
#!define KB_KEY_ENTER 31
#!define KB_KEY_BACKSPACE 32

playervar selectedKeyboardKey = 0
playervar additionalXOffset = 0
playervar additionalYOffset = 0

playervar kbKeys
playervar kbKeysGuesses = []

enum KbLayout:
    QWERTY,
    AZERTY,
    QWERTZ

playervar kbLayout = KbLayout.AZERTY

rule "":
    @Event eachPlayer
    #print("{}: {}".format(eventPlayer, eventPlayer.getHorizontalFacingAngle()))

/*rule "debug hud":
    @Event eachPlayer

    print("x: {}, y: {}".format(CURSOR_X, CURSOR_Y))
    print("Letter: {}".format(getKeyboardSelectedKey()))
    print("currentGuess: |{}|".format(hostPlayer.currentGuess))
    print("nb texts: {}".format(getNumberOfTextIds()))*/

rule "Determine keyboard layout":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    @Condition not eventPlayer.hasPassedWelcomeScreen
    @Condition eventPlayer.isHoldingButton(Button.JUMP)
    eventPlayer.startFacing(
        angleToDirection(30, 0) if any([button == "A" or button == "W" for button in [
            buttonString(Button.ABILITY_1),
            buttonString(Button.ABILITY_2),
            buttonString(Button.CROUCH),
            buttonString(Button.INTERACT),
            buttonString(Button.JUMP),
            buttonString(Button.MELEE),
            buttonString(Button.PRIMARY_FIRE),
            buttonString(Button.RELOAD),
            buttonString(Button.SECONDARY_FIRE),
            buttonString(Button.ULTIMATE),
        ]]) or "{}".format(Map.PRACTICE_RANGE) == "Champ de tir"
        else angleToDirection(60, 0) if "{}".format(Map.PRACTICE_RANGE) == "Trainingsbereich"
        else angleToDirection(90, 0), 999999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)

    #Because of precision errors, we round to the hundredth.
    waitUntil(round(eventPlayer.getHorizontalFacingAngle()*100)/100 in [30, 60, 90], 3)

    if round(eventPlayer.getHorizontalFacingAngle()*100)/100 == 30:
        eventPlayer.kbLayout = KbLayout.AZERTY
    elif round(eventPlayer.getHorizontalFacingAngle()*100)/100 == 60:
        eventPlayer.kbLayout = KbLayout.QWERTZ
    else:
        eventPlayer.kbLayout = KbLayout.QWERTY

    eventPlayer.stopFacing()

    if eventPlayer.kbLayout == KbLayout.AZERTY:
        eventPlayer.kbFirstRow = w"AZERTYUIOP"
        eventPlayer.kbSecondRow = w"QSDFGHJKLM"
        eventPlayer.kbThirdRow = w"WXCVBN "
    elif eventPlayer.kbLayout == KbLayout.QWERTZ:
        eventPlayer.kbFirstRow = w"QWERTZUIOP"
        eventPlayer.kbSecondRow = w"ASDFGHJKL "
        eventPlayer.kbThirdRow = w"YXCVBNM"
    else:
        eventPlayer.kbFirstRow = w"QWERTYUIOP"
        eventPlayer.kbSecondRow = w"ASDFGHJKL "
        eventPlayer.kbThirdRow = w"ZXCVBNM"
    eventPlayer.kbKeys = " {}{}{}".format(eventPlayer.kbFirstRow, eventPlayer.kbSecondRow, eventPlayer.kbThirdRow)

rule "Toggle keyboard":
    @Event eachPlayer
    @Condition gameStatus == GameStatus.ROUND_IN_PROGRESS
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition (not eventPlayer.isCommunicatingEmote()) == true
    @Condition len(eventPlayer.guesses) < maxGuesses
    @Condition not eventPlayer.hasGuessedWord
    
    eventPlayer.hasKeyboardOpened = not eventPlayer.hasKeyboardOpened


rule "guesses exhausted":
    @Event eachPlayer
    @Condition eventPlayer.hasGuessedWord or len(eventPlayer.guesses) >= maxGuesses or gameStatus != GameStatus.ROUND_IN_PROGRESS
    eventPlayer.hasKeyboardOpened = false
    if len(eventPlayer.guesses) >= maxGuesses:
        smallMessage(eventPlayer, "Ran out of guesses!")
    elif eventPlayer.hasGuessedWord:
        smallMessage(eventPlayer, "Guessed it! +{} points".format(10+(maxGuesses - len(eventPlayer.guesses))**2))
        eventPlayer.setUltCharge(100)
        eventPlayer.addToScore(10+(maxGuesses - len(eventPlayer.guesses))**2)
        playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.GREEN, eventPlayer, 99)
        playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.GREEN, eventPlayer, 20)
        


rule "Display keyboard":

    #First row
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, " {} {} {} {} {} {} {} {} {} {} ".format(
        localPlayer.kbFirstRow.charAt(0) if localPlayer.kbKeysGuesses[0+1] == 0 else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(1) if localPlayer.kbKeysGuesses[1+1] == 0 else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(2) if localPlayer.kbKeysGuesses[2+1] == 0 else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(3) if localPlayer.kbKeysGuesses[3+1] == 0 else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(4) if localPlayer.kbKeysGuesses[4+1] == 0 else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(5) if localPlayer.kbKeysGuesses[5+1] == 0 else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(6) if localPlayer.kbKeysGuesses[6+1] == 0 else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(7) if localPlayer.kbKeysGuesses[7+1] == 0 else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(8) if localPlayer.kbKeysGuesses[8+1] == 0 else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(9) if localPlayer.kbKeysGuesses[9+1] == 0 else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.8 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_WHITE, SpecVisibility.DEFAULT)
    
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, " {} {} {} {} {} {} {} {} {} {} ".format(
        localPlayer.kbFirstRow.charAt(0) if localPlayer.kbKeysGuesses[0+1] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(1) if localPlayer.kbKeysGuesses[1+1] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(2) if localPlayer.kbKeysGuesses[2+1] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(3) if localPlayer.kbKeysGuesses[3+1] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(4) if localPlayer.kbKeysGuesses[4+1] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(5) if localPlayer.kbKeysGuesses[5+1] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(6) if localPlayer.kbKeysGuesses[6+1] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(7) if localPlayer.kbKeysGuesses[7+1] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(8) if localPlayer.kbKeysGuesses[8+1] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(9) if localPlayer.kbKeysGuesses[9+1] == GuessResult.BAD else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.8 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_GRAY, SpecVisibility.DEFAULT)
    
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, " {} {} {} {} {} {} {} {} {} {} ".format(
        localPlayer.kbFirstRow.charAt(0) if localPlayer.kbKeysGuesses[0+1] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(1) if localPlayer.kbKeysGuesses[1+1] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(2) if localPlayer.kbKeysGuesses[2+1] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(3) if localPlayer.kbKeysGuesses[3+1] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(4) if localPlayer.kbKeysGuesses[4+1] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(5) if localPlayer.kbKeysGuesses[5+1] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(6) if localPlayer.kbKeysGuesses[6+1] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(7) if localPlayer.kbKeysGuesses[7+1] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(8) if localPlayer.kbKeysGuesses[8+1] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(9) if localPlayer.kbKeysGuesses[9+1] == GuessResult.GOOD else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.8 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_GREEN, SpecVisibility.DEFAULT)
    
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, " {} {} {} {} {} {} {} {} {} {} ".format(
        localPlayer.kbFirstRow.charAt(0) if localPlayer.kbKeysGuesses[0+1] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(1) if localPlayer.kbKeysGuesses[1+1] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(2) if localPlayer.kbKeysGuesses[2+1] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(3) if localPlayer.kbKeysGuesses[3+1] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(4) if localPlayer.kbKeysGuesses[4+1] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(5) if localPlayer.kbKeysGuesses[5+1] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(6) if localPlayer.kbKeysGuesses[6+1] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(7) if localPlayer.kbKeysGuesses[7+1] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(8) if localPlayer.kbKeysGuesses[8+1] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbFirstRow.charAt(9) if localPlayer.kbKeysGuesses[9+1] == GuessResult.WRONG_PLACE else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.8 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_YELLOW, SpecVisibility.DEFAULT)
    
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, {
        null: "",
        1: "[＿]　 　 　 　 　 　 　 　 　 ",
        2: " 　[＿]　 　 　 　 　 　 　 　 ",
        3: " 　 　[＿]　 　 　 　 　 　 　 ",
        4: " 　 　 　[＿]　 　 　 　 　 　 ",
        5: " 　 　 　 　[＿]　 　 　 　 　 ",
        6: " 　 　 　 　 　[＿]　 　 　 　 ",
        7: " 　 　 　 　 　 　[＿]　 　 　 ",
        8: " 　 　 　 　 　 　 　[＿]　 　 ",
        9: " 　 　 　 　 　 　 　 　[＿]　 ",
        10: " 　 　 　 　 　 　 　 　 　[＿]",
    }[null if not isValueBetween(CURSOR_Y_LOCAL, KEYBOARD_TOP_LEFT_Y, KEYBOARD_TOP_LEFT_Y+KEY_SIDE_LENGTH) else (floor((CURSOR_X_LOCAL-KEYBOARD_TOP_LEFT_X)/HORIZONTAL_KEY_DISTANCE)) + KB_KEY_ROW_1]
    , updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.8 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_SELECTION, SpecVisibility.DEFAULT)

    #Second row
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "   {} {} {} {} {} {} {} {} {} {} ".format(
        localPlayer.kbSecondRow.charAt(0) if localPlayer.kbKeysGuesses[0+11] == 0 else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(1) if localPlayer.kbKeysGuesses[1+11] == 0 else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(2) if localPlayer.kbKeysGuesses[2+11] == 0 else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(3) if localPlayer.kbKeysGuesses[3+11] == 0 else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(4) if localPlayer.kbKeysGuesses[4+11] == 0 else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(5) if localPlayer.kbKeysGuesses[5+11] == 0 else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(6) if localPlayer.kbKeysGuesses[6+11] == 0 else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(7) if localPlayer.kbKeysGuesses[7+11] == 0 else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(8) if localPlayer.kbKeysGuesses[8+11] == 0 else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(9) if localPlayer.kbKeysGuesses[9+11] == 0 else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.5 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_WHITE, SpecVisibility.DEFAULT)
    
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "   {} {} {} {} {} {} {} {} {} {} ".format(
        localPlayer.kbSecondRow.charAt(0) if localPlayer.kbKeysGuesses[0+11] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(1) if localPlayer.kbKeysGuesses[1+11] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(2) if localPlayer.kbKeysGuesses[2+11] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(3) if localPlayer.kbKeysGuesses[3+11] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(4) if localPlayer.kbKeysGuesses[4+11] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(5) if localPlayer.kbKeysGuesses[5+11] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(6) if localPlayer.kbKeysGuesses[6+11] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(7) if localPlayer.kbKeysGuesses[7+11] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(8) if localPlayer.kbKeysGuesses[8+11] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(9) if localPlayer.kbKeysGuesses[9+11] == GuessResult.BAD else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.5 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_GRAY, SpecVisibility.DEFAULT)
    
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "   {} {} {} {} {} {} {} {} {} {} ".format(
        localPlayer.kbSecondRow.charAt(0) if localPlayer.kbKeysGuesses[0+11] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(1) if localPlayer.kbKeysGuesses[1+11] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(2) if localPlayer.kbKeysGuesses[2+11] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(3) if localPlayer.kbKeysGuesses[3+11] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(4) if localPlayer.kbKeysGuesses[4+11] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(5) if localPlayer.kbKeysGuesses[5+11] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(6) if localPlayer.kbKeysGuesses[6+11] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(7) if localPlayer.kbKeysGuesses[7+11] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(8) if localPlayer.kbKeysGuesses[8+11] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(9) if localPlayer.kbKeysGuesses[9+11] == GuessResult.GOOD else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.5 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_GREEN, SpecVisibility.DEFAULT)
    
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "   {} {} {} {} {} {} {} {} {} {} ".format(
        localPlayer.kbSecondRow.charAt(0) if localPlayer.kbKeysGuesses[0+11] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(1) if localPlayer.kbKeysGuesses[1+11] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(2) if localPlayer.kbKeysGuesses[2+11] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(3) if localPlayer.kbKeysGuesses[3+11] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(4) if localPlayer.kbKeysGuesses[4+11] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(5) if localPlayer.kbKeysGuesses[5+11] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(6) if localPlayer.kbKeysGuesses[6+11] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(7) if localPlayer.kbKeysGuesses[7+11] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(8) if localPlayer.kbKeysGuesses[8+11] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbSecondRow.charAt(9) if localPlayer.kbKeysGuesses[9+11] == GuessResult.WRONG_PLACE else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.5 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_YELLOW, SpecVisibility.DEFAULT)

    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, {
        null: "",
        11: b"  [＿]　 　 　 　 　 　 　 　 　 ",
        12: b"   　[＿]　 　 　 　 　 　 　 　 ",
        13: b"   　 　[＿]　 　 　 　 　 　 　 ",
        14: b"   　 　 　[＿]　 　 　 　 　 　 ",
        15: b"   　 　 　 　[＿]　 　 　 　 　 ",
        16: b"   　 　 　 　 　[＿]　 　 　 　 ",
        17: b"   　 　 　 　 　 　[＿]　 　 　 ",
        18: b"   　 　 　 　 　 　 　[＿]　 　 ",
        19: b"   　 　 　 　 　 　 　 　[＿]　 ",
        20: b"   　 　 　 　 　 　 　 　 　[＿]",
        }[null if not isValueBetween(CURSOR_Y_LOCAL, KEYBOARD_TOP_LEFT_Y+VERTICAL_KEY_DISTANCE, KEYBOARD_TOP_LEFT_Y+KEY_SIDE_LENGTH+VERTICAL_KEY_DISTANCE) or localPlayer.kbLayout != KbLayout.AZERTY and (floor((CURSOR_X_LOCAL-(KEYBOARD_TOP_LEFT_X+KEYBOARD_INDENT))/HORIZONTAL_KEY_DISTANCE)) + KB_KEY_ROW_2 == 20 else (floor((CURSOR_X_LOCAL-(KEYBOARD_TOP_LEFT_X+KEYBOARD_INDENT))/HORIZONTAL_KEY_DISTANCE)) + KB_KEY_ROW_2]
    , updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.5 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_SELECTION, SpecVisibility.DEFAULT)

    #Third row
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "     {} {} {} {} {} {} {} \&fullwidth_space; \&fullwidth_space; \&fullwidth_space; ".format(
        localPlayer.kbThirdRow.charAt(0) if localPlayer.kbKeysGuesses[0+21] == 0 else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(1) if localPlayer.kbKeysGuesses[1+21] == 0 else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(2) if localPlayer.kbKeysGuesses[2+21] == 0 else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(3) if localPlayer.kbKeysGuesses[3+21] == 0 else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(4) if localPlayer.kbKeysGuesses[4+21] == 0 else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(5) if localPlayer.kbKeysGuesses[5+21] == 0 else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(6) if localPlayer.kbKeysGuesses[6+21] == 0 else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.2 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_WHITE, SpecVisibility.DEFAULT)
    
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "     {} {} {} {} {} {} {} \&fullwidth_space; \&fullwidth_space; \&fullwidth_space; ".format(
        localPlayer.kbThirdRow.charAt(0) if localPlayer.kbKeysGuesses[0+21] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(1) if localPlayer.kbKeysGuesses[1+21] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(2) if localPlayer.kbKeysGuesses[2+21] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(3) if localPlayer.kbKeysGuesses[3+21] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(4) if localPlayer.kbKeysGuesses[4+21] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(5) if localPlayer.kbKeysGuesses[5+21] == GuessResult.BAD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(6) if localPlayer.kbKeysGuesses[6+21] == GuessResult.BAD else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.2 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_GRAY, SpecVisibility.DEFAULT)
    
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "     {} {} {} {} {} {} {} \&fullwidth_space; \&fullwidth_space; \&fullwidth_space; ".format(
        localPlayer.kbThirdRow.charAt(0) if localPlayer.kbKeysGuesses[0+21] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(1) if localPlayer.kbKeysGuesses[1+21] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(2) if localPlayer.kbKeysGuesses[2+21] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(3) if localPlayer.kbKeysGuesses[3+21] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(4) if localPlayer.kbKeysGuesses[4+21] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(5) if localPlayer.kbKeysGuesses[5+21] == GuessResult.GOOD else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(6) if localPlayer.kbKeysGuesses[6+21] == GuessResult.GOOD else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.2 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_GREEN, SpecVisibility.DEFAULT)
    
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "     {} {} {} {} {} {} {} \&fullwidth_space; \&fullwidth_space; \&fullwidth_space; ".format(
        localPlayer.kbThirdRow.charAt(0) if localPlayer.kbKeysGuesses[0+21] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(1) if localPlayer.kbKeysGuesses[1+21] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(2) if localPlayer.kbKeysGuesses[2+21] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(3) if localPlayer.kbKeysGuesses[3+21] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(4) if localPlayer.kbKeysGuesses[4+21] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(5) if localPlayer.kbKeysGuesses[5+21] == GuessResult.WRONG_PLACE else "\&fullwidth_space;",
        localPlayer.kbThirdRow.charAt(6) if localPlayer.kbKeysGuesses[6+21] == GuessResult.WRONG_PLACE else "\&fullwidth_space;"
    ), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.2 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_YELLOW, SpecVisibility.DEFAULT)

    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, {
        null: "",
        21: "    [＿]　 　 　 　 　 　 　 　 　 ",
        22: "     　[＿]　 　 　 　 　 　 　 　 ",
        23: "     　 　[＿]　 　 　 　 　 　 　 ",
        24: "     　 　 　[＿]　 　 　 　 　 　 ",
        25: "     　 　 　 　[＿]　 　 　 　 　 ",
        26: "     　 　 　 　 　[＿]　 　 　 　 ",
        27: "     　 　 　 　 　 　[＿]　 　 　 ",
    }[null if not isValueBetween(CURSOR_Y_LOCAL, KEYBOARD_TOP_LEFT_Y+VERTICAL_KEY_DISTANCE*2, KEYBOARD_TOP_LEFT_Y+KEY_SIDE_LENGTH+VERTICAL_KEY_DISTANCE*2) or localPlayer.kbLayout == KbLayout.AZERTY and (floor((CURSOR_X_LOCAL-(KEYBOARD_TOP_LEFT_X+KEYBOARD_INDENT*2))/HORIZONTAL_KEY_DISTANCE)) + KB_KEY_ROW_3 == 27 else (floor((CURSOR_X_LOCAL-(KEYBOARD_TOP_LEFT_X+KEYBOARD_INDENT*2))/HORIZONTAL_KEY_DISTANCE)) + KB_KEY_ROW_3]
    , updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((0.2 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.KB_SELECTION, SpecVisibility.DEFAULT)

    #Enter buttons
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "Ｅ \&fullwidth_space; \&fullwidth_space;                                                   ", updateEveryTick(localPlayer.getEyePosition() + (100 * (((-0.08 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 3, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.KB_SELECTION if isValueBetween(CURSOR_X_LOCAL, ENTER_TOP_LEFT_X, ENTER_BOTTOM_RIGHT_X) and isValueBetween(CURSOR_Y_LOCAL, ENTER_TOP_LEFT_Y, ENTER_BOTTOM_RIGHT_Y) else Color.KB_WHITE, SpecVisibility.DEFAULT)
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, " ｎ ｅ                                                    ", updateEveryTick(localPlayer.getEyePosition() + (100 * (((-0.08 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 3, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.KB_SELECTION if isValueBetween(CURSOR_X_LOCAL, ENTER_TOP_LEFT_X, ENTER_BOTTOM_RIGHT_X) and isValueBetween(CURSOR_Y_LOCAL, ENTER_TOP_LEFT_Y, ENTER_BOTTOM_RIGHT_Y) else Color.KB_WHITE, SpecVisibility.DEFAULT)
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, " ｔ ｒ                                                ", updateEveryTick(localPlayer.getEyePosition() + (100 * (((-0.08 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 3, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.KB_SELECTION if isValueBetween(CURSOR_X_LOCAL, ENTER_TOP_LEFT_X, ENTER_BOTTOM_RIGHT_X) and isValueBetween(CURSOR_Y_LOCAL, ENTER_TOP_LEFT_Y, ENTER_BOTTOM_RIGHT_Y) else Color.KB_WHITE, SpecVisibility.DEFAULT)
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "                                \&left_arrow;", updateEveryTick(localPlayer.getEyePosition() + (100 * (((-0.09 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,  Color.KB_SELECTION if isValueBetween(CURSOR_X_LOCAL, BACKSPACE_TOP_LEFT_X, BACKSPACE_BOTTOM_RIGHT_X) and isValueBetween(CURSOR_Y_LOCAL, BACKSPACE_TOP_LEFT_Y, BACKSPACE_BOTTOM_RIGHT_Y) else Color.KB_WHITE, SpecVisibility.DEFAULT)
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "              ｜￣￣｜                     ｜￣￣｜    ", updateEveryTick(localPlayer.getEyePosition() + (100 * (((-0.1 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.BLACK, SpecVisibility.DEFAULT)
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "  ￣￣￣                                 ￣￣￣    ", updateEveryTick(localPlayer.getEyePosition() + (100 * (((-0.1 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.BLACK, SpecVisibility.DEFAULT)
    createInWorldText(localPlayer if localPlayer.hasKeyboardOpened else null, "  ＿＿＿                                 ＿＿＿    ", updateEveryTick(localPlayer.getEyePosition() + (100 * (((-0.1 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.BLACK, SpecVisibility.DEFAULT)


rule "Create menu cursor":
    createInWorldText(localPlayer.hasKeyboardOpened, "\&top_left_arrow;", 
    updateEveryTick(
        localPlayer.getEyePosition() 
        + (
            100 * (
                max(min(CURSOR_X_LOCAL, BORDER_BOTTOM_RIGHT_X), BORDER_TOP_LEFT_X)
                * (
                    crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))
                )
                + (
                    -1 * max(min(CURSOR_Y_LOCAL, BORDER_BOTTOM_RIGHT_Y), BORDER_TOP_LEFT_Y)
                    * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))
                ) 
                + 3 * localPlayer.getFacingDirection()
            )
        )
    ), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.ORANGE, SpecVisibility.DEFAULT)


rule "Open menu":
    @Event eachPlayer
    @Condition (not eventPlayer.isDummy()) == true
    @Condition eventPlayer.hasKeyboardOpened == true
    
    chase(eventPlayer.additionalXOffset, updateEveryTick(eventPlayer.additionalXOffset + max(0, CURSOR_X - BORDER_BOTTOM_RIGHT_X) - max(0, BORDER_TOP_LEFT_X - CURSOR_X)), rate=9999, ChaseReeval.DESTINATION_AND_RATE)
    chase(eventPlayer.additionalYOffset, updateEveryTick(eventPlayer.additionalYOffset + max(0, CURSOR_Y - BORDER_BOTTOM_RIGHT_Y) - max(0, BORDER_TOP_LEFT_Y - CURSOR_Y)), rate=9999, ChaseReeval.DESTINATION_AND_RATE)

    eventPlayer.startForcingOutlineFor(getAllPlayers(), true, Color.YELLOW, OutlineVisibility.DEFAULT)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
    eventPlayer.setAimSpeed(10)
    eventPlayer.originalFacingDir = eventPlayer.getFacingDirection()
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.disableHeroHUD()

/*
rule "chases are bad":
    @Event eachPlayer
    @Condition eventPlayer.hasKeyboardOpened
    do:
        eventPlayer.additionalXOffset = eventPlayer.additionalXOffset + max(0, CURSOR_X - BORDER_BOTTOM_RIGHT_X) - max(0, BORDER_TOP_LEFT_X - CURSOR_X)
        eventPlayer.additionalYOffset = eventPlayer.additionalYOffset + max(0, CURSOR_Y - BORDER_BOTTOM_RIGHT_Y) - max(0, BORDER_TOP_LEFT_Y - CURSOR_Y)
        wait()
    while RULE_CONDITION*/


rule "Close menu":
    @Event eachPlayer
    @Condition (not eventPlayer.isDummy()) == true
    @Condition (not eventPlayer.hasKeyboardOpened) == true
    
    stopChasingVariable(eventPlayer.additionalXOffset)
    stopChasingVariable(eventPlayer.additionalYOffset)
    eventPlayer.stopForcingOutlineFor(getAllPlayers())
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.setAimSpeed(100)
    eventPlayer.additionalXOffset = 0
    eventPlayer.additionalYOffset = 0
    eventPlayer.setPrimaryFireEnabled(true)
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.enableHeroHud()

def vibrate():
    for eventPlayer.i in range(30):
        eventPlayer.vibrationLeft = random.randint(0, len(vibrationSpaces)-1)
        eventPlayer.vibrationRight = random.randint(0, len(vibrationSpaces)-1)
        wait()
    eventPlayer.vibrationLeft = 0
    eventPlayer.vibrationRight = 0

rule "Press key":
    @Event eachPlayer
    @Condition eventPlayer.hasKeyboardOpened and eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.forceKeyboardValidation == true
    if eventPlayer.forceKeyboardValidation:
        goto validWord
    eventPlayer.selectedKeyboardKey = getKeyboardSelectedKey()
    if eventPlayer.selectedKeyboardKey and not (eventPlayer.kbLayout == KbLayout.AZERTY and eventPlayer.selectedKeyboardKey == 27) and not (eventPlayer.kbLayout != KbLayout.AZERTY and eventPlayer.selectedKeyboardKey == 20):
        if eventPlayer.selectedKeyboardKey == 31:
            if strLen(eventPlayer.currentGuess) == nbLetters:
                if isHardModeEnabled:
                    for eventPlayer.i in range(28):
                        if eventPlayer.kbKeysGuesses[eventPlayer.i] == GuessResult.WRONG_PLACE:
                            if not strContains(eventPlayer.currentGuess, eventPlayer.kbKeys.charAt(eventPlayer.i)):
                                eventPlayer.errorMsg = "Guess must contain '{}'".format(normalAlphabet.charAt(fullwidthAlphabet.strIndex(eventPlayer.kbKeys.charAt(eventPlayer.i))))
                                #eventPlayer.errorMsg = "Guess '{}' must contain '{}'".format(eventPlayer.currentGuess, eventPlayer.kbKeys.charAt(eventPlayer.i))
                                vibrate()
                                eventPlayer.errorMsg = null
                                return
                        if eventPlayer.i%5 == 0:
                            wait()
                    for eventPlayer.i in range(5):
                        if eventPlayer.validLetterBools[eventPlayer.i]:
                            if eventPlayer.currentGuess.charAt(eventPlayer.i) != wordToGuess.charAt(eventPlayer.i):
                                eventPlayer.errorMsg = "{} letter must be '{}'".format(ordinals[eventPlayer.i], normalAlphabet.charAt(fullwidthAlphabet.strIndex(wordToGuess.charAt(eventPlayer.i))))
                                vibrate()
                                eventPlayer.errorMsg = null
                                return

                wait()
                if validWords[fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(0))][fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(1))] != []:
                    for eventPlayer.i in range(len(validWords[fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(0))][fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(1))])):
                        for eventPlayer.j in range(strLen(validWords[fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(0))][fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(1))][eventPlayer.i])/3):
                            if (
                                validWords[fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(0))][fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(1))][eventPlayer.i].charAt(eventPlayer.j*3+0) == compressionAlphabet.charAt(fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(2)))
                                and
                                validWords[fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(0))][fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(1))][eventPlayer.i].charAt(eventPlayer.j*3+1) == compressionAlphabet.charAt(fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(3)))
                                and 
                                validWords[fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(0))][fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(1))][eventPlayer.i].charAt(eventPlayer.j*3+2) == compressionAlphabet.charAt(fullwidthAlphabet.strIndex(eventPlayer.currentGuess.charAt(4)))
                            ):
                                goto validWord
                wait()

                eventPlayer.errorMsg = "Word does not exist"
                vibrate()
                eventPlayer.errorMsg = null
                return

                validWord:
                eventPlayer.forceKeyboardValidation = false
                if eventPlayer.currentGuess == wordToGuess:
                    eventPlayer.hasGuessedWord = true
                for eventPlayer.i in range(nbLetters):
                    if eventPlayer.currentGuess.charAt(eventPlayer.i) == wordToGuess.charAt(eventPlayer.i):
                        eventPlayer.guessResults.append(GuessResult.GOOD)
                        playEffect(eventPlayer, DynamicEffect.BUFF_EXPLOSION_SOUND, null, eventPlayer, 200)
                        eventPlayer.kbKeysGuesses[eventPlayer.kbKeys.strIndex(eventPlayer.currentGuess.charAt(eventPlayer.i))] = GuessResult.GOOD
                        eventPlayer.validLetterBools[eventPlayer.i] = true
                    elif not strContains(wordToGuess, eventPlayer.currentGuess.charAt(eventPlayer.i)):
                        eventPlayer.guessResults.append(GuessResult.BAD)
                        playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, null, eventPlayer, 200)
                        eventPlayer.kbKeysGuesses[eventPlayer.kbKeys.strIndex(eventPlayer.currentGuess.charAt(eventPlayer.i))] = GuessResult.BAD
                    elif (
                        #nb of letter in target word
                        len(wordToGuess.split(eventPlayer.currentGuess.charAt(eventPlayer.i))) - 1
                        -
                        #nb of letter that are green
                        len([idx for idx in [0,1,2,3,4,5,6,7,8].slice(0, nbLetters) if eventPlayer.currentGuess.charAt(eventPlayer.i) == eventPlayer.currentGuess.charAt(idx) and wordToGuess.charAt(idx) == eventPlayer.currentGuess.charAt(idx)])
                        -
                        #nb of letter that are already used and not green
                        len([idx for idx in [0,1,2,3,4,5,6,7,8].slice(0, eventPlayer.i) if eventPlayer.currentGuess.charAt(eventPlayer.i) == eventPlayer.currentGuess.charAt(idx) and wordToGuess.charAt(idx) != eventPlayer.currentGuess.charAt(idx)])

                        > 0
                    ):
                        eventPlayer.guessResults.append(GuessResult.WRONG_PLACE)
                        playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, null, eventPlayer, 200)
                        eventPlayer.kbKeysGuesses[eventPlayer.kbKeys.strIndex(eventPlayer.currentGuess.charAt(eventPlayer.i))] max= GuessResult.WRONG_PLACE
                    else:
                        #double/triple letter with no equivalent
                        eventPlayer.guessResults.append(GuessResult.BAD)
                        playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, null, eventPlayer, 200)
                        eventPlayer.kbKeysGuesses[eventPlayer.kbKeys.strIndex(eventPlayer.currentGuess.charAt(eventPlayer.i))] max= GuessResult.BAD

                    wait(2.5/nbLetters)
                eventPlayer.guesses.append(eventPlayer.currentGuess)
                eventPlayer.currentGuess = ""
            else:
                eventPlayer.errorMsg = "Not enough letters"
                vibrate()
                eventPlayer.errorMsg = null

        elif eventPlayer.selectedKeyboardKey == 32:
            eventPlayer.currentGuess = eventPlayer.currentGuess.substring(0, strLen(eventPlayer.currentGuess)-1)
        elif strLen(eventPlayer.currentGuess) < nbLetters:
            eventPlayer.currentGuess = "{}{}".format(eventPlayer.currentGuess, eventPlayer.kbFirstRow.charAt(eventPlayer.selectedKeyboardKey-1) if eventPlayer.selectedKeyboardKey <= 10 else eventPlayer.kbSecondRow.charAt(eventPlayer.selectedKeyboardKey-11) if eventPlayer.selectedKeyboardKey <= 20 else eventPlayer.kbThirdRow.charAt(eventPlayer.selectedKeyboardKey-21))
