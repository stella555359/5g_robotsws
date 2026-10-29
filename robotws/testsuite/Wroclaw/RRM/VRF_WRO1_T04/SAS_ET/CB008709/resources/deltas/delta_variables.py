"""
:copyright: Nokia Networks
:author: Damian Zak
:maintainer: Damian Zak
:contact: damian.zak@nokia.com
:team: MN_RAN_RD_VRF_KRK_11
"""

CB008709_A_TC004_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actVoNR",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRPMRNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "miNrRSUP",
                "value": "5min",
                "operation": "update"
            }
        ]
    }
]

CB008709_G_TC011_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRDRB-16",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actDddsReduction",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actDlTxResumeOnPdcpStatRep",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actLostPduFastRetx",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actOptDataFlowRateEst",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "allowedPdcchPowerBoostALDueCce",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "allowedPdcchPowerBoostALDueCfg",
                "value": "None",
                "operation": "update"
            },
            {
                "parameterName": "caPduReSendingDelayMargin",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "cellAggrLevel",
                "value": [
                    "Not FR1 CA eligible"
                ],
                "operation": "update"
            },
            {
                "parameterName": "discardTimer",
                "value": "100ms",
                "operation": "update"
            },
            {
                "parameterName": "dlAllowMinDelayLinkXxCalib",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "dlFlowControlAlgo",
                "value": "3gppFlowControl",
                "operation": "update"
            },
            {
                "parameterName": "dscp",
                "value": "0",
                "operation": "update"
            },
            {
                "parameterName": "durationThresDiscardDl",
                "value": "40",
                "operation": "update"
            },
            {
                "parameterName": "durationThresDiscardDlMacSdu",
                "value": "40",
                "operation": "update"
            },
            {
                "parameterName": "durationThresDiscardDlPdcpPdu5GLeg",
                "value": "40",
                "operation": "update"
            },
            {
                "parameterName": "durationThresDiscardDlPdcpPduLteLeg",
                "value": "40",
                "operation": "update"
            },
            {
                "parameterName": "durationThresDiscardUl",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "endMarkerTimer",
                "value": "300",
                "operation": "update"
            },
            {
                "parameterName": "maxDddsPeriodCpuOvld",
                "value": "40",
                "operation": "update"
            },
            {
                "parameterName": "nrDrbMacDN",
                "value": "MRBTS-1/NRBTS-1/NRDRB_MAC-1",
                "operation": "update"
            },
            {
                "parameterName": "nrDrbPdcpDN",
                "value": "MRBTS-1/NRBTS-1/NRDRB_PDCP-3",
                "operation": "update"
            },
            {
                "parameterName": "nrDrbRlcAmDN",
                "value": "MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2",
                "operation": "update"
            },
            {
                "parameterName": "nrDrxDN",
                "value": "MRBTS-1/NRBTS-1/NRDRX-1",
                "operation": "update"
            },
            {
                "parameterName": "numSduDiscard",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "queuingDelayDiscardStart",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "queuingDelayDiscarding",
                "value": "Controlled Delay (CoDel)",
                "operation": "update"
            },
            {
                "parameterName": "queuingDelaySduDiscardThreshold",
                "value": "750",
                "operation": "update"
            },
            {
                "parameterName": "resType",
                "value": "GBR",
                "operation": "update"
            },
            {
                "parameterName": "rlcMode",
                "value": "RLC_UM",
                "operation": "update"
            },
            {
                "parameterName": "rlcPduDelayThCa",
                "value": "30",
                "operation": "update"
            },
            {
                "parameterName": "sduDiscardIntervalTmr",
                "value": "500",
                "operation": "update"
            },
            {
                "parameterName": "volThresDiscardDl",
                "value": "8000",
                "operation": "update"
            },
            {
                "parameterName": "volThresDiscardDlMacSdu",
                "value": "8000",
                "operation": "update"
            },
            {
                "parameterName": "volThresDiscardDlPdcpPdu5GLeg",
                "value": "8000",
                "operation": "update"
            },
            {
                "parameterName": "volThresDiscardDlPdcpPduLteLeg",
                "value": "8000",
                "operation": "update"
            },
            {
                "parameterName": "volThresDiscardUl",
                "value": "800",
                "operation": "update"
            },
            {
                "parameterName": "minForwardTputXx",
                "value": "100",
                "operation": "update"
            },
            {
                "parameterName": "maxForwardTimeLimitXx",
                "value": "50",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
        "operation": "update",
        "parameters": [

        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "allowRegularSrAboveMaxQuota",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "nrResourceList",
                "value": [
                        {
                            "resourceDN": "MRBTS-1/NRBTS-1/SNSSAI-1"
                        }
                ],
                "operation": "update"
            },
            {
                "parameterName": "srRacParams",
                "value": [
                    {
                        "maxQuota": "20",
                        "minQuota": "20"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "allowRegularSrAboveMaxQuota",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "nrResourceList",
                "value": [
                        {
                            "resourceDN": "MRBTS-1/NRBTS-1/SNSSAI-2"
                        }
                ],
                "operation": "update"
            },
            {
                "parameterName": "srRacParams",
                "value": [
                    {
                        "maxQuota": "20",
                        "minQuota": "20"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "allowRegularSrAboveMaxQuota",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "nrResourceList",
                "value": [
                        {
                            "resourceDN": "MRBTS-1/NRBTS-1/SNSSAI-3"
                        }
                ],
                "operation": "update"
            },
            {
                "parameterName": "srRacParams",
                "value": [
                    {
                        "maxQuota": "20",
                        "minQuota": "20"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actNonVoNRGbrService",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actVoNR",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "nrResourceGroupProfileUlDN",
                "value": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRDRB_5QI-7",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "fiveqiValueList",
                "value": [
                    "2"
                ],
                "operation": "update"
            },
            {
                "parameterName": "dataForwarding",
                "value": "IRATDataFwd",
                "operation": "update"
            },
            {
                "parameterName": "nrDrbDN",
                "value": "MRBTS-1/NRBTS-1/NRDRB-16",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRDRB-16",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "actDddsReduction",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actDlTxResumeOnPdcpStatRep",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "allowedPdcchPowerBoostALDueCce",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "allowedPdcchPowerBoostALDueCfg",
                "value": "None",
                "operation": "update"
            },
            {
                "parameterName": "nrDrxDN",
                "value": "MRBTS-1/NRBTS-1/NRDRX-1",
                "operation": "update"
            },
            {
                "parameterName": "actLostPduFastRetx",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actOptDataFlowRateEst",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "caPduReSendingDelayMargin",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "cellAggrLevel",
                "value": [
                    "Not FR1 CA eligible"
                ],
                "operation": "update"
            },
            {
                "parameterName": "discardTimer",
                "value": "100ms",
                "operation": "update"
            },
            {
                "parameterName": "dlAllowMinDelayLinkXxCalib",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "dlFlowControlAlgo",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "dscp",
                "value": "46",
                "operation": "update"
            },
            {
                "parameterName": "durationThresDiscardDl",
                "value": "40",
                "operation": "update"
            },
            {
                "parameterName": "durationThresDiscardDlMacSdu",
                "value": "40",
                "operation": "update"
            },
            {
                "parameterName": "durationThresDiscardDlPdcpPdu5GLeg",
                "value": "40",
                "operation": "update"
            },
            {
                "parameterName": "durationThresDiscardDlPdcpPduLteLeg",
                "value": "40",
                "operation": "update"
            },
            {
                "parameterName": "durationThresDiscardUl",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "endMarkerTimer",
                "value": "2000",
                "operation": "update"
            },
            {
                "parameterName": "l2OHFactorDl",
                "value": "16",
                "operation": "update"
            },
            {
                "parameterName": "l2OHFactorUl",
                "value": "35",
                "operation": "update"
            },
            {
                "parameterName": "maxDataRateGbrDl",
                "value": "1000",
                "operation": "update"
            },
            {
                "parameterName": "maxDataRateGbrUl",
                "value": "30000",
                "operation": "update"
            },
            {
                "parameterName": "maxDddsPeriodCpuOvld",
                "value": "40",
                "operation": "update"
            },
            {
                "parameterName": "maxRlcQueueingDelayGbr",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "maxTransferDelayGbr",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "nrDrbMacDN",
                "value": "MRBTS-1/NRBTS-1/NRDRB_MAC-5",
                "operation": "update"
            },
            {
                "parameterName": "nrDrbPdcpDN",
                "value": "MRBTS-1/NRBTS-1/NRDRB_PDCP-3",
                "operation": "update"
            },
            {
                "parameterName": "nrDrbRlcUmDN",
                "value": "MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1",
                "operation": "update"
            },
            {
                "parameterName": "numSduDiscard",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "queuingDelayDiscardStart",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "queuingDelayDiscarding",
                "value": "Controlled Delay (CoDel)",
                "operation": "update"
            },
            {
                "parameterName": "queuingDelaySduDiscardThreshold",
                "value": "750",
                "operation": "update"
            },
            {
                "parameterName": "resType",
                "value": "GBR",
                "operation": "update"
            },
            {
                "parameterName": "rlcMode",
                "value": "RLC_UM",
                "operation": "update"
            },
            {
                "parameterName": "rlcPduDelayThCa",
                "value": "30",
                "operation": "update"
            },
            {
                "parameterName": "schedulWeight",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "sduDiscardIntervalTmr",
                "value": "500",
                "operation": "update"
            },
            {
                "parameterName": "volThresDiscardDl",
                "value": "8000",
                "operation": "update"
            },
            {
                "parameterName": "volThresDiscardDlMacSdu",
                "value": "8000",
                "operation": "update"
            },
            {
                "parameterName": "volThresDiscardDlPdcpPdu5GLeg",
                "value": "8000",
                "operation": "update"
            },
            {
                "parameterName": "volThresDiscardDlPdcpPduLteLeg",
                "value": "8000",
                "operation": "update"
            },
            {
                "parameterName": "volThresDiscardUl",
                "value": "800",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRDRB_MAC-5",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "delayTarget",
                "value": "50",
                "operation": "update"
            },
            {
                "parameterName": "lcgid",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "prioritisedBitRate",
                "value": "16kBps",
                "operation": "update"
            },
            {
                "parameterName": "schedulBSD",
                "value": "100ms",
                "operation": "update"
            },
            {
                "parameterName": "schedulPrio",
                "value": "12",
                "operation": "update"
            }
        ]
    }
]

CB008709_K_TC013_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-3"
                            },
                            {
                                "resourceDN": "SNSSAI-2"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-1"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC014_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "NRSPIDGRP-5"
                            },
                            {
                                "resourceDN": "NRSPIDGRP-4"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "NRSPIDGRP-3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC015_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-2"
                            },
                            {
                                "resourceDN": "NRSPIDGRP-3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "NRSPIDGRP-2"
                            },
                            {
                                "resourceDN": "SNSSAI-3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-5",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-5"
                            },
                            {
                                "resourceDN": "NRSPIDGRP-6"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-6",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "NRSPIDGRP-5"
                            },
                            {
                                "resourceDN": "SNSSAI-6"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC016_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-2",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "spid",
                    "value": "101",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "120",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-3",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "spid",
                    "value": "121",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "140",
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC017_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "NRPLMN-2",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-3",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "NRPLMN-1",
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC018_LOCK_SNSSAI_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "administrativeState",
                    "value": "Locked",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-3",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "administrativeState",
                    "value": "Locked",
                    "operation": "update"
                },
            ]
    }
]

CB008709_K_TC018_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDNList",
                    "value":
                        [
                            "MRBTS-1/NRBTS-1/NRPLMN-2"
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-3",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDNList",
                    "value":
                        [
                            "NRPLMN-2"
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC019_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
        "operation": "delete",
        "parameters":
            []
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-4",
        "operation": "delete",
        "parameters":
            []
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-5",
        "operation": "delete",
        "parameters":
            []
    }
]

CB008709_K_TC020_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
        "operation": "delete",
        "parameters":
            []
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-5",
        "operation": "delete",
        "parameters":
            []
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-6",
        "operation": "delete",
        "parameters":
            []
    }
]

CB008709_K_TC021_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-4",
        "operation": "delete",
        "parameters":
            []
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-5",
        "operation": "delete",
        "parameters":
            []
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-3",
        "operation": "delete",
        "parameters":
            []
    }
]

CB008709_K_TC022_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "defaultRgSaList",
                    "value":
                        [
                            {
                                "nrPlmnDN": "NRPLMN-1",
                                "nrResourceGroupId": "1"
                            },
                            {
                                "nrPlmnDN": "NRPLMN-2",
                                "nrResourceGroupId": "3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC023_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "defaultRgNsaList",
                    "value":
                        [
                            {
                                "nrPlmnDN": "NRPLMN-1",
                                "nrResourceGroupId": "3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC024_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "defaultRgNsaList",
                    "value":
                        [
                            {
                                "nrPlmnDN": "NRPLMN-1",
                                "nrResourceGroupId": "4"
                            },
                            {
                                "nrPlmnDN": "NRPLMN-2",
                                "nrResourceGroupId": "7"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "defaultRgSaList",
                    "value":
                        [
                            {
                                "nrPlmnDN": "NRPLMN-1",
                                "nrResourceGroupId": "3"
                            },
                            {
                                "nrPlmnDN": "NRPLMN-2",
                                "nrResourceGroupId": "7"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC025_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-4"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "40",
                                "minQuota": "20"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-4",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "administrativeState",
                    "value": "Unlocked",
                    "operation": "update"
                },
                {
                    "parameterName": "nrPlmnDNList",
                    "value":
                        [
                            "NRPLMN-2"
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "sd",
                    "value": "4",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-4",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-5"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "24",
                                "minQuota": "10"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-5",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "administrativeState",
                    "value": "Unlocked",
                    "operation": "update"
                },
                {
                    "parameterName": "nrPlmnDNList",
                    "value":
                        [
                            "NRPLMN-1"
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "sd",
                    "value": "5",
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC026_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-4",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "NRPLMN-1",
                    "operation": "update"
                },
                {
                    "parameterName": "spid",
                    "value": "81",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "100",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-5",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "NRPLMN-1",
                    "operation": "update"
                },
                {
                    "parameterName": "spid",
                    "value": "101",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "120",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-7",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "NRSPIDGRP-4"
                            },
                            {
                                "resourceDN": "NRSPIDGRP-5"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "20",
                                "minQuota": "5"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC027_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-3",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "administrativeState",
                    "value": "Unlocked",
                    "operation": "update"
                },
                {
                    "parameterName": "nrPlmnDNList",
                    "value":
                        [
                            "NRPLMN-1"
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "sd",
                    "value": "3",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-4",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "administrativeState",
                    "value": "Unlocked",
                    "operation": "update"
                },
                {
                    "parameterName": "nrPlmnDNList",
                    "value":
                        [
                            "NRPLMN-2"
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "sd",
                    "value": "4",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-4",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "NRPLMN-1",
                    "operation": "update"
                },
                {
                    "parameterName": "spid",
                    "value": "81",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "100",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-5",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "NRPLMN-1",
                    "operation": "update"
                },
                {
                    "parameterName": "spid",
                    "value": "101",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "120",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-6",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-3"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "50",
                                "minQuota": "5"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-7",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "NRSPIDGRP-4"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "70",
                                "minQuota": "5"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-8",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-4"
                            },
                            {
                                "resourceDN": "NRSPIDGRP-5"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "7",
                                "minQuota": "4"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC028_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-7",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-5"
                            },
                            {
                                "resourceDN": "NRSPIDGRP-5"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "15",
                                "minQuota": "5"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-8",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-6"
                            },
                            {
                                "resourceDN": "NRSPIDGRP-6"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "60",
                                "minQuota": "6"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-9",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-7"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "39",
                                "minQuota": "11"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-10",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "NRSPIDGRP-7"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "35",
                                "minQuota": "5"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC029_LOCK_SNSSAI_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "administrativeState",
                    "value": "Locked",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-4",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "administrativeState",
                    "value": "Locked",
                    "operation": "update"
                },
            ]
    }
]

CB008709_K_TC029_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "defaultRgSaList",
                    "value":
                        [
                            {
                                "nrPlmnDN": "NRPLMN-1",
                                "nrResourceGroupId": "2"
                            },
                            {
                                "nrPlmnDN": "NRPLMN-2",
                                "nrResourceGroupId": "10"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "NRSPIDGRP-3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-4",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "SNSSAI-3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-7",
        "operation": "delete",
        "parameters":
            []
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "NRPLMN-2",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-4",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "NRPLMN-1",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDNList",
                    "value":
                        [
                            "MRBTS-1/NRBTS-1/NRPLMN-2"
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-4",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDNList",
                    "value":
                        [
                            "NRPLMN-1"
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-6",
        "operation": "delete",
        "parameters":
            []
    },
    {
        "distName": "MRBTS-1/NRBTS-1/TRACKINGAREA-200",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "snssaiList",
                    "value":
                        [
                            {
                                "snssaiDN": "MRBTS-1/NRBTS-1/SNSSAI-1"
                            },
                            {
                                "snssaiDN": "MRBTS-1/NRBTS-1/SNSSAI-2"
                            },
                            {
                                "snssaiDN": "MRBTS-1/NRBTS-1/SNSSAI-3"
                            },
                            {
                                "snssaiDN": "MRBTS-1/NRBTS-1/SNSSAI-4"
                            },
                            {
                                "snssaiDN": "MRBTS-1/NRBTS-1/SNSSAI-5"
                            },
                            {
                                "snssaiDN": "MRBTS-1/NRBTS-1/SNSSAI-7"
                            },
                            {
                                "snssaiDN": "MRBTS-1/NRBTS-1/SNSSAI-8"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-7",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "administrativeState",
                    "value": "Unlocked",
                    "operation": "update"
                },
                {
                    "parameterName": "nrPlmnDNList",
                    "value":
                        [
                            "NRPLMN-1",
                            "NRPLMN-2"
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "sd",
                    "value": "7",
                    "operation": "update"
                },
                {
                    "parameterName": "sst",
                    "value": "1",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/SNSSAI-8",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "administrativeState",
                    "value": "Unlocked",
                    "operation": "update"
                },
                {
                    "parameterName": "nrPlmnDNList",
                    "value":
                        [
                            "NRPLMN-2"
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "sd",
                    "value": "8",
                    "operation": "update"
                },
                {
                    "parameterName": "sst",
                    "value": "1",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-7",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "NRPLMN-1",
                    "operation": "update"
                },
                {
                    "parameterName": "spid",
                    "value": "141",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "160",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-8",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "NRPLMN-2",
                    "operation": "update"
                },
                {
                    "parameterName": "spid",
                    "value": "161",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "180",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-9",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "NRSPIDGRP-5"
                            },
                            {
                                "resourceDN": "NRSPIDGRP-4"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "NRSPIDGRP-3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC015_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/SNSSAI-2"
                            },
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/NRSPIDGRP-3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/NRSPIDGRP-2"
                            },
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/SNSSAI-3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-5",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/SNSSAI-5"
                            },
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/NRSPIDGRP-6"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-6",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/NRSPIDGRP-5"
                            },
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/SNSSAI-6"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC024_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "defaultRgNsaList",
                    "value":
                        [
                            {
                                "nrPlmnDN": "NRPLMN-1",
                                "nrResourceGroupId": "4"
                            },
                            {
                                "nrPlmnDN": "NRPLMN-2",
                                "nrResourceGroupId": "7"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "defaultRgSaList",
                    "value":
                        [
                            {
                                "nrPlmnDN": "NRPLMN-1",
                                "nrResourceGroupId": "3"
                            },
                            {
                                "nrPlmnDN": "NRPLMN-2",
                                "nrResourceGroupId": "7"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC031_1_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/NRSPIDGRP-4"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-4",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/NRSPIDGRP-3"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC031_2_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "MRBTS-1/NRBTS-1/NRPLMN-2",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-5",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC031_3_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-8",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "MRBTS-1/NRBTS-1/NRPLMN-1",
                    "operation": "update"
                },
                {
                    "parameterName": "spid",
                    "value": "161",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "180",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-9",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "MRBTS-1/NRBTS-1/NRPLMN-2",
                    "operation": "update"
                },
                {
                    "parameterName": "spid",
                    "value": "181",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "200",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-8",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/NRSPIDGRP-8"
                            },
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/NRSPIDGRP-9"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "40",
                                "minQuota": "10"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]

CB008709_K_TC031_4_ONLINE_CHANGE_DELTA = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1",
        "operation": "update",
        "parameters":
            [
                {
                    "parameterName": "defaultRgNsaList",
                    "value":
                        [
                            {
                                "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-1",
                                "nrResourceGroupId": "2"
                            },
                            {
                                "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-2",
                                "nrResourceGroupId": "9"
                            }
                        ],
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-6",
        "operation": "delete",
        "parameters":
            []
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-6",
        "operation": "delete",
        "parameters":
            []
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRSPIDGRP-10",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrPlmnDN",
                    "value": "MRBTS-1/NRBTS-1/NRPLMN-2",
                    "operation": "update"
                },
                {
                    "parameterName": "spid",
                    "value": "201",
                    "operation": "update"
                },
                {
                    "parameterName": "spidLast",
                    "value": "220",
                    "operation": "update"
                }
            ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-9",
        "operation": "create",
        "parameters":
            [
                {
                    "parameterName": "nrResourceList",
                    "value":
                        [
                            {
                                "resourceDN": "MRBTS-1/NRBTS-1/NRSPIDGRP-10"
                            }
                        ],
                    "operation": "update"
                },
                {
                    "parameterName": "schedulerParams",
                    "value":
                        [
                            {
                                "maxQuota": "60",
                                "minQuota": "10"
                            }
                        ],
                    "operation": "update"
                }
            ]
    }
]
