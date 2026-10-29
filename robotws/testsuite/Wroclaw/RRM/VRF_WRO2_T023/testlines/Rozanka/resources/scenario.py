CELLS_LST = [
    'GNB_CELL_1_FDD_40MHZ',
    'GNB_CELL_4_n78',
    'GNB_CELL_8_1',
    'GNB_CELL_8_2',
    'GNB_CELL_10',
    'GNB_CELL_5',
    'GNB_CELL_6',
    'GNB_CELL_44',
]

CONFIGS = {
    "eNB6104": {
        "eNB_IP": "10.44.95.119",
        "VM_IP":  "10.44.156.165",
        "eNB_ID": "6104",
        "technology":  "5g",
        "cell_type":  "nr",
        "cplane": "10.44.95.55",
        "uplane": "10.44.94.247",
    },
}

CELL_LIST = [
    'NRCELL-1', 'NRCELL-2', 'NRCELL-4',
    'NRCELL-5', 'NRCELL-6', 'NRCELL-8',
    'NRCELL-9', 'NRCELL-10'
]

REMOTE_TSHARK = {
    'interface': 'ens3f0',
    'tshark_dir': '/usr/local/bin',
    'ssh_ip': '10.42.61.49',
    'log_dir': '/tmp',
    'ssh_username': 'ute',
    'ssh_password': 'uteute',
}

REMOTE_PC = {
    'ssh_ip': '10.44.72.233',
    'ssh_username': 'sranwro2',
    'ssh_password': 'Ru1eTheAir!2',
}

ABSTRACT_LIB_CONFIG = '/home/ute/testline_configuration/7_16_UTE5GCLOUDU001/ta_ue_config.yaml'
TA_ATTENUATOR_CONFIG = '/home/ute/testline_configuration/7_16_UTE5GCLOUDU001/ta_ue_config.yaml'
