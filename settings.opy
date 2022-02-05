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
                "damageDealt%": 10,
                "damageReceived%": 10,
                "healingDealt%": 500,
                "healingReceived%": 500,
                "health%": 500,
                "combatUltGen%": 0,
                "passiveUltGen%": 0
            }
        }
    }
}

