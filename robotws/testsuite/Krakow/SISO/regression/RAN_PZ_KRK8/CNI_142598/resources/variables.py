feature_enable = [
    {
        "distName": "MRBTS-75066/MNL-1/MNLENT-1/FEATCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actIntelligentSynceAssHoTime",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": "MRBTS-75066/MNL-1/MNLENT-1/SYNC-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "synceAssistedHoldoverMode",
                "operation": "update",
                "value": "IntelligentHoldover"
            }
        ]
    }
]

feature_disable = [
    {
        "distName": "MRBTS-75066/MNL-1/MNLENT-1/FEATCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actIntelligentSynceAssHoTime",
                "operation": "update",
                "value": "false"
            }
        ]
    },
    {
        "distName": "MRBTS-75066/MNL-1/MNLENT-1/SYNC-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "synceAssistedHoldoverMode",
                "operation": "delete",
                "value": "IntelligentHoldover"
            }
        ]
    }
]
