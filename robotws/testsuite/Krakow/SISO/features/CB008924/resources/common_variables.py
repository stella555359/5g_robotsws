from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from resources import generate_attenuator_matrix

TPUT_MATRIX = {
    'NRCELL-16': {  # NR
        'tput_dl': '131 Mbits/sec',
        'tput_ul': '24 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-17': {  # NR
        'tput_dl': '90 Mbits/sec',  # 117 on QC65
        'tput_ul': '24 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-21': {  # NR
        'tput_dl': '191 Mbits/sec',
        'tput_ul': '45 Mbits/sec',  # with bler ~5%
        'protocol': 'tcp',
    },
    'NRCELL-36': {  # NR
        'tput_dl': '131 Mbits/sec',
        'tput_ul': '24 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-37': {  # NR
        'tput_dl': '130 Mbits/sec',  # 169 on QC65
        'tput_ul': '31 Mbits/sec',  # 256QAM UL
        'protocol': 'tcp',
    },
    'LNCEL-11': {  # LTE
        'tput_dl': '191 Mbits/sec',
        'tput_ul': '32 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-12': {  # LTE
        'tput_dl': '191 Mbits/sec',
        'tput_ul': '28 Mbits/sec',  # tput target reduced in compare to 11, 31 because of pucch blanking and pusch mask
        'protocol': 'tcp',
    },
    'LNCEL-13': {  # LTE
        'tput_dl': '371 Mbits/sec',
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-19': {  # LTE
        'tput_dl': '183 Mbits/sec',
        'tput_ul': '34 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-22': {  # LTE
        'tput_dl': '183 Mbits/sec',
        'tput_ul': '34 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-31': {  # LTE
        'tput_dl': '191 Mbits/sec',
        'tput_ul': '32 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-32': {  # LTE
        'tput_dl': '115 Mbits/sec',
        'tput_ul': '28 Mbits/sec',  # tput target reduced in compare to 11, 31 because of pucch blanking and pusch mask
        'protocol': 'tcp',
    },
    'LNCEL-33': {  # LTE
        'tput_dl': '370 Mbits/sec',  # 64 QAM DL
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-39': {  # LTE
        'tput_dl': '183 Mbits/sec',
        'tput_ul': '34 Mbits/sec',
        'protocol': 'tcp',
    },
}

qrxlevmin_min = '-44'
qrxlevmin_max = '-130'

ATTENUATION_VALUE_DEFAULT = 110
ATTENUATOR_IPS = [atten.ip_addr for atten in BuiltIn().get_variable_value('${tl.attenuators}')]
ATTENUATOR_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')
MAX_ATTENUATION_VALUE = 110
AVG_ATTENUATION_VALUE = 40
MIN_ATTENUATION_VALUE = 5
VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ATTENUATOR_MAP = {
    'NR': {
        '16': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [14, 18],
        },
        '17': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [14, 18],
        },
        '21': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [1, 5],
        },
        '36': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [9, 10],
        },
        '37': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [9, 10],
        },
    },
    'LTE': {
        '11': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [14, 18],
        },
        '12': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [14, 18],
        },
        '13': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [14, 18],
        },
        '19': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [14, 18],
        },
        '22': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [1, 5],
        },
        '31': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [9, 10],
        },
        '32': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [9, 10],
        },
        '33': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [9, 10],
        },
        '39': {
            'ip_address': ATTENUATOR_IPS,
            'ports': [9, 10],
        },
    },
}

QRXLEV = {
    'NR': {
        'parameter_name': 'qRxLevMin',
        'min': '-22',
        'max': '-45',
    },
    'LTE': {
        'parameter_name': 'qrxlevmin',
        'min': '-44',
        'max': '-90',
    },
}

ATTENUATOR_MATRIX = generate_attenuator_matrix(ATTENUATOR_MAP, QRXLEV)

ATTENUATOR_PORTS = [val['port'] for key, val in ATTENUATOR_MATRIX.items() if 'port' in val]

LTE_CELL = 19
NR_CELL = 21

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
            'param_name': 'timingAdvanceOffset',
            'dist_name': GnbDistNamePatterns.cell_dist_name.format({}, {}, NR_CELL),
            'correct_value': 'n0',
            'incorrect_value': 'n99999',
            'mod_type': 'Conditional restart',
            'fault_type': 'INCORRECT_ENUM',
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
    'Cell_block_unblock': ['Cell blocked',
                           'EN DSS De-activated on partner side'],
    'Snapshot': ['EN DSS De-activated on partner side',
                 'System information broadcast parameters overflow',
                 'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM',
                 'BTS Reset Cause'],
    'BTS_reset': ['EN DSS De-activated on partner side',
                  'System information broadcast parameters overflow',
                  'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM',
                  'BTS Reset Cause'],
    'Recommissioning': ['EN DSS De-activated on partner side',
                        'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM',
                        'System information broadcast parameters overflow',
                        'BTS Reset Cause'],
    'RU_reset': ['EN DSS De-activated on partner side',
                 'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM'],
    'RU_lock_unlock': ['EN DSS De-activated on partner side'],
}
