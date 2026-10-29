import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# #gnb###
GNB_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id)
GNB_NR_BTS_NAME = GNB_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].dus[0].global_bts_id)
GNB_CELL_NAME = GNB_NR_BTS_NAME + '/NRCELL-'
GNB_NRDRB_NAME = GNB_NR_BTS_NAME + '/NRDRB-'

# # CU ##
CU_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].cu.instance_id)
CU_NR_BTS_NAME = CU_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].cu.global_bts_id)
CU_NRDRB_NAME = CU_NR_BTS_NAME + '/NRDRB-'

PC1_TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "mdrb.nokia.com",
            "iperf_port": "44325",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "150MKbits/sec", "duration": "10"},
            "ul": {"target_throughput": "100MKbits/sec", "duration": "10"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "mdrb.nokia.com",
        },
        "1": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44326",
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
        "ue_index_for_call": ["0", "1"]
    },
}

PC2_TLCommonConfig = {
    "MultiUECFG": {
        "2": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44326",
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
            "iperf_port": "44328",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "1000MKbits/sec", "duration": "10"},
            "ul": {"target_throughput": "200MKbits/sec", "duration": "10"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap2nokiacom",
        },
        "ue_index_for_call": ["2", "3"]
    },
}

L2Lo_RAD_para = [{"name": "rdEnableDebugLogForBurst", "value": "true"},
                 {"name": "rdEnableDebugRlcPdusReceived", "value": "true"},]

L2HiDU_RAD_para = [{"name": "rdDebugDlRlcPduBurstsCounters", "value": "true"},
                   {"name": "rdDebugBurstCounters", "value": "true"},]

case1_ue_info = {"0": {"iperf_port": "44325",
                       "dl": {"target_throughput": "100MKbits/sec", "duration": "10"},
                       "ul": {"target_throughput": "50MKbits/sec", "duration": "10"},
                       "apn_address": "wap2nokiacom"},
                 "1": {"iperf_port": "44326",
                       "dl": {"target_throughput": "500MKbits/sec", "duration": "10"},
                       "ul": {"target_throughput": "80MKbits/sec", "duration": "10"},
                       "apn_address": "wap2nokiacom"}
                 }

case3_ue_info = {"3": {"iperf_port": "44325",
                       "dl": {"target_throughput": "1000MKbits/sec", "duration": "10"},
                       "ul": {"target_throughput": "100MKbits/sec", "duration": "10"},
                       "apn_address": "wap2nokiacom"}
                 }

case7_ue_info = {"0": {"iperf_port": "44906",
                       "dl": {"target_throughput": "100MKbits/sec", "duration": "10"},
                       "ul": {"target_throughput": "100MKbits/sec", "duration": "10"},
                       "apn_address": "wap2nokiacom"}
                 }

case_D_ue_info = {"3": {"iperf_port": "44325",
                        "dl": {"target_throughput": "600MKbits/sec", "duration": "10"},
                        "ul": {"target_throughput": "100MKbits/sec", "duration": "10"},
                        "apn_address": "wap2nokiacom"}
                  }

case3_C_ue_info = {"3": {"iperf_port": "44325",
                         "dl": {"target_throughput": "600MKbits/sec", "duration": "20"},
                         "ul": {"target_throughput": "200MKbits/sec", "duration": "20"},
                         "apn_address": "wap2nokiacom"}
                   }

case7_C_ue_info_pc1 = {"0": {"iperf_port": "44325",
                             "dl": {"target_throughput": "250MKbits/sec", "duration": "10"},
                             "ul": {"target_throughput": "100MKbits/sec", "duration": "10"},
                             "apn_address": "wap2nokiacom"},
                       }

case7_C_ue_info_pc2 = {"2": {"iperf_port": "44325",
                             "dl": {"target_throughput": "1000MKbits/sec", "duration": "10"},
                             "ul": {"target_throughput": "200MKbits/sec", "duration": "10"},
                             "apn_address": "wap2nokiacom"},
                       "3": {"iperf_port": "44326",
                             "dl": {"target_throughput": "250MKbits/sec", "duration": "10"},
                             "ul": {"target_throughput": "100MKbits/sec", "duration": "10"},
                             "apn_address": "wap2nokiacom"},
                       }

case1_para = [dict(distName=GNB_CELL_NAME + '1',
              parameters=[{'parameterName': 'actEmfTestMode', 'value': 'true', 'operation': 'update'}],
              operation='update')]

case3_para = [dict(mo_dn=GNB_CELL_NAME + '2', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
              dict(mo_dn=GNB_CELL_NAME + '12', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
              dict(mo_dn=GNB_CELL_NAME + '3', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
              dict(mo_dn=GNB_CELL_NAME + '4', updated_paras_dict={'qRxLevMin': '-60'}, operation='replace'),
              dict(mo_dn=GNB_CELL_NAME + '5', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
              dict(mo_dn=GNB_CELL_NAME + '14', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace')]

case7_du_para = [dict(mo_dn=GNB_CELL_NAME + '2', updated_paras_dict={'qRxLevMin': '-60'}, operation='replace'),
                 dict(mo_dn=GNB_CELL_NAME + '12', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
                 dict(mo_dn=GNB_CELL_NAME + '3', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
                 dict(mo_dn=GNB_CELL_NAME + '4', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
                 dict(mo_dn=GNB_CELL_NAME + '5', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
                 dict(mo_dn=GNB_CELL_NAME + '14', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
                 dict(mo_dn=GNB_NR_BTS_NAME,
                      updated_paras_dict={'/actDrbProfileForCellAggrLevel/0': 'FR1_SA'}, operation='replace'),
                 dict(mo_dn=GNB_NRDRB_NAME + '13',
                      updated_paras_dict={'/cellAggrLevel/0': 'Not FR1 CA eligible'}, operation='replace')]

case_C_para = [dict(mo_dn=GNB_CELL_NAME + '2', updated_paras_dict={'qRxLevMin': '-60'}, operation='replace'),
               dict(mo_dn=GNB_CELL_NAME + '12', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
               dict(mo_dn=GNB_CELL_NAME + '3', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
               dict(mo_dn=GNB_CELL_NAME + '4', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
               dict(mo_dn=GNB_CELL_NAME + '5', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace'),
               dict(mo_dn=GNB_CELL_NAME + '14', updated_paras_dict={'qRxLevMin': '-22'}, operation='replace')]

case7_du_para_re = [dict(mo_dn=GNB_NR_BTS_NAME,
                         updated_paras_dict={'/actDrbProfileForCellAggrLevel/0': 'disabled'}, operation='replace'),
                    dict(mo_dn=GNB_NRDRB_NAME + '13',
                         updated_paras_dict={'/cellAggrLevel/0': 'FR1 CA eligible'}, operation='replace')]

case7_cu_para = [dict(mo_dn=CU_NR_BTS_NAME,
                      parameter_change_list=[{'parameter_path': '/actDrbProfileForCellAggrLevel/0',
                                              'value': 'FR1_SA', 'operation_type': 'replace'}]),
                 dict(mo_dn=CU_NRDRB_NAME + '13',
                      parameter_change_list=[{'parameter_path': '/cellAggrLevel/0',
                                              'value': 'Not FR1 CA eligible', 'operation_type': 'replace'}])]

case7_cu_para_recover = [dict(mo_dn=CU_NR_BTS_NAME,
                              parameter_change_list=[{'parameter_path': '/actDrbProfileForCellAggrLevel/0',
                                                      'value': 'disabled', 'operation_type': 'replace'}]),
                         dict(mo_dn=CU_NRDRB_NAME + '13',
                              parameter_change_list=[{'parameter_path': '/cellAggrLevel/0',
                                                      'value': 'FR1 CA eligible', 'operation_type': 'replace'}])]
