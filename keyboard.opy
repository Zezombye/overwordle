#!mainFile "main.opy"

settings {
    "main": {
        "description": "OverWordle BETA by Zezombye\n\nUses Keyboard by AlaskaWolf and Josbird's Cursor Menu",
        "modeName": "OverWordle"
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps": [
                "workshopIsland"
            ]
        },
        "general": {
            "enableRandomHeroes": false,
            "respawnTime%": 30,
        }
    },
}

#Global variables

globalvar CHAR_ARRAY 0
globalvar XpositionARRAY 1
globalvar YpositionARRAY 2
globalvar TestIndex 3
globalvar CharSize 4


#Player variables

playervar originalFacingDir
playervar hasKeyboardOpened

playervar kbFirstRow = w"QWERTYUIOP"
playervar kbSecondRow = w"ASDFGHJKLM"
playervar kbThirdRow = w"ZXCVBNM"

#!define SENSIVITY 0.2
#!define KEYBOARD_INDENT 0.06
#!define KEYBOARD_TOP_LEFT_X -1.42
#!define KEYBOARD_TOP_LEFT_Y 0.84
#!define HORIZONTAL_KEY_DISTANCE 0.27111111
#!define VERTICAL_KEY_DISTANCE 0.3
#!define KEY_SIDE_LENGTH 0.24
#!define CURSOR_X ((angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.originalFacingDir)) * SENSIVITY) - eventPlayer.additionalXOffset)
#!define CURSOR_Y ((-angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.originalFacingDir)) * SENSIVITY) - eventPlayer.additionalYOffset)

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

playervar selectedKeyboardKey
playervar additionalXOffset = 0
playervar additionalYOffset = 0

rule "▒▒▒▒▒▒▒▒▒▒ Created By AlaskaWolf, Based on Josinbird's cursor menu ▒▒▒▒▒▒▒▒▒▒▒▒":


rule "debug hud":
    @Event eachPlayer

    print("x: {}, y: {}".format(CURSOR_X, CURSOR_Y))
    print("Letter: {}".format(getKeyboardSelectedKey()))
    print("currentGuess: |{}|".format(hostPlayer.currentGuess))
#区Γ┌┏

rule "Toggle keyboard":
    @Event eachPlayer
    @Condition (not eventPlayer.isDummy()) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition (not eventPlayer.isCommunicatingEmote()) == true
    
    eventPlayer.hasKeyboardOpened = not eventPlayer.hasKeyboardOpened


rule "The keyboard itself":
    @Event eachPlayer

    chase(eventPlayer.selectedKeyboardKey, getKeyboardSelectedKey(), rate=999, ChaseReeval.DESTINATION_AND_RATE)

    #First row
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, " {} {} {} {} {} {} {} {} {} {} ".format(
        eventPlayer.kbFirstRow.charAt(0),
        eventPlayer.kbFirstRow.charAt(1),
        eventPlayer.kbFirstRow.charAt(2),
        eventPlayer.kbFirstRow.charAt(3),
        eventPlayer.kbFirstRow.charAt(4),
        eventPlayer.kbFirstRow.charAt(5),
        eventPlayer.kbFirstRow.charAt(6),
        eventPlayer.kbFirstRow.charAt(7),
        eventPlayer.kbFirstRow.charAt(8),
        eventPlayer.kbFirstRow.charAt(9)
    ), updateEveryTick(eventPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(eventPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + ((0.8 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, {
        null: "",
        1: "[{}]　 　 　 　 　 　 　 　 　 ".format(eventPlayer.kbFirstRow.charAt(0)),
        2: " 　[{}]　 　 　 　 　 　 　 　 ".format(eventPlayer.kbFirstRow.charAt(1)),
        3: " 　 　[{}]　 　 　 　 　 　 　 ".format(eventPlayer.kbFirstRow.charAt(2)),
        4: " 　 　 　[{}]　 　 　 　 　 　 ".format(eventPlayer.kbFirstRow.charAt(3)),
        5: " 　 　 　 　[{}]　 　 　 　 　 ".format(eventPlayer.kbFirstRow.charAt(4)),
        6: " 　 　 　 　 　[{}]　 　 　 　 ".format(eventPlayer.kbFirstRow.charAt(5)),
        7: " 　 　 　 　 　 　[{}]　 　 　 ".format(eventPlayer.kbFirstRow.charAt(6)),
        8: " 　 　 　 　 　 　 　[{}]　 　 ".format(eventPlayer.kbFirstRow.charAt(7)),
        9: " 　 　 　 　 　 　 　 　[{}]　 ".format(eventPlayer.kbFirstRow.charAt(8)),
        10: " 　 　 　 　 　 　 　 　 　[{}]".format(eventPlayer.kbFirstRow.charAt(9)),
    }[eventPlayer.selectedKeyboardKey]
    , updateEveryTick(eventPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(eventPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + ((0.8 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN, SpecVisibility.DEFAULT)

    #Second row
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, "   {} {} {} {} {} {} {} {} {} {} ".format(
        eventPlayer.kbSecondRow.charAt(0),
        eventPlayer.kbSecondRow.charAt(1),
        eventPlayer.kbSecondRow.charAt(2),
        eventPlayer.kbSecondRow.charAt(3),
        eventPlayer.kbSecondRow.charAt(4),
        eventPlayer.kbSecondRow.charAt(5),
        eventPlayer.kbSecondRow.charAt(6),
        eventPlayer.kbSecondRow.charAt(7),
        eventPlayer.kbSecondRow.charAt(8),
        eventPlayer.kbSecondRow.charAt(9)
    ), updateEveryTick(eventPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(eventPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + ((0.5 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, {
        null: "",
        11: "  [{}]　 　 　 　 　 　 　 　 　 ".format(eventPlayer.kbSecondRow.charAt(0)),
        12: "   　[{}]　 　 　 　 　 　 　 　 ".format(eventPlayer.kbSecondRow.charAt(1)),
        13: "   　 　[{}]　 　 　 　 　 　 　 ".format(eventPlayer.kbSecondRow.charAt(2)),
        14: "   　 　 　[{}]　 　 　 　 　 　 ".format(eventPlayer.kbSecondRow.charAt(3)),
        15: "   　 　 　 　[{}]　 　 　 　 　 ".format(eventPlayer.kbSecondRow.charAt(4)),
        16: "   　 　 　 　 　[{}]　 　 　 　 ".format(eventPlayer.kbSecondRow.charAt(5)),
        17: "   　 　 　 　 　 　[{}]　 　 　 ".format(eventPlayer.kbSecondRow.charAt(6)),
        18: "   　 　 　 　 　 　 　[{}]　 　 ".format(eventPlayer.kbSecondRow.charAt(7)),
        19: "   　 　 　 　 　 　 　 　[{}]　 ".format(eventPlayer.kbSecondRow.charAt(8)),
        20: "   　 　 　 　 　 　 　 　 　[{}]".format(eventPlayer.kbSecondRow.charAt(9)),
    }[eventPlayer.selectedKeyboardKey]
    , updateEveryTick(eventPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(eventPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + ((0.5 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN, SpecVisibility.DEFAULT)

    #Third row
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, "     {} {} {} {} {} {} {} \&fullwidth_space; \&fullwidth_space; \&fullwidth_space; ".format(
        eventPlayer.kbThirdRow.charAt(0),
        eventPlayer.kbThirdRow.charAt(1),
        eventPlayer.kbThirdRow.charAt(2),
        eventPlayer.kbThirdRow.charAt(3),
        eventPlayer.kbThirdRow.charAt(4),
        eventPlayer.kbThirdRow.charAt(5),
        eventPlayer.kbThirdRow.charAt(6)
    ), updateEveryTick(eventPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(eventPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + ((0.2 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText(eventPlayer, {
        null: "",
        21: "    [{}]　 　 　 　 　 　 　 　 　 ".format(eventPlayer.kbThirdRow.charAt(0)),
        22: "     　[{}]　 　 　 　 　 　 　 　 ".format(eventPlayer.kbThirdRow.charAt(1)),
        23: "     　 　[{}]　 　 　 　 　 　 　 ".format(eventPlayer.kbThirdRow.charAt(2)),
        24: "     　 　 　[{}]　 　 　 　 　 　 ".format(eventPlayer.kbThirdRow.charAt(3)),
        25: "     　 　 　 　[{}]　 　 　 　 　 ".format(eventPlayer.kbThirdRow.charAt(4)),
        26: "     　 　 　 　 　[{}]　 　 　 　 ".format(eventPlayer.kbThirdRow.charAt(5)),
        27: "     　 　 　 　 　 　[{}]　 　 　 ".format(eventPlayer.kbThirdRow.charAt(6)),
    }[eventPlayer.selectedKeyboardKey]
    , updateEveryTick(eventPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(eventPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + ((0.2 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.GREEN, SpecVisibility.DEFAULT)

    #Enter buttons
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, "Ｅ \&fullwidth_space; \&fullwidth_space;                                                   ", updateEveryTick(eventPlayer.getEyePosition() + (100 * (((-0.08 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 3, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.WHITE if eventPlayer.selectedKeyboardKey != 31 else Color.GREEN, SpecVisibility.DEFAULT)
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, " ｎ ｅ                                                    ", updateEveryTick(eventPlayer.getEyePosition() + (100 * (((-0.08 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 3, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,  Color.WHITE if eventPlayer.selectedKeyboardKey != 31 else Color.GREEN, SpecVisibility.DEFAULT)
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, " ｔ ｒ                                                ", updateEveryTick(eventPlayer.getEyePosition() + (100 * (((-0.08 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 3, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,  Color.WHITE if eventPlayer.selectedKeyboardKey != 31 else Color.GREEN, SpecVisibility.DEFAULT)
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, "                                \&left_arrow;", updateEveryTick(eventPlayer.getEyePosition() + (100 * (((-0.09 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,  Color.WHITE if eventPlayer.selectedKeyboardKey != 32 else Color.GREEN, SpecVisibility.DEFAULT)
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, "              ｜￣￣｜                     ｜￣￣｜    ", updateEveryTick(eventPlayer.getEyePosition() + (100 * (((-0.1 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.BLACK, SpecVisibility.DEFAULT)
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, "  ￣￣￣                                 ￣￣￣    ", updateEveryTick(eventPlayer.getEyePosition() + (100 * (((-0.1 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.BLACK, SpecVisibility.DEFAULT)
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, "  ＿＿＿                                 ＿＿＿    ", updateEveryTick(eventPlayer.getEyePosition() + (100 * (((-0.1 + -1.7) * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))) + 3 * eventPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.BLACK, SpecVisibility.DEFAULT)


rule "Create menu cursor":
    @Event eachPlayer
    createInWorldText(eventPlayer if eventPlayer.hasKeyboardOpened else null, "\&top_left_arrow;", 
    updateEveryTick(
        eventPlayer.getEyePosition() 
        + (
            100 * (
                max(min(CURSOR_X, BORDER_BOTTOM_RIGHT_X), BORDER_TOP_LEFT_X)
                * (
                    crossProduct(eventPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))
                )
                + (
                    -1 * max(min(CURSOR_Y, BORDER_BOTTOM_RIGHT_Y), BORDER_TOP_LEFT_Y)
                    * (angleToDirection(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.getFacingDirection()) - 90))
                ) 
                + 3 * eventPlayer.getFacingDirection()
            )
        )
    ), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.ORANGE, SpecVisibility.DEFAULT)


rule "Open menu":
    @Event eachPlayer
    @Condition (not eventPlayer.isDummy()) == true
    @Condition eventPlayer.hasKeyboardOpened == true
    
    eventPlayer.setAimSpeed(10)
    eventPlayer.originalFacingDir = eventPlayer.getFacingDirection()
    chase(eventPlayer.additionalXOffset, eventPlayer.additionalXOffset + max(0, CURSOR_X - BORDER_BOTTOM_RIGHT_X) - max(0, BORDER_TOP_LEFT_X - CURSOR_X), rate=99999, ChaseReeval.DESTINATION_AND_RATE)
    chase(eventPlayer.additionalYOffset, eventPlayer.additionalYOffset + max(0, CURSOR_Y - BORDER_BOTTOM_RIGHT_Y) - max(0, BORDER_TOP_LEFT_Y - CURSOR_Y), rate=99999, ChaseReeval.DESTINATION_AND_RATE)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.disableHeroHUD()
    #eventPlayer.disableGamemodeHud()
    #eventPlayer.Message = ""


rule "Close menu":
    @Event eachPlayer
    @Condition (not eventPlayer.isDummy()) == true
    @Condition (not eventPlayer.hasKeyboardOpened) == true
    
    #eventPlayer.stopCamera()
    eventPlayer.setAimSpeed(100)
    stopChasingVariable(eventPlayer.additionalXOffset)
    stopChasingVariable(eventPlayer.additionalYOffset)
    eventPlayer.additionalXOffset = 0
    eventPlayer.additionalYOffset = 0
    eventPlayer.setPrimaryFireEnabled(true)
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.enableHeroHud()
    #eventPlayer.enableGamemodeHud()

rule "Press key":
    @Event eachPlayer
    @Condition eventPlayer.hasKeyboardOpened
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    if eventPlayer.selectedKeyboardKey:
        if eventPlayer.selectedKeyboardKey == 31:
            if strLen(eventPlayer.currentGuess) == nbLetters:
                eventPlayer.guesses.append(eventPlayer.currentGuess)
                eventPlayer.currentGuess = ""
        elif eventPlayer.selectedKeyboardKey == 32:
            eventPlayer.currentGuess = eventPlayer.currentGuess.substring(0, strLen(eventPlayer.currentGuess)-1)
        elif strLen(eventPlayer.currentGuess) < nbLetters:
            eventPlayer.currentGuess = "{}{}".format(eventPlayer.currentGuess, eventPlayer.kbFirstRow.charAt(eventPlayer.selectedKeyboardKey-1) if eventPlayer.selectedKeyboardKey <= 10 else eventPlayer.kbSecondRow.charAt(eventPlayer.selectedKeyboardKey-11) if eventPlayer.selectedKeyboardKey <= 20 else eventPlayer.kbThirdRow.charAt(eventPlayer.selectedKeyboardKey-21))
