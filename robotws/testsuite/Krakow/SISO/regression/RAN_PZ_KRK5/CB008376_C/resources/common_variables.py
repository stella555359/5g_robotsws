from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from robot.libraries.BuiltIn import BuiltIn

LTE_CELL = 7
NR_CELL = 1
BTS_ID = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')

TPUT_MATRIX = {
    'NRCELL-1': {  # NR
        'tput_dl': '856 Mbits/sec',  # Max reached ~800M
        'tput_ul': '446 Mbits/sec',
        'protocol': 'udp',
        'deviation_ul': '5%',
        'deviation_dl': '50%'
    },
}

QRXLEV_PARAMS = {
    'dist_name': GnbDistNamePatterns.cell_dist_name.format(BTS_ID, BTS_ID, NR_CELL),
    'parameter': 'qRxLevMin',
    'qrxlevmin_max': '-45',
    'qrxlevmin_min': '-22'
}

ALL_PARAMETERS_TO_CHANGE = {
    'NR': [
        {
            'param_name': 'numNonGbrPdcpSduDiscard',
            'dist_name': GnbDistNamePatterns.bts_dist_name,
            'correct_value': '50',
            'incorrect_value': '100',
            'mod_type': 'Restart needed',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'prachRootSequenceIndex',
            'dist_name': GnbDistNamePatterns.cell_dist_name.format({}, {}, NR_CELL),
            'correct_value': '10',
            'incorrect_value': '900',
            'mod_type': 'Object locking',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'maxNumX2Links',
            'dist_name': GnbDistNamePatterns.bts_dist_name,
            'correct_value': '200',
            'incorrect_value': '300',
            'mod_type': 'Online',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'rlpDetDlHarqThreshold',
            'dist_name': GnbDistNamePatterns.cell_dist_name.format({}, {}, NR_CELL),
            'correct_value': '40',
            'incorrect_value': '10001',
            'mod_type': 'Conditional restart',
            'fault_type': 'VALUE_IS_TOO_BIG',
        },
    ],
    'LTE': [
        {
            'param_name': 'sctpHeartbeatInterval',
            'dist_name': '{}/SCTP-1'.format(EnbDistNamePatterns.bts_dist_name),
            'correct_value': '25',
            'incorrect_value': '100',
            'mod_type': 'Restart needed',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'actMultipleCarrier',
            'dist_name': EnbDistNamePatterns.bts_dist_name,
            'correct_value': '5_carrierOperation',
            'incorrect_value': '15_carrierOperation',
            'mod_type': 'Conditional restart',
            'fault_type': 'INCORRECT_ENUM'
        },
        {
            'param_name': 'tPingPong',
            'dist_name': EnbDistNamePatterns.cell_dist_name.format({}, {}, LTE_CELL),
            'correct_value': '1000',
            'incorrect_value': '21000',
            'mod_type': 'Online',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'rootSeqIndex',
            'dist_name': '{}/LNCEL_FDD-0'.format(EnbDistNamePatterns.cell_dist_name.format({}, {}, LTE_CELL)),
            'correct_value': '13',
            'incorrect_value': '999',
            'mod_type': 'Object locking',
            'fault_type': 'VALUE_IS_TOO_BIG',
        },
    ],
}

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Cell_block_unblock': ['Cell blocked'],
    'Snapshot': ['BTS Reset Cause'],
    'BTS_reset': ['BTS Reset Cause'],
    'Recommissioning': ['BTS Reset Cause', 'Cell blocked'],
}
