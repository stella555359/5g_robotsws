from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns

ATTENUATOR1_IP = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')
ATTENUATOR2_IP = BuiltIn().get_variable_value('${tl.attenuators[1].ip_addr}')

ATTENUATOR1_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')
ATTENUATOR2_PORT = BuiltIn().get_variable_value('${tl.attenuators[1].port}')

VENDOR1 = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')
VENDOR2 = BuiltIn().get_variable_value('${tl.attenuators[1].vendor}')

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 0,
    },
}

TPUT_MATRIX = {
    'atten_default_values': ATTENUATOR_VALUES,
    'linux_congestion': 'reno',
    'parallel_streams': '5',
    'buffer_client': None,
    'buffer_server': None,
    'size_packet': '1320B',
    'interval': '1',
    'NRCELL-1': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '1',
        'real_cell_id': '1263403009',
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [1, 2, 3, 4],
                'atten_ul': {
                    0: [1, 2, 3, 4],
                },
                'atten_dl': {
                    0: [1, 2, 3, 4],
                },
            },
        ],
    },
    'NRCELL-2': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '2',
        'real_cell_id': '1263403010',
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [5, 6, 7, 8],
                'atten_ul': {
                    0: [5, 6, 7, 8],
                },
                'atten_dl': {
                    0: [5, 6, 7, 8],
                },
            },
        ],
    },
    'NRCELL-3': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '3',
        'real_cell_id': '1263403011',
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [9, 10, 11, 12],
                'atten_ul': {
                    0: [9, 10, 11, 12],
                },
                'atten_dl': {
                    0: [9, 10, 11, 12],
                },
            },
        ],
    },
    'NRCELL-4': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '4',
        'real_cell_id': '1263403012',
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [1, 2, 3, 4],
                'atten_ul': {
                    0: [1, 2, 3, 4],
                },
                'atten_dl': {
                    0: [1, 2, 3, 4],
                },
            },
        ],
    },
    'NRCELL-5': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '5',
        'real_cell_id': '1263403013',
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [5, 6, 7, 8],
                'atten_ul': {
                    0: [5, 6, 7, 8],
                },
                'atten_dl': {
                    0: [5, 6, 7, 8],
                },
            },
        ],
    },
    'NRCELL-6': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '6',
        'real_cell_id': '1263403014',
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [9, 10, 11, 12],
                'atten_ul': {
                    0: [9, 10, 11, 12],
                },
                'atten_dl': {
                    0: [9, 10, 11, 12],
                },
            },
        ],
    },
    'NRCELL-7': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '7',
        'real_cell_id': '1263403015',
        'attenuators': [
            {
                'ip_address': ATTENUATOR2_IP,
                'att_port': ATTENUATOR2_PORT,
                'vendor': VENDOR2,
                'ports': [9, 10, 11, 12],
                'atten_ul': {
                    0: [9, 10, 11, 12],
                },
                'atten_dl': {
                    0: [9, 10, 11, 12],
                },
            },
        ],
    },
    'NRCELL-8': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '8',
        'real_cell_id': '1263403016',
        'attenuators': [
            {
                'ip_address': ATTENUATOR2_IP,
                'att_port': ATTENUATOR2_PORT,
                'vendor': VENDOR2,
                'ports': [1, 2, 3, 4],
                'atten_ul': {
                    0: [1, 2, 3, 4],
                },
                'atten_dl': {
                    0: [1, 2, 3, 4],
                },
            },
        ],
    },
    'NRCELL-9': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '9',
        'real_cell_id': '1263403017',
        'attenuators': [
            {
                'ip_address': ATTENUATOR2_IP,
                'att_port': ATTENUATOR2_PORT,
                'vendor': VENDOR2,
                'ports': [9, 10, 11, 12],
                'atten_ul': {
                    0: [9, 10, 11, 12],
                },
                'atten_dl': {
                    0: [9, 10, 11, 12],
                },
            },
        ],
    },
    'NRCELL-10': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '10',
        'real_cell_id': '1263403018',
        'attenuators': [
            {
                'ip_address': ATTENUATOR2_IP,
                'att_port': ATTENUATOR2_PORT,
                'vendor': VENDOR2,
                'ports': [5, 6, 7, 8],
                'atten_ul': {
                    0: [5, 6, 7, 8],
                },
                'atten_dl': {
                    0: [5, 6, 7, 8],
                },
            },
        ],
    },
    'NRCELL-11': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '175 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '11',
        'real_cell_id': '1263403019',
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                'atten_ul': {
                    0: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                },
                'atten_dl': {
                    0: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                },
            },
        ],
    },
    'NRCELL-22': {
        'DL': {
            'tput': '1595 Mbits/sec',
        },
        'UL': {
            'tput': '200 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': '22',
        'real_cell_id': '1263403030',
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [5, 6, 7, 8],
                'atten_ul': {
                    0: [5, 6, 7, 8],
                },
                'atten_dl': {
                    0: [5, 6, 7, 8],
                },

            },
            {
                'ip_address': ATTENUATOR2_IP,
                'att_port': ATTENUATOR2_PORT,
                'vendor': VENDOR2,
                'ports': [1, 2, 3, 4],
                'atten_ul': {
                    0: [1, 2, 3, 4],
                },
                'atten_dl': {
                    0: [1, 2, 3, 4],
                },
            },
        ],
    },
}

ASIR_ALARMS = {
    'Default_list_of_alarms': [],
    'Config_Reset': [3060]
}

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Comm_and_Recomm': ['Failure detected on assigned antennas'],
    'Snapshot': ['Setup of X2 connectivity to gNB failed'],
    'Cell_block_unblock': ['Cell blocked'],
}
