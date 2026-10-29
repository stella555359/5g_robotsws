LOCK_SNSSAI = [
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Locked",
                "operation": "update"
            }
        ]
    }
]

SETUP_FEATURE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/SERVEDAMF-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "amfIPAddress",
                "value": "10.0.1.200",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SERVEDAMF-3",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "amfIPAddress",
                "value": "10.0.1.210",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SERVEDAMF-4",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "amfIPAddress",
                "value": "10.0.1.220",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SERVEDAMF-5",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "amfIPAddress",
                "value": "10.0.1.230",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SERVEDAMF-6",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "amfIPAddress",
                "value": "10.0.1.240",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "fiveGsTac",
                "value": "200",
                "operation": "update"
            },
            {
                "parameterName": "snssaiList",
                "value": [
                    {
                        "snssaiDN": "MRBTS-1/NRBTS-1/SNSSAI-1"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Unlocked",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "MRBTS-1/NRBTS-1/NRPLMN-2",
                    "MRBTS-1/NRBTS-1/NRPLMN-3",
                    "MRBTS-1/NRBTS-1/NRPLMN-4",
                    "MRBTS-1/NRBTS-1/NRPLMN-5",
                    "MRBTS-1/NRBTS-1/NRPLMN-6"
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRPLMN-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "mcc",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "mnc",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "mncLength",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRPLMN-3",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "mcc",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "mnc",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "mncLength",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRPLMN-4",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "mcc",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "mnc",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "mncLength",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRPLMN-5",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "mcc",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "mnc",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "mncLength",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRPLMN-6",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "mcc",
                "value": "6",
                "operation": "update"
            },
            {
                "parameterName": "mnc",
                "value": "6",
                "operation": "update"
            },
            {
                "parameterName": "mncLength",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRanSharing",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actRanSharingEnh",
                "value": "max_10_PLMNs",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "trackingAreaDN",
                "value": "",
                "operation": "delete"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "trackingAreaDN",
                "value": "",
                "operation": "delete"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "trackingAreaDN",
                "value": "",
                "operation": "delete"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "trackingAreaDN",
                "value": "",
                "operation": "delete"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "trackingAreaDN",
                "value": "",
                "operation": "delete"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "trackingAreaDN",
                "value": "",
                "operation": "delete"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "trackingAreaDN",
                "value": "",
                "operation": "delete"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "trackingAreaDN",
                "value": "",
                "operation": "delete"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "MRBTS-1/NRBTS-1/NRPLMN-3",
                    "MRBTS-1/NRBTS-1/NRPLMN-4",
                    "MRBTS-1/NRBTS-1/NRPLMN-5",
                    "MRBTS-1/NRBTS-1/NRPLMN-6"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-788",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-2"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "MRBTS-1/NRBTS-1/NRPLMN-3",
                    "MRBTS-1/NRBTS-1/NRPLMN-4",
                    "MRBTS-1/NRBTS-1/NRPLMN-5",
                    "MRBTS-1/NRBTS-1/NRPLMN-6"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-788",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-2"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_SA-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "MRBTS-1/NRBTS-1/NRPLMN-3",
                    "MRBTS-1/NRBTS-1/NRPLMN-4",
                    "MRBTS-1/NRBTS-1/NRPLMN-5",
                    "MRBTS-1/NRBTS-1/NRPLMN-6"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-788",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_SA-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-2"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4/NRPLMNSET_SA-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "MRBTS-1/NRBTS-1/NRPLMN-3",
                    "MRBTS-1/NRBTS-1/NRPLMN-4",
                    "MRBTS-1/NRBTS-1/NRPLMN-5",
                    "MRBTS-1/NRBTS-1/NRPLMN-6"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-788",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4/NRPLMNSET_SA-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-2"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5/NRPLMNSET_SA-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "MRBTS-1/NRBTS-1/NRPLMN-3",
                    "MRBTS-1/NRBTS-1/NRPLMN-4",
                    "MRBTS-1/NRBTS-1/NRPLMN-5",
                    "MRBTS-1/NRBTS-1/NRPLMN-6"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-788",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5/NRPLMNSET_SA-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-2"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6/NRPLMNSET_SA-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "MRBTS-1/NRBTS-1/NRPLMN-3",
                    "MRBTS-1/NRBTS-1/NRPLMN-4",
                    "MRBTS-1/NRBTS-1/NRPLMN-5",
                    "MRBTS-1/NRBTS-1/NRPLMN-6"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-788",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6/NRPLMNSET_SA-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-2"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7/NRPLMNSET_SA-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "MRBTS-1/NRBTS-1/NRPLMN-3",
                    "MRBTS-1/NRBTS-1/NRPLMN-4",
                    "MRBTS-1/NRBTS-1/NRPLMN-5",
                    "MRBTS-1/NRBTS-1/NRPLMN-6"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-788",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7/NRPLMNSET_SA-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-2"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8/NRPLMNSET_SA-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "MRBTS-1/NRBTS-1/NRPLMN-3",
                    "MRBTS-1/NRBTS-1/NRPLMN-4",
                    "MRBTS-1/NRBTS-1/NRPLMN-5",
                    "MRBTS-1/NRBTS-1/NRPLMN-6"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-788",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8/NRPLMNSET_SA-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "cellReservedForOperatorUse",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "cellReservedForOperatorUseUacAutoMax",
                "value": "notReserved",
                "operation": "update"
            },
            {
                "parameterName": "nrPlmnDNList",
                "value": [
                    "MRBTS-1/NRBTS-1/NRPLMN-2"
                ],
                "operation": "update"
            },
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                "operation": "update"
            }
        ]
    }
]
