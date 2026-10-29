__maintainer__ = "Andrzej Kulmacz"
__team__ = "MN 5G RAN I&V 7 Prodzn SiSo"
__email__ = "andrzej.kulmacz@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)
from taf.config.testline import RealEnb, Enb
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import EPCSim
from taf.config.testline.pdu import ATEN, Gude
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.gnb.networkaddress import NetworkAddress

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc_ssh = SshServiceDetails(addr="10.42.158.184", username="ute", password="ute")

_test_pc = TestPc(default_ssh_connection_details=_test_pc_ssh)

_enb_pdu = Gude(addr="1.44.206.6", port_numbers=[11])

_ru_pdu = ATEN(addr="1.44.206.7", port_numbers=[4])

_ru = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_ru_pdu.pdu_ports[4],
)

_capacity_unit = CapacityUnit(addr="192.168.253.22")

_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_enb_pdu.pdu_ports[11]
)

_airscale = Airscale([_common_unit])

_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.175", username="admin", password="admin"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.89", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.89", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="1.1.1.1", username="admin", password="admin"
    ),
)

_control_1 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.89", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.89", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="1.1.1.1", username="admin", password="admin"
    ),
)

_ncir = NCIR(compute_nodes=[_compute], control_nodes=[_control_0], version="ncir_18")

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_16_CLOUD2700T01_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="c2710",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_16_CLOUD2700T01_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_16_CLOUD2700T01_BTS",
    env_files=[os.path.join(_CFG_DIR, "config_bts.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip="10.42.55.224",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.55.224", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.55.224", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(airscale=_airscale, rus=[_ru])

_cbts = CloudBts(
    cu=_cu, dus=[_du], cloud_deployment=_cloud_deployment, vnf_name="c2710"
)

_core = EPCSim(
    mme_ip="10.1.1.100",
    mcc=555,
    mnc=10,
    tac=61,
    default_ssh_connection_details=_test_pc_ssh,
    dir_path="/opt/core",
    cfg_filename="epcsim.cfg",
)

_lteenb = RealEnb(airscale=_du, x2_link_addr=NetworkAddress(v4="10.1.1.7"))

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_lteenb],
    ues=None,
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_ASIKA101L_ABILA101B1_ABILA101B2_AEUB",
    core=_core,
    pdus=[_enb_pdu, _ru_pdu],
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]
