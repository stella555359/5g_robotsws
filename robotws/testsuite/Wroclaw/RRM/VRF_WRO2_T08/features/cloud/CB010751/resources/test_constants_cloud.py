PARAMS_10751_VCU = {
    'MRBTS-8505/NRBTS-8505': {
        'actRrcInactStateRedCap': 'true',
        'drbInactivityTimerSARedCap': '10',
        'drbRrcInactInactivityTimerSARedCap': '5',
        'srbInactivityTimerSARedCap': '60',
        'actRrcInactState': 'intra-gNB',
        'actIntraFreqHoSA': 'true',
        'actInterFreqHoSA': 'true',
        't380': '5min',
    },
    'MRBTS-8505/NRBTS-8505/NRCELL-5': {
        'actRedCapUeSupport': 'true',
        'maxNumOfRrcSARedCap': '200',
        'cellBarredRedCap': '1RX barring',
    },
    'MRBTS-8505/NRBTS-8505/NRCELL-50': {
        'actRedCapUeSupport': 'true',
        'maxNumOfRrcSARedCap': '200',
        'cellBarredRedCap': '1RX barring',

    }
}


PARAMS_10751_VDU_2 = {
    'MRBTS-8505/NRBTS-8505': {
        'actRrcInactStateRedCap': 'true',
        'actRrcInactState': 'intra-gNB',
    },
    'MRBTS-8505/NRBTS-8505/NRCELL-5': {
        'actRedCapUeSupport': 'true',
        'maxNumOfRrcSARedCap': '200',
        'cellBarredRedCap': '1RX barring',
    }
}

PARAMS_10751_VDU_1 = {
    'MRBTS-8505/NRBTS-8505': {
        'actRrcInactStateRedCap': 'true',
        'actRrcInactState': 'intra-gNB',
    },
    'MRBTS-8505/NRBTS-8505/NRCELL-50': {
        'actRedCapUeSupport': 'true',
        'maxNumOfRrcSARedCap': '200',
        'cellBarredRedCap': '1RX barring',
    }
}

ELT_CONFIG = {
    'com_port': 'COM4',
    'pyro_port': '9092',
    'python': 'python'
}
UE_SERIAL_NUMBER = 'm60_caymus_c1951'
ELT_LOG_NAME = 'elt_log.json'
DCAP_LOG_NAME = 'dcap_log.zip'

CELL_PORTS = {
    '501': {
        'attenuator_id': 0,
        'ports': [1, 2, 3, 4],
    },
    '502': {
        'attenuator_id': 0,
        'ports': [9, 10, 11, 12],
    },
    '505': {
        'attenuator_id': 0,
        'ports': [13, 14, 15, 16],
    },
    # yes, 505 and 506 are on the same ports
    '506': {
        'attenuator_id': 0,
        'ports': [13, 14, 15, 16],
    },
    '504': {
        'attenuator_id': 1,
        'ports': [13, 14, 15, 16],
    },
    '605': {
        'attenuator_id': 2,
        'ports': [1, 2, 3, 4],
    },
    # yes, 605 and 606 are on  the same ports
    '606': {
        'attenuator_id': 2,
        'ports': [1, 2, 3, 4],
    },
    '602': {
        'attenuator_id': 2,
        'ports': [9, 10, 11, 12],
    },
    '601': {
        'attenuator_id': 2,
        'ports': [13, 14, 15, 16]
    },
    '604': {
        'attenuator_id': 1,
        'ports': [9, 10, 11, 12]
    }
}

SOURCE_CELL = '605'
TARGET_CELL = '505'
MIN_ATTENUATION = 10
MAX_ATTENUATION = 90
ATTENUATION_STEP = 2

AT_COMMAND_APN = 'AT+EAPNSET="5gsawro",2,"type=default;protocol=IP;roaming_protocol=IP;authtype=0;' \
                 'carrier_enabled=1;max_conns=0;max_conns_time=0;wait_time=0;' \
                 'bearer_bitmask=4294836223;inactive_timer=0'
AT_COMMANDS = ['AT+EGCMD=6,6,"VGMM_CLEAR_GUTI"', 'AT+ERAT=15', 'AT+EAPNLOCK=1', 'AT+EAPNSET="5gsawro",1,"",""',
               AT_COMMAND_APN, 'AT+EAPNLOCK=0',
               'AT+EIAAPN="5gsawro"' 'AT+ESBP=5,"SBP_REJECT_QUERY_CONNECTED_STATE_CID",0',
               'AT+CEMODE=0', 'AT+EFUN=1', 'AT+EAPNACT=1,"5gsawro","default",0', 'AT+CGPADDR=1']
