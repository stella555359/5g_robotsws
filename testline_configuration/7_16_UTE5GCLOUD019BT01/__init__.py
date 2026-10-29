__maintainer__ = "Krystian Kazmierczak"
__team__ = "MN 5G RAN I&V Cloud"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "krystian.kazmierczak@nokia.com"


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
    DeploymentSecurityGroupStack,
)
from taf.config.testline.gnb import CloudBts, CU, DU
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.pdu import PduPort, ATEN
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline import NetworkAddress, RealEnb


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.23", username="ute", password="ute"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.45.185.85",
        username="admin",
        tenant="admin",
        password="UByhxKN9u2R4RBXz7HEwqgNJr",
        version="v3",
        protocol="http",
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.185.84", username="stack", password="stack"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr=" 10.42.235.13", username="admin", password="admin"
    ),
)

_ncir_0 = NCIR(compute_nodes=[], control_nodes=[_control_0], version="osp_10")

_cbts_flavor_0 = DeploymentFlavorStack(
    name="TL_7_16_UTE5GCLOUD019BT01_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "5gbts_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_flavor.yaml"),
    default_vnf_prefix="c19b-5gbts",
)

_cbts_net_0 = [
    DeploymentNetworkStack(
        name="TL_7_16_UTE5GCLOUD019BT01_EXT_NET",
        env_files=[os.path.join(_CFG_DIR, "5gbts_ext_net.env")],
        yaml_file=os.path.join(_CFG_DIR, "5gbts_ext_net.yaml"),
    ),
    DeploymentNetworkStack(
        name="TL_7_16_UTE5GCLOUD019BT01_INT_NET",
        env_files=[os.path.join(_CFG_DIR, "5gbts_int_net.env")],
        yaml_file=os.path.join(_CFG_DIR, "5gbts_int_net.yaml"),
    ),
    DeploymentNetworkStack(
        name="TL_7_16_UTE5GCLOUD019BT01_OAM_NET",
        env_files=[os.path.join(_CFG_DIR, "5gbts_oam_net.env")],
        yaml_file=os.path.join(_CFG_DIR, "5gbts_oam_net.yaml"),
    ),
]

_cbts_sec_0 = DeploymentSecurityGroupStack(
    name="TL_7_16_UTE5GCLOUD019BT01_SECURITY_GROUP",
    env_files=[os.path.join(_CFG_DIR, "5gbts_security_group.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_security_group.yaml"),
)

_cbts_vnf_0 = DeploymentVnfStack(
    name="TL_7_16_UTE5GCLOUD019BT01_BTS",
    env_files=[os.path.join(_CFG_DIR, "5gbts_heat.env")],
    yaml_file=os.path.join(_CFG_DIR, "5gbts_heat.yaml"),
)

_cloud_deployment_0 = CloudDeployment(
    default_cfg_dir=_CFG_DIR,
    flavors=[_cbts_flavor_0],
    networks=_cbts_net_0,
    vnfs=[_cbts_vnf_0],
    security_groups=[_cbts_sec_0],
    cloud_hosting=_ncir_0,
)

_cu_0 = CU(
    backhaul_site_oam_ip="2a00:8a00:6000:607c::fd05",
    oam_ssh_connection_details=SshServiceDetails(
        addr="2a00:8a00:6000:607c::fd05", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="[2a00:8a00:6000:607c::fd05]", username="Nemuadmin", password="nemuuser"
    ),
)

_common_unit_lmp_connection1 = SshServiceDetails(
    addr="192.168.255.127", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lmp_connection2 = SshServiceDetails(
    addr="192.168.255.128", username="toor4nsn", password="oZPS0POrRieRtu"
)

_pdu1 = ATEN(addr="10.44.206.37", port_numbers=list(range(1, 8)))

_pdu2 = ATEN(addr="10.44.206.38", port_numbers=list(range(1, 8)))

_common_unit_pdu_port1 = PduPort(pdu=_pdu2, port_no=3)

_common_unit_pdu_port2 = PduPort(pdu=_pdu2, port_no=4)

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
    f1_c_ip_addr=NetworkAddress(v6="2A00:8A00:6000:607c::f040"),
    f1_u_ip_addr=NetworkAddress(v6="2A00:8A00:6000:607c::f041"),
    f1_m_ip_addr=NetworkAddress(v6="2A00:8A00:6000:607c::f042"),
)

_du2 = DU(
    airscale=_airscale2,
    f1_c_ip_addr=NetworkAddress(v6="2A00:8A00:6000:607c::f060"),
    f1_u_ip_addr=NetworkAddress(v6="2A00:8A00:6000:607c::f061"),
    f1_m_ip_addr=NetworkAddress(v6="2A00:8A00:6000:607c::f062"),
)

_cbts_0 = CloudBts(
    cu=_cu_0,
    cloud_deployment=_cloud_deployment_0,
    dus=[_du1, _du2],
    vnf_name="c19b-5gbts",
    instance_id=50415,
    global_bts_id=50415,
)

_enb = RealEnb(x2_link_addr=NetworkAddress(v6="2A00:8A00:6000:607c::5004"))

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts_0],
    tl_cloud_topology="CLOUD_5G_OSP_4xCOMP_MULTIDU_ASIKL_ABILB1_ECPRI_AEUD_IPv6",
    cloud_hostings=[_ncir_0],
    pdus=[_pdu1, _pdu2],
    enbs=[_enb],
)
tl = TestlineWrapper(tl)

__all__ = ["tl"]
