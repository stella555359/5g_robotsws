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
                 {"name": "rdEnableDebugRlcPdusReceived", "value": "true"},
                 {"name": "L2TraceL2LoTxBitmap", "value": "4294967295"}]

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
                        "dl": {"target_throughput": "1200MKbits/sec", "duration": "10"},
                        "ul": {"target_throughput": "100MKbits/sec", "duration": "10"},
                        "apn_address": "wap2nokiacom"}
                  }

case3_C_ue_info = {"3": {"iperf_port": "44325",
                         "dl": {"target_throughput": "800MKbits/sec", "duration": "20"},
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
                             "dl": {"target_throughput": "1000MKbits/sec", "duration": "10"},
                             "ul": {"target_throughput": "200MKbits/sec", "duration": "10"},
                             "apn_address": "wap2nokiacom"},
                       }

case1_para = [dict(distName=GNB_CELL_NAME + '2',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                   operation='update'),
              dict(distName=GNB_CELL_NAME + '12',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-60', 'operation': 'update'}],
                   operation='update'),
              dict(distName=GNB_CELL_NAME + '3',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                   operation='update'),
              dict(distName=GNB_CELL_NAME + '4',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                   operation='update'),
              dict(distName=GNB_CELL_NAME + '5',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                   operation='update'),
              dict(distName=GNB_CELL_NAME + '14',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                   operation='update')]

case3_para = [dict(distName=GNB_CELL_NAME + '2',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                   operation='update'),
              dict(distName=GNB_CELL_NAME + '12',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                   operation='update'),
              dict(distName=GNB_CELL_NAME + '3',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                   operation='update'),
              dict(distName=GNB_CELL_NAME + '4',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-60', 'operation': 'update'}],
                   operation='update'),
              dict(distName=GNB_CELL_NAME + '5',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                   operation='update'),
              dict(distName=GNB_CELL_NAME + '14',
                   parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                   operation='update')]

case7_du_para = [dict(distName=GNB_CELL_NAME + '2',
                      parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                      operation='update'),
                 dict(distName=GNB_CELL_NAME + '12',
                      parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                      operation='update'),
                 dict(distName=GNB_CELL_NAME + '3',
                      parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                      operation='update'),
                 dict(distName=GNB_CELL_NAME + '4',
                      parameters=[{'parameterName': 'qRxLevMin', 'value': '-60', 'operation': 'update'}],
                      operation='update'),
                 dict(distName=GNB_CELL_NAME + '5',
                      parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                      operation='update'),
                 dict(distName=GNB_CELL_NAME + '14',
                      parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                      operation='update'),
                 dict(distName=GNB_NR_BTS_NAME,
                      parameters=[{'parameterName': 'actDrbProfileForCellAggrLevel', 'value': ['FR1_SA'],
                                   'operation': 'update'}],
                      operation='update'),
                 dict(distName=GNB_NRDRB_NAME + '13',
                      parameters=[
                          {'parameterName': 'cellAggrLevel', 'value': ['Not FR1 CA eligible'], 'operation': 'update'}],
                      operation='update')
                 ]

case_C_para = [dict(distName=GNB_CELL_NAME + '2',
                    parameters=[{'parameterName': 'qRxLevMin', 'value': '-60', 'operation': 'update'}],
                    operation='update'),
               dict(distName=GNB_CELL_NAME + '12',
                    parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                    operation='update'),
               dict(distName=GNB_CELL_NAME + '3',
                    parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                    operation='update'),
               dict(distName=GNB_CELL_NAME + '4',
                    parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                    operation='update'),
               dict(distName=GNB_CELL_NAME + '5',
                    parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                    operation='update'),
               dict(distName=GNB_CELL_NAME + '14',
                    parameters=[{'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}],
                    operation='update')]

case7_du_para_re = [dict(distName=GNB_NR_BTS_NAME,
                         parameters=[{'parameterName': 'actDrbProfileForCellAggrLevel', 'value': ['disabled'],
                                      'operation': 'update'}],
                         operation='update'),
                    dict(distName=GNB_NRDRB_NAME + '13',
                         parameters=[
                             {'parameterName': 'cellAggrLevel', 'value': ['FR1 CA eligible'], 'operation': 'update'}],
                         operation='update')]

enable_fhm_ipv6_para = [dict(distName=GNB_BTS_NAME + '/MNL-1/MNLENT-1/FEATCADM-1',
                             parameters=[{'parameterName': 'actEcpriMplaneIPV6', 'value': 'true',
                                          'operation': 'update'}],
                             operation='update'),
                        # MRBTS-2003/MNL-1/MNLENT-1/MPLANEFHNW-1.mPlaneFHIPAddressV6DN=
                        # MRBTS-2003/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1
                        dict(distName=GNB_BTS_NAME + '/MNL-1/MNLENT-1/MPLANEFHNW-1',
                             parameters=[{'parameterName': 'mPlaneFHIPAddressV6DN',
                                          'value': GNB_BTS_NAME + '/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV6-1',
                                          'operation': 'update'},
                                         {'parameterName': 'preferredLifetime', 'value': '300',
                                          'operation': 'update'},
                                         ],
                             operation='update'),
                        dict(distName=GNB_BTS_NAME + '/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV6-1',
                             parameters=[{'parameterName': 'uniqueIpAddressIdentifier',
                                          'value': 'fhm',
                                          'operation': 'update'},
                                         ],
                             operation='create'),
                        dict(distName=GNB_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1',
                             parameters=[{'parameterName': 'internetProtocolVersion', 'value': 'IPV6',
                                          'operation': 'update'},
                                         {'parameterName': 'serialNumberPlanned', 'value': '1M250310856',
                                          'operation': 'update'},
                                         ],
                             operation='update'),
                        dict(distName=GNB_BTS_NAME + '/EQM-1/APEQM-1/RMOD-5',
                             parameters=[{'parameterName': 'internetProtocolVersion', 'value': 'IPV6',
                                          'operation': 'update'},
                                         {'parameterName': 'serialNumberPlanned', 'value': 'EB2244R1893',
                                          'operation': 'update'},
                                         ],
                             operation='update')]

disable_fhm_ipv6_para = [dict(distName=GNB_BTS_NAME + '/MNL-1/MNLENT-1/FEATCADM-1',
                              parameters=[{'parameterName': 'actEcpriMplaneIPV6', 'value': 'false',
                                           'operation': 'update'}],
                              operation='update'),
                         dict(distName=GNB_BTS_NAME + '/MNL-1/MNLENT-1/MPLANEFHNW-1',
                              parameters=[{'parameterName': 'mPlaneFHIPAddressV6DN',
                                           'value': GNB_BTS_NAME + '/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1',
                                           'operation': 'delete'}],
                              operation='update'),
                         dict(distName=GNB_BTS_NAME + '/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV6-1',
                              parameters=[],
                              operation='delete'),
                         dict(distName=GNB_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1',
                              parameters=[{'parameterName': 'internetProtocolVersion', 'value': 'IPV4',
                                           'operation': 'update'}],
                              operation='update'),
                         dict(distName=GNB_BTS_NAME + '/EQM-1/APEQM-1/RMOD-5',
                              parameters=[{'parameterName': 'internetProtocolVersion', 'value': 'IPV4',
                                           'operation': 'update'}],
                              operation='update')]

case7_cu_para = [dict(distName=CU_NR_BTS_NAME,
                      parameters=[{'parameterName': 'actDrbProfileForCellAggrLevel', 'value': ['FR1_SA'],
                                   'operation': 'update'}],
                      operation='update'),
                 dict(distName=CU_NRDRB_NAME + '13',
                      parameters=[
                           {'parameterName': 'cellAggrLevel', 'value': ['Not FR1 CA eligible'], 'operation': 'update'}],
                      operation='update')]

case7_cu_para_recover = [dict(distName=CU_NR_BTS_NAME,
                              parameters=[{'parameterName': 'actDrbProfileForCellAggrLevel', 'value': ['disabled'],
                                           'operation': 'update'}],
                              operation='update'),
                         dict(distName=CU_NRDRB_NAME + '13',
                              parameters=[{'parameterName': 'cellAggrLevel',
                                           'value': ['FR1 CA eligible'],
                                           'operation': 'update'}],
                              operation='update')]
