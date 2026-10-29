__maintainer__ = "Jagoda Kubacka"
__team__ = "I_MN_RAN_RD_VRF_WRO3_4"
__email__ = "I_MN_RAN_RD_VRF_WRO3_4@internal.nsn.com"
__owner_email__ = "jagoda.kubacka@nokia.com"
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

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.170",
        v6="2a00:8a00:6000:607c::1:ae09",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:ae01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.68.236",
        v6="2a00:8a00:6000:607c::1:af09",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.44",
        v6="2a00:8a00:6000:607c::1:b009",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.106",
        v6="2a00:8a00:6000:607c::1:b109",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b101/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.68.236",
        v6="2a00:8a00:6000:607c::1:af09",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.70.44",
        v6="2a00:8a00:6000:607c::1:b009",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
)

# smod port 10, 11
_pdu_1 = Gude(
    addr="10.44.206.158",
    port_numbers=[11, 10],
    model="EPC",
    version="8221-1",
)
# AEHC 1 - rm port 7
_pdu_2 = Gude(
    addr="10.44.205.176",
    port_numbers=[7],
    model="EPC",
    version="8221-1",
)

# AEHC 2, 3 - rm port 8, 12
_pdu_3 = Gude(
    addr="10.44.205.175",
    port_numbers=[8, 12],
    model="EPC",
    version="8221-1",
)

# AHLOA 1, 2, 4 - ports 9,11,10; AHFIB 1, 2, 3 - rm port 7,2,3
_pdu_4 = Gude(
    addr="10.44.177.76",
    port_numbers=[2, 3, 7, 9, 10, 11],
    model="EPC",
    version="8221-1",
)

# AHLOA 3 - rm port 12
_pdu_5 = Gude(
    addr="10.44.177.75",
    port_numbers=[12],
    model="EPC",
    version="8221-1",
)

_pdu_6 = Gude(
    addr="10.44.177.178",
    port_numbers=[6],
    model="EPC",
    version="8221-1",
)

# AHFIB 4 - port 7
_pdu_7 = Gude(
    addr="10.44.205.210",
    port_numbers=[7],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2043V0PX2",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=21
    ),
    pdu_port=_pdu_4.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.139", port=5001),
        ]
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL1923V0A6O",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=21
    ),
    pdu_port=_pdu_4.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.140", port=5001),
        ]
    ),
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9190720655",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=21
    ),
    pdu_port=_pdu_4.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.141", port=5001),
        ]
    ),
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1933G104Q",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=21
    ),
    pdu_port=_pdu_4.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.143", port=5001),
        ]
    ),
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1933G101A",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=21
    ),
    pdu_port=_pdu_4.pdu_ports[11],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.144", port=5001),
        ]
    ),
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1934G10VM",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.134", port=21
    ),
    pdu_port=_pdu_5.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.145", port=5001),
        ]
    ),
)
_rmod_10 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2045V0S8Q",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" 172.16.33.129", port=21
    ),
    pdu_port=_pdu_7.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.142", port=5001),
        ]
    ),
)
_rmod_11 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1933G104J",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.135", port=21
    ),
    pdu_port=_pdu_4.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.146", port=5001),
        ]
    ),
)
_rmod_4 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="L1204110698",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.38", port=21
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.147", port=5001),
        ]
    ),
)
_rmod_5 = RU(
    ru_hw_group="cMAArChile_64T64Rz",
    radio_type="AEHC",
    serial_number="L1204708700",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.42", port=21
    ),
    pdu_port=_pdu_3.pdu_ports[8],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.148", port=5001),
        ]
    ),
)
_rmod_6 = RU(
    ru_hw_group="cMAArChile_64T64Rz",
    radio_type="AEHC",
    serial_number="K9223130046",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.46", port=21
    ),
    pdu_port=_pdu_3.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.149", port=5001),
        ]
    ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231800018",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204109000",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_10],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193679281",
    rus=[_rmod_7, _rmod_8, _rmod_9, _rmod_11],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233105995",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204505524",
    rus=[],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503558",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="475765A.102",
    serial_number="L1230613816",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11],
    instance_id=50279,
    oam_ip=NetworkAddress(
       v4="10.44.68.170",
       vlan_id=459,
       routing_v4=RoutingInformation(gateway="10.44.65.65", ip_prefix_length=26),
  )
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_5, _rmod_6],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_du_1_gnb_1 = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_7, _rmod_8, _rmod_9, _rmod_11])

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50279, instance_id=50279, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.149.38", username="ute", password="UTE.debian12"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(
        addr="10.44.149.28", username="ute", password="UTE.debian12"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"),
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5, _pdu_6, _pdu_7]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_CLASSICAL_SRAN_NL_2ASIM_2ABIP_2ABIO_1ABIA_3xAHFIB_3xAEHC_3xAHLOA_TMO-1",
    pdus=_pdus,
)

__all__ = ["tl"]
