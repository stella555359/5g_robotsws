from robot.libraries.BuiltIn import BuiltIn

ATTENUATOR1_IP = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')
ATTENUATOR2_IP = BuiltIn().get_variable_value('${tl.attenuators[1].ip_addr}')

ATTENUATOR1_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')
ATTENUATOR2_PORT = BuiltIn().get_variable_value('${tl.attenuators[1].port}')

VENDOR1 = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')
VENDOR2 = BuiltIn().get_variable_value('${tl.attenuators[1].vendor}')

ATTENUATOR_VALUES = {
    'RADIORACK': {      # mandatory, attenuator vendor
        'max': 110,     # mandatory, max attenuation value used to attenuate ports
        'avg': 10,      # mandatory, average attenuation value used during UE attach
    },
    'TOPYOUNG': {
        'max': 90,
        'avg': 10,
    },
}

TPUT_MATRIX = {
    'atten_default_values': ATTENUATOR_VALUES,  # mandatory when attenuators are used, default values for attenuators
    'linux_congestion': None,                   # mandatory, default linux congestion control in iperf cmd
    'parallel_streams': '1',                    # mandatory, default number of parallel streams in iperf cmd
    'buffer_client': None,                      # mandatory, default buffer size on client side in iperf cmd
    'buffer_server': None,                      # mandatory, default buffer size on server side in iperf cmd
    'size_packet': '1320B',                     # mandatory, default packet size in iperf cmd
    'interval': '1',                            # mandatory, default interval in iperf cmd
    'LNCEL-10': {
        'UL': {                                 # optional, uplink traffic
            'tput': '68 Mbits/sec',               # mandatory, throughput used in iperf cmd and/or for validation
            'protocol': 'tcp',                    # optional, protocol used for specific direction in iperf cmd
            # Below list of parameters which can be defined for specific direction if there is a need to use values
            # different from default ones
            'linux_congestion': 'None',           # optional, linux congestion control in iperf cmd
            'parallel_streams': '1',              # optional, number of parallel streams in iperf cmd
            'buffer_client': None,                # optional, buffer size on client side in iperf cmd
            'buffer_server': None,                # optional, buffer size on server side in iperf cmd
            'size_packet': '1320B',               # optional, packet size in iperf cmd
            'interval': '1',                      # optional, interval in iperf cmd
        },
        'DL': {                                 # optional, downlink traffic
            'tput': '185 Mbits/sec',              # mandatory, throughput used in iperf cmd and/or for validation
            'protocol': 'udp',                    # optional, protocol in iperf cmd (tcp, udp)
            'tput_target': '60 Mbits/sec',        # optional, used when expected target throughput lower than `tput`
        },
        'protocol': 'tcp',                      # mandatory (if not specify per direction), protocol used
                                                # in iperf cmd for both directions
        'global_cell_id': 10,                   # mandatory, global cell id
        'real_cell_id': 20050698,               # mandatory, real cell id
        'attenuators': [                        # optional, list of attenuators
            {
                'ip_address': ATTENUATOR2_IP,   # mandatory, attenuator ip address
                'att_port': ATTENUATOR2_PORT,   # mandatory, attenuator port
                'vendor': VENDOR2,              # mandatory, attenuator vendor
                'ports': [7, 8, 9, 10],         # mandatory, list of attenuator ports used for this cell
                'atten_dl': {                   # mandatory when DL, attenuation values (dict_keys) used for ports
                    0: [7, 8, 9, 10]            # (dict_values) when downlink traffic is running
                },
                'atten_ul': {                   # mandatory when UL, attenuation values (dict_keys) used for ports
                    5: [7, 8, 9, 10]            # (dict_values) when uplink traffic is running
                }
            }
        ],
    },
    'NRCELL-2_1': {
        'DL': {
            'tput': '185 Mbits/sec',
        },
        'protocol': 'tcp',
        'global_cell_id': 2,
        'real_cell_id': 20050697,
    }
}
