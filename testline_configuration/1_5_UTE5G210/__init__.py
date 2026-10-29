__maintainer__ = "Huang Lei"
__email__ = "lei.10.huang@nokia-sbell.com"

import os
import yaml
import re
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline import DU
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import EPC
from taf.config.testline.pdu import FACOM, HBTE, FPFH
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.testpc import TestPc

_pdu_1 = FPFH(addr="10.108.190.47", port_numbers=[1, 2, 3, 4, 5, 6])
_pdu_2 = FPFH(addr="10.108.190.50", port_numbers=[1, 2, 3, 4, 5, 6])
_pdu_3 = FPFH(addr="10.108.190.57", port_numbers=[1, 2, 3, 4, 5, 6])
_pdu_4 = FPFH(addr="10.108.190.40", port_numbers=[1, 2, 3, 4, 5, 6])

_rmod_1 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1244910557",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251101933",
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1245007160",
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="AH250102170",
    pdu_port=_pdu_4.pdu_ports[2],
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="AH250102184",
    pdu_port=_pdu_4.pdu_ports[4],
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHLOB",
    serial_number="BL2248D518I",
    pdu_port=_pdu_4.pdu_ports[5],
)
_rmod_7 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2222N4072",
    pdu_port=_pdu_4.pdu_ports[1],
)
_rmod_8 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2221N405P",
    pdu_port=_pdu_4.pdu_ports[3],
)
_rmod_9 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2217N401N",
    pdu_port=_pdu_2.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1215008555",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184380927",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_7, _rmod_8, _rmod_9],    
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233704787",
    pdu_port=_pdu_2.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231609449",
    pdu_port=_pdu_2.pdu_ports[1],
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_lmp_connection_1 = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_lmp_connection_2 = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_fct_1 = CommonUnit(

    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233402455",
    lmp_connection=_lmp_connection_1,
)
_fct_2 = CommonUnit(

    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH244039928",
    lmp_connection=_lmp_connection_2,
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    f1_m_ip_addr="10.68.181.198",
)
_du_2 = DU(
    airscale=_smod_2,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    f1_m_ip_addr="10.68.181.198",
)
# CU
_cu = CU(
    backhaul_site_oam_ip="10.68.181.198",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.198", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(cu=_cu, dus=[_du_1])
_classical_bts_2 = ClassicalBts(cu=_cu, dus=[_du_2])

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.234", username="ute", password="ute"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.235", username="ute", password="ute"
    ),
    connections=[_classical_bts_2.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_bts_1, _classical_bts_2],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_SRAN_CLASSICAL_2ASIM_1ABIO_1ABIA_2ABIP_3xAVHA_3AHLOB_3AHFII_FULLRACK",
)
__all__ = ["tl"]
