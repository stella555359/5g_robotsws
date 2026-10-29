btsid = 578
scout_id = "1_2_CLOUD970"
distName = "MRBTS-${btsid}/EQM-1/APEQM-1/RMOD-1"
dst_dir = "/home/ute/Netconf"
location = "/home/ute/results"
scf_pat = "/home/ute/Downloads"
scf_path = "/home/ute/Downloads/c_mrbts970_scf.xml"
scf_path1 = "./testsuite/Bangalore/ORAN/SG04/resources/scf_MRBTS-578_TL2_1_ORU_ORG.xml"
scf_path2 = "./testsuite/Bangalore/ORAN/SG04/resources/scf_MRBTS-578_TL2_1_ORU_Modified.xml"
plan_path1 = "/home/ute/Plan"
plan_path = "/home/ute/Plan/NETACT-970-5-0.xml"
plan_pathx = "/home/ute/Plan/NETACT-970-6-0.xml"
LOCAL_DIR = "/home/ute/Downloads/"
acplan_path1 = "/home/ute/Downloads/netact_mrbts-578_pnp.xml"
path_ssd_m1_s2 = "./testsuite/Bangalore/ORAN/SG04/resources/netact-mr578-ssd-m1-s2.xml"
path_ssd_m1_s2_failure = "./testsuite/Bangalore/ORAN/SG04/resources/netact-mr578-ssd-m1-s2_failure.xml"
passive_sw = "Passive SW version"
imp_path1 = "--data @/var/tmp/netact-mr578-ssd-m1-s2.xml"
imp_path2 = "--data @/var/tmp/netact-mr578-ssd-m1-s2_failure.xml"
imp_header = "-H 'Content-Type:application/vnd.nokia-sm-import-request-v1+xml' -X POST"
imp_url = "'https://srnclab1042lbwas.srnblr.nsn-rdnet.net:443/sm-operations/api/sm/operations/v1/execute/\
ssd-plan-import?overwrite=true'"
pnp_report1 = "/home/ute/Downloads/NetAct-pnp-report1.txt"
pnp_report2 = "/home/ute/Downloads/NetAct-pnp-report2.txt"
output_pnp1 = "configuration provision failed"
output_pnp2 = "configuration provision succeeded"
WEB_URL = "https://${NETACT_NAME}lbwas.srnblr.nsn-rdnet.net/authentication/Login"
NETACT_NAME = "srnclab1042"
NetAct_host = "10.43.48.16"
NetAct_uname = "omc"
NetAct_pwd = "Medsql!_1893"
DIST_NAME = "PLMN-PLMN/MRBTS-578"
AutoHWID = "DH222244594"
pnp_subnet = 28
pnp_vlanid = 310
pnp_mplaneip = "10.43.197.216"
pnp_defgw = "10.43.197.209"
pnp_netactip = "10.43.48.28"
DIST_NAMES = "PLMN-PLMN/MRBTS-970"
oru_sw_ver1 = "NK-RU-POC-1202.FGP_NMS"
oru_sw_ver2 = "O-RU_OkMultiPackage_NMS"
oru_sw_ver3 = "NK_RU_POC_1103_FGP_NMS"
oru_sw_ver4 = "O-RU______OkMulti_EmptyZip_NMS"
dcaphost = "10.58.238.65"
dcapport = 443
dcap_version = "dcapv3"
dcap_uname = "dcapuser"
dcap_pwd = "dcapadmin!"

dcaphost = "10.41.209.115"
btshost = "10.43.197.216"
btsport = 443
bts_uname = "Nemuadmin"
bts_pwd = "nemuuser"
trace_id = 14.0
Timestamp = "0"
tc4 = "case-4_NetAct"
config_status = 1.0
counter_nos = "M55606C00001,M55606C00002,M55606C00003,M55606C00004,M55606C00005,M55606C00006,\
M55606C00007,M55606C00008,M55606C00009,M55606C00010"
lterel_disc = "https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build"
SW_DESTINATION = "/home/ute/Downloads"
resources_path = "/home/ute/robotws/testsuite/Bangalore/ORAN/SG04/resources"
Docker_user_name = "ute"
Docker_password = "BT5l@bus3rl0g1n"
ORU_SIM_IP = "10.45.150.67"
oran_alias = "oran_sim"
DOCKER_NAME = "orusim"

TECHNOLOGY = "SBTS-Nokia Multi Radio Transceiver Station"
MEASUREMENT = "O-RAN Transceiver Statistics"

OBJECT_AGGREGATION = "PLMN"
TIME_AGGREGATION = "RAW"
FILTER_BY = "MRBTS"
TIME_R = "Relative time"


# non default BTS ip config

use_diff_bts_IP = True
non_def_BTS_IP = "10.58.239.214"
