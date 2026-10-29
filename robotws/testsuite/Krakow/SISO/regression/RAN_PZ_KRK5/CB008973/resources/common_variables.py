from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from resources import generate_attenuator_matrix

TPUT_MATRIX = {
    'NRCELL-10': {  # NR
        'tput_dl': '198 Mbits/sec',
        'tput_ul': '110 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-20': {  # NR
        'tput_dl': '198 Mbits/sec',
        'tput_ul': '110 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-30': {  # NR
        'tput_dl': '198 Mbits/sec',
        'tput_ul': '110 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-11': {  # LTE
        'tput_dl': '185 Mbits/sec',
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-21': {  # LTE
        'tput_dl': '185 Mbits/sec',
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-31': {  # LTE
        'tput_dl': '185 Mbits/sec',
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-41': {  # LTE
        'tput_dl': '185 Mbits/sec',
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-42': {  # LTE
        'tput_dl': '185 Mbits/sec',
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-255': {  # LTE
        'tput_dl': '371 Mbits/sec',
        'tput_ul': '97 Mbits/sec',
        'protocol': 'tcp',
    },
}

gNB_PDU = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}')
gNB_PDU_port = [BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}'), ]
gNB_PDU_model = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port}')

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 0,
        'min': 0,
    },
}

ATTENUATOR_IP1 = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')
ATTENUATOR_IP2 = BuiltIn().get_variable_value('${tl.attenuators[1].ip_addr}')

ATTENUATOR_PORT1 = BuiltIn().get_variable_value('${tl.attenuators[0].port}')
ATTENUATOR_PORT2 = BuiltIn().get_variable_value('${tl.attenuators[1].port}')

VENDOR1 = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')
VENDOR2 = BuiltIn().get_variable_value('${tl.attenuators[1].vendor}')

ATTENUATOR_MAP = {
    'NR': {
        '10': {
            'ip_address': ATTENUATOR_IP1,
            'ports': [1, 2],
            'vendor': VENDOR1,
            'att_port': ATTENUATOR_PORT1,
        },
        '20': {
            'ip_address': ATTENUATOR_IP1,
            'ports': [3, 4],
            'vendor': VENDOR1,
            'att_port': ATTENUATOR_PORT1,
        },
        '30': {
            'ip_address': ATTENUATOR_IP1,
            'ports': [5, 6],
            'vendor': VENDOR1,
            'att_port': ATTENUATOR_PORT1,
        },
    },
    'LTE': {
        '11': {
            'ip_address': ATTENUATOR_IP1,
            'ports': [1, 2],
            'vendor': VENDOR1,
            'att_port': ATTENUATOR_PORT1,
        },
        '21': {
            'ip_address': ATTENUATOR_IP1,
            'ports': [3, 4],
            'vendor': VENDOR1,
            'att_port': ATTENUATOR_PORT1,
        },
        '31': {
            'ip_address': ATTENUATOR_IP1,
            'ports': [5, 6],
            'vendor': VENDOR1,
            'att_port': ATTENUATOR_PORT1,
        },
        '41': {
            'ip_address': ATTENUATOR_IP1,
            'ports': [7, 8],
            'vendor': VENDOR1,
            'att_port': ATTENUATOR_PORT1,
        },
        '42': {
            'ip_address': ATTENUATOR_IP1,
            'ports': [7, 8],
            'vendor': VENDOR1,
            'att_port': ATTENUATOR_PORT1,
        },
        '255': {
            'ip_address': ATTENUATOR_IP1,
            'ports': [9, 10, 11, 12],
            'vendor': VENDOR1,
            'att_port': ATTENUATOR_PORT1,
        },
    },
}

CELL_MAP_FOR_NR_RAT_RESET = [10, 20, 30]

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

LTE_CELL = 42
NR_CELL = 10

PARAM_TO_CHANGE_WITH_COMM = [
    {
        'param_name': 'gnssLineDelay',
        'dist_name': 'MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1',
        'correct_value': '151',
        'incorrect_value': '3000',
        'mod_type': 'Restart needed',
        'fault_type': 'VALUE_IS_TOO_BIG'
    },
]

ALL_PARAMETERS_TO_CHANGE = {
    'NR': [
        {
            'param_name': 'maxParallelXnSetup',
            'dist_name': GnbDistNamePatterns.bts_dist_name,
            'correct_value': '6',
            'incorrect_value': '300',
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
            'correct_value': 'n25600',
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
            'correct_value': '130',
            'incorrect_value': '999',
            'mod_type': 'Object locking',
            'fault_type': 'VALUE_IS_TOO_BIG',
        },
    ],
}

ADDITIONAL_ALARMS_FOR_TESTS = {
    'pRRH_block': ['Failure detected on assigned antennas'],
    'ASiR_HUB_lock': ['NgGnbInitPartialReset', 'NgGnbInitFullReset'],
    'Recomm_and_comm': ['Failure detected on assigned antennas'],
    'Cell_block_unblock': ['Cell blocked'],
    'Snapshot': ['BTS Reset Cause'],
    'pRRH_Reset': ['Failure detected on assigned antennas', 'NgGnbInitFullReset', 'NgGnbInitPartialReset'],
    'BBMOD_Reset': ['Antennas assignment not available', 'NgGnbInitFullReset',  'NgGnbInitPartialReset'],
    'Template_Comm': ['No connection to unit'],
    'IPsec': []
}
