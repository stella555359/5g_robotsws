from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
PARAMETERS_FOR_RECOMM = {
    'NR': [                                                  # Optional, NR/LTE RAT
        {
            'param_name': 'numNonGbrPdcpSduDiscard',         # Mandatory, parameter name to be changed
            'dist_name': GnbDistNamePatterns.bts_dist_name,  # Mandatory, object dist name to which parameter belongs
            'correct_value': '50',                           # Mandatory, correct parameter value, different than actual
                                                             # value
            'incorrect_value': '100',                        # Mandatory, incorrect parameter value, should be discarded
            'mod_type': 'NR RAT reset',                      # Mandatory, parameter modification type
            'fault_type': 'VALUE_IS_TOO_BIG'                 # Mandatory, fault returned during recommissioning with
                                                             # incorrect value
        },
    ],
    'LTE': [
        {
            'param_name': 'sctpHeartbeatInterval',
            'dist_name': '{}/SCTP-1'.format(EnbDistNamePatterns.bts_dist_name),
            'correct_value': '25',
            'incorrect_value': '100',
            'mod_type': 'LTE RAT reset',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
    ],
}
