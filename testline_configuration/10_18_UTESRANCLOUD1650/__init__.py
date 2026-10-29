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

HW_LOCATION_CODE = "Timisoara"

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.47.40", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.47.41", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FPFH(addr="10.255.3.138", port_numbers=[1, 2, 3, 4, 5, 6], login="admin", password="admin")
_pdu_2 = FPFH(addr="10.255.3.135", port_numbers=[1, 2, 3, 4, 5, 6], login="admin", password="admin")
_pdu_3 = FPFH(addr="10.255.3.137", port_numbers=[1, 2, 3, 4, 5, 6], login="admin", password="admin")
_pdu_4 = FPFH(addr="10.255.3.138", port_numbers=[1, 2, 3, 4, 5, 6], login="admin", password="admin")
_pdu_6 = FPFH(addr="10.255.3.140", port_numbers=[1, 2, 3, 4, 5, 6], login="admin", password="admin")
_pdu_7 = FPFH(addr="10.255.3.141", port_numbers=[1, 2, 3, 4, 5, 6], login="admin", password="admin")

_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_6.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_6.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_6.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_6.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_6.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_6.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_7.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_7.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_7.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_7.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_7.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_7.pdu_ports[6].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="BL2241D50P5",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.135", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="BL2241D50PC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.134", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="BL2241D50ON",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.136", port=2323
    ),
    pdu_port=_pdu_6.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244701951",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2243N436I",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2234N41L6",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_7 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1204107321",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.158", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_8 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1204110670",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.154", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[3],
)

_rmod_9 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1204107322",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.162", port=2323
    ),
    pdu_port=_pdu_7.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1230613425",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1220101794",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="RW191801856",
)
_fsp_4 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="DH214641984",
)
_fsp_5 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1221603020",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3, _fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1240802169",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1220315227",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    oam_ip=NetworkAddress("10.15.236.50"),
    instance_id=10650,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9],
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))

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
    tl_cloud_topology="CLOUD_SRAN_NLG_10650_1ASIL_2ABIO_1ABIA_1ASIL_2ABIO_3AHLOB_3AHFII_3AEHC",
    bscs=[_bsc],
                
)

__all__ = ["tl"]
