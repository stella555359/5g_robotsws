# -*- coding: utf-8 -*-
# @Time    : 2025/1/10 14:18
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : assert_emil_value.py
# @Software: PyCharm

PDUSessionResourceFailedToSetupListCxtFail = [
    {
        "pDUSessionID": 1,
        "pDUSessionResourceSetupUnsuccessfulTransfer": {
            "cause": {
                "radioNetwork": "radio-resources-not-available"
            }
        }
    }
]

dRB_To_Setup_List_NG_RAN_82_85 = [
    [
        {
            "dRB-ID": 4,
            "sDAP-Configuration": {
                "defaultDRB": "false",
                "sDAP-Header-UL": "absent",
                "sDAP-Header-DL": "absent"
            },
            "pDCP-Configuration": {
                "pDCP-SN-Size-UL": "s-12",
                "pDCP-SN-Size-DL": "s-12",
                "rLC-Mode": "rlc-um-bidirectional",
                "t-ReorderingTimer": {
                    "t-Reordering": "ms100"
                },
                "discardTimer": "infinity",
                "outOfOrderDelivery": "true"
            },
            "cell-Group-Information": [
                {
                    "cell-Group-ID": 0
                }
            ],
            "qos-flow-Information-To-Be-Setup": [
                {
                    "qoS-Flow-Identifier": 1,
                    "qoSFlowLevelQoSParameters": {
                        "qoS-Characteristics": {
                            "non-Dynamic-5QI": {
                                "fiveQI": 82,
                                "maxDataBurstVolume": 600
                            }
                        },
                        "nGRANallocationRetentionPriority": {
                            "priorityLevel": 8,
                            "pre-emptionCapability": "shall-not-trigger-pre-emption",
                            "pre-emptionVulnerability": "pre-emptable"
                        },
                        "gBR-QoS-Flow-Information": {
                            "maxFlowBitRateDownlink": 408000,
                            "maxFlowBitRateUplink": 408000,
                            "guaranteedFlowBitRateDownlink": 249000,
                            "guaranteedFlowBitRateUplink": 249000
                        }
                    }
                }
            ]
        }
    ],
    [
        {
            "dRB-ID": 4,
            "sDAP-Configuration": {
                "defaultDRB": "false",
                "sDAP-Header-UL": "absent",
                "sDAP-Header-DL": "absent"
            },
            "pDCP-Configuration": {
                "pDCP-SN-Size-UL": "s-12",
                "pDCP-SN-Size-DL": "s-12",
                "rLC-Mode": "rlc-um-bidirectional",
                "t-ReorderingTimer": {
                    "t-Reordering": "ms100"
                },
                "discardTimer": "infinity",
                "outOfOrderDelivery": "true"
            },
            "cell-Group-Information": [
                {
                    "cell-Group-ID": 0
                }
            ],
            "qos-flow-Information-To-Be-Setup": [
                {
                    "qoS-Flow-Identifier": 1,
                    "qoSFlowLevelQoSParameters": {
                        "qoS-Characteristics": {
                            "non-Dynamic-5QI": {
                                "fiveQI": 85,
                                "maxDataBurstVolume": 600
                            }
                        },
                        "nGRANallocationRetentionPriority": {
                            "priorityLevel": 7,
                            "pre-emptionCapability": "shall-not-trigger-pre-emption",
                            "pre-emptionVulnerability": "pre-emptable"
                        },
                        "gBR-QoS-Flow-Information": {
                            "maxFlowBitRateDownlink": 816000,
                            "maxFlowBitRateUplink": 816000,
                            "guaranteedFlowBitRateDownlink": 448000,
                            "guaranteedFlowBitRateUplink": 448000
                        }
                    }
                }
            ]
        }
    ]
]

dRB_To_Setup_List_NG_RAN_88_128_225 = [
    [
        {
            "dRB-ID": 4,
            "sDAP-Configuration": {
                "defaultDRB": "false",
                "sDAP-Header-UL": "absent",
                "sDAP-Header-DL": "absent"
            },
            "pDCP-Configuration": {
                "pDCP-SN-Size-UL": "s-12",
                "pDCP-SN-Size-DL": "s-12",
                "rLC-Mode": "rlc-um-bidirectional",
                "t-ReorderingTimer": {
                    "t-Reordering": "ms100"
                },
                "discardTimer": "infinity",
                "outOfOrderDelivery": "true"
            },
            "cell-Group-Information": [
                {
                    "cell-Group-ID": 0
                }
            ],
            "qos-flow-Information-To-Be-Setup": [
                {
                    "qoS-Flow-Identifier": 1,
                    "qoSFlowLevelQoSParameters": {
                        "qoS-Characteristics": {
                            "non-Dynamic-5QI": {
                                "fiveQI": 88,
                                "maxDataBurstVolume": 500
                            }
                        },
                        "nGRANallocationRetentionPriority": {
                            "priorityLevel": 7,
                            "pre-emptionCapability": "shall-not-trigger-pre-emption",
                            "pre-emptionVulnerability": "pre-emptable"
                        },
                        "gBR-QoS-Flow-Information": {
                            "maxFlowBitRateDownlink": 1800000,
                            "maxFlowBitRateUplink": 1800000,
                            "guaranteedFlowBitRateDownlink": 400000,
                            "guaranteedFlowBitRateUplink": 400000
                        }
                    }
                }
            ]
        }
    ],
    [
        {
            "dRB-ID": 4,
            "sDAP-Configuration": {
                "defaultDRB": "false",
                "sDAP-Header-UL": "absent",
                "sDAP-Header-DL": "absent"
            },
            "pDCP-Configuration": {
                "pDCP-SN-Size-UL": "s-12",
                "pDCP-SN-Size-DL": "s-12",
                "rLC-Mode": "rlc-um-bidirectional",
                "t-ReorderingTimer": {
                    "t-Reordering": "ms100"
                },
                "discardTimer": "infinity",
                "outOfOrderDelivery": "true"
            },
            "cell-Group-Information": [
                {
                    "cell-Group-ID": 0
                }
            ],
            "qos-flow-Information-To-Be-Setup": [
                {
                    "qoS-Flow-Identifier": 1,
                    "qoSFlowLevelQoSParameters": {
                        "qoS-Characteristics": {
                            "non-Dynamic-5QI": {
                                "fiveQI": 128,
                                "maxDataBurstVolume": 400
                            }
                        },
                        "nGRANallocationRetentionPriority": {
                            "priorityLevel": 7,
                            "pre-emptionCapability": "shall-not-trigger-pre-emption",
                            "pre-emptionVulnerability": "pre-emptable"
                        },
                        "gBR-QoS-Flow-Information": {
                            "maxFlowBitRateDownlink": 1000000,
                            "maxFlowBitRateUplink": 1000000,
                            "guaranteedFlowBitRateDownlink": 70000,
                            "guaranteedFlowBitRateUplink": 70000
                        }
                    }
                }
            ]
        }
    ],
    [
        {
            "dRB-ID": 4,
            "sDAP-Configuration": {
                "defaultDRB": "false",
                "sDAP-Header-UL": "absent",
                "sDAP-Header-DL": "absent"
            },
            "pDCP-Configuration": {
                "pDCP-SN-Size-UL": "s-12",
                "pDCP-SN-Size-DL": "s-12",
                "rLC-Mode": "rlc-um-bidirectional",
                "t-ReorderingTimer": {
                    "t-Reordering": "ms100"
                },
                "discardTimer": "infinity",
                "outOfOrderDelivery": "true"
            },
            "cell-Group-Information": [
                {
                    "cell-Group-ID": 0
                }
            ],
            "qos-flow-Information-To-Be-Setup": [
                {
                    "qoS-Flow-Identifier": 1,
                    "qoSFlowLevelQoSParameters": {
                        "qoS-Characteristics": {
                            "non-Dynamic-5QI": {
                                "fiveQI": 225,
                                "maxDataBurstVolume": 300
                            }
                        },
                        "nGRANallocationRetentionPriority": {
                            "priorityLevel": 7,
                            "pre-emptionCapability": "shall-not-trigger-pre-emption",
                            "pre-emptionVulnerability": "pre-emptable"
                        },
                        "gBR-QoS-Flow-Information": {
                            "maxFlowBitRateDownlink": 1000000,
                            "maxFlowBitRateUplink": 1000000,
                            "guaranteedFlowBitRateDownlink": 50000,
                            "guaranteedFlowBitRateUplink": 50000
                        }
                    }
                }
            ]
        }
    ]
]

DRBs_ToBeSetup_Item_82_MDBV = {
    'fiveQI': 82,
    'averagingWindow': 1900,
    'maxDataBurstVolume': 600
}

DRBs_ToBeSetup_Item_85_MDBV = {
    'fiveQI': 85,
    'averagingWindow': 1900,
    'maxDataBurstVolume': 600
}

DRBs_ToBeSetup_Item_88_MDBV = {
    'fiveQI': 88,
    'averagingWindow': 1800,
    'maxDataBurstVolume': 500
}

DRBs_ToBeSetup_Item_128_MDBV = {
    'fiveQI': 128,
    'averagingWindow': 1700,
    'maxDataBurstVolume': 400
}

DRBs_ToBeSetup_Item_225_MDBV = {
    'fiveQI': 225,
    'averagingWindow': 1600,
    'maxDataBurstVolume': 300
}

mac_LogicalChannelConfig_5qi_82_84 = {
    'ul-SpecificParameters': {
        'bucketSizeDuration': 'ms5',
        'logicalChannelGroup': 6,
        'logicalChannelSR-DelayTimerApplied': False,
        'logicalChannelSR-Mask': False,
        'prioritisedBitRate': 'kBps512',
        'priority': 5,
        'schedulingRequestID': 0
    }
}

mac_LogicalChannelConfig_5qi_83 = {
    'ul-SpecificParameters': {
        'bucketSizeDuration': 'ms10',
        'logicalChannelGroup': 6,
        'logicalChannelSR-DelayTimerApplied': False,
        'logicalChannelSR-Mask': False,
        'prioritisedBitRate': 'kBps64',
        'priority': 5,
        'schedulingRequestID': 0
    }
}

dRB_To_Setup_List_NG_RAN_84 = [
    {
        'cell-Group-Information': [{'cell-Group-ID': 0}],
        'dRB-ID': 5,
        'pDCP-Configuration': {
            'discardTimer': 'ms30',
            'outOfOrderDelivery': 'true',
            'pDCP-SN-Size-DL': 's-18',
            'pDCP-SN-Size-UL': 's-18',
            'rLC-Mode': 'rlc-um-bidirectional',
            't-ReorderingTimer': {'t-Reordering': 'ms10'}
        },
        'qos-flow-Information-To-Be-Setup': [
            {
                'qoS-Flow-Identifier': 2,
                'qoSFlowLevelQoSParameters': {
                    'gBR-QoS-Flow-Information': {
                        'guaranteedFlowBitRateDownlink': 476000,
                        'guaranteedFlowBitRateUplink': 476000,
                        'maxFlowBitRateDownlink': 724000,
                        'maxFlowBitRateUplink': 724000
                    },
                    'nGRANallocationRetentionPriority': {
                        'pre-emptionCapability': 'shall-not-trigger-pre-emption',
                        'pre-emptionVulnerability': 'pre-emptable',
                        'priorityLevel': 'no-priority'
                    },
                    'qoS-Characteristics': {'non-Dynamic-5QI': {'fiveQI': 84}}
                }
            }
        ],
        'sDAP-Configuration': {
            'defaultDRB': 'false',
            'sDAP-Header-DL': 'absent',
            'sDAP-Header-UL': 'absent'
        }
    }
]

ITF_L2_HI_CU_USER_BEARERSETUPREQ_ID = {
    'flowControlActive': 1,
    'drbIdentity': 5,
    'resourceType': 2,
    'rlcMode': 1,
    'snFieldLength': 18,
    'reorderingTimer': 10,
    'dlMdbv': 1354,
    'mdbvMargin': 0,
    'dlRanPdb': 25
}

ITF_L2_PS_USER_BEARERSETUPREQ_ID = {
    'dlMdbv': 1354,
    'ulMdbv': 1354,
    'dlRanPdb': 25,
    'ulRanPdb': 25,
    'avgWindow': 2000,
    'discardTimerDl': 30
}

BearerContextModificationResponse = [
    {
        'dRB-ID': 5,
        'flow-Setup-List': [
            {
                'qoS-Flow-Identifier': 2
            }
        ],
        'uL-UP-Transport-Parameters': [
            {
                'cell-Group-ID': 0,
                'uP-TNL-Information': {
                    'gTPTunnel': {
                        'gTP-TEID': '400101A4',
                        'transportLayerAddress': {
                            'length': 128,
                            'value': '0001000B000000000000000000000000'
                        }
                    }
                }
            }
        ]
    }
]

BearerContextModificationResponse2 = [
    {
        'dRB-ID': 5,
        'flow-Setup-List': [
            {
                'qoS-Flow-Identifier': 2
            }
        ],
        'uL-UP-Transport-Parameters': [
            {
                'cell-Group-ID': 0,
                'uP-TNL-Information': {
                    'gTPTunnel': {
                        'gTP-TEID': '400101A6',
                        'transportLayerAddress': {
                            'length': 128,
                            'value': '0001000B000000000000000000000000'
                        }
                    }
                }
            }
        ]
    }
]

QosFlowSetupRequestList = [
    {
        'qosFlowIdentifier': 1,
        'qosFlowLevelQosParameters': {
            'allocationAndRetentionPriority': {
                'pre-emptionCapability': 'shall-not-trigger-pre-emption',
                'pre-emptionVulnerability': 'pre-emptable',
                'priorityLevelARP': 15
            },
            'gBR-QosInformation': {
                'guaranteedFlowBitRateDL': 476000,
                'guaranteedFlowBitRateUL': 476000,
                'maximumFlowBitRateDL': 724000,
                'maximumFlowBitRateUL': 724000
            },
            'qosCharacteristics': {
                'nonDynamic5QI': {
                    'averagingWindow': 2000,
                    'fiveQI': 84,
                    'maximumDataBurstVolume': 1354
                }
            }
        }
    }
]

PDUSessionResourceToReleaseListRelCmd = [
    {
        'pDUSessionID': 2,
        'pDUSessionResourceReleaseCommandTransfer': {
            'cause': {
                'nas': 'normal-release'
            }
        }
    }
]

dRB_To_Setup_Mod_List_NG_RAN_6_84 = [
    {
        "cell-Group-Information": [
            {"cell-Group-ID": 0}
        ],
        "dRB-ID": 5,
        "flow-Mapping-Information": [
            {
                "qoS-Flow-Identifier": 2,
                "qoSFlowLevelQoSParameters": {
                    "nGRANallocationRetentionPriority": {
                        "pre-emptionCapability": "shall-not-trigger-pre-emption",
                        "pre-emptionVulnerability": "pre-emptable",
                        "priorityLevel": "no-priority"
                    },
                    "qoS-Characteristics": {
                        "non-Dynamic-5QI": {
                            "fiveQI": 6
                        }
                    }
                }
            }
        ],
        "pDCP-Configuration": {
            "discardTimer": "ms10",
            "pDCP-SN-Size-DL": "s-18",
            "pDCP-SN-Size-UL": "s-18",
            "rLC-Mode": "rlc-am",
            "t-ReorderingTimer": {
                "t-Reordering": "ms300"
            }
        },
        "sDAP-Configuration": {
            "defaultDRB": "true",
            "sDAP-Header-DL": "absent",
            "sDAP-Header-UL": "present"
        }
    },
    {
        "cell-Group-Information": [
            {"cell-Group-ID": 0}
        ],
        "dRB-ID": 6,
        "flow-Mapping-Information": [
            {
                "qoS-Flow-Identifier": 1,
                "qoSFlowLevelQoSParameters": {
                    "gBR-QoS-Flow-Information": {
                        "guaranteedFlowBitRateDownlink": 476000,
                        "guaranteedFlowBitRateUplink": 476000,
                        "maxFlowBitRateDownlink": 724000,
                        "maxFlowBitRateUplink": 724000
                    },
                    "nGRANallocationRetentionPriority": {
                        "pre-emptionCapability": "shall-not-trigger-pre-emption",
                        "pre-emptionVulnerability": "pre-emptable",
                        "priorityLevel": "no-priority"
                    },
                    "qoS-Characteristics": {
                        "non-Dynamic-5QI": {
                            "fiveQI": 84,
                            "maxDataBurstVolume": 1354
                        }
                    }
                }
            }
        ],
        "pDCP-Configuration": {
            "discardTimer": "ms30",
            "outOfOrderDelivery": "true",
            "pDCP-SN-Size-DL": "s-18",
            "pDCP-SN-Size-UL": "s-18",
            "rLC-Mode": "rlc-um-bidirectional",
            "t-ReorderingTimer": {
                "t-Reordering": "ms30"
            }
        },
        "sDAP-Configuration": {
            "defaultDRB": "false",
            "sDAP-Header-DL": "absent",
            "sDAP-Header-UL": "absent"
        }
    }
]
