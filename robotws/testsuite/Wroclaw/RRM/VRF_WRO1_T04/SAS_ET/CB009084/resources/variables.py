# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek
:contact: michal.maczek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import math
import os


SKIP_REPORT_TO_QC = False

CURDIR = '{}'.format(os.path.dirname(os.path.realpath(__file__)))

GNB_IP = '192.168.255.129'
AP_IP = '192.168.200.129'
NOKIA_USERNAME = 'toor4nsn'
NOKIA_PASS = "oZPS0POrRieRtu"
WEBEM_USERNAME = 'Nemuadmin'
WEBEM_PASS = 'nemuuser'

TRUE = True
FALSE = False

IPHY_DIR_PATH_DEFAULT = '/opt/iphy/latest'
EGATE_CONSOLE_LOG = os.path.join(IPHY_DIR_PATH_DEFAULT, 'egate_console.log')
EDAEMON_PORT = '22222'
EGATE_PORT = '20000'
SIB_RECEPTION_DICT_SA_SANSA_3CELL = {2: [3]}
SIB_RECEPTION_DICT_SA_SANSA = {2: [1]}
SIB_RECEPTION_LIST = [SIB_RECEPTION_DICT_SA_SANSA, {2: [2]}, {2: [3]}]
DO_NOT_ALLOW_FIRST_REBOOT = False
SET_VARIABLE_DURING_SCF_COLLECTION = True

ENB_ID = '1'
GNB_ID = '2'

TPUT_LIFETIME = '1200'

LARGE_BWP = 'large'
SMALL_BWP = 'small'

TELNET_FILE = '/home/ute/telnet.txt'
SCF_DIR = "/home/ute/testline_init_results/execution/configs/topology_configs/node_1/"
BASIC_SCF_FILE_PRB_DSS = os.path.join(SCF_DIR, "SANSA_FS_CPRI_CMWV_FDD/scfc.xml")
SCFS = {
    'basic': os.path.join(SCF_DIR, "SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE/scfc.xml"),
    'custom': "/home/ute/testline_init_results/configs/custom-config/sm/scfc.xml"
}
DELTAS = {
    "FDD": {
        'max_over_100': None,
        'min_over_100': None,
        'min_over_max': None,
        '6nsa_20sa': None,
        'pooling': os.path.join(CURDIR, 'configs/FDD/DELTA_PRB_POOLING.json'),
        'prb_dss': os.path.join(CURDIR, 'configs/FDD/DELTA_PRB_DSS.json'),
        'dss': os.path.join(CURDIR, 'configs/FDD/DELTA_DSS.json'),
        'f_mu_mimo': None,  # Only TDD
        'g_multiple_bwps': None,
        'c_harq_retx': os.path.join(CURDIR, 'configs/FDD/DELTA_C_B501_HARQ_RETX.json'),
        'h_ec2_gbr_load': os.path.join(CURDIR, 'configs/FDD/DELTA_H_EC2_GBR_LOAD.json')
    },
    "TDD": {
        'max_over_100': os.path.join(CURDIR, 'configs/TDD/DELTA_MAX_OVER_100.json'),
        'min_over_100': os.path.join(CURDIR, 'configs/TDD/DELTA_MIN_OVER_100.json'),
        'min_over_max': os.path.join(CURDIR, 'configs/TDD/DELTA_MIN_OVER_MAX.json'),
        '6nsa_20sa': os.path.join(CURDIR, 'configs/TDD/DELTA_6NSA_20SA_ITEM_C.json'),
        '7nsa_21sa': os.path.join(CURDIR, 'configs/TDD/DELTA_7NSA_21SA.json'),
        'grb_enabled': os.path.join(CURDIR, 'configs/TDD/DELTA_GRB_ENABLED.json'),
        'f_mu_mimo': os.path.join(CURDIR, 'configs/TDD/DELTA_MU_MIMO.json'),
        'g_multiple_bwps': os.path.join(CURDIR, 'configs/TDD/DELTA_G_MULTIPLE_BWPs_TDD.json'),
        'c_harq_retx': None,  # Only FDD
        'h_ec2_gbr_load': None  # Only FDD
    }
}

DELTA_RECONFIG = os.path.join(CURDIR, 'configs/DELTA_RECONFIG.json')

WTS_CONFIGS = {
    'FDD': {
        'prb_dss':  os.path.join(CURDIR, 'configs/FDD/dss_pooling.cfg'),
        'dss':  os.path.join(CURDIR, 'configs/FDD/dss.cfg'),
        'pooling': os.path.join(CURDIR, 'configs/FDD/pooling.cfg'),
        'f_mu_mimo': None,  # Only TDD
        'g_multiple_bwps': None,
        'c_harq_retx': os.path.join(CURDIR, 'configs/FDD/basic_setup_C_B501_harq_retx.cfg'),
        '6UE_ext_traffic': None,
        'h_ec2_gbr_load': os.path.join(CURDIR, 'configs/FDD/basic_setup_H_EC2_GBR_LOAD.cfg')
    },
    'TDD': {
        '6UE_ext_traffic':  os.path.join(CURDIR, 'configs/TDD/6UE_ext_traffic.cfg'),
        'f_mu_mimo': os.path.join(CURDIR, 'configs/TDD/mu_mimo.cfg'),
        'grb_enabled': os.path.join(CURDIR, 'configs/TDD/grb_enabled.cfg'),
        'g_multiple_bwps': os.path.join(CURDIR, 'configs/TDD/basic_setup_G_multiple_bwps_TDD.cfg'),
        'c_harq_retx': None,  # Only FDD
        'h_ec2_gbr_load': None  # Only FDD
    }
}

CELL_WITH_TPUT_FOR_H_EC2_GBR_LOAD = '3'

VENDOR_GNB = os.path.join(CURDIR, 'configs/FDD/vendor_from_gnb.xml')
VENDOR_PRB_DSS = os.path.join(CURDIR, 'configs/FDD/vendor_PRB_DSS.xml')
VENDOR_PRB = os.path.join(CURDIR, 'configs/FDD/vendor_PRB.xml')
VENDOR_DSS_DICT = {
    'maxNumLayerPrbDlL1Sp': '424',
    'maxNumLayerPrbUlL1Sp': '212',
    'maxNumStreamPrbDlL1Sp': '424',
    'maxNumStreamPrbUlL1Sp': '424'
}
VENDOR_PRB_DICT = {
    'maxNumLayerPrbDlL1Sp': '636',
    'maxNumLayerPrbUlL1Sp': '318',
    'maxNumStreamPrbDlL1Sp': '636',
    'maxNumStreamPrbUlL1Sp': '636'
}
SCF_PATH_DSS = os.path.join(CURDIR, 'configs/custom/base_scf_DSS.xml')
IPHY_PATH_DSS = os.path.join(CURDIR, 'configs/custom/iphy_DSS.xml')
SCF_PATH_PRB_DSS = os.path.join(CURDIR, 'configs/custom/base_scf_PRB_DSS.xml')
IPHY_PATH_PRB_DSS = os.path.join(CURDIR, 'configs/custom/iphy_PRB_DSS.xml')

IPHY_PATH_H_GBR = os.path.join(CURDIR, 'configs/custom/iphy_H_GBR.xml')

UE1_ID = '1'
UE2_ID = '2'
UE3_ID = '3'
UES_IDS_G_LARGE = ['1', '3', '5']
UES_IDS_G_SMALL = ['2', '4', '6']
SLICES_IDS_G = ['1', '2', '3']
SA_2UE_IDS = ['1', '2']
SA_3UE_IDS = ['1', '2', '3']
NSA_6UE_IDS = ['11', '12', '13', '14', '15', '16']
NSA_1UE_ID = ['11']
FROM_1_TO_7 = [str(slice) for slice in range(1, 8)]
FROM_8_TO_14 = [str(slice) for slice in range(8, 15)]
FROM_15_TO_20 = [str(slice) for slice in range(15, 21)]
SA_20_SLICES = [FROM_1_TO_7, FROM_8_TO_14, FROM_15_TO_20]
NSA_PLMNS = ['311:489', '312:490', '313:491', '314:492', '315:493', '316:494']
MAX_TDD_UTE = 20
MAX_FDD_UTE = 20
MAX_NSA_UE = 5
UE_IP_DL = {
    'TDD': ['1.2.4.{}'.format(i+2) for i in range(MAX_TDD_UTE)],
    'FDD': ['1.2.4.{}'.format(i+2) for i in range(MAX_TDD_UTE)],
    'NSA': ['4.7.254.208'] + ['4.7.254.21{}'.format(i+2) for i in range(MAX_NSA_UE)]
}
TPUT_40MHZ = '40'
MCC_311 = '311'
MNC_489 = '489'
SST_1 = '1'
SD_13714341 = '13714341'
SD_2 = '2'
SD_3 = '3'
FIRST_BEAM_F_MU_MIMO = {
    'profile_id': '1',
    'ueBeamIndexInitial': '0,1',
    'csirs_bestbeam': '1',
    'csirs_rsrp_best': '-44',
    'csirs_rsrp_avg': '-50',
    'ue_testmode_set_nr_id': '1',
    'testmode': 'beam_control',
    'action': 'activate',
    'beamaction': 'attach'
}
SECOND_BEAM_F_MU_MIMO = {
    'profile_id': '2',
    'ueBeamIndexInitial': '1,0',
    'csirs_bestbeam': '6',
    'csirs_rsrp_best': '-45',
    'csirs_rsrp_avg': '-120',
    'ue_testmode_set_nr_id': '2',
    'testmode': 'beam_control',
    'action': 'activate',
    'beamaction': 'attach'
}
DEFAULT_PLMN_INFP_F_MU_MIMO = {
    'mcc': '311',
    'mnc': '489'
}
# 3 UEs are needed, only for 2 beams are configured
BEAMFORMING_INFO_F_MU_MIMO = [FIRST_BEAM_F_MU_MIMO, SECOND_BEAM_F_MU_MIMO, None]
PLMNS_INFO_F_MU_MIMO = [DEFAULT_PLMN_INFP_F_MU_MIMO, DEFAULT_PLMN_INFP_F_MU_MIMO, DEFAULT_PLMN_INFP_F_MU_MIMO]
SST_SD_INFO_F_MU_MIMO = [{'sst': '1', 'sd': '13714341'}, {'sst': '1', 'sd': '2'}, {'sst': '1', 'sd': '3'}]
TPUT = {'TDD': '220',
        'FDD': '250'}
TPUT_IPERF = '250M'
CB_TPUT = '50M'
GRB_ENABLED_SLICES_ID = ['3', '1', '2']
GRB_WAIT_TIME = [200, 0, 200]
# First ue doesn't have modified pdu session
PDU_SESSION_SETUP = [
    None,
    {
        'pdu': '2',
        'ue': '2',
        'qosflows_to_add': '3',
        'qosflows_to_del': None,
        'by': 'amf'
    },
    {
        'pdu': '3',
        'ue': '3',
        'qosflows_to_add': '4',
        'qosflows_to_del': None,
        'by': 'amf'
    }
]

PDU_3UE_IDS_G_MULTIPLE_BWPS = ['1', '2', '3']
GW_3UE_IDS_G_MULTIPLE_BWPS = ['1', '2', '3']

PDU_SESSION_MODIFY_INFO_DURING_ATTACH_INFO_H_EC2_GBR_LOAD = {
    'ue': '51',
    'pdu': '2',
    'qosflows_to_add': '2',
    'qosflows_to_del': None,
    'by': 'amf'
}
PDU_SESSION_MODIFY_INFO_3_UE_VONR_INFO_H_EC2_GBR_LOAD = {
    'ue': '1',
    'pdu': '2',
    'qosflows_to_add': '2',
    'qosflows_to_del': None,
    'by': 'amf'
}
SA_3UE_IDS_H_EC2_GBR_LOAD = ['1', '2', '3']
SLICES_3UE_H_EC2_GBR_LOAD = ['1', '2', '3']
PDU_3UE_IDS_H_EC2_GBR_LOAD = ['1', '2', '3']
GW_3UE_IDS_H_EC2_GBR_LOAD = ['1', '2', '3']
PDU_SESSIONS_MODIFY_INFO_H_EC2_GBR_LOAD = [None, None, PDU_SESSION_MODIFY_INFO_DURING_ATTACH_INFO_H_EC2_GBR_LOAD]

BLER_INFO_C_HARQ_RETX = {
    'csi_profile_id': '2',
    'cqi_mode': 'fixed',
    'cqi': '8',
    'ri_mode': 'fixed',
    'ri': '1',
    'pmi_mode': 'fixed',
    'pmi': '0',
    'bler_profile_id': '25',
    'dl_bler': '100,100,100,100,100,100,100,100',
}

TRIGGER_BLER_INFO_C_HARQ_RETX = {
    'id': '1',
    'testmode': 'bler',
    'action': 'activate',
    'profile_id': BLER_INFO_C_HARQ_RETX['bler_profile_id']
}

DEACTIVATE_BLER_INFO_C_HARQ_RETX = {
    'id': TRIGGER_BLER_INFO_C_HARQ_RETX['id'],
    'testmode': TRIGGER_BLER_INFO_C_HARQ_RETX['testmode'],
    'action': 'deactivate',
    'profile_id': BLER_INFO_C_HARQ_RETX['bler_profile_id']
}

BH_ETH3_IP_ADDR = \
    ['10.0.1.1', '10.0.1.121', '10.0.1.131', '10.0.1.133', '10.0.1.134', '10.0.1.135', '10.0.1.136', '10.0.1.137']
BH_ETH4_IP_ADDR = ['10.0.2.1', '10.0.2.121']

ALIAS_TSHARK_SHERPA = "ALIAS_TSHARK_SHERPA"
SHERPA_L2PS = "L2Ps"
SHERPA_L2HIPDCP = "L2HiPdcp"
SHERPA_TYPES = [SHERPA_L2PS, SHERPA_L2HIPDCP]
SHERPA_SOURCE_IP = '10.0.1.2'
SHERPA_DESTINATION_IP = '10.0.1.1'
SHERPA_PORT = 5678
SHERPA_DSCP = 32
SHERPA_ETH_INTERFACE = "eth4"
SHERPA_PREFIX = "sherpa_9084_"

COLLECTOR_NAME = 'l2stream3'
TTITRACE_NAME_PREFIX = 'ttitrace_9084_'

SYSLOG_NAME_PREFIX = "syslog_9084_"
SYSLOG_ALIAS = "ALIAS_SYSLOG_GNB"
SNAPSHOT_NAME_PREFIX = "snapshot_9084_"

UTILIZATION_MARGIN = 10
UTILIZATION_MARGIN_C = 2

DELTA_DYNAMIC_KEYS_SUBSTITUTES_SUBFEATURE_MAPPING = {
    'quotas': {
        "$resourceGroup1_minQuota": '10',
        "$resourceGroup1_maxQuota": '20',
        "$resourceGroup2_minQuota": '30',
        "$resourceGroup2_maxQuota": '40',
        "$resourceGroup3_minQuota": '50',
        "$resourceGroup3_maxQuota": '60',
        "$resourceGroup4_minQuota": '70',
        "$resourceGroup4_maxQuota": '80',
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2",
        '$resourceGroup3_dn': "SNSSAI-3",
        '$resourceGroup4_dn': "SNSSAI-4"
    },
    'sd': {
        '$sdValue1': '1',
        '$sdValue2': '2',
        '$sdValue3': '3',
        '$sdValue4': '4'
    },
    'mcc': {
        '$mccValue1': '1',
        '$mccValue2': '2',
        '$mccValue3': '3',
        '$mccValue4': '4'
    },
    'mnc': {
        '$mncValue1': '1',
        '$mncValue2': '2',
        '$mncValue3': '3',
        '$mncValue4': '4'
    },
    'cell_params': {
        '$nrCellId': "1",
        '$cellDepType': "SA+NSA"
    }
}

DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C_RECONFIG = {
    'quotas': {
        "$resourceGroup1_minQuota": '2',
        "$resourceGroup1_maxQuota": '50',
        "$resourceGroup2_minQuota": '2',
        "$resourceGroup2_maxQuota": '60',
        "$resourceGroup3_minQuota": '2',
        "$resourceGroup3_maxQuota": '20',
        "$resourceGroup4_minQuota": '2',
        "$resourceGroup4_maxQuota": '10',
        "$resourceGroup5_minQuota": '2',
        "$resourceGroup5_maxQuota": '99',
        "$resourceGroup6_minQuota": '2',
        "$resourceGroup6_maxQuota": '5',
        "$resourceGroup7_minQuota": '5',
        "$resourceGroup7_maxQuota": '10',
        "$resourceGroup8_minQuota": '5',
        "$resourceGroup8_maxQuota": '12',
        "$resourceGroup9_minQuota": '5',
        "$resourceGroup9_maxQuota": '14',
        "$resourceGroup10_minQuota": '5',
        "$resourceGroup10_maxQuota": '16',
        "$resourceGroup11_minQuota": '5',
        "$resourceGroup11_maxQuota": '18',
        "$resourceGroup12_minQuota": '5',
        "$resourceGroup12_maxQuota": '20',
        "$resourceGroup13_minQuota": '5',
        "$resourceGroup13_maxQuota": '22',
        "$resourceGroup14_minQuota": '5',
        "$resourceGroup14_maxQuota": '24',
        "$resourceGroup15_minQuota": '5',
        "$resourceGroup15_maxQuota": '26',
        "$resourceGroup16_minQuota": '5',
        "$resourceGroup16_maxQuota": '14',
        "$resourceGroup17_minQuota": '2',
        "$resourceGroup17_maxQuota": '50',
        "$resourceGroup18_minQuota": '2',
        "$resourceGroup18_maxQuota": '50',
        "$resourceGroup19_minQuota": '2',
        "$resourceGroup19_maxQuota": '50',
        "$resourceGroup20_minQuota": '5',
        "$resourceGroup20_maxQuota": '36',
        "$resourceGroup21_minQuota": '5',
        "$resourceGroup21_maxQuota": '16',
        "$resourceGroup22_minQuota": '1',
        "$resourceGroup22_maxQuota": '36',
        "$resourceGroup23_minQuota": '1',
        "$resourceGroup23_maxQuota": '36',
        "$resourceGroup24_minQuota": '1',
        "$resourceGroup24_maxQuota": '36',
        "$resourceGroup25_minQuota": '1',
        "$resourceGroup25_maxQuota": '36',
        "$resourceGroup26_minQuota": '1',
        "$resourceGroup26_maxQuota": '36'
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2",
        '$resourceGroup3_dn': "SNSSAI-3",
        '$resourceGroup4_dn': "SNSSAI-4",
        '$resourceGroup5_dn': "SNSSAI-5",
        '$resourceGroup6_dn': "SNSSAI-6",
        '$resourceGroup7_dn': "SNSSAI-7",
        '$resourceGroup8_dn': "SNSSAI-8",
        '$resourceGroup9_dn': "SNSSAI-9",
        '$resourceGroup10_dn': "SNSSAI-10",
        '$resourceGroup11_dn': "SNSSAI-11",
        '$resourceGroup12_dn': "SNSSAI-12",
        '$resourceGroup13_dn': "SNSSAI-13",
        '$resourceGroup14_dn': "SNSSAI-14",
        '$resourceGroup15_dn': "SNSSAI-15",
        '$resourceGroup16_dn': "SNSSAI-16",
        '$resourceGroup17_dn': "SNSSAI-17",
        '$resourceGroup18_dn': "SNSSAI-18",
        '$resourceGroup19_dn': "SNSSAI-19",
        '$resourceGroup20_dn': "SNSSAI-20",
        '$resourceGroup21_dn': "NRPLMN-1",
        '$resourceGroup22_dn': "NRPLMN-2",
        '$resourceGroup23_dn': "NRPLMN-3",
        '$resourceGroup24_dn': "NRPLMN-4",
        '$resourceGroup25_dn': "NRPLMN-5",
        '$resourceGroup26_dn': "NRPLMN-6"
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3',
        '$sdValue4': '4',
        '$sdValue5': '5',
        '$sdValue6': '6',
        '$sdValue7': '7',
        '$sdValue8': '8',
        '$sdValue9': '9',
        '$sdValue10': '10',
        '$sdValue11': '11',
        '$sdValue12': '12',
        '$sdValue13': '13',
        '$sdValue14': '14',
        '$sdValue15': '15',
        '$sdValue16': '16',
        '$sdValue17': '17',
        '$sdValue18': '18',
        '$sdValue19': '19',
        '$sdValue20': '20',
        '$sdValue21': None,
        '$sdValue22': None,
        '$sdValue23': None,
        '$sdValue24': None,
        '$sdValue25': None,
        '$sdValue26': None
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1',
        '$sstValue4': '1',
        '$sstValue5': '1',
        '$sstValue6': '1',
        '$sstValue7': '1',
        '$sstValue8': '1',
        '$sstValue9': '1',
        '$sstValue10': '1',
        '$sstValue11': '1',
        '$sstValue12': '1',
        '$sstValue13': '1',
        '$sstValue14': '1',
        '$sstValue15': '1',
        '$sstValue16': '1',
        '$sstValue17': '1',
        '$sstValue18': '1',
        '$sstValue19': '1',
        '$sstValue20': '1',
        '$sstValue21': None,
        '$sstValue22': None,
        '$sstValue23': None,
        '$sstValue24': None,
        '$sstValue25': None,
        '$sstValue26': None
    },
    'mcc': {
        '$mccValue1': '311',
        '$mccValue2': '311',
        '$mccValue3': '311',
        '$mccValue4': '311',
        '$mccValue5': '311',
        '$mccValue6': '311',
        '$mccValue7': '311',
        '$mccValue8': '311',
        '$mccValue9': '311',
        '$mccValue10': '311',
        '$mccValue11': '311',
        '$mccValue12': '311',
        '$mccValue13': '311',
        '$mccValue14': '311',
        '$mccValue15': '311',
        '$mccValue16': '311',
        '$mccValue17': '311',
        '$mccValue18': '311',
        '$mccValue19': '311',
        '$mccValue20': '311',
        '$mccValue21': '311',
        '$mccValue22': "312",
        '$mccValue23': "313",
        '$mccValue24': "314",
        '$mccValue25': "315",
        '$mccValue26': "316"
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '489',
        '$mncValue3': '489',
        '$mncValue4': '489',
        '$mncValue5': '489',
        '$mncValue6': '489',
        '$mncValue7': '489',
        '$mncValue8': '489',
        '$mncValue9': '489',
        '$mncValue10': '489',
        '$mncValue11': '489',
        '$mncValue12': '489',
        '$mncValue13': '489',
        '$mncValue14': '489',
        '$mncValue15': '489',
        '$mncValue16': '489',
        '$mncValue17': '489',
        '$mncValue18': '489',
        '$mncValue19': '489',
        '$mncValue20': '489',
        '$mncValue21': '489',
        '$mncValue22': "490",
        '$mncValue23': "491",
        '$mncValue24': "492",
        '$mncValue25': "493",
        '$mncValue26': "494"
    },
    'cell_params': {
        '$nrCellId': {
            'FDD': "2",
            'TDD': "1"
        },
        '$cellDepType': "SA+NSA"
    }
}

DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C = {
    'quotas': {
        "$resourceGroup1_minQuota": '1',
        "$resourceGroup1_maxQuota": '2',
        "$resourceGroup2_minQuota": '2',
        "$resourceGroup2_maxQuota": '4',
        "$resourceGroup3_minQuota": '4',
        "$resourceGroup3_maxQuota": '8',
        "$resourceGroup4_minQuota": '8',
        "$resourceGroup4_maxQuota": '16',
        "$resourceGroup5_minQuota": '1',
        "$resourceGroup5_maxQuota": '2',
        "$resourceGroup6_minQuota": '2',
        "$resourceGroup6_maxQuota": '4',
        "$resourceGroup7_minQuota": '4',
        "$resourceGroup7_maxQuota": '8',
        "$resourceGroup8_minQuota": '8',
        "$resourceGroup8_maxQuota": '16',
        "$resourceGroup9_minQuota": '1',
        "$resourceGroup9_maxQuota": '2',
        "$resourceGroup10_minQuota": '2',
        "$resourceGroup10_maxQuota": '4',
        "$resourceGroup11_minQuota": '4',
        "$resourceGroup11_maxQuota": '8',
        "$resourceGroup12_minQuota": '8',
        "$resourceGroup12_maxQuota": '16',
        "$resourceGroup13_minQuota": '1',
        "$resourceGroup13_maxQuota": '2',
        "$resourceGroup14_minQuota": '2',
        "$resourceGroup14_maxQuota": '4',
        "$resourceGroup15_minQuota": '4',
        "$resourceGroup15_maxQuota": '8',
        "$resourceGroup16_minQuota": '8',
        "$resourceGroup16_maxQuota": '16',
        "$resourceGroup17_minQuota": '1',
        "$resourceGroup17_maxQuota": '2',
        "$resourceGroup18_minQuota": '2',
        "$resourceGroup18_maxQuota": '4',
        "$resourceGroup19_minQuota": '4',
        "$resourceGroup19_maxQuota": '8',
        "$resourceGroup20_minQuota": '8',
        "$resourceGroup20_maxQuota": '16',
        "$resourceGroup21_minQuota": '1',
        "$resourceGroup21_maxQuota": '2',
        "$resourceGroup22_minQuota": '2',
        "$resourceGroup22_maxQuota": '4',
        "$resourceGroup23_minQuota": '4',
        "$resourceGroup23_maxQuota": '8',
        "$resourceGroup24_minQuota": '8',
        "$resourceGroup24_maxQuota": '16',
        "$resourceGroup25_minQuota": '1',
        "$resourceGroup25_maxQuota": '40',
        "$resourceGroup26_minQuota": '1',
        "$resourceGroup26_maxQuota": '40'
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2",
        '$resourceGroup3_dn': "SNSSAI-3",
        '$resourceGroup4_dn': "SNSSAI-4",
        '$resourceGroup5_dn': "SNSSAI-5",
        '$resourceGroup6_dn': "SNSSAI-6",
        '$resourceGroup7_dn': "SNSSAI-7",
        '$resourceGroup8_dn': "SNSSAI-8",
        '$resourceGroup9_dn': "SNSSAI-9",
        '$resourceGroup10_dn': "SNSSAI-10",
        '$resourceGroup11_dn': "SNSSAI-11",
        '$resourceGroup12_dn': "SNSSAI-12",
        '$resourceGroup13_dn': "SNSSAI-13",
        '$resourceGroup14_dn': "SNSSAI-14",
        '$resourceGroup15_dn': "SNSSAI-15",
        '$resourceGroup16_dn': "SNSSAI-16",
        '$resourceGroup17_dn': "SNSSAI-17",
        '$resourceGroup18_dn': "SNSSAI-18",
        '$resourceGroup19_dn': "SNSSAI-19",
        '$resourceGroup20_dn': "SNSSAI-20",
        '$resourceGroup21_dn': "NRPLMN-1",
        '$resourceGroup22_dn': "NRPLMN-2",
        '$resourceGroup23_dn': "NRPLMN-3",
        '$resourceGroup24_dn': "NRPLMN-4",
        '$resourceGroup25_dn': "NRPLMN-5",
        '$resourceGroup26_dn': "NRPLMN-6"
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3',
        '$sdValue4': '4',
        '$sdValue5': '5',
        '$sdValue6': '6',
        '$sdValue7': '7',
        '$sdValue8': '8',
        '$sdValue9': '9',
        '$sdValue10': '10',
        '$sdValue11': '11',
        '$sdValue12': '12',
        '$sdValue13': '13',
        '$sdValue14': '14',
        '$sdValue15': '15',
        '$sdValue16': '16',
        '$sdValue17': '17',
        '$sdValue18': '18',
        '$sdValue19': '19',
        '$sdValue20': '20',
        '$sdValue21': None,
        '$sdValue22': None,
        '$sdValue23': None,
        '$sdValue24': None,
        '$sdValue25': None,
        '$sdValue26': None
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1',
        '$sstValue4': '1',
        '$sstValue5': '1',
        '$sstValue6': '1',
        '$sstValue7': '1',
        '$sstValue8': '1',
        '$sstValue9': '1',
        '$sstValue10': '1',
        '$sstValue11': '1',
        '$sstValue12': '1',
        '$sstValue13': '1',
        '$sstValue14': '1',
        '$sstValue15': '1',
        '$sstValue16': '1',
        '$sstValue17': '1',
        '$sstValue18': '1',
        '$sstValue19': '1',
        '$sstValue20': '1',
        '$sstValue21': None,
        '$sstValue22': None,
        '$sstValue23': None,
        '$sstValue24': None,
        '$sstValue25': None,
        '$sstValue26': None
    },
    'mcc': {
        '$mccValue1': '311',
        '$mccValue2': '311',
        '$mccValue3': '311',
        '$mccValue4': '311',
        '$mccValue5': '311',
        '$mccValue6': '311',
        '$mccValue7': '311',
        '$mccValue8': '311',
        '$mccValue9': '311',
        '$mccValue10': '311',
        '$mccValue11': '311',
        '$mccValue12': '311',
        '$mccValue13': '311',
        '$mccValue14': '311',
        '$mccValue15': '311',
        '$mccValue16': '311',
        '$mccValue17': '311',
        '$mccValue18': '311',
        '$mccValue19': '311',
        '$mccValue20': '311',
        '$mccValue21': '311',
        '$mccValue22': "312",
        '$mccValue23': "313",
        '$mccValue24': "314",
        '$mccValue25': "315",
        '$mccValue26': "316"
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '489',
        '$mncValue3': '489',
        '$mncValue4': '489',
        '$mncValue5': '489',
        '$mncValue6': '489',
        '$mncValue7': '489',
        '$mncValue8': '489',
        '$mncValue9': '489',
        '$mncValue10': '489',
        '$mncValue11': '489',
        '$mncValue12': '489',
        '$mncValue13': '489',
        '$mncValue14': '489',
        '$mncValue15': '489',
        '$mncValue16': '489',
        '$mncValue17': '489',
        '$mncValue18': '489',
        '$mncValue19': '489',
        '$mncValue20': '489',
        '$mncValue21': '489',
        '$mncValue22': "490",
        '$mncValue23': "491",
        '$mncValue24': "492",
        '$mncValue25': "493",
        '$mncValue26': "494"
    },
    'cell_params': {
        '$nrCellId': {
            'FDD': "2",
            'TDD': "1"
        },
        '$cellDepType': "SA+NSA"
    }
}

DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_E_PRB_POOLING = {
    'quotas': {
        "$resourceGroup1_minQuota": '45',
        "$resourceGroup1_maxQuota": '80',
        "$resourceGroup2_minQuota": '45',
        "$resourceGroup2_maxQuota": '80',
        "$resourceGroup3_minQuota": '5',
        "$resourceGroup3_maxQuota": '5'
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2",
        '$resourceGroup3_dn': "SNSSAI-4"
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1'
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '489',
        '$mncValue3': '489',
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '311',
        '$mncValue3': '311',
    },
    'nrcell': {
        '$nrcellValue1': '1',
        '$nrcellValue2': '2',
        '$nrcellValue3': '4'
    },
    'cell_params': {
        '$nrCellId': "1",
        '$cellDepType': "SA+NSA"
    }
}
DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_E_PRB_POOLING_DSS_1_CELL = {
    'quotas': {
        "$resourceGroup1_minQuota": '35',
        "$resourceGroup1_maxQuota": '80'
    }
}

DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_E_PRB_POOLING_DSS_2_CELL = {
    'quotas': {
        "$resourceGroup1_minQuota": '25',
        "$resourceGroup1_maxQuota": '80'
    }
}
DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_E_PRB_POOLING_DSS_3_CELL = {
    'quotas': {
        "$resourceGroup1_minQuota": '20',
        "$resourceGroup1_maxQuota": '30'
    }
}
DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_E_PRB_POOLING_DSS = {
    'quotas': {
        "$resourceGroup1_minQuota": '35',
        "$resourceGroup1_maxQuota": '80',
        "$resourceGroup2_minQuota": '25',
        "$resourceGroup2_maxQuota": '80',
        "$resourceGroup3_minQuota": '20',
        "$resourceGroup3_maxQuota": '30'
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2",
        '$resourceGroup3_dn': "SNSSAI-3"
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1'
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '489',
        '$mncValue3': '489',
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '311',
        '$mncValue3': '311',
    },
    'nrcell': {
        '$nrcellValue1': '1',
        '$nrcellValue2': '2',
        '$nrcellValue3': '3'
    },
    'cell_params': {
        '$nrCellId': "1",
        '$cellDepType': "SA+NSA"
    }
}

DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_E_DSS = {
    'quotas': {
        "$resourceGroup1_minQuota": '10',
        "$resourceGroup1_maxQuota": '80',
        "$resourceGroup2_minQuota": '20',
        "$resourceGroup2_maxQuota": '80',
        "$resourceGroup3_minQuota": '30',
        "$resourceGroup3_maxQuota": '80'
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2",
        '$resourceGroup3_dn': "SNSSAI-3"
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1'
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '489',
        '$mncValue3': '489',
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '311',
        '$mncValue3': '311',
    },
    'cell_params': {
        '$nrCellId': "3",
        '$cellDepType': "SA+NSA"
    }
}

DELTA_DYN_KEYS_SUBS_MAPPING_G_MULTI_BWP = {
    'quotas': {
        "$resourceGroup1_minQuota": '50',
        "$resourceGroup1_maxQuota": '80',
        "$resourceGroup2_minQuota": '20',
        "$resourceGroup2_maxQuota": '40',
        "$resourceGroup3_minQuota": '30',
        "$resourceGroup3_maxQuota": '50'
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2",
        '$resourceGroup3_dn': "SNSSAI-3"
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1'
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '489',
        '$mncValue3': '489',
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '311',
        '$mncValue3': '311',
    },
    'cell_params': {
        '$nrCellId': "1",
        '$cellDepType': "SA+NSA"
    }
}

DELTA_DYN_KEYS_SUBS_MAPPING_G_SMALL_BWP = {
    'quotas': {
        "$resourceGroup1_minQuota": '30',
        "$resourceGroup1_maxQuota": '40',
        "$resourceGroup2_minQuota": '30',
        "$resourceGroup2_maxQuota": '50',
        "$resourceGroup3_minQuota": '30',
        "$resourceGroup3_maxQuota": '60'
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2",
        '$resourceGroup3_dn': "SNSSAI-3"
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1'
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '489',
        '$mncValue3': '489',
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '311',
        '$mncValue3': '311',
    },
    'cell_params': {
        '$nrCellId': "1",
        '$cellDepType': "SA+NSA"
    }
}

DELTA_DYN_KEYS_SUBS_MAPPING_F_MU_MIMO = {
    'quotas': {
        "$resourceGroup1_minQuota": '10',
        "$resourceGroup1_maxQuota": '20',
        "$resourceGroup2_minQuota": '20',
        "$resourceGroup2_maxQuota": '40',
        "$resourceGroup3_minQuota": '40',
        "$resourceGroup3_maxQuota": '80'
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2",
        '$resourceGroup3_dn': "SNSSAI-3"
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1'
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '489',
        '$mncValue3': '489',
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '311',
        '$mncValue3': '311',
    },
    'cell_params': {
        '$nrCellId': "1",
        '$cellDepType': "SA+NSA"
    }
}

DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_C_B501_RETX = {
    'quotas': {
        "$resourceGroup1_minQuota": '10',
        "$resourceGroup1_maxQuota": '30',
        "$resourceGroup2_minQuota": '70',
        "$resourceGroup2_maxQuota": '100'
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2"
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1'
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '489'
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '311'
    },
    'nrcell': {
        '$nrcellValue1': '3',
        '$nrcellValue2': '3'
    },
    'cell_params': {
        '$nrCellId': "3",
        '$cellDepType': "SA+NSA"
    }
}

DELTA_DYN_KEYS_SUBSTITUTES_MAPPING_H_EC2_GBR_LOAD = {
    'quotas': {
        "$resourceGroup1_minQuota": '10',
        "$resourceGroup1_maxQuota": '60',
        "$resourceGroup2_minQuota": '5',
        "$resourceGroup2_maxQuota": '5',
        "$resourceGroup3_minQuota": '20',
        "$resourceGroup3_maxQuota": '20',
        "$resourceGroup4_minQuota": '15',
        "$resourceGroup4_maxQuota": '15',
        "$resourceGroup5_minQuota": '20',
        "$resourceGroup5_maxQuota": '20',
        "$resourceGroup6_minQuota": '25',
        "$resourceGroup6_maxQuota": '25',
        "$resourceGroup7_minQuota": '5',
        "$resourceGroup7_maxQuota": '5'
    },
    'dn_list': {
        '$resourceGroup1_dn': "SNSSAI-1",
        '$resourceGroup2_dn': "SNSSAI-2",
        '$resourceGroup3_dn': "SNSSAI-3",
        '$resourceGroup4_dn': "SNSSAI-4",
        '$resourceGroup5_dn': "SNSSAI-5",
        '$resourceGroup6_dn': "SNSSAI-6",
        '$resourceGroup7_dn': "SNSSAI-7"
    },
    'sd': {
        '$sdValue1': '13714341',
        '$sdValue2': '2',
        '$sdValue3': '3',
        '$sdValue4': '4',
        '$sdValue5': '5',
        '$sdValue6': '6',
        '$sdValue7': '7'
    },
    'sst': {
        '$sstValue1': '1',
        '$sstValue2': '1',
        '$sstValue3': '1',
        '$sstValue4': '1',
        '$sstValue5': '1',
        '$sstValue6': '1',
        '$sstValue7': '1'
    },
    'mnc': {
        '$mncValue1': '489',
        '$mncValue2': '489',
        '$mncValue3': '489',
        '$mncValue4': '489',
        '$mncValue5': '489',
        '$mncValue6': '489',
        '$mncValue7': '489'
    },
    'mcc': {
        '$mncValue1': '311',
        '$mncValue2': '311',
        '$mncValue3': '311',
        '$mncValue4': '311',
        '$mncValue5': '311',
        '$mncValue6': '311',
        '$mncValue7': '311'
    },
    'nrcell': {
        '$nrcellValue1': '3',
        '$nrcellValue2': '3',
        '$nrcellValue3': '3',
        '$nrcellValue4': '3',
        '$nrcellValue5': '3',
        '$nrcellValue6': '3',
        '$nrcellValue7': '3'
    },
    'cell_params': {
        '$nrCellId': "3",
        '$cellDepType': "SA+NSA"
    }
}

VALIDATION_ERROR = r'\"stack\"\:"Error: Validation failed\!\\n'
MIN_QUOTAS_ERROR = r'\"severity\: Error, text\: The sum of NRRESOURCEGROUP\.schedulerParams\.minQuota of all the ' + \
                   r'NRRESOURCEGROUP instances under a same parent NRRESOURCEGROUP_PROFILE instance shall be equal ' + \
                   r'or lower than 100\"'
MAX_QUOTAS_ERROR = r'it is required that \$\{NRRESOURCEGROUP\-\d\.schedulerParams\-\d\.minQuota\} \(value\: \d+\%' + \
                   r'\) less\/equal to \$\{NRRESOURCEGROUP\-\d\.schedulerParams\-\d\.maxQuota\} \(value\: \d+\%\)'
VALUE_IS_TOO_BIG = r'\'VALUE_IS_TOO_BIG\''
ADMIN_LOG_PATHS = ['/home/ute/robotws/admin_api_default.log',
                   '/home/ute/MN/UTE/robotws/admin_api_default.log']

# COUNTERS
M55359C00000 = 'M55359C00000'
M55359C00001 = 'M55359C00001'
M55308C10007 = 'M55308C10007'
M55328C00003 = 'M55328C00003'

M55338C01000 = 'M55338C01000'
M55311C42008 = 'M55311C42008'
M55338C01001 = 'M55338C01001'
M55319C02007 = 'M55319C02007'

M55115C00015 = 'M55115C00015'
M55311C44008 = 'M55311C44008'

M55139C02501 = 'M55139C02501'
M55139C02502 = 'M55139C02502'
M55338C01002 = 'M55338C01002'

M55332C00001 = 'M55332C00001'
M55332C00002 = 'M55332C00002'
M55332C02001 = 'M55332C02001'

M55308C10005 = 'M55308C10005'
M55308C00001 = 'M55308C00001'

M55308C10001 = 'M55308C10001'
M55308C10003 = 'M55308C10003'

M55311C05006 = 'M55311C05006'
M55311C05007 = 'M55311C05007'

M55326C02001 = 'M55326C02001'
M55326C02009 = 'M55326C02009'
M55326C02002 = 'M55326C02002'
M55323C04002 = 'M55323C04002'
M55310C01002 = 'M55310C01002'
M55320C20002 = 'M55320C20002'
M55125C03502 = 'M55125C03502'
M55138C01002 = 'M55138C01002'
M55138C01001 = 'M55138C01001'
M55326C02003 = 'M55326C02003'

DL_PRB_AVAIL_SAS = 'M55308C10013'
PRB_AVAIL_PDSCH_SLICES = "M55308C10007"
DL_PRB_USED_DATA_NRG = 'M55910C00001'
DL_PRB_UTIL_SLOT_MAX_NRG = 'M55910C00002'

COUNTERS_PRB_DL = [DL_PRB_AVAIL_SAS, DL_PRB_USED_DATA_NRG, DL_PRB_UTIL_SLOT_MAX_NRG, PRB_AVAIL_PDSCH_SLICES]
DL_PRB_USED_COUNTERS_26RG_TDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                  '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG",
                                                  '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-4/NCUPNRG",
                                                  '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-5/NCUPNRG",
                                                  '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-6/NCUPNRG",
                                                  '7': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-7/NCUPNRG",
                                                  '8': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-8/NCUPNRG",
                                                  '9': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-9/NCUPNRG",
                                                  '10': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-10/NCUPNRG",
                                                  '11': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-11/NCUPNRG",
                                                  '12': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-12/NCUPNRG",
                                                  '13': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-13/NCUPNRG",
                                                  '14': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-14/NCUPNRG",
                                                  '15': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-15/NCUPNRG",
                                                  '16': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-16/NCUPNRG",
                                                  '17': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-17/NCUPNRG",
                                                  '18': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-18/NCUPNRG",
                                                  '19': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-19/NCUPNRG",
                                                  '20': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-20/NCUPNRG",
                                                  '21': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-21/NCUPNRG",
                                                  '22': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-22/NCUPNRG",
                                                  '23': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-23/NCUPNRG",
                                                  '24': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-24/NCUPNRG",
                                                  '25': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-25/NCUPNRG",
                                                  '26': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-26/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_26RG_TDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                      '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                      '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG",
                                                      '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-4/NCUPNRG",
                                                      '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-5/NCUPNRG",
                                                      '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-6/NCUPNRG",
                                                      '7': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-7/NCUPNRG",
                                                      '8': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-8/NCUPNRG",
                                                      '9': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-9/NCUPNRG",
                                                      '10': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-10/NCUPNRG",
                                                      '11': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-11/NCUPNRG",
                                                      '12': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-12/NCUPNRG",
                                                      '13': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-13/NCUPNRG",
                                                      '14': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-14/NCUPNRG",
                                                      '15': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-15/NCUPNRG",
                                                      '16': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-16/NCUPNRG",
                                                      '17': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-17/NCUPNRG",
                                                      '18': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-18/NCUPNRG",
                                                      '19': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-19/NCUPNRG",
                                                      '20': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-20/NCUPNRG",
                                                      '21': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-21/NCUPNRG",
                                                      '22': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-22/NCUPNRG",
                                                      '23': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-23/NCUPNRG",
                                                      '24': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-24/NCUPNRG",
                                                      '25': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-25/NCUPNRG",
                                                      '26': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-26/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_26RG_TDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '7': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '8': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '9': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '10': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '11': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '12': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '13': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '14': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '15': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '16': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '17': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '18': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '19': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '20': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '21': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '22': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '23': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '24': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '25': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                   '26': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA"}}

DL_PRB_USED_COUNTERS_3RG_FDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                 '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_3RG_FDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                     '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_USED_COUNTERS_7RG_FDD_GBR = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                     '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG",
                                                     '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-4/NCUPNRG",
                                                     '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-5/NCUPNRG",
                                                     '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-6/NCUPNRG",
                                                     '7': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-7/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_7RG_FDD_GBR = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                         '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                         '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG",
                                                         '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-4/NCUPNRG",
                                                         '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-5/NCUPNRG",
                                                         '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-6/NCUPNRG",
                                                         '7': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-7/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_7RG_FDD_GBR = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                      '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                      '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                      '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                      '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                      '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                      '7': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA"}}

DL_PRB_AVAIL_COUNTERS_3RG_FDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA"}}

DL_PRB_USED_COUNTERS_3RG_FDD_DSS = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                     '3': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_3RG_FDD_DSS = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                         '2': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                         '3': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_3RG_FDD_DSS = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NCELA",
                                                      '2': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NCELA",
                                                      '3': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NCELA"}}

DL_PRB_USED_COUNTERS_2RG_FDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_2RG_FDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_2RG_FDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA"}}

DL_PRB_USED_COUNTERS_3RG_TDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                 '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_MAX_UTIL_COUNTERS_3RG_TDD = {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                     '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                     '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG"}}

DL_PRB_AVAIL_COUNTERS_3RG_TDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA"}}

DL_PRB_USED_COUNTERS_3RG_PRB_DSS_1_CELL = \
    {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG"}}
DL_PRB_USED_COUNTERS_3RG_PRB_DSS_2_CELL = \
    {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-2/NRRESOURCEGROUP-2/NCUPNRG"}}
DL_PRB_USED_COUNTERS_3RG_PRB_DSS_3_CELL = \
    {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG"}}
DL_PRB_MAX_UTIL_COUNTERS_3RG_PRB_DSS_1_CELL = \
    {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG"}}
DL_PRB_MAX_UTIL_COUNTERS_3RG_PRB_DSS_2_CELL = \
    {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-2/NRRESOURCEGROUP-2/NCUPNRG"}}
DL_PRB_MAX_UTIL_COUNTERS_3RG_PRB_DSS_3_CELL = \
    {"M55910C00002": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG"}}
DL_PRB_AVAIL_COUNTERS_3RG_PRB_DSS_1_CELL = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-1/NCELA"}}
DL_PRB_AVAIL_COUNTERS_3RG_PRB_DSS_2_CELL = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-2/NCELA"}}
DL_PRB_AVAIL_COUNTERS_3RG_PRB_DSS_3_CELL = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-2/NRCELL-3/NCELA"}}

TPUTS_26RG = [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
              100, 100, 100, 100, 100]

TPUTS_1RG = [100]
TPUTS_2RG = [100, 100]
TPUTS_3RG = [100, 100, 100]
TPUTS_7RG_GBR = [500, 50, 50, 50, 50, 50, 50]
COUNTERS_DSS = [M55332C02001, M55332C00002, M55332C00001]
COUNTERS_PRB = [M55308C00001, M55308C10005]
COUNTERS_GRB_ENABLED = [M55326C02009, M55326C02002, M55323C04002, M55310C01002, M55320C20002, M55125C03502,
                        M55138C01002, M55138C01001, M55326C02003]

SA_UTILIZATION_COUNTER_LIST = [M55359C00000, M55359C00001, M55308C10007, M55328C00003]
NSA_UTILIZATION_COUNTER_LIST = [M55338C01001, M55338C01000, M55338C01002]

COUNTERS_C_B501_RETX = [M55311C05006, M55311C05007]
MAX_UTI_RATIO_RANGE_C_B501_RETX = {
    SD_13714341: {
        "min": 10,
        "max": 30
    },
    SD_2: {
        "min": 70,
        "max": 100
    }
}
SET_COUNTER_LIST_VARIABLES_C_B501_RETX = True
COUNTER_MAX_UTILIZATION_RATIO_MARGIN_C_B501_RETX = float(4)
COUNTER_TARGET_SHARE_MARGIN_C_B501_RETX = float(4)
RAISE_EXCEPTION_DURING_MAX_UTILIZATION_RATIO_VALIDATION_C_B501_RETX = True

COUNTERS_G_MULTIPLE_BWPS = [M55139C02501, M55139C02502]
SET_COUNTER_LIST_VARIABLES_G_MULTIPLE_BWPS = True
COUNTER_MAX_UTILIZATION_RATIO_MARGIN_G_B1_MULTI_BWP = float(20)
COUNTER_MAX_UTILIZATION_RATIO_MARGIN_G_B1_MULTI_BWP_SMALL = float(2)
COUNTER_TARGET_SHARE_MARGIN_G_B1_MULTI_BWP = float(3)
RAISE_EXCEPTION_DURING_MAX_UTILIZATION_RATIO_VALIDATION_G_B1_MULTI_BWP = True
USED_PRBS_MARGIN_G_B1_MULTIPLE_SMALL_BWP = float(3)

COUNTERS_F_MU_MIMO = [M55308C10001, M55308C10003, M55308C10007, M55359C00000]
MARGIN_COUNTERS_COMPARISON_F_MU_MIMO = float(3)
SET_COUNTER_LIST_VARIABLES_F_MU_MIMO = True
COUNTER_MAX_UTILIZATION_RATIO_MARGIN_F_MU_MIMO = float(4)
COUNTER_TARGET_SHARE_MARGIN_F_MU_MIMO = float(4)
RAISE_EXCEPTION_DURING_MAX_UTILIZATION_RATIO_VALIDATION_F_MU_MIMO = True

COUNTERS_E_DSS_ENALBED = [M55332C00001, M55332C00002, M55332C02001]
EXCEPTED_SPECIFIC_PART_OF_COUNTER_E_DSS_ENABLED = float(70)
MARGIN_COUNTERS_COMPARISON_E_DSS_ENABLED = float(3)

COUNTERS_H_EC2_GBR_LOAD = [M55326C02001, M55138C01002, M55138C01001]
COUNTER_MAX_UTILIZATION_RATIO_MARGIN_H_EC2_GBR_LOAD = float(25)
COUNTER_MAX_UTILIZATION_RATIO_MARGIN_H_EC2_GBR_LOAD_VONR = float(2)
COUNTER_TARGET_SHARE_MARGIN_H_EC2_GBR_LOAD = float(25)
COUNTER_TARGET_SHARE_MARGIN_H_EC2_GBR_LOAD_VONR = float(6)
RAISE_EXCEPTION_DURING_MAX_UTILIZATION_RATIO_VALIDATION_H_EC2_GBR_LOAD = True
IS_GBR_TC = True

# THE END OF COUNTERS
BIP_MCSHARK_PATH = '/home/ute/.local/lib/wireshark/plugins/4.0/epan'
BIP_E_DSS_ENABLED_PREFIX = 'dldata_pdsch_send_req'
BIP_USING_MCSHARK_E_DSS_ENABLED = True
FILTER_PDSCH_PDCCH_SEND_REQ_E_DSS_ENABLED = '-Y "dldata_pdschsendreq && !(3gpp.rnti==65535)"'
SLOTS_USED_E_DSS_ENABLED = ['1', '2', '3', '4', '6', '7', '8']
START_PRB_VALUE_EXPECTED_E_DSS_ENABLED = '0'
NUM_OF_PRB_VALUE_EXPECTED_E_DSS_ENABLED = '106'

BIP_F_MU_MIMO_PREFIX = 'dldata_pdsch_pdcch_send_req'
BIP_USING_MCSHARK_F_MU_MIMO = True
FILTER_PDSCH_PDCCH_SEND_REQ_F = '-Y "(dldata_pdschsendreql1sw || dldata_pdcchsendreql1sw) && !(3gpp.rnti==65535)"'

DLDATA_PDSCHSENDREQ_TEXT = 'dldata_pdschsendreq'
DLDATA_PDCCHSENDREQ_TEXT = 'dldata_pdcchsendreq'
DCI_INFO_ITEM_TEXT = 'dciInfo_item_'
SFN_UINT16_REGEXP = r'sfn \(Uint16\): (?P<VALUE>\d+)'
SLOT_UINT8_REGEXP = r'slot \(Uint8\): (?P<VALUE>\d+)'
BEAM_ID_UINT8_REGEXP = r'beamId \(Uint8\): (?P<VALUE>\d+)'
RNTI_UINT16_REGEXP = r'rnti \(Uint16\): (?P<VALUE>\d+)'
PATTERN_ID_ITEM_0_UINT16_REGEXP = r'patternId_item_0 \(Uint16\): (?P<VALUE>\d+)'
START_PRB_UINT16_REGEXP = r'startPrb \(Uint16\): (?P<VALUE>\d+)'
NUM_OF_PRB_UINT16_REGEXP = r'numOfPrb \(Uint16\): (?P<VALUE>\d+)'

DOWNLINK_CONFIG_COMMON_EGATE = 'downlinkConfigCommon'
UPLINK_CONFIG_COMMON_EGATE = 'uplinkConfigCommon'

DOWNLINK_BWP_ADD_MOD_LIST_EGATE = 'downlinkBWP-ToAddModList'
UPLINK_BWP_ADD_MOD_LIST_EGATE = 'uplinkBWP-ToAddModList'

_BWP_TYPES = {
    'TDD': {
        'large_bwp': {
            'chbw': 100,
            'max_rb': 273
        },
        'small_bwp': {
            'chbw': 60,
            'max_rb': 162
        },
    },
    'FDD': {
        'large_bwp': {
            'chbw': 20,
            'max_rb': 106
        },
        'small_bwp': {
            'chbw': 15,
            'max_rb': 79
        }
    }
}


def _calc_bwps_ratio(cell_tech):
    small_ch_bw = float(_BWP_TYPES[cell_tech]['small_bwp']['chbw'])
    large_ch_bw = float(_BWP_TYPES[cell_tech]['large_bwp']['chbw'])
    ratio = small_ch_bw/large_ch_bw
    return ratio


MULTIPLE_BWPS_RATIO = {
    'TDD': {
        'bwps_ratio': _calc_bwps_ratio('TDD')
    },
    'FDD': {
        'bwps_ratio': _calc_bwps_ratio('FDD')
    }
}


def _calc_location_and_bandwith(l_rbs):
    n_size_bwp = 275    # const
    rb_start = 0        # const
    if (l_rbs - 1) <= math.floor(float(n_size_bwp) / 2.0):
        riv = n_size_bwp * (l_rbs - 1) + rb_start
    else:
        riv = n_size_bwp * (n_size_bwp - l_rbs + 1) + (n_size_bwp - 1 - rb_start)
    return riv


VALIDATION_EGATE_CONSOLE_LOG_G_MULTIPLE_BWPS = {
    'TDD': {
        'locationAndBandwidth_SmallBWP': _calc_location_and_bandwith(l_rbs=_BWP_TYPES['TDD']['small_bwp']['max_rb']),
        'locationAndBandwidth_LargeBWP': _calc_location_and_bandwith(l_rbs=_BWP_TYPES['TDD']['large_bwp']['max_rb']),
        'carrierBandwith_SmallBWP': _BWP_TYPES['TDD']['small_bwp']['max_rb'],
        'carrierBandwith_LargeBWP': _BWP_TYPES['TDD']['large_bwp']['max_rb']
    },
    'FDD': {
        'locationAndBandwidth_SmallBWP': _calc_location_and_bandwith(l_rbs=_BWP_TYPES['FDD']['small_bwp']['max_rb']),
        'locationAndBandwidth_LargeBWP': _calc_location_and_bandwith(l_rbs=_BWP_TYPES['FDD']['large_bwp']['max_rb']),
        'carrierBandwith_SmallBWP': _BWP_TYPES['FDD']['small_bwp']['max_rb'],
        'carrierBandwith_LargeBWP': _BWP_TYPES['FDD']['large_bwp']['max_rb']
    }
}

VALIDATION_EGATE_CONSOLE_LOG_REGEXPS = {
    "carrierBandwidth": r'carrierBandwidth (?P<VALUE>\d+)',
    'locationAndBandwidth': r'locationAndBandwidth (?P<VALUE>\d+)'
}


# QC Configuration

QC_TESTCASES_TITLES = {
    # C-B101
    'EC1': "[1]CB009084_C_007_more_then_max_possible_slices_EC",
    # C-B501
    'reTX_02': "[1]TC_02_2_UEs_2_slices_SA_QCI_6_quota_10_30_and_70_100_FDD_BLER_MCS",
    'reTX_01': "[1]TC_01_2_UEs_2_slices_SA_QCI_6_quota_10_30_and_70_100_FDD",
    # E-B101
    'EB101_DSS_PRB': "[1]CB009084_E_003_B101_slice_aware_scheduler_with_PRB_Pooling_and_DSS_enabled",
    'EB101_DSS': "[1]CB009084_E_002_B101_slice_aware_scheduler_with_DSS_enabled",
    'EB101_PRB': "[1]CB009084_E_001_B101_slice_aware_scheduler_with_PRB_Pooling_enabled",
    # F-B1
    'FB1': "[1]CB009084_F_001_B1_slice_aware_scheduler_with_basic_mu_mimo",
    # Needed cell tech...
    'TDD': {
        # C-B101
        'B101': "[1]CB009084_C_002_B101_slice_aware_scheduler_verification_NSA_SA_26_slices_TDD",
        # C-B102
        'B102': "[1]CB009084_C_004_B102_allocated_PRBs_for_NSA_counters_TDD",
        # C-B301
        'B301': "[1]CB009084_C_006_B301_slice_aware_scheduler_changing_configuration_online_with_NSA_SA_26_slices_TDD",

        # G-EC2
        'G_EC2': "[1]CB009084_G_003_EC2_slice_aware_scheduler_with_smallest_BWP_TDD",
        # G-B1
        'G_B1': "[1]CB009084_G_001_B1_slice_aware-scheduler_with_multiple_BWPs_TDD",

        # H-EC3
        'H_EC3': "[1]CB009084_H_005_EC3_slice_aware_scheduler_wrong_quotas_configuration_TDD",
        # H_EC2
        'H_EC2_GBR_LOAD': None
    },
    'FDD': {
        # C-B101
        'B101': "[1]CB009084_C_001_B101_slice_aware_scheduler_verification_NSA_SA_26_slices_FDD",
        # C-B102
        'B102': "[1]CB009084_C_003_B102_allocated_PRBs_for_NSA_counters_FDD",
        # C-B301
        'B301': "[1]CB009084_C_005_B301_slice_aware_scheduler_changing_configuration_online_with_NSA_SA_26_slices_FDD",

        # G-EC2
        'G_EC2': "[1]CB009084_G_004_EC2_slice_aware_scheduler_with_smallest_BWP_FDD",
        # G-B1
        'G_B1': "[1]CB009084_G_002_B1_slice_aware-scheduler_with_multiple_BWPs_FDD",

        # H-EC3
        'H_EC3': "[1]CB009084_H_006_EC3_slice_aware_scheduler_wrong_quotas_configuration_FDD",
        # H_EC2
        'H_EC2_GBR_LOAD': "CB009084-H-EC2_slice_aware_scheduler_with_excessive_gbr_load_FDD"
    }
}

_dirname_9084 = 'CB009084_Slice_Aware_Scheduler'
_path_qc_9084 = 'Root\\Test_Sets\\Trunk\\RAN_L2_SW_KRK_2\\{}'.format(_dirname_9084)
_path_qc_22R4_9084 = 'Root\\Test_Sets\\22R4\\Regression\\RAN_L2_SW_KRK_2\\{}'.format(_dirname_9084)
_path_qc_23R1_9084 = 'Root\\Test_Sets\\23R1\\Regression\\RAN_L2_SW_KRK_2\\{}'.format(_dirname_9084)
_projectname_qc_9084_C = 'CB009084-C'
_projectname_qc_9084_E = 'CB009084-E'
_projectname_qc_9084_F = 'CB009084-F'
_projectname_qc_9084_G = 'CB009084-G'
_projectname_qc_9084_H = 'CB009084-H'

QC_DIR_NAMES = {
    'SBTS00': {
        "EC1": {'path': _path_qc_9084, 'project': _projectname_qc_9084_C},
        "reTX_02": {'path': _path_qc_9084, 'project': _projectname_qc_9084_C},
        "reTX_01": {'path': _path_qc_9084, 'project': _projectname_qc_9084_C},

        "EB101_DSS_PRB": {'path': _path_qc_9084, 'project': _projectname_qc_9084_E},
        "EB101_DSS": {'path': _path_qc_9084, 'project': _projectname_qc_9084_E},
        "EB101_PRB": {'path': _path_qc_9084, 'project': _projectname_qc_9084_E},

        "FB1": {'path': _path_qc_9084, 'project': _projectname_qc_9084_F},

        "B101": {'path': _path_qc_9084, 'project': _projectname_qc_9084_C},
        "B102": {'path': _path_qc_9084, 'project': _projectname_qc_9084_C},
        "B301": {'path': _path_qc_9084, 'project': _projectname_qc_9084_C},

        "G_EC2": {'path': _path_qc_9084, 'project': _projectname_qc_9084_G},
        "G_B1": {'path': _path_qc_9084, 'project': _projectname_qc_9084_G},

        "H_EC3": {'path': _path_qc_9084, 'project': _projectname_qc_9084_H},
        "H_EC2_GBR_LOAD": {'path': _path_qc_9084, 'project': _projectname_qc_9084_H}
    },
    'SBTS23R1': {
        "EC1": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_C},
        "reTX_02": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_C},
        "reTX_01": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_C},

        "EB101_DSS_PRB": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_E},
        "EB101_DSS": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_E},
        "EB101_PRB": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_E},

        "FB1": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_F},

        "B101": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_C},
        "B102": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_C},
        "B301": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_C},

        "G_EC2": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_G},
        "G_B1": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_G},

        "H_EC3": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_H},
        "H_EC2_GBR_LOAD": {'path': _path_qc_23R1_9084, 'project': _projectname_qc_9084_H}
    },
    'SBTS22R4': {
        "EC1": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_C},
        "reTX_02": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_C},
        "reTX_01": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_C},

        "EB101_DSS_PRB": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_E},
        "EB101_DSS": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_E},
        "EB101_PRB": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_E},

        "FB1": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_F},

        "B101": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_C},
        "B102": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_C},
        "B301": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_C},

        "G_EC2": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_G},
        "G_B1": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_G},

        "H_EC3": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_H},
        "H_EC2_GBR_LOAD": {'path': _path_qc_22R4_9084, 'project': _projectname_qc_9084_H}
    }
}

_desc = 'Krakow VRF Engineering team testcases for CB009084 feature'
_qc_doc = \
    'maintainer: Mateusz Rzeczyca, Kamil Bucki, Adrianna Pienkowska\ndescription:\n{}'.format(_desc)

REPORT_QC = {
    'qc_project': "RAN_ET",
    'qc_domain': "MN_RAN",
    'ca': 'RAN_L2_SW_KRK_2',
    'username': 'owner',
    'links': {},
    'add_info': ["UTE", "TAF"],
    'suite_path': None,
    'qc_testlab_path': None,
    'qc_test_set_name': None,
    'features_covered': None,
    'doc': _qc_doc
}
