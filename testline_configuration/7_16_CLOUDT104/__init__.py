__maintainer__ = "Piotr Oleszczyk"
__team__ = "RRM team"
__email__ = "piotr.oleszczyk@nokia.com"
__owner_email__ = "piotr.oleszczyk@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.cloud_hosting import (
    NCIR,
    ControlNode,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)
from taf.config.testline.gnb import CloudBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import EPCSim
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.compatibility.configuration import TestlineWrapper

import os

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.1", username="ute", password="ute"
    )
)

_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.1", username="admin", password="admin"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.14", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.14", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.1", username="admin", password="admin"
    ),
)

_control_1 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.14", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.14", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.1", username="admin", password="admin"
    ),
)

_ncir = NCIR(
    compute_nodes=[_compute], control_nodes=[_control_0, _control_1], version="ncir_17A"
)

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_16_CLOUD1600T01_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="C2600T01",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_16_CLOUD1600T01_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_16_CLOUD1600T01_BTS",
    env_files=[os.path.join(_CFG_DIR, "config_bts.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_bts.yaml"),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip="10.44.181.82",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.181.82", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.181.82", username="Nemuadmin", password="nemuuser"
    ),
    f1m="192.168.2.111",
    f1c="192.168.2.112",
    f1u="192.168.2.113",
    x2c="192.168.4.111",
    x2u="192.168.4.112",
    s1c="192.168.4.111",
    s1u="192.168.4.112",
    tracing=None,
)

_pdu1 = ATEN(addr="10.44.61.127", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdus = [_pdu1]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu1.pdu_ports[3],
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.102.2", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[6],
    ru_hw_group="",
    radio_type="AEUA",
)

_du1 = DU(Airscale(common_units=[_asik_du1]), rus=[_ru])

_cbts = CloudBts(
    cu=_cu, cloud_deployment=_cloud_deployment, vnf_name="c1600t01", dus=[_du1]
)

_core = EPCSim(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.1", username="ute", password="ute"
    ),
    dir_path="/opt/core",
    cfg_filename="epcsim.cfg",
    mme_ip="10.1.1.100",
    mcc=311,
    mnc=489,
    tac=788,
    edaemon_port=10000,
    egate_port=20000,
)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=_pdu1.pdu_ports[1]
)

_lteenb = RealEnb(
    airscale=Airscale(common_units=[_common_unit_lte]), x2_link_addr="10.1.1.110"
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_ASIKA101_ABILA101_AEUA_ENB",
    core=_core,
    pdus=_pdus,
    enbs=[_lteenb],
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]
