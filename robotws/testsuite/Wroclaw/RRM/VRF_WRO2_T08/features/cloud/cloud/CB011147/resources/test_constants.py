TRUNK_SOURCE_CELL = '502'
TRUNK_TARGET_CELL = '504'
BRANCH_SOURCE_CELL = '100'
BRANCH_TARGET_CELL = '101'

MIN_ATTENUATION = 0
MAX_ATTENUATION = 90
TARGET_ATTENUATION = 30

ELT_LOG_NAME = 'elt_log.json'
DCAP_LOG_NAME = 'dcap_log.zip'

CELL_PORTS = {
    '502': {
        'attenuator_id': 0,
        'ports': [9, 10, 11, 12],
    },
    '504': {
        'attenuator_id': 1,
        'ports': [13, 14, 15, 16]
    },
    '100': {
        'attenuator_id': 0,
        'ports': [1, 2, 3, 4]
    },
    '101': {
        'attenuator_id': 0,
        'ports': [5, 6, 7, 8]
    },
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
