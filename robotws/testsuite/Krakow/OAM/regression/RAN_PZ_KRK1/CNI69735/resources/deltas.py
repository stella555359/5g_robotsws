delta_bw15 = [
    {
        "distName": "MRBTS-76164/NRBTS-76164/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "cellBwpList",
                "value": [
                    {
                        "actPdcchCceFragmentControl": "false",
                        "actUpperThrAckNackFiltering": "false",
                        "actUpperThrAckNackHrFiltering": "false",
                        "pdcchResourcePreference": "peakRate",
                        "bwpDN": "MRBTS-76164/NRBTS-76164/BWP_PROFILE-4",
                        "cellBwpId": "0",
                    },
                    {
                        "actPdcchCceFragmentControl": "false",
                        "actUpperThrAckNackFiltering": "false",
                        "actUpperThrAckNackHrFiltering": "false",
                        "pdcchResourcePreference": "peakRate",
                        "bwpDN": "MRBTS-76164/NRBTS-76164/BWP_PROFILE-45",
                        "cellBwpId": "1",
                    },
                ],
            }
        ],
    },
    {
        "distName": "MRBTS-76164/NRBTS-76164/NRCELL-5/NRCELL_FDD-1",
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "chBwDl", "value": "15MHz"},
            {"operation": "update", "parameterName": "chBwUl", "value": "15MHz"},
        ],
    },
]


delta_bw20 = [
    {
        "distName": "MRBTS-76164/NRBTS-76164/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "cellBwpList",
                "value": [
                    {
                        "actPdcchCceFragmentControl": "false",
                        "actUpperThrAckNackFiltering": "false",
                        "actUpperThrAckNackHrFiltering": "false",
                        "pdcchResourcePreference": "peakRate",
                        "bwpDN": "MRBTS-76164/NRBTS-76164/BWP_PROFILE-4",
                        "cellBwpId": "0",
                    },
                    {
                        "actPdcchCceFragmentControl": "false",
                        "actUpperThrAckNackFiltering": "false",
                        "actUpperThrAckNackHrFiltering": "false",
                        "pdcchResourcePreference": "peakRate",
                        "bwpDN": "MRBTS-76164/NRBTS-76164/BWP_PROFILE-56",
                        "cellBwpId": "1",
                    },
                ],
            }
        ],
    },
    {
        "distName": "MRBTS-76164/NRBTS-76164/NRCELL-5/NRCELL_FDD-1",
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "chBwDl", "value": "20MHz"},
            {"operation": "update", "parameterName": "chBwUl", "value": "20MHz"},
        ],
    },
]

delta_bw60 = [
    {
        "distName": "MRBTS-76164/NRBTS-76164/NRCELL-6",
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "chBw", "value": "60MHz"},
        ],
    }
]

delta_bw100 = [
    {
        "distName": "MRBTS-76164/NRBTS-76164/NRCELL-6",
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "chBw", "value": "100MHz"},
        ],
    }
]
