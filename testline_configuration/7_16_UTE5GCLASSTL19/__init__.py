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
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=310, mnc=260)

_pdu = Gude(
    addr="10.44.206.140", port_numbers=[5, 7, 9, 10], model="EPC", version="8226-1"
)

_rmod_1 = RU(
    ru_hw_group="FRMr6_4T4R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193301361",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu.pdu_ports[10],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFB.value,
    serial_number="EA171411384",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222310840",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1214511935",
    rus=[_rmod_1],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193775069",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH220345011",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="473095A.204",
    serial_number="EA194754136",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du = DU(_smod_1)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.90.189",
        vlan_id=488,
        routing_v4=RoutingInformation(
            gateway="10.44.90.129", destIpAddr="255.255.255.192"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.90.230",
        vlan_id=489,
        routing_v4=RoutingInformation(
            gateway="10.44.90.193", destIpAddr="255.255.255.192"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.91.41",
        vlan_id=490,
        routing_v4=RoutingInformation(
            gateway="10.44.91.1", destIpAddr="255.255.255.192"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.91.80",
        vlan_id=491,
        routing_v4=RoutingInformation(
            gateway="10.44.91.65", destIpAddr="255.255.255.192"
        ),
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50440, instance_id=50440)

_enb_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2],
    oam_ip=NetworkAddress("10.44.92.50"),
    x2_link_addr=NetworkAddress(
        v4="10.44.92.113",
        vlan_id=495,
        routing_v4=RoutingInformation(
            gateway="10.44.92.65", destIpAddr="255.255.255.192"
        ),
    ),
    global_bts_id=40440,
    instance_id=40440,
)

_test_pc = TestPc(
    SshServiceDetails(addr="10.44.178.61", username="ute"),
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
    addr="10.42.22.50", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_askey = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.50",
    serial_number="dafb23ff",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="/usr/bin/iperf3",
        bind_ue_ip="10.45.168.53",
        interval=1,
    ),
)

_test_pc_enb = TestPc(
    SshServiceDetails(addr="10.42.53.29", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

# it is walkaround if we can't split power between gnb and enb
test_line_additional_vms = [_test_pc_enb]

tl = TestLine(
    test_pc=[_test_pc],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABIOB1_AHCA_AEQN",
    core=_core,
    pdus=_pdu,
    enbs=[_enb_1],
    test_pcs=[_test_pc],
    ues=[_askey],
)

__all__ = ["tl"]
