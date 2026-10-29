TRUNK_SOURCE_CELL = '602'
BRANCH_SOURCE_CELL = '100'

TRUNK_PARAMS_8116_A1 = {
    'MRBTS-8505/NRBTS-8505': {
        'actUPIPSupportForPreferred': 'false',
        'actUplaneIntegrityProtection': 'SA',
        'integrityProtPrefL': {
            'nia1_128': '3',
            'nia2_128': '4',
            'nia3_128': '2'
        }
    }
}
BRANCH_PARAMS_8116_A1 = {
    'MRBTS-8674/NRBTS-8674': {
        'actUPIPSupportForPreferred': 'false',
        'actUplaneIntegrityProtection': 'SA',
        'integrityProtPrefL': {
            'nia1_128': '3',
            'nia2_128': '4',
            'nia3_128': '2'
        }
    }
}
ELT_CONFIG_BRANCH = {
    'com_port': 'COM28',
    'pyro_port': '9092',
    'python': 'python'
}
ELT_CONFIG_TRUNK = {
    'com_port': 'COM5',
    'pyro_port': '9092',
    'python': 'python'
}

MIN_ATTENUATION = 0


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

A_1 = {
    "Integrity": "Selecting algorithms for integrity and ciphering",
    "SRB": "New srb integrity algorithm",
    "aes": "algorithm: aes"
}
