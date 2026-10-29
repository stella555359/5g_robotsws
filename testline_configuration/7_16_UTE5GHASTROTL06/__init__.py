__maintainer__ = "Grzegorz Slowinski"
__team__ = "RRM1 team"
__email__ = "grzegorz.slowinski@nokia.com"
__owner_email__ = "grzegorz.slowinski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.flexi import Flexi
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.ue import Android
from taf.config.testline.attenuator import TopYoung, JFW


_pdu_gnb = Gude(
    addr="10.44.177.53",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_gnb_ru = Gude(
    addr="10.44.177.139",
    port_numbers=[1, 2],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_gnb, _pdu_gnb_ru]

_attenuator1 = TopYoung(
    ip_addr="10.42.221.152",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_attenuator2 = JFW(
    ip_addr="10.42.61.4",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4],
    model="50PA-717",
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.85.121/26", v6=None, vlan_id=50),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.85.161/26", v6=None, vlan_id=50),
    x2u=NetworkAddress(v4="10.44.76.157/26", v6=None, vlan_id=50),
    s1u=NetworkAddress(v4="10.44.76.208/26", v6=None, vlan_id=50),
    xnc=NetworkAddress(v4="10.44.85.161/26", v6=None, vlan_id=50),
    xnu=NetworkAddress(v4="10.44.76.157/26", v6=None, vlan_id=50),
    ngc=NetworkAddress(v4="10.44.84.234/26", v6=None, vlan_id=50),
    ngu=NetworkAddress(v4="10.44.76.208/26", v6=None, vlan_id=50),
    tracing=None,
)

_cu_gnb_1.m = NetworkAddress(v4="https://10.44.85.121", v6=None, vlan_id=50)

_gnb_ru_1 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1213401828",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_gnb_ru_2 = RU(
    ru_hw_group="",
    radio_type="AEHC",
    serial_number="L1211203216",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)


_bbmod_1_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1205002456",
    rus=[],
)

_bbmod_2_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211302998",
    rus=[_gnb_ru_1],
)

_bbmod_3_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211506424",
    rus=[_gnb_ru_2],
)

_smod_gnb_1 = CommonUnit(
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1203606154",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1_gnb_1, _bbmod_2_gnb_1, _bbmod_3_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[3],
)

_airscale_gnb_1 = Airscale([_smod_gnb_1])

_du_1_gnb = DU(_airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb], instance_id=50004, global_bts_id=50004
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.54", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIO_2xAEHC",
    core=_core,
    pdus=_pdus,
    ues=[_ues],
    attenuator=_attenuator1,
    test_pcs=[_lmp_vm_gnb_1],
)

__all__ = ["tl"]
