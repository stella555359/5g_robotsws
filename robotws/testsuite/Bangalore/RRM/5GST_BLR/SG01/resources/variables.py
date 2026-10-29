import os

from testsuite.RRM.Krakow.resources.Python.common_gnb import get_builtin_value


tl = get_builtin_value(param_name="tl")

# General vars
ADMIN_ALIAS = 'default'
NOKIA_PASS = tl.gnbs[0].cu.oam_ssh_connection_details.password
NOKIA_LOGIN = tl.gnbs[0].cu.oam_ssh_connection_details.username
NOKIA_USERNAME = tl.gnbs[0].cu.oam_ssh_connection_details.username
GNB_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr
OUTPUT_DIR = '/home/ute/results'
SUITE_LOGS_DIR = 'CB006064'

# WTS vars
ALIAS_TSHARK = 'tshark_1'
ALIAS_WTS_6064 = 'ap_egate'
EDAEMON_PORT = '22222'
EGATE_PORT = '20000'
WTS_DIR_PATH = '/opt/iphy/latest'

EPCSIM_CFG_FILE = 'basic_l1bypass_sa_call_tdd_cmwv_6UEs.cfg'
EPCSIM_CFG_4CELLS_FILE = 'basic_l1bypass_sa_call_tdd_cmwv_6UEs_4cells.cfg'
EPCSIM_CFG_10UE_FILE = 'basic_l1bypass_sa_call_tdd_cmwv_10UEs_new_UECap_beam_reports.cfg'
EPCSIM_CFG_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), EPCSIM_CFG_FILE)
EPCSIM_CFG_4CELLS_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), EPCSIM_CFG_4CELLS_FILE)
EPCSIM_CFG_10UE_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), EPCSIM_CFG_10UE_FILE)

# Regexes
REGEX_EGATE_ACTIVATED = '(The state is ACTIVE)'
REGEX_UE_ATTACH_PASS = r'(UE with RAN UE NGAP ID \d+ and AMF UE NGAP ID \d+ is now Registered)'
REGEX_PDU_SESSION_PASS = r'(Established PDU session ID=\d+ using PDU Gateway ID=\d+)'
REGEX_STOP_TRAFFIC = r'UE \d+: Traffic was stopped for \d+ sessions and upf:\d+'
REGEX_START_TRAFFIC = {
    'ul': r'UE\d+: Started Uplink Internal traffic over UDP on Ue:\d+',
    'dl': r'UE\d+: Started Downlink Internal traffic over UDP on Ue:\d+'
}
REGEX_SIB_1_RECEPTION_PASS = r'(SystemInformationBlockType1)'

# Biplog
BIP_MESSAGES_TC4B = ['uldata_pucchreceiverespps']
BIP_MESSAGES_TC3D = ['uldata_pucchreceivereq']
UE_BEAM_ASSIGNMENT_TC3D = {1: 21, 2: 21, 3: 26, 4: 26, 6: 21, 7: 21, 8: 26, 9: 26}
CONFIGURE_BEAM_0 = r'beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ' \
                   r'ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50'
CONFIGURE_BEAM_1 = r'beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ' \
                   r'ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120'
GNB_MIRROR_SCRIPT_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'bip_script/gnbMirroring.sh')
GNB_MIRROR_CONFIG_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'bip_script/gnbMirroringConfig.sh')

# BIP
MIRRORING_SCRIPTS_PATH = os.path.dirname(os.path.abspath(__file__)) + '/../../resources/Robot/BIP_scripts/'
MIRRORING_SCRIPT = 'gnbMirroring.sh'
MIRRORING_CONFIG = 'gnbMirroringConfig.sh'
FULL_MIRRORING_SCRIPT = MIRRORING_SCRIPTS_PATH + MIRRORING_SCRIPT
FULL_MIRRORING_CONFIG = MIRRORING_SCRIPTS_PATH + MIRRORING_CONFIG
GNB_MIRRORING_SCRIPT = '/user/toor4nsn/' + MIRRORING_SCRIPT
GNB_MIRRORING_CONFIG = '/user/toor4nsn/' + MIRRORING_CONFIG
MIRRORING_DESTINATION = '/tmp/bip.pcap'
BIP_PCAP_FILE = '/tmp/bip.pcap'
BIP_PCAP_FILE_ASIK = '/tmp/tcpdump_L2L1_bip_filtering_off.pcap0'
LUASHARK_PATH = '/opt/luashark/generated_luashark/luashark.lua'

# TTI
TTI_SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__)) + '/../../resources/Python/TtiTraces/gnb_tti_traces_v3.sh'

# SCF parameters
SCF_CB006064_UTE_CLOUD_BASIC_FILE = 'basic_SCF_UTE_Cloud.xml'
FULL_PATH_TO_DEFAULT_SCF = OUTPUT_DIR + '/' + SUITE_LOGS_DIR + '/' + SCF_CB006064_UTE_CLOUD_BASIC_FILE
SCF_CB006064_BASIC_FILE = 'Configuration_scf_MRBTS-1_TL19_l1bypass_eCPRI_SA.xml'
DELTA_CB006064_B_CONF1_TC4 = 'delta_CB006064-B_conf1_TC4.json'
DELTA_CB006064_B_CONF2_TC6 = 'delta_CB006064-B_conf2_TC6.json'
DELTA_CB006064_B_CONF2_TC9 = 'delta_CB006064-B_conf2_TC9.json'
DELTA_CB006064_C_CONF1_TC3 = 'delta_CB006064-C_conf1_TC3.json'
DELTA_CB006064_C_CONF1_TC6 = 'delta_CB006064-C_conf1_TC6.json'
DELTA_CB006064_D_CONF1_TC1 = 'delta_CB006064-D_conf1_TC1.json'
DELTA_CB006064_D_CONF1_TC3 = 'delta_CB006064-D_conf1_TC3.json'
DELTA_CB006064_BASIC_CONFIG_FILE = 'delta_CB006064_basic_configuration.json'

# PM counters
CELLS_TO_CHECK = [1, 2]
PM_COUNTERS_PRBS = ['M55308C10004']
PM_COUNTERS_BASIC = ['M55303C14001', '>0', 'PUCCH_FORMAT1_NON_DTX',
                     'M55303C18001', '>0', 'PUCCH_FORMAT3_NON_DTX',
                     'M55303C13001', '<16', 'PUCCH_FORMAT1_DTX',
                     'M55303C17001', '<16', 'PUCCH_FORMAT3_DTX']
PM_COUNTERS_WITH_TPUT = PM_COUNTERS_BASIC + ['M55308C10002', '>0', 'PRB_USED_PUSCH']

PDSCH_INIT = ["M55300C000{:02d}".format(x) for x in range(0, 29)]
SUCCESS_PDSCH_BY_INIT = ["M55300C010{:02d}".format(x) for x in range(0, 29)]
SUCCESS_PDSCH_BY_ANY = ["M55300C020{:02d}".format(x) for x in range(0, 29)]
UNSUCCESS_PDSCH_BY_LAST_HARQ = ["M55300C030{:02d}".format(x) for x in range(0, 29)]

SW_CONFIG_ADDITIONAL = {
    '0x5800F3': 1,  # WA to enable F3 non-DTX
    '0x10041': 5,   # ERadCcs_AaSysLogOutputMode - UDP logging enabled
    '0x1003F': 1,   # AaSysLogInputLevel
    '0x10040': 1,   # AaSysLogOutputLevel
    '0x590072': 1,  # CP-RT log level
    '0x41001b': 1,  # CP-NRT log level
}
