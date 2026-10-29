__maintainer__ = "Tomasz_Sobania"
__team__ = "5G_PZ_2_WRO_8_SG"
__email__ = "tomasz.sobania@nokia.com"
__owner_email__ = "tomasz.sobania@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.lmi import SerialOverTcp, Remote


cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.205.87",
    port_numbers=[2, 3, 4, 7, 9],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.205.114",
    port_numbers=[8],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA205252694",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.13", port=5001),
        ]
    ),
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA205252696",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.12", port=5001),
        ]
    ),
)

_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="EA205155147",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[8],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.11", port=5001),
        ]
    ),
)

_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="F7163620974",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508100",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173006989",
    rus=[_rmod_4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1204402818",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu1.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173012644",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du = DU(_smod_1)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.11",
        v6="2a00:8a00:6000:607c::2a0b",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.224.1"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2a0b"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.224.11", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.224.75",
        v6="2a00:8a00:6000:607c::2b0b",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2b01"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.139",
        v6="2a00:8a00:6000:607c::2c0b",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2c01"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.203",
        v6="2a00:8a00:6000:607c::2d0b",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.203",
        v6="2a00:8a00:6000:607c::2d0b",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50824, instance_id=50824)

_enb_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4],
    oam_ip=NetworkAddress("10.44.225.139"),
    x2_link_addr=NetworkAddress(
        v4="10.44.225.139",
        v6="2a00:8a00:6000:607c::300b",
        vlan_id=922,
        routing_v4=RoutingInformation(gateway="10.44.225.193"),
    ),
    global_bts_id=40824,
    instance_id=40824,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.141", username="ute"),
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
    SshServiceDetails(addr="10.44.149.142", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails("10.44.72.16", "wro5grrm", password="5gpass!1")

_realcore_appsrv = TafUeAppServer(app_server_name='APP_1',
                                  address='10.45.168.53',
                                  user='5g',
                                  password='2019H@slo',
                                  )

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    bind_ue_ip='10.42.197.170'
)

_android_ue = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.44.72.16",
    serial_number="NAAIOC1841509SA",
    imsi="310260560003274",
    capabilities=["REAL_ANDROID_UE"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
)

_attenuator = TopYoung(ip_addr="10.42.61.37", port=3001, model="TAS_24T24_04G6_90_1S_EJS",
                          attenuation_port_numbers=[13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])

_core = RealCore5G(mcc=540, mnc=1)

tl = TestLine(
    test_pc=[_test_pc_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIB_ABIO_2xAREA_AHEGB_UTECA",
    gnbs=[_gnb_1],
    enbs=[_enb_1],
    core=_core,
    pdus=_pdus,
    attenuator=_attenuator,
    test_pcs=[_test_pc_1, _test_pc_2],
    ues=[_android_ue],
)

__all__ = ["tl"]
