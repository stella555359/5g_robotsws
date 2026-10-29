# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Cornelia Cozma"
__email__ = "cornelia.cozma@nokia.com"


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

_test_pc = TestPc(
    SshServiceDetails(addr="10.5.20.135", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.3.96", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.3.97", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXJB.value,
    serial_number="K9171311794",
    default_telnet_connection_details=TelnetConnectionDetails(
       addr="172.16.10.128", port=2323   
    ),
    pdu_port=_pdu_2.pdu_ports[3],
 )   
_rmod_2 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="K9234700027",
    default_telnet_connection_details=TelnetConnectionDetails(
       addr="172.16.37.128", port=2323   
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="K9234700100",
    default_telnet_connection_details=TelnetConnectionDetails(
       addr="172.16.37.129", port=2323   
    ),
    pdu_port=_pdu_2.pdu_ports[2],                           
 )
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="L1185108484",
    default_telnet_connection_details=TelnetConnectionDetails(
       addr="172.16.37.130", port=2323   
    ),
    pdu_port=_pdu_2.pdu_ports[4],                          
 )
_rmod_5 = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    radio_type=RadioTypes.AEQW.value,
    serial_number="1M222318947",
    default_telnet_connection_details=TelnetConnectionDetails(
       addr="172.22.9.154", port=2323   
    ),
    pdu_port=_pdu_2.pdu_ports[6],                          
)
_rmod_6 = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    radio_type=RadioTypes.AEQW.value,
    serial_number="1M222318959",
    default_telnet_connection_details=TelnetConnectionDetails(
       addr="172.22.9.158", port=2323   
    ),
    pdu_port=_pdu_2.pdu_ports[5],        
)

_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171221110",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="DH234521950",
)

_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="RW190402318",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1242114510",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_smod_1 = Airscale([_fct_1])
                            
_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.175"),
    instance_id=10775,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))

_bsc = BSC(
    name="BSC_ASTRA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="SYSTEM", password="SYSTEM"
    ),
)
tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_NLG_1775_1ASIB_2ABIA_1ABIO_1FXJB_2AZNA_1AREA_2AEQW",
    bscs=[_bsc]
)

__all__ = ["tl"]
