from robot.libraries.BuiltIn import BuiltIn
from resources import generate_attenuator_matrix

ATTENUATOR_IP = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')
ATTENUATOR_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')
VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'min': 10,
    }
}

ATTENUATOR_MAP = {
    'NR': {
        '24': {
            'cell_id': '24',
            'real_cell_id': '1263779864',
            'ip_address': [ATTENUATOR_IP],
            'ports': [5, 6],
            'atten_ul': {
                0: [5, 6]
            },
            'atten_dl': {
                0: [5, 6]
            }
        },
        '24_1': {
            'cell_id': '24',
            'real_cell_id': '1263779864',
            'ip_address': [ATTENUATOR_IP],
            'ports': [7, 8],
            'atten_ul': {
                0: [7, 8]
            },
            'atten_dl': {
                0: [7, 8]
            }
        },
    },
    'LTE': {
        '21': {
            'cell_id': '21',
            'real_cell_id': '19746581',
            'ip_address': [ATTENUATOR_IP],
            'ports': [5, 6],
            'atten_ul': {
                30: [5, 6]
            },
            'atten_dl': {
                0: [5, 6]
            }
        }
    }
}

TPUT_MATRIX = {
    'NRCELL-24': {
        'tput_dl': '189 Mbits/sec',
        'tput_ul': '77 Mbits/sec',
        'protocol': 'tcp'
    },
    'NRCELL-24_1': {
        'tput_dl': '189 Mbits/sec',
        'tput_ul': '77 Mbits/sec',
        'protocol': 'tcp'
    },
    'LNCEL-21': {
        'tput_dl': '185 Mbits/sec',
        'tput_ul': '59 Mbits/sec',
        'protocol': 'tcp'
    }
}

QRXLEV = {
    'LTE': {
        'parameter_name': 'qrxlevmin',
        'min': '-44',
        'max': '-90',
    },
    'NR': {
        'parameter_name': 'qRxLevMin',
        'min': '-22',
        'max': '-45',
    }
}

ATTENUATOR_MATRIX = generate_attenuator_matrix(ATTENUATOR_MAP, QRXLEV)

CB009918 = {
    'notEnergySaving': ['21', '12'],
    'energySaving': ['11']
}

CB009918_hpa = {
    'notEnergySaving': ['21', '12'],
    'ReducedEnergySaving': ['11']
}

cells_to_block_gen3 = [21, 25]

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Test1': ['Alarm1', 'Alarm2', 'Unit power reset', 'No connection to unit', 'BTS Reset Cause',
              'EN DSS De-activated on partner side'],
    'Test1_EDA': ['Alarm1', 'Alarm2', 'Unit power reset', 'No connection to unit', 'BTS Reset Cause',
                  'EN DSS De-activated on partner side', 'Failure in optical interface', 'RRU power loss'],
    'Test3': ['Unit power reset', 'No connection to unit', 'NgGnbInitPartialReset'],
    'Test4': ['Unit power reset', 'No connection to unit', 'NgGnbInitPartialReset', 'BTS Reset Cause', 'Cell blocked']
}
