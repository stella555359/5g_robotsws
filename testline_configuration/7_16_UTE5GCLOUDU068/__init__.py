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
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.core import RealCore, RealCore5GDetails
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN, APC
from taf.config.testline.appserver import TafUeAppServer, AppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid, TafUeMtk, MediaTek
from taf.config.testline.pdn import PDN, PDPTypes, PDNTafUeAndroidDetails
from taf.config.testline.pdu import RRB

# Testline config variables

_pdu_1 = Gude("10.44.205.142", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.205.130", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.44.205.188", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_4 = Gude("10.44.205.131", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_5 = Gude("10.44.177.221", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

#RMODs (WebEM teminal: radio-modules-ls)
_rmod_1 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA,
    serial_number="BL2344H645V",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQL,
    serial_number="L1230314345",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGC,
    serial_number="EA210351029",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type=RadioTypes.AHIB,
    serial_number="AH192600782",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB,
    serial_number="BL2215V0177",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA,
    serial_number="BL2345H649G",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[10],
)
_rmod_7 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA,
    serial_number="BL2344H6481",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[12],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHSB,
    serial_number="RW234101012",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

#BBMODs (via toor4nsn: rio-ip FSPx)
#In ASIL Master
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173716156",
    rus=[_rmod_3, _rmod_5],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233003914",
    rus=[_rmod_3, _rmod_4, _rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400409",
    rus=[_rmod_8],
)
#In ASIL Slave
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233003922",
    rus=[_rmod_2],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171716681",
    rus=[_rmod_1, _rmod_6, _rmod_7],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1234102916",
    rus=[_rmod_1, _rmod_6, _rmod_7],
)

#SYSMODS
#ASIL Master
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224805770",
)
#ASIL Slave
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224805771",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.207.173"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=55202, instance_id=55202)
_gnb_2 = ClassicalBts(cu=_cu, dus=[_du_2], master=_gnb_1)

_gnb_1.slave = _gnb_2

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_8,
    ],
    oam_ip=NetworkAddress("10.44.207.173"),
    global_bts_id=55202,
    instance_id=8623,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_6,
        _rmod_7,
    ],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.57", username="ute"),
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
    SshServiceDetails(addr="10.44.156.59", username="ute"),
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_2xASIL_ABIO_2xABIA_3xABIQ_AHEGC_AHFIB_AHIB_AHSB_AQQL_3xAHEGHA",
    pdus=[_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5],
)

__all__ = ["tl"]
