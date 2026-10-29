TRUNK_SOURCE_CELL = '602'

MIN_ATTENUATION = 0
MAX_ATTENUATION = 90

DCAP_LOG_NAME = 'dcap_log.zip'

CELL_PORTS = {
    '602': {
        'attenuator_id': 2,
        'ports': [9, 10, 11, 12],
    },
}

ELT_CONFIG_TRUNK = {
    'com_port': 'COM5',
    'pyro_port': '9092',
    'python': 'python'
}
