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
NRCELL700name = _NRBTSname + '/NRCELL-700'

# UE part
all_ue_index = [0, 1, 2]
CB008236_PUSCH_slot_aggregation_ue_index = [0, 2]
CB009189_ue_index = [2]
CB008126_8234_ue_index = [2]
is_new_Qcom_ue_type = [False, True, True]
UES_TYPE = [tl.ues[0].capabilities[0], tl.ues[1].capabilities[0], tl.ues[2].capabilities[0]]
DXDATA2_APN = '95 1030'
CLICK_ACCESS_POINT = '380 1060'
expected_tput_dl = '1'
Send_Tput_DL = '400M'
expected_tput_ul = '1'
Send_Tput_UL = '200M'
expected_tput_dl_9189 = '1'
Send_Tput_DL_9189 = '2000M'
expected_tput_ul_9189 = '1'
Send_Tput_UL_9189 = '400M'
expected_tput_dl_8126_8234 = '1'
Send_Tput_DL_8126_8234 = '400M'
expected_tput_ul_8126_8234 = '1'
Send_Tput_UL_8126_8234 = '100M'
TRAFFIC_DL_PORT = tl.ues[0].iperf_details.port
TRAFFIC_UL_PORT = tl.ues[0].iperf_details.ssh_connection_details.port

# LOG NAME
UE_ATTACH_WIRESHARK = ['ATTACH_LOG_0.pcap', 'ATTACH_LOG_1.pcap', 'ATTACH_LOG_2.pcap']
EXCEL_KPI_PATH = '/opt/workspace/SCF/Excel_KPI/'
EXCEL_KPI_FILE_NAME = 'QoS_explore_testing.xlsx'
EXECUTOR_FILE_PATH = '/opt/workspace/SCF/'
EXECUTOR_FILE_8126_8234 = 'sessionAmbr_mofidy_8126_8234.txt'
MODIFY_SESSION_AMBR_VALUE_WIRESHARK = 'MODIFY_SESSION_AMBR_VALUE_LOG'
MODIFY_SESSION_AMBR_INITIAL_VALUE_WIRESHARK = 'MODIFY_SESSION_AMBR_INITIAL_VALUE_LOG'
MODIFY_SESSION_AMBR_VALUE_TXT = 'PDU_AMBR_DL_80_UL_5.txt'
RECOVER_MODIFY_SESSION_AMBR_VALUE_TXT = 'PDU_AMBR_DL_initial_UL_initial.txt'
CB008236_adjust_pa_to_trigger_pcap = 'CB008236_adjust_pa_to_trigger.pcap'

# CELL CHECK
cells_CB008236_PUSCH_slot_aggregation = [NRCELL400name]
cells_CB008236_PUSCH_slot_aggregation_states_disabled = ['disabled']
cells_CB008236_PUSCH_slot_aggregation_states_enabled = ['enabled']
cells_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions = [NRCELL700name]
cells_QoS_Flow_Modification_CB008234_UE_AMBR_SA = [NRCELL700name]
cells_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions_states_disabled = ['disabled']
cells_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions_states_enabled = ['enabled']
cells_QoS_Flow_Modification_CB008234_UE_AMBR_SA_states_enabled = ['enabled']
cells_QoS_Flow_Modification_CB008234_UE_AMBR_SA_states_disabled = ['disabled']

# GNB PARAS
PARAMETERS_CB008236_JSON_FILE = 'PARAMETERS_CB008236_JSON_FILE.json'
PARAMETERS_CB008236_PUSCH_slot_aggregation_FDD_NPI_FOT = [
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
                "parameterName": "ulTransPrecodeCtl",
                "operation": "update",
                "value": [
                    dict(ulSlotAggOffTotPwrThresh='33',
                         ulSlotAggOnTotPwrThresh='30',
                         ulTransPrecodeOffSinrThrRedCap='35',
                         ulTransPrecodeOffSinrThresh='35',
                         ulTransPrecodeOnSinrThresh='15',
                         ulTransPrecodeOnSinrThrRedCap='15',
                         ulTransPrecodePi2Bpsk='true',
                         ulTransPrePi2BpskPwrBoost='false')
                ]
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
            }
        ]
    }
]
PARAMETERS_RECOVER_CB008236_JSON_FILE = 'PARAMETERS_RECOVER_CB008236_JSON_FILE.json'
PARAMETERS_RECOVER_CB008236_PUSCH_slot_aggregation_FDD_NPI_FOT = [
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
                "parameterName": "ulTransPrecodeCtl",
                "operation": "update",
                "value": [
                    dict(ulSlotAggOffTotPwrThresh='15',
                         ulSlotAggOnTotPwrThresh='12',
                         ulTransPrecodeOffSinrThrRedCap='35',
                         ulTransPrecodeOffSinrThresh='35',
                         ulTransPrecodeOnSinrThresh='15',
                         ulTransPrecodeOnSinrThrRedCap='15',
                         ulTransPrecodePi2Bpsk='true',
                         ulTransPrePi2BpskPwrBoost='false')
                ]
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
            }
        ]
    }
]

PARAMETERS_CB009189_JSON_FILE = 'PARAMETERS_CB009189_JSON_FILE.json'
PARAMETERS_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions = [
    {
        "distName": _NRCELL701name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Locked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRDRB_MAC_2,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxDlHarqTxDrb",
                "value": "4",
                "operation": "update"
            },
            {
                "parameterName": "maxUlHarqTxDrb",
                "value": "4",
                "operation": "update"
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
            }
        ]
    }
]
PARAMETERS_RECOVER_CB009189_JSON_FILE = 'PARAMETERS_RECOVER_CB009189_JSON_FILE.json'
PARAMETERS_RECOVER_CB009189_Service_aware_Scheduling_Request_and_H_ARQ_retransmissions = [
    {
        "distName": _NRCELL701name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Unlocked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRDRB_MAC_2,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxDlHarqTxDrb",
                "value": "8",
                "operation": "update"
            },
            {
                "parameterName": "maxUlHarqTxDrb",
                "value": "8",
                "operation": "update"
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
            }
        ]
    }
]

PARAMETERS_CB008126_CB008234_JSON_FILE = 'PARAMETERS_CB008126_CB008234_JSON_FILE.json'
PARAMETERS_CB008126_CB008234_QoS_Flow_Modification_CB008234_UE_AMBR_SA = [
    {
        "distName": _NRCELL701name,
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

PARAMETERS_RECOVER_CB008126_CB008234_JSON_FILE = 'PARAMETERS_RECOVER_CB008126_CB008234_JSON_FILE.json'
PARAMETERS_RECOVER_CB008126_CB008234_QoS_Flow_Modification_CB008234_UE_AMBR_SA = [
    {
        "distName": _NRCELL701name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Unlocked",
                "operation": "update"
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

PARAMETERS_CB008236_PA_INITIAL_VALUE = [0, 0, 0, 0]
PARAMETERS_CB008236_PA_TARGET_VALUE = [30, 30, 30, 30]
PARAMETERS_CB008236_PA_STEP = 2
# PARAMETERS_CB009189_PA_INITIAL_VALUE = [10, 10, 10, 10]
PARAMETERS_CB009189_PA_INITIAL_VALUE = [30, 30, 30, 30]
PARAMETERS_CB009189_PA_TARGET_VALUE = [82, 82, 82, 82]
PARAMETERS_CB009189_PA_STEP = 3
PARAMETERS_CB008126_8234_PA_INITIAL_VALUE = [10, 10, 10, 10]
RECOVER_PA_MAX_VALUE = [127, 127, 127, 127]
