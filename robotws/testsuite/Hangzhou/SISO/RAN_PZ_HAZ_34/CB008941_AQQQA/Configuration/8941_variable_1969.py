from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

MRBTS_ID = tl.gnbs[0].instance_id
NRBTS_ID = tl.gnbs[0].global_bts_id
MRBTS = "MRBTS-" + str(MRBTS_ID)
NRBTS = "NRBTS-" + str(NRBTS_ID)
dcap_ip = tl.gnbs[0].dcap.connection_details.addr
dcap_port = tl.gnbs[0].dcap.connection_details.port


delta_8941 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCELL-311",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "chBw",
                "value": "100MHz",
                "operation": "update"
            },
            {
                "parameterName": "pucchModeSelect",
                "value": "longPucch",
                "operation": "update"
            },
            {
                "parameterName": "cellBwpList",
                "value": [
                  {
                    "bwpDN": MRBTS + "/" + NRBTS + "/BWP_PROFILE-6",
                    "cellBwpId": 0
                  },
                  {
                    "bwpDN": MRBTS + "/" + NRBTS + "/BWP_PROFILE-67",
                    "cellBwpId": 1
                  }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actFdmScheduling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actFdmEnhancedScheduling",
                "value": "true",
                "operation": "update"
            }
        ]
    }
]

delta_8941_001 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCELL-311",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "chBw",
                "value": "100MHz",
                "operation": "update"
            },
            {
                "parameterName": "pucchModeSelect",
                "value": "longPucch",
                "operation": "update"
            },
            {
                "parameterName": "actLongPucchPhase2",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "cellBwpList",
                "value": [
                  {
                    "bwpDN": MRBTS + "/" + NRBTS + "/BWP_PROFILE-6",
                    "cellBwpId": 0
                  },
                  {
                    "bwpDN": MRBTS + "/" + NRBTS + "/BWP_PROFILE-67",
                    "cellBwpId": 1
                  }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actFdmScheduling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actFdmEnhancedScheduling",
                "value": "true",
                "operation": "update"
            }
        ]
    }
]

delta_8941_002 = [
    {
        "distName": MRBTS + "/" + NRBTS + "/NRCELL-311",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "chBw",
                "value": "100MHz",
                "operation": "update"
            },
            {
                "parameterName": "pucchModeSelect",
                "value": "longPucch",
                "operation": "update"
            },
            {
                "parameterName": "actLongPucchPhase2",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "cellBwpList",
                "value": [{
                    "bwpDN": MRBTS + "/" + NRBTS + "/BWP_PROFILE-6",
                    "cellBwpId": 0
                  },
                  {
                    "bwpDN": MRBTS + "/" + NRBTS + "/BWP_PROFILE-67",
                    "cellBwpId": 1
                  }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": MRBTS + "/" + NRBTS,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actFdmScheduling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actFdmEnhancedScheduling",
                "value": "true",
                "operation": "update"
            }
        ]
    }
]
