__maintainer__ = ""
__team__ = ""
__email__ = "@internal.nsn.com"

import os
from taf.config.testline.cloud_hosting import ControlNode, NCIR, CloudDeployment
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
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore4G

__all__ = ["tl"]

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.22", username="ute", password="ute"
    )
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_controlNode = ControlNode(
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

_ncir = NCIR(compute_nodes=[], control_nodes=[_controlNode], version="ncir_18")

_cloud_deployment = CloudDeployment(default_cfg_dir=cfg_dir, cloud_hosting=_ncir)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4A34",
        vlan_id=776,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4A01", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="2A00:8A00:6000:607c::1:4A34", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="2A00:8A00:6000:607c::1:4A34"
    ),
    f1m=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4B34",
        vlan_id=777,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4B01", ip_prefix_length=120
        ),
    ),
    f1c=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4C34",
        vlan_id=778,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4C01", ip_prefix_length=120
        ),
    ),
    f1u=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4E34",
        vlan_id=778,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4E01", ip_prefix_length=120
        ),
    ),
    x2c=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4D34",
        vlan_id=779,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4D01", ip_prefix_length=120
        ),
    ),
    x2u=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4F34",
        vlan_id=779,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4F01", ip_prefix_length=120
        ),
    ),
    s1c=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4D35",
        vlan_id=779,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4D01", ip_prefix_length=120
        ),
    ),
    s1u=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:5034",
        vlan_id=779,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:5001", ip_prefix_length=120
        ),
    ),
)

_pdu_gnb = ATEN(addr="1.1.1.1", port_numbers=[3])

_pdu_gnb_ru = EPC(addr="10.44.206.150", port_numbers=[12])

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

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    f1_c_ip_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:5234",
        vlan_id=784,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:5201", ip_prefix_length=120
        ),
    ),
    f1_m_ip_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:5134",
        vlan_id=783,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:5101", ip_prefix_length=120
        ),
    ),
    f1_u_ip_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:5334",
        vlan_id=785,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:5301", ip_prefix_length=120
        ),
    ),
    rus=[_gnb_ru],
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
    capacity_units=[],
    pdu_port=_pdu_enb.pdu_ports[7],
)

_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=1900,
    instance_id=1900,
    x2_link_addr=NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4D36",
        vlan_id=779,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4D01", ip_prefix_length=120
        ),
    ),
)

_enb_1.m_plane = (
    NetworkAddress(
        v6="2A00:8A00:6000:607c::1:4A34",
        vlan_id=776,
        routing=RoutingInformation(
            gateway="2A00:8A00:6000:607c::1:4A01", ip_prefix_length=120
        ),
    ),
)

_cbts = CloudBts(
    cu=_cu_gnb_1,
    dus=[_du_1_gnb_1],
    cloud_deployment=_cloud_deployment,
    vnf_name="C026T02",
    global_bts_id=1900,
    instance_id=1900,
)

_tl_cloud_topology = "CLOUD_5G_ASIKL_ABILB1_AEUA_ENB"

_core = RealCore4G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    cloud_hostings=[_ncir],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_enb_1],
)
