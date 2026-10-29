# coding=utf-8
import os

from robot.libraries.BuiltIn import BuiltIn


def get_builtin_value(param_name, default=None):
    return BuiltIn().get_variable_value('${{{}}}'.format(param_name), default)


tl = get_builtin_value(param_name='tl')
OUTPUT_DIR = BuiltIn().get_variable_value('${OUTPUT_DIR}')
SUITE_NAME = BuiltIn().get_variable_value('${SUITE_NAME}')
NOKIA_PASS = tl.gnbs[0].cu.oam_ssh_connection_details.password
NOKIA_USERNAME = tl.gnbs[0].cu.oam_ssh_connection_details.username
NOKIA_LOGIN = tl.gnbs[0].cu.oam_ssh_connection_details.username
GNB_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr
AP_IP = tl.ues[0].l1.common_units[0].lmp_connection.addr
HTTP_PASS = tl.gnbs[0].cu.oam_http_connection_details.password
HTTP_LOGIN = tl.gnbs[0].cu.oam_http_connection_details.username

DELTA_TC04 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files', 'CB008746-A_TC04_delta.json')
DELTA_TC05 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files', 'CB008746-A_TC05_delta.json')
DELTA_TC06 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files', 'CB008746-A_TC06_delta.json')
DELTA_TC07 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files', 'CB008746-A_TC07_delta.json')
DELTA_TC08 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files', 'CB008746-A_TC08_delta.json')
DELTA_TC17 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files', 'CB008746-A_TC17_delta.json')
DELTA_TC17_ONLINE_CHANGE = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                        'delta_files', 'CB008746-A_TC17_online_change_delta.json')

DELTA_TC20 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files', 'CB008746-C_TC20_delta.json')
DELTA_TC21 = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files', 'CB008746-C_TC21_delta.json')

SYSCOM_VALIDATION_TC04 = {
    'quotas': {
        '1': {
            'min': '20',
            'max': '70'
        },
        '2': {
            'min': '20',
            'max': '60'
        },
        '3': {
            'min': '20',
            'max': '80'
        },
        '4': {
            'min': '0',
            'max': '100'
        },
        '5': {
            'min': '0',
            'max': '100'
        },
        '6': {
            'min': '0',
            'max': '100'
        },
        '7': {
            'min': '0',
            'max': '100'
        },
        '8': {
            'min': '0',
            'max': '100'
        },
    },
    'plmns': {
        '1': {
            'mcc': '311',
            'mnc': '489',
            'mnc_length': '3',
        },
        '2': {
            'mcc': '312',
            'mnc': '490',
            'mnc_length': '3',
        }
    },
    'default_rgs': {
        1, 3, 4, 7
    }
}

SYSCOM_VALIDATION_TC05 = {
    'quotas': {
        '1': {
            'min': '10',
            'max': '40'
        },
        '2': {
            'min': '30',
            'max': '60'
        }
    },
    'plmns': {
        '1': {
            'mcc': '311',
            'mnc': '489',
            'mnc_length': '3',
        },
    },
    'default_rgs': {
        1, 2
    }
}

SYSCOM_VALIDATION_TC06 = {
    'quotas': {
        '1': {
            'min': '15',
            'max': '50'
        },
        '2': {
            'min': '10',
            'max': '40'
        },
        '3': {
            'min': '10',
            'max': '60'
        },
        '4': {
            'min': '20',
            'max': '80'
        },
        '5': {
            'min': '0',
            'max': '100'
        },
        '6': {
            'min': '0',
            'max': '100'
        },
    },
    'plmns': {
        '1': {
            'mcc': '311',
            'mnc': '489',
            'mnc_length': '3',
        },
        '2': {
            'mcc': '312',
            'mnc': '490',
            'mnc_length': '3',
        }
    },
    'default_rgs': {
        1, 3, 5, 6
    }
}

SYSCOM_VALIDATION_TC07 = {
    'quotas': {
        '1': {
            'min': '20',
            'max': '60'
        },
        '2': {
            'min': '10',
            'max': '50'
        }
    },
    'plmns': {
        '1': {
            'mcc': '311',
            'mnc': '489',
            'mnc_length': '3',
        },
    },
    'default_rgs': {
        1, 2
    }
}

SYSCOM_VALIDATION_TC08 = {
    'quotas': {
        '1': {
            'min': '20',
            'max': '60'
        },
        '2': {
            'min': '40',
            'max': '80'
        },
        '3': {
            'min': '10',
            'max': '80'
        }
    },
    'plmns': {
        '1': {
            'mcc': '311',
            'mnc': '489',
            'mnc_length': '3',
        },
        '2': {
            'mcc': '312',
            'mnc': '490',
            'mnc_length': '3',
        },
    },
    'default_rgs': {
        1, 3
    }
}

SYSCOM_VALIDATION_TC17 = {
    'quotas': {
        '1': {
            'min': '20',
            'max': '80'
        },
        '2': {
            'min': '20',
            'max': '40'
        },
        '3': {
            'min': '30',
            'max': '60'
        },
        '5': {
            'min': '2',
            'max': '100'
        },
        '6': {
            'min': '2',
            'max': '100'
        },
        '7': {
            'min': '2',
            'max': '100'
        }
    },
    'plmns': {
        '1': {
            'mcc': '311',
            'mnc': '489',
            'mnc_length': '3',
        },
        '2': {
            'mcc': '312',
            'mnc': '490',
            'mnc_length': '3',
        },
    },
    'default_rgs': {
        1, 3, 5, 6
    }
}

SYSCOM_VALIDATION_TC20 = {
    'quotas': {
        '1': {
            'min': '10',
            'max': '80'
        },
        '2': {
            'min': '30',
            'max': '80'
        },
        '3': {
            'min': '30',
            'max': '80'
        }
    },
    'plmns': {
        '1': {
            'mcc': '311',
            'mnc': '489',
            'mnc_length': '3',
        },
        '2': {
            'mcc': '312',
            'mnc': '490',
            'mnc_length': '3',
        },
    },
    'default_rgs': {
        1, 3
    }
}

SYSCOM_VALIDATION_TC21 = {
    'quotas': {
        '1': {
            'min': '10',
            'max': '80'
        },
        '2': {
            'min': '50',
            'max': '100'
        },
        '3': {
            'min': '0',
            'max': '100'
        },
        '4': {
            'min': '0',
            'max': '100'
        }
    },
    'plmns': {
        '1': {
            'mcc': '311',
            'mnc': '489',
            'mnc_length': '3',
        },
        '2': {
            'mcc': '312',
            'mnc': '490',
            'mnc_length': '3',
        },
    },
    'default_rgs': {
        1, 2, 3, 4
    }
}

SYSCOM_VALIDATION_TC22 = {
    'quotas': {
        '1': {
            'min': '20',
            'max': '60'
        },
        '2': {
            'min': '60',
            'max': '90'
        }
    },
    'plmns': {
        '1': {
            'mcc': '311',
            'mnc': '489',
            'mnc_length': '3',
        },
        '2': {
            'mcc': '312',
            'mnc': '490',
            'mnc_length': '3',
        },
    },
    'default_rgs': {
        1, 2
    }
}

UE_CAP_TC05 = 'E1A09000575F7A13160003C0A02C1001018093170019C3D0304D9061CF9863CA160704C020311C01AA3626EB04610D0' \
              '2083A4023EB65C558D0E7C471E819F604F8CC8E3C873E819F604FA8E7CC31E50B0381C3C5C0017C0070005F0001C80E' \
              '003650000500000751B0A303582308681041D2011F5B2E2AC6873E238F40CFB027C66471E439F40CFB027D473E618F2' \
              '8581C0E1E2E000BE0038002F8000E007001860E140400000E30F0A000309A00010E30F0A000305000020E30E0A00E26' \
              '8000030E307134200000718789A00184D00010B80180510134142281A044D929C5851276C94E2C2891364A71614E89B' \
              '2538B0226C94E2C2891364A7140F40B00F800A070300E0600A80E000C07C27004000000020000040100000000800001' \
              '0040000100200000C010000080080000500400200802008000060040000300200001C0100000E008004000000100001' \
              '00080040300C010000120080000A004002020080080040701C0100001724A0040C030B925000061724A00C0C0300C03' \
              '0B92500406018061724A0180C0300C0300C0300C2E4940201806018060185C928070300C0300C0300C0300C2E094000' \
              '185C928000313925002060189C928020300C0313825000062724A01C0C0300C0300C0300C031392500606018060189C' \
              '92800030392500E060180601806018060181C928030300C0300C0E0940001818020000340DE54D654D60A56065606D6' \
              '0CD652D64CD602D60256045646D6E9182B40D04000025949410000196524040000A5949410000396524040001259490' \
              '10000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504010300C965250' \
              '400032594940C52AAAA55174AAAE95455058AA071541A2A94C55268AA031540A2A91D5576A0097C09E8140A05028140' \
              'A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A050000600101C00C20200C' \
              '018080300010100600C04008000808030000200C018D50300008101820303A100'

MRDC_UE_CAPS_TC05 = 'A107C18C2608018280389A000000883982C100389A100004883D86C1001020713400309A00021222E442E61304' \
                    '20E2680061340006442E6130400E1400061340008441CC160841C2800000A440802809B00A0020580A106893A7' \
                    '42D929C5853A16C94E2C69D3A14ED929C5893A14ED929C5893A14ED929C5853A16C94E28080288000401010060' \
                    '0004018040800080202038020C00040100010000401804010060004000300808030080200C0008000401010060' \
                    '10040180008000C020200C0200'

VONR_UE_CAP_NR_TC06 = 'E1A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F88DAC3' \
                      '1B47498A823F96524CA01105B260901831E31FF9863CA160703878099D87619D876008006000000000E23000' \
                      '00000210602372687C0390400000290400000A90400001292500001A6017036F236B7480282000012CA4A080' \
                      '000CB29282000052CA4A080001CB29282000092CA4A480002A9652501340EAE91D5D0AA9A55515DA8020F003' \
                      '40201000000000004008010A41A8'

TC4_SA_UE_QOS_FLOWS_TO_BE_ADDED = [{'id': '2', '5qi': '7'},
                                   {'id': '3', '5qi': '8'}]

NSA_BEARER = (2, 3)
MU_MIMO_NSA_BEARER = (2, 3)
MU_MIMO_SECOND_PLMN_MCC_MNC = '312:490'

SHERPA_TYPES = ['L2Ps', 'L2Lo', 'L2HiRlc', 'L2HiPdcp']

NSA_ONLY_SIB_RECEPTION_DICT = {1: [1]}
CA_CELL_SIB_RECEPTION_DICT = {2: [1, 2]}
ALL_CELLS_SIB_RECEPTION_DICT = {2: [1, 2, 3, 4]}

OPTLINK = '<optlink>\n<physicalId>1.7</physicalId>\n<virtualId>2</virtualId>\n<linkRate>25</linkRate>' \
          '\n<rat>5G</rat>\n</optlink>\n'

UE_CAP_NR_TC21 = 'E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD820' \
                 '2020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025' \
                 '965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA' \
                 '3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E' \
                 '0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B7000' \
                 '0800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F00000' \
                 '0000000072A68000800004B2CA801A55542C007000B00000004008011AB130001020304050607080B10111213192125' \
                 '2627284A71ADA'

TRAFFIC_PARAMS_TC6 = [
    {'ue_id': 151, 'traffic_id': 2, 'tput': 50, 'bearer': 2},
    {'ue_id': 152, 'traffic_id': 2, 'tput': 50, 'bearer': 2},
    {'ue_id': 153, 'traffic_id': 2, 'tput': 50, 'bearer': 2},
    {'ue_id': 154, 'traffic_id': 2, 'tput': 50, 'bearer': 2},
    {'ue_id': 155, 'traffic_id': 2, 'tput': 50, 'bearer': 2},
    {'ue_id': 156, 'traffic_id': 3, 'tput': 50, 'bearer': 2},
    {'ue_id': 157, 'traffic_id': 2, 'tput': 50, 'bearer': 2},
    {'ue_id': 158, 'traffic_id': 3, 'tput': 50, 'bearer': 2},
    {'ue_id': 51, 'traffic_id': 2, 'tput': 30, 'bearer': 1},
    {'ue_id': 52, 'traffic_id': 2, 'tput': 8, 'bearer': 2},
    {'ue_id': 53, 'traffic_id': 2, 'tput': 8, 'bearer': 2},
    {'ue_id': 54, 'traffic_id': 2, 'tput': 8, 'bearer': 2},
    {'ue_id': 55, 'traffic_id': 2, 'tput': 40, 'bearer': 1},
]

MU_MIMO_TRAFFIC_PARAMS_TC20 = [
    {'ue_id': 101, 'traffic_id': 2, 'tput': 175, 'bearer': 2},
    {'ue_id': 101, 'traffic_id': 3, 'tput': 175, 'bearer': 3},
    {'ue_id': 102, 'traffic_id': 2, 'tput': 175, 'bearer': 2},
    {'ue_id': 102, 'traffic_id': 3, 'tput': 175, 'bearer': 3},
    {'ue_id': 103, 'traffic_id': 2, 'tput': 175, 'bearer': 2},
    {'ue_id': 104, 'traffic_id': 2, 'tput': 175, 'bearer': 2},
    {'ue_id': 104, 'traffic_id': 3, 'tput': 175, 'bearer': 3},
    {'ue_id': 104, 'traffic_id': 4, 'tput': 175, 'bearer': 2},
    {'ue_id': 104, 'traffic_id': 5, 'tput': 175, 'bearer': 3},
    {'ue_id': 105, 'traffic_id': 2, 'tput': 175, 'bearer': 2},
    {'ue_id': 105, 'traffic_id': 3, 'tput': 175, 'bearer': 2},
    {'ue_id': 106, 'traffic_id': 2, 'tput': 175, 'bearer': 2},
    {'ue_id': 106, 'traffic_id': 3, 'tput': 175, 'bearer': 2},
    {'ue_id': 107, 'traffic_id': 2, 'tput': 175, 'bearer': 2},
    {'ue_id': 107, 'traffic_id': 3, 'tput': 175, 'bearer': 3},
]

MU_MIMO_TRAFFIC_PARAMS_TC21 = [
    {'ue_id': 101, 'traffic_id': 2, 'tput': 100, 'bearer': 2},
    {'ue_id': 101, 'traffic_id': 3, 'tput': 100, 'bearer': 3},
    {'ue_id': 102, 'traffic_id': 2, 'tput': 100, 'bearer': 2},
    {'ue_id': 102, 'traffic_id': 3, 'tput': 100, 'bearer': 3},
    {'ue_id': 103, 'traffic_id': 2, 'tput': 100, 'bearer': 2},
    {'ue_id': 103, 'traffic_id': 3, 'tput': 100, 'bearer': 3},
    {'ue_id': 104, 'traffic_id': 2, 'tput': 175, 'bearer': 2},
    {'ue_id': 104, 'traffic_id': 3, 'tput': 175, 'bearer': 3},
    {'ue_id': 104, 'traffic_id': 4, 'tput': 175, 'bearer': 2},
    {'ue_id': 105, 'traffic_id': 2, 'tput': 175, 'bearer': 2},
    {'ue_id': 105, 'traffic_id': 3, 'tput': 175, 'bearer': 3},
    {'ue_id': 106, 'traffic_id': 2, 'tput': 175, 'bearer': 2},
    {'ue_id': 106, 'traffic_id': 3, 'tput': 175, 'bearer': 3},
    {'ue_id': 106, 'traffic_id': 4, 'tput': 175, 'bearer': 3},
    {'ue_id': 1, 'traffic_id': 1, 'tput': 175, 'bearer': 1},
    {'ue_id': 2, 'traffic_id': 1, 'tput': 20, 'bearer': 2},
    {'ue_id': 3, 'traffic_id': 1, 'tput': 175, 'bearer': 1},
    {'ue_id': 4, 'traffic_id': 1, 'tput': 20, 'bearer': 2},
]

MU_MIMO_TRAFFIC_PARAMS_TC22 = [
    {"ue_id": 101, "traffic_id": 1, "tput": 135, 'bearer': 2},
    {"ue_id": 101, "traffic_id": 2, "tput": 135, 'bearer': 2},
    {"ue_id": 102, "traffic_id": 1, "tput": 135, 'bearer': 2},
    {"ue_id": 102, "traffic_id": 2, "tput": 135, 'bearer': 2},
    {"ue_id": 103, "traffic_id": 1, "tput": 135, 'bearer': 2},
    {"ue_id": 103, "traffic_id": 2, "tput": 135, 'bearer': 2},
    {"ue_id": 104, "traffic_id": 1, "tput": 150, 'bearer': 2},
    {"ue_id": 104, "traffic_id": 2, "tput": 150, 'bearer': 2},
    {"ue_id": 104, "traffic_id": 3, "tput": 150, 'bearer': 2},
    {"ue_id": 105, "traffic_id": 1, "tput": 150, 'bearer': 2},
    {"ue_id": 105, "traffic_id": 2, "tput": 150, 'bearer': 2},
    {"ue_id": 105, "traffic_id": 3, "tput": 150, 'bearer': 2},
    {"ue_id": 106, "traffic_id": 1, "tput": 150, 'bearer': 2},
    {"ue_id": 106, "traffic_id": 2, "tput": 150, 'bearer': 2},
    {"ue_id": 106, "traffic_id": 3, "tput": 150, 'bearer': 2},
]

ARTIFACTORY_REPO_URL = 'https://artifactory-espoo2.int.net.nokia.com/artifactory/asmrap-krk-local//'
BSR_ARTIFACTORY_FILENAME = '1866-A_BSR_AQQL_FULL.zip'
BSR_PACKAGE_NAME = 'BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip'

DEFAULT_IPHY_PATH = '/home/ute/testline_init_results/execution/configs/topology_configs/' \
                    'SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE/iphy.xml'

CELL_IDS_1 = [50]
CELL_IDS_3 = [52]
CELL_IDS_1_2 = [50, 51]
