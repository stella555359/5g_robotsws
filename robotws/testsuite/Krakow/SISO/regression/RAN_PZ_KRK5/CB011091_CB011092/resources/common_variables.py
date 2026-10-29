from robot.libraries.BuiltIn import BuiltIn

gnb_oam_ip = BuiltIn().get_variable_value('${tl.gnbs[0].cu.oam_http_connection_details.addr}')
mrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')
nrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')

bts_names_for_features = {
    'B3': 'CB011092_B3',
    'supercell': 'CB011092_B3_supercell'
}
ADDITIONAL_ALARMS_FOR_TESTS = {
    'Cell_block_unblock': ['Cell blocked'],
    'pRRH_Reset': ['Failure detected on assigned antennas', 'WiFi Configuration Issue'],
    'Snapshot': ['BTS Reset Cause', 'WiFi Configuration Issue'],
    'BTS_block': ['BTS Reset Cause', 'Unit synchronization failed', 'BTS blocked', 'WiFi Configuration Issue'],
    'BTS_reset': ['BTS Reset Cause', 'WiFi Configuration Issue'],
    'sfp_lock': ['BTS Reset Cause', 'BTS configuration error (not enough HW for LCR)', 'No connection to unit',
                 'Transmission path failure', 'WiFi Configuration Issue']
}

UUF_QC_IDS = {
    'SBTS00':
    {
            'QC_ID_UPGRADE': 243319,
            'QC_ID_RESET': 243329
    },
    'SBTS25R3':
    {
            'QC_ID_UPGRADE': 207489,
            'QC_ID_RESET': 207500
    }
}

TPUT_MATRIX = {
    'NRCELL-1_B3': {
        'tput_dl': '290 Mbits/sec',
        'tput_ul': '31 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '2',
        'linux_congestion': 'cubic'
    },
    'NRCELL-2_B3': {
        'tput_dl': '290 Mbits/sec',
        'tput_ul': '31 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '2',
        'linux_congestion': 'cubic'
    },
    'NRCELL-3_B3': {
        'tput_dl': '290 Mbits/sec',
        'tput_ul': '30 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '2',
        'linux_congestion': 'cubic'
    },
    'NRCELL-4_B3': {
        'tput_dl': '290 Mbits/sec',
        'tput_ul': '30 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '2',
        'linux_congestion': 'cubic'
    },
    'NRCELL-5_B3': {
        'tput_dl': '1530 Mbits/sec',
        'tput_ul': '198 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '2',
        'linux_congestion': 'cubic'
    },
    'NRCELL-5_B3_supercell': {
        'tput_dl': '1530 Mbits/sec',
        'tput_ul': '199 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '2',
        'linux_congestion': 'cubic'
    },
    'NRCELL-6_B3': {
        'tput_dl': '1530 Mbits/sec',
        'tput_ul': '198 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '2',
        'linux_congestion': 'cubic'
    },
    'NRCELL-7_B3': {
        'tput_dl': '1530 Mbits/sec',
        'tput_ul': '198 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '2',
        'linux_congestion': 'cubic'
    },
    'NRCELL-8_B3': {
        'tput_dl': '1530 Mbits/sec',
        'tput_ul': '198 Mbits/sec',
        'protocol': 'tcp',
        'parallel_streams': '2',
        'linux_congestion': 'cubic'
    }
}

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 5,
        'min': 0,
    },
    'TOPYOUNG': {
        'max': 90,
        'avg': 5,
        'min': 0,
    },
}


ATTENUATOR_IP1 = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')
ATTENUATOR_IP2 = BuiltIn().get_variable_value('${tl.attenuators[1].ip_addr}')

ATTENUATOR_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')

VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ATTENUATOR_MAP = {
    'NR': {
        '1': {
            'cell_id': '1',
            'real_cell_id': '1328300033',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 3, 4, 5, 6, 7, 8],
                    'atten_ul': {
                        0: [1, 2, 3, 4, 5, 6, 7, 8],
                    },
                    'atten_dl': {
                        0: [1, 2, 3, 4, 5, 6, 7, 8],
                    }
                }
            ]
        },
        '1_B3': {
            'cell_id': '1',
            'real_cell_id': '1328300033',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [1, 2, 3, 4, 5, 6, 7, 8],
                    'atten_ul': {
                       110: [1, 2, 3, 4],
                       0: [5, 6, 7, 8],
                    },
                    'atten_dl': {
                        0: [1, 2, 3, 4],
                        110: [5, 6, 7, 8],
                    }
                }
            ]
        },
        '2': {
            'cell_id': '2',
            'real_cell_id': '1328300034',
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
        '2_B3': {
            'cell_id': '2',
            'real_cell_id': '1328300034',
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
            'real_cell_id': '1328300035',
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
                        0: [1, 2, 3, 4]
                    }
                }
            ]
        },
        '3_B3': {
            'cell_id': '3',
            'real_cell_id': '1328300035',
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
                        0: [1, 2, 3, 4]
                    }
                }
            ]
        },
        '4': {
            'cell_id': '4',
            'real_cell_id': '1328300036',
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
                        0: [1, 2, 3, 4]
                    }
                }
            ]
        },
        '4_B3': {
            'cell_id': '4',
            'real_cell_id': '1328300036',
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
                        0: [1, 2, 3, 4]
                    }
                }
            ]
        },
        '5': {
            'cell_id': '5',
            'real_cell_id': '1328300037',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
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
        '5_B3': {
            'cell_id': '5',
            'real_cell_id': '1328300037',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
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
        '5_B3_supercell': {
            'cell_id': '5',
            'real_cell_id': '1328300037',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
                    'vendor': VENDOR,
                    'ports': [9, 10, 11, 12, 13, 14, 15, 16],
                    'atten_ul': {
                        0: [9, 10, 11, 12, 13, 14, 15, 16],
                    },
                    'atten_dl': {
                        0: [9, 10, 11, 12, 13, 14, 15, 16],
                    }
                }
            ]
        },
        '6': {
            'cell_id': '6',
            'real_cell_id': '1328300038',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
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
        '6_B3': {
            'cell_id': '6',
            'real_cell_id': '1328300038',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
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
        '7': {
            'cell_id': '6',
            'real_cell_id': '1328300039',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
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
        '7_B3': {
            'cell_id': '7',
            'real_cell_id': '1328300039',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
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
        '8': {
            'cell_id': '8',
            'real_cell_id': '1328300040',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
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
        '8_B3': {
            'cell_id': '8',
            'real_cell_id': '1328300040',
            'attenuators': [
                {
                    'ip_address': ATTENUATOR_IP1,
                    'att_port': ATTENUATOR_PORT,
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
        'min': '-60',
    }
}
