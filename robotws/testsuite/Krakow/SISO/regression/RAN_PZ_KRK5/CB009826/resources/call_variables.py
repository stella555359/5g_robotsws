from robot.libraries.BuiltIn import BuiltIn

ATTENUATOR1_IP = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')

ATTENUATOR1_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')

VENDOR1 = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ADDITIONAL_ALARMS_FOR_TESTS = {
    'BTS_reset': ['BTS Reset Cause']
}

ATTENUATOR_VALUES = {
    'RADIORACK': {                              # mandatory, attenuator vendor
        'max': 110,                             # mandatory, max attenuation value used to attenuate ports
        'avg': 10,                              # mandatory, average attenuation value used during UE attach
    },
    'TOPYOUNG': {
        'max': 90,
        'avg': 10,
    },
}

TPUT_MATRIX = {
    'atten_default_values': ATTENUATOR_VALUES,  # mandatory when attenuators are used, default values for attenuators
    'linux_congestion': 'cubic',                # mandatory, default linux congestion control in iperf cmd
    'parallel_streams': '2',                    # mandatory, default number of parallel streams in iperf cmd
    'buffer_client': None,                      # mandatory, default buffer size on client side in iperf cmd
    'buffer_server': None,                      # mandatory, default buffer size on server side in iperf cmd
    'size_packet': '1320B',                     # mandatory, default packet size in iperf cmd
    'interval': '1',                            # mandatory, default interval in iperf cmd
    'LNCEL-1': {
        'UL': {                                 # optional, uplink traffic
            'tput': '10 Mbits/sec',             # mandatory, throughput used in iperf cmd and/or for validation
        },
        'DL': {                                 # optional, downlink traffic
            'tput': '35 Mbits/sec',             # mandatory, throughput used in iperf cmd and/or for validation
        },
        'protocol': 'tcp',                      # mandatory (if not specify per direction), protocol used
                                                # in iperf cmd for both directions
        'global_cell_id': 1,                    # mandatory, global cell id
        'real_cell_id': 19492353,               # mandatory, real cell id
        'attenuators': [                        # optional, list of attenuators
            {
                'ip_address': ATTENUATOR1_IP,   # mandatory, attenuator ip address
                'att_port': ATTENUATOR1_PORT,   # mandatory, attenuator port
                'vendor': VENDOR1,              # mandatory, attenuator vendor
                'ports': [9, 10, 11, 12],       # mandatory, list of attenuator ports used for this cell
                'atten_dl': {                   # mandatory when DL, attenuation values (dict_keys) used for ports
                    10: [9, 10, 11, 12]         # (dict_values) when downlink traffic is running
                },
                'atten_ul': {                   # mandatory when UL, attenuation values (dict_keys) used for ports
                    10: [9, 10, 11, 12]         # (dict_values) when uplink traffic is running
                }
            }
        ],
    },
    'LNCEL-5': {
        'UL': {
            'tput': '430 Mbits/sec',
            'linux_congestion': None,
        },
        'DL': {
            'tput': '1700 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 5,
        'real_cell_id': 19492357,
        'attenuators': [],
    },
    'NRCELL-11': {
        'UL': {
            'tput': '90 Mbits/sec',
            'parallel_streams': '4',
        },
        'DL': {
            'tput': '200 Mbits/sec',
            'parallel_streams': '4',
        },
        'protocol': 'tcp',
        'global_cell_id': 11,
        'real_cell_id': 1247510539,
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [9, 10, 11, 12],
                'atten_dl': {
                    10: [9, 10, 11, 12]
                },
                'atten_ul': {
                    10: [9, 10, 11, 12]
                }
            }
        ],
    },
    'NRCELL-32': {
        'UL': {
            'tput': '200 Mbits/sec',
        },
        'DL': {
            'tput': '1450 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 32,
        'real_cell_id': 1247510560,
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [1, 2, 3, 4],
                'atten_dl': {
                    10: [1, 2, 3, 4]
                },
                'atten_ul': {
                    10: [1, 2, 3, 4]
                }
            }
        ],
    },
    'NRCELL-41': {
        'UL': {
            'tput': '180 Mbits/sec',
        },
        'DL': {
            'tput': '1450 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 41,
        'real_cell_id': 1247510569,
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [13, 14, 15, 16],
                'atten_dl': {
                    10: [13, 14, 15, 16]
                },
                'atten_ul': {
                    10: [13, 14, 15, 16]
                }
            }
        ],
    },
    'NRCELL-51': {
        'UL': {
            'tput': '80 Mbits/sec',
        },
        'DL': {
            'tput': '400 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 51,
        'real_cell_id': 1247510579,
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [9, 10, 11, 12],
                'atten_dl': {
                    10: [9, 10, 11, 12]
                },
                'atten_ul': {
                    10: [9, 10, 11, 12]
                }
            }
        ],
    },
    'NRCELL-61': {
        'UL': {
            'tput': '180 Mbits/sec',
        },
        'DL': {
            'tput': '1500 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 61,
        'real_cell_id': 1247510589,
        'attenuators': [
            {
                'ip_address': ATTENUATOR1_IP,
                'att_port': ATTENUATOR1_PORT,
                'vendor': VENDOR1,
                'ports': [5, 6, 7, 8],
                'atten_dl': {
                    10: [5, 6, 7, 8]
                },
                'atten_ul': {
                    10: [5, 6, 7, 8]
                }
            }
        ],
    },
    'NRCELL-21': {
        'UL': {
            'tput': '450 Mbits/sec',
        },
        'DL': {
            'tput': '4000 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 21,
        'real_cell_id': 1247510549,
        'attenuators': [],
    },
    'NRCELL-22': {
        'UL': {
            'tput': '450 Mbits/sec',
        },
        'DL': {
            'tput': '4000 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 22,
        'real_cell_id': 1247510550,
        'attenuators': [],
    },
    'NRCELL-23': {
        'UL': {
            'tput': '450 Mbits/sec',
        },
        'DL': {
            'tput': '4000 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 23,
        'real_cell_id': 1247510551,
        'attenuators': [],
    },
    'NRCELL-24': {
        'UL': {
            'tput': '450 Mbits/sec',
        },
        'DL': {
            'tput': '4000 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 24,
        'real_cell_id': 1247510552,
        'attenuators': [],
    },
    'NRCELL-25': {
        'UL': {
            'tput': '450 Mbits/sec',
        },
        'DL': {
            'tput': '4000 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 25,
        'real_cell_id': 1247510553,
        'attenuators': [],
    },
    'NRCELL-26': {
        'UL': {
            'tput': '450 Mbits/sec',
        },
        'DL': {
            'tput': '4000 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 26,
        'real_cell_id': 1247510554,
        'attenuators': [],
    },
    'NRCELL-27': {
        'UL': {
            'tput': '450 Mbits/sec',
        },
        'DL': {
            'tput': '4000 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 27,
        'real_cell_id': 1247510555,
        'attenuators': [],
    },
    'NRCELL-28': {
        'UL': {
            'tput': '450 Mbits/sec',
        },
        'DL': {
            'tput': '4000 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 28,
        'real_cell_id': 1247510556,
        'attenuators': [],
    },
}
