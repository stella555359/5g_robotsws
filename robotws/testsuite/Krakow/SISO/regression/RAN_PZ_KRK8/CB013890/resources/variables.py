mrbts_id = '75066'

delta_pmax_31 = [
    {
        "distName": "MRBTS-{}/NRBTS-{}/NRCELL-0/NRCBSDCELL-0",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "configSetForVariChBw",
                "operation": "update",
                "value": [
                    {
                        "desiredPmax": "310",
                        "bwpDN1": f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/BWP_PROFILE-4",
                        "bwpDN2": f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/BWP_PROFILE-77",
                        "chBw": "10MHz",
                        "cSRS": "7",
                        "type0CoresetConfigurationIndex": "7",
                        "reqMinNumPuschPrb": "19",
                        "msg1FrequencyStart": "6",
                    }
                ],
            }
        ],
    },
    {
        "distName": "MRBTS-{}/NRBTS-{}/NRCELL-2/NRCBSDCELL-0",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "configSetForVariChBw",
                "operation": "update",
                "value": [
                    {
                        "desiredPmax": "310",
                        "bwpDN1": f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/BWP_PROFILE-4",
                        "bwpDN2": f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/BWP_PROFILE-77",
                        "chBw": "10MHz",
                        "cSRS": "7",
                        "type0CoresetConfigurationIndex": "6",
                        "reqMinNumPuschPrb": "19",
                        "msg1FrequencyStart": "6",
                    }
                ],
            }
        ],
    },
]

delta_pmax_37 = [
    {
        "distName": "MRBTS-{}/NRBTS-{}/NRCELL-0/NRCBSDCELL-0",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "configSetForVariChBw",
                "operation": "update",
                "value": [
                    {
                        "desiredPmax": "364",
                        "bwpDN1": f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/BWP_PROFILE-4",
                        "bwpDN2": f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/BWP_PROFILE-77",
                        "chBw": "10MHz",
                        "cSRS": "7",
                        "type0CoresetConfigurationIndex": "7",
                        "reqMinNumPuschPrb": "19",
                        "msg1FrequencyStart": "6",
                    }
                ],
            }
        ],
    },
    {
        "distName": "MRBTS-{}/NRBTS-{}/NRCELL-2/NRCBSDCELL-0",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "configSetForVariChBw",
                "operation": "update",
                "value": [
                    {
                        "desiredPmax": "370",
                        "bwpDN1": f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/BWP_PROFILE-4",
                        "bwpDN2": f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/BWP_PROFILE-77",
                        "chBw": "10MHz",
                        "cSRS": "7",
                        "type0CoresetConfigurationIndex": "6",
                        "reqMinNumPuschPrb": "19",
                        "msg1FrequencyStart": "6",
                    }
                ],
            }
        ],
    },
]
