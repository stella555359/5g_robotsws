__maintainer__ = "Oleksandr Kulieshov"
__email__ = "oleksasndr.kulieshov@nokia.com"
__owner_email__ = "oleksasndr.kulieshov@nokia.com"
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

_pdu_1 = Gude("10.44.205.206", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.44.205.188", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.44.205.205", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_4 = Gude("10.44.177.85", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAIB.value,
    serial_number="BL2107I276E",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAFB.value,
    serial_number="YK183800098",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[10],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAIB.value,
    serial_number="BL2107I2779",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAFB.value,
    serial_number="BL2031H23HQ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAFB.value,
    serial_number="BL2019H206T",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.135", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AAIB.value,
    serial_number="BL2105I26XY",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.133", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164005769",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173003823",
    rus=[_rmod_3, _rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.23",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1163102111",
    rus=[_rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_3.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171604368",
)

_smod_1 = Airscale([_fct_1])



_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1,_rmod_2,_rmod_3,_rmod_4,_rmod_5,_rmod_6],
    oam_ip=NetworkAddress("10.44.207.154"),
    global_bts_id=8059,
    instance_id=8059,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.136", username="ute", password="uteUTE!"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIA_ABIA_FULLRACK_AAIB_AAFB_AHLOA_ENB",
    pdus=[_pdu_1, _pdu_2, _pdu_3, _pdu_4],
)

__all__ = ["tl"]
