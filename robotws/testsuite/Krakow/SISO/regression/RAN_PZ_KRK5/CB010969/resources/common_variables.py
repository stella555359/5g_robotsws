import os
import json
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns


TPUT_MATRIX = {
    'NRCELL-1': {  # NR
        'tput_dl': '1525 Mbits/sec',
        'tput_ul': '174 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '5',
        'linux_congestion': 'reno'
    },
    'NRCELL-2': {  # NR
        'tput_dl': '1525 Mbits/sec',
        'tput_ul': '174 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '5',
        'linux_congestion': 'reno'
    },
    'NRCELL-3': {  # NR
        'tput_dl': '1522 Mbits/sec',
        'tput_ul': '174 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '5',
        'linux_congestion': 'reno'
    },
    'NRCELL-4': {  # NR
        'tput_dl': '1525 Mbits/sec',
        'tput_ul': '174 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '5',
        'linux_congestion': 'reno'
    },
    'NRCELL-5': {  # NR
        'tput_dl': '151 Mbits/sec',
        'tput_ul': '32 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '5',
        'linux_congestion': 'reno'
    },
    'NRCELL-6': {  # NR
        'tput_dl': '151 Mbits/sec',
        'tput_ul': '32 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '5',
        'linux_congestion': 'reno'
    },
    'NRCELL-7': {  # NR
        'tput_dl': '151 Mbits/sec',
        'tput_ul': '32 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '5',
        'linux_congestion': 'reno'
    },
    'NRCELL-8': {  # NR
        'tput_dl': '151 Mbits/sec',
        'tput_ul': '32 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '5',
        'linux_congestion': 'reno'
    },
}

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 20,
        'min': 0,
    },
    'TOPYOUNG': {
        'max': 90,
        'avg': 5,
        'min': 0,
    },
}


ue_info = BuiltIn().get_variable_value('${tl.ues[0]}')

ATTENUATOR_IP1 = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')

ATTENUATOR_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')

VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')


ATTENUATOR_MAP = {
    'NR': {
        '1': {
            'cell_id': '1',
            'real_cell_id': '1262518273',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 3, 4],
                    'atten_ul': {
                        0: [1, 2, 3, 4],
                    },
                    'atten_dl': {
                        0: [1, 2, 3, 4],
                    }
                }
            ]
        },
        '2': {
            'cell_id': '2',
            'real_cell_id': '1262518274',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [5, 6, 7, 8],
                    'atten_ul': {
                        0: [5, 6, 7, 8],
                    },
                    'atten_dl': {
                        0: [5, 6, 7, 8],
                    }
                }
            ]
        },
        '3': {
            'cell_id': '3',
            'real_cell_id': '1262518275',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [9, 10, 11, 12],
                    'atten_ul': {
                        10: [9, 10, 11, 12],
                    },
                    'atten_dl': {
                        0: [9, 10, 11, 12],
                    }
                },
            ]
        },
        '4': {
            'cell_id': '4',
            'real_cell_id': '1262518276',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [13, 14, 15, 16],
                    'atten_ul': {
                        12: [13, 14, 15, 16],
                    },
                    'atten_dl': {
                        0: [13, 14, 15, 16],
                    }
                },
            ]
        },
        '5': {
            'cell_id': '5',
            'real_cell_id': '1262518277',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [9, 10],
                    'atten_ul': {
                        0: [9, 10],
                    },
                    'atten_dl': {
                        20: [9, 10],
                    }
                }
            ]
        },
        '6': {
            'cell_id': '6',
            'real_cell_id': '1262518278',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [9, 10],
                    'atten_ul': {
                        0: [9, 10],
                    },
                    'atten_dl': {
                        20: [9, 10],
                    }
                }
            ]
        },
        '7': {
            'cell_id': '7',
            'real_cell_id': '1262518279',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [13, 14],
                    'atten_ul': {
                        0: [13, 14],
                    },
                    'atten_dl': {
                        10: [13, 14],
                    }
                }
            ]
        },
        '8': {
            'cell_id': '8',
            'real_cell_id': '1262518280',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [13, 14],
                    'atten_ul': {
                        0: [13, 14],
                    },
                    'atten_dl': {
                        10: [13, 14],
                    }
                }
            ]
        },
    },
}

QRXLEV = {
    'LTE': {
        'parameter_name': 'qrxlevmin',
        'max': '-44',
        'min': '-100',
    },
    'NR': {
        'parameter_name': 'qRxLevMin',
        'max': '-22',
        'min': '-45',
    }
}

ASIR_ALARMS = {
    'Default_list_of_alarms': [],
    'Config_Reset': [3060]
}

ADDITIONAL_ALARMS_FOR_TESTS = {
    'pRRH_block': ['Failure detected on assigned antennas'],
    'Comm_and_Recomm': ['Failure detected on assigned antennas', 'BTS Reset Cause',
                        'Antennas assignment not available'],
    'L3_call': [],
    'BTS_reset': ['BTS Reset Cause'],
    'BTS_Block': ['BTS blocked'],
    'Cell_block_unblock': ['Cell blocked'],
    'pRRH_Reset': ['Failure detected on assigned antennas'],
    'Cell_add_del': [],
    'ASiR_HUB_lock': ['Setup of X2 connectivity to gNB failed'],
    'Hub_reset': ['Failure detected on assigned antennas', 'EN DSS De-activated on partner side'],
    'Snapshot': ['BTS Reset Cause', 'Setup of X2 connectivity to gNB failed'],
    'Fault_Trigger': ['Failure detected on assigned antennas']
}

gnb_oam_ip = BuiltIn().get_variable_value('${tl.gnbs[0].cu.oam_http_connection_details.addr}')
mrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')
nrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')


params_to_verify_pmax_after_cell_add_del = [
    {
        "param_name": "pMax per NR pRRH radio card",
        "abbr": "pMaxPerNrAntRadioCard",
        "dist_name": "MRBTS-{}/EQM_R-1/APEQM_R-1/ASIRMOD_R-{}".format(mrbts_id, 5),
        "act_param_val": "",  # should be empty
        "new_param_val": ""  # should be empty
    }
]


params_to_change_for_trigger_fault_4484 = [
    {
        "param_name": "NR Absolute radio frequency channel number",
        "abbr": "nrarfcn",
        "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts_id, nrbts_id, 1),
        "act_param_val": "",  # should be empty
        "new_param_val": "623266"
    }
]


change_cell_power = [
    {
        "param_name": "Maximum output power",
        "abbr": "pMax",
        "dist_name": "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts_id, nrbts_id, 2),
        "cell_id": 2,
        "act_param_val": "",  # should be empty
        "new_param_val": "175"
    }
]
