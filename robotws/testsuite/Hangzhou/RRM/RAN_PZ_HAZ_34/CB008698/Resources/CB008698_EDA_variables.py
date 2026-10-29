from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_enb_id = str(tl.enbs[0].instance_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-' + _global_id
_MRBTSname2 = 'MRBTS-' + _gnb_id2
_MRBTSname_enb = 'MRBTS-' + _global_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_NRBTSname2 = _MRBTSname2 + '/NRBTS-' + _gnb_id2
_LNBTSname = _MRBTSname_enb + '/LNBTS-' + _enb_id
_LTECELLname = _LNBTSname + '/LNCEL-4'
_LTECELL48040name = _LNBTSname + '/LNCEL-48040'
_LTECELL48041name = _LNBTSname + '/LNCEL-48041'
_LTECELL48042name = _LNBTSname + '/LNCEL-48042'
_LTECELL48043name = _LNBTSname + '/LNCEL-48043'
_LTECELL48044name = _LNBTSname + '/LNCEL-48044'
_LTECELL48045name = _LNBTSname + '/LNCEL-48045'
_LTECELL48046name = _LNBTSname + '/LNCEL-48046'
_LTECELL48047name = _LNBTSname + '/LNCEL-48047'
_LTECELL48048name = _LNBTSname + '/LNCEL-48048'
_LTECELL48049name = _LNBTSname + '/LNCEL-48049'
_NRCELLname = _NRBTSname + '/NRCELL-1'
_NRCELL2name = _NRBTSname + '/NRCELL-2'
_NRCELL3name = _NRBTSname + '/NRCELL-3'
_NRCELL4name = _NRBTSname + '/NRCELL-4'
_NRCELL21name = _NRBTSname + '/NRCELL-21'
_NRCELL400name = _NRBTSname + '/NRCELL-400'
_NRCELL410name = _NRBTSname + '/NRCELL-410'
_NRCELL544name = _NRBTSname + '/NRCELL-544'
_NRCELL545name = _NRBTSname + '/NRCELL-545'
_NRCELL644name = _NRBTSname + '/NRCELL-644'
_NRCELL645name = _NRBTSname + '/NRCELL-645'
_NRCELL700name = _NRBTSname + '/NRCELL-700'
_NRCELL701name = _NRBTSname + '/NRCELL-701'
_NRBTSDUname = _NRBTSname + '/NRDU-9999'
_NRBTSDUname2 = _NRBTSname2 + '/NRDU-1'
_NRCELLname2 = _NRBTSname2 + '/NRCELL-1'
_NRBTSDUnameGRPgNB1cell = _NRBTSname + '/NRCELLGRP-0'
_NRBTSDUnameGRPgNB1cell2 = _NRBTSname + '/NRCELLGRP-1'
_NRREL1namegnb1 = _NRCELLname + '/NRREL-1'
_NRREL2namegnb1 = _NRCELLname + '/NRREL-2'
_NRREL3namegnb1 = _NRCELLname + '/NRREL-3'
_NRRELLnamegnb1 = _NRCELL2name + '/NRREL-0'
_NRRELLnamegnb11 = _NRCELL2name + '/NRREL-1'
_NRRELLnamegnb12 = _NRCELL2name + '/NRREL-2'
_NRRELL400namegnb12 = _NRCELL400name + '/NRREL-2'
_NRRELLnamegnb13 = _NRCELL2name + '/NRREL-3'
_NRRELLnamegnb2 = _NRCELLname2 + '/NRREL-2'
_NRRELLnamegnb20 = _NRCELLname2 + '/NRREL-1'
_NRREL21namegnb1 = _NRCELL2name + '/NRREL-1'
_SERVEDAMF = _NRBTSname + '/SERVEDAMF-1'
_NRCELL1_FDD1 = _NRCELLname + '/NRCELL_FDD-1'
_NRCELL2_FDD1 = _NRCELL2name + '/NRCELL_FDD-1'
_NRCELL400_FDD1 = _NRCELL400name + '/NRCELL_FDD-1'
_BWP_PROFILE_0 = _NRBTSname + '/BWP_PROFILE-0'
_BWP_PROFILE_7 = _NRBTSname + '/BWP_PROFILE-7'
_BWP_PROFILE_8 = _NRBTSname + '/BWP_PROFILE-8'
_NRULCG_PROFILE_2 = _NRBTSname + '/NRULCG_PROFILE-2'
_NRDRB_13 = _NRBTSname + '/NRDRB-13'
_NRPMRNL = _NRBTSname + '/NRPMRNL-1'
_NRDLMUMIMO_1_700 = _NRCELL700name + '/NRDLMUMIMO-1'
_NRDRB_MAC_2 = _NRBTSname + '/NRDRB_MAC-2'

NRCELL400name = _NRBTSname + '/NRCELL-400'
NRCELL410name = _NRBTSname + '/NRCELL-410'
NRCELL544name = _NRBTSname + '/NRCELL-544'
NRCELL545name = _NRBTSname + '/NRCELL-545'
NRCELL644name = _NRBTSname + '/NRCELL-644'
NRCELL645name = _NRBTSname + '/NRCELL-645'
NRCELL700name = _NRBTSname + '/NRCELL-700'
NRCELL701name = _NRBTSname + '/NRCELL-701'

# UE part
all_ue_index = [0, 1, 2]
EDA_05272546_ue_index_CASE_1 = [1, 0]
EDA_05272546_ue_index_CASE_2 = [1, 0]
is_new_Qcom_ue_type = [False, True, True]
UES_TYPE = [tl.ues[0].capabilities[0], tl.ues[1].capabilities[0], tl.ues[2].capabilities[0]]
DXDATA2_APN = '95 1030'
CLICK_ACCESS_POINT = '380 1060'
TRAFFIC_DL_PORT = tl.ues[0].iperf_details.port
TRAFFIC_UL_PORT = tl.ues[0].iperf_details.ssh_connection_details.port

# LOG NAME
UE_ATTACH_WIRESHARK = ['ATTACH_LOG_0.pcap', 'ATTACH_LOG_1.pcap', 'ATTACH_LOG_2.pcap']
EXCEL_KPI_PATH = '/opt/workspace/SCF/Excel_KPI/'
EXCEL_KPI_FILE_NAME = 'QoS_explore_testing.xlsx'
EXECUTOR_FILE_PATH = '/opt/workspace/SCF/'

# CELL CHECK
cells_EDA_05272546 = [NRCELL400name,
                      NRCELL410name,
                      NRCELL544name,
                      NRCELL545name,
                      NRCELL644name,
                      NRCELL645name,
                      NRCELL700name,
                      NRCELL701name]
cells_EDA_05272546_states_disabled = ['disabled',
                                      'disabled',
                                      'disabled',
                                      'disabled',
                                      'disabled',
                                      'disabled',
                                      'disabled',
                                      'disabled'
                                      ]
cells_EDA_05272546_states_enabled = ['enabled',
                                     'enabled',
                                     'enabled',
                                     'enabled',
                                     'enabled',
                                     'enabled',
                                     'enabled',
                                     'enabled'
                                     ]

# GNB PARAS
PARAMETERS_EDA_05272546_JSON_FILE = 'PARAMETERS_EDA_05272546_JSON_FILE.json'
PARAMETERS_EDA_05272546 = [
    {
        "distName": _LTECELL48040name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "locked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _LTECELL48045name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "locked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL400name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "0"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPriorityAccess",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "maxNumOfCaUsersNRCell",
                "operation": "update",
                "value": "2"
            },
            {
                "parameterName": "maxNumOfNonGBRBearersSA",
                "operation": "update",
                "value": "2"
            },
            {
                "parameterName": "maxNumOfNrDcSnUsers",
                "operation": "update",
                "value": "3"
            },
            {
                "parameterName": "maxNumOfRrcSA",
                "operation": "update",
                "value": "2"
            },
            {
                "parameterName": "maxNumOfRrcSARedCap",
                "operation": "update",
                "value": "0"
            },
            {
                "parameterName": "maxNumOfSCellAlloc",
                "operation": "update",
                "value": "2"
            },
            {
                "parameterName": "maxNumOfUsersPerCell",
                "operation": "update",
                "value": "2"
            },
            {
                "parameterName": "maxNumOfUsersPerNRCell",
                "operation": "update",
                "value": "3"
            }
        ]
    },
    {
        "distName": _NRCELL410name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL544name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL545name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL644name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL645name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    }, {
        "distName": _NRCELL700name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL701name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cipherPrefL",
                "operation": "update",
                "value": [
                    dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')
                ]
            },
            {
                "parameterName": "integrityProtPrefL",
                "operation": "update",
                "value": [
                    dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')
                ]
            },
            {
                "parameterName": "actDrbPreemption",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actSliceAwareAdmissionCtrl",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "maxNumOfPreemptions",
                "operation": "update",
                "value": "4"
            },
            {
                "parameterName": "actUserPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRBTSDUname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfDrbsReservForTempUse",
                "operation": "update",
                "value": "120"
            }
        ]
    }
]
PARAMETERS_RECOVER_EDA_05272546_JSON_FILE = 'PARAMETERS_RECOVER_EDA_05272546_JSON_FILE.json'
PARAMETERS_RECOVER_EDA_05272546 = [
    {
        "distName": _LTECELL48040name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "unlocked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _LTECELL48045name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "unlocked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL400name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "1"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            },
            {
                "parameterName": "actPriorityAccess",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "maxNumOfCaUsersNRCell",
                "operation": "update",
                "value": "128"
            },
            {
                "parameterName": "maxNumOfNonGBRBearersSA",
                "operation": "update",
                "value": "550"
            },
            {
                "parameterName": "maxNumOfNrDcSnUsers",
                "operation": "update",
                "value": "192"
            },
            {
                "parameterName": "maxNumOfRrcSA",
                "operation": "update",
                "value": "275"
            },
            {
                "parameterName": "maxNumOfRrcSARedCap",
                "operation": "update",
                "value": "200"
            },
            {
                "parameterName": "maxNumOfSCellAlloc",
                "operation": "update",
                "value": "192"
            },
            {
                "parameterName": "maxNumOfUsersPerCell",
                "operation": "update",
                "value": "192"
            },
            {
                "parameterName": "maxNumOfUsersPerNRCell",
                "operation": "update",
                "value": "275"
            }
        ]
    },
    {
        "distName": _NRCELL410name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL544name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL545name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL644name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL645name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    }, {
        "distName": _NRCELL700name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL701name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cipherPrefL",
                "operation": "update",
                "value": [
                    dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')
                ]
            },
            {
                "parameterName": "integrityProtPrefL",
                "operation": "update",
                "value": [
                    dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')
                ]
            },
            {
                "parameterName": "actDrbPreemption",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actSliceAwareAdmissionCtrl",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "maxNumOfPreemptions",
                "operation": "delete",
                "value": "4"
            },
            {
                "parameterName": "actUserPreemption",
                "operation": "update",
                "value": "false"
            }
        ]
    },
    {
        "distName": _NRBTSDUname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfDrbsReservForTempUse",
                "operation": "delete",
                "value": "120"
            }
        ]
    }
]

PARAMETERS_EDA_05272546_CASE_2_JSON_FILE = 'PARAMETERS_EDA_05272546_CASE_2_JSON_FILE.json'
PARAMETERS_EDA_05272546_CASE_2 = [
    {
        "distName": _LTECELL48040name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "locked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _LTECELL48045name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "locked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL400name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "0"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPriorityAccess",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "maxNumOfCaUsersNRCell",
                "operation": "update",
                "value": "2"
            },
            {
                "parameterName": "maxNumOfNonGBRBearersSA",
                "operation": "update",
                "value": "24"
            },
            {
                "parameterName": "maxNumOfNrDcSnUsers",
                "operation": "update",
                "value": "3"
            },
            {
                "parameterName": "maxNumOfRrcSA",
                "operation": "update",
                "value": "24"
            },
            {
                "parameterName": "maxNumOfRrcSARedCap",
                "operation": "update",
                "value": "0"
            },
            {
                "parameterName": "maxNumOfSCellAlloc",
                "operation": "update",
                "value": "2"
            },
            {
                "parameterName": "maxNumOfUsersPerCell",
                "operation": "update",
                "value": "2"
            },
            {
                "parameterName": "maxNumOfUsersPerNRCell",
                "operation": "update",
                "value": "24"
            },
            {
                "parameterName": "numOfRadioResReservForPa",
                "operation": "update",
                "value": "39"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "1"
            },
            {
                "parameterName": "preferredVoNrSrPeriod",
                "operation": "update",
                "value": "slots20"
            },
            {
                "parameterName": "reqMinNumPuschPrb",
                "operation": "update",
                "value": "100"
            },
            {
                "parameterName": "srPeriodicity",
                "operation": "update",
                "value": "slots20"
            },
            {
                "parameterName": "srPeriodicityMin",
                "operation": "update",
                "value": "slots5"
            },
            {
                "parameterName": "periodicCsiAcquisition",
                "operation": "update",
                "value": [
                    dict(csiReportPeriodicity='slots20', scramblingIdStep='3')
                ]
            }
        ]
    },
    {
        "distName": _NRCELL410name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL544name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL545name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL644name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL645name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    }, {
        "distName": _NRCELL700name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL701name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cipherPrefL",
                "operation": "update",
                "value": [
                    dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')
                ]
            },
            {
                "parameterName": "integrityProtPrefL",
                "operation": "update",
                "value": [
                    dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')
                ]
            },
            {
                "parameterName": "actDrbPreemption",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actSliceAwareAdmissionCtrl",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "maxNumOfPreemptions",
                "operation": "update",
                "value": "4"
            },
            {
                "parameterName": "actUserPreemption",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRBTSDUname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfDrbsReservForTempUse",
                "operation": "update",
                "value": "120"
            }
        ]
    }
]
PARAMETERS_RECOVER_EDA_05272546_CASE_2_JSON_FILE = 'PARAMETERS_RECOVER_EDA_05272546_CASE_2_JSON_FILE.json'
PARAMETERS_RECOVER_EDA_05272546_CASE_2 = [
    {
        "distName": _LTECELL48040name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "unlocked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _LTECELL48045name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "unlocked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL400name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "1"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            },
            {
                "parameterName": "actPriorityAccess",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "maxNumOfCaUsersNRCell",
                "operation": "update",
                "value": "128"
            },
            {
                "parameterName": "maxNumOfNonGBRBearersSA",
                "operation": "update",
                "value": "550"
            },
            {
                "parameterName": "maxNumOfNrDcSnUsers",
                "operation": "update",
                "value": "192"
            },
            {
                "parameterName": "maxNumOfRrcSA",
                "operation": "update",
                "value": "275"
            },
            {
                "parameterName": "maxNumOfRrcSARedCap",
                "operation": "update",
                "value": "200"
            },
            {
                "parameterName": "maxNumOfSCellAlloc",
                "operation": "update",
                "value": "192"
            },
            {
                "parameterName": "maxNumOfUsersPerCell",
                "operation": "update",
                "value": "192"
            },
            {
                "parameterName": "maxNumOfUsersPerNRCell",
                "operation": "update",
                "value": "275"
            },
            {
                "parameterName": "numOfRadioResReservForPa",
                "operation": "update",
                "value": "0"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "update",
                "value": "0"
            },
            {
                "parameterName": "preferredVoNrSrPeriod",
                "operation": "update",
                "value": "slots40"
            },
            {
                "parameterName": "reqMinNumPuschPrb",
                "operation": "update",
                "value": "19"
            },
            {
                "parameterName": "srPeriodicity",
                "operation": "update",
                "value": "slots80"
            },
            {
                "parameterName": "srPeriodicityMin",
                "operation": "update",
                "value": "slots40"
            },
            {
                "parameterName": "periodicCsiAcquisition",
                "operation": "update",
                "value": [
                    dict(csiReportPeriodicity='slots160', scramblingIdStep='3')
                ]
            }
        ]
    },
    {
        "distName": _NRCELL410name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL544name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL545name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL644name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL645name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    }, {
        "distName": _NRCELL700name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRCELL701name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEmPaPreemptionWithRgRac",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "allowEmergencyReservForTempUse",
                "operation": "delete",
                "value": "false"
            },
            {
                "parameterName": "numOfRadioResReservForTempUse",
                "operation": "delete",
                "value": "30"
            },
            {
                "parameterName": "preferNsaPreemption",
                "operation": "delete",
                "value": "true"
            }
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cipherPrefL",
                "operation": "update",
                "value": [
                    dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')
                ]
            },
            {
                "parameterName": "integrityProtPrefL",
                "operation": "update",
                "value": [
                    dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')
                ]
            },
            {
                "parameterName": "actDrbPreemption",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actSliceAwareAdmissionCtrl",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "maxNumOfPreemptions",
                "operation": "delete",
                "value": "4"
            },
            {
                "parameterName": "actUserPreemption",
                "operation": "update",
                "value": "false"
            }
        ]
    },
    {
        "distName": _NRBTSDUname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfDrbsReservForTempUse",
                "operation": "delete",
                "value": "120"
            }
        ]
    }
]

# PA
RU_PA_info = [
    {
        'att_ipaddr': tl.attenuator[0].ip_addr,
        'ports': [tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no,
                  tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no,
                  tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no,
                  tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no]},
    {
        'att_ipaddr': tl.attenuator[0].ip_addr,
        'ports': [tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no,
                  tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no,
                  tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no,
                  tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no]},
    {
        'att_ipaddr': tl.attenuator[0].ip_addr,
        'ports': [tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no,
                  tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no,
                  tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no,
                  tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no]},
    {
        'att_ipaddr': tl.attenuator[0].ip_addr,
        'ports': [tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no,
                  tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no,
                  tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no,
                  tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no]},
    {
        'att_ipaddr': tl.attenuator[1].ip_addr,
        'ports': [tl.gnbs[0].dus[0].rus[4].attenuation_ports[0].port_no,
                  tl.gnbs[0].dus[0].rus[4].attenuation_ports[1].port_no,
                  tl.gnbs[0].dus[0].rus[4].attenuation_ports[2].port_no,
                  tl.gnbs[0].dus[0].rus[4].attenuation_ports[3].port_no]},
    {
        'att_ipaddr': tl.attenuator[1].ip_addr,
        'ports': [tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no,
                  tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no,
                  tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no,
                  tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no]}
]

PARAMETERS_EDA_05272546_PA_INITIAL_VALUE = [0, 0, 0, 0]
PARAMETERS_EDA_05272546_PA_TARGET_VALUE = [30, 30, 30, 30]
PARAMETERS_EDA_05272546_PA_STEP = 2
PARAMETERS_CB009189_PA_INITIAL_VALUE = [10, 10, 10, 10]
PARAMETERS_CB009189_PA_TARGET_VALUE = [82, 82, 82, 82]
PARAMETERS_CB009189_PA_STEP = 3
PARAMETERS_CB008126_8234_PA_INITIAL_VALUE = [10, 10, 10, 10]
RECOVER_PA_MAX_VALUE = [127, 127, 127, 127]

EDA_05272546_counter_ids_CASE_1 = ['M55139C00013']
EDA_05272546_counter_ids_CASE_2 = ['M55139C00010']
EDA_05272546_dic_paths = [f'BTS/{_NRBTSname}/NRCELL-400/RSADU']
EDA_05272546_expected_values = [1]
