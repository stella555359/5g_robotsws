import os
import json
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns

gnb_oam_ip = BuiltIn().get_variable_value('${tl.gnbs[0].cu.oam_http_connection_details.addr}')
mrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')
nrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')


bts_names_for_features = {
    'B1': 'CB009766_B1_NR_LTE_DSS_ABIO',
    'TRIMODE': 'CB009766_B1_NR_LTE_DSS_ABIO_TRIMODE'
}

TPUT_MATRIX = {
    'LNCEL-1_B1': {  # NSA
        'tput_dl': '300 Mbits/sec',
        'tput_ul': '140 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'LNCEL-111': {
        'tput_dl': '185 Mbits/sec',
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'LNCEL-2_B1': {
        'tput_dl': '92 Mbits/sec',
        'tput_ul': '32 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'LNCEL-3_B1': {  # DSS
        'tput_dl': '55 Mbits/sec',
        'tput_ul': '14 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'LNCEL-4_B1': {
        'tput_dl': '92 Mbits/sec',
        'tput_ul': '32 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'LNCEL-5_B1': {  # DSS
        'tput_dl': '55 Mbits/sec',
        'tput_ul': '14 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'LNCEL-6_B1': {
        'tput_dl': '92 Mbits/sec',
        'tput_ul': '32 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'LNCEL-7_B1': {
        'tput_dl': '92 Mbits/sec',
        'tput_ul': '32 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'NRCELL-11_B1': {  # NSA
        'tput_dl': '210 Mbits/sec',
        'tput_ul': '108 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'NRCELL-12_B1': {
        'tput_dl': '210 Mbits/sec',
        'tput_ul': '108 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'NRCELL-21_B1': {  # DSS
        'tput_dl': '142 Mbits/sec',
        'tput_ul': '71 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'NRCELL-22_B1': {
        'tput_dl': '210 Mbits/sec',
        'tput_ul': '108 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'NRCELL-31_B1': {
        'tput_dl': '210 Mbits/sec',
        'tput_ul': '108 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
    'NRCELL-32_B1': {  # DSS
        'tput_dl': '142 Mbits/sec',
        'tput_ul': '71 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '4',
        'linux_congestion': 'reno'
    },
}

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 10,
        'min': 0,
    },
    'TOPYOUNG': {
        'max': 90,
        'avg': 10,
        'min': 0,
    },
}

ATTENUATOR_IP = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')
ATTENUATOR_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')
VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ATTENUATOR_MAP = {
    'LTE': {
        '1': {
            'cell_id': '1',
            'real_cell_id': '19481601',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 5, 6],
                    'atten_ul': {
                        0: [1, 2, 5, 6]
                    },
                    'atten_dl': {
                        0: [1, 2, 5, 6]
                    }
                }
            ]
        },
        '1_B1': {
            'cell_id': '1',
            'real_cell_id': '19481601',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 5, 6],
                    'atten_ul': {
                        110: [1, 5],
                        15: [2, 6]
                    },
                    'atten_dl': {
                        110: [1, 5],
                        5: [2, 6]
                    }
                }
            ]
        },
        '111': {
            'cell_id': '1',
            'real_cell_id': '19481601',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 5, 6],
                    'atten_ul': {
                        0: [1, 2, 5, 6]
                    },
                    'atten_dl': {
                        0: [1, 2, 5, 6]
                    }
                }
            ]
        },
        '2': {
            'cell_id': '2',
            'real_cell_id': '19481602',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [9, 10, 13, 14],
                    'atten_ul': {
                        0: [9, 10, 13, 14]
                    },
                    'atten_dl': {
                        0: [9, 10, 13, 14]
                    }
                }
            ]
        },
        '2_B1': {
            'cell_id': '2',
            'real_cell_id': '19481602',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [9, 10, 13, 14],
                    'atten_ul': {
                        0: [9, 13],
                        110: [10, 14]
                    },
                    'atten_dl': {
                        0: [9, 13],
                        110: [10, 14]
                    }
                }
            ]
        },
        '3': {
            'cell_id': '3',
            'real_cell_id': '19481603',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [3, 7],
                    'atten_ul': {
                        0: [3, 7]
                    },
                    'atten_dl': {
                        0: [3, 7]
                    }
                }
            ]
        },
        '3_B1': {
            'cell_id': '3',
            'real_cell_id': '19481603',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [3, 7],
                    'atten_ul': {
                        0: [3, 7]
                    },
                    'atten_dl': {
                        0: [3, 7]
                    }
                }
            ]
        },
        '4': {
            'cell_id': '4',
            'real_cell_id': '19481604',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [11, 15],
                    'atten_ul': {
                        0: [11, 15]
                    },
                    'atten_dl': {
                        0: [11, 15]
                    }
                }
            ]
        },
        '4_B1': {
            'cell_id': '4',
            'real_cell_id': '19481604',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [11, 15],
                    'atten_ul': {
                        0: [11, 15]
                    },
                    'atten_dl': {
                        0: [11, 15]
                    }
                }
            ]
        },
        '5': {
            'cell_id': '5',
            'real_cell_id': '19481605',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [4, 8],
                    'atten_ul': {
                        0: [4, 8]
                    },
                    'atten_dl': {
                        0: [4, 8]
                    }
                }
            ]
        },
        '5_B1': {
            'cell_id': '5',
            'real_cell_id': '19481605',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [4, 8],
                    'atten_ul': {
                        0: [4, 8]
                    },
                    'atten_dl': {
                        0: [4, 8]
                    }
                }
            ]
        },
        '6': {
            'cell_id': '6',
            'real_cell_id': '19481606',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [4, 8],
                    'atten_ul': {
                        0: [4, 8]
                    },
                    'atten_dl': {
                        0: [4, 8]
                    }
                }
            ]
        },
        '6_B1': {
            'cell_id': '6',
            'real_cell_id': '19481606',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [4, 8],
                    'atten_ul': {
                        0: [4, 8]
                    },
                    'atten_dl': {
                        0: [4, 8]
                    }
                }
            ]
        },
        '7': {
            'cell_id': '7',
            'real_cell_id': '19481607',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [4, 8],
                    'atten_ul': {
                        0: [4, 8]
                    },
                    'atten_dl': {
                        0: [4, 8]
                    }
                }
            ]
        },
        '7_B1': {
            'cell_id': '7',
            'real_cell_id': '19481607',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [4, 8],
                    'atten_ul': {
                        0: [4, 8]
                    },
                    'atten_dl': {
                        0: [4, 8]
                    }
                }
            ]
        },
    },
    'NR': {
        '11': {
            'cell_id': '11',
            'real_cell_id': '1246822411',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 5, 6],
                    'atten_ul': {
                        0: [1, 2, 5, 6]
                    },
                    'atten_dl': {
                        0: [1, 2, 5, 6]
                    }
                }
            ]
        },
        '11_B1': {
            'cell_id': '11',
            'real_cell_id': '1246822411',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 5, 6],
                    'atten_ul': {
                        0: [1, 5],
                        110: [2, 6]
                    },
                    'atten_dl': {
                        0: [1, 2, 5, 6]
                    }
                }
            ]
        },
        '12': {
            'cell_id': '12',
            'real_cell_id': '1246822412',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 5, 6],
                    'atten_ul': {
                        0: [1, 2, 5, 6]
                    },
                    'atten_dl': {
                        0: [1, 2, 5, 6]
                    }
                },
            ]
        },
        '12_B1': {
            'cell_id': '12',
            'real_cell_id': '1246822412',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 5, 6],
                    'atten_ul': {
                        20: [1, 5],
                        110: [2, 6]
                    },
                    'atten_dl': {
                        0: [1, 5],
                        110: [2, 6]
                    }
                }
            ]
        },
        '13': {
            'cell_id': '13',
            'real_cell_id': '1246822413',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 5, 6],
                    'atten_ul': {
                        0: [1, 2, 5, 6]
                    },
                    'atten_dl': {
                        0: [1, 2, 5, 6]
                    }
                }
            ]
        },
        '14': {  # band 8
            'cell_id': '14',
            'real_cell_id': '1246822414',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [9, 10, 13, 14],
                    'atten_ul': {
                        20: [9, 13],
                        110: [10, 14]
                    },
                    'atten_dl': {
                        0: [9, 13],
                        10: [10, 14]
                    }
                }
            ]
        },
        '21': {
            'cell_id': '21',
            'real_cell_id': '1246822421',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [3, 7],
                    'atten_ul': {
                        0: [3, 7]
                    },
                    'atten_dl': {
                        0: [3, 7]
                    }
                }
            ]
        },
        '21_B1': {
            'cell_id': '21',
            'real_cell_id': '1246822421',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [3, 7],
                    'atten_ul': {
                        30: [3, 7]
                    },
                    'atten_dl': {
                        0: [3, 7]
                    }
                }
            ]
        },
        '22': {
            'cell_id': '22',
            'real_cell_id': '1246822422',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [3, 7],
                    'atten_ul': {
                        0: [3, 7]
                    },
                    'atten_dl': {
                        0: [3, 7]
                    }
                }
            ]
        },
        '22_B1': {
            'cell_id': '22',
            'real_cell_id': '1246822422',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [3, 7],
                    'atten_ul': {
                        20: [3, 7]
                    },
                    'atten_dl': {
                        20: [3, 7]
                    }
                }
            ]
        },
        '23': {
            'cell_id': '23',
            'real_cell_id': '1246822423',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [3, 7],
                    'atten_ul': {
                        0: [3, 7]
                    },
                    'atten_dl': {
                        0: [3, 7]
                    }
                }
            ]
        },
        '24': {  # band 8
            'cell_id': '24',
            'real_cell_id': '1246822424',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [11, 15],
                    'atten_ul': {
                        20: [11, 15]
                    },
                    'atten_dl': {
                        0: [11, 15]
                    }
                }
            ]
        },
        '31': {
            'cell_id': '31',
            'real_cell_id': '1246822431',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [4, 8],
                    'atten_ul': {
                        0: [4, 8],
                    },
                    'atten_dl': {
                        0: [4, 8],
                    }
                }
            ]
        },
        '31_B1': {
            'cell_id': '31',
            'real_cell_id': '1246822431',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [12, 16],
                    'atten_ul': {
                        20: [12, 16],
                    },
                    'atten_dl': {
                        0: [12, 16],
                    }
                }
            ]
        },
        '32': {
            'cell_id': '32',
            'real_cell_id': '1246822432',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [4, 8],
                    'atten_ul': {
                        0: [4, 8],
                    },
                    'atten_dl': {
                        0: [4, 8],
                    }
                }
            ]
        },
        '32_B1': {
            'cell_id': '32',
            'real_cell_id': '1246822432',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [4, 8],
                    'atten_ul': {
                        40: [4, 8],
                    },
                    'atten_dl': {
                        20: [4, 8],
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
        'min': '-90',  # 80
    },
    'NR': {
        'parameter_name': 'qRxLevMin',
        'max': '-22',
        'min': '-65',
    }
}

ADDITIONAL_ALARMS_FOR_TESTS = {
    'L3_call': [],
    'Snapshot': ['BTS Reset Cause', 'EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell',
                 'EN DSS De-activated on partner side'],
    'Upgrade': ['EN DSS De-activated on partner side', 'Failure detected on assigned antennas',
                'Antennas assignment not available', 'Incompatible SW version detected',
                'Setup of X2 connectivity to gNB failed', 'BTS Reset Cause'],
}

LTE_CELL = 1
NR_CELL = 11

ALL_PARAMETERS_TO_CHANGE = {
    'NR': [
        {
            'param_name': 'maxParallelXnSetup',
            'dist_name': GnbDistNamePatterns.bts_dist_name,
            'correct_value': '6',
            'incorrect_value': '300',
            'mod_type': 'Restart needed',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'actBbPoolTddFr1Enh',
            'dist_name': GnbDistNamePatterns.bts_dist_name,
            'correct_value': 'true',
            'incorrect_value': 'abc',
            'mod_type': 'Restart needed',
            'fault_type': 'provided value is not consistent with parameter NIDD definition'
        },
        {
            'param_name': 'maxNumX2Links',
            'dist_name': GnbDistNamePatterns.bts_dist_name,
            'correct_value': '200',
            'incorrect_value': '300',
            'mod_type': 'Online',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'rlpDetDlHarqThreshold',
            'dist_name': GnbDistNamePatterns.cell_dist_name.format({}, {}, NR_CELL),
            'correct_value': '40',
            'incorrect_value': '10001',
            'mod_type': 'Conditional restart',
            'fault_type': 'VALUE_IS_TOO_BIG',
        },
        {
            'param_name': 'prachRootSequenceIndex',
            'dist_name': GnbDistNamePatterns.cell_dist_name.format({}, {}, NR_CELL),
            'correct_value': '10',
            'incorrect_value': '900',
            'mod_type': 'Object locking',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
    ],
}
