__maintainer__ = "Bartosz Kozlowski"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "bartosz.1.kozlowski@nokia.com"
__owner_email__ = "bartosz.1.kozlowski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation, Connection
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.attenuator import JFW, AttenuationPort
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu_su = Gude(
    addr="10.44.200.109",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_ru = Gude(
    addr="10.44.200.110",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_attenuator = JFW(
    ip_addr="10.42.54.91", port=3001, attenuation_port_numbers=range(1, 13), pdu_port=_pdu_su.pdu_ports[11]
)

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5_4T4R",
    radio_type="AHLOA",
    serial_number="BL2106G10I0",
    pdu_port=_pdu_ru.pdu_ports[8],
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[4:8]
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5_4T4R",
    radio_type="AHLOA",
    serial_number="K9183920957",
    pdu_port=_pdu_ru.pdu_ports[7],
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[8:12]
)

# _ru3 = RU(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="172.16.33.128", username="root", password=""
#     ),
#     lmp_connection=SshServiceDetails(addr="", username=""),
#     radio_type="AHFII",
#     ru_hw_group="AirScale_RF_4T4R_B",   #Not sure about this
#     serial_number="BL2234N41LR",
#     pdu_port=_pdu_ru.pdu_ports[12],
#     attenuation_ports=list(_attenuator.attenuator_ports.keys())[0:4]
# )

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="A.102",
    product_code="475792A.102",
    serial_number="L1233803013",
    rus=[_ru1, _ru2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="A.102",
    product_code="475792A.102",
    serial_number="L1233803008",
    rus=[],
    # rus=[_ru3],
)

_common_unit = CommonUnit(
    hardware_type="ASIL",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_su.pdu_ports[3],
    hardware_version="474767A.101",
    serial_number="DH220640226"
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.85.13",
        vlan_id=518,
        routing=RoutingInformation(gateway="10.42.85.1", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.42.85.77",
        vlan_id=519,
        routing=RoutingInformation(gateway="10.42.85.65", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.42.85.141",
        vlan_id=520,
        routing=RoutingInformation(gateway="10.42.85.129", ip_prefix_length=26),
    ),
)

_cu.m = NetworkAddress(
    v4="10.42.84.16",
    vlan_id=517,
    routing=RoutingInformation(gateway="10.42.84.1", ip_prefix_length=24),
)

_cu.sync = NetworkAddress(
    v4="10.42.85.205",
    vlan_id=521,
    routing=RoutingInformation(gateway="10.42.85.193", ip_prefix_length=26),
)

_du = DU(Airscale([_common_unit]), rus=[_ru1, _ru2])    #_ru1, _ru2, _ru3

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50199, instance_id=50199)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=310, mnc=260)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.173", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_cbts.dus[0].airscale.common_units[0]
        )
    ]
)

_ue_pc_ssh = SshServiceDetails("10.44.72.21", "wro5grrm", password="5gpass!1")

_realcore_appsrv_ipv4 = TafUeAppServer(
    app_server_name="realcore",
    address="10.45.168.52",
    bind_interface_ip="10.45.168.52",
    user="syslab",
    password="system"
)

_realcore_appsrv_ipv6 = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246",
    bind_interface_ip="2a00:8a00:6000:607c:ffff:ffff:ffff:fe06",
    user="syslab",
    password="Pass4System!"
)

_iperf_ue_ipv4 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_ipv4,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    interface_name='n26wro'
)

_iperf_ue_ipv6 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_ipv6,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    interface_name='fast.t-mobile.com'
)

_android_ue = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.44.72.21",
    ue_pc_port="8001",
    serial_number="HZQN1876AAKA2000089",
    imsi="310260560002722",
    phone_number='+35848560002722',
    capabilities=["REAL_UE_SA"],
    data_transfer=[_iperf_ue_ipv4, _iperf_ue_ipv6],
    network_mode_switch_method='adb',
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_CLASSICAL_HALFRACK_SA_NSA_ANDROID_ASIL_2xABIP_2xAHLOA_AHFII_GNB",
    attenuator=_attenuator,
    core=_real_core,
    ues=[_android_ue],
    pdus=[_pdu_su, _pdu_ru]
)

tl.tl_type = "sa/nsa"
tl.smod_slave = False

__all__ = ["tl"]
