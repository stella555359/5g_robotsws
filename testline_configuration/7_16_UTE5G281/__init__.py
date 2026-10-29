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
        v4="10.44.68.146",
        v6="2a00:8a00:6000:607c::1:ae07",
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
        v4="10.44.68.210",
        v6="2a00:8a00:6000:607c::1:af07",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.18",
        v6="2a00:8a00:6000:607c::1:b007",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.82",
        v6="2a00:8a00:6000:607c::1:b107",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b101/120"),
    ),
    ngu=NetworkAddress(
         v4="10.44.70.146",
         v6="2a00:8a00:6000:607c::1:b207",
         vlan_id=907,
         routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
         routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b201/120"
         ),
     ),
     ngc=NetworkAddress(
         v4="10.44.70.210",
         v6="2a00:8a00:6000:607c::1:b307",
         vlan_id=909,
         routing_v4=RoutingInformation(gateway="10.44.70.193/26"),
         routing_v6=RoutingInformation(
             gateway="2a00:8a00:6000:607c::1:b301/120"
         ),
     ),
    xnc=NetworkAddress(
        v4="10.44.68.210",
        v6="2a00:8a00:6000:607c::1:af07",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.70.18",
        v6="2a00:8a00:6000:607c::1:b007",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
)

_pdu_1 = Gude(
    addr="10.44.205.210",
    port_numbers=[8, 9, 10],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.44.206.158",
    port_numbers=[1, 7],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.44.205.175",
    port_numbers=[1, 9],
    model="EPC",
    version="8221-1",
)

_pdu_4 = Gude(
    addr="10.44.205.176",
    port_numbers=[2],
    model="EPC",
    version="8221-1",
)

_pdu_5 = Gude(
    addr="10.44.177.24",
    port_numbers=[6, 7],
    model="EPC",
    version="8221-1",
)

_pdu_6 = Gude(
    addr="10.44.177.26",
    port_numbers=[12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2339N49UA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=21
    ),
    pdu_port=_pdu_1.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.130", port=5001),
        ]
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9242437471",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=21
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.131", port=5001),
        ]
    ),
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="K9242437480",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=21
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.132", port=5001),
        ]
    ),
)
_rmod_4 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251600008",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.162", port=21
    ),
    pdu_port=_pdu_3.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.125", port=5001),
        ]
    ),
)
_rmod_5 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251600007",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=21
    ),
    pdu_port=_pdu_3.pdu_ports[9],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.126", port=5001),
        ]
    ),
)
_rmod_6 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1251301870",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.158", port=21
    ),
    pdu_port=_pdu_4.pdu_ports[2],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.127", port=5001),
        ]
    ),
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOB",
    serial_number="AH243706177",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.154", port=21
    ),
    pdu_port=_pdu_5.pdu_ports[6],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.136", port=5001),
        ]
    ),
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOB",
    serial_number="AH243521993",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=21
    ),
    pdu_port=_pdu_5.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.137", port=5001),
        ]
    ),
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOB",
    serial_number="AH243706174",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=21
    ),
    pdu_port=_pdu_6.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.7.138", port=5001),
        ]
    ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214208660",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104677",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1183710422",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104675",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204206293",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1213712358",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1213502827",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=50291,
    oam_ip=NetworkAddress(
       v4="10.44.68.146",
       vlan_id=903,
       routing_v4=RoutingInformation(gateway="10.44.68.129", ip_prefix_length=26),
  )
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_du_1_gnb_1 = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6])

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50291, instance_id=50291, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.149.39", username="ute", password="UTE.debian12"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(
        addr="10.44.149.48", username="ute", password="UTE.debian12"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"),
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5, _pdu_6]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_TL281_TMO-2",
    pdus=_pdus,
)

__all__ = ["tl"]
