__maintainer__ = "Maciej Haladewicz"
__team__ = "Pz 2 WRO 7 SG"
__email__ = "maciej.haladewicz@nokia.com"
__owner_email__ = "maciej.haladewicz@nokia.com"

import os
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.ue import MediaTek
from taf.config.testline.connection_details import (
    SshServiceDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.appserver import AppServer
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.core import RealCore
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb


_pdu1 = Gude(addr="10.44.205.226", port_numbers=[9], model="EPC", version="8221-1")

_pdu2 = Gude(addr="10.44.205.229", port_numbers=[7, 8, 10], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2]

#dummy attenuator
_attenuator = TopYoung(
    ip_addr="10.42.221.144",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.207.238/26", v6=None, vlan_id=724),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.207.238/26", v6=None, vlan_id=724),
    x2u=NetworkAddress(v4="10.44.207.238/26", v6=None, vlan_id=724),
    s1u=NetworkAddress(v4="10.44.207.238/26", v6=None, vlan_id=724),
    xnc=NetworkAddress(v4="10.44.207.238/26", v6=None, vlan_id=724),
    xnu=NetworkAddress(v4="10.44.207.238/26", v6=None, vlan_id=724),
    ngc=NetworkAddress(v4="10.44.207.238/26", v6=None, vlan_id=724),
    ngu=NetworkAddress(v4="10.44.207.238/26", v6=None, vlan_id=724),
)

_cu_gnb.m = NetworkAddress(v4="https://10.44.207.238", v6=None, vlan_id=724),

_rmod_1 = RU(
    ru_hw_group="",
    radio_type="AVQL",
    serial_number="L1233304837",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu2.pdu_ports[7],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2231V05JG",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu2.pdu_ports[10],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type="AQQE",
    serial_number="L1215106573",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu2.pdu_ports[8],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400412",
    rus=[_rmod_3],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1180417985",
    rus=[_rmod_2],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233206255",
    rus=[_rmod_1],
)

_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2, _bbmod_3],
    pdu_port=_pdu1.pdu_ports[9],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1191006745",
)

_smod_1 = Airscale([_smod_gnb_master_left])

_du_1_gnb = DU(_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3])

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=55088, global_bts_id=55088
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.294.24", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ue_pc_ssh = SshServiceDetails(
    addr="10.42.22.101", username="wro5grrm", password="5gpass!1"
)

_ue_config = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "nokia_ue.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master],
    gnbs=[_cbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIO_ABIA_ABIQ_AVQL_AHFIB_AQQE",
    core=_core,
    pdus=_pdus,
    ues=[_ue_config],
    attenuator=_attenuator,
    attenuators=[_attenuator],
)

__all__ = ["tl"]
