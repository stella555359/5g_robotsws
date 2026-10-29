'''
:copyright: Nokia Networks
:author: Agata Sidlo
:contact: agata.sidlo@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
'''
import os
from itertools import repeat

CURDIR = '{}'.format(os.path.dirname(os.path.realpath(__file__)))
CONFIGS = '{}/configs'.format(CURDIR)

GNB_IP = '192.168.255.129'
AP_IP = '192.168.200.129'
NOKIA_USERNAME = 'toor4nsn'
NOKIA_PASS = 'oZPS0POrRieRtu'
WEBEM_USERNAME = 'Nemuadmin'
WEBEM_PASS = 'nemuuser'

BIP_NAME_PREFIX = 'BIP_'
TTITRACE_NAME_PREFIX = 'TTI_'
SYSLOG_NAME_PREFIX = 'SYSLOG_'
SNAPSHOT_NAME_PREFIX = 'SNAPSHOT_'
SYSCOME_NAME_PREFIX = 'SYSCOM_'

DELTA_ACT_1_SPIDGRP_0_PMQAP = os.path.join(CURDIR, 'configs/Delta_activate_feature_1_SPIDGRP_0_PMQAP.json')
DELTA_ACT_5_SPIDGRP_3_PMQAP = os.path.join(CURDIR, 'configs/Delta_activate_feature_5_SPIDGRP_3_PMQAP_3_PLMN.json')
DELTA_ACT_5_SPIDGRP_4_PMQAP = os.path.join(CURDIR, 'configs/Delta_activate_feature_5_SPIDGRP_4_PMQAP_4_PLMN.json')
DELTA_ACT_32_SPIDGRP_8_PMQAP = os.path.join(CURDIR, 'configs/Delta_activate_feature_32_SPIDGRP_8_PMQAP_6_PLMN.json')
DELTA_ACT_NRPMQAP_PER_SPID_FDMSCHED_FALSE = \
    os.path.join(CURDIR, 'configs/Delta_activate_feature_4_SPIDGRP_4_PMQAP_FDMSched_false.json')
DELTA_ACT_NRPMQAP_PER_SPID = os.path.join(CURDIR, 'configs/Delta_activate_feature_4_SPIDGRP_4_PMQAP.json')
DELTA_ACT_NRPMQAP_SPID_MODIFY_RECOM = os.path.join(CURDIR, 'configs/Delta_A_B108_recommissioning.json')
DELTA_ACT_NRPMQAP_SPID_DEFAULT = os.path.join(CURDIR, 'configs/Delta_activate_feature_2_SPIDGRP_3_PMQAP.json')
DELTA_ACT_NRPMQAP_SPID_DEFAULT_RECOM_1 = os.path.join(CURDIR, 'configs/Delta_A_B108_003_recommissioning_1.json')
DELTA_ACT_NRPMQAP_SPID_DEFAULT_RECOM_2 = os.path.join(CURDIR, 'configs/Delta_A_B108_003_recommissioning_2.json')
DELTA_ACT_NRPMQAP_SPID_DEFAULT_RECOM_3 = os.path.join(CURDIR, 'configs/Delta_A_B108_003_recommissioning_3.json')
DELTA_DEACT_SPID_FOR_NSA = os.path.join(CURDIR, 'configs/Delta_deactivate_feature_A_B401.json')
DELTA_ACT_SPID_FOR_NSA = os.path.join(CURDIR, 'configs/Delta_activate_feature_again_A_B401.json')
DELTA_A_B301_001_1_WITHOUT_SAS_AND_8746 = os.path.join(CURDIR, 'configs/Delta_A_B301_001_1_without_SAS_and_8746.json')
DELTA_A_B301_002_1_WITH_SAS_AND_8746 = os.path.join(CURDIR, 'configs/Delta_A_B301_002_1_with_SAS_and_8746.json')
DELTA_ACT_SAS_SPID_NSA_SA_RECONF = os.path.join(CURDIR, 'configs/Delta_recommissioning_activate_SAS_and_8746.json')
DELTA_DEACT_SAS_SPID_NSA_SA_RECONF = os.path.join(CURDIR, 'configs/Delta_recommissioning_deactivate_SAS_and_8746.json')
DELTA_A_B105_003_FDD = os.path.join(CURDIR, 'configs/Delta_A_B105_003_FDD.json')
DELTA_A_B401_WITHOUT_8746 = os.path.join(CURDIR, 'configs/Delta_A_B401_without_8746.json')
DELTA_A_B301_003_TDD = os.path.join(CURDIR, 'configs/Delta_A_B301_003.json')
DELTA_A_B301_004_FDD = os.path.join(CURDIR, 'configs/Delta_A_B301_004_FDD.json')
DELTA_A_B301_CHANGE_QUOTAS = os.path.join(CURDIR, 'configs/Delta_recommissioning_change_min_max_quotas.json')
DELTA_B_PRB_DSS = os.path.join(CURDIR, 'configs/Delta_B_PRB_DSS.json')

WTS_CFG_BASIC = '/opt/iphy/latest/basic_setup.cfg'
WTS_4_UE_3_PLMN = os.path.join(CURDIR, 'configs/WTS_4_UE_3_PLMN.cfg')
WTS_6_UE_3_PLMN_FDD = os.path.join(CURDIR, 'configs/WTS_6_UE_3_PLMN_FDD.cfg')
WTS_9_UE_3_PLMN_FDD = os.path.join(CURDIR, 'configs/WTS_9_UE_3_PLMN_FDD.cfg')
WTS_10_UE_1_PLMN_FDD = os.path.join(CURDIR, 'configs/WTS_10_UE_1_PLMN_FDD.cfg')
WTS_7_UE_3_PLMN = os.path.join(CURDIR, 'configs/WTS_7_UE_3_PLMN.cfg')
WTS_9_UE_3_PLMN = os.path.join(CURDIR, 'configs/WTS_9_UE_3_PLMN.cfg')
WTS_8_UE_4_PLMN = os.path.join(CURDIR, 'configs/WTS_8_UE_4_PLMN.cfg')
WTS_3_UE_1_PLMN_FDD = os.path.join(CURDIR, 'configs/WTS_3_UE_1_PLMN_FDD.cfg')
WTS_32_UE_6_PLMN = os.path.join(CURDIR, 'configs/WTS_32_UE_6_PLMN.cfg')
WTS_32_UE_6_PLMN_FDD = os.path.join(CURDIR, 'configs/WTS_32_UE_6_PLMN_FDD.cfg')
WTS_3UEs_ACT_DEACT_FDD = os.path.join(CURDIR, '')
WTS_2UEs_ACT_FDD = os.path.join(CURDIR, '')
WTS_2UEs_ACT_TDD = os.path.join(CURDIR, '')
WTS_8_NSA_UEs_6_SA_UEs_ACT_TDD = os.path.join(CURDIR, 'configs/WTS_8_NSA_UE_6_SA_UE_3_PLMN.cfg')
WTS_8_NSA_UEs_6_SA_UEs_ACT_FDD = os.path.join(CURDIR, 'configs/WTS_8_NSA_UE_6_SA_UE_3_PLMN_FDD.cfg')
WTS_CFG_PRB_DSS = os.path.join(CURDIR, 'configs/WTS_PRB_DSS.cfg')

WORKING_DIR = os.getcwd()
SCF_PATH_PRB_DSS = os.path.join(WORKING_DIR, 'testsuite/Wroclaw/RRM/VRF_WRO1_T04/SAS_ET',
                                'CB009084/resources/configs/custom/base_scf_PRB_DSS.xml')
IPHY_PATH_PRB_DSS = os.path.join(WORKING_DIR, 'testsuite/Wroclaw/RRM/VRF_WRO1_T04/SAS_ET',
                                 'CB009084/resources/configs/custom/iphy_PRB_DSS.xml')

IPHY_DIR_PATH_DEFAULT = '/opt/iphy/latest'
EGATE_CONSOLE_LOG = os.path.join(IPHY_DIR_PATH_DEFAULT, 'egate_console.log')
EDAEMON_PORT = '22222'
EGATE_PORT = '20000'
SIB_RECEPTION_DICT_SA_SANSA = {2: [1]}
SIB_RECEPTION_LIST = [SIB_RECEPTION_DICT_SA_SANSA, {2: [2]}, {2: [3]}]
DO_NOT_ALLOW_FIRST_REBOOT = False
SET_VARIABLE_DURING_SCF_COLLECTION = True

LUASHARK_ROOT_PATH = '/opt/luashark'
ENABLE_MCSHARK_USAGE = True

WIRESHARK_PLUGINS_PATH_1 = '/usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/'
WIRESHARK_PLUGINS_PATH_2 = '/home/ute/.local/lib/wireshark/plugins/3.6/epan/'

BH_ETH3_IP_ADDR = \
    ['10.0.1.1', '10.0.1.121', '10.0.1.131', '10.0.1.133', '10.0.1.134', '10.0.1.135', '10.0.1.136', '10.0.1.137']
BH_ETH4_IP_ADDR = ['10.0.2.1', '10.0.2.121']
ADMIN_LOG_PATHS = ['/home/ute/robotws/admin_api_default.log', '/home/ute/MN/UTE/robotws/admin_api_default.log']

NSA_PLMNS = ['311:489', '312:490', '313:491', '314:492', '315:493', '316:494']
MAX_TDD_UTE = 20
MAX_FDD_UTE = 20
MAX_NSA_UE = 5
UE_IP_DL = {
    'TDD': ['1.2.4.{}'.format(i + 2) for i in range(MAX_TDD_UTE)],
    'FDD': ['10.12.2.{}'.format(i + 2) for i in range(MAX_FDD_UTE)],
    'NSA': ['4.7.254.208'] + ['4.7.254.21{}'.format(i + 2) for i in range(MAX_NSA_UE)]
}
UE_ID_18 = ['18']
UE_IDS_18_19 = ['18', '19']
UE_IDS_16_17 = ['16', '17']
UE_IDS_14_15_16 = ['14', '15', '16']
UE_IDS_14_15_16_17 = ['14', '15', '16', '17']
UE_IDS_17_18 = ['17', '18']
UE_IDS_19_20 = ['19', '20']

ALIAS_TSHARK_SHERPA = 'ALIAS_TSHARK_SHERPA'
SHERPA_L2PS = 'L2Ps'
SHERPA_L2HIPDCP = 'L2HiPdcp'
SHERPA_TYPES = [SHERPA_L2PS, SHERPA_L2HIPDCP]
SHERPA_SOURCE_IP = '10.0.1.2'
SHERPA_DESTINATION_IP = '10.0.1.1'
SHERPA_PORT = 5678
SHERPA_DSCP = 32
SHERPA_ETH_INTERFACE = 'eth4'
SHERPA_PREFIX = 'sherpa_8746_'

COLLECTOR_NAME = 'l2stream3'
TTITRACE_NAME_PREFIX = 'ttitrace_8746_'

SYSLOG_NAME_PREFIX = 'syslog_8746_'
SYSLOG_ALIAS = 'ALIAS_SYSLOG_GNB'
SNAPSHOT_NAME_PREFIX = 'snapshot_8746_'

BIP_REMOTE_DIR = '/user/toor4nsn/'
HW_TYPE_ASIB_ABIO = 'ASIB_ABIO'
HW_TYPE_ASIB_ABIL = 'ASIB_ABIL'
HW_TYPE_ASIL_ABIO = 'ASIL_ABIO'

BIP_ASIB_ABIO_OUTPUT_FILE = '/tmp/bip.pcap'
BIP_ASIB_ABIL_OUTPUT_FILE = '/tmp/tcpdump_L2L1_bip_filtering_on.pcap0'
BIP_ASIL_ABIO_OUTPUT_FILE = '/tmp/tcpdump_L2L1_bip_filtering_on.pcap0'

BIP_TERMINATE_ASIB_ABIO_NAME = 'bip.pcap'
BIP_TERMINATE_ASIB_ABIL_NAME = 'tcpdump_L2L1_bip_filtering_on.pcap0'
BIP_TERMINATE_ASIL_ABIO_NAME = 'tcpdump_L2L1_bip_filtering_on.pcap0'

# BIP FILTERS
BIP_MSG_CELLSETUPREQ = 'itf_l2_ps_cell_cellsetupreq'
BIP_FILTER_CELLSETUPREQ = '-Y "{}"'.format(BIP_MSG_CELLSETUPREQ)
BIP_MSG_CELLRECONFREQ = 'itf_l2_ps_cell_cellreconfigurationreq'
BIP_FILTER_CELLRECONFREQ = '-Y "{}"'.format(BIP_MSG_CELLRECONFREQ)
BIP_MSG_USERSETUPREQ = 'itf_l2_ps_user_usersetupreq'
BIP_FILTER_USERSETUPREQ = '-Y "{}"'.format(BIP_MSG_USERSETUPREQ)
NG_LINK_MSG_UE_CONTEXT_SETUP = 'x2ap.SgNBAdditionRequest_element'
NG_LINK_FILTER_UE_CONTEXT_SETUP = '-Y "{}"'.format(NG_LINK_MSG_UE_CONTEXT_SETUP)

VALID_BIP_CELLGRP_ID_REGEXP = r'nrCellGrpId \(Uint16\): (?P<CELLGRP_ID>\d+)'

# cellSetupReq
VALID_BIP_CELL_ID_REGEXP = r'lcrId \(Uint16\): (?P<MINQUOTA>\d+)'
VALID_BIP_RESOURCE_GROUP_LIST_SPLIT_TEXT = 'resourceGroupList_item_'
VALID_BIP_MINQUOTA_REGEXP = r'minQuota \(Uint8\): (?P<MINQUOTA>\d+)'
VALID_BIP_MAXQUOTA_REGEXP = r'maxQuota \(Uint8\): (?P<MAXQUOTA>\d+)'
VALID_BIP_NRG_ID_REGEXP = r'[R|r]esourceGroupId \(Uint8\): (?P<NRG_ID>\d+)'
VALID_BIP_PLMN_CONFIG_ID_REGEXP = r'values_item_\d+\s+\(itf_PlmnConfig\)'
VALID_BIP_MCC_REGEXP = r'plmnIdBytes_item_0 \(Uint8\): (?P<FIRST_ENCODED_NUMBER>\d+)'
VALID_BIP_MNC_REGEXP = r'plmnIdBytes_item_1 \(Uint8\): (?P<SECOND_ENCODED_NUMBER>\d+)'
VALID_BIP_MNC_LENGTH_REGEXP = r'plmnIdBytes_item_2 \(Uint8\): (?P<THIRD_ENCODED_NUMBER>\d+)'
VALID_BIP_FEATURE_ACTIVATED = 'sliceAwareSchedulerCellActivation (Boolean): True'
VALID_BIP_FEATURE_8746_ACTIVATED = 'actNsaResourceGroupSlicing (Boolean): '
VALID_BIP_NSA_RESOURCE_GRP_IN_PLMN_REGEXP = r'nsaResourceGroup \(StaticVariableSizedArray\)\n\s+Length \(Uint32\): 0'
VALID_BIP_DEFAULT_NRG_ID_REGEXP = r'nsaDefaultResourceGroupId_item_0 \(Uint8\): (?P<DEFAULT_NRG_ID>\d+)'

# userSetupReq
VALID_BIP_EMPTY_RESOURCE_GROUP_ID_REGEXP = r'dlResourceGroupId \(StaticOptional\)\n\s+Length \(Uint32\): 0'
VALID_BIP_RESOURCE_GROUP_ID_REGEXP = r'[R|r]esourceGroupId_item_0 \(Uint8\): (?P<NRGID>\d+)'

# UE Context Setup
VALID_UE_CONTEXT_SETUP_REGEXP = r'id: id-SubscriberProfileIDforRFP \(275\)\n\s+criticality: ignore \(1\)\n\s+' \
                                r'value\n\s+SubscriberProfileIDforRFP: (?P<SPID>\d+)'

VALID_SYSLOG_FEATURE_ACTIVATED = '\'sliceAwareSchedulerCellActivation\':true'
VALID_SYSLOG_PLMN_CONFIG_LIST = 'plmnConfigList'

VALID_SYSLOG_QUOTAS_CONFIG_REGEXP = r'CellSetupReq: plmn: \d has slices: \d:\d+ ' + \
                                    r'{minQuota: (?P<MINQUOTA_1>\d+), maxQuota: (?P<MAXQUOTA_1>\d+)},\s*\d+:\d+ ' + \
                                    r'{minQuota: (?P<MINQUOTA_2>\d+), maxQuota: (?P<MAXQUOTA_2>\d+)}'
VALID_SYSLOG_CONFIG_REGEXP_SECOND_SLICE = r'CellSetupReq: plmn: [1-9] has slices: \d:\d+ ' + \
                                          r'{minQuota: (?P<MINQUOTA>\d+), maxQuota: (?P<MAXQUOTA>\d+)}'

QUOTAS_EXPECTED_A003 = [
    {
        'min': '10',
        'max': '50'
    }
]
PLMN_EXPECTED_A003 = [
    {
        'mcc': '311',
        'mnc': '489',
        'mnc_length': '3'
    }
]
SA_3UE_IDS = ['1', '2', '3']
SA_3UE_IDS_2 = ['4', '5', '6']
SA_4UE_IDS = ['1', '2', '3', '5']
SA_SLICES_1_2_3 = ['1', '2', '3']
SA_SLICES_1_3_1 = ['1', '3', '1']
SA_SLICES_1_2_3_4 = ['1', '2', '3', '4']
GATEWAY_PDU_IDS_4_5_6 = ['4', '5', '6']

UE_SPID_VALUES_A_B601_last = [None, None, None, None]
UE_SPID_VALUES_A_B105_001 = [2, 29, 1, 256, 7, 33]
UE_SPID_VALUES_A_B105_002 = [7, 50, 10, 50, 50, 54]
UE_SPID_VALUES_A_B105_003 = [55, 256, 104]
UE_SPID_VALUES_PRB_DSS = [7, 50, 60]
UE_SPID_VALUES_32_UES = [10, 19, 29, 31, 45, 55, 65, 255, 85, 5, 15, 25, 35, 55, 255, 145, 215, 100, 101, 15, 20, 100,
                         None, 32, 45, None, 1, 12, 14, 15, 51, 42]
UE_SPID_VALUES_A_B107_001 = [94, 105, None, 6, None, 7, 256]
UE_SPID_VALUES_A_B107_002 = [91, None, 1, 28, 55, 201]
UE_SPID_VALUES_A_B108_001 = [None, 9, 28, 250, None, 236, 227]
UE_SPID_VALUES_A_B108_001_AFTER_RECOM = [None, 242]
UE_SPID_VALUES_A_B108_002 = [None, 9, 28, 250, None, 236, 120]
UE_SPID_VALUES_A_B108_002_AFTER_RECOM = [120, 236]
UE_SPID_VALUES_A_B108_003_10UES = [None, 5, 131, None, 4, 140, 135, None, None, 127]
UE_SPID_VALUES_A_B108_003_3UES_1 = [None, 5, 131]
UE_SPID_VALUES_A_B108_003_3UES_2 = [None, 5, 131, None, 4, 140]
UE_SPID_VALUES_A_B108_003_8UES = [None, 5, 131, None, 4, 140, 135, None]
UE_SPID_VALUES_A_B108_003_3UES = [None, 5, 131]
UE_SPID_VALUES_A_B108_003_6UES = [None, 5, 131, None, 4, 140]
UE_SPID_VALUES_A_B108_003_10UES = [None, 5, 131, None, 4, 140, 135, None, None, 127]
UE_SPID_VALUES_A_B401 = [1, 7, 3, 8, 127]
UE_SPID_VALUES_A_B401_2 = [57, 100]
UE_SPID_VALUES_A_B301_001_1 = [9, 5, None]
UE_SPID_VALUES_A_B301_001_2 = [5, 100, 90, 90]
UE_SPID_VALUES_A_B301_001_3 = [200]
UE_SPID_VALUES_A_B301_003 = [1, 63, 63]
UE_SPID_VALUES_A_B301_004 = [1, 63, 12, 131]

FOUR_UES_PLMNS = ['311:489', '311:489', '312:490', '313:491']
SIX_UES_PLMNS_A_B105_001 = ['311:489', '311:489', '312:490', '313:491', '313:491', '313:491']
SIX_UES_PLMNS_A_B105_002 = ['311:489', '312:490', '312:490', '313:491', '313:491', '314:492']
THREE_UES_PLMNS_A_B105_003 = ['311:489', '311:489', '311:489']
THREE_UES_PLMNS_PRB_DSS = ['311:489', '311:489', '311:489']
SEVEN_UES_PLMNS_A_B107_001 = ['311:489', '311:489', '311:489', '312:490', '313:491', '313:491', '313:491']
SIX_UES_PLMNS_A_B107_002 = ['311:489', '311:489', '312:490', '313:491', '313:491', '313:491']
SEVEN_UES_PLMNS_A_B108_001 = ['311:489', '313:491', '313:491', '313:491', '313:491', '313:491', '313:491']
TWO_UES_PLMNS_A_B108_001_AFTER_RECOM = ['311:489', '313:491']
SEVEN_UES_PLMNS_A_B108_002 = ['311:489', '313:491', '313:491', '313:491', '313:491', '313:491', '313:491']
TWO_UES_PLMNS_A_B108_002_AFTER_RECOM = ['313:491', '313:491']
SIX_UES_PLMNS_A_B108_002 = []
THREE_UES_PLMNS_A_B108_003_AFTER_RECOM = ['311:489', '311:489', '311:489']
TWO_UES_PLMNS_A_B108_003_AFTER_RECOM = ['311:489', '311:489']
SIX_UES_PLMNS_A_B108_003_AFTER_RECOM = ['311:489' for _ in range(6)]
EIGHT_UES_PLMNS_A_B108_003_AFTER_RECOM = ['311:489' for _ in range(8)]
TEN_UES_PLMNS_A_B108_003_AFTER_RECOM = ['311:489' for _ in range(10)]
FIVE_UES_PLMNS_A_B401 = ['311:489', '311:489', '312:490', '313:491', '313:491']
TWO_UES_PLMNS_A_B401 = ['313:491', '313:491']
THREE_UES_PLMNS_A_B301_001_1 = ['311:489', '312:490', '312:490']
FOUR_UES_PLMNS_A_B301_001_2 = ['311:489', '312:490', '312:490', '313:491']
ONE_UE_PLMN_A_B301_001_3 = ['312:490']
THREE_UES_PLMNS = ['311:489', '312:490', '313:491']
FOUR_UES_PLMNS_A_B301 = ['311:489', '312:490', '313:491', '313:491']

THIRTY_TWO_UES_PLMNS_A_B105 = []
THIRTY_TWO_UES_PLMNS_A_B105.extend(repeat('311:489', 7))
THIRTY_TWO_UES_PLMNS_A_B105.extend(repeat('312:490', 4))
THIRTY_TWO_UES_PLMNS_A_B105.extend(repeat('313:491', 8))
THIRTY_TWO_UES_PLMNS_A_B105.extend(repeat('314:492', 4))
THIRTY_TWO_UES_PLMNS_A_B105.extend(repeat('315:493', 4))
THIRTY_TWO_UES_PLMNS_A_B105.extend(repeat('316:494', 5))

EXPECTED_NRG_IDS_A_B105_002 = [1, 3, 2, 4, 4, None]
EXPECTED_NRG_IDS_A_B105_003 = [2, 1, 3]
EXPECTED_NRG_IDS_A_B105_32_UES = list(range(1, 33))
EXPECTED_NRG_IDS_A_B105_32_UES[7] = None
EXPECTED_NRG_IDS_A_B105_32_UES[22] = None
EXPECTED_NRG_IDS_A_B105_32_UES[25] = None
EXPECTED_NRG_IDS_A_B107_001_UES = [2, None, None, None, None, 4, 4]
EXPECTED_NRG_IDS_A_B107_002_UES = [2, None, 3, 4, 4, 4]

TWO_UES_ID = [11, 12]
THREE_UES_ID = [11, 12, 13]
FOUR_UES_ID = [11, 12, 13, 14]
SIX_UES_ID = [11, 12, 13, 14, 15, 16]
SEVEN_UES_ID = [11, 12, 13, 14, 15, 16, 17]
NINE_UES_ID = [11, 12, 13, 14, 15, 16, 17, 18, 19]
THIRTY_TWO_UES_ID = list(range(11, 43))
CELL_ID_FOR_UES = {11: 1, 12: 1, 13: 1, 14: 1, 15: 1, 16: 1}
TEN_UE_IDS = [11, 12, 13, 14, 15, 16, 17, 18, 19, 20]

DL_PRB_COUNTERS = ['M55910C00001', 'M55363C00003', 'M55910C00002', 'M55308C10013', 'M55363C00001', 'M55359C00000',
                   'M55359C00001']
PRB_SPID_COUNTERS = ['M55363C00001', 'M55363C00003']
COUNTERS_DSS = ['M55332C02001', 'M55332C00002', 'M55332C00001']
COUNTERS_DSS_PRB = ['M55308C10005', 'M55308C10013']
DL_PRB_USED_COUNTERS_7RG_FDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-2/NCUPNRG",
                                                 '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-3/NCUPNRG",
                                                 '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-4/NCUPNRG",
                                                 '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-5/NCUPNRG",
                                                 '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-6/NCUPNRG",
                                                 '7': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NRRESOURCEGROUP-7/NCUPNRG"}}
DL_PRB_AVAIL_COUNTERS_7RG_FDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA",
                                                  '7': "BTS/MRBTS-1/NRBTS-1/NRCELL-3/NCELA"}}
DL_PRB_USED_COUNTERS_7RG_TDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                 '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG",
                                                 '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-4/NCUPNRG",
                                                 '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-5/NCUPNRG",
                                                 '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-6/NCUPNRG",
                                                 '7': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-7/NCUPNRG"}}
DL_PRB_AVAIL_COUNTERS_7RG_TDD = {"M55308C10013": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '6': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA",
                                                  '7': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA"}}
DL_PRB_USED_COUNTERS_5RG_TDD = {"M55910C00001": {'1': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG",
                                                 '2': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG",
                                                 '3': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3/NCUPNRG",
                                                 '4': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-4/NCUPNRG",
                                                 '5': "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-5/NCUPNRG"}}
DL_PRB_AVAIL_COUNTERS_5RG_TDD = {"M55308C10013": "BTS/MRBTS-1/NRBTS-1/NRCELL-1/NCELA"}
TPUTS_5RG = [100, 100, 100, 100, 100]
TPUTS_7RG = [100, 100, 100, 100, 100, 100, 100]
TPUTS_7RG_RG2_EMPTY = [100, 0, 100, 100, 100, 100, 100]
UTILIZATION_MARGIN = 5
SPIDS_301_01_ZERO = [3, 4]
SPIDS_301_01_NON_ZERO = [1, 2]
SNSSAIS_301_01 = [1, 2, 3]
SPIDS_301_02 = [1, 2, 3, 4]
SNSSAIS_301_02 = [2]
SPIDS_401_02_ZERO = [1, 2, 3, 5]
SPIDS_401_02_NON_ZERO = [4]

PRB_DSS_CELLS = [1, 2, 3]
PRB_DSS_UES = [11, 12, 13]

TPUT_TDD_RATIO = 2.2
TPUT_105_002 = [231, 341, 429, 253, 253, 484]
TPUT_105_003 = [120, 120, 80]
TPUT_105_32 = [22, 34, 45, 60, 75, 25, 30, 90, 55, 125, 25, 45, 25, 85, 55, 55, 40, 40, 85, 40, 90, 90, 25, 25, 25, 90,
               40, 105, 20, 70, 40, 25]
TPUT_PRB_DSS = [300, 300, 300]
TPUT_107_001 = [150, 320, 440, 550, 75, 75, 75]
TPUT_107_002 = [35, 175, 130, 17, 17, 17]
TPUT_301_003_SA = [550, 220, 363, 286]
TPUT_301_003_NSA = [440, 605, 297]
TPUT_108_002 = [150, 40, 40, 40, 40, 40, 40]
TPUT_401_001_5UE = [160, 305, 240, 385, 380]
TPUT_401_001_7UE = [160, 305, 240, 385, 380, 30, 30]
TPUT_401_002_5UE = [33, 63, 50, 70, 80]
UE_IP_A_B301_001_1 = ['72.23.0.1', '72.23.0.2', '72.23.0.3']
UE_IP_A_B301_001_2 = ['72.23.0.4', '72.23.0.5', '72.23.0.6']
UE_IP_4_SA_A_B301 = ['72.23.0.1', '72.23.0.2', '72.23.0.3', '72.23.0.5']
# QC Configuration

QC_TESTCASES_TITLES = {
    'TDD': {
        'A_B601_OAM_TDD': 'CB008746-A_B601_OAM_activate_feature_TDD',
        'A_B601_CELLSETUPREQ_FDD': 'CB008746-A_B601_CellSetupReq_fields_check_TDD',
        'A_B601_no_SPID_TDD': 'CB008746-A_B601_NSA_Slicing_Ues_with_no_SPID_TDD',
        'A_B105_CHECK_QUOTAS_TDD': 'CB008746-A_B105_Slice_aware_scheduler_check_quotas_for_NSA_only_TDD',
        'A_B105_32_SLICES_TDD': 'CB008746-A_B105_Slice_aware_scheduler_verification_NSA_32_slices_TDD',
        'A_B107_NRPMQAP_SPID_TDD': 'CB008746-A_B107_NRPMQAP_per_SPID_counters_TDD',
        'A_B108_TDD': 'CB008746-A_B108_online_NRPMQAP_spidRange_modification_TDD',
        'A_B401_SPID_TDD': 'CB008746-A_B401_SPID_online_activation_deactivation_for_NSA_only_TDD',
        'A_B301_NSA_SA_TDD': 'CB008746-A_B301_SAS_and_SPID_online_activation_for_NSA_SA_TDD',
        'A_B301_NSA_SA_MODY_TDD': 'CB008746-A_B301_Quotas_online_modification_NSA_SA_TDD',
    },
    'FDD': {
        'A_B601_OAM_FDD': 'CB008746-A_B601_OAM_activate_feature_FDD',
        'A_B601_CELLSETUPREQ_FDD': 'CB008746-A_B601_CellSetupReq_fields_check_FDD',
        'A_B105_unknown_SPID_FDD': 'CB008746-A_B105_NSA_Slicing_Ues_with_unknown_SPID_FDD',
        'A_B105_CHECK_QUOTAS_FDD': 'CB008746-A_B105_Slice_aware_scheduler_check_quotas_for_NSA_only_FDD',
        'A_B105_32_SLICES_FDD': 'CB008746-A_B105_Slice_aware_scheduler_verification_NSA_32_slices_FDD',
        'A_B301_NSA_SA_FDD': 'CB008746-A_B301_SAS_and_SPID_online_activation_for_NSA_SA_FDD',
        'A_B301_NSA_SA_MODY_FDD': 'CB008746-A_B301_Quotas_online_modification_NSA_SA_FDD',
        'A_B107_NRPMQAP_SPID_FDD': 'CB008746-A_B107_NRPMQAP_per_SPID_counters_FDD',
        'A_B108_FDD': 'CB008746-A_B108_online_NRPMQAP_spidRange_modification_FDD',
        'A_B108_default_FDD': 'CB008746-A_B108_online_NRPMQAP_spidRange_modification_with_default_value_FDD',
        'A_B401_SPID_FDD': 'CB008746-A_B401_SPID_online_activation_deactivation_for_NSA_only_FDD',
        'EB101_DSS_PRB': 'CB008746-B_B103_SPID_based_slicing_with_PRB_pooling_and_DSS_enabled'
    }
}

_DIRNAME_8746 = 'CB008746-SR_SPID_based_NSA_slicing'
_PATH_QC_23R3_8746 = 'Root\\Test_Sets\\23R3\\New_Features\\RAN_L2_SW_KRK_2\\{}'.format(_DIRNAME_8746)
_PATH_QC_TRUNK_8746 = 'Root\\Test_Sets\\Trunk\\RAN_L2_SW_KRK_2\\{}'.format(_DIRNAME_8746)
_PROJECTNAME_QC_8746 = 'CB008746-A_SPID_based_NSA_slicing_for_FR1'
_PROJECTNAME_QC_8746_B = 'CB008746-B_Interaction_with_PRB_pooling_and_DSS'
QC_DIR_NAMES = {
    'SBTS00': {
        'A_B601_OAM_TDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B601_CELLSETUPREQ_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B601_no_SPID_TDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B105_CHECK_QUOTAS_TDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B105_32_SLICES_TDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B601_OAM_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B601_CELLSETUPREQ_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B105_unknown_SPID_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B105_CHECK_QUOTAS_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B105_32_SLICES_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B301_NSA_SA_TDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B301_NSA_SA_MODY_TDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B301_NSA_SA_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B301_NSA_SA_MODY_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B107_NRPMQAP_SPID_TDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B108_TDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B108_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B108_default_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B401_SPID_TDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B401_SPID_FDD': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746},
        'EB101_DSS_PRB': {'path': _PATH_QC_TRUNK_8746, 'project': _PROJECTNAME_QC_8746_B}
    },
    'SBTS23R4': {
        'A_B601_OAM_TDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B601_CELLSETUPREQ_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B601_no_SPID_TDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B105_CHECK_QUOTAS_TDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B105_32_SLICES_TDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B601_OAM_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B601_CELLSETUPREQ_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B105_unknown_SPID_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B105_CHECK_QUOTAS_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B105_32_SLICES_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B301_NSA_SA_TDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B301_NSA_SA_MODY_TDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B301_NSA_SA_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B301_NSA_SA_MODY_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B107_NRPMQAP_SPID_TDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B108_TDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B108_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B108_default_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B401_SPID_TDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'A_B401_SPID_FDD': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746},
        'EB101_DSS_PRB': {'path': _PATH_QC_23R3_8746, 'project': _PROJECTNAME_QC_8746_B}
    }
}

_DESC = 'Krakow VRF Engineering team testcases for CB008746 feature'
_QC_DOC = \
    'maintainer: Adrianna Pienkowska, Jacek Kozmic, Agata Sidlo, Bartosz Stanek\ndescription:\n{}'.format(_DESC)

REPORT_QC = {
    'qc_project': 'RAN_ET',
    'qc_domain': 'MN_RAN',
    'ca': 'RAN_L2_SW_KRK_2',
    'username': 'owner',
    'links': {},
    'add_info': ['UTE', 'TAF'],
    'suite_path': None,
    'qc_testlab_path': None,
    'qc_test_set_name': None,
    'features_covered': None,
    'doc': _QC_DOC
}

VENDOR_GNB = os.path.join(CURDIR, 'configs/vendor_from_gnb.xml')
VENDOR_PRB_DSS = os.path.join(CURDIR, 'configs/vendor_PRB_DSS.xml')
VENDOR_PRB = os.path.join(CURDIR, 'configs/vendor_PRB.xml')
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

BIP_E_DSS_ENABLED_PREFIX = 'dldata_pdsch_send_req'
BIP_USING_MCSHARK_E_DSS_ENABLED = True
FILTER_PDSCH_PDCCH_SEND_REQ_E_DSS_ENABLED = '-Y "dldata_pdschsendreq && !(3gpp.rnti==65535)"'
SLOTS_USED_E_DSS_ENABLED = ['1', '2', '3', '4', '6', '7', '8']
START_PRB_VALUE_EXPECTED_E_DSS_ENABLED = '0'
NUM_OF_PRB_VALUE_EXPECTED_E_DSS_ENABLED = '106'
