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
)
from taf.config.testline.gnb import CloudBts, CU, DU
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.pdu import PduPort, ATEN
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline import NetworkAddress, RealEnb


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.66", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.167", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.167", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="10.42.208.201", username="admin"),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_18")

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_16_CLOUD029T02_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "5gbts_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_flavor.yaml"),
    default_vnf_prefix="cloud-029-t02",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_16_CLOUD029T02_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "5gbts_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_16_CLOUD029T02_BTS",
    env_files=[os.path.join(_CFG_DIR, "5gbts_heat.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_heat.yaml"),
)

_cloud_deployment = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor],
    networks=[_cbts_net],
    vnfs=[_cbts_vnf],
    cloud_hosting=_ncir,
)

_cu = CU(
    backhaul_site_oam_ip="10.44.78.20",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.78.20", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.78.20", username="Nemuadmin", password="nemuuser"
    ),
)

_common_unit_lmp_connection1 = SshServiceDetails(
    addr="192.168.255.127", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lmp_connection2 = SshServiceDetails(
    addr="192.168.255.128", username="toor4nsn", password="oZPS0POrRieRtu"
)

_pdu = ATEN(addr="10.44.206.109", port_numbers=list(range(1, 8)))

_common_unit_pdu_port1 = PduPort(pdu=_pdu, port_no=2)

_common_unit_pdu_port2 = PduPort(pdu=_pdu, port_no=4)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_common_unit1 = CommonUnit(
    lmp_connection=_common_unit_lmp_connection1,
    capacity_units=[_capacity_unit],
    pdu_port=_common_unit_pdu_port1,
)

_common_unit2 = CommonUnit(
    lmp_connection=_common_unit_lmp_connection2,
    capacity_units=[_capacity_unit],
    pdu_port=_common_unit_pdu_port2,
)

_airscale1 = Airscale([_common_unit1])
_airscale2 = Airscale([_common_unit2])

_du1 = DU(
    airscale=_airscale1,
    f1_c_ip_addr="10.44.207.143",
    f1_u_ip_addr="10.44.207.144",
    f1_m_ip_addr="10.44.207.142",
)

_du2 = DU(
    airscale=_airscale2,
    f1_c_ip_addr="10.44.207.146",
    f1_u_ip_addr="10.44.207.147",
    f1_m_ip_addr="10.44.207.145",
)

_cbts = CloudBts(
    cu=_cu,
    cloud_deployment=_cloud_deployment,
    dus=[_du1, _du2],
    vnf_name="cloud-029-t02",
    instance_id=50409,
    global_bts_id=50409,
)

_enb = RealEnb(x2_link_addr=NetworkAddress(v4="10.44.75.196"))

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_MIN_ASIKA101_ABILA102",
    cloud_hostings=[_ncir],
    pdus=[_pdu],
    enbs=[_enb],
)
tl = TestlineWrapper(tl)

__all__ = ["tl"]
