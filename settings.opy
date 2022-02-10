#!mainFile "main.opy"
settings {
    "main": {
        "description": "Play the popular game Wordle in Overwatch!\nEach round, a word is chosen that you must guess.\nBe the first to guess with as few tries as possible to win!\n\nv"+VERSION+" by Zezombye | Code: "+CODE+"\nJoin the discord for feedback: discord.gg/YP544CH\n\nUses AlaskaWolf's keyboard and Josbird's cursor menu",
        "modeName": "OverWordle "+VERSION
    },
    /*"lobby": {
        "dataCenterPreference": "brazil2",
    },*/
    "gamemodes": {
        "ffa": {
            "disabledMaps": [
                "workshopExpanse",
                "workshopExpanseNight",
                "workshopGreenScreen"
            ],
            "scoreToWin": 5000
        },
        "general": {
            "gamemodeStartTrigger": "allSlotsFilled",
            "heroLimit": "off",
            "respawnTime%": 30
        }
    },
    "heroes": {
        "allTeams": {
            "general": {
                "combatUltGen%": 0,
                "passiveUltGen%": 0
            }
        }
    },
    "workshop": {
        "Enable hard mode (revealed hints must be used)": true,
        "Start round with last round's word": true,
    }
}

