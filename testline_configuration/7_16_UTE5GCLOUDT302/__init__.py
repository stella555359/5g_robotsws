__maintainer__ = "Rafal Kaczmarski"
__team__ = "5G_PZ_2_WRO_8_SG"
__email__ = "rafal.kaczmarski@nokia.com"
__owner_email__ = "rafal.kaczmarski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.ue import TafUeAndroid, TafUeMtk
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.pdu import Gude
from taf.config.testline.lmi import SerialOverTcp, Remote


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_core = RealCore5G(mcc=540, mnc=1)

_pdu1 = Gude(
    addr="10.44.205.86",
    port_numbers=[3, 7, 8, 9],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.205.113",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.205.114",
    port_numbers=[5, 7],
    model="EPC",
    version="8221-1",
)

_pdu4 = Gude(
    addr="10.44.205.115",
    port_numbers=[6, 7],
    model="EPC",
    version="8221-1",
)

_pdu5 = Gude(
    addr="10.44.205.112",
    port_numbers=[12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4, _pdu5]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS194202597",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu4.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.26", port=5001),
        ]
    ),
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS193605501",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu4.pdu_ports[6],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.27", port=5001),
        ]
    ),
)

_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS194202596",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu5.pdu_ports[12],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.28", port=5001),
        ]
    ),
)

_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS210101375",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.16", port=5001),
        ]
    ),
)

_rmod_5 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS210101340",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[7],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.17", port=5001),
        ]
    ),
)

_rmod_6 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS210101313",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[5],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.33.18", port=5001),
        ]
    ),
)

_rmod_7 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="AH192600558",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1183218614",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:102",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1194014430",
    rus=[_rmod_7],
)

_fsp_3 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1184319587",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181619402",
    rus=[_rmod_7, _rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu1.pdu_ports[8],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="EA194456038",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1201204806",
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu1.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1172900720",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
_smod_3 = Airscale([_fct_3])

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.22",
        v6="2a00:8a00:6000:607c::2a16",
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
        addr="10.44.224.22", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.86",
        v6="2a00:8a00:6000:607c::2b16",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2b01"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.150",
        v6="2a00:8a00:6000:607c::2c16",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2c01"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.214",
        v6="2a00:8a00:6000:607c::2d16",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.214",
        v6="2a00:8a00:6000:607c::2d16",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
)

_cu_1.m = NetworkAddress(
    v4="10.44.224.22",
    v6="2a00:8a00:6000:607c::2a16",
    vlan_id=915,
    routing=RoutingInformation(gateway="10.44.224.1"),
)

_cu_1.sync = NetworkAddress(
    v4="10.44.225.22",
    v6="2a00:8a00:6000:607c::2e16",
    vlan_id=919,
    routing=RoutingInformation(gateway="10.44.225.1"),
)

_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.23",
        v6="2a00:8a00:6000:607c::2a17",
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
        addr="10.44.224.23", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.87",
        v6="2a00:8a00:6000:607c::2b17",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2b01"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.151",
        v6="2a00:8a00:6000:607c::2c17",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2c01"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.215",
        v6="2a00:8a00:6000:607c::2d17",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.215",
        v6="2a00:8a00:6000:607c::2d17",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
)

_cu_2.m = NetworkAddress(
    v4="10.44.224.23",
    v6="2a00:8a00:6000:607c::2a17",
    vlan_id=915,
    routing=RoutingInformation(gateway="10.44.224.1"),
)

_cu_2.sync = NetworkAddress(
    v4="10.44.225.23",
    v6="2a00:8a00:6000:607c::2e17",
    vlan_id=919,
    routing=RoutingInformation(gateway="10.44.225.1"),
)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=50831, instance_id=50831)
_gnb_2 = ClassicalBts(cu=_cu_2, dus=[_du_2], global_bts_id=50832, instance_id=50832)

_enb_1 = RealEnb(
    system_module=_smod_3,
    rms=[_rmod_7, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.44.225.150"),
    x2_link_addr=NetworkAddress(
        v4="10.44.225.150",
        v6="2a00:8a00:6000:607c::3016",
        vlan_id=922,
        routing_v4=RoutingInformation(gateway="10.44.225.193"),
    ),
    global_bts_id=40832,
    instance_id=40832,
)

_attenuator = TopYoung(
    ip_addr="10.42.54.61",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 14, 15, 16, 17, 18, 19, 20],
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.146", username="ute"),
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
    SshServiceDetails(addr="10.44.149.147", username="ute"),
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
    SshServiceDetails(addr="10.44.178.11", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails("10.42.22.239", "wro5grrm", password="5gpass!1")

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
    version=3,
    server_close_delay=50,
    bind_ue_ip='10.42.197.170',
)

pdn_5gsawro = PDNTafUeAndroidDetails(
    entryName="5gsawro",
    apnName="5gsawro",
    apnType=["DEFAULT", "MMS", "IMS", "HIPRI", "SUPL", "FOTA", "CBS", "XCAP"],
    carrierEnabled=True,
    operatorNumeric="54001",
)

_android_ue_1 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.239",
    serial_number="0123456789ABCDEF",
    imei="351901031120409",
    imsi="310260560003083",
    capabilities=["REAL_ANDROID_UE"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[pdn_5gsawro],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_gnb_1, _gnb_2],
    enbs=[_enb_1],
    pdus=_pdus,
    attenuator=_attenuator,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIKR_2xABIL_3xAHCA_AHIB_ASIKL_ABIL_3xAHCA_UTECA",
    core=_core,
    ues=[_android_ue_1],
)
__all__ = ["tl"]
