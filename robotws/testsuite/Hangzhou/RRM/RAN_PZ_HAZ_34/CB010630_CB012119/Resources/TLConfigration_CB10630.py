import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# #gnb###
GNB_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
GNB_NR_BTS_NAME = GNB_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].instance_id)
GNB_CELL_NAME = GNB_NR_BTS_NAME + '/NRCELL-'
GNB_BWP_NAME = GNB_NR_BTS_NAME + '/BWP_PROFILE-'

TLCommonConfig = {
    "MultiUECFG": {
        "1": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "dxdata3",
            "iperf_port": "44373",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "2600MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "dxdata3",
        },
        "ue_index_for_call": ["1"]
    },
}

TLCommonConfig1 = {
    "MultiUECFG": {
        "1": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "mdrb.nokia.com",
            "iperf_port": "44373",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "400MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "10MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "mdrb.nokia.com",
        },
        "ue_index_for_call": ["1"]
    },
}

TLCommonConfig_CaseG02 = {
    "MultiUECFG": {
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "NSA",
            "apn": "mdrb.nokia.com",
            "iperf_port": "44373",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "580MKbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "70MKbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_NSA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "mdrb.nokia.com",
        },
        "ue_index_for_call": ["0"]
    },
}

D_case1_para = [dict(dist_name=GNB_CELL_NAME + '3', parameter='chBw', value='10MHz', operation='update'),
                dict(dist_name=GNB_CELL_NAME + '4', parameter='qRxLevMin', value='-22', operation='update'),
                dict(dist_name=GNB_CELL_NAME + '3', parameter='cellBwpList',
                     value=[{'bwpDN': GNB_BWP_NAME + '4', 'cellBwpId': 0, 'actPdcchCceFragmentControl': False,
                             'actUpperThrAckNackFiltering': False, 'actUpperThrAckNackHrFiltering': False,
                             'pdcchResourcePreference': 'peakRate'},
                            {'bwpDN': GNB_BWP_NAME + '44', 'cellBwpId': 1, 'actPdcchCceFragmentControl': False,
                             'actUpperThrAckNackFiltering': False, 'actUpperThrAckNackHrFiltering': False,
                             'pdcchResourcePreference': 'peakRate'}],
                     operation='update')]

D_case1_para_recover = [dict(dist_name=GNB_CELL_NAME + '3', parameter='chBw', value='15MHz', operation='update'),
                        dict(dist_name=GNB_CELL_NAME + '4', parameter='qRxLevMin', value='-60', operation='update'),
                        dict(dist_name=GNB_CELL_NAME + '3', parameter='cellBwpList',
                        value=[{'bwpDN': GNB_BWP_NAME + '2', 'cellBwpId': 0, 'actPdcchCceFragmentControl': False,
                                'actUpperThrAckNackFiltering': False, 'actUpperThrAckNackHrFiltering': False,
                                'pdcchResourcePreference': 'peakRate'},
                               {'bwpDN': GNB_BWP_NAME + '42', 'cellBwpId': 1, 'actPdcchCceFragmentControl': False,
                                'actUpperThrAckNackFiltering': False, 'actUpperThrAckNackHrFiltering': False,
                                'pdcchResourcePreference': 'peakRate'}],
                        operation='update')]

profile_list1 = ['0', '1', '2', '3', '108', '1087', '2', '3']

profile_list2 = ['101', '1011', '102', '1022', '103', '1033', '104', '1044']

delete_dist_list = [GNB_NR_BTS_NAME + '/NRCELL', GNB_NR_BTS_NAME + '/NRCELLGRP',
                    GNB_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR']

add_dist_list = [GNB_NR_BTS_NAME + '/NRCELL', GNB_NR_BTS_NAME + '/NRCELLGRP',
                 GNB_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR']

add_dist_list1 = [GNB_NR_BTS_NAME + '/BWP_PROFILE']

add_dist_list2 = [GNB_CELL_NAME + '10/NRREL-13', GNB_CELL_NAME + '5/NRREL-13']

modify_para_dict1 = {'dist_name_list': [
    GNB_NR_BTS_NAME + '/NRCELL', GNB_NR_BTS_NAME + '/NRCELL',
    GNB_NR_BTS_NAME + '/NRCELL', GNB_NR_BTS_NAME + '/NRCELL-5/NRREL',
    GNB_NR_BTS_NAME + '/NRCELL-7/NRREL', GNB_NR_BTS_NAME + '/NRCELL'],
                     'p_name_list': ['lcrId', 'physCellId', 'chBw', 'lcrId', 'lcrId', 'mMimoAntArrayMode'],
                     'all_id_list': [['4', '5', '6', '7'], ['4', '5', '6', '7'], ['7'], ['13'], ['10'],
                                     ['4', '5', '6', '7']],
                     'new_value_list': [
                         ['4', '5', '6', '7'], ['330', '331', '332', '333'], ['15MHz'], ['7'], ['5'],
                         ['Full 64TRX Array (4x8x2)', 'Full 64TRX Array (4x8x2)',
                          'Full 64TRX Array (4x8x2)', 'Full 64TRX Array (4x8x2)']]}

modify_para_dict2 = {'dist_name_list': [GNB_NR_BTS_NAME + '/NRCELLGRP-4', GNB_NR_BTS_NAME + '/NRCELLGRP-5',
                                        GNB_NR_BTS_NAME + '/NRCELLGRP-6', GNB_NR_BTS_NAME + '/NRCELLGRP-7'],
                     'list_name': ['nrCellList', 'nrCellList', 'nrCellList', 'nrCellList'],
                     'all_id_list': ['4', '5', '6', '7'],
                     'new_value_list': ['4', '5', '6', '7'],
                     'index_list': [0, 0, 0, 0]
                     }


BWP_dict_50M = [{'actPdcchCceFragmentControl': 'false',
                 'actUpperThrAckNackFiltering': 'false',
                 'actUpperThrAckNackHrFiltering': 'false',
                 'bwpDN': GNB_BWP_NAME+'6',
                 'cellBwpId': '0',
                 'pdcchResourcePreference': 'peakRate'},
                {'actPdcchCceFragmentControl': 'false',
                 'actUpperThrAckNackFiltering': 'false',
                 'actUpperThrAckNackHrFiltering': 'false',
                 'bwpDN': GNB_BWP_NAME+'66',
                 'cellBwpId': '1',
                 'pdcchResourcePreference': 'peakRate'}, ]

BWP_dict_100M = [{'actPdcchCceFragmentControl': 'false',
                  'actUpperThrAckNackFiltering': 'false',
                  'actUpperThrAckNackHrFiltering': 'false',
                  'bwpDN': GNB_BWP_NAME+'6',
                  'cellBwpId': '0',
                  'pdcchResourcePreference': 'peakRate'},
                 {'actPdcchCceFragmentControl': 'false',
                  'actUpperThrAckNackFiltering': 'false',
                  'actUpperThrAckNackHrFiltering': 'false',
                  'bwpDN': GNB_BWP_NAME+'64',
                  'cellBwpId': '1',
                  'pdcchResourcePreference': 'peakRate'}, ]

json_update_50M = [
    dict(dist_name=GNB_CELL_NAME + '0',
         parameter='cellBwpList', value=BWP_dict_50M, operation='update'),
    dict(dist_name=GNB_CELL_NAME + '0',
         parameter='chBw', value='50MHz', operation='update'),
    dict(dist_name=GNB_CELL_NAME + '1',
         parameter='cellBwpList', value=BWP_dict_50M, operation='update'),
    dict(dist_name=GNB_CELL_NAME + '1',
         parameter='chBw', value='50MHz', operation='update'),
]

json_update_100M = [
    dict(dist_name=GNB_CELL_NAME + '0',
         parameter='cellBwpList', value=BWP_dict_100M, operation='update'),
    dict(dist_name=GNB_CELL_NAME + '0',
         parameter='chBw', value='100MHz', operation='update'),
    dict(dist_name=GNB_CELL_NAME + '1',
         parameter='cellBwpList', value=BWP_dict_100M, operation='update'),
    dict(dist_name=GNB_CELL_NAME + '1',
         parameter='chBw', value='100MHz', operation='update'),
]
