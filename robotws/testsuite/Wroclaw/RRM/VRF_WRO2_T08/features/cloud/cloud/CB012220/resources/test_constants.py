TRUNK_SOURCE_CELL = '602'
BRANCH_SOURCE_CELL = '100'


MIN_ATTENUATION = 0
MAX_ATTENUATION = 90


ELT_LOG_NAME = 'elt_log.json'
DCAP_LOG_NAME = 'dcap_log.zip'

CELL_PORTS = {
    '602': {
        'attenuator_id': 2,
        'ports': [9, 10, 11, 12],
    },
    '100': {
        'attenuator_id': 0,
        'ports': [1, 2, 3, 4]
    }
}

ELT_CONFIG_TRUNK = {
    'com_port': 'COM5',
    'pyro_port': '9092',
    'python': 'python'
}

ELT_CONFIG_BRANCH = {
    'com_port': 'COM28',
    'pyro_port': '9092',
    'python': 'python'
}
