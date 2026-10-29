__maintainer__ = "Katarzyna Meinhardt"
__team__ = "I_MN_RAN_RD_VRF_WRO3_4"
__email__ = "I_MN_RAN_RD_VRF_WRO3_4@internal.nsn.com"
__owner_email__ = "katarzyna.meinhardt@nokia.com"
__customer__ = "TMO"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails, HttpConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.dcap import DcapBasic
from taf.config.testline import RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU, DU                                   
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.lmi import SerialOverTcp, Remote
                                                     
cfg_dir = os.path.dirname(os.path.abspath(__file__))

# ************************************************ PDUs ************************************************

# smod port 12-ASIB, 9-ASIL1
_pdu_1 = Gude(
    addr="10.44.206.158",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# smod port 4-ASIL2
_pdu_2 = Gude(
    addr="10.44.177.75",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port 1-AHLOA3, 4-AEHC3, 10-AEHC2, 12-AHLOA1
_pdu_3 = Gude(
    addr="10.44.177.24",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

# rm port 10-AHFIB3, 11-AHFIB1, 12-AHFIB2
_pdu_4 = Gude(
    addr="10.44.177.128",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port 9-AHLOA2
_pdu_5 = Gude(
    addr="10.44.205.176",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# rm port 7-AEHC1
_pdu_6 = Gude(
    addr="10.44.205.175",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5, _pdu_6]

# ************************************************ RMs *************************************************

_ahloa1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1933G1YMP",
    pdu_port=_pdu_3.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.129", port=5001),
        ]
    ),
)

_ahloa2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1919G10HT",
    pdu_port=_pdu_5.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.130", port=5001),
        ]
    ),
)

_ahloa3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1934G10UX",
    pdu_port=_pdu_3.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.131", port=5001),
        ]
    ),
)

_ahfib1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.133", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2006V03LP",
    pdu_port=_pdu_4.pdu_ports[11],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.132", port=5001),
        ]
    ),
)

_ahfib2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.133", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL1919V00CG",
    pdu_port=_pdu_4.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.133", port=5001),
        ]
    ),
)

_ahfib3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.131", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL1910V00XO",
    pdu_port=_pdu_4.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.128", port=5001),
        ]
    ),
)

_aehc1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.26", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="AH244903261",
    pdu_port=_pdu_6.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.122", port=5001),
        ]
    ),
)

_aehc2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.26", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="L1204708724",
    pdu_port=_pdu_3.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.123", port=5001),
        ]
    ),
)

_aehc3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.34", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="AH244903268",
    pdu_port=_pdu_3.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.124", port=5001),
        ]
    ),
)


# ************************************************ ENB1 ************************************************

# ASIB
_abia3 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193577689",
    rus=[_ahloa1, _ahloa2, _ahloa3],
)
_abia2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172903755",
    rus=[_ahfib3],
)
_abia1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183143158",
    rus=[_ahfib1, _ahfib2],
)

_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH204667670",
    capacity_units=[_abia1, _abia2, _abia3],
    pdu_port=_pdu_1.pdu_ports[12],
)
_airscale_asib = Airscale(common_units=[_asib])
_real_asib = RealEnb(
    system_module=_airscale_asib,
    rms=[_ahfib1, _ahfib2, _ahfib3, _ahloa1, _ahloa2, _ahloa3],
)


# ************************************************ GNB1-DUALASIL ************************************************

_abio3_l = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1210302292",
    rus=[_ahfib1, _ahfib2, _ahfib3],
)
_abil2_l = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1183608721",
    rus=[_ahloa3],
)
_abil1_l = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1183608721",
    rus=[_ahloa1, _ahloa2],
)
_abip1_r = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231811001",
    rus=[_aehc1, _aehc2, _aehc3],
)

_asil1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[_abil1_l, _abil2_l, _abio3_l],
    pdu_port=_pdu_1.pdu_ports[9],
)
_asil2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[_abip1_r],
    pdu_port=_pdu_2.pdu_ports[4],
)

_airscale_asil1 = Airscale(common_units=[_asil1])
_airscale_asil2 = Airscale(common_units=[_asil2])

_du_asil1 = DU(
    airscale=_airscale_asil1,
    rus=[_ahfib1, _ahfib2, _ahfib3, _ahloa1, _ahloa2, _ahloa3, _aehc1, _aehc2, _aehc3],
)
_du_asil2 = DU(
    airscale=_airscale_asil2,
    rus=[_ahfib1, _ahfib2, _ahfib3, _ahloa1, _ahloa2, _ahloa3, _aehc1, _aehc2, _aehc3],
)

_cu_asils = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.151",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.44.68.215", v6="", vlan_id=904),
    x2u=NetworkAddress(v4="10.44.70.20", v6="", vlan_id=905),
    s1u=NetworkAddress(v4="10.44.70.84", v6="", vlan_id=906),
)

_classical_asil1 = ClassicalBts(
    dus=[_du_asil1], cu=_cu_asils, instance_id=50204, global_bts_id=50204
)
_classical_asil2 = ClassicalBts(
    dus=[_du_asil2],
    cu=_cu_asils,
    instance_id=50204,
    global_bts_id=50204,
    master=_classical_asil1,
)
_classical_asil1.slave = _classical_asil2


# ************************************************ VMs ************************************************

# ASIL node1
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.90", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_airscale_asil1.common_units[0],
            interface_type="lmp",
        )
    ],
)

# ASIL node2 primary
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.91", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_airscale_asil2.common_units[0],
            interface_type="lmp",
        )
    ],
)

# ASIB node3 secondary
_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.77", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_real_asib.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)


# ************************************************ SUM ************************************************


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_classical_asil1, _classical_asil2],
    tl_cloud_topology="CLOUD_SRAN_TL282_TMO-3",
    pdus=_pdus,
    enbs=[_real_asib],
)

__all__ = ["tl"]
