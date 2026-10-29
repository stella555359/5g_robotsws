__maintainer__ = "Bartosz Kozlowski"
__team__ = "RRM team"
__email__ = "bartosz.1.kozlowski@nokia.com"
__owner_email__ = "palina.krasnova@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G, RealCore5GDetails
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.200.183",
    port_numbers=[1, 2, 5, 6, 7],
    model="EPC",
    version="8041-1",
)

_pdu2 = Gude(
    addr="10.44.200.187",
    port_numbers=[1, 2, 5, 7],
    model="EPC",
    version="8041-1",
)

_pdu3 = Gude(
    addr="10.44.200.190",
    port_numbers=[5, 6, 8],
    model="EPC",
    version="8041-1",
)

_pdus = [_pdu1, _pdu2, _pdu3]

_attenuator = TopYoung(
    ip_addr="10.42.221.80",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_04G6_90_1S_EJS"
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2004G104L",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.133", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.133", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2003G10XE",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1930G11OX",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[7],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1913V008L",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.132", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.132", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1910V00UF",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2051V0WQ7",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.131", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.131", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[7],
)

_rmod_7 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="AH231900718",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.154", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.154", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[5],
)

_rmod_8 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9223130065",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.158", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.158", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[5],
)

_rmod_9 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="AH234900453",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.162", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.162", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="A.102",
    product_code="474020A.102",
    serial_number="L1184411870",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIL",
    hardware_version="A.102",
    product_code="474020A.102",
    serial_number="L1185109743",
    rus=[_rmod_4, _rmod_5],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="B.102",
    product_code="474020B.102",
    serial_number="L1203802108",
    rus=[_rmod_6],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="B.101",
    product_code="475266B.101",
    serial_number="L1224206414",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.103",
    product_code="473096A.103",
    serial_number="K9173824765",
    rus=[_rmod_4, _rmod_5],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    product_code="473096A.103",
    serial_number="K9173824770",
    rus=[_rmod_6],
)

_fsp_7 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    product_code="473096A.103",
    serial_number="L1162608178",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu3.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224815346",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu3.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224209038",
)

# SMOD ENB
_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5, _fsp_6, _fsp_7],
    pdu_port=_pdu3.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="473764A.120",
    serial_number="L1191304511",
)

_core = RealCore5G(mcc=1, mnc=1)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
_smod_3 = Airscale([_fct_3])    # ENB

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.88.13",
        vlan_id=571,
        routing_v4=RoutingInformation(gateway="10.42.88.1"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.88.13", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.32.13",
        vlan_id=576,
        routing_v4=RoutingInformation(gateway="10.42.32.1"),
    ),
    x2u=NetworkAddress(
        v4="10.42.89.139",
        vlan_id=574,
        routing_v4=RoutingInformation(gateway="10.42.89.129"),
    ),
    s1u=NetworkAddress(
        v4="10.42.89.139",
        vlan_id=574,
        routing_v4=RoutingInformation(gateway="10.42.89.129"),
    ),
    ngu=NetworkAddress(
        v4="10.42.89.139",
        vlan_id=574,
        routing_v4=RoutingInformation(gateway="10.42.89.129"),
    )
)

_cu_1.m = NetworkAddress(
    v4="10.42.88.13",
    vlan_id=571,
    routing_v4=RoutingInformation(gateway="10.42.88.1"),
)

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=55267, instance_id=55267)
_gnb_2 = ClassicalBts(cu=_cu_1, dus=[_du_2], global_bts_id=55267, instance_id=55267)

_enb_1 = RealEnb(
    system_module=_smod_3,
    oam_ip=NetworkAddress("10.42.88.11"),
    x2_link_addr=NetworkAddress(
        v4="10.42.89.139",
        vlan_id=574,
        routing_v4=RoutingInformation(gateway="10.42.89.129"),
    ),
    global_bts_id=55267,
    instance_id=8816,
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.42.194.143", username="ute", password="UTE.debian12"),
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
    default_ssh_connection_details=SshServiceDetails(addr="10.42.194.151", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        )
    ]
)

# ENB VM
_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.42.209.39", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module,
            interface_type="lmp",
        )
    ]
)

_ue_pc_ssh = SshServiceDetails("10.42.224.33", "plwr4gsfe", password="ltesfe4@")

_realcore_appsrv = TafUeAppServer(app_server_name="APP_1",
                                  address="10.45.168.52",
                                  bind_interface_ip="10.45.168.52",
                                  user="qt5g",
                                  password="5Gqtmoth!",
                                  )

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_realcore_appsrv,
    binary_path="/data/data/com.nokia.android.application/",
    interval=1,
    server_close_delay=50,
    interface_name="n26wro",
)

pdn_n26wro = PDNTafUeAndroidDetails(
    entryName="n26wro",
    apnName="n26wro",
    apnType=["default"],
    carrierEnabled=True,
    operatorNumeric="00101",
)

_android_ue_1 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.33",
    ue_pc_port="8080",
    serial_number="RFCW216W9EY",
    imei="355552510889109",
    imsi="001017000022104",
    capabilities=["REAL_UE", "RFCW216W9EY"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[pdn_n26wro],
)

_android_ue_2 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.33",
    ue_pc_port="8080",
    serial_number="RFCW20EQWYA",
    imei="350932554437913",
    imsi="001017000022103",
    capabilities=["REAL_UE", "RFCW20EQWYA"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    pdns=[pdn_n26wro],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_1, _gnb_2],
    enbs=[],
    tl_cloud_topology="",
    attenuator=_attenuator,
    core=_core,
    ues=[_android_ue_1, _android_ue_2],
    pdus=_pdus,
)

__all__ = ["tl"]
