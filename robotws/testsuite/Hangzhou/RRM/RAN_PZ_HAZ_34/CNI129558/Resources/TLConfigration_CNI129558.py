import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ##gnb1###
GNB_BTS_NAME0 = 'MRBTS-' + str(tl.gnbs[0].instance_id)
GNB_NR_BTS_NAME0 = GNB_BTS_NAME0 + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
GNB_CELL_NAME0 = GNB_NR_BTS_NAME0 + '/NRCELL-'
GNB0_NRCELLGRP = GNB_NR_BTS_NAME0 + '/NRCELLGRP-'
GNB0_NRDU = GNB_NR_BTS_NAME0 + '/NRDU-'

GNB_BTS_NAME1 = 'MRBTS-' + str(tl.gnbs[1].instance_id)
GNB_NR_BTS_NAME1 = GNB_BTS_NAME1 + '/NRBTS-' + str(tl.gnbs[1].global_bts_id)
GNB_CELL_NAME1 = GNB_NR_BTS_NAME1 + '/NRCELL-'

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44051",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "50MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap2nokiacom",
        },
        "1": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44052",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "50MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap2nokiacom",
        },
        "2": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44053",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "50MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap2nokiacom",
        },
        "3": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44054",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "50MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap2nokiacom",
        },
        "4": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44055",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "50MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_5",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap2nokiacom",
        },
        "5": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44056",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "50MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_6",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap2nokiacom",
        },
        "6": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44057",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "50MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_7",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap2nokiacom",
        },
        "7": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44058",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "50MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap2nokiacom",
        },
        "ue_index_for_call": ["0", "1", "2", "3", "4", "5", "6", "7"]
    },
}


A_B1_06_PA_value1 = [0, 0, 0, 0, 127, 127, 127, 127, 127, 127, 127, 127, 0, 0, 127, 127]
A_B1_06_PA_value2 = [40, 40, 40, 40, 127, 127, 127, 127, 127, 127, 127, 127, 0, 0, 127, 127]

A_B2_05_PA_value1 = [40, 40, 40, 40, 40, 40, 40, 40, 127, 127, 127, 127, 0, 0, 127, 127]
A_B2_05_PA_value2 = [40, 40, 40, 40, 0, 0, 0, 0, 127, 127, 127, 127, 0, 0, 127, 127]

A_B3_05_PA_value1 = [40, 40, 40, 40, 40, 40, 40, 40, 127, 127, 127, 127, 0, 0, 127, 127]
A_B3_05_PA_value2 = [0, 0, 0, 0, 40, 40, 40, 40, 127, 127, 127, 127, 0, 0, 127, 127]
A_B3_05_PA_value3 = [10, 10, 10, 10, 0, 0, 0, 0, 127, 127, 127, 127, 0, 0, 127, 127]

A_B4_02_PA_value1 = [40, 40, 40, 40, 40, 40, 40, 40, 127, 127, 127, 127, 0, 0, 127, 127]
A_B4_02_PA_value2 = [40, 40, 40, 40, 0, 0, 0, 0, 127, 127, 127, 127, 0, 0, 127, 127]
A_B4_02_PA_value3 = [40, 40, 40, 40, 40, 40, 40, 40, 0, 0, 0, 0, 20, 20, 127, 127]
A_B4_02_PA_value4 = [40, 40, 40, 40, 0, 0, 0, 0, 30, 30, 30, 30, 20, 20, 127, 127]

B_B2_03_PA_value1 = [40, 40, 40, 40, 40, 40, 40, 40, 0, 0, 0, 0, 127, 127, 127, 127]
B_B2_03_PA_value2 = [0, 0, 0, 0, 40, 40, 40, 40, 30, 30, 30, 30, 127, 127, 127, 127]

B_B3_05_PA_value2 = [40, 40, 40, 40, 0, 0, 0, 0, 40, 40, 40, 40, 127, 127, 127, 127]
B_B3_05_PA_value3 = [0, 0, 0, 0, 20, 20, 20, 20, 40, 40, 40, 40, 127, 127, 127, 127]

init_PA_value = [0] * 14 + [127] * 2

PCI_and_PA_port_mapping = {50: [1, 2, 3, 4],
                           51: [5, 6, 7, 8],
                           61: [9, 10, 11, 12],
                           62: [9, 10, 11, 12],
                           27: [13, 14], }

A_B1_06_UE_Cell_info = {'0': 27, '2': 27, '4': 50, '6': 50}

A_B2_05_UE_Cell_info = {'0': 51, '2': 51, '4': 27, '6': 27}

pci_50_config = {'ssb_freq': '656640', 'pci': '50', 'scs': '30', 'band': '77'}

pci_51_config = {'ssb_freq': '663264', 'pci': '51', 'scs': '30', 'band': '77'}

pci_27_config = {'ssb_freq': '369850', 'pci': '27', 'scs': '15', 'band': '3'}

pci_61_config = {'ssb_freq': '649920', 'pci': '61', 'scs': '30', 'band': '77'}

pci_62_config = {'ssb_freq': '656928', 'pci': '62', 'scs': '30', 'band': '77'}

A_B1_06_UE_lock_info = {'0': pci_27_config,
                        '2': pci_27_config,
                        '4': pci_50_config,
                        '6': pci_50_config, }

A_B2_05_UE_lock_info = {'4': pci_27_config,
                        '6': pci_27_config,
                        '0': pci_51_config,
                        '2': pci_51_config, }

A_B3_05_UE_lock_info = {'2': pci_27_config,
                        '4': pci_27_config,
                        '6': pci_27_config,
                        '0': pci_50_config, }

A_B4_02_UE_lock_info = {'2': pci_51_config,
                        '4': pci_27_config,
                        '6': pci_27_config,
                        '0': pci_61_config, }

B_B3_05_UE_lock_info = {'1': pci_51_config,
                        '2': pci_61_config,
                        '4': pci_61_config,
                        '6': pci_61_config, }

B_IWK1_03_UE_lock_info = {'2': pci_61_config,
                          '4': pci_61_config,
                          '6': pci_61_config,
                          '1': pci_51_config, }
B_B2_03_UE_lock_info = {'2': pci_61_config,
                        '4': pci_61_config,
                        '6': pci_61_config,
                        '0': pci_50_config, }

B_B4_03_UE_lock_info = {'2': pci_61_config,
                        '4': pci_61_config,
                        '6': pci_61_config,
                        '1': pci_51_config, }

empty_ue_info = {"ue_index_for_call": []}

A_B1_06_ue_info1 = {"ue_index_for_call": ["4", "6"]}

A_B1_06_ue_info2 = {"ue_index_for_call": ["2"]}

A_B1_06_ue_info3 = {"ue_index_for_call": ["0"]}

B_B2_03_ue_info1 = {"ue_index_for_call": ["2", "4", "6"]}

B_B3_05_ue_info2 = {"ue_index_for_call": ["1"]}

A_B1_06_syslog_check_info = ['cell']
#                              'Check can admit with scell preemption success']

A_B3_05_ue_info1 = {"ue_index_for_call": ["2", "4", "6"]}

# A_B1_06_ue_info2 = {"ue_index_for_call": ["3"],
#                     "ue_tp": {"3": {"dl": 5, "ul": 1}}}
#

common_para1 = dict(parameter='maxNumOfRrcSA', value='2', operation='update')
common_para2 = dict(parameter='maxNumOfUsersPerCell', value='2', operation='update')
common_para3 = dict(parameter='maxNumOfUsersPerNRCell', value='3', operation='update')
common_para4 = dict(parameter='maxNumOfNrDcSnUsers', value='3', operation='update')
common_para5 = dict(parameter='maxNumOfCaUsersNRCell', value='3', operation='update')
common_para6 = dict(parameter='maxNumOfSCellAlloc', value='3', operation='update')

common_par1_re = dict(parameter='maxNumOfRrcSA', value='10', operation='update')
common_par2_re = dict(parameter='maxNumOfUsersPerCell', value='10', operation='update')
common_par3_re = dict(parameter='maxNumOfUsersPerNRCell', value='10', operation='update')
common_par4_re = dict(parameter='maxNumOfNrDcSnUsers', value='10', operation='update')
common_par5_re = dict(parameter='maxNumOfCaUsersNRCell', value='10', operation='update')
common_par6_re = dict(parameter='maxNumOfSCellAlloc', value='10', operation='update')

handover_allowed = dict(parameter='handoverAllowedSA', value='allowed', operation='update')
handover_XnHoNotAllowed = dict(parameter='handoverAllowedSA', value='XnHoNotAllowed', operation='update')
handover_forbidden = dict(parameter='handoverAllowedSA', value='forbidden', operation='update')

CA_allowed_para1 = dict(parameter='sCellAdditionMethod', value='blind', operation='update')
CA_allowed_para2 = dict(parameter='sCellOperationalMode', value='dlOnly', operation='update')

CA_forbidden_para1 = dict(parameter='sCellAdditionMethod', operation='delete')
CA_forbidden_para2 = dict(parameter='sCellOperationalMode', operation='delete')


CELL1_Para = [{**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_para1},
              {**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_para2},
              {**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_para3},
              {**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_para4},
              {**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_para5},
              {**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_para6},]

CELL1_Para_recover = [{**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_par1_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_par2_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_par3_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_par4_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_par5_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '1'), **common_par6_re},]

CELL3_Para = [{**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_para1},
              {**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_para2},
              {**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_para3},
              {**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_para4},
              {**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_para5},
              {**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_para6},]

CELL3_Para_recover = [{**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_par1_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_par2_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_par3_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_par4_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_par5_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '3'), **common_par6_re},]

CELL4_Para = [{**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_para1},
              {**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_para2},
              {**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_para3},
              {**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_para4},
              {**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_para5},
              {**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_para6},]

CELL4_Para_recover = [{**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_par1_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_par2_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_par3_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_par4_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_par5_re},
                      {**dict(dist_name=GNB_CELL_NAME0 + '4'), **common_par6_re},]

A_B4_02 = [{**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **handover_forbidden}]
A_B4_02_r = [{**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **handover_allowed}]
A_B4_02_para = CELL3_Para + A_B4_02
A_B4_02_para_recover = CELL3_Para_recover + A_B4_02_r

A_B4_02_para1 = [{**dict(dist_name=GNB_CELL_NAME1 + '2/NRREL-2'), **handover_XnHoNotAllowed}]
A_B4_02_para1_recover = [{**dict(dist_name=GNB_CELL_NAME1 + '2/NRREL-2'), **handover_forbidden}]

A_B3_05 = [{**dict(dist_name=GNB_CELL_NAME0 + '1/NRREL-2'), **handover_allowed},
           {**dict(dist_name=GNB_CELL_NAME0 + '4/NRREL-1'), **CA_forbidden_para1},
           {**dict(dist_name=GNB_CELL_NAME0 + '4/NRREL-1'), **CA_forbidden_para2},]

A_B3_05_r = [{**dict(dist_name=GNB_CELL_NAME0 + '1/NRREL-2'), **handover_forbidden},
             {**dict(dist_name=GNB_CELL_NAME0 + '4/NRREL-1'), **CA_allowed_para1},
             {**dict(dist_name=GNB_CELL_NAME0 + '4/NRREL-1'), **CA_allowed_para2},]
A_B3_05_para = CELL3_Para + A_B3_05
A_B3_05_para_recover = CELL3_Para_recover + A_B3_05_r

B_B2_03_para1 = [dict(dist_name=GNB_CELL_NAME1 + '2', parameter='maxNumOfRrcSA',
                      value='3', operation='update')]
B_B2_03_para1_recover = [dict(dist_name=GNB_CELL_NAME1 + '2', parameter='maxNumOfRrcSA',
                         value='2', operation='update')]

B_B3_05 = [dict(dist_name=GNB_NR_BTS_NAME0, parameter='actSCellPreemption', value='true', operation='update'),
           {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-1'), **handover_allowed},
           # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-1'), **CA_forbidden_para1},
           # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-1'), **CA_forbidden_para2},
           {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **handover_forbidden},
           # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **CA_forbidden_para1},
           # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **CA_forbidden_para2},
           {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-3'), **handover_forbidden},
           # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-3'), **CA_forbidden_para1},
           # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-3'), **CA_forbidden_para2},
           ]

B_B3_05_r = [dict(dist_name=GNB_NR_BTS_NAME0, parameter='actSCellPreemption', value='true', operation='update'),
             {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-1'), **handover_forbidden},
             # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-1'), **CA_forbidden_para1},
             # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-1'), **CA_forbidden_para2},
             {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **handover_allowed},
             # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **CA_forbidden_para1},
             # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **CA_forbidden_para2},
             {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-3'), **handover_allowed},
             # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-3'), **CA_forbidden_para1},
             # {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-3'), **CA_forbidden_para2},
             ]

B_B3_05_para = CELL1_Para + B_B3_05
B_B3_05_para_recover = CELL1_Para_recover + B_B3_05_r

B_B4_03 = [{**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-1'), **handover_XnHoNotAllowed},
           {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **handover_forbidden},
           {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-3'), **handover_forbidden},]

B_B4_03_p1 = [{**dict(dist_name=GNB_CELL_NAME1 + '2/NRREL-4'), **CA_allowed_para1},
              {**dict(dist_name=GNB_CELL_NAME1 + '2/NRREL-4'), **CA_allowed_para2},]

B_B4_03_p1_r = [{**dict(dist_name=GNB_CELL_NAME1 + '2/NRREL-4'), **CA_forbidden_para1},
                {**dict(dist_name=GNB_CELL_NAME1 + '2/NRREL-4'), **CA_forbidden_para2},]

B_B4_03_para = CELL1_Para + B_B4_03
B_B4_03_para_recover = CELL1_Para_recover + B_B3_05_r
B_B4_03_para1 = B_B2_03_para1 + B_B4_03_p1
B_B4_03_para1_recover = B_B2_03_para1_recover + B_B4_03_p1_r

B_IKW1_03_p = [dict(dist_name=GNB_CELL_NAME0 + '1', parameter='numOfRadioResReservForTempUse',
                    value='0', operation='update'),
               dict(dist_name=GNB_CELL_NAME0 + '1', parameter='numOfRadioResReservForEmergency',
                    value='1', operation='update'),
               dict(dist_name=GNB_CELL_NAME0 + '1', parameter='actEmPaPreemptionWithRgRac',
                    value='true', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0, parameter='actSliceAwareAdmissionCtrl',
                    value='true', operation='update'),
               dict(dist_name=GNB_CELL_NAME0 + '1', parameter='numOfRadioResReservForPa',
                    value='0', operation='update'),
               dict(dist_name=GNB_CELL_NAME0 + '1', parameter='actMcQosSupport', value='true', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0 + '/NRPRIOACC_PROFILE-1', parameter='arpPrioLevelMpsMax',
                    value='2', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0 + '/NRPRIOACC_PROFILE-1', parameter='arpPrioLevelMpsMin',
                    value='2', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0 + '/NRPRIOACC_PROFILE-1', parameter='nrPlmnIdx',
                    value='3', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0, parameter='actDrbPreemption', value='false', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0, parameter='actUserPreemption', value='false', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0, parameter='actSCellPreemption', value='false', operation='update'),
               {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-1'), **handover_allowed},
               {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **handover_forbidden},
               {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-3'), **handover_forbidden},
               ]

B_IKW1_03_r = [dict(dist_name=GNB_CELL_NAME0 + '1', parameter='numOfRadioResReservForTempUse',
                    value='30', operation='update'),
               dict(dist_name=GNB_CELL_NAME0 + '1', parameter='numOfRadioResReservForEmergency',
                    value='0', operation='update'),
               dict(dist_name=GNB_CELL_NAME0 + '1', parameter='actEmPaPreemptionWithRgRac',
                    value='false', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0, parameter='actSliceAwareAdmissionCtrl',
                    value='false', operation='update'),
               dict(dist_name=GNB_CELL_NAME0 + '1', parameter='numOfRadioResReservForPa', operation='delete'),
               dict(dist_name=GNB_CELL_NAME0 + '1', parameter='actMcQosSupport', value='false', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0 + '/NRPRIOACC_PROFILE-1', parameter='arpPrioLevelMpsMax',
                    value='7', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0 + '/NRPRIOACC_PROFILE-1', parameter='arpPrioLevelMpsMin',
                    value='5', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0 + '/NRPRIOACC_PROFILE-1', parameter='nrPlmnIdx',
                    value='1', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0, parameter='actDrbPreemption', value='true', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0, parameter='actUserPreemption', value='true', operation='update'),
               dict(dist_name=GNB_NR_BTS_NAME0, parameter='actSCellPreemption', value='true', operation='update'),
               {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-1'), **handover_forbidden},
               {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-2'), **handover_allowed},
               {**dict(dist_name=GNB_CELL_NAME0 + '3/NRREL-3'), **handover_allowed},
               ]

B_IKW1_03_para = CELL1_Para + B_IKW1_03_p
B_IKW1_03_para_recover = CELL1_Para_recover + B_IKW1_03_r
