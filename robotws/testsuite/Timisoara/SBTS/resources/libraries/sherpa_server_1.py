from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.ue import *
from testsuite.Hangzhou.OAM.RAN_PZ_HAZ_34.libraries.global_vars import *

ue_config = get_common_ue_config(tl.ues[0], 0)
sherpa_server_ip = ue_config['cpc_ip']
sherpa_server_username = ue_config['cpc_username']
sherpa_server_password = ue_config['cpc_password']
sherpa_server_local = "/cygdrive/c/sherpa_log"
