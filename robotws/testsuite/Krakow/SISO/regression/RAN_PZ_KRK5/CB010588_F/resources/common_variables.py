import os
import json
from robot.libraries.BuiltIn import BuiltIn
from resources import generate_attenuator_matrix
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns

ATTENUATOR_IP1 = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')
ATTENUATOR_IP2 = BuiltIn().get_variable_value('${tl.attenuators[1].ip_addr}')
ATTENUATOR_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')
VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 0,
        'min': 0,
    },
    'TOPYOUNG': {
        'max': 90,
        'avg': 10,
        'min': 0,
    },
}

ATTENUATOR_MAP = {
    'LTE': {
        '111': {
            'cell_id': '111',
            'real_cell_id': '19738991',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [3, 4],
                    'atten_ul': {
                        0: [3, 4]
                    },
                    'atten_dl': {
                        0: [3, 4]
                    }
                }
            ]
        },
        '112': {
            'cell_id': '112',
            'real_cell_id': '19738992',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [3, 4],
                    'atten_ul': {
                        0: [3, 4]
                    },
                    'atten_dl': {
                        0: [3, 4]
                    }
                }
            ]
        },
        '121': {
            'cell_id': '121',
            'real_cell_id': '19739001',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [5, 6],
                    'atten_ul': {
                        0: [5, 6]
                    },
                    'atten_dl': {
                        0: [5, 6]
                    }
                }
            ]
        },

        '131': {
            'cell_id': '131',
            'real_cell_id': '19739011',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP2,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [15, 16],
                    'atten_ul': {
                        0: [15, 16]
                    },
                    'atten_dl': {
                        0: [15, 16]
                    }
                }
            ]
        },
        '211': {
            'cell_id': '211',
            'real_cell_id': '19739091',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [13, 14],
                    'atten_ul': {
                        0: [13, 14]
                    },
                    'atten_dl': {
                        0: [13, 14]
                    }
                }
            ]
        },
        '212': {
            'cell_id': '212',
            'real_cell_id': '19739092',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [13, 14],
                    'atten_ul': {
                        0: [13, 14]
                    },
                    'atten_dl': {
                        0: [13, 14]
                    }
                }
            ]
        },
        '213': {
            'cell_id': '213',
            'real_cell_id': '19739093',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP2,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [9, 10],
                    'atten_ul': {
                        0: [9, 10]
                    },
                    'atten_dl': {
                        0: [9, 10]
                    }
                }
            ]
        },
        '214': {
            'cell_id': '214',
            'real_cell_id': '19739094',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP2,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [9, 10],
                    'atten_ul': {
                        0: [9, 10]
                    },
                    'atten_dl': {
                        0: [9, 10]
                    }
                }
            ]
        },
        '221': {
            'cell_id': '221',
            'real_cell_id': '19739101',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP2,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [11, 12],
                    'atten_ul': {
                        0: [11, 12]
                    },
                    'atten_dl': {
                        0: [11, 12]
                    }
                }
            ]
        },
        '222': {
            'cell_id': '222',
            'real_cell_id': '19739102',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP2,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [11, 12],
                    'atten_ul': {
                        0: [11, 12]
                    },
                    'atten_dl': {
                        0: [11, 12]
                    }
                }
            ]
        },
        '231': {
            'cell_id': '231',
            'real_cell_id': '19739111',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP2,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [13, 14],
                    'atten_ul': {
                        0: [13, 14]
                    },
                    'atten_dl': {
                        0: [13, 14]
                    }
                }
            ]
        },
    },
    'NR': {
        '1': {
            'cell_id': '1',
            'real_cell_id': '1263288321',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [13, 14, 15, 16],
                    'atten_ul': {
                        10: [13, 14, 15, 16]
                    },
                    'atten_dl': {
                        10: [13, 14, 15, 16]
                    }
                }
            ]
        },
        '2': {
            'cell_id': '2',
            'real_cell_id': '1263288322',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP2,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 3, 4],
                    'atten_ul': {
                        15: [1, 2, 3, 4]
                    },
                    'atten_dl': {
                        4: [1, 2, 3, 4]
                    }
                }
            ]
        },
        '3': {
            'cell_id': '3',
            'real_cell_id': '1263288323',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP2,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [5, 6, 7, 8],
                    'atten_ul': {
                        15: [5, 6, 7, 8]
                    },
                    'atten_dl': {
                        0: [5, 6, 7, 8]
                    }
                }
            ]
        },
        '4': {
            'cell_id': '4',
            'real_cell_id': '1263288324',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [9, 10, 11, 12],
                    'atten_ul': {
                        10: [9, 10, 11, 12]
                    },
                    'atten_dl': {
                        10: [9, 10, 11, 12]
                    }
                },
            ]
        },
        '11': {
            'cell_id': '11',
            'real_cell_id': '1263288331',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2],
                    'atten_ul': {
                        5: [1, 2]
                    },
                    'atten_dl': {
                        5: [1, 2]
                    }
                }
            ]
        },
        '12': {
            'cell_id': '12',
            'real_cell_id': '1263288332',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2],
                    'atten_ul': {
                        5: [1, 2]
                    },
                    'atten_dl': {
                        5: [1, 2]
                    }
                }
            ]
        },
        '31': {
            'cell_id': '31',
            'real_cell_id': '1263288351',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [7, 8],
                    'atten_ul': {
                        0: [7, 8]
                    },
                    'atten_dl': {
                        10: [7, 8]
                    }
                }
            ]
        },
        '21': {
            'cell_id': '21',
            'real_cell_id': '1263288341',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [5, 6],
                    'atten_ul': {
                        10: [5, 6]
                    },
                    'atten_dl': {
                        10: [5, 6]
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
        'min': '-80',  # 80
    },
    'NR': {
        'parameter_name': 'qRxLevMin',
        'max': '-22',
        'min': '-50',
    }
}


TPUT_MATRIX = {
    'NRCELL-1': {
        'tput_dl': '1510 Mbits/sec',
        'tput_ul': '195 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'NRCELL-2': {
        'tput_dl': '1530 Mbits/sec',
        'tput_ul': '173 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'NRCELL-3': {
        'tput_dl': '1530 Mbits/sec',
        'tput_ul': '173 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'NRCELL-4': {
        'tput_dl': '1530 Mbits/sec',
        'tput_ul': '195 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'NRCELL-11': {
        'tput_dl': '212 Mbits/sec',
        'tput_ul': '107 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'NRCELL-12': {
        'tput_dl': '212 Mbits/sec',
        'tput_ul': '107 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'NRCELL-31': {
        'tput_dl': '212 Mbits/sec',
        'tput_ul': '107 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'NRCELL-32': {
        'tput_dl': '212 Mbits/sec',
        'tput_ul': '107 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-111': {
        'tput_dl': '185 Mbits/sec',
        'tput_ul': '67 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-112': {
        'tput_dl': '185 Mbits/sec',
        'tput_ul': '67 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-121': {
        'tput_dl': '390 Mbits/sec',
        'tput_ul': '174 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-131': {
        'tput_dl': '185 Mbits/sec',
        'tput_ul': '67 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-211': {
        'tput_dl': '135 Mbits/sec',
        'tput_ul': '12 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-212': {
        'tput_dl': '135 Mbits/sec',
        'tput_ul': '12 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-213': {
        'tput_dl': '135 Mbits/sec',
        'tput_ul': '12 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-214': {
        'tput_dl': '135 Mbits/sec',
        'tput_ul': '12 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-221': {
        'tput_dl': '135 Mbits/sec',
        'tput_ul': '12 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-222': {
        'tput_dl': '135 Mbits/sec',
        'tput_ul': '12 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
    'LNCEL-231': {
        'tput_dl': '135 Mbits/sec',
        'tput_ul': '12 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '8',
        'linux_congestion': 'cubic'
    },
}

QRXLEV = {
    'LTE': {
        'parameter_name': 'qrxlevmin',
        'max': '-44',
        'min': '-90',
    },
    'NR': {
        'parameter_name': 'qRxLevMin',
        'max': '-22',
        'min': '-45',
    }
}

ATTENUATOR_MATRIX = generate_attenuator_matrix(ATTENUATOR_MAP, QRXLEV)

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Snapshot': ['BTS Reset Cause', 'Setup of X2 connectivity to gNB failed'],
    'RAT_reset': ['Setup of X2 connectivity to gNB failed',
                  'Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability'],
    'RAT_block': ['RAT blocked'],
    'BTS_reset': ['BTS Reset Cause', 'Setup of X2 connectivity to gNB failed'],
    'Comm_and_Recomm': ['BTS Reset Cause', 'Setup of X2 connectivity to gNB failed',
                        'Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability'],
    'Cell_block_unblock': ['Cell blocked']
}
CELL_MAP_FOR_RAT_RESET = {
    'LTE': [111, 112, 121, 131, 211, 212, 213, 214],
    'NR': [4, 2, 3, 21, 1, 31, 11, 12]
}

LTE_CELL = 131
NR_CELL = 4

ALL_PARAMETERS_TO_CHANGE = {
    'NR': [
        {
            'param_name': 'dnPrefix',
            'dist_name': 'MRBTS-77105',
            'correct_value': 'A=A',
            'incorrect_value': 'a' * 500,
            'mod_type': 'Restart needed',
            'fault_type': 'VALUE_IS_TO_TOO_LONG'
        },
        {
            'param_name': 'prachConfigurationIndex',
            'dist_name': GnbDistNamePatterns.cell_dist_name.format({}, {}, NR_CELL),
            'correct_value': '150',
            'incorrect_value': '300',
            'mod_type': 'Object locking',
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
            'param_name': 'nrarfcn',
            'dist_name': GnbDistNamePatterns.cell_dist_name.format({}, {}, NR_CELL),
            'correct_value': '524820',
            'incorrect_value': '3279166',
            'mod_type': 'Conditional restart',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
    ],
    'LTE': [
        {
            'param_name': 'sctpHeartbeatInterval',
            'dist_name': '{}/SCTP-1'.format(EnbDistNamePatterns.bts_dist_name),
            'correct_value': '25',
            'incorrect_value': '100',
            'mod_type': 'Restart needed',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'actMultipleCarrier',
            'dist_name': EnbDistNamePatterns.bts_dist_name,
            'correct_value': '4_carrierOperation',
            'incorrect_value': '15_carrierOperation',
            'mod_type': 'Conditional restart',
            'fault_type': 'INCORRECT_ENUM'
        },
        {
            'param_name': 'tPingPong',
            'dist_name': EnbDistNamePatterns.cell_dist_name.format({}, {}, LTE_CELL),
            'correct_value': '1000',
            'incorrect_value': '21000',
            'mod_type': 'Online',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'rootSeqIndex',
            'dist_name': '{}/LNCEL_FDD-0'.format(EnbDistNamePatterns.cell_dist_name.format({}, {}, LTE_CELL)),
            'correct_value': '10',
            'incorrect_value': '999',
            'mod_type': 'Object locking',
            'fault_type': 'VALUE_IS_TOO_BIG',
        },
    ],
}
