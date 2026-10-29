__maintainer__ = "Daniel Cozma"
__email__ = "daniel.cozma@nokia.com"
__owner_email__ = "mihai.rusu@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

import os
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import TafUeAndroid

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.53", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.54", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.1.144",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.255.1.143",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M162062609",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXEB.value,
    serial_number="1M164728527",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU.value,
    serial_number="K9170305334",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="K9234700038",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.123", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q190823885",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.125", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q191212044",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA194854728",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA192071630",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA194751063",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1164604263",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="RW192103339",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.92"),
    instance_id=10692,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_5, _rmod_6],
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.27.141.158"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.141.158", username="Nemuadmin", password="systeM123!"
    ),
)

_bsc = BSC(
    name="BSC_DHARANI",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.126.20", username="SYSTEM", password="SYSTEM"
    ),
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LWG_10692_1ASIA_2ABIA_1ASIA_1ABIA_1FRGU_1FXDB_1FXEB_1AZNB_2AZNA",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
