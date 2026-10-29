__maintainer__ = "Tomasz Sobania"
__team__ = "RRM team"
__email__ = "tomasz.sobania@nokia.com"
__owner_email__ = "tomasz.sobania@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.200.200",
    port_numbers=[1, 8],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.200.201",
    port_numbers=[8],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.200.215",
    port_numbers=[1],
    model="EPC",
    version="8041-1",
)

_pdu4 = Gude(
    addr="10.44.206.212",
    port_numbers=[5],
    model="EPC",
    version="8226-1",
)

_pdu5 = Gude(
    addr="10.44.177.199",
    port_numbers=[9],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4, _pdu5]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="NQ233890115",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="NQ232492713",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[8],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="NQ233890102",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[1],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHPB.value,
    serial_number="NQ242611981",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu3.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9232912636",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu4.pdu_ports[5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    hardware_type="ASOE",
    hardware_version="A.101",
    serial_number="EA211854008",
    pdu_port=_pdu5.pdu_ports[9],
)

_core = RealCore5G(mcc=540, mnc=1)

_smod_1 = Airscale([_fct_1])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.41.33",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.42.41.1"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.41.96",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.42.41.1"),
    ),
    x2u=NetworkAddress(
        v4="10.42.41.160",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.42.41.1"),
    ),
    s1u=NetworkAddress(
        v4="10.42.41.160",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.42.41.1"),
    ),
    ngu=NetworkAddress(
        v4="10.42.41.160",
        vlan_id=919,
        routing_v4=RoutingInformation(gateway="10.42.41.1"),
    ),
)

_du_1 = DU(_smod_1)

_attenuator_AQQJ = TopYoung(
    ip_addr="10.42.54.195", port=3001, attenuation_port_numbers=[15, 16, 19, 20, 21, 22, 23, 24]
)
# 15-20 - SA_250, 21-24 - SA_252
_attenuator_AHPB = TopYoung(
    ip_addr="10.42.54.9", port=3001, attenuation_port_numbers=[17, 18, 19, 20]
)
# 17,18 - SA_253, 19,20 - SA_254

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=50825, instance_id=50825)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.180.203", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails("10.42.215.71", "wro5grrm", password="5gpass!1", port=22))

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
    ue_pc_address="10.42.215.71",
    serial_number="1c1ac8ae",
    capabilities=["REAL_ANDROID_UE"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
)

tl = TestLine(
    test_pc=_test_pc_1,
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASOE_3xAQQJ_AHPB_AHPJ",
    core=_core,
    pdus=_pdus,
    attenuator=[_attenuator_AQQJ, _attenuator_AHPB],
    test_pcs=[_test_pc_1],
    ues=[_qualcomm]
)

__all__ = ["tl"]
