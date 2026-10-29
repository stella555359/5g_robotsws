from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
DEFAULT_PARAMETERS_FOR_RECOMM = {
    'NR': [
        {
            'param_name': 'dnPrefix',
            'dist_name': 'MRBTS-{}'.format({}),
            'correct_value': 'A=A',
            'incorrect_value': 'A',
            'mod_type': 'Restart needed',
            'fault_type': 'INCORRECT_PATTERN'
        },
        {
            'param_name': 'numNonGbrPdcpSduDiscard',
            'dist_name': GnbDistNamePatterns.bts_dist_name,
            'correct_value': '50',
            'incorrect_value': '100',
            'mod_type': 'NR RAT reset',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'timingAdvanceOffset',
            'dist_name': GnbDistNamePatterns.cell_dist_name.format({}, {}, {}),
            'correct_value': 'n0',
            'incorrect_value': 'n99999',
            'mod_type': 'Conditional BTS restart',
            'fault_type': 'INCORRECT_ENUM',
        },
        {
            'param_name': 'prachRootSequenceIndex',
            'dist_name': GnbDistNamePatterns.cell_dist_name.format({}, {}, {}),
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
    ],
    'LTE': [
        {
            'param_name': 'dnPrefix',
            'dist_name': 'MRBTS-{}'.format({}),
            'correct_value': 'B=B',
            'incorrect_value': 'A',
            'mod_type': 'Restart needed',
            'fault_type': 'INCORRECT_PATTERN'
        },
        {
            'param_name': 'sctpHeartbeatInterval',
            'dist_name': '{}/SCTP-1'.format(EnbDistNamePatterns.bts_dist_name),
            'correct_value': '25',
            'incorrect_value': '100',
            'mod_type': 'LTE RAT reset',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'actMultipleCarrier',
            'dist_name': EnbDistNamePatterns.bts_dist_name,
            'correct_value': '5_carrierOperation',
            'incorrect_value': '15_carrierOperation',
            'mod_type': 'Conditional BTS restart',
            'fault_type': 'INCORRECT_ENUM'
        },
        {
            'param_name': 'tPingPong',
            'dist_name': EnbDistNamePatterns.cell_dist_name.format({}, {}, {}),
            'correct_value': '1000',
            'incorrect_value': '21000',
            'mod_type': 'Online',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'rootSeqIndex',
            'dist_name': '{}/LNCEL_FDD-0'.format(EnbDistNamePatterns.cell_dist_name.format({}, {}, {})),
            'correct_value': '13',
            'incorrect_value': '999',
            'mod_type': 'Object locking',
            'fault_type': 'VALUE_IS_TOO_BIG',
        },
    ],
}
