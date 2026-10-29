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


__maintainer__ = "Daniel Szymak"
__team__ = "RRM1 team"
__email__ = "daniel.szymak@nokia.com"
__owner_email__ = "daniel.szymak@nokia.com"


_pdu1 = Gude(
    addr="10.44.177.207",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.205.108",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu3 = ATEN(
    addr="10.44.205.203",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_pdu4 = ATEN(
    addr="10.44.200.236",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4]

_attenuator = TopYoung(
    ip_addr="10.42.61.141",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.85.79/26", v6=None, vlan_id=820),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.85.79/26", v6=None, vlan_id=820),
    x2u=NetworkAddress(v4="10.44.85.79/26", v6=None, vlan_id=820),
    s1u=NetworkAddress(v4="10.44.85.79/26", v6=None, vlan_id=820),
    xnc=NetworkAddress(v4="10.44.85.79/26", v6=None, vlan_id=820),
    xnu=NetworkAddress(v4="10.44.85.79/26", v6=None, vlan_id=820),
    ngc=NetworkAddress(v4="10.44.85.79/26", v6=None, vlan_id=820),
    ngu=NetworkAddress(v4="10.44.85.79/26", v6=None, vlan_id=820),
)

_cu_gnb.m = NetworkAddress(v4="https://10.44.85.79", v6=None, vlan_id=820)

_rmod_1 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1934G10WU",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[9],
        _attenuator.attenuator_ports[10],
        _attenuator.attenuator_ports[11],
        _attenuator.attenuator_ports[12],
    ],
    pdu_port=_pdu2.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1934G10W9",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[21],
        _attenuator.attenuator_ports[22],
        _attenuator.attenuator_ports[23],
        _attenuator.attenuator_ports[24],
    ],
    pdu_port=_pdu2.pdu_ports[9],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1934G10WX",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu2.pdu_ports[7],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1184006121",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1],
    pdu_port=_pdu4.pdu_ports[5],
    hardware_type="ASIK",
    hardware_version="474021A.101",
    serial_number="L1182514162",
)

_smod_1 = Airscale([_smod_gnb_master_left])

_du_1_gnb = DU(_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3])

_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=50074, global_bts_id=50074
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.180.13", username="ute", password="UTE.debian12"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ue_pc_ssh_1 = SshServiceDetails(
    addr="10.42.22.134", username="wro5grrm", password="5gpass!1"
)

_ue_pc_ssh_2 = SshServiceDetails(
    addr="10.42.72.181", username="wro5grrm", password="5gpass!1"
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master],
    gnbs=[_cbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIK_ABIK_3xAHLOA",
    core=_core,
    pdus=_pdus,
    attenuator=_attenuator,
    attenuators=[_attenuator],
)

__all__ = ["tl"]
