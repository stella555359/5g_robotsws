from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


def get_ru_info(tl):
    ru_list = tl.gnbs[0].dus[0].rus
    rus = []
    for ru in ru_list:
        ru_info = {}
        ru_info['addr'] = ru.default_ssh_connection_details.addr
        ru_info['username'] = ru.default_ssh_connection_details.username
        ru_info['password'] = ru.default_ssh_connection_details.password
        ru_info['ru_type'] = ru.ru_hw_group
        if ru.serial_number:
            ru_info['serial_number'] = ru.serial_number
        if ru.lmp_connection:
            ru_info['ctrl_addr'] = ru.lmp_connection.addr
            ru_info['ctrl_username'] = ru.lmp_connection.username
            ru_info['ctrl_password'] = ru.lmp_connection.password
        rus.append(ru_info)
    return rus


def get_RU_PB_info(tl):
    ru_list = tl.gnbs[0].dus[0].rus
    rus_PB_info = []
    for ru in ru_list:
        ru_info = {}
        ru_info['addr'] = ru.pdu_port.pdu.addr
        ru_info['port'] = ru.pdu_port.port_no
        rus_PB_info.append(ru_info)
    return rus_PB_info


def get_ENB_info(tl):
    enb_list = tl.enbs[0].airscale.common_units
    ENBs = []
    for enb in enb_list:
        enb_info = {}
        enb_info['addr'] = enb.lmp_connection.addr
        enb_info['username'] = enb.lmp_connection.username
        enb_info['password'] = enb.lmp_connection.password
        try:
            enb_info['pc_addr'] = enb.test_pc.default_ssh_connection_details.addr
            enb_info['pc_username'] = enb.test_pc.default_ssh_connection_details.username
            enb_info['pc_password'] = enb.test_pc.default_ssh_connection_details.password
        except Exception:
            enb_info['pc_addr'] = '1.1.1.1'
        ENBs.append(enb_info)
    return ENBs


def get_ue_pc_info(tl):
    ue_pcs = []
    try:
        ue_list = tl.ues
        for ue in ue_list:
            ue_info = {}
            ue_info['addr'] = ue.ssh_connection_details.addr
            ue_info['username'] = ue.ssh_connection_details.username
            ue_info['password'] = ue.ssh_connection_details.password
            ue_pcs.append(ue_info)
    except Exception:
        print('No ue')
    return ue_pcs


def get_enb_pc_info(tl):
    enb_pcs = []
    try:
        enb_pc_list = tl.test_pcs
        for pc in enb_pc_list:
            enb_pc_info = {}
            enb_pc_info['addr'] = pc.default_ssh_connection_details.addr
            enb_pc_info['username'] = pc.default_ssh_connection_details.username
            enb_pc_info['password'] = pc.default_ssh_connection_details.password
            enb_pcs.append(enb_pc_info)
    except Exception:
        print('No enb pc info in testline_config, just affect concurrent tl')
    return enb_pcs


def get_fsmf_info(tl):
    fsmf = []
    try:
        fsmf_list = tl.enbs[1].airscale.common_units
        for item in fsmf_list:
            hardware_type = item.hardware_type
            if hardware_type != 'FSMF':
                continue
            fsmf_info = {}
            fsmf_info['mplane_addr'] = tl.enbs[1].oam_ip
            fsmf_info['ssh_addr'] = item.lmp_connection.addr
            fsmf_info['username'] = item.lmp_connection.username
            fsmf_info['password'] = item.lmp_connection.password
            fsmf_info['test_pc_ip'] = item.test_pc.default_ssh_connection_details.addr
            fsmf_info['test_pc_user'] = item.test_pc.default_ssh_connection_details.username
            fsmf_info['test_pc_pass'] = item.test_pc.default_ssh_connection_details.password
            fsmf.append(fsmf_info)
    except Exception:
        print('No fsmf!')
    return fsmf


def get_slave_gnb_du_info(tl):
    slave_gnb_du = tl.gnbs[1].dus[0].airscale.common_units[0]
    slave_gnb_du_info = {}
    slave_gnb_du_info['addr'] = slave_gnb_du.lmp_connection.addr
    slave_gnb_du_info['username'] = slave_gnb_du.lmp_connection.username
    slave_gnb_du_info['password'] = slave_gnb_du.lmp_connection.password
    try:
        slave_gnb_du_info['pc_addr'] = slave_gnb_du.test_pc.default_ssh_connection_details.addr
        slave_gnb_du_info['pc_username'] = slave_gnb_du.test_pc.default_ssh_connection_details.username
        slave_gnb_du_info['pc_password'] = slave_gnb_du.test_pc.default_ssh_connection_details.password
    except Exception:
        print('No slave gnb du')
    return slave_gnb_du_info


tl = BuiltIn().get_variable_value("${tl}")

rus = get_ru_info(tl)
rus_PB_info = get_RU_PB_info(tl)
try:
    ENBs = get_ENB_info(tl)
except Exception:
    print("no enb info!")
fsmf = get_fsmf_info(tl)
enb_pcs = get_enb_pc_info(tl)
ue_pcs = get_ue_pc_info(tl)

# Fail log will upload to this ftp server.
ftp_server = '10.57.167.31'

# The site in upload_log_id will delete the logs of 5 days ago when it run cases.
upload_log_id = 847

# The path of delete code and log from taf.
log_Path_List = ["/opt/transformers.dynamic.nsn-net.net/workspace/CIT/Master/Manual/"]

Multi_BTS_ID = ['312']
if_moran = False
BTS_ID = tl.gnbs[0].instance_id
if (len(tl.gnbs) > 1) and (str(BTS_ID) not in Multi_BTS_ID):
    if_moran = True
    Peer_WEBUI_ADDR = tl.gnbs[1].cu.oam_http_connection_details.addr
    peer_asik_addr = tl.gnbs[1].cu.oam_ssh_connection_details.addr
elif (len(tl.gnbs) > 1) and (str(BTS_ID) in Multi_BTS_ID):
    if_moran = False
    Peer_WEBUI_ADDR = tl.gnbs[1].cu.oam_http_connection_details.addr
    peer_asik_addr = tl.gnbs[1].cu.oam_ssh_connection_details.addr
    PEER_BTS_ID = tl.gnbs[1].instance_id
    try:
        SLAVE_GNB_DU = get_slave_gnb_du_info(tl)
    except Exception:
        print("no slave gnb dus info!")

if tl.gnbs[0].global_bts_id:
    NRBTS_ID = tl.gnbs[0].global_bts_id
else:
    NRBTS_ID = tl.gnbs[0].instance_id
# For save eNB snapshot
ENB_user = 'Nemuadmin'
ENB_psd = 'nemuuser'

Ignore_Fault = """61524,61652,9000,61649,61074,61618,4592,1932,4334,4655,4654,4459,4687,1936,4340,4293,4651,6129
,4652,4681,6327"""
Ignore_Fault_Fallback = """61524,61652,9000,61649,61074,61618,4592,1932,4334,4420,23,6450,7300,7319,4340,4655,4654,4459
,4293,4651,4652,7107"""
# except_fault_id = "61524,61652,9000,61649,61074,61618,4592,1932,4334,4420"
Fallback_fault = ['4082', '4085']
Exp_Fault_Fallback = ['SW fallback']
# 4340-Previously downloaded plan was overwritten, cm provision happened during gps upgrade
ignore_history_fault = """7319,7300,9000,61524,61652,61649,61074,61618,4592,1932,4420,4340,4655,4654,4459,4293,4651,
4652,7107,6327"""
ignore_history_fault_for_concurrent = """7319,7300,9000,61524,61652,61649,61074,61618,4592,1932,4420,4340,10,1898,4452,
4655,4654,4459,16,4298,4293,4651,62003,7509,7513,7107,7511,4652,4405"""
ignore_history_fault_moran_slave = """7319,7300,9000,61524,61652,61649,61074,61618,4592,1932,4420,4340,10,1898,4452,
4655,4654,4459,16,4298,4293,4651,7107,4220,4652"""
eNB_Ignore_Fault = """61524,61652,9000,61649,61074,61618,4592,1932,4334,4420,4655,4654,4297,6261,4459,6327,6450,4651,
6129,61074,4652,7300,7107,7319,4681"""
fail_history_fault = ["reset"]
fail_history_faultId = ["10", "1868"]

# Use for "Check if Trace Session Alive".
Session_Type = {
    "Trace Expert": "27002",
    "DCAP": "49151",
    "PCMD": "48151"
}

# The following bts site will not save pass log for saving time.
Ignore_pass_log = ['838', '852', '847']

# "Reset GPS Module in Case GPS Error"
GPS_fault = ["4452"]

# "Check GPS Firmware Upgrade Alarm Not Exist"
GPS_firmware_upgrade_alarm = ["4420"]

# "Power Reset RU for Special Fault"
RU_power_reset_fault = ["10", "1920", "1908", "1906"]

# The site in eNB_snapshot will save enb snapshot when enb has unexpected fault.
eNB_snapshot = ['841', '847', '850', '852', '288', '2503', '851', '596', '871', '312', '838', '875', '292',
                '315', '600', '599']

# Catch realtime log will catch tcpdump msg.
cpif_ip = '192.168.253.228'
cp16_ip = '192.168.253.16'
cpcl_ip = '192.168.253.226'
cpnb_ip = '192.168.253.227'

# "Clear RD Flag in Uboot Environment"
bsh_lsit = ['bsh 0:0', 'bsh 1:0', 'bsh 1:1', 'bsh 2:0', 'bsh 2:1', 'bsh 3:0', 'bsh 3:1']

# Precheck RU flags will set the right flag if the RU do not have the right flag.
RU_GW_IP = {
    '192.168.100.100': 'ccsShell.sh rad -pw 0x10042 0xC0A86464',
    '192.168.100.200': 'ccsShell.sh rad -pw 0x10042 0xC0A864c8',
    '192.168.101.100': 'ccsShell.sh rad -pw 0x10042 0xC0A86564',
    '192.168.101.200': 'ccsShell.sh rad -pw 0x10042 0xC0A865c8',
}
RU_Standard_Flag = ['0x10042', '0x10043']

# Unexpected reset
Extra_Reset = ["System module site reset : Recovery (Execute reset.)", "probably SW crash",
               "Recovery (Execute reset.)", "Watchdog reset"]

# Stop_flag will be set to 1 when some critical fault appeared. And test will be stopped, the environment will be kept.
stop_flag = '0'

# Stop_flag will be set to 1 when the following fault at the site in Stop_BTS_ID fault appeared.
# And test will be stopped, the environment will be kept.
Stop_Fault_ID = ['1911', '10']
Stop_BTS_ID = ['875', '852', '862', '291', '505', '311', '310', '306', '575', '591', '315', '599', '600',
               '596', '312', '883', '888']

# Trigger Recovery Action According to Fault ID
Recovery_to_Fault = {
    23: "Upgrade to Current SW Version",
    1850: "Upgrade to Current SW Version",
    4452: "Reset GPS and Check GPS Status",
    10: "WA for Fault 10",
    1868: "Site Reset by command if Cell not onAir",
    7300: "Site Reset by command if Cell not onAir",
    2002: "WA for Fault 10",
    1920: "Power Reset RU for Special Fault",
    1908: "Power Reset RU for Special Fault",
    1906: "Power Reset RU for Special Fault",
    4001: "Site Reset And Check Status"
}

# Different release' downtime.
Downtime_With_Different_Config = {
    'SBTS21B_Intra_SA': 1008,
    'SBTS21B_Intra_NSA': 1008,
    'SBTS21B_Inter_SA': 1080,
    'SBTS21B_Inter_NSA': 1080,
    'SBTS22R1_Intra_SA': 792,
    'SBTS22R1_Intra_NSA': 756,
    'SBTS22R1_Inter_SA': 1008,
    'SBTS22R1_Inter_NSA': 972,
    'SBTS22R2_Intra_SA': 792,
    'SBTS22R2_Intra_NSA': 756,
    'SBTS22R2_Inter_SA': 1008,
    'SBTS22R2_Inter_NSA': 972,
    'SBTS22R3_Intra_SA': 1200,
    'SBTS22R3_Intra_NSA': 1200,
    'SBTS22R3_Inter_SA': 1200,
    'SBTS22R3_Inter_NSA': 1200,
    'SBTS22R4_Intra_SA': 1200,
    'SBTS22R4_Intra_NSA': 1200,
    'SBTS22R4_Inter_SA': 1200,
    'SBTS22R4_Inter_NSA': 1200,
    'SBTS23R1_Intra_SA': 1200,
    'SBTS23R1_Intra_NSA': 1200,
    'SBTS23R1_Inter_SA': 1200,
    'SBTS23R1_Inter_NSA': 1200,
    'SBTS23R2_Intra_SA': 1200,
    'SBTS23R2_Intra_NSA': 1200,
    'SBTS23R2_Inter_SA': 1200,
    'SBTS23R2_Inter_NSA': 1200,
    'SBTS23R3_Intra_SA': 1200,
    'SBTS23R3_Intra_NSA': 1200,
    'SBTS23R3_Inter_SA': 1200,
    'SBTS23R3_Inter_NSA': 1200,
    'SBTS23R4_Intra_SA': 1200,
    'SBTS23R4_Intra_NSA': 1200,
    'SBTS23R4_Inter_SA': 1200,
    'SBTS23R4_Inter_NSA': 1200,
    'SBTS24R1_Intra_SA': 1200,
    'SBTS24R1_Intra_NSA': 1200,
    'SBTS24R1_Inter_SA': 1200,
    'SBTS24R1_Inter_NSA': 1200,
    'SBTS00_Intra_SA': 1200,
    'SBTS00_Intra_NSA': 1200,
    'SBTS00_Inter_SA': 1200,
    'SBTS00_Inter_NSA': 1200,
}
Concurrent_BTS_ID = ['841', '852', '847', '838', '596', '875', '871', '851', '600', '315', '599']
Dual_Core_BTS_ID = ['838', '851', '847', '868', '292']

# If bts id in Ignore_CM_BTS, will not do cm provision
Ignore_CM_BTS = []

# The command for catch ru journal log
RU_journallog_command = 'journalctl -f\n'

# The command for catch ru tcpdump, need to modify to right one if you want to use it.
RU_tcpdump_command = 'write ru tcpdump command here,end with RU_tcpdump.pcap\n'

# If wait time is not 0, please fill it with the format of 20 min, the time of keep on air after site reset
Wait_Time_After_Site_Reset = 0

# If the RU in your site need to enable ssh every time after site reset, please put the id in enable_BTS_ID.
enable_BTS_ID = ['292', '98', '838', '850', '852', '841', '847', '306', '731', '505', '803', '97', '862', '863', '575',
                 '868', '87', '297', '732', '734', '711', '736', '871', '848', '805', '875', '741', '744', '745',
                 '869', '870', '747', '882', '705', '748', '883', '888', '11655']

# Need to modify commonBuild_trunk when trunk release change.
commonBuild_trunk = 'SBTS24R1'

# If the site in eNB_alarm_BTS_ID has alarms which cannot be ignored, will fail case.
eNB_alarm_BTS_ID = ['841', '850', '852', '847', '851', '288', '2503', '868', '871', '315', '599', '600',
                    '312', '596', '875', '292']

# In catch realtime log, the site in made_log_BTS_ID can catch made log.
made_log_BTS_ID = ['291', '851', '286', '804', '810', '871', '883', '888']

# Use for get SWDL_Time and ACT_Time in /ffs/run/config/SWDLreport.txt
SW_Process = {
    'Download': ['Started Software Build Download', 'Finished Software Build Download'],
    'Activation': ['Started Activation of Software Build', 'Finished Activation of Software Build']
}

# RU type in made2_ru need to check made power
made2_ru = ['AQQL', 'AQQK', 'AQQY']

# RU HW family REL>=5
disable_swconfig_cleanup_ru = ['AHPE', 'AHPB', 'AHCA',
                               'AHFIB', 'AHLOA', 'AHBCC']

# The site in made2_ru_BTS_ID have made2 RU
made2_ru_BTS_ID = ['871']

# The site in DSS_monitor_ID will catch tcpdump of DSS
DSS_monitor_ID = ['851', '871']

# The site in notDowntime_BTS_ID will not check downtime.
notDowntime_BTS_ID = ['847', '575', '810', '868', '288', '838', '312', '596', '852', '869', '851', '882']

# The site in not_collect_log_when_alarm will not start the python job once after site reset,
# the job will catch snapshot and ru log right after fault appeared.
not_collect_log_when_alarm = ['882', '838', '868', '852', '847']

# This dict is for L3 call, key:bts id, value: cell id.
BTS_L3call = {
    '847': ['401'],
    '575': ['8'],
    '312': ['1'],
    '596': ['1'],
    '288': ['1'],
    '810': ['1'],
    '838': ['401', '1'],
    '315': ['1'],
    '599': ['1'],
    '600': ['1']
}

# The site in E2E_BTS_ID will do special E2E test,for example L3call in Reset Case.
E2E_BTS_ID = ['312', '315', '596', '599', '600']
# The site in E2E_BTS_ID support support tput more than 100M,Commn site still 100M.
E2E_L3Call_tput = 1400
Common_L3Call_tput = 100

# The site which is customer of AT&T, this kind of site need upgrade ENB firstly then GNB later.
ATT_BTS_ID = ['851']

# For netact integrate
DICT__NODE_SERVICE_LIST = {
    "LDAP_MASTER_HOSTS": "dirsrv",
    "LDAP_REPLICA_HOSTS": "dirsrv-secondary",
    "DNS_MASTER_HOSTS": "DNS-Master",
    "DNS_SLAVE_HOSTS": "DNS-Slave",
    "DB_HOSTS": "db",
    "NFS_HOSTS": "nfs",
    "LB_PRI_HOSTS": "lb-unify-primary",
    "LB_BKP_HOSTS": "lb-unify-backup",
    "JBI_NBI3GC_HOSTS": "nbi3gc",
    "JBI_NWI3_HOSTS": "nwi3",
    "JBI_Q3_HOSTS": "q3user",
    "SOCKS_PROXY_HOSTS": "socks",
    "JBI_NX2SXOH_HOSTS": "nx2s",
    "SAU_MEDIATION_HOSTS": "saucnt",
    "TP_MGR_HOSTS": "sqm_collector_npm_tp",
    "JBI_NBINSN_HOSTS": "nbisnmp"
}

# For netact integrate
DICT__NODE_SERVICE_LIST_REP = {
    "JBI_NBI3GCPM_HOSTS": "nbi3gcpm",
    "JBI_COMMONMEDIATION_HOSTS": "common_mediations",
    "JBI_FMPIPE_HOSTS": "fm_pipe",
    "WAS_CLUSTER_NETACT_HOSTS": "was",
    "WAS_DMGR_HOSTS": "dmgr",
    "TP_HOSTS": "sqm_jboss_portal",
    "PM_HOSTS": "etlcolmx",
    "PM_MGR_HOSTS": "rep_crons"
}
