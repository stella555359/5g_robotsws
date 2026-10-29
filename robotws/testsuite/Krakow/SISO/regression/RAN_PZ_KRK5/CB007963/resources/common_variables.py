import os
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from resources import generate_attenuator_matrix

gNB_PDU = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}')
gNB_PDU_port = [BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}'), ]
gNB_PDU_model = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port}')

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Cell_block_unblock': ['Cell blocked', 'EN DSS De-activated on partner side',
                           'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM'],
    'Cell_lock_unlock': ['EN DSS De-activated on partner side',
                         'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM',
                         'Setup of X2 connectivity to gNB failed'],
    'RAT_reset': ['EN DSS De-activated on partner side',
                  'Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability'],
    'pRRH_block_unblock': ['Failure detected on assigned antennas'],
    'pRRH_reset': ['Failure detected on assigned antennas'],
    'Hub_reset': ['Failure detected on assigned antennas', 'EN DSS De-activated on partner side'],
    'ASiR_HUB_lock': ['Setup of X2 connectivity to gNB failed'],
    'BTS_reset': ['EN DSS De-activated on partner side',
                  'BTS Reset Cause'],
    'Comm_and_Recomm': ['BTS Reset Cause', 'Failure detected on assigned antennas',
                        'EN DSS De-activated on partner side', '5G cell configuration mismatch',
                        'Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability',
                        'Setup of X2 connectivity to gNB failed',
                        'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM',
                        ],
    'BBMOD_lock': ['EN DSS De-activated on partner side', 'Setup of X2 connectivity to gNB failed',
                   'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM',
                   'Setup of X2 connectivity to gNB failed',
                   'NgGnbInitPartialReset'],
    'Power_reset': ['BTS Reset Cause', 'Fault signature for crash or failure',
                    'EN DSS De-activated on partner side',
                    'Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability',
                    'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM'],
    'RAT_reset_with_bts_reset': ['EN DSS De-activated on partner side',
                                 'Cell problem due to associated X2 links and/or NG links an/or E1 link unavailability',
                                 'System information broadcast parameters overflow',
                                 'EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM',
                                 'BTS Reset Cause', 'Diagnostic Files collected']
}

reset_prrh_with_call = [
    {
        'cell_to_call': 'LNCEL-11',
        'prrh_to_lock': '4',
    },
    {
        'cell_to_call': 'LNCEL-12_2',
        'prrh_to_lock': '2',  # 12_3
    },
    {
        'cell_to_call': 'NRCELL-2',
        'prrh_to_lock': '8',
    },
    {
        'cell_to_call': 'NRCELL-33',
        'prrh_to_lock': '5',
    },
]

lock_bbmod_with_call = [
    {
        'cell_to_call': 'NRCELL-32_2',
        'bbmod_to_lock': '3',
    },
    {
        'cell_to_call': 'NRCELL-1_1',
        'bbmod_to_lock': '4',
    },
    {
        'cell_to_call': 'LNCEL-13_1',
        'bbmod_to_lock': '1',
    },
    {
        'cell_to_call': 'LNCEL-11',
        'bbmod_to_lock': '2',
    },

]


CELL_MAP_FOR_RAT_RESET = {
    'LTE': [13, 11, 12],
    'NR': [1, 0, 2, 32, 33, 34, 31]
}

CURDIR = '{}'.format(os.path.dirname(os.path.realpath(__file__)))
DELTA_COMMISIONING_LTE_RAT_RESET = os.path.join(CURDIR, 'configs/delta_commisioning_LTE_RAT_reset.json')

LTE_CELL = 11
NR_CELL = 2

ALL_PARAMETERS_TO_CHANGE = {
    'NR': [
        {
            'param_name': 'dnPrefix',
            'dist_name': 'MRBTS-77107',
            'correct_value': 'A=A',
            'incorrect_value': 'a' * 500,
            'mod_type': 'Restart needed',
            'fault_type': 'VALUE_IS_TO_TOO_LONG'
        },
        {
            'param_name': 'prachConfigurationIndex',
            'dist_name': GnbDistNamePatterns.cell_dist_name.format({}, {}, NR_CELL),
            'correct_value': '38',
            'incorrect_value': '300',
            'mod_type': 'Object locking',
            'fault_type': 'VALUE_IS_TOO_BIG'
        },
        {
            'param_name': 'actBbPoolTddFr1Enh',
            'dist_name': GnbDistNamePatterns.bts_dist_name,
            'correct_value': 'true',
            'incorrect_value': 'abc',
            'mod_type': 'Restart needed',
            'fault_type': 'provided value is not consistent with parameter NIDD definition'
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
            'correct_value': '4_carrierOperation',
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
            'correct_value': '10',
            'incorrect_value': '999',
            'mod_type': 'Object locking',
            'fault_type': 'VALUE_IS_TOO_BIG',
        },
    ],
}

TPUT_MATRIX = {
    'NRCELL-1_1': {
        'tput_dl': '150 Mbits/sec',
        'tput_ul': '71 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-1_2': {
        'tput_dl': '150 Mbits/sec',
        'tput_ul': '71 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-2': {
        'tput_dl': '3470 Mbits/sec',
        'tput_ul': '164 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-31': {
        'tput_dl': '1600 Mbits/sec',
        'tput_ul': '170 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-32_1': {
        'tput_dl': '911 Mbits/sec',
        'tput_ul': '112 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-32_2': {
        'tput_dl': '911 Mbits/sec',
        'tput_ul': '112 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-33': {
        'tput_dl': '1600 Mbits/sec',
        'tput_ul': '172 Mbits/sec',
        'protocol': 'tcp',
    },
    'NRCELL-34': {
        'tput_dl': '407 Mbits/sec',
        'tput_ul': '40 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-11': {
        'tput_dl': '375 Mbits/sec',
        'tput_ul': '173 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-12_1': {
        'tput_dl': '54 Mbits/sec',
        'tput_ul': '16 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-12_2': {
        'tput_dl': '54 Mbits/sec',
        'tput_ul': '16 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-13_1': {
        'tput_dl': '180 Mbits/sec',
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-13_2': {
        'tput_dl': '180 Mbits/sec',
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-14': {
        'tput_dl': '180 Mbits/sec',
        'tput_ul': '68 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-15': {
        'tput_dl': '136 Mbits/sec',
        'tput_ul': '12 Mbits/sec',
        'protocol': 'tcp',
    },
    'LNCEL-16': {
        'tput_dl': '136 Mbits/sec',
        'tput_ul': '12 Mbits/sec',
        'protocol': 'tcp',
    }
}

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 10,
        # 'min': 20,
    },
}

ATTENUATOR_IP1 = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')
ATTENUATOR_IP2 = BuiltIn().get_variable_value('${tl.attenuators[1].ip_addr}')

ATTENUATOR_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')

VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ATTENUATOR_MAP = {
    'LTE': {
        '11': {
            'cell_id': '11',
            'ip_address': [ATTENUATOR_IP2],
            'ports': [15, 16],
            'atten_ul': {
                0: [15, 16]
            },
            'atten_dl': {
                0: [15, 16]
            }
        },
        '12_1': {
            'cell_id': '12',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [3, 4],
            'atten_ul': {
                10: [3, 4]
            },
            'atten_dl': {
                10: [3, 4]
            }
        },
        '12_2': {
            'cell_id': '12',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [5, 6],
            'atten_ul': {
                10: [5, 6]
            },
            'atten_dl': {
                10: [5, 6]
            }
        },
        '13_1': {
            'cell_id': '13',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [19, 20],
            'atten_ul': {
                10: [19, 20]
            },
            'atten_dl': {
                10: [19, 20]
            }
        },
        '13_2': {
            'cell_id': '13',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [21, 22],
            'atten_ul': {
                10: [21, 22],
            },
            'atten_dl': {
                10: [21, 22],
            }
        },
        '14': {
            'cell_id': '14',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [13, 14],
            'atten_ul': {
                10: [13, 14],
            },
            'atten_dl': {
                10: [13, 14],
            }
        },
        '15': {
            'cell_id': '15',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [28, 29],
            'atten_ul': {
                20: [28, 29],
            },
            'atten_dl': {
                20: [28, 29],
            }
        },
        '16': {
            'cell_id': '16',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [31, 32],
            'atten_ul': {
                0: [31, 32],
            },
            'atten_dl': {
                0: [31, 32],
            }
        },
    },
    'NR': {
        '1_1': {
            'cell_id': '1',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [3, 4],
            'atten_ul': {
                10: [3, 4],
            },
            'atten_dl': {
                10: [3, 4],
            }
        },
        '1_2': {
            'cell_id': '1',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [5, 6],
            'atten_ul': {
                10: [5, 6],
            },
            'atten_dl': {
                10: [5, 6],
            }
        },
        '2': {
            'cell_id': '2',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [1, 2, 9, 10, 11, 12, 27, 28, 29, 30],
            'atten_ul': {
                10: [1, 2],
                36: [9, 10, 11, 12],
                47: [27, 28, 29, 30]
            },
            'atten_dl': {
                10: [1, 2],
                30: [9, 10, 11, 12],
                20: [27, 28, 29, 30]
            }
        },
        '31': {
            'cell_id': '31',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [9, 10, 11, 12],
            'atten_ul': {
                38: [9, 10, 11, 12],
            },
            'atten_dl': {
                30: [9, 10, 11, 12],
            }
        },
        '32_1': {
            'cell_id': '32',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [15, 16, 17, 18],
            'atten_ul': {
                36: [15, 16, 17, 18],
            },
            'atten_dl': {
                30: [15, 16, 17, 18],
            }
        },
        '32_2': {
            'cell_id': '32',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [23, 24, 25, 26],
            'atten_ul': {
                36: [23, 24, 25, 26],
            },
            'atten_dl': {
                30: [23, 24, 25, 26],
            }
        },
        '33': {
            'cell_id': '33',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [27, 28, 29, 30],
            'atten_ul': {
                47: [27, 28, 29, 30],
            },
            'atten_dl': {
                20: [27, 28, 29, 30],
            }
        },
        '34': {
            'cell_id': '34',
            'ip_address': [ATTENUATOR_IP1],
            'ports': [31, 32],
            'atten_ul': {
                16: [31, 32],
            },
            'atten_dl': {
                16: [31, 32],
            }
        },
    },
}

QRXLEV = {
    'LTE': {
        'parameter_name': 'qrxlevmin',
        'min': '-44',
        'max': '-100',
    },
    'NR': {
        'parameter_name': 'qRxLevMin',
        'min': '-22',
        'max': '-50',
    }
}

ATTENUATOR_MATRIX = generate_attenuator_matrix(ATTENUATOR_MAP, QRXLEV)

PARAM_TO_CHANGE_WITH_COMM = [
    {
        'param_name': 'gnssLineDelay',
        'dist_name': 'MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1',
        'correct_value': '200',
        'incorrect_value': '3000',
        'mod_type': 'Restart needed',
        'fault_type': 'VALUE_IS_TOO_BIG'
    },
]

REAL_CELL_IDS = {
    'LNCEL-11': '19739403'
}
