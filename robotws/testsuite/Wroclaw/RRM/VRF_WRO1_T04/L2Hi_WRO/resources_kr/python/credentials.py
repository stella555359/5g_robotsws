VM_IP = 'localhost'
VM_USERNAME = 'ute'
VM_PASSWORD = 'ute'

# Cloud credentials
CONTROLLER_IP = '10.45.185.23'

gNB_CLOUD_OAM_IP = '10.44.200.137'
gNB_CLOUD_OAM_USERNAME = 'robot'
gNB_CLOUD_OAM_PASSWORD = 'rastre1'

MZOAM_WEBUI_URL = 'https://10.44.200.137/'
MZOAM_WEBUI_USER = 'Nemuadmin'
MZOAM_WEBUI_PASSWORD = 'nemuuser'

CLOUD_ASIK_IP = '192.168.2.60'
CLOUD_ASIK_USERNAME = 'toor4nsn'
CLOUD_ASIK_PASSWORD = 'oZPS0POrRieRtu'

CPIF_USERNAME = 'robot'
CPIF_PASSWORD = 'rastre1'
CPCL_USERNAME = 'robot'
CPCL_PASSWORD = 'rastre1'
CPNB_USERNAME = 'robot'
CPNB_PASSWORD = 'rastre1'
CPUE_USERNAME = 'robot'
CPUE_PASSWORD = 'rastre1'
CPNRT_USERNAME = 'robot'
CPNRT_PASSWORD = 'rastre1'

CLOUD_WTS_IP = '10.42.208.101'
CLOUD_WTS_USERNAME = 'ute'
CLOUD_WTS_PASSWORD = 'ute'

CLOUD_WTS_CONF_FILE = 'basic_nsa_call_tdd_above6GHz.cfg'

CLOUD_EGATE_PORT = '8080'


# Classical credentials
gNB_CLASSICAL_OAM_IP = '192.168.255.129'
gNB_CLASSICAL_OAM_USERNAME = 'toor4nsn'
gNB_CLASSICAL_OAM_PASSWORD = 'oZPS0POrRieRtu'

COAM_WEBUI_URL = 'https://192.168.255.129/'
COAM_WEBUI_USER = 'Nemuadmin'
COAM_WEBUI_PASSWORD = 'nemuuser'

WTS_IP = 'localhost'
WTS_USERNAME = 'ute'
WTS_PASSWORD = 'ute'

EGATE_PORT = '20000'

gNB_ASIK_SLAVE_IP = 'fct-1-0b'
gNB_ASIK_SLAVE_USERNAME = 'toor4nsn'
gNB_ASIK_SLAVE_PASSWORD = 'oZPS0POrRieRtu'

gNB_ABIL_MASTER_IP = 'fsp-1-1a'
gNB_ABIL_MASTER_USERNAME = 'toor4nsn'
gNB_ABIL_MASTER_PASSWORD = 'oZPS0POrRieRtu'

AP_IP = '192.168.200.1'
AP_USERNAME = 'toor4nsn'
AP_PASSWORD = 'oZPS0POrRieRtu'
DEV_USERNAME = 'developer'
DEV_PASSWORD = '$developer#'
AP_L2_IP = '192.168.253.84'
AP_L2_USERNAME = 'toor4nsn'
AP_L2_PASSWORD = 'oZPS0POrRieRtu'

gNB_abil_master = {'host': gNB_ABIL_MASTER_IP, 'user': gNB_ABIL_MASTER_USERNAME, 'password': gNB_ABIL_MASTER_PASSWORD,
                   'proxy': {'host': gNB_CLASSICAL_OAM_IP, 'user': gNB_CLASSICAL_OAM_USERNAME,
                             'password': gNB_CLASSICAL_OAM_PASSWORD}}
gNB_asik_master = {'host': gNB_CLASSICAL_OAM_IP, 'user':  gNB_CLASSICAL_OAM_USERNAME,
                   'password':  gNB_CLASSICAL_OAM_PASSWORD}
gNB_asik_slave = {'host': gNB_ASIK_SLAVE_IP, 'user': gNB_ASIK_SLAVE_USERNAME, 'password': gNB_ASIK_SLAVE_PASSWORD,
                  'proxy': {'host': gNB_CLASSICAL_OAM_IP, 'user': gNB_CLASSICAL_OAM_USERNAME,
                            'password': gNB_CLASSICAL_OAM_PASSWORD}}
AP_asik_master = {'host': AP_IP, 'user': AP_USERNAME, 'password': AP_PASSWORD}
AP_asik_slave = {'host': AP_L2_IP, 'user': AP_L2_USERNAME, 'password': AP_L2_PASSWORD,
                 'proxy': {'host': AP_IP, 'user': AP_USERNAME, 'password': AP_PASSWORD}}
WTS = {'host': WTS_IP, 'user': WTS_USERNAME, 'password': WTS_PASSWORD}
