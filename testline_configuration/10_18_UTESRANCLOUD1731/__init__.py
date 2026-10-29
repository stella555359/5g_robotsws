__maintainer__ = "Giorgia Toth"
__email__ = "giorgia.toth@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.pdu import FPFH
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
    default_ssh_connection_details=SshServiceDetails(addr="10.5.47.50", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.47.51", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.1.98",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.1.99",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_3 = FPFH(
    addr="10.255.1.181",
    port_numbers=[1, 2, 3, 4, 5, 6],
    protocol="http",

)

_pdu_4 = Gude(
    addr="10.255.1.100",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_3.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_OPENED"

_pdu_4.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.107",
    serial_number="DH240102317",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304423",
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA185173922",
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA192071874",
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171221151",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2],
    pdu_port=_pdu_4.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233302552",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3,_fsp_4,_fsp_5],
    pdu_port=_pdu_4.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH200762697",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARDB.value,
    serial_number="K9203827660",
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_2 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q190504264",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q190504564",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q172714279",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA201653441",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_6 = RU(
    ru_hw_group="cMAAr6.2a_32T32R",
    radio_type=RadioTypes.AQQF.value,
    serial_number="NQ242397713",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_7 = RU(
    ru_hw_group="cMAAr6.2a_32T32R",
    radio_type=RadioTypes.AQQF.value,
    serial_number="K9253421995",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_8 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="F7170740012",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_9 = RU(
    ru_hw_group="cMAAr6.2a_32T32R",
    radio_type=RadioTypes.AQQF.value,
    serial_number="1M222318963",
    pdu_port=_pdu_3.pdu_ports[2],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
    oam_ip=NetworkAddress("10.15.236.131"),
    instance_id=10731,
)

_bsc = BSC(
    name="BSC_ASTRA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="VRFTSR", password="VRFTSR!@"
    ),
 )
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
    ],
    master=_enb_sbts_1
)

_enb_sbts_2.slave = _enb_sbts_1

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1,_test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLG_1731_1ASIM_1ABIO_1ABIP_1ASIB_3ABIA_1ARDB_1FRGT_3AQQF_3AZNA_1AREA",
    bscs=[_bsc]
)

__all__ = ["tl"]
