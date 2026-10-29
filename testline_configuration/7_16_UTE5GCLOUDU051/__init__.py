# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Igor Kleschenok"
__email__ = "igor.kleschenok@nokia.com"
__owner_email__ = "igor.kleschenok@nokia.com"
__team__ = "pz2wro3"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import RRB

_pdu_1 = Gude("10.42.61.238", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2208V0XE2",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1922V00CT",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9184922741",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9190907511",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2015G1ALA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2016G1ANO",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163517795",
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163606700",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173007587",
    rus=[_rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173007588",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1203604607",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203605165",
    rus=[_rmod_1, _rmod_2],
)
_fsp_7 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1192408889",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5, _fsp_6, _fsp_7],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="EA193954771",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173423640",
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173104648",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
_smod_3 = Airscale([_fct_3])


_du_1 = DU(_smod_1)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.207.200"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=4030, instance_id=4030)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
    ],
    oam_ip=NetworkAddress("10.44.207.136"),
    global_bts_id=11249,
    instance_id=11249,
)

_enb_sbts_3 = RealEnb(
    system_module=_smod_3,
    rms=[
        _rmod_4,
        _rmod_5,
        _rmod_6,
    ],
    master=_enb_sbts_2,
)

_enb_sbts_2.slave = _enb_sbts_3

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.158", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnbs_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.156.243", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_3 = TestPc(
    SshServiceDetails(addr="10.44.156.246", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_3.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts_2, _enb_sbts_3],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIK_3xABIL_3xAHFIB_3xAHLOA_ENB_UTECA",
    pdus=[_pdu_1],
)

__all__ = ["tl"]
