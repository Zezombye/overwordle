#!mainFile "main.opy"
settings {
    "main": {
        "description": "OverWordle "+VERSION+" by Zezombye | Code: "+CODE+"\n\nUses Keyboard by AlaskaWolf and Josbird's Cursor Menu",
        "modeName": "OverWordle "+VERSION
    },
    /*"lobby": {
        "dataCenterPreference": "brazil2",
    },*/
    "gamemodes": {
        "ffa": {
            "enabledMaps": [
                "workshopIsland"
            ],
            "scoreToWin": 5000
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
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
    }
}

