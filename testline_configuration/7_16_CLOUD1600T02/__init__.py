__maintainer__ = "Oleksii Mikhanchuk"
__team__ = "MN 5G RAN I&V Cloud"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "oleksii.mikhanchuk@nokia.com"


import os
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
from taf.config.testline.core import EPCSim
from taf.config.testline import LTEEmuEnb
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.pdu import PduPort, ATEN
from taf.compatibility.configuration import TestlineWrapper


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.66", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.199", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.199", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_17A")

_cbts_flavor = DeploymentFlavorStack(
    name="cloud-016-t02-FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="cloud-016-t01",
)

_cbts_net = DeploymentNetworkStack(
    name="cloud-016-t02-NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="cloud-016-t02-HEAT",
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
    backhaul_site_oam_ip="2A00:8A00:6000:607c::E740",
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::E740", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="2A00:8A00:6000:607c::E740", username="Nemuadmin", password="nemuuser"
    ),
)

_common_unit_lmp_connection = SshServiceDetails(
    addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
)

_pdu = ATEN(addr="10.44.206.109", port_numbers=list(range(2, 8)))

_common_unit_pdu_port = PduPort(pdu=_pdu, port_no=1)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_common_unit = CommonUnit(
    lmp_connection=_common_unit_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_common_unit_pdu_port,
)

_airscale = Airscale([_common_unit])

_du = DU(airscale=_airscale)

_cbts = CloudBts(
    cu=_cu, cloud_deployment=_cloud_deployment, dus=[_du], vnf_name="cloud-016-t02"
)

_epcsim = EPCSim(
    mme_ip="10.1.1.100",
    mcc=311,
    mnc=489,
    tac=333,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.21", username="ute", password="ute"
    ),
    dir_path="/home/ute/Robot_LteEmu",
    cfg_filename="Robot_LteEmu_Config",
)

_lteSim = LTEEmuEnb(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.206.79", username="ute", password="ute"
    ),
    dir_path="/home/ute/wts771",
    cfg_filename="basic_wts_step2.cfg",
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_MIN_ASIKA101_ABILA102_IPv6_BRANCH",
    cloud_hostings=[_ncir],
    core=_epcsim,
    enbs=[_lteSim],
    pdus=[_pdu],
)
tl = TestlineWrapper(tl)

__all__ = ["tl"]
