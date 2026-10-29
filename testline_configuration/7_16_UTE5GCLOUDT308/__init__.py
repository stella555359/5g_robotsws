__maintainer__ = "Tomasz Sobania"
__team__ = "MN RAN RD VRF WRO2 8"
__email__ = "tomasz.sobania@nokia.com"
__owner_email__ = "tomasz.sobania@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
    IperfDataTransferIperfOptions,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdu import Gude


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=540, mnc=1)

_pdu1 = Gude(
    addr="10.44.205.85",
    port_numbers=[5, 6, 10, 12],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.205.115",
    port_numbers=[8, 9, 10, 11],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.205.114",
    port_numbers=[6],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2, _pdu3]

_ue_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails("10.44.72.7", "wro5grrm", password="5gpass!1", port=22))


_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1914V00JD",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[10],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1923V00GE",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.35", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[6],
)


_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1926V0E1T",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.36", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[8],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH211900808",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.37", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[9],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH211900810",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.38", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[11],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1204505680",
    rus=[_rmod_1, _rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1204505669",
    rus=[_rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508069",
    rus=[_rmod_4, _rmod_5],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164416944",
    rus=[_rmod_1, _rmod_2],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162808081",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1242008360",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1242008356",
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu1.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="A.104",
    serial_number="L1184400933",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
_smod_3 = Airscale([_fct_3])

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.20",
        v6="2a00:8a00:6000:607c::2a14",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.224.1"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2a01"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.224.20", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.84",
        v6="2a00:8a00:6000:607c::2b14",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2b01"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.148",
        v6="2a00:8a00:6000:607c::2c14",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2c01"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.212",
        v6="2a00:8a00:6000:607c::2d14",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.212",
        v6="2a00:8a00:6000:607c::2d14",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
)

_cu.m = NetworkAddress(
    v4="10.44.224.20",
    v6="2a00:8a00:6000:607c::2a14",
    vlan_id=915,
    routing=RoutingInformation(gateway="10.44.224.1"),
    routing_v6=RoutingInformation(
        gateway="2a00:8a00:6000:607c::2a01"
    ),
)

_cu.sync = NetworkAddress(
    v4="10.44.225.20",
    v6="2a00:8a00:6000:607c::2e14",
    vlan_id=919,
    routing=RoutingInformation(gateway="10.44.225.1"),
    routing_v6=RoutingInformation(
        gateway="2a00:8a00:6000:607c::2e01"
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=50829, instance_id=50829)
_gnb_2 = ClassicalBts(cu=_cu, dus=[_du_2])

_enb_1 = RealEnb(
    system_module=_smod_3,
    rms=[_rmod_1, _rmod_2, _rmod_1],
    oam_ip=NetworkAddress("10.44.225.148"),
    x2_link_addr=NetworkAddress(
        v4="10.44.225.148",
        v6="2a00:8a00:6000:607c::3114",
        vlan_id=922,
        routing=RoutingInformation(gateway="10.44.225.193"),
    ),
    global_bts_id=40829,
    instance_id=40829,
)

_enb_1.m = NetworkAddress(
    v4="10.44.225.148",
    v6="2a00:8a00:6000:607c::3014",
    vlan_id=921,
    routing=RoutingInformation(gateway="10.44.225.129"),
)

_attenuator_1 = TopYoung(
    ip_addr="10.42.54.153",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_attenuator_2 = TopYoung(
    ip_addr="10.42.54.9",
    port=3001,
    attenuation_port_numbers=[5, 6, 9, 10, 11, 12, 13, 14, 15, 16],
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.178.12", username="ute"),
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
    SshServiceDetails(addr="10.44.178.46", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)


_test_pc_3 = TestPc(
    SshServiceDetails(addr="10.44.178.13", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_android_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_realcore_appsrvv = TafUeAppServer(
    app_server_name='APP_1',
    address='10.45.168.53',
    user='5g',
    password='2019H@slo',
)

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrvv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    bind_ue_ip='10.42.197.170'
)

_qualcomm = TafUeAndroid(
    ssh_connection_details=_ue_pc.default_ssh_connection_details,
    ue_pc_address="10.44.72.7",
    serial_number="9bbd4220",
    capabilities=["REAL_ANDROID_UE"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
)

tl = TestLine(
    test_pc=[_test_pc_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_2xASIL_3xAHFIB_2xAZHL_RFS",
    gnbs=[_gnb_1, _gnb_2],
    enbs=[_enb_1],
    core=_core,
    pdus=_pdus,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    ues=[_qualcomm],
)

__all__ = ["tl"]
