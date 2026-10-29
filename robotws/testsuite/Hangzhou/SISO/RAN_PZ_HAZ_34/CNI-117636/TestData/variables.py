"""Variables for CNI-117636 test cases."""

# MIMO muting parameters dictionary
muting_parameters_dict = {
    "nrbts": [
        {"dist_name": "None", "parameter": "actNrLBmMimoRTXPowerSaving", "value": "false"},
        {"dist_name": "None", "parameter": "actNrExtCellSOMethod", "value": "false"},
        {"dist_name": "None", "parameter": "actNrMixedSOMethod", "value": "false"}
    ],
    "cellgrp": [
        {"dist_name": "None", "parameter": "lbpsSOMethod", "value": "cell switch off"}
    ]
}

# Fault parameters dictionary with beamset configurations
fault_parameters_dict = {
    "beamset_list": ["beamSet_2", "beamSet_5_3", "beamSet_3_3_2_square"],

    "beamSet_2": {
        "trigger_fault": {
            "nrcell": [
                {
                    "dist_name": "None",
                    "parameter": "beamSet",
                    "value": [{"basicBeamSet": "beamSet_2", "tiltOffset": "6"}]
                }
            ],
            "nrcellgrp": [
                {
                    "dist_name": "None",
                    "parameter": "numberOfTransmittedSsBlocks",
                    "value": "2 beams"
                }
            ]
        },
        "clear_fault": {
            "nrcell": [
                {
                    "dist_name": "None",
                    "parameter": "beamSet",
                    "value": [{"basicBeamSet": "beamSet_2", "tiltOffset": "0"}]
                }
            ]
        }
    },

    "beamSet_5_3": {
        "trigger_fault": {
            "nrcell": [
                {
                    "dist_name": "None",
                    "parameter": "beamSet",
                    "value": [{"basicBeamSet": "beamSet_5_3", "tiltOffset": "5"}]
                }
            ],
            "nrcellgrp": [
                {
                    "dist_name": "None",
                    "parameter": "numberOfTransmittedSsBlocks",
                    "value": "8 beams"
                }
            ]
        },
        "clear_fault": {
            "nrcell": [
                {
                    "dist_name": "None",
                    "parameter": "beamSet",
                    "value": [{"basicBeamSet": "beamSet_5_3", "tiltOffset": "0"}]
                }
            ]
        }
    },

    "beamSet_3_3_2_square": {
        "trigger_fault": {
            "nrcell": [
                {
                    "dist_name": "None",
                    "parameter": "beamSet",
                    "value": [{"basicBeamSet": "beamSet_3_3_2_square", "tiltOffset": "1"}]
                }
            ],
            "nrcellgrp": [
                {
                    "dist_name": "None",
                    "parameter": "numberOfTransmittedSsBlocks",
                    "value": "8 beams"
                }
            ]
        },
        "clear_fault": {
            "nrcell": [
                {
                    "dist_name": "None",
                    "parameter": "beamSet",
                    "value": [{"basicBeamSet": "beamSet_3_3_2_square", "tiltOffset": "0"}]
                }
            ]
        }
    }
}
