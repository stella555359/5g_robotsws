__maintainer__ = "QT NPS"
__team__ = "MN 5G_RAN Pz NPS CI"
__email__ = "5G_NPS_CI@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.core import EPCSim
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.ue import AirphoneCloud, Airphone
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from collections import OrderedDict
from taf.config.testline.ue import TM500


########################################################
TL_NPS_name = "CV35"
TL_name = "7_20_QT" + TL_NPS_name
IPV = "IPV4"
# MODEM_BOARD='ABIL'  #ABIL   ABIK
# ASIK public IP
asik_addr_webui = "10.5.114.92"
asik_addr = "10.5.114.92"
asik_username = "toor4nsn"
asik_password = "oZPS0POrRieRtu"
########################################################

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.114.94", username="ute", password="ute"
    )
)


_lmp_connection = SshServiceDetails(
    addr=asik_addr, username="toor4nsn", password="oZPS0POrRieRtu"
)

_cu = CU(
    backhaul_site_oam_ip=asik_addr,
    oam_ssh_connection_details=SshServiceDetails(
        addr=asik_addr, username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr=asik_addr_webui, username="Nemuadmin", password="nemuuser"
    ),
)

_du_capacity_unit = CapacityUnit(addr="6.6.6.6")


_airphone_cloud = AirphoneCloud(
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.245", username="_rcpadmin", password="RCP_owner"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="192.168.255.245"),
)

_egate = SshServiceDetails(addr="0.0.0.0", username="user2", password="password2")

_l3 = SshServiceDetails(
    addr="192.168.255.245", username="_rcpadmin", password="RCP_owner"
)

_l2 = SshServiceDetails(
    addr="192.168.255.245", username="_rcpadmin", password="RCP_owner"
)


capacity_unit = CapacityUnit(addr="6.6.6.6")

_common_unit = CommonUnit(
    lmp_connection=_lmp_connection, capacity_units=[capacity_unit]
)

_airscale = Airscale(common_units=[_common_unit])

_l1 = Airscale(common_units=[_common_unit])

_airphone = Airphone(
    egate=_egate,
    l3_ssh_connection_details=_l3,
    l2_ssh_connection_details=_l2,
    l1=_l1,
    airphone_cloud=_airphone_cloud,
)

# _du = DU(airscale=_airscale, rus=[_ru])
_du = DU(airscale=_airscale, rus=[])

_classicalbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="10.5.112.66",
    mcc=-1,
    mnc=-1,
    tac=-1,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.112.66", username="ute", password="ute"
    ),
    dir_path="/home/ute/WTS/WTS-4.0.4236",
    cfg_filename="basic_wts_step2.cfg",
)

_tm500 = TM500(
    tma_host=SshServiceDetails(
        addr="10.14.62.173", username="cv5g2_1", password="B@st1en5G"
    ),
    tma_command_port=5004,
    pdu_port=None,
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_classicalbts],
    core=_epcsim,
    ues=[_tm500],
    tl_cloud_topology=TL_NPS_name,
)

tl = TestlineWrapper(tl)


Config_with_airphone = "False"


# please define the key-value mapping dict like the order like below
_swpool_tools = "/ffs/run/swpool/TOOLS/"
_5G_L1NODE = "/ffs/run/swpool/5G/L1NODE/"
_5G_L1PLTF = "/ffs/run/swpool/5G/L1PLTF/"
_swpool_5g = "/ffs/run/swpool/5G/"
path_map_file_dict = OrderedDict()
path_map_file_dict[_swpool_tools] = ["lfs-install-helper"]
path_map_file_dict[_5G_L1NODE] = ["*.bin"]
path_map_file_dict[_5G_L1PLTF] = ["5GL1SW.itb"]
path_map_file_dict[_swpool_5g] = ["default-install.sh"]

# variables for install loner package
loner_name = "5GL1SW.tgz"
local_modify_file_path = _CFG_DIR
swconfig_path = os.path.join(_CFG_DIR, "WA_file", "swconfig_local.txt")
oamagentjs_path = os.path.join(_CFG_DIR, "WA_file", "oamagentjs.tgz")

# powerswitch for ASIK
# powerstation_ip = '10.5.113.126'
# user:administrator ,passwd:uteadmin
# powerstation_asik_port = 2


fsp_addr = "192.168.253.22"

fct_addr = "192.168.253.17"

# SW_PATH = "/home/ute/sw_download"

WMP_flag = True
Install_flag = "0"
# classical_eoc_filename = '5g_pid12_classical_l2rt_eoc.json'
asik_swconfig_path = os.path.join(_CFG_DIR, "WA_file", "swconfig.txt")
# asik_eoc_path = os.path.join(_CFG_DIR, 'WA_file', classical_eoc_filename)

# ???    No RF on TL17
# rf_addr = '172.16.1.5'
# rf_username = 'root'
# rf_password = 'umniedziala'

# wa for json
pid_json_path = os.path.join(
    "/tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/profiles/5G19/",
    "5g_pid12_class.json",
)
# pid_json_path = os.path.join(
#    '/tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/profiles/5G18A/',
#    '5g_pid11_classical_eoc.json')


# For test compatibility
cfg_dir = _CFG_DIR
__all__ = ["tl"]
