from robot.libraries.BuiltIn import BuiltIn

ATTENUATOR_IP_16 = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')
ATTENUATOR_IP_8 = BuiltIn().get_variable_value('${tl.attenuators[1].ip_addr}')

ATTENUATOR_PORT_16 = BuiltIn().get_variable_value('${tl.attenuators[0].port}')
ATTENUATOR_PORT_8 = BuiltIn().get_variable_value('${tl.attenuators[1].port}')

VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 10,
    },
    'TOPYOUNG': {
        'max': 90,
        'avg': 10,
    },
}

TPUT_MATRIX1 = {
    'atten_default_values': ATTENUATOR_VALUES,
    'linux_congestion': None,
    'parallel_streams': '1',
    'buffer_client': None,
    'buffer_server': None,
    'size_packet': '1320B',
    'interval': '1',
    'NRCELL-0': {
        'UL': {
            'tput': '165 Mbits/sec',
        },
        'DL': {
            'tput': '1200 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 0,
        'real_cell_id': 1264533504,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP_16,
                'att_port': ATTENUATOR_PORT_16,
                'vendor': VENDOR,
                'ports': [1, 2, 3, 4],
                'atten_ul': {
                    0: [1, 2, 3, 4],
                },
                'atten_dl': {
                    0: [1, 2, 3, 3],
                }
            }
        ]
    },
    'NRCELL-1': {
        'UL': {
            'tput': '165 Mbits/sec',
        },
        'DL': {
            'tput': '1200 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 1,
        'real_cell_id': 1264533505,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP_16,
                'att_port': ATTENUATOR_PORT_16,
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
    'NRCELL-2': {
        'UL': {
            'tput': '165 Mbits/sec',
        },
        'DL': {
            'tput': '1200 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 2,
        'real_cell_id': 1264533506,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP_16,
                'att_port': ATTENUATOR_PORT_16,
                'vendor': VENDOR,
                'ports': [9, 10, 11, 12],
                'atten_ul': {
                    0: [9, 10, 11, 12],
                },
                'atten_dl': {
                    0: [9, 10, 11, 12],
                }
            }
        ]
    },
    'NRCELL-11': {
        'UL': {
            'tput': '100 Mbits/sec',
        },
        'DL': {
            'tput': '400 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 11,
        'real_cell_id': 1264533515,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP_16,
                'att_port': ATTENUATOR_PORT_16,
                'vendor': VENDOR,
                'ports': [13, 14, 15, 16],
                'atten_ul': {
                    0: [13, 14, 15, 16],
                },
                'atten_dl': {
                    0: [13, 14, 15, 16],
                }
            }
        ]
    },
    'NRCELL-21': {
        'UL': {
            'tput': '100 Mbits/sec',
        },
        'DL': {
            'tput': '400 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 21,
        'real_cell_id': 1264533525,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP_8,
                'att_port': ATTENUATOR_PORT_8,
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
    'NRCELL-31': {
        'UL': {
            'tput': '100 Mbits/sec',
        },
        'DL': {
            'tput': '400 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 31,
        'real_cell_id': 1264533535,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP_8,
                'att_port': ATTENUATOR_PORT_8,
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
    'LNCEL-10': {
        'UL': {
            'tput': '74 Mbits/sec',
        },
        'DL': {
            'tput': '365 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 10,
        'real_cell_id': 19758346,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP_16,
                'att_port': ATTENUATOR_PORT_16,
                'vendor': VENDOR,
                'ports': [13, 14, 15, 16],
                'atten_ul': {
                    40: [13, 14, 15, 16],
                },
                'atten_dl': {
                    40: [13, 14, 15, 16],
                }
            }
        ]
    },
    'LNCEL-20': {
        'UL': {
            'tput': '74 Mbits/sec',
        },
        'DL': {
            'tput': '365 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 20,
        'real_cell_id': 19758356,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP_8,
                'att_port': ATTENUATOR_PORT_8,
                'vendor': VENDOR,
                'ports': [1, 2, 3, 4],
                'atten_ul': {
                    10: [1, 2, 3, 4],
                },
                'atten_dl': {
                    10: [1, 2, 3, 4],
                }
            }
        ]
    },
    'LNCEL-30': {
        'UL': {
            'tput': '74 Mbits/sec',
        },
        'DL': {
            'tput': '365 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 30,
        'real_cell_id': 19758366,
        'attenuators': [
            {
                'ip_address': ATTENUATOR_IP_8,
                'att_port': ATTENUATOR_PORT_8,
                'vendor': VENDOR,
                'ports': [5, 6, 7, 8],
                'atten_ul': {
                    10: [5, 6, 7, 8],
                },
                'atten_dl': {
                    10: [5, 6, 7, 8],
                }
            }
        ]
    }
}

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Upgrade': ['Incompatible SW version detected', 'Incompatible Sw detected',
                'GTP-U Path Failure', 'WiFi Configuration Issue'],
    'Snapshot': ['BTS Reset Cause', 'Incompatible SW version detected',
                 'Incompatible Sw detected', 'GTP-U Path Failure', 'WiFi Configuration Issue'],
    'Supercell': ['BTS Reset Cause', 'Not able to synchronize baseband bus',
                  'No connection to unit', 'Unit power reset'],
}

counters = {
    'M40002C1_min': {
        'formula': "response['BTS']['MRBTS-77181']['SBTS_Energy_Consumption']['M40002C1']",
        "value": 7000,
        "condition": ">="

    },
    'M40002C1_max': {
        'formula': "response['BTS']['MRBTS-77181']['SBTS_Energy_Consumption']['M40002C1']",
        "value": 7400,
        "condition": "<="

    },
    'M40002C2_min': {
        'formula': "response['BTS']['MRBTS-77181']['SBTS_Energy_Consumption']['M40002C2']",
        "value": 10800,
        "condition": ">="

    },
    'M40002C2_max': {
        'formula': "response['BTS']['MRBTS-77181']['SBTS_Energy_Consumption']['M40002C2']",
        "value": 11200,
        "condition": "<="

    }
}

DELTAS = {
    'actSupercell': 'actSupercell.json',
    'deactSupercell': 'deactSupercell.json',
}
