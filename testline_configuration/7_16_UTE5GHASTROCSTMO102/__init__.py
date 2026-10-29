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


__maintainer__ = "Michal Wabich"
__team__ = "RRM1 team"
__email__ = "michal.wabich@nokia.com"
__owner_email__ = "michal.wabich@nokia.com"


_pdu1 = Gude(
    addr="10.44.177.108",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu2 = Gude(
    addr="10.44.177.123",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdus = [_pdu1, _pdu2]

_attenuator = TopYoung(
    ip_addr="10.42.54.154",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.229.144/26", v6=None, vlan_id=674),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.229.208/26", v6=None, vlan_id=675),
    x2u=NetworkAddress(v4="10.44.230.16/26", v6=None, vlan_id=676),
    s1u=NetworkAddress(v4="10.44.230.80/26", v6=None, vlan_id=677),
    xnc=NetworkAddress(v4="10.44.229.208/26", v6=None, vlan_id=675),
    xnu=NetworkAddress(v4="10.44.230.16/26", v6=None, vlan_id=676),
    ngc=NetworkAddress(v4="10.44.230.208/26", v6=None, vlan_id=679),
    ngu=NetworkAddress(v4="10.44.230.80/26", v6=None, vlan_id=677),
)

_cu_gnb.m = NetworkAddress(v4="https://10.44.229.144", v6=None, vlan_id=674)

_rmod_1 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2317N4522",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[9],
        _attenuator.attenuator_ports[10],
        _attenuator.attenuator_ports[11],
        _attenuator.attenuator_ports[12],
    ],
    pdu_port=_pdu1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2240N42OB",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[21],
        _attenuator.attenuator_ports[22],
        _attenuator.attenuator_ports[23],
        _attenuator.attenuator_ports[24],
    ],
    pdu_port=_pdu1.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2240N42MY",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu1.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9224908423",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
    ],
    pdu_port=_pdu2.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9224908451",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[17],
        _attenuator.attenuator_ports[18],
        _attenuator.attenuator_ports[19],
        _attenuator.attenuator_ports[20],
    ],
    pdu_port=_pdu2.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="K9222600545",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu1.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2240D50O9",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
    ],
    pdu_port=_pdu1.pdu_ports[7],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="BL2228D500O",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator.attenuator_ports[13],
        _attenuator.attenuator_ports[14],
        _attenuator.attenuator_ports[15],
        _attenuator.attenuator_ports[16],
    ],
    pdu_port=_pdu1.pdu_ports[8],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="	BL2241D50PN",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu1.pdu_ports[9],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004080",
    rus=[_rmod_2, _rmod_3, _rmod_7, _rmod_8, _rmod_9],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204008341",
    rus=[_rmod_1],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004110",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2],
    pdu_port=_pdu1.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503231",
)

_smod_gnb_slave_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_3],
    pdu_port=_pdu1.pdu_ports[11],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503230",
)

_smod_1 = Airscale([_smod_gnb_master_left])

_smod_2 = Airscale([_smod_gnb_slave_right])

_du_1_gnb = DU(_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_7, _rmod_8, _rmod_9])

_du_2_gnb = DU(_smod_2, rus=[_rmod_4, _rmod_5, _rmod_6])


_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=55102, global_bts_id=55102
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.110", username="ute", password="ute"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

# _cbts_2 = ClassicalBts(
#     cu=_cu_gnb, dus=[_du_2_gnb], instance_id=55102, global_bts_id=55102
# )
#
# _lmp_vm_gnb_1_slave = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.44.149.110", username="ute", password="ute"
#     ),
#     connections=[_cbts_2.dus[0].airscale.common_units[0]],
# )

_core = RealCore5G(mcc=310, mnc=260)

_ue_pc_ssh_1 = SshServiceDetails(
    addr="10.42.224.43", username="wro5grrm", password="5gpass!1"
)

_ue_pc_ssh_2 = SshServiceDetails(
    addr="10.42.224.44", username="wro5grrm", password="5gpass!1"
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
