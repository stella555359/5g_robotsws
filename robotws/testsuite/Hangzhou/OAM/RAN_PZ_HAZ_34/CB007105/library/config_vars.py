DICT__param_config = {
    "A": {
        "parameters": {
            "dlMimoMode": {
                "value": "2x2 Open Loop Spatial Multiplexing",
                "distname": "NRCELL",
                "name": "Downlink MIMO Mode"
            },
            "nrCellType": {
                "value": "2DL2UL",
                "distname": "NRCELL",
                "name": "NR Cell type"
            },
            "basicBeamSet": {
                "value": "beamSet_1",
                "distname": "NRCELL",
                "name": "Basic Beam Set"
            },
            "numberOfTransmittedSsBlocks": {
                "value": "1 beam",
                "distname": "NRCELLGRP",
                "name": "Number of transmitted Synchronization Signal Blocks"
            }
        },
        "objects": [
            {"action": "add", "classname": "com.nokia.srbts.mnl:CHANNEL",
             "copyfrom": "MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1"},
            {"action": "add", "classname": "com.nokia.srbts.mnl:CHANNEL",
             "copyfrom": "MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1"},
        ]
    },
    "C": {
        "parameters": {
            "dlMimoMode": {
                "value": "4x4 or 4x2 Open Loop Spatial Multiplexing",
                "distname": "NRCELL",
                "name": "Downlink MIMO Mode"
            },
            "nrCellType": {
                "value": "4DL2UL",
                "distname": "NRCELL",
                "name": "NR Cell type"
            },
            "basicBeamSet": {
                "value": "beamSet_2",
                "distname": "NRCELL",
                "name": "Basic Beam Set"
            },
            "numberOfTransmittedSsBlocks": {
                "value": "2 beams",
                "distname": "NRCELLGRP",
                "name": "Number of transmitted Synchronization Signal Blocks"
            }
        },
        "objects": [
            {"action": "remove", "name": "CHANNEL-5"},
            {"action": "remove", "name": "CHANNEL-6"},
        ]
    }
}

DICT__L3CALL_CELL = {
    "832": "1"
}
