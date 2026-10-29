# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BRGPRT_NAME_1 = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1'
MR_NR_BRGPRT_NAME_2 = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2'
MR_NR_L2SWI_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1'
MR_NR_DSCPTOQMAP_NAME = MR_NR_L2SWI_NAME + '/DSCPTOQMAP-1'
MR_NR_PCP2QMAP_NAME = MR_NR_L2SWI_NAME + '/PCP2QMAP-1'

keywords_list1 = ['BRGPRT_A-1', 'BRGPRT_A-2']

filter_list1 = ['ip.dsfield.dscp == 20', 'ip.dsfield.dscp == 46']

txt_list1 = ['dscp_20.txt', 'dscp_46.txt']

filter_list2 = ['ip.dsfield.dscp == 20', 'ip.dsfield.dscp == 38']

txt_list2 = ['dscp_20.txt', 'dscp_38.txt']

filter_list_case7 = ['vlan.priority == 1', 'vlan.priority == 7']

txt_list3 = ['VlanPriority1.txt', 'VlanPriority7.txt']

filter_list_case9 = ['vlan.priority == 1', '!vlan']

txt_list4 = ['VlanPriority1.txt', 'notvlan.txt']

Modify_009case_step5_1 = [dict(dist_name=MR_NR_BRGPRT_NAME_1, parameter='portDefaultVlanPriority', value='4'),
                          dict(dist_name=MR_NR_BRGPRT_NAME_2, parameter='portDefaultVlanPriority', value='4')]

gnb_para1 = [dict(dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
                  parameter='maxNumScellsDl', value='3', operation='update')]

gnb_para2 = [dict(dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
                  parameter='maxNumScellsDl', value='7', operation='update')]


total_tp_orge = [{b'DL_bler': [0, 0, 0, 0],
                  b'DL_tp': [0, 0, 0, 0],
                  b'UL_bler': [0, 0, 0, 0],
                  b'UL_tp': [0, 0, 0, 0]},
                 {b'DL_bler': [0, 0, 0, 0],
                  b'DL_tp': [0, 0, 0, 0],
                  b'UL_bler': [0, 0, 0, 0],
                  b'UL_tp': [0, 0, 0, 0]},
                 {b'DL_bler': [0, 0, 0, 0],
                  b'DL_tp': [0, 0, 0, 0],
                  b'UL_bler': [0, 0, 0, 0],
                  b'UL_tp': [0, 0, 0, 0]}]

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "wap2nokiacom",
            "iperf_port": "44324",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "2250MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "300MKbits/sec", "duration": "3600"},
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
            "iperf_port": "44325",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "2250MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "300MKbits/sec", "duration": "3600"},
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
