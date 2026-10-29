ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 0,
    },
}


TPUT_MATRIX = {
    'atten_default_values': ATTENUATOR_VALUES,
    'linux_congestion': 'reno',
    'parallel_streams': '8',
    'buffer_client': None,
    'buffer_server': None,
    'size_packet': '1450B',
    'interval': '1',
    'NRCELL-1_DL': {
        'DL': {
            'tput': '4000 Mbits/sec',
            'size_packet': '1450B',
            'parallel_streams': '8',
        },
        'protocol': 'tcp',
        'global_cell_id': 1,
        'real_cell_id': 19458056,
    },
    'NRCELL-1_UL': {
        'UL': {
            'tput': '550 Mbits/sec',
            'size_packet': '1320B',
            'parallel_streams': '8',
        },
        'protocol': 'tcp',
        'global_cell_id': 1,
        'real_cell_id': 19458056,
    },
}
