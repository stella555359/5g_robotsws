import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ##gnb1###
GNB_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
GNB_NR_BTS_NAME = GNB_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
GNB_CELL1_NAME = GNB_NR_BTS_NAME + '/NRCELL-1'
GNB_CELL4_NAME = GNB_NR_BTS_NAME + '/NRCELL-4'
GNB_NRRESOURCEGROUP1 = GNB_NR_BTS_NAME + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1'
GNB_NRRESOURCEGROUP2 = GNB_NR_BTS_NAME + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2'
GNB_NRRESOURCEGROUP3 = GNB_NR_BTS_NAME + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3'
ul_port_list = tl.ues[0].iperf_details.ports[0:5]
dl_port_list = tl.ues[0].iperf_details.ports[5:10]

case5_para = [dict(dist_name=GNB_CELL4_NAME, parameter='actDlDynSwitchAlloc', value='false', operation='update')]

case5_para_recover = [dict(dist_name=GNB_CELL4_NAME, parameter='actDlDynSwitchAlloc', value='true',
                           operation='update')]

case8_para = [dict(dist_name=GNB_CELL4_NAME, parameter='actPdcchSharingWithPdsch', value='true', operation='update')]

case8_para_recover = [dict(dist_name=GNB_CELL4_NAME, parameter='actPdcchSharingWithPdsch', value='false',
                           operation='update')]

case10_para = [dict(dist_name=GNB_NRRESOURCEGROUP1, parameter='schedulerParams',
                    value=[{'maxQuota': 10, 'minQuota': 5}], operation='update'),
               dict(dist_name=GNB_NRRESOURCEGROUP2, parameter='schedulerParams',
                    value=[{'maxQuota': 30, 'minQuota': 20}], operation='update'),
               dict(dist_name=GNB_NRRESOURCEGROUP3, parameter='schedulerParams',
                    value=[{'maxQuota': 100, 'minQuota': 30}], operation='update')
               ]

case10_para_recover = [dict(dist_name=GNB_NRRESOURCEGROUP1, parameter='schedulerParams',
                       value=[{'maxQuota': 100, 'minQuota': 0}], operation='update'),
                       dict(dist_name=GNB_NRRESOURCEGROUP2, parameter='schedulerParams',
                       value=[{'maxQuota': 100, 'minQuota': 0}], operation='update'),
                       dict(dist_name=GNB_NRRESOURCEGROUP3, parameter='schedulerParams',
                       value=[{'maxQuota': 100, 'minQuota': 0}], operation='update')
                       ]

case4_ue_info = {'4': {'ul_port': ul_port_list[0], 'dl_port': dl_port_list[0],
                       'ul_process_num': 1, 'dl_process_num': 1,
                       'ul_throughput': '25M', 'dl_throughput': '220M', 'ue_mode': 'X80'},
                 '7': {'ul_port': ul_port_list[3], 'dl_port': dl_port_list[3],
                       'ul_process_num': 1, 'dl_process_num': 1,
                       'ul_throughput': '130M', 'dl_throughput': '850M', 'ue_mode': 'X80'},
                 'ue_call_list': ['4', '7']}

case8_ue_info = {'7': {'ul_port': ul_port_list[3], 'dl_port': dl_port_list[3],
                       'ul_process_num': 1, 'dl_process_num': 1,
                       'ul_throughput': '175M', 'dl_throughput': '1250M', 'ue_mode': 'X80'},
                 'ue_call_list': ['7']}

case6_ue_info = {'5': {'ul_port': ul_port_list[1], 'dl_port': dl_port_list[1],
                       'ul_process_num': 1, 'dl_process_num': 1,
                       'ul_throughput': '80M', 'dl_throughput': '190M', 'ue_mode': 'samsung'},
                 '6': {'ul_port': ul_port_list[2], 'dl_port': dl_port_list[2],
                       'ul_process_num': 1, 'dl_process_num': 1,
                       'ul_throughput': '80M', 'dl_throughput': '190M', 'ue_mode': 'X80'},
                 'ue_call_list': ['5', '6']}

case11_ue_info = {'5': {'ul_port': ul_port_list[1], 'dl_port': dl_port_list[1],
                        'ul_process_num': 1, 'dl_process_num': 1,
                        'ul_throughput': '50M', 'dl_throughput': '50M', 'ue_mode': 'samsung'},
                  '6': {'ul_port': ul_port_list[2], 'dl_port': dl_port_list[2],
                        'ul_process_num': 1, 'dl_process_num': 1,
                        'ul_throughput': '50M', 'dl_throughput': '330M', 'ue_mode': 'X80'},
                  'ue_call_list': ['5', '6']}

case10_ue1_info = {'4': {'ul_port': ul_port_list[0], 'dl_port': dl_port_list[0],
                         'ul_process_num': 1, 'dl_process_num': 1,
                         'ul_throughput': '1M', 'dl_throughput': '2M', 'ue_mode': 'X80'},
                   'ue_call_list': ['4']}

case10_ue2_info = {'7': {'ul_port': ul_port_list[3], 'dl_port': dl_port_list[3],
                         'ul_process_num': 1, 'dl_process_num': 1,
                         'ul_throughput': '1M', 'dl_throughput': '2M', 'ue_mode': 'X80'},
                   'ue_call_list': ['7']}

case10_ue3_info = {'4': {'ul_port': ul_port_list[0], 'dl_port': dl_port_list[0],
                         'ul_process_num': 1, 'dl_process_num': 1,
                         'ul_throughput': '1M', 'dl_throughput': '2M', 'ue_mode': 'X80'},
                   '7': {'ul_port': ul_port_list[3], 'dl_port': dl_port_list[3],
                         'ul_process_num': 1, 'dl_process_num': 1,
                         'ul_throughput': '1M', 'dl_throughput': '2M', 'ue_mode': 'X80'},
                   'ue_call_list': ['4', '7']}

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "mdrb.nokia.com",
            "iperf_port": "44205",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "130MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "12MKbits/sec", "duration": "3600"},
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
            "apn": "mdrb.nokia.com",
            "iperf_port": "44206",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "130MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "12MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "mdrb.nokia.com",
        },
        "2": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "mdrb.nokia.com",
            "iperf_port": "44207",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "130MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "12MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "mdrb.nokia.com",
        },
        "3": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "mdrb.nokia.com",
            "iperf_port": "44208",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "130MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "12MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "mdrb.nokia.com",
        },
        "ue_index_for_call": ["0", "1", "2", "3"]
    },
}
