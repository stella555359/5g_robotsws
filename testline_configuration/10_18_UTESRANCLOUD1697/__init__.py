__maintainer__ = "Cosmin Poenar"
__email__ = "cosmin.poenar@nokia.com"
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
    SshServiceDetails(addr="10.5.20.9", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.10", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.1.28",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.1.29",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
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
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXFC.value,
    serial_number="F7164834695",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_2 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA170783082",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.119", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA170682218",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.122", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXCB.value,
    serial_number="1M154507850",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_5 = RU(
    ru_hw_group="FRMrRH4.3_4T4R",
    radio_type=RadioTypes.FRIJ.value,
    serial_number="EA171181437",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.123", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_6 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type=RadioTypes.FRPA.value,
    serial_number="EA170710982",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.117", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_7 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXFC.value,
    serial_number="F7164834697",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.125", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_8 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXCB.value,
    serial_number="1M163503042",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.127", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171712511",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183143147",
)

_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183143005",
)

_fsp_4 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171221112",
)

_fsp_5 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170304519",
)

_fsp_6 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162601207",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171423727",
    rus=[_rmod_1, _rmod_4],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1164710716",
    rus=[_rmod_2, _rmod_3, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_4],
    oam_ip=NetworkAddress("10.15.236.97"),
    instance_id=10697,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_3, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))


_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="Nemuadmin", password="Nokia@123"
    ),
)

_bsc = BSC(
    name="BSC_ASTRA_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="TVRFTSR", password="VRFTSR!@"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LWG_10697_1ASIA_3ABIA_1ASIA_3ABIA_3FRIJ_1FRPA_2FXCB_2FXFC",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
