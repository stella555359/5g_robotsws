__maintainer__ = "Barbier Jean-Michel"
__team__ = "MN 5G RAN I&V 1 Pz 1 SG"
__email__ = "I_UTE_NPS_5G@internal.nsn.com"


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
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.pdu import PduPort, ATEN
from taf.compatibility.configuration import TestlineWrapper


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.28.0.3", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.14.62.160",
        username="wrsroot",
        tenant="admin",
        password="uteadmin5G!",
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.62.160", username="wrsroot", password="uteadmin5G!"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="", username="", password=""),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_17A")

_cbts_flavor = DeploymentFlavorStack(
    name="7_20_CLOUD5GPSIV012_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="cv12",
)

_cbts_net = DeploymentNetworkStack(
    name="7_20_CLOUD5GPSIV012_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="7_20_CLOUD5GPSIV012_BTS",
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
    backhaul_site_oam_ip="10.14.48.12",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.12", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.48.12", username="Nemuadmin", password="nemuuser"
    ),
)

_common_unit_lmp_connection = SshServiceDetails(
    addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
)

_pdu = ATEN(addr="10.5.114.247", port_numbers=list(range(1, 9)))

_common_unit_pdu_port = PduPort(pdu=_pdu, port_no=1)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_common_unit = CommonUnit(
    lmp_connection=_common_unit_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_common_unit_pdu_port,
)

_airscale = Airscale([_common_unit])

_du = DU(airscale=_airscale)

_cbts = CloudBts(cu=_cu, cloud_deployment=_cloud_deployment, dus=[_du], vnf_name="cv12")

_epcsim = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.58.253", username="ute", password="ute"
    ),
    dir_path="/opt/lteemu",
    cfg_filename="basic_cfg_LteEmu.csssssfg",
    mme_ip="192.168.4.134",
    mcc=-1,
    mnc=-1,
    tac=-1,
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_MIN_ASIKA101_ABILA102_18A",
    cloud_hostings=[_ncir],
    core=_epcsim,
    pdus=[_pdu],
)
tl = TestlineWrapper(tl)

__all__ = ["tl"]
