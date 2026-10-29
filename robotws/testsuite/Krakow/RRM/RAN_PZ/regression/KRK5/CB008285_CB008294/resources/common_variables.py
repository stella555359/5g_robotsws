import os
import json
from robot.libraries.BuiltIn import BuiltIn
from resources import generate_attenuator_matrix


TPUT_MATRIX = {
    'CB008285_A_016': {
        'NRCELL-251': {
            'tput_dl': '505 Mbits/sec',
            'tput_ul': '140 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': '4',
            'linux_congestion': None
        }
    },
    'CB008285_A_011': {
        'NRCELL-251': {
            'tput_dl': '345 Mbits/sec',
            'tput_ul': '114 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': '4',
            'linux_congestion': None
        }
    },
    'CB008285_A_013': {
        'NRCELL-251': {
            'tput_dl': '505 Mbits/sec',
            'tput_ul': '140 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': '4',
            'linux_congestion': None
        }
    },
    'CB008285_B_044': {
        'NRCELL-251': {
            'tput_dl': '345 Mbits/sec',
            'tput_ul': '110 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': '4',
            'linux_congestion': None
        }
    },
    'CB008294_A_B3_006_1_1': {
        'NRCELL-251': {
            'tput_dl': '560 Mbits/sec',
            'tput_ul': '140 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': '4',
            'linux_congestion': None
        }
    },
    'CB008294_A_B3_006_7_3': {
        'NRCELL-251': {
            'tput_dl': '3700 Mbits/sec',
            'tput_ul': '415 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',
            'linux_congestion': None
        }
    },
    'CB008294_A_B3_006_4_4': {
        'NRCELL-251': {
            'tput_dl': '2300 Mbits/sec',
            'tput_ul': '550 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': '4',
            'linux_congestion': None
        }
    },
    'CB008294_A_B3_006_8_4': {
        'NRCELL-251': {
            'tput_dl': '3800 Mbits/sec',
            'tput_ul': '550 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',
            'linux_congestion': None
        }
    },
    'CB008285_B_008': {
        'NRCELL-251': {
            'tput_dl': '500 Mbits/sec',
            'tput_ul': '140 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': '4',
            'linux_congestion': None
        }
    },
    'CB008285_B_025': {
        'NRCELL-251': {
            'tput_dl': '10 Mbits/sec',
            'tput_ul': '10 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',
            'linux_congestion': None
        }
    },
    'CB008294_A_PMO1_001': {
        'NRCELL-251': {
            'tput_dl': '4000 Mbits/sec',
            'tput_ul': '535 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',
            'linux_congestion': None
        }
    },
    'CB008285_B_010': {
        'NRCELL-251': {
            'tput_dl': '505 Mbits/sec',
            'tput_ul': '140 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': '4',
            'linux_congestion': None
        }
    },
    'CB008285_B_053': {
        'NRCELL-251': {
            'tput_dl': '410 Mbits/sec',
            'tput_ul': '130 Mbits/sec',
            'protocol': 'tcp',
            'parallel_streams': '4',
            'linux_congestion': None
        }
    },
    'CB008294_A_B3_002': {
        'NRCELL-251': {
            'tput_dl': '3700 Mbits/sec',
            'tput_ul': '535 Mbits/sec',
            'protocol': 'udp',
            'parallel_streams': '1',
            'linux_congestion': None
        }
    },
}

ATTENUATOR_VALUES = {
    'RADIORACK': {
        'max': 110,
        'avg': 5,
        'min': 0,
    },
    'TOPYOUNG': {
        'max': 90,
        'avg': 5,
        'min': 0,
    },
}

os.environ["ATTENUATOR_VALUES"] = json.dumps(ATTENUATOR_VALUES)  # need for new call procedure


ATTENUATOR_IP1 = BuiltIn().get_variable_value('${tl.attenuators[0].ip_addr}')
ATTENUATOR_IP2 = BuiltIn().get_variable_value('${tl.attenuators[1].ip_addr}')

ATTENUATOR_PORT = BuiltIn().get_variable_value('${tl.attenuators[0].port}')

VENDOR = BuiltIn().get_variable_value('${tl.attenuators[0].vendor}')

ATTENUATOR_MAP = {
    'NR': {
        '251': {
            'cell_id': '251',
            'real_cell_id': '1247117563',
            'attenuators': []
        },
    },
}

QRXLEV = {
    'LTE': {
        'parameter_name': 'qrxlevmin',
        'max': '-44',
        'min': '-100',
    },
    'NR': {
        'parameter_name': 'qRxLevMin',
        'max': '-22',
        'min': '-50',
    }
}

ATTENUATOR_MATRIX = generate_attenuator_matrix(ATTENUATOR_MAP, QRXLEV)


os.environ["UE_PROXY_PATH"] = ','.join([
    "UE_POOLS",
    "TafUeAtPool",
    "inline_config",
    "COM6",
    "CONSTRUCTOR_PARAMETERS",
    "configuration"
])

CALL_FLOW_MESSAGE_PATTERNS = [
    r'.*rrcContainer:\s+rrcSetupRequest.*',
    r'.*\"Decoded-NAS-message\":\s+\"REGISTRATION REQUEST.*',
    r'.*\"Decoded-NAS-message\":\s+\"REGISTRATION ACCEPT.*',
    r'.*.NGAP:\s+InitialUEMessage*.',
    r'.*.NGAP:\s+DownlinkNASTransport.*',
    r'.*.NGAP:\s+InitialContextSetupRequest.*',
    r'.*.NGAP:\s+UERadioCapabilityInfoIndication.*',
    r'.*.NGAP:\s+InitialContextSetupResponse.*',
    r'.pDUSessionResourceSetupRequestTransfer.*',
    r'.pDUSessionResourceSetupResponseTransfer.*',
    r'.*.NGAP:\s+UEContextReleaseCommand.*',
]


COUNTERS = {
    'CB008285_B_044': {
        'M55303C04002': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NULSQ']['M55303C04002']",
            "value": 1,
            "condition": ">="
        },
        'M55303C03001': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NULSQ']['M55303C03001']",
            "value": 0,
            "condition": ">="
        },
        'M55303C03000': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NULSQ']['M55303C03000']",
            "value": 0,
            "condition": ">="
        },
    },
    'CB008294_A_B3_006_7_3': {
        'M55118C00005': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00005']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00009': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00009']",
            "value": 1,
            "condition": ">="
        },
    },
    'CB008294_A_B3_006_4_4': {
        'M55118C09502': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C09502']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00010': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00010']",
            "value": 1,
            "condition": ">="
        },
    },
    'CB008294_A_B3_006_8_4': {
        'M55118C00006': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00006']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00010': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00010']",
            "value": 1,
            "condition": ">="
        },
    },
    'CB008285_B_008_1': {
        'M55119C00001': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NNGCB']['M55119C00001']",
            "value": 1,
            "condition": ">="
        },
        'M55119C00002': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NNGCB']['M55119C00002']",
            "value": 1,
            "condition": ">="
        }
    },
    'CB008285_B_008_2': {
        'M55119C00501': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NNGCB']['M55119C00501']",
            "value": 1,
            "condition": ">="
        }
    },
    'CB008285_B_020': {
        'M55124C00001': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NRRCC']['M55124C00001']",
            "value": 1,
            "condition": ">="
        },
        'M55124C05501': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NRRCC']['M55124C05501']",
            "value": 1,
            "condition": ">="
        },
        'M55157C00033': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NRMOP']['M55157C00033']",
            "value": 1,
            "condition": ">="
        }
    },
    'CB008294_A_PMO1_001': {
        'M55118C00003': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00003']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00006': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00006']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00008': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00008']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00010': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00010']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00015': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00015']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00012': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00012']",
            "value": 1,
            "condition": ">="
        },
        'M55139C03005': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['RSADU']['M55139C03005']",
            "value": 1,
            "condition": ">="
        },
        'M55139C03008': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['RSADU']['M55139C03008']",
            "value": 1,
            "condition": ">="
        },
        'M55138C03506': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['RSACU']['M55138C03506']",
            "value": 1,
            "condition": ">="
        },
        'M55138C03509': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['RSACU']['M55138C03509']",
            "value": 1,
            "condition": ">="
        },
        'M55156C00022': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['CUCM']['M55156C00022']",
            "value": 1,
            "condition": ">="
        },
        'M55156C00029': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['CUCM']['M55156C00029']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00017_1': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00017']",
            "value": 0,
            "condition": "=="
        },
        'M55118C00017_2': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-252']['NCAC']['M55118C00017']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00017_3': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-253']['NCAC']['M55118C00017']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00017_4': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-254']['NCAC']['M55118C00017']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00020_1': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00020']",
            "value": 0,
            "condition": "=="
        },
        'M55118C00020_2': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-252']['NCAC']['M55118C00020']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00020_3': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-253']['NCAC']['M55118C00020']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00020_4': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-254']['NCAC']['M55118C00020']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00020_5': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-255']['NCAC']['M55118C00020']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00020_6': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-256']['NCAC']['M55118C00020']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00020_7': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-257']['NCAC']['M55118C00020']",
            "value": 1,
            "condition": ">="
        },
    },
    'CB008285_B_053': {
        'M55306C06001': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NRACH']['M55306C06001']",
            "value": 2,
            "condition": ">="
        },
        'M55306C03001': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NRACH']['M55306C03001']",
            "value": 2,
            "condition": ">="
        }
    },
    'CB008294_A_B3_002': {
        'M55118C00006': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00006']",
            "value": 1,
            "condition": ">="
        },
        'M55118C00010': {
            "formula": "response['BTS']['MRBTS-76118']['NRBTS-76118']['NRCELL-251']['NCAC']['M55118C00010']",
            "value": 1,
            "condition": ">="
        }
    }
}

ADDITIONAL_ALARMS_FOR_TESTS = {
    'A_011': ['Incorrect cell parameter configuration'],
    'B_013': ['Antenna module lost'],
    'CB008285_B_007': ['Ethernet link unstable'],
    'CB008285_B_025': ['Failure in connection between BTS and 3rd party tool']

}
