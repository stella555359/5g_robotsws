# -*- coding: utf-8 -*-
# @Time    : 2025/1/10 14:18
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : assert_emil_value.py
# @Software: PyCharm
QosFlowSetupRequestList = {
    "qosFlowIdentifier": 1,
    "qosFlowLevelQosParameters": {
        "allocationAndRetentionPriority": {
            "pre-emptionCapability": "shall-not-trigger-pre-emption",
            "pre-emptionVulnerability": "pre-emptable",
            "priorityLevelARP": 15
        },
        "gBR-QosInformation": {
            "guaranteedFlowBitRateDL": 20000000,
            "guaranteedFlowBitRateUL": 20000000,
            "maximumFlowBitRateDL": 30720000,
            "maximumFlowBitRateUL": 30720000
        },
        "qosCharacteristics": {
            "nonDynamic5QI": {
                "fiveQI": 3
            }
        }
    }
}
FIVE_QI_LIST = [2, 4, 71, 72, 76, 128, 254]
dRB_To_Setup_List_NG_RAN = {
    "cell-Group-Information": [{
        "cell-Group-ID": 0
    }],
    "dRB-ID": 5,
    "pDCP-Configuration": {
        "discardTimer": "infinity",
        "pDCP-SN-Size-DL": "s-18",
        "pDCP-SN-Size-UL": "s-18",
        "rLC-Mode": "rlc-am",
        "t-ReorderingTimer": {
            "t-Reordering": "ms100"
        }
    },
    "qos-flow-Information-To-Be-Setup": [{
        "qoS-Flow-Identifier": 7,
        "qoSFlowLevelQoSParameters": {
            "nGRANallocationRetentionPriority": {
                "pre-emptionCapability": "shall-not-trigger-pre-emption",
                "pre-emptionVulnerability": "pre-emptable",
                "priorityLevel": "no-priority"
            },
            "qoS-Characteristics": {
                "non-Dynamic-5QI": {
                    "fiveQI": 8
                }
            }
        }
    }],
    "sDAP-Configuration": {
        "defaultDRB": "true",
        "sDAP-Header-DL": "absent",
        "sDAP-Header-UL": "present"
    }
}
