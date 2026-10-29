######################################
#  TestLine 29 Ulm                   #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 05 SG SQD66"
__team__ = "MN ECE RD ULM L2PS 05 SG SQD66"
__email__ = "I_ECE_RD_ULM_SQD_66@internal.nsn.com"

import os

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.cloud_hosting import (
    NCIR,
    ControlNode,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.gnb import CloudBts, CU, DU
from taf.config.testline import RealEnb
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import TM500
from taf.config.testline.pdu import APC
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.radio import RU


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.18.200", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.47.18.120", username="admin", tenant="admin", password="system123"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.18.120", username="cloudadmin", password="system123"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="ul5g0634-14.iv.ulm.nsn-rdnet.net", username="admin", password="admin"
    ),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_19")

_cbts_flavor = DeploymentFlavorStack(
    name="TL29_5gbts_flavors",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file="5gbts_flavor.yaml",
    default_vnf_prefix="tl29-5gbts",
)

_cbts_net = DeploymentNetworkStack(
    name="TL29_5gbts_ext",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file="5gbts_ext_net.yaml",
)

_cbts_vnf = DeploymentVnfStack(
    name="TL29_5gbts_rac",
    env_files=[os.path.join(_CFG_DIR, "config_bts.env")],
    yaml_file="5gbts_heat.yaml",
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip="192.168.125.10",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.125.10", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.125.10", username="Nemuadmin", password="nemuuser", port=443
    ),
)


# GNB DU1 ABIL
_gnb_du1_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

# GNB DU1 ASIK
_gnb_du1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb_du1_capu],
    hardware_type="ASIK",
)

_gnb_du1_airscale = Airscale(common_units=[_gnb_du1_comu])


_gnb_du1 = DU(
    airscale=_gnb_du1_airscale,
    f1_m_ip_addr="192.168.255.129",
    f1_c_ip_addr="192.168.2.62",
    f1_u_ip_addr="192.168.2.61",
    rus=None,
)


_gnb = CloudBts(
    cu=_cu, dus=[_gnb_du1], cloud_deployment=_cloud_deployment, vnf_name="tl29-5gbts"
)

_epcsim = EPCSim(
    mme_ip="192.168.6.1",
    mcc=777,
    mnc=14,
    tac=777,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.18.200", username="ute", password="ute"
    ),
    dir_path="/opt/5g_wts",
    cfg_filename="TL29_basic_cfg_realLteEnb.cfg",
    edaemon_port=20021,
    egate_port=22222,
)

_tm500_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="ul5gueapp301", username="viavi1user", password="qwer2009!"
    ),
    network_interface_address="192.168.13.1",
    iperf_path="/usr/bin/iperf",
)


_tm500 = TM500(
    tma_host=SshServiceDetails(
        addr="10.46.212.226", username="viavi1user", password="qwer2009!"
    ),
    tma_command_port=5003,
    pdu_port=None,
    tma_path="C:\\Program Files (x86)\\Aeroflex\\TM500\\5G_NR_Squad66\\Test Mobile Application\\TmaApplication.exe",
    iperf_details=_tm500_iperf,
    imsi="311489000000787",
    sec_key="01020304050607080910101010101001",
)

_net_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="ul5gappserv302", username="dpdktests", password="qwer2009!"
    ),
    network_interface_address="192.168.13.1",
    iperf_path="/usr/bin/iperf",
)

_net_appserver = AppServer(iperf_details=_net_iperf)

_enb_capu = CapacityUnit(addr="192.168.253.36")

_enb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.4.121", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb_capu],
    pdu_port="",
)

_enb_airscale = Airscale(common_units=[_enb_comu])

_enb_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port="",
    radio_type=None,
    attenuation_ports=None,
)

_enb = RealEnb(system_module=_enb_airscale, rms=[_enb_rm])


# Testline
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_gnb],
    enbs=[_enb],
    cloud_hostings=[_ncir],
    core=_epcsim,
    tl_cloud_topology="CLOUD_5G_TYPE",
    ues=[_tm500],
    appserver=_net_appserver,
)

__all__ = ["tl"]
