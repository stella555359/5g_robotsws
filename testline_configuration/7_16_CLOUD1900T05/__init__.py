__maintainer__ = "Artur Tabaka"
__team__ = "MN 5G RAN I&V 3 Pz Autom 1 SG"
__email__ = "I_CV_WRO_AUTOTEAM@internal.nsn.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import NetworkAddress
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
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.enb import LTEEmuEnb
from taf.config.testline.pdu import ATEN

import os

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.25", username="ute", password="ute"
    )
)

_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.230", username="admin", password="admin"
    )
)

_control_0 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.44.149.37", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.37", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.233", username="admin", password="admin"
    ),
)

_control_1 = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.44.149.37", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.37", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.44.196.232", username="admin", password="admin"
    ),
)

_ncir = NCIR(
    compute_nodes=[_compute], control_nodes=[_control_0, _control_1], version="ncir_18"
)

_cbts_flavor = DeploymentFlavorStack(
    name="c02605_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_flavor.yaml"),
    default_vnf_prefix="C026T05",
)

_cbts_net = DeploymentNetworkStack(
    name="c02605_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, "config_ext_net.yaml"),
)

_cbts_vnf = DeploymentVnfStack(
    name="c02605_BTS",
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
    backhaul_site_oam_ip=NetworkAddress(v6="2A00:8A00:6000:607c::1:4A7c"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::1:4A7c", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="2A00:8A00:6000:607c::1:4A7c", username="Nemuadmin", password="nemuuser"
    ),
    f1m=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4B7c",
        vlan_id=799,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:5101", ip_prefix_length=120
        ),
    ),
    f1c=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4C7c",
        vlan_id=800,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:5201", ip_prefix_length=120
        ),
    ),
    f1u=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4E7c",
        vlan_id=802,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:5301", ip_prefix_length=120
        ),
    ),
    x2c=NetworkAddress(v6="2A00:8A00:6000:607c::1:4D7c", vlan_id=801),
    x2u=NetworkAddress(v6="2A00:8A00:6000:607c::1:4D7d", vlan_id=802),
    s1u=NetworkAddress(v6="2A00:8A00:6000:607c::1:4D7d", vlan_id=803),
    tracing=None,
)

_pdu1 = ATEN(addr="10.44.206.128", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdu2 = EPC(addr="10.44.206.150", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])

_pdus = [_pdu1, _pdu2]

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu1.pdu_ports[1],
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.102.2", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[12],
    ru_hw_group="",
    radio_type="",
)

_du1 = DU(
    Airscale(common_units=[_asik_du1]),
    f1_c_ip_addr=NetworkAddress(v6="2A00:8A00:6000:607c::1:527c"),
    f1_m_ip_addr=NetworkAddress(v6="2A00:8A00:6000:607c::1:517c"),
    f1_u_ip_addr=NetworkAddress(v6="2A00:8A00:6000:607c::1:537c"),
    f1_c_cu=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:5200",
        vlan_id=784,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4C01", ip_prefix_length=120
        ),
    ),
    f1_m_cu=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:5100",
        vlan_id=783,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4B01", ip_prefix_length=120
        ),
    ),
    f1_u_cu=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:5300",
        vlan_id=785,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4E01", ip_prefix_length=120
        ),
    ),
    rus=[_ru],
)

_cbts = CloudBts(
    cu=_cu, cloud_deployment=_cloud_deployment, vnf_name="C026T05", dus=[_du1]
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    tl_cloud_topology="CLOUD_5G_ASIKA101L_ABILA102B1",
    pdus=_pdus,
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]
