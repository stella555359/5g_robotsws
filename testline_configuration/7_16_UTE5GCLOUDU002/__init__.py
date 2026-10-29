__maintainer__ = "lukasz.parzybut@nokia.com"
__email__ = "lukasz.parzybut@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.47", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.149.79", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

pdu_1 = Gude("10.44.205.134", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", version="8220-1") #A2,A3
pdu_2 = Gude("10.44.205.130", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", version="8221-1") #B2 AEQV
pdu_4 = Gude("10.44.205.184", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", version="8221-1")# B3 FHKA B5 AHEH

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1184014345",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1190810674",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1184003370",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101493",
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183943076",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1201102948",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="475266A.101",
    serial_number="L1204101493",
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AEQV,
    serial_number="1M201206006",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.48.162", port=2323
    ),
    pdu_port=pdu_2.pdu_ports[7],
)

_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEH,
    serial_number="EA203856871",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.128", port=2323
    ),
    pdu_port=pdu_4.pdu_ports[11],
)

_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.FHKA,
    serial_number="EA180150783",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=pdu_4.pdu_ports[9],
)


_du_1 = DU(_smod_1, rus=[_rmod_1])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.95.93"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.95.29",
    ),
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.44.95.94"),
    global_bts_id=3627,
    instance_id=3627,
)

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=2002, instance_id=2002)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
    gnbs=[_gnbs_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABILB1_ABILB2_ABILB3_AHLOA_AEQV",
    pdus=[pdu_1, pdu_2, pdu_4],
)

__all__ = ["tl"]
