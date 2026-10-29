# -*- coding: utf-8 -*-
"""
Author: Grzegorz Kaczor
"""

RRC_RECONF_6_SCELL_DL_ATT = "M55118C02010"
RRC_RECONF_6_SCELL_DL_SUCC = "M55118C03010"

beams_data = [
    {
        "beam_id": 8,
        "pm_counter": "M55306C00009",
        "unmuted_value": 4294967039
    },
    {
        "beam_id": 9,
        "pm_counter": "M55306C00010",
        "unmuted_value": 4294966783
    },
    {
        "beam_id": 10,
        "pm_counter": "M55306C00011",
        "unmuted_value": 4294966271
    },
    {
        "beam_id": 11,
        "pm_counter": "M55306C00012",
        "unmuted_value": 4294965247
    },
    {
        "beam_id": 12,
        "pm_counter": "M55306C00013",
        "unmuted_value": 4294963199
    },
    {
        "beam_id": 13,
        "pm_counter": "M55306C00014",
        "unmuted_value": 4294959103
    },
    {
        "beam_id": 14,
        "pm_counter": "M55306C00015",
        "unmuted_value": 4294950911
    },
    {
        "beam_id": 15,
        "pm_counter": "M55306C00016",
        "unmuted_value": 4294934527
    },
    {
        "beam_id": 16,
        "pm_counter": "M55306C00017",
        "unmuted_value": 4294901759
    },
    {
        "beam_id": 17,
        "pm_counter": "M55306C00018",
        "unmuted_value": 4294836223
    },
    {
        "beam_id": 18,
        "pm_counter": "M55306C00019",
        "unmuted_value": 4294705151
    },
    {
        "beam_id": 19,
        "pm_counter": "M55306C00020",
        "unmuted_value": 4294443007
    },
    {
        "beam_id": 20,
        "pm_counter": "M55306C00021",
        "unmuted_value": 4293918719
    },
    {
        "beam_id": 21,
        "pm_counter": "M55306C00022",
        "unmuted_value": 4292870143
    },
    {
        "beam_id": 22,
        "pm_counter": "M55306C00023",
        "unmuted_value": 4290772991
    },
    {
        "beam_id": 23,
        "pm_counter": "M55306C00024",
        "unmuted_value": 4286578687
    },
    {
        "beam_id": 24,
        "pm_counter": "M55306C00025",
        "unmuted_value": 4278190079
    },
    {
        "beam_id": 25,
        "pm_counter": "M55306C00026",
        "unmuted_value": 4261412863
    },
    {
        "beam_id": 26,
        "pm_counter": "M55306C00027",
        "unmuted_value": 4227858431
    },
    {
        "beam_id": 27,
        "pm_counter": "M55306C00028",
        "unmuted_value": 4160749567
    },
    {
        "beam_id": 28,
        "pm_counter": "M55306C00029",
        "unmuted_value": 4026531839
    },
    {
        "beam_id": 29,
        "pm_counter": "M55306C00030",
        "unmuted_value": 3758096383
    },
    {
        "beam_id": 30,
        "pm_counter": "M55306C00031",
        "unmuted_value": 3221225471
    },
    {
        "beam_id": 31,
        "pm_counter": "M55306C00032",
        "unmuted_value": 2147483647
    }
]

beam_dist_data = [{
    "distName": "MRBTS-{}/NRBTS-{}/NRCELL-{}",
    "operation": "update",
    "parameters": [
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetFR2_8_8_8_8_1P",
                        "beamSetInUse": "beamSetFR2_8_8_8_8_1P",
                        "beamsMuted": None,
                        "leftEdgeAngle": "45",
                        "lowerEdgeAngle": "110",
                        "rightEdgeAngle": "45",
                        "upperEdgeAngle": "90"
                    }
                ],
                "operation": "update"
            }
        ]
    }
]
