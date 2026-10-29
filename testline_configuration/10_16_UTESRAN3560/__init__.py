# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Paulina Zachorodna"
__email__ = "paulina.zachorodna@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline import Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails
)
from taf.config.testline.testpc import TestPc, Connection


_pdu_1 = Gude(
    addr="10.42.80.119",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHBA",
    serial_number="LBALLU-YD163509MU3",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.0", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3]
)

_rmod_2 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHBA",
    serial_number="LBALLU-YD16470DAB2",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.1", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2]
)

_rmod_3 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="UHBA",
    serial_number="LBALLU-YD16460D03F",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1]
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170105494",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173110395"
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.42.150.127"),
    instance_id=100834
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.237", username="ute"), 
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1]

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_ASIA_1ABIA_3UHBA_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
