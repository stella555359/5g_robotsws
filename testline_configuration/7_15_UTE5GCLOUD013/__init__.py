######################################
#  TestLine 13 Ulm                   #
######################################
__maintainer__ = "MN ECE ULM R&D L3NRT 07 SqdGp63"
__team__ = "MN ECE ULM R&D L3NRT 07 SqdGp63"
__email__ = "I_ECE_RD_ULM_SQD_63@internal.nsn.com"
__owner_email__ = "vasileios.papoutsis@nokia.com"

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
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="kiwi313.delab3.nsn", username="dpdktests", password="qwer2009!"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.47.18.100", username="admin", tenant="admin", password="UTEadmin_0"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.18.100", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.46.138.130", username="admin", password="admin"
    ),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="NCIR18")

_cbts_flavor = DeploymentFlavorStack(
    name="TL13_5gbts_flavors",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file="5gbts_flavor.yaml",
    default_vnf_prefix="tl13-5gbts",
)

_cbts_net = DeploymentNetworkStack(
    name="TL13_5gbts_ext",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file="5gbts_ext_net.yaml",
)

_cbts_vnf = DeploymentVnfStack(
    name="TL13_5gbts_rac",
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

# DU1: port 3, DU2: port 4
_gnb_dus_pdu = APC(addr="10.46.139.55", port_numbers=[3, 4])
_gnb_rf1_pdu = APC(addr="10.46.139.56", port_numbers=[2])
_gnb_rf2_pdu = APC(addr="10.46.139.57", port_numbers=[6])

# eNB airscale: port 4, eNB RF: port 1
_enb_pdu = APC(addr="10.46.139.61", port_numbers=[4, 1])

# GNB DU1 ABILs
_gnb_du1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")
_gnb_du1_capu2 = CapacityUnit(addr="192.168.253.24", hardware_type="ABIL")

# GNB DU1 ASIK
_gnb_du1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.11", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb_du1_capu1, _gnb_du1_capu2],
    pdu_port=_gnb_dus_pdu.pdu_ports[3],
    hardware_type="ASIK",
)

_gnb_du1_airscale = Airscale(common_units=[_gnb_du1_comu])

_gnb_du1_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb_rf1_pdu.pdu_ports[2],
    radio_type="AEUD",
    attenuation_ports=None,
)

_gnb_du1 = DU(airscale=_gnb_du1_airscale, rus=[_gnb_du1_rm])

# GNB DU2 ABIL
_gnb_du2_capu = CapacityUnit(addr="192.168.253.36", hardware_type="ABIL")

# GNB DU2 ASIK
_gnb_du2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb_du2_capu],
    pdu_port=_gnb_dus_pdu.pdu_ports[4],
    hardware_type="ASIK",
)

_gnb_du2_airscale = Airscale(common_units=[_gnb_du2_comu])

_gnb_du2_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb_rf2_pdu.pdu_ports[6],
    radio_type="AEUD",
    attenuation_ports=None,
)

_gnb_du2 = DU(airscale=_gnb_du2_airscale, rus=[_gnb_du2_rm])

_gnb = CloudBts(
    cu=_cu,
    dus=[_gnb_du1, _gnb_du2],
    cloud_deployment=_cloud_deployment,
    vnf_name="tl13-5gbts",
)

_epcsim = EPCSim(
    mme_ip="192.168.4.2",
    mcc=311,
    mnc=489,
    tac=333,
    default_ssh_connection_details=SshServiceDetails(
        addr="kiwi313.delab3.nsn", username="dpdktests", password="qwer2009!"
    ),
    dir_path="/opt/WTS",
    cfg_filename="TL13_viavi_cfg_realLteEnb_multi_UE_mutliDRB.cfg",
    edaemon_port=22222,
    egate_port=20021,
)

_enb_capu = CapacityUnit(addr="192.168.253.36")

_enb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.4.121", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb_capu],
    pdu_port=_enb_pdu.pdu_ports[4],
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
    pdu_port=_enb_pdu.pdu_ports[1],
    radio_type=None,
    attenuation_ports=None,
)

_enb = RealEnb(system_module=_enb_airscale, rms=[_enb_rm])

_tm500_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="ul5gueapp304", username="dpdktests", password="qwer2009!"
    ),
    network_interface_address="192.168.113.1",
    iperf_path="/usr/bin/iperf",
)

_tm500 = TM500(
    tma_host=SshServiceDetails(
        addr="tmapc304.delab3.nsn", username="viavi4user", password="qwer2009!"
    ),
    tma_command_port=5003,
    pdu_port=None,
    tma_path="C:\\Program Files (x86)\\Aeroflex\\TM500\\5G NR - NLA 4.28.1\\Test Mobile Application\\TmaApplication.exe",
    iperf_details=_tm500_iperf,
    imsi="311489000000787",
    sec_key="01020304050607080910101010101001",
)

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="ul5gappserv302", username="dpdktests", password="qwer2009!"
    ),
    network_interface_address="192.168.113.1",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

# Testline
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_gnb],
    enbs=[_enb],
    cloud_hostings=[_ncir],
    core=_epcsim,
    tl_cloud_topology="CLOUD_5G_TYPE",
    pdus=[_gnb_dus_pdu, _gnb_rf1_pdu, _gnb_rf2_pdu, _enb_pdu],
    ues=[_tm500],
    appserver=_core_appserver,
)

__all__ = ["tl"]
