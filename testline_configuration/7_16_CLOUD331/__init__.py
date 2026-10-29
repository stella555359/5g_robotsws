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
        addr="10.44.156.49", username="ute", password="ute"
    )  # need to change VM
)

_lmp_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.1", username="ute", password="ute"
    )  # need to change VM
)
cfg_dir = os.path.dirname(os.path.abspath(__file__))

_controlNode = ControlNode(  # NCIR OK
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
_ncir = NCIR(compute_nodes=[], control_nodes=[_controlNode], version="ncir_19")

_cbts_flavor = DeploymentFlavorStack(
    name="7_16_CLOUD331_FLAVOR",  # need to change
    env_files=[os.path.join(_CFG_DIR, "5gbts_flavor.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
    default_vnf_prefix="tl331",  # need to change
)

_cbts_net = DeploymentNetworkStack(
    name="7_16_CLOUD331_EXT_NET",  # need to change
    env_files=[os.path.join(_CFG_DIR, "5gbts_ext_net.env")],
    yaml_file=os.path.join(_CFG_DIR, ""),
)

_cbts_vnf = DeploymentVnfStack(
    name="7_16_CLOUD331_BTS",  # need to change
    env_files=[os.path.join(_CFG_DIR, "5gbts_heat.env")],
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
        v4="10.44.81.10",  # need to change
        v6="2A00:8A00:6000:607c::3414",
        vlan_id=411,
        routing_v4=RoutingInformation(gateway="10.44.81.1/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3401/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.81.6", username="Nemuadmin", password="nemuuser"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="2A00:8A00:6000:607c::3414"),
    f1m=NetworkAddress(
        v4="10.44.81.23",  # need to change
        v6="2A00:8A00:6000:607c::3514",
        vlan_id=412,
        routing_v4=RoutingInformation(gateway="10.44.81.17/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3501/120"),
    ),
    f1c=NetworkAddress(
        v4="10.44.81.39",
        v6="2A00:8A00:6000:607c::3614",
        vlan_id=413,
        routing_v4=RoutingInformation(gateway="10.44.81.33/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3601/120"),
    ),
    f1u=NetworkAddress(
        v4="10.44.81.71",
        v6="2A00:8A00:6000:607c::3814",
        vlan_id=415,
        routing_v4=RoutingInformation(gateway="10.44.81.65/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3801/120"),
    ),
    x2c=NetworkAddress(
        v4="10.44.81.58",
        v6="2A00:8A00:6000:607c::3714",
        vlan_id=414,
        routing_v4=RoutingInformation(gateway="10.44.81.49/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3701/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.81.87",
        v6="2A00:8A00:6000:607c::3914",
        vlan_id=416,
        routing_v4=RoutingInformation(gateway="10.44.81.81/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3901/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.81.103",
        v6="2A00:8A00:6000:607c::3A14",
        vlan_id=417,
        routing_v4=RoutingInformation(gateway="10.44.81.97/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3A01/120"),
    ),
)

_pdu_gnb = ATEN(addr="none", port_numbers=[2])  # need to change MS

_pdu_gnb_ru = EPC(addr="none", port_numbers=[12])

_gnb_ru = RU(
    ru_hw_group="AEUB",
    default_ssh_connection_details=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="none", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[12],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(  # need to change MS
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[2],
)

_asik_gnb_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[2],  # <-----need to fill
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])
_airscale_gnb_2 = Airscale(common_units=[_asik_gnb_2])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=1),
    )
]

_du_1 = DU(
    airscale=_airscale_gnb_1,
    f1_c_ip_addr=NetworkAddress(  # need to change
        v6="2A00:8A00:6000:607c::3C14", v4="10.44.81.135", vlan_id=419
    ),
    f1_m_ip_addr=NetworkAddress(  # need to change
        v6="2A00:8A00:6000:607c::3B14", v4="10.44.81.119", vlan_id=418
    ),
    f1_u_ip_addr=NetworkAddress(  # need to change
        v6="2A00:8A00:6000:607c::3D14", v4="10.44.81.151", vlan_id=420
    ),
    f1_c_cu=NetworkAddress(
        v4="10.44.81.128",
        v6="2A00:8A00:6000:607c::3C00",
        vlan_id=419,
        routing_v4=RoutingInformation(gateway="10.44.81.129/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3601/120"),
    ),
    f1_m_cu=NetworkAddress(
        v4="10.44.81.112",
        v6="2A00:8A00:6000:607c::3B00",
        vlan_id=418,
        routing_v4=RoutingInformation(gateway="10.44.81.113/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3501/120"),
    ),
    f1_u_cu=NetworkAddress(
        v4="10.44.81.144",
        v6="2A00:8A00:6000:607c::3D00",
        vlan_id=420,
        routing_v4=RoutingInformation(gateway="10.44.81.145/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3801/120"),
    ),
    rus=[_gnb_ru],
    cablinks=_ru_cablinks,
    global_bts_id=50243,  # need to change
    instance_id=50243,  # need to change
)

_du_2 = DU(
    airscale=_airscale_gnb_1,
    f1_c_ip_addr=NetworkAddress(  # need to change
        v6="2A00:8A00:6000:607c::3C04", v4="10.44.81.137", vlan_id=419
    ),
    f1_m_ip_addr=NetworkAddress(  # need to change
        v6="2A00:8A00:6000:607c::3B04", v4="10.44.81.121", vlan_id=418
    ),
    f1_u_ip_addr=NetworkAddress(  # need to change
        v6="2A00:8A00:6000:607c::3D04", v4="10.44.81.153", vlan_id=420
    ),
    f1_c_cu=NetworkAddress(
        v4="10.44.81.128",
        v6="2A00:8A00:6000:607c::3C00",
        vlan_id=419,
        routing_v4=RoutingInformation(gateway="10.44.81.129/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3601/120"),
    ),
    f1_m_cu=NetworkAddress(
        v4="10.44.81.112",
        v6="2A00:8A00:6000:607c::3B00",
        vlan_id=418,
        routing_v4=RoutingInformation(gateway="10.44.81.113/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3501/120"),
    ),
    f1_u_cu=NetworkAddress(
        v4="10.44.81.144",
        v6="2A00:8A00:6000:607c::3D00",
        vlan_id=420,
        routing_v4=RoutingInformation(gateway="10.44.81.145/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3801/120"),
    ),
    rus=[_gnb_ru],
    cablinks=_ru_cablinks,
    global_bts_id=50245,  # need to change
    instance_id=50245,  # need to change
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.48", username="ute", password="ute"  # need to change
    )
)

_pdu_enb = ATEN(addr="None", port_numbers=[7])

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_enb.pdu_ports[7],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40241,  # need to change
    instance_id=40241,  # need to change
    x2_link_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::3715",
        v4="10.44.81.55",
        vlan_id=414,
        routing_v4=RoutingInformation(gateway="10.44.81.49/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3701/120"),
    ),
)

_enb_1.m_plane = (
    NetworkAddress(
        v6="2A00:8A00:6000:607c::3415",
        v4="10.44.81.11",
        vlan_id=411,
        routing_v4=RoutingInformation(gateway="10.44.81.1/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607c::3401/120"),
    ),
)

_cbts = CloudBts(
    cu=_cu_gnb_1,
    dus=[_du_1, _du_2],
    cloud_deployment=_cloud_deployment,
    vnf_name="tl331",  # need to change
    global_bts_id=50241,  # need to change
    instance_id=50241,  # need to change
)

_tl_cloud_topology = (
    "CLOUD_5G_MULTIDU_ASIKA101LR_ABILA101B1B4_AEUA"  # need to change MS
)


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
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_gnb_2, _lmp_vm_enb_1],
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
)

__all__ = ["tl"]
