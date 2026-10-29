######################################
#  TestLine 120 Ulm                   #
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
from taf.config.testline.core import RealCore
from taf.config.testline.ue import TM500
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.47.196.120", username="admin", tenant="admin", password="UTEadmin_0"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.196.120", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.46.138.130", username="admin", password="admin"
    ),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="NCIR19A")

_gnb1_cbts_flavor = DeploymentFlavorStack(
    name="TL120_5gbts_flavors",
    env_files=[os.path.join(_CFG_DIR, "TL120_5gbts_flavor.env")],
    yaml_file="5gbts_flavor.yaml",
    default_vnf_prefix="tl120-5gbts",
)

_gnb1_cbts_net = DeploymentNetworkStack(
    name="TL120_5gbts_ext",
    env_files=[os.path.join(_CFG_DIR, "TL120_5gbts_ext.env")],
    yaml_file="5gbts_ext_net.yaml",
)

_gnb1_cbts_vnf = DeploymentVnfStack(
    name="TL120_5gbts_rac",
    env_files=[os.path.join(_CFG_DIR, "TL120_5gbts_heat.env")],
    yaml_file="5gbts_heat.yaml",
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_gnb1_cbts_flavor],
    networks=[_gnb1_cbts_net],
    vnfs=[_gnb1_cbts_vnf],
    cloud_hosting=_ncir,
)

_gnb1_cu = CU(
    backhaul_site_oam_ip="192.168.125.10",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.125.10", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.125.10", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_gnb2_cu = CU(
    backhaul_site_oam_ip="192.168.125.10",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.125.10", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.125.10", username="Nemuadmin", password="nemuuser", port=443
    ),
)

# gNB2 DU-ASOD: port B3, gNB1 DU1-ASOD: port B2, gNB1 DU2-ASIK: port B1
_gnb_dus_pdu = Gude(
    addr="10.46.133.35", port_numbers=[7, 8, 9], model="EPC", version="8221-1"
)

# gNB2 DU-ASOD AEUD: port B5, gNB1 DU1-ASOD AEUD: port , gNB1 DU2-ASIK AEUD1: port , gNB1 DU2-ASIK AEUD2: port
_gnb_rfs_pdu = Gude(
    addr="10.46.133.28", port_numbers=[11], model="EPC", version="8221-1"
)

# eNB airscale: port 4, eNB RF: port 1
_enb_pdu = Gude(addr="10.46.133.35", port_numbers=[2, 4], model="EPC", version="8221-1")

# gNB1 DU1
_gnb1_du1_capu = CapacityUnit(addr="192.168.253.20")

# gNB1 DU1 ASOD
_gnb1_du1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_du1_capu],
    pdu_port=_gnb_dus_pdu.pdu_ports[8],
    hardware_type="ASOD",
)

_gnb1_du1_airscale = Airscale(common_units=[_gnb1_du1_comu])

_gnb1_du1_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb_rfs_pdu.pdu_ports[11],
    radio_type="AEUD",
    attenuation_ports=None,
)

_gnb1_du1 = DU(airscale=_gnb1_du1_airscale, rus=[_gnb1_du1_rm])

# gNB1 DU2 ABILs
_gnb1_du2_capu1 = CapacityUnit(addr="192.168.253.36", hardware_type="ABIL")
_gnb1_du2_capu2 = CapacityUnit(addr="192.168.253.40", hardware_type="ABIL")

# gNB1 DU2 ASIK
_gnb1_du2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_du2_capu1, _gnb1_du2_capu2],
    pdu_port=_gnb_dus_pdu.pdu_ports[7],
    hardware_type="ASIK",
)

_gnb1_du2_airscale = Airscale(common_units=[_gnb1_du2_comu])

_gnb1_du2_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb_rfs_pdu.pdu_ports[11],
    radio_type="AEUD",
    attenuation_ports=None,
)

_gnb1_du2 = DU(airscale=_gnb1_du2_airscale, rus=[_gnb1_du2_rm])

_gnb1 = CloudBts(
    cu=_gnb1_cu,
    dus=[_gnb1_du1, _gnb1_du2],
    cloud_deployment=_cloud_deployment,
    vnf_name="tl120-5gbts",
)

# gNB2 DU
_gnb2_du_capu = CapacityUnit(addr="192.168.253.17")

# gNB2 DU ASOD
_gnb2_du_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb2_du_capu],
    pdu_port=_gnb_dus_pdu.pdu_ports[9],
    hardware_type="ASOD",
)

_gnb2_du_airscale = Airscale(common_units=[_gnb2_du_comu])

_gnb2_du_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb_rfs_pdu.pdu_ports[11],
    radio_type="AEUD",
    attenuation_ports=None,
)

_gnb2_du = DU(airscale=_gnb2_du_airscale, rus=[_gnb2_du_rm])

_gnb2 = CloudBts(
    cu=_gnb2_cu,
    dus=[_gnb2_du],
    cloud_deployment=_cloud_deployment,
    vnf_name="tl119-5gbts",
)

_real_core = RealCore(mcc="555", mnc="10")

_enb_capu = CapacityUnit(addr="192.168.253.36")

_enb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.200.140", username="toor4nsn", password="oZPS0POrRieRtu"
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
    pdu_port=_enb_pdu.pdu_ports[2],
    radio_type=None,
    attenuation_ports=None,
)

_enb = RealEnb(system_module=_enb_airscale, rms=[_enb_rm])

_tm500_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="ul5gueapp202", username="dpdktests", password="qwer2009!"
    ),
    network_interface_address="10.44.35.210",
    iperf_path="/usr/bin/iperf",
)

_viavi_pdu = Gude(addr="10.46.133.35", port_numbers=[12], model="EPC", version="8221-1")

_tm500 = TM500(
    tma_host=SshServiceDetails(
        addr="tmapc202.delab3.nsn", username="viavi2user", password="qwer2009!"
    ),
    tma_command_port=5003,
    pdu_port=_viavi_pdu.pdu_ports[12],
    tma_path="C:\\Program Files (x86)\\Aeroflex\\TM500\\5G NR - NLA 4.33.1\\Test Mobile Application\\TmaApplication.exe",
    iperf_details=_tm500_iperf,
    imsi="555107000000045",
    sec_key="00112233445566778899AABBCCDDEEFF",
)

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.210", username="ute", password="ute"
    ),
    network_interface_address="10.44.35.210",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

# test pcs

_gnb1_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.200.181", username="ute", password="ute"
    ),
    connections=[_gnb1],
)

_gnb2_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.200.179", username="ute", password="ute"
    ),
    connections=[_gnb2],
)

_enb_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.200.180", username="ute", password="ute"
    ),
    connections=[_enb],
)

# Testline
tl = TestLine(
    test_pc=_gnb1_test_pc,
    test_pcs=[_gnb1_test_pc, _gnb2_test_pc, _enb_test_pc],
    gnbs=[_gnb1, _gnb2],
    enbs=[_enb],
    cloud_hostings=[_ncir],
    core=_real_core,
    tl_cloud_topology="CLOUD_5G_TYPE",
    pdus=[_gnb_dus_pdu, _gnb_rfs_pdu, _enb_pdu],
    ues=[_tm500],
    appserver=_core_appserver,
)

__all__ = ["tl"]
