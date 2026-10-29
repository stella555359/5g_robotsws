__maintainer__ = "Rafał Sytyk"
__team__ = "I_5GSC_5G_PZ1_WRO_9"
__email__ = "I_5GSC_5G_PZ1_WRO_9@internal.nsn.com"
__owner_email__ = "rafal.sytyk@nokia.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.attenuator import JFW
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, PduPort, Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.core import RealCore4G


cfg_dir = os.path.dirname(os.path.abspath(__file__))

_attenuator = JFW(
    ip_addr="10.42.54.193",
    port=3001,
    attenuation_port_numbers=[9, 10, 11, 12],
    model="50PA-717",
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.85.111",
        v6="2a00:8a00:6000:607c::1:605e",
        vlan_id=820,
        routing_v4=RoutingInformation(gateway="10.44.85.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6001/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.85.166",
        v6="2a00:8a00:6000:607c::1:615e",
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.85.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6101/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.76.180",
        v6="2a00:8a00:6000:607c::1:6237",
        vlan_id=822,
        routing_v4=RoutingInformation(gateway="10.44.76.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6201/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.76.248",
        v6="2a00:8a00:6000:607c::1:6339",
        vlan_id=823,
        routing_v4=RoutingInformation(gateway="10.44.76.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6301/120"),
    ),
)

_pdu_gnb = Gude(addr="10.44.205.14", port_numbers=[12], model="EPC", version="8221-1")
_pdu_gnb_ru1 = Gude(
    addr="10.44.205.14", port_numbers=[2], model="EPC", version="8221-1"
)

_pdu_gnb_ru2 = Gude(addr="10.44.205.14", port_numbers=[11], model="EPC", version="8221-1"
)

_pdu_gnb_ru3 = Gude(addr="10.44.206.162", port_numbers=[5], model="EPC", version="8221-1"
)
_pdu_fanbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])
_pdu_gpsbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])


_pdus = [
    _pdu_gnb,
    _pdu_gnb_ru1,
    _pdu_gnb_ru2,
    _pdu_gnb_ru3,
    _pdu_fanbreaker,
    _pdu_gpsbreaker,
]

_gnb_ru1 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[2],
    radio_type=RadioTypes.AHLOA.value,
)

_gnb_ru2 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.53", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[5],
    radio_type=RadioTypes.AHLOA.value,
)

_gnb_ru3 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.54", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[11],
    radio_type=RadioTypes.AHLOA.value,
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20",
                                   rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3],
                                   )

_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIK",
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50370, instance_id=50370
)


_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.168", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1",device=_cbts.dus[0].airscale.common_units[0], interface_type="lmp")
    ]
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIKL_ABILB1_3xAHLOA"

_core = RealCore4G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_gnb_1],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
