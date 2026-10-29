__maintainer__ = "Maciej Nowak"
__team__ = "MN 5G&SC 5G Pz I&V 7 Wro 3"
__email__ = "maciej.1.nowak@nokia.com"
__owner_email__ = "maciej.1.nowak@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.core import EPCSim
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

__all__ = ["tl"]

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc_ssh = SshServiceDetails(addr="10.42.53.110", username="ute", password="ute")

_test_pc = TestPc(default_ssh_connection_details=_test_pc_ssh)

##Enb
_enb_pdu = Gude(addr="10.44.206.16", port_numbers=[10], model="EPC", version="8220-1")

##RU
_ru_pdu = ATEN(addr="10.44.206.17", port_numbers=[1])

_ru = RU(
    ru_hw_group="5Ggen4_HighF_8T8R",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.49", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_ru_pdu.pdu_ports[1],
)

_capacity_unit = CapacityUnit(addr="192.168.253.22")

_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_enb_pdu.pdu_ports[10]
)

_airscale = Airscale([_common_unit])

_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.175", username="admin", password="admin"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.42.55.138", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.55.138", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.175", username="admin", password="admin"
    ),
)

_control_1 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.42.55.138", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.55.138", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.208.140", username="admin", password="admin"
    ),
)

_ncir = NCIR(control_nodes=[_control_0], compute_nodes=[_compute], version="ncir_17A")

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_16_CLOUD5G1800T08_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="c1800-t08",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_16_CLOUD5G1800T08_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_16_CLOUD5G1800T08_BTS",
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
    backhaul_site_oam_ip="10.42.55.138",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.55.138", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.55.138", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(airscale=_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_core = EPCSim(
    mme_ip="10.1.1.100",
    mcc="555",
    mnc="10",
    tac=61,
    default_ssh_connection_details=_test_pc_ssh,
    dir_path="/opt/core",
    cfg_filename="epcsim.cfg",
)

_lteenb = RealEnb(airscale=_airscale, x2_link_addr=NetworkAddress(v4="10.1.1.7"))

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_lteenb],
    ues=None,
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_ASIKA101L_ABILA102B1_AEUB_BRANCH_eCPRI",
    core=_core,
    pdus=[_enb_pdu, _ru_pdu],
)
