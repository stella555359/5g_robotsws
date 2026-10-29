# Copyright: Nokia 5G RAN
# Contact: ruiyu.han@nokia.com
from testsuite.Hangzhou.OAM.RAN_PZ_HAZ_34.libraries.global_vars import *


PARAMS_TO_actRfiTesting_true = {
    'update': [
        dict(
            value='true',
            dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
            parameter='actRfiTesting'
        )
    ]
}


PARAMS_TO_actRfiTesting_false = {
    'update': [
        dict(
            value='false',
            dist_name='MRBTS-%s/MNL-1/MNLENT-1/FEATCADM-1' % (GLOBAL_BTS_ID),
            parameter='actRfiTesting'
        )
    ]
}

RU_RFSCAN_COUNT = {
    "AEHC": {
        "Composite Rx (HBF0)": 10,
        "Feedback Tx (PDRx)": 10,
        "Carrier Rx (FIR9)": 2
    }
}

RU_RFSCAN_SN = {"L1211707927"}

# RULOG_TL = ['89', '289', '295', '842', '863']
BB_ignore_TL = ['89', '290']
RU_ignore_TL = ['99']

RU_CMD_LIST = ["ip addr"]

# RU_CMD_LIST = ["sudo tcpdump -i bond0.257 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w \
# /ram/cfm_bond0_257.pcap &> /dev/null &\n\
# sudo tcpdump -i bond0.258 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_bond0_258.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i bond0.259 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_bond0_259.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i bond0.260 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_bond0_260.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i arb0p0 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_arbop0.pcap &> /dev/null &"]
#
# RU_THOR_CMD_LIST = ["sudo tcpdump -i rfoe0 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w \
# /ram/cfm_rfoe0.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe1 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe1.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe2 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe2.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe3 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe3.pcap &> /dev/null &\n\
# sudo tcpdump -i rfoe4 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_rfoe4.pcap &> /dev/null &\n\
# sudo tcpdump -i br_rfoe0 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe0.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i br_rfoe1 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe1.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i br_rfoe2  'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe2.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i br_rfoe3  'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_br_rfoe3.pcap \
# &> /dev/null &\n\
# sudo tcpdump -i bond0.257 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_257.pcap\
#  &> /dev/null &\n\
# sudo tcpdump -i bond0.258 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_258.pcap\
#  &> /dev/null &\n\
# sudo tcpdump -i bond0.259 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_259.pcap\
#  &> /dev/null &\n\
# sudo tcpdump -i bond0.260 'ether proto 0x8902 or (vlan and ether proto 0x8902)' -w /ram/cfm_thor_bond0_260.pcap\
#  &> /dev/null &"]

RULOG_TL = {
    '89': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
           'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
           'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
           'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
           'commission': True, 'power_reset': True, 'ru_power_reset': True
           },
    '289': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '295': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '502': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '881': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '846': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '290': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '860': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
    '94': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
           'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
           'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
           'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
           'commission': True, 'power_reset': True, 'ru_power_reset': True
           },
    '835': {'log_check': False, 'site_reset': True, 'ru_reset': True, 'site_reset_withouthwf': True,
            'cell_reset': True, 'cell_lock_unlock': True, 'cell_block_unblock': True,
            'ru_lock_unlock': True, 'bbmod_reset': True, 'bbmod_lock_unlock': True,
            'rat_reset': True, 'rat_block_unblock': True, 'du_lock_unlock': True,
            'commission': True, 'power_reset': True, 'ru_power_reset': True
            },
}

egen_TL = []
ipcapture_TL = []

L3CALL_TL = {'846': {
    '31': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '30',
           'duration': '60'},
    '32': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '60',
           'duration': '60'},
    '33': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '30',
           'duration': '60'}
}
}

LTE_CELL_NOT_OPERATION_TL = ["4000835"]
