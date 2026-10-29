"""
:copyright: Nokia Networks
:author: Damian Zak, Mateusz Plinta, Mateusz Pajor, Damian Piasecki
:maintainer: Damian Zak, Mateusz Plinta, Mateusz Pajor
:contact: damian.zak@nokia.com, mateusz.plinta@nokia.com, mateusz.pajor@nokia.com, damian.piasecki@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG, MN_RAN_L2_SW_2_KRK_Vrf_SG
"""


def REMOVE_UL_SUBCELLS_TEMPLATE(cell_id):
    return [
        {
            "distName": f"MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{cell_id}/CHANNELGROUP-1/CHANNEL-2",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "direction",
                    "value": "TX",
                    "operation": "update"
                }
            ]
        },
        {
            "distName": f"MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{cell_id}/CHANNELGROUP-1/CHANNEL-3",
            "operation": "delete",
            "parameters": []
        },
        {
            "distName": f"MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{cell_id}/CHANNELGROUP-1/CHANNEL-4",
            "operation": "delete",
            "parameters": []
        },
        {
            "distName": f"MRBTS-1/NRBTS-1/NRCELL-{cell_id}",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "nrCellType",
                    "value": "2DL0UL",
                    "operation": "update"
                }
            ]
        }
    ]


def ADD_UL_SUBCELLS_TEMPLATE(cell_id):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/NRCELL-{cell_id}",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "nrCellType",
                    "value": "2DL2UL",
                    "operation": "update"
                }
            ]
        },
        {
            "distName": f"MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{cell_id}/CHANNELGROUP-1/CHANNEL-2",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "direction",
                    "value": "RX",
                    "operation": "update"
                }
            ]
        },
        {
            "distName": f"MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{cell_id}/CHANNELGROUP-1/CHANNEL-3",
            "operation": "create",
            "parameters": [
                {
                    "parameterName": "direction",
                    "value": "TX",
                    "operation": "update"
                },
                {
                    "parameterName": "resourceDN",
                    "value": "MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1",
                    "operation": "update"
                }
            ]
        },
        {
            "distName": f"MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{cell_id}/CHANNELGROUP-1/CHANNEL-4",
            "operation": "create",
            "parameters": [
                {
                    "parameterName": "direction",
                    "value": "RX",
                    "operation": "update"
                },
                {
                    "parameterName": "resourceDN",
                    "value": "MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1",
                    "operation": "update"
                }
            ]
        }
    ]


def UNSET_PRIMARY_CELL_TEMPLATE(cell_id):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/NRCELL-{cell_id}",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "cellBarred",
                    "value": "barred",
                    "operation": "update"
                },
                {
                    "parameterName": "intraFreqReselection",
                    "value": "notAllowed",
                    "operation": "update"
                },
                {
                    "parameterName": "sCellOnlyFr2Sa",
                    "value": "true",
                    "operation": "update"
                }
            ]
        }
    ]


def SET_PRIMARY_CELL_TEMPLATE(cell_id):
    return [
        {
            "distName": f"MRBTS-1/NRBTS-1/NRCELL-{cell_id}",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "cellBarred",
                    "value": "notBarred",
                    "operation": "update"
                },
                {
                    "parameterName": "intraFreqReselection",
                    "value": "allowed",
                    "operation": "update"
                },
                {
                    "parameterName": "sCellOnlyFr2Sa",
                    "value": "false",
                    "operation": "update"
                }
            ]
        }
    ]


DELTA_A_B307_TC1 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELLGRP-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numberOfTransmittedSsBlocks",
                "value": "1 beam",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B307_TC2 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "6",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELLGRP-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numberOfTransmittedSsBlocks",
                "value": "1 beam",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B307_TC3 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "1",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELLGRP-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numberOfTransmittedSsBlocks",
                "value": "1 beam",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B307_TC4 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "1",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELLGRP-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numberOfTransmittedSsBlocks",
                "value": "1 beam",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B307_TC5 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELLGRP-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numberOfTransmittedSsBlocks",
                "value": "1 beam",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B311_TC1 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "6",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferBased",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B311_TC2 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferBased",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B311_TC3 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferBased",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B311_TC4 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferBased",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B311_TC5 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferBased",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms1280",
                "operation": "update"
            }
        ]
    }
]

DELTA_B_B101_TC1 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actOverheatingAssistance",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferBased",
                "operation": "update"
            },
            {
                "parameterName": "timerOverheatIndProhibit",
                "value": "2s",
                "operation": "update"
            },
            {
                "parameterName": "timerPostOverheating",
                "value": "0",
                "operation": "update"
            }
        ]
    }
]

DELTA_B_B101_TC2 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actOverheatingAssistance",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferBased",
                "operation": "update"
            },
            {
                "parameterName": "timerOverheatIndProhibit",
                "value": "2s",
                "operation": "update"
            },
            {
                "parameterName": "timerPostOverheating",
                "value": "0",
                "operation": "update"
            }
        ]
    }
]

DELTA_B_B101_TC3 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actOverheatingAssistance",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "mcsDeactSCellDl",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "mcsDeactSCellUl",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "pathlossDeltaActSCellDl",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "pathlossDeltaActSCellUl",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferAndRLQualityBased",
                "operation": "update"
            },
            {
                "parameterName": "timerOverheatIndProhibit",
                "value": "2s",
                "operation": "update"
            },
            {
                "parameterName": "timerPostOverheating",
                "value": "0",
                "operation": "update"
            }
        ]
    }
]

DELTA_B_B101_TC4 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actOverheatingAssistance",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "6",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferBased",
                "operation": "update"
            },
            {
                "parameterName": "timerOverheatIndProhibit",
                "value": "2s",
                "operation": "update"
            },
            {
                "parameterName": "timerPostOverheating",
                "value": "0",
                "operation": "update"
            }
        ]
    }
]

DELTA_B_B101_TC5 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actOverheatingAssistance",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSCellReleaseBadSCellRlq",
                "value": "enabled_Fr1",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "mcsDeactSCellDl",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "mcsDeactSCellUl",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "pathlossDeltaActSCellDl",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "pathlossDeltaActSCellUl",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferAndRLQualityBased",
                "operation": "update"
            },
            {
                "parameterName": "sCellDeactivationBadRlqCount",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "sCellExcludelistTimerFr1",
                "value": "20",
                "operation": "update"
            },
            {
                "parameterName": "timerOverheatIndProhibit",
                "value": "2s",
                "operation": "update"
            },
            {
                "parameterName": "timerPostOverheating",
                "value": "0",
                "operation":
                    "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "4",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "4",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "4",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "4",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "4",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "4",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "4",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "4",
                "operation": "update"
            }
        ]
    }
]

DELTA_B_B101_TC6 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actOverheatingAssistance",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "sCellActivationMethod",
                "value": "bufferBased",
                "operation": "update"
            },
            {
                "parameterName": "timerOverheatIndProhibit",
                "value": "2s",
                "operation": "update"
            },
            {
                "parameterName": "timerPostOverheating",
                "value": "0",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B6_TC2 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-9",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-10",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            }
        ]
    }
]

DELTA_ROBUSTNESS = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "mcsDeactSCellDl",
                "value": "10"
            },
            {
                "operation": "update",
                "parameterName": "mcsDeactSCellUl",
                "value": "10"
            },
            {
                "operation": "update",
                "parameterName": "pathlossDeltaActSCellDl",
                "value": "3"
            },
            {
                "operation": "update",
                "parameterName": "pathlossDeltaActSCellUl",
                "value": "3"
            },
            {
                "operation": "update",
                "parameterName": "sCellActivationMethod",
                "value": "bufferAndRLQualityBased"
            },
            {
                "operation": "update",
                "parameterName": "sCellDeactivationBadRlqCount",
                "value": "10"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms160"
            },
            {
                "operation": "update",
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "25"
            },
            {
                "operation": "update",
                "parameterName": "bufferThesholdSCellDePrioritize",
                "value": "300000"
            },
            {
                "operation": "update",
                "parameterName": "sCellDePrioritizeEvalPeriod",
                "value": "1000"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThUL",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThreshold",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "15"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms160"
            },
            {
                "operation": "update",
                "parameterName": "bufferThesholdSCellDePrioritize",
                "value": "300000"
            },
            {
                "operation": "update",
                "parameterName": "sCellDePrioritizeEvalPeriod",
                "value": "1000"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThUL",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThreshold",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "15"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms160"
            },
            {
                "operation": "update",
                "parameterName": "bufferThesholdSCellDePrioritize",
                "value": "300000"
            },
            {
                "operation": "update",
                "parameterName": "sCellDePrioritizeEvalPeriod",
                "value": "1000"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThUL",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThreshold",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "15"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms160"
            },
            {
                "operation": "update",
                "parameterName": "bufferThesholdSCellDePrioritize",
                "value": "300000"
            },
            {
                "operation": "update",
                "parameterName": "sCellDePrioritizeEvalPeriod",
                "value": "1000"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThUL",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThreshold",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "15"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms160"
            },
            {
                "operation": "update",
                "parameterName": "bufferThesholdSCellDePrioritize",
                "value": "300000"
            },
            {
                "operation": "update",
                "parameterName": "sCellDePrioritizeEvalPeriod",
                "value": "1000"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThUL",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThreshold",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "15"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms160"
            },
            {
                "operation": "update",
                "parameterName": "bufferThesholdSCellDePrioritize",
                "value": "300000"
            },
            {
                "operation": "update",
                "parameterName": "sCellDePrioritizeEvalPeriod",
                "value": "1000"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThUL",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThreshold",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "15"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms160"
            },
            {
                "operation": "update",
                "parameterName": "bufferThesholdSCellDePrioritize",
                "value": "300000"
            },
            {
                "operation": "update",
                "parameterName": "sCellDePrioritizeEvalPeriod",
                "value": "1000"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThUL",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThreshold",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "15"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "sCellDeactivationTimerGNB",
                "value": "ms160"
            },
            {
                "operation": "update",
                "parameterName": "bufferThesholdSCellDePrioritize",
                "value": "300000"
            },
            {
                "operation": "update",
                "parameterName": "sCellDePrioritizeEvalPeriod",
                "value": "1000"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThUL",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellBadChannelQualityThreshold",
                "value": "12"
            },
            {
                "operation": "update",
                "parameterName": "sCellGoodChannelQualityThreshold",
                "value": "15"
            }
        ]
    }
]

DELTA_A_B6_TC3 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-9",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-10",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B6_TC4 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDl",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUl",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-9",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-10",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B6_TC5 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDl",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUl",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-9",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-10",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B6_TC6 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDl",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUl",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "value": "barred",
                "operation": "update"
            },
            {
                "parameterName": "intraFreqReselection",
                "value": "notAllowed",
                "operation": "update"
            },
            {
                "parameterName": "sCellOnlyFr2Sa",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "value": "notBarred",
                "operation": "update"
            },
            {
                "parameterName": "intraFreqReselection",
                "value": "allowed",
                "operation": "update"
            },
            {
                "parameterName": "sCellOnlyFr2Sa",
                "value": "false",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-9",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-10",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B6_TC7 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDl",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUl",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "value": "barred",
                "operation": "update"
            },
            {
                "parameterName": "intraFreqReselection",
                "value": "notAllowed",
                "operation": "update"
            },
            {
                "parameterName": "sCellOnlyFr2Sa",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "value": "notBarred",
                "operation": "update"
            },
            {
                "parameterName": "intraFreqReselection",
                "value": "allowed",
                "operation": "update"
            },
            {
                "parameterName": "sCellOnlyFr2Sa",
                "value": "false",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-9",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-10",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B6_TC8 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDl",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUl",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "value": "barred",
                "operation": "update"
            },
            {
                "parameterName": "intraFreqReselection",
                "value": "notAllowed",
                "operation": "update"
            },
            {
                "parameterName": "sCellOnlyFr2Sa",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "value": "notBarred",
                "operation": "update"
            },
            {
                "parameterName": "intraFreqReselection",
                "value": "allowed",
                "operation": "update"
            },
            {
                "parameterName": "sCellOnlyFr2Sa",
                "value": "false",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-9",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-10",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B6_TC9 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDl",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUl",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf5To8CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf5To8CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf5To8CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf5To8CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf5To8CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf5To8CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf5To8CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf5To8CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-9",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-10",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B6_TC10 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsDl",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUl",
                "value": "3",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf3To4CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf3To4CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf3To4CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf3To4CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf3To4CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf3To4CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf3To4CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf3To4CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-9",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-10",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "true",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B7_TC2 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "6",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B7_TC3 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B7_TC6 = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf2CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf2CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf2CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf2CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf2CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf2CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf2CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumOf2CCUsersFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    }
]

DELTA_D_B101_TC1 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "rrcReestabTypeSA",
                "value": "viaRRCSetup",
                "operation": "update"
            }
        ]
    }
]

DELTA_D_B101_TC2 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "rrcReestabTypeSA",
                "value": "deactivated",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "t301",
                "value": "1000ms",
                "operation": "update"
            }
        ]
    }
]

DELTA_A_B307_TC4 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "1",
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-3",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-4",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-5",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-6",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-7",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-8",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actBeamforming",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "beamSet",
                "value": [
                    {
                        "basicBeamSet": "beamSetAbf_1A",
                        "leftEdgeAngle": "60",
                        "lowerEdgeAngle": "90",
                        "rightEdgeAngle": "60",
                        "upperEdgeAngle": "60"
                    }
                ],
                "operation": "update"
            }
        ]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELLGRP-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numberOfTransmittedSsBlocks",
                "value": "1 beam",
                "operation": "update"
            }
        ]
    }
]

DELTA_E_B101_TC1 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "7",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            }
        ]
    }
]

DELTA_E_B101_TC2 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "6",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            }
        ]
    }
]

DELTA_E_B101_TC3 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            }
        ]
    }
]

DELTA_E_B101_TC4 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            }
        ]
    }
]

DELTA_E_B101_TC5 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "3",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "3",
                "operation": "update"
            }
        ]
    }
]

DELTA_E_B101_TC6 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "2",
                "operation": "update"
            }
        ]
    }
]

DELTA_E_B101_TC7 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "1",
                "operation": "update"
            }
        ]
    }
]

DELTA_E_B101_TC8 = [
    {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumScellsDlFr2SA",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "maxNumScellsUlFr2SA",
                "value": "1",
                "operation": "update"
            }
        ]
    }
]
