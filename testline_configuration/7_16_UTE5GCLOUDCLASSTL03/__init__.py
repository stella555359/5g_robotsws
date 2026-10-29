__maintainer__ = "Krzysztof Wrbel"
__team__ = "I_MN_RAN_PZ1_WRO_8_SG_GMS"
__email__ = "krzysztof.1.wrobel@nokia.com"
__owner_email__ = "krzysztof.1.wrobel@nokia.com"

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
from taf.config.testline import (
    DU,
    RU,
    RadioTypes,
    NetworkAddress,
    RoutingInformation,
    RealEnb,
)
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=540, mnc=1)

_attenuator = JFW(ip_addr="10.42.54.207", port=3001, attenuation_port_numbers=[15, 16])

_pdu1 = Gude(addr="10.44.206.178", port_numbers=[1, 2, 9], model="EPC", version="8220-1")

_pdu2 = Gude(addr="10.44.206.249", port_numbers=[9], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFB.value,
    serial_number="EA174113445",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[9],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="AH192301539",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1183608772",
    rus=[],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508284",
    rus=[_rmod_1],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1183610588",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH220345016",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu1.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="DH194153121",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du = DU(_smod_1)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.66.154",
        vlan_id=464,
        routing_v4=RoutingInformation(
            gateway="10.44.66.129", destIpAddr="255.255.255.192"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.66.218",
        vlan_id=465,
        routing_v4=RoutingInformation(
            gateway="10.44.66.193", destIpAddr="255.255.255.192"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.67.16",
        vlan_id=466,
        routing_v4=RoutingInformation(
            gateway="10.44.67.1", destIpAddr="255.255.255.192"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.67.80",
        vlan_id=467,
        routing_v4=RoutingInformation(
            gateway="10.44.67.65", destIpAddr="255.255.255.192"
        ),
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50434, instance_id=50434)

_enb_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2],
    oam_ip=NetworkAddress("10.44.66.155"),
    x2_link_addr=NetworkAddress(
        v4="10.44.66.219",
        vlan_id=465,
        routing_v4=RoutingInformation(
            gateway="10.44.66.193", destIpAddr="255.255.255.192"
        ),
    ),
    global_bts_id=40434,
    instance_id=40434,
)

_test_pc = TestPc(
    SshServiceDetails(addr="10.44.156.163", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.42.22.111", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.52",
    user="syslab",
    password="system",
    bind_interface_ip="10.45.168.52",
)

_android_qu0 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.111",
    serial_number="bd0d1296",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.45.168.52",
        interval=1,
    ),
)

_android_qu1 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.111",
    serial_number="6764ce0d",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.45.168.52",
        interval=1,
    ),
)

_android_qu2 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.111",
    serial_number="78a8ef0f",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.45.168.52",
        interval=1,
    ),
)

_samsungS20 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.111",
    serial_number="RFCN103WP0H",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.45.168.52",
        interval=1,
    ),
)

_test_pc_enb = TestPc(
    SshServiceDetails(addr="10.44.156.219", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=[_test_pc],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABILB1_ABIOB2_ENB",
    core=_core,
    pdus=_pdus,
    attenuator=[_attenuator],
    enbs=[_enb_1],
    test_pcs=[_test_pc, _test_pc_enb],
    ues=[_android_qu0, _android_qu1, _android_qu2, _samsungS20],
)

__all__ = ["tl"]
