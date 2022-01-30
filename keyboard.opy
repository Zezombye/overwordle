#!mainFile "main.opy"

settings {
    "main": {
        "description": "OverWordle BETA by Zezombye\n\nUses Keyboard by AlaskaWolf and Josbird's Cursor Menu",
        "modeName": "OverWordle"
    },
    "gamemodes": {
        "skirmish": {
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

playervar Message 0
playervar OriginalFacingDIR 125
playervar TEXTMAKER 127


rule "▒▒▒▒▒▒▒▒▒▒ Created By AlaskaWolf, Based on Josinbird's cursor menu ▒▒▒▒▒▒▒▒▒▒▒▒":


rule "Toggle menu":
    @Event eachPlayer
    @Condition (not eventPlayer.isDummy()) == true
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition (not eventPlayer.isCommunicatingEmote()) == true
    
    eventPlayer.TEXTMAKER = not eventPlayer.TEXTMAKER


rule "The keyboard itself":
    createInWorldText([player for player in getAllPlayers() if player.TEXTMAKER], "     [{0}{1}]".format(localPlayer.Message, "|" if getTotalTimeElapsed() % 1.1 < 0.5 else "  "), updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.OriginalFacingDIR, angleToDirection(horizontalAngleOfDirection(localPlayer.OriginalFacingDIR), verticalAngleOfDirection(localPlayer.OriginalFacingDIR) - 90))) + ((1.55 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.OriginalFacingDIR), verticalAngleOfDirection(localPlayer.OriginalFacingDIR) - 90))) + 3 * localPlayer.OriginalFacingDIR))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getAllPlayers() if player.TEXTMAKER], "q    w    e    r    t    y    u    i    o    p          ", updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.OriginalFacingDIR, angleToDirection(horizontalAngleOfDirection(localPlayer.OriginalFacingDIR), verticalAngleOfDirection(localPlayer.OriginalFacingDIR) - 90))) + ((0.8 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.OriginalFacingDIR), verticalAngleOfDirection(localPlayer.OriginalFacingDIR) - 90))) + 3 * localPlayer.OriginalFacingDIR))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getAllPlayers() if player.TEXTMAKER], "     a    s    d    f    g    h    j    k    l               ", updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.OriginalFacingDIR, angleToDirection(horizontalAngleOfDirection(localPlayer.OriginalFacingDIR), verticalAngleOfDirection(localPlayer.OriginalFacingDIR) - 90))) + ((0.5 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.OriginalFacingDIR), verticalAngleOfDirection(localPlayer.OriginalFacingDIR) - 90))) + 3 * localPlayer.OriginalFacingDIR))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getAllPlayers() if player.TEXTMAKER], "                  z    x    c    v    b    n    m                              ", updateEveryTick(localPlayer.getEyePosition() + (100 * (-0.14 * (crossProduct(localPlayer.OriginalFacingDIR, angleToDirection(horizontalAngleOfDirection(localPlayer.OriginalFacingDIR), verticalAngleOfDirection(localPlayer.OriginalFacingDIR) - 90))) + ((0.2 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.OriginalFacingDIR), verticalAngleOfDirection(localPlayer.OriginalFacingDIR) - 90))) + 3 * localPlayer.OriginalFacingDIR))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getAllPlayers() if player.TEXTMAKER], "    [ Enter ]          [    ←    ]", updateEveryTick(localPlayer.getEyePosition() + (100 * (0.6 * (crossProduct(localPlayer.OriginalFacingDIR, angleToDirection(horizontalAngleOfDirection(localPlayer.OriginalFacingDIR), verticalAngleOfDirection(localPlayer.OriginalFacingDIR) - 90))) + ((-0.1 + -1.7) * (angleToDirection(horizontalAngleOfDirection(localPlayer.OriginalFacingDIR), verticalAngleOfDirection(localPlayer.OriginalFacingDIR) - 90))) + 3 * localPlayer.OriginalFacingDIR))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)


rule "Create menu cursor":
    createInWorldText([player for player in getAllPlayers() if player.TEXTMAKER], "▲", updateEveryTick(localPlayer.getEyePosition() + (100 * (angleDifference(horizontalAngleOfDirection(localPlayer.getFacingDirection()), horizontalAngleOfDirection(localPlayer.OriginalFacingDIR)) * (crossProduct(localPlayer.getFacingDirection(), angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + ((angleDifference(verticalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.OriginalFacingDIR)) - 0.2) * (angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90))) + 3 * localPlayer.getFacingDirection()))), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR, Color.ORANGE, SpecVisibility.DEFAULT)


rule "Open menu":
    @Event eachPlayer
    @Condition (not eventPlayer.isDummy()) == true
    @Condition eventPlayer.TEXTMAKER == true
    
    eventPlayer.setAimSpeed(10)
    eventPlayer.OriginalFacingDIR = eventPlayer.getFacingDirection()
    eventPlayer.startCamera(eventPlayer.getEyePosition() + eventPlayer.OriginalFacingDIR * 2, eventPlayer.getEyePosition() + eventPlayer.OriginalFacingDIR * 999, 800)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.disableHeroHUD()
    eventPlayer.disableGamemodeHud()
    #eventPlayer.Message = ""


rule "Close menu":
    @Event eachPlayer
    @Condition (not eventPlayer.isDummy()) == true
    @Condition (not eventPlayer.TEXTMAKER) == true
    
    eventPlayer.stopCamera()
    eventPlayer.setAimSpeed(100)
    eventPlayer.setPrimaryFireEnabled(true)
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.enableHeroHud()
    eventPlayer.enableGamemodeHud()


rule "Cursor bounds":
    @Event eachPlayer
    @Condition eventPlayer.TEXTMAKER == true
    @Condition (abs(angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR))) > 6.2 / 2 + 0.05 or abs(angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR))) > 3.6 / 2 + 0.05) == true
    
    eventPlayer.setFacing(angleToDirection(min(max(horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR) - angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR)), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR) - 6.2 / 2), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR) + 6.2 / 2), min(max(verticalAngleOfDirection(eventPlayer.OriginalFacingDIR) - angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR)), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR) - 3.6 / 2), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR) + 3.6 / 2)), Relativity.TO_WORLD)
    wait()
    if RULE_CONDITION:
        goto RULE_START


/*
rule "detect (debug) *":
    @Event eachPlayer
    #@Condition eventPlayer.TEXTMAKER == true
    #@Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    
    #detect 'a' test
    #if abs(angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - -1) <= 3 / 2 and abs(angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - 0.4) <= 3 / 2:
    hudHeader([player for player in getAllPlayers() if abs(angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - XpositionARRAY[TestIndex]) <= CharSize / 2 and abs(angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - YpositionARRAY[TestIndex]) <= CharSize / 2], "Detected AREA!!!", HudPosition.LEFT, 0, Color.RED, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader([player for player in getAllPlayers() if abs(angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - 0) <= 1.1 / 2 and abs(angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - -1.499) <= 0.39 / 2], "Detected SPACEBAR!!!", HudPosition.LEFT, 0, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader([player for player in getAllPlayers() if abs(angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - 1.35) <= 1.08 / 2 and abs(angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - -1.499) <= 0.39 / 2], "Detected bksp!!!", HudPosition.LEFT, 0, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
*/

rule "▒▒▒▒▒▒  Set Globals (Letters to type, key positions)":
    CHAR_ARRAY = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "!", "@", "-", "+", "=", "_", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "(", ")", "A", "S", "D", "F", "G", "H", "J", "K", "L", ":", "'", "\"", "Z", "X", "C", "V", "B", "N", "M", "<", ">", ",", ".", "/", "?"]
    XpositionARRAY = [-2.16, -1.872, -1.572, -1.272, -0.97, -0.665, -0.36, -0.04, 0.277, 0.584, 0.868, 1.168, 1.468, 1.72, 2.02, 2.29, -1.75, -1.4, -1.074, -0.783, -0.49, -0.2, 0.115, 0.4, 0.692, 0.999, 1.275, 1.53, -1.59, -1.29, -0.99, -0.69, -0.39, -0.05, 0.25, 0.55, 0.85, 1.108, 1.35, 1.59, -1.46, -1.16, -0.86, -0.54, -0.24, 0.08, 0.428, 0.745, 1.024, 1.317, 1.54, 1.79, 2.088]
    YpositionARRAY = [-0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.325, -0.61, -0.61, -0.61, -0.61, -0.61, -0.61, -0.61, -0.61, -0.61, -0.61, -0.61, -0.61, -0.91, -0.91, -0.91, -0.91, -0.91, -0.91, -0.91, -0.91, -0.91, -0.91, -0.91, -0.91, -1.19, -1.19, -1.19, -1.19, -1.17, -1.17, -1.17, -1.19, -1.19, -1.19, -1.19, -1.19, -1.19]
    #TestIndex = 40
    #0.32 DONT CHANGE
    CharSize = 0.32


/*
rule "Test index debug text*":
    hudHeader(getAllPlayers(), "testing index: [{0}] [{1}]".format(TestIndex, CHAR_ARRAY[TestIndex]), HudPosition.RIGHT, 0, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
*/

/*
rule "Test index increase*":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    
    TestIndex += 1
*/

/*
rule "Test index decrease*":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    
    TestIndex -= 1
*/

/*
rule "vvvv (you can a loop to any these) vvvv *":
*/

rule "TYPE IT    [ A ]":
    @Event eachPlayer
    @Condition eventPlayer.TEXTMAKER == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition (len([_ for _, i in XpositionARRAY if abs(angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - XpositionARRAY[i]) <= CharSize / 2 and abs(angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - YpositionARRAY[i]) <= CharSize / 2])) > null
    
    eventPlayer.Message = "{0}{1}".format(eventPlayer.Message, CHAR_ARRAY[XpositionARRAY.index((sorted([_ for _, i in XpositionARRAY if abs(angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - XpositionARRAY[i]) <= CharSize / 2 and abs(angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - YpositionARRAY[i]) <= CharSize / 2], lambda _, i: abs(angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - XpositionARRAY[i])))[0])])


rule "TYPE IT SPACE  [______]":
    @Event eachPlayer
    @Condition eventPlayer.TEXTMAKER == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition abs(angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - 0) <= 1.1 / 2
    @Condition abs(angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - -1.499) <= 0.39 / 2
    
    eventPlayer.Message = "{0}{1}".format(eventPlayer.Message, " ")


rule "UN-TYPE IT    [_<--BKSP_]":
    @Event eachPlayer
    @Condition eventPlayer.TEXTMAKER == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition abs(angleDifference(horizontalAngleOfDirection(eventPlayer.getFacingDirection()), horizontalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - 1.3) <= 1 / 2
    @Condition abs(angleDifference(verticalAngleOfDirection(eventPlayer.getFacingDirection()), verticalAngleOfDirection(eventPlayer.OriginalFacingDIR)) - -1.499) <= 0.39 / 2
    
    eventPlayer.Message = eventPlayer.Message.substring(0, strLen(eventPlayer.Message) - 1)


