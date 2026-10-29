"""
This file contains variables used in verification of CB013660.

:copyright: Nokia Networks
:author:   Kamil Bielecki <kamil.bielecki@nokia.com>
:maintainer:   Kamil Bielecki <kamil.bielecki@nokia.com>
"""

simultaneous_activation = [
    {
        "distName": "MRBTS-{}/MNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ruPhaseSwActivationResetPolicy",
                "value": "Simultaneous",
                "operation": "update",
            }
        ],
    }
]

sequential_activation = [
    {
        "distName": "MRBTS-{}/MNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ruPhaseSwActivationResetPolicy",
                "value": "Sequential",
                "operation": "update",
            }
        ],
    }
]

user_defined_activation = [
    {
        "distName": "MRBTS-{}/MNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ruPhaseSwActivationResetPolicy",
                "value": "User configuration",
                "operation": "update",
            }
        ],
    },
    {
        "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-1",
        "operation": "update",
        "parameters": [
            {"parameterName": "ruPhaseResetOrder", "value": "1", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-2",
        "operation": "update",
        "parameters": [
            {"parameterName": "ruPhaseResetOrder", "value": "2", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-3",
        "operation": "update",
        "parameters": [
            {"parameterName": "ruPhaseResetOrder", "value": "3", "operation": "update"}
        ],
    },
]

ru_only_upgrade = [
    {
        "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-1",
        "operation": "update",
        "parameters": [
            {"parameterName": "upgradePhase", "value": "RU", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-2",
        "operation": "update",
        "parameters": [
            {"parameterName": "upgradePhase", "value": "RU", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-3",
        "operation": "update",
        "parameters": [
            {"parameterName": "upgradePhase", "value": "RU", "operation": "update"}
        ],
    },
]

du_upgrade = [
    {
        "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-1",
        "operation": "update",
        "parameters": [
            {"parameterName": "upgradePhase", "value": "RU", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-2",
        "operation": "update",
        "parameters": [
            {"parameterName": "upgradePhase", "value": "DU", "operation": "update"}
        ],
    },
    {
        "distName": "MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "upgradePhase",
                "value": "No upgrade",
                "operation": "update",
            }
        ],
    },
    {
        "distName": "MRBTS-{}/MNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ruPhaseSwActivationResetPolicy",
                "value": "Simultaneous",
                "operation": "update",
            }
        ],
    },
]
