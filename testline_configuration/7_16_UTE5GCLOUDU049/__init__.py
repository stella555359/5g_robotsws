__maintainer__ = "Igor Kleschenok"
__email__ = "igor.kleschenok@nokia.com"
__owner_email__ = "igor.kleschenok@nokia.com"
__team__ = "pz2wro3"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import RRB

_pdu_1 = Gude("10.44.205.135", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.205.184", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.44.177.17", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1AS5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9183920900",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1ASA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2235W2EW8",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2247W2NV3",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="K9203119567",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_7 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1213401831",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.26", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_8 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1213401832",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.30", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_9 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1213401833",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.34", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214209176",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171213696",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234301768",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234301766",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233409523",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233503240",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.207.168"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=2004, instance_id=20003)
_gnb_2 = ClassicalBts(cu=_cu, dus=[_du_2], master=_gnb_1)

_gnb_1.slave = _gnb_2

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
    ],
    oam_ip=NetworkAddress("10.44.207.168"),
    global_bts_id=2004,
    instance_id=2004,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_bsc = BSC(
    name="BSC_mcBSC34",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.44.139.2", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.20", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.149.46", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_1, _gnb_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_2xASIL_ABIA_4xABIO_3xAEHC_3xAHFIG_3xAHLOA_ENB_UTECA",
    pdus=[_pdu_1, _pdu_2, _pdu_3],
)

__all__ = ["tl"]
