import os
import json
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns

ue_info = BuiltIn().get_variable_value('${tl.ues[0]}')

ATTENUATOR_IP1 = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')

ATTENUATOR_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')

VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ref_num = '56215'
pre_key = 'X2gd-4PJa-QLo2-rk9k'

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 10,
    },
    'TOPYOUNG': {
        'max': 90,
        'avg': 5,
    },
}

TPUT_MATRIX = {
    'atten_default_values': ATTENUATOR_VALUES,
    'linux_congestion': None,
    'parallel_streams': '1',
    'buffer_client': None,
    'buffer_server': None,
    'size_packet': '1400B',
    'interval': '1',
    'NRCELL-1': {
        'protocol': 'tcp',
        'UL': {
            'tput': '82 Mbits/sec',
        },
        'DL': {
            'tput': '730 Mbits/sec', },
        'global_cell_id': 1,
        'real_cell_id': 1264402433,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP1,
                'att_port': ATTENUATOR_PORT,
                'vendor': VENDOR,
                'ports': [13, 14, 15, 16],
                'atten_ul': {
                    20: [13, 14, 15, 16],
                },
                'atten_dl': {
                    10: [13, 14, 15, 16],
                }
            },
        ]
    },
    'NRCELL-2': {  # NR
        'protocol': 'tcp',
        'UL': {
            'tput': '82 Mbits/sec',
        },
        'DL': {
            'tput': '730 Mbits/sec', },
        'global_cell_id': 2,
        'real_cell_id': 1264402434,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP1,
                'att_port': ATTENUATOR_PORT,
                'vendor': VENDOR,
                'ports': [9, 10, 11, 12],
                'atten_ul': {
                    20: [9, 10, 11, 12],
                },
                'atten_dl': {
                    10: [9, 10, 11, 12],
                }
            }
        ]
    },
    'NRCELL-1_S': {
        'protocol': 'tcp',
        'UL': {
            'tput': '81 Mbits/sec',
        },
        'DL': {
            'tput': '730 Mbits/sec', },
        'global_cell_id': 1,
        'real_cell_id': 1264402433,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP1,
                'att_port': ATTENUATOR_PORT,
                'vendor': VENDOR,
                'ports': [9, 10, 11, 12, 13, 14, 15, 16],
                'atten_ul': {
                    20: [9, 10, 11, 12, 13, 14, 15, 16],
                },
                'atten_dl': {
                    10: [9, 10, 11, 12, 13, 14, 15, 16],
                }
            }
        ]
    },
}

ASIR_ALARMS = {
    'Default_list_of_alarms': []
}

ADDITIONAL_ALARMS_FOR_TESTS = {
    'supercell': ['Failure detected on assigned antennas', 'BTS Reset Cause',
                  'Antennas assignment not available'],
    'L3_call': ['BTS Reset Cause'],
    'pRRH_Reset': ['Failure detected on assigned antennas', 'BTS Reset Cause',
                   'Antennas assignment not available'],
    'ASiR_HUB_lock': ['Setup of X2 connectivity to gNB failed', 'BTS Reset Cause'],
    'discovery': ['Failure detected on assigned antennas', 'BTS Reset Cause',
                  'Antennas assignment not available'],
    'Snapshot': ['Failure detected on assigned antennas', 'BTS Reset Cause',
                 'Antennas assignment not available'],
}
