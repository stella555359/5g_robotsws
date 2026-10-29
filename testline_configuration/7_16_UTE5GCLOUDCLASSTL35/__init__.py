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

_core = RealCore5G(mcc=310, mnc=260)

_attenuator = JFW(
    ip_addr="10.42.54.207", port=3001, attenuation_port_numbers=[1, 2, 3, 4, 7, 8]
)

_pdu1 = Gude(
    addr="10.44.206.178", port_numbers=[3, 4, 6, 10, 12], model="EPC", version="8220-1"
)

_pdus = [_pdu1]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="AH192600728",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[12],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1933G10O0",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1945V00KS",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu1.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1184319573",
    rus=[_rmod_1, _rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193679291",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIK",
    hardware_version="474021A.101",
    serial_number="L1190309413",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu1.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1184505438",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du = DU(_smod_1)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.66.144",
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
        v4="10.44.66.208",
        vlan_id=465,
        routing_v4=RoutingInformation(
            gateway="10.44.66.193", destIpAddr="255.255.255.192"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.67.11",
        vlan_id=466,
        routing_v4=RoutingInformation(
            gateway="10.44.67.1", destIpAddr="255.255.255.192"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.67.75",
        vlan_id=467,
        routing_v4=RoutingInformation(
            gateway="10.44.67.65", destIpAddr="255.255.255.192"
        ),
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51101, instance_id=51101)

_enb_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_3],
    oam_ip=NetworkAddress("10.44.66.145"),
    x2_link_addr=NetworkAddress(
        v4="10.44.66.209",
        vlan_id=465,
        routing_v4=RoutingInformation(
            gateway="10.44.66.193", destIpAddr="255.255.255.192"
        ),
    ),
    global_bts_id=41101,
    instance_id=41101,
)

_test_pc = TestPc(
    SshServiceDetails(addr="10.44.178.117", username="ute"),
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
    addr="10.42.22.179", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_android = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.179",
    serial_number="0123456789ABCDEF",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.44.43.21",
        interval=1,
    ),
)

_test_pc_enb = TestPc(
    SshServiceDetails(addr="10.44.178.118", username="ute"),
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
    attenuator=[_attenuator],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AHIB_2xAHLOA_ENB",
    core=_core,
    pdus=_pdus,
    enbs=[_enb_1],
    test_pcs=[_test_pc, _test_pc_enb],
    ues=[_android],
)

__all__ = ["tl"]
