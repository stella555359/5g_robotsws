__maintainer__ = "Damian Silkowski"
__team__ = "MN 5G RAN I&V Cloud"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "damian.silkowski@nokia.com"


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
        addr="10.42.53.95", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.42.181.48", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.181.48", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(addr="10.42.208.201", username="admin"),
)

_ncir = NCIR(compute_nodes=[], control_nodes=[_control_0], version="ncir_19")

_cbts_flavor = DeploymentFlavorStack(
    name="TL_7_16_CLOUD031T01_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "5gbts_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_flavor.yaml"),
    default_vnf_prefix="cloud-031-t01",
)

_cbts_net = DeploymentNetworkStack(
    name="TL_7_16_CLOUD031T01_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "5gbts_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="TL_7_16_CLOUD031T01_BTS",
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
    backhaul_site_oam_ip="2A00:8A00:6000:607c::1:8104",
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::1:8104", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="[2A00:8A00:6000:607c::1:8104]", username="Nemuadmin", password="nemuuser"
    ),
)

_common_unit_lmp_connection1 = SshServiceDetails(
    addr="192.168.255.127", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lmp_connection2 = SshServiceDetails(
    addr="192.168.255.128", username="toor4nsn", password="oZPS0POrRieRtu"
)

_pdu = ATEN(addr="10.44.206.37", port_numbers=list(range(1, 8)))

_common_unit_pdu_port1 = PduPort(pdu=_pdu, port_no=6)

_common_unit_pdu_port2 = PduPort(pdu=_pdu, port_no=6)

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
    f1_c_ip_addr="2a00:8a00:6000:607c::1:1a18",
    f1_u_ip_addr="2a00:8a00:6000:607c::1:1a16",
    f1_m_ip_addr="2a00:8a00:6000:607c::1:1a17",
)

_du2 = DU(
    airscale=_airscale2,
    f1_c_ip_addr="2a00:8a00:6000:607c::1:1a23",
    f1_u_ip_addr="2a00:8a00:6000:607c::1:1a24",
    f1_m_ip_addr="2a00:8a00:6000:607c::1:1a22",
)


_cbts = CloudBts(
    cu=_cu,
    cloud_deployment=_cloud_deployment,
    dus=[_du1, _du2],
    vnf_name="cloud-031-t01",
    instance_id=50410,
    global_bts_id=50410,
)


_enb = RealEnb(x2_link_addr=NetworkAddress(v6="2A00:8A00:6000:607c::1:440"))

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_MULTIDU_ASIKA101L_ABILA102B1_IPv6",
    cloud_hostings=[_ncir],
    pdus=[_pdu],
    enbs=[_enb],
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]
