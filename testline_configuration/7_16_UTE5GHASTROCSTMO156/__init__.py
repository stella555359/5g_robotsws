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
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.85.87/26", v6=None, vlan_id=820),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.85.87/26", v6=None, vlan_id=820),
    x2u=NetworkAddress(v4="10.44.85.87/26", v6=None, vlan_id=820),
    s1u=NetworkAddress(v4="10.44.85.87/26", v6=None, vlan_id=820),
    xnc=NetworkAddress(v4="10.44.85.87/26", v6=None, vlan_id=820),
    xnu=NetworkAddress(v4="10.44.85.87/26", v6=None, vlan_id=820),
    ngc=NetworkAddress(v4="10.44.85.87/26", v6=None, vlan_id=820),
    ngu=NetworkAddress(v4="10.44.85.87/26", v6=None, vlan_id=820),
)

_cu_gnb.m = NetworkAddress(v4="https://10.44.85.87", v6=None, vlan_id=820)

_rmod_1 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2039G1M0J",
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
    serial_number="BL2034G1HI0",
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
    serial_number="BL2039G1M2V",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu2.pdu_ports[7],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2032G1H7V",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
    ],
    pdu_port=_pdu1.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2037V0LEI",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[17],
        _attenuator.attenuator_ports[18],
        _attenuator.attenuator_ports[19],
        _attenuator.attenuator_ports[20],
    ],
    pdu_port=_pdu3.pdu_ports[3],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2037V0LC5",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu3.pdu_ports[1],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2037V0LEK",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
    ],
    pdu_port=_pdu3.pdu_ports[2],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="K9190718015",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[13],
        _attenuator.attenuator_ports[14],
        _attenuator.attenuator_ports[15],
        _attenuator.attenuator_ports[16],
    ],
    pdu_port=_pdu1.pdu_ports[3],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1254000420",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu2.pdu_ports[1],
)

_rmod_10 = RU(
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251510255",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu2.pdu_ports[11],
)

_rmod_11 = RU(
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251300677",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu2.pdu_ports[6],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="DH250612321",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_bbmod_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233802972",
    rus=[_rmod_9, _rmod_10, _rmod_11],
)

_bbmod_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233802970",
    rus=[_rmod_5, _rmod_6],
)

_bbmod_6 = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240602919",
    rus=[_rmod_7, _rmod_8],
)

_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1],
    pdu_port=_pdu4.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234311047",
)

_smod_gnb_slave_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_4, _bbmod_5, _bbmod_6],
    pdu_port=_pdu4.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234311058",
)

_smod_1 = Airscale([_smod_gnb_master_left])

_smod_2 = Airscale([_smod_gnb_slave_right])

_du_1_gnb = DU(_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])

_du_2_gnb = DU(
    _smod_2, rus=[_rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11]
)


_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=50828, global_bts_id=50828
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.158.131", username="ute", password="UTE.debian12"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_2_gnb], instance_id=50828, global_bts_id=50828
)
_lmp_vm_gnb_1_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.180.145", username="ute", password="UTE.debian12"
    ),
    connections=[_cbts_2.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ue_pc_ssh_1 = SshServiceDetails(
    addr="10.42.22.134", username="wro5grrm", password="5gpass!1"
)

_ue_pc_ssh_2 = SshServiceDetails(
    addr="10.42.72.181", username="wro5grrm", password="5gpass!1"
)

_ue_config = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "UEs.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master],
    gnbs=[_cbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_ABIP_ABIO_3xAHFII_3xAEHC_3xAHLOB_MRAT",
    core=_core,
    pdus=_pdus,
    ues=[_ue_config],
    attenuator=_attenuator,
    attenuators=[_attenuator],
)

__all__ = ["tl"]