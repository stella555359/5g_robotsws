__maintainer__ = "Filip Radwanski"
__team__ = "I_5GSC_5G_PZ1_WRO_5"
__email__ = "I_5GSC_5G_PZ1_WRO_5@internal.nsn.com"
__owner_email__ = "filip.radwanski@nokia.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, Gude, PduPort
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.core import RealCore5G

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.88.164",
        v6="2a00:8a00:6000:607c::1:b629",
        vlan_id="480",
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b601/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.88.228",
        v6="2a00:8a00:6000:607c::1:b729",
        vlan_id="481",
        routing_v4=RoutingInformation(gateway="10.44.88.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b701/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.89.40",
        v6="2a00:8a00:6000:607c::1:b82d",
        vlan_id="482",
        routing_v4=RoutingInformation(gateway="10.44.89.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b801/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.89.106",
        v6="2a00:8a00:6000:607c::1:b92f",
        vlan_id="483",
        routing_v4=RoutingInformation(gateway="10.44.89.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b901/120"),
    ),
)

_cu_gnb_1.sync = NetworkAddress(
    v4="10.44.89.230",
    v6="2a00:8a00:6000:607c::1:ba2b",
    vlan_id="484",
    routing_v4=RoutingInformation(gateway="10.44.89.193/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:ba01/120"),
)

_pdu_gnb = Gude(addr="10.44.205.105", port_numbers=[8], model="EPC", version="8221-1")
_pdu_gnb_ru1 = Gude(
    addr="10.44.205.89", port_numbers=[7], model="EPC", version="8221-1"
)
_pdu_gnb_ru2 = Gude(
    addr="10.44.205.89", port_numbers=[6], model="EPC", version="8221-1"
)
_pdu_fanbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])
_pdu_gpsbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])

_pdus = [_pdu_gnb, _pdu_gnb_ru1, _pdu_gnb_ru2, _pdu_fanbreaker, _pdu_gpsbreaker]


_gnb_ru1 = RU(
    ru_hw_group="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[7],
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.33.129", port=2323),
    radio_type=RadioTypes.AHCA.value,
)

_gnb_ru2 = RU(
    ru_hw_group="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[6],
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.33.128", port=2323),
    radio_type=RadioTypes.AHCA.value,
)

_abil1_gnb_1_master = CapacityUnit(
	addr="192.168.253.20",
	rus=[_gnb_ru1, _gnb_ru2],
)

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIB",
    capacity_units=[_abil1_gnb_1_master],
    pdu_port=_pdu_gnb.pdu_ports[8],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50364, instance_id=50364
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.56", username="ute", password="P@ssword1234"
    ),
    connections=[
	 NetworkAddress(v4="192.168.255.126"),
         Connection(interface="eth1",device=_cbts.dus[0].airscale.common_units[0], interface_type="lmp")
	],
)

_pdu_enb = ATEN(addr="0.0.0.0", port_numbers=[0])

_asik_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_enb.pdu_ports[0],
)

_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])

_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    global_bts_id=40386,
    instance_id=1900,
    x2_link_addr=NetworkAddress(v4="10.44.90.92", vlan_id=487),
    oam_ip=NetworkAddress(v4="10.44.90.28", vlan_id=486),
)

_enb_1.m_plane = NetworkAddress(v4="10.44.90.28", vlan_id=486)


_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.61", username="ute", password="ute"
    ),
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIBL_ABIO_2xAHCA"

_core = RealCore5G(mcc=555, mnc=10)

tl = TestLine(
    test_pc=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_gnb_1],
    pdus=_pdus,
)

__all__ = ["tl"]
