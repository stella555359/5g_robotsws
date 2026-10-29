__maintainer__ = "Damian Siwa"
__team__ = "TRSSEC"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"

import os
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
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.11", username="ute", password="ute"
    )
)

_controlNode = ControlNode(
    open_stack_connection_details=OpenStackConnectionDetails(
        ip_addr="10.44.181.191", username="admin", tenant="admin", password="uteadmin"
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.181.191", username="wrsroot", password="uteadmin"
    ),
    bmc_connection_details=BmcConnectionDetails(
        addr="10.42.210.208", username="admin", password="admin"
    ),
)

_compute = ComputeNode(
    bmc_connection_details=BmcConnectionDetails(
        addr="1.1.1.1", username="admin", password="admin"
    )
)
_ncir = NCIR(compute_nodes=[_compute], control_nodes=[_controlNode], version="ncir_19")

_cbts_flavor = DeploymentFlavorStack(
    name="7_16_CLOUD069_FLAVOR",
    env_files=[os.path.join(_CFG_DIR, "config_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="c002tl69",
)

_cbts_net = DeploymentNetworkStack(
    name="7_16_CLOUD069_EXT_NET",
    env_files=[os.path.join(_CFG_DIR, "config_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="7_16_CLOUD069_BTS",
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
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2A00:8A00:6000:607c::3404",
        vlan_id=411,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3401/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::3404", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="2A00:8A00:6000:607c::3404"),
    f1m=NetworkAddress(
        v6="2A00:8A00:6000:607c::3504",
        vlan_id=412,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3B01/120"),
    ),
    f1c=NetworkAddress(
        v6="2A00:8A00:6000:607c::3604",
        vlan_id=413,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3C01/120"),
    ),
    f1u=NetworkAddress(
        v6="2A00:8A00:6000:607c::3804",
        vlan_id=415,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3D01/120"),
    ),
    x2c=NetworkAddress(
        v6="2A00:8A00:6000:607c::3704",
        vlan_id=414,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3701/120"),
    ),
    x2u=NetworkAddress(
        v6="2A00:8A00:6000:607c::3904",
        vlan_id=416,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3901/120"),
    ),
    s1u=NetworkAddress(
        v6="2A00:8A00:6000:607c::3A04",
        vlan_id=417,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3A01/120"),
    ),
)

_pdu_gnb = ATEN(addr="10.44.206.111", port_numbers=[3])

_pdu_gnb_ru = EPC(addr="none", port_numbers=[12])

_gnb_ru = RU(
    ru_hw_group="AEUA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.102.2", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[12],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[3],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=1),
    ),
]

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    f1_c_ip_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::3C04", v4="10.44.81.132", vlan_id=419
    ),
    f1_m_ip_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::3B04", v4="10.44.81.116", vlan_id=418
    ),
    f1_u_ip_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::3D04", v4="10.44.81.148", vlan_id=420
    ),
    f1_c_cu=NetworkAddress(
        v6="2A00:8A00:6000:607c::3C00",
        vlan_id=419,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3601/120"),
    ),
    f1_m_cu=NetworkAddress(
        v6="2A00:8A00:6000:607c::3B00",
        vlan_id=418,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3501/120"),
    ),
    f1_u_cu=NetworkAddress(
        v6="2A00:8A00:6000:607c::3D00",
        vlan_id=420,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3801/120"),
    ),
    rus=[_gnb_ru],
    cablinks=_ru_cablinks,
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="ute", password="ute"
    )
)

_pdu_enb = ATEN(addr="None", port_numbers=[7])

_asik_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_enb.pdu_ports[7],
)

_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40208,
    instance_id=40208,
    x2_link_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::3705",
        v4="10.44.81.53",
        vlan_id=414,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3705/120"),
    ),
)

_enb_1.m_plane = (
    NetworkAddress(
        v6="2A00:8A00:6000:607c::3405",
        v4="10.44.81.5",
        vlan_id=411,
        routing=RoutingInformation(gateway="2A00:8A00:6000:607c::3401/120"),
    ),
)

_cbts = CloudBts(
    cu=_cu_gnb_1,
    dus=[_du_1_gnb_1],
    cloud_deployment=_cloud_deployment,
    vnf_name="c002tl69",
    global_bts_id=50208,
    instance_id=50208,
)

_tl_cloud_topology = "CLOUD_5G_LB_ASIKA101_ABILA102_SA"


_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)


_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=540, mnc=1)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_enb_1],
)

__all__ = ["tl"]
