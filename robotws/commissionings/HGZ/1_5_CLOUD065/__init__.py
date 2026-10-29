__owner__ = "Sheng Haoyun"
__maintainer__ = "Sheng Haoyun"
__email__ = "haoyun-lyle.sheng@nokia-sbell.com"

import os
import re
import yaml
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline import DU
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.airscale import CommonUnit, CapacityUnit

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.213", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = FPFH(
    addr="10.56.7.171",
    port_numbers=[6],
    model="fpfh",
)

_pdu_2 = FACOM(
    addr="10.69.66.101",
    port_numbers=[2, 3, 4],
    model="facom",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1171910337",
    pdu_port=_pdu_1.pdu_ports[6],
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1190601880",
    capacity_units=[_fsp_1],
)

_airscale = Airscale([_fct_1])

_cu = CU(
    backhaul_site_oam_ip="10.56.7.94",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.7.94", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.7.94", username="Nemuadmin", password="nemuuser"
    ),
)


_ru_1 = RU(
    ru_hw_group="AWHHF:CPRI_A_RRH_4T4R",
    serial_number="EB2019R0635",
    pdu_port=_pdu_2.pdu_ports[2],
)

_ru_2 = RU(
    ru_hw_group="AWHHD:CPRI_A_RRH_4T4R",
    serial_number="EB1947R0024",
    pdu_port=_pdu_2.pdu_ports[3],
)

_ru_3 = RU(
    ru_hw_group="AWHHD:CPRI_A_RRH_4T4R",
    serial_number="EB1947R0026",
    pdu_port=_pdu_2.pdu_ports[4],
)

_du = DU(
    airscale=_airscale,
    rus=[
        _ru_1,
        _ru_2,
        _ru_3,
    ],
    f1_m_ip_addr="10.56.7.94",
)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_classical_bts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBL_ABIAB1_1xAWHHF_2xAWHHD",
)

__all__ = ["tl"]
