__maintainer__ = "Rafal Skrok"
__team__ = "MN 5G RAN I&V Cloud"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "rafal.skrok@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RadioTypes, RoutingInformation
from taf.config.testline.radio import RU
from taf.config.testline import RealEnb
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAndroid

_cfg_dir = os.path.dirname(os.path.abspath(__file__))


# PDU
_common_pdu = Gude(
    addr="10.44.205.191", port_numbers=[6, 8, 10], model="EPC", version="8221-1"
)
_pdu_AZHL = Gude(addr="10.44.205.192", port_numbers=[9], model="EPC", version="8221-1")

# 5G radio units
_azhl = RU(
    ru_hw_group="Below6GHz",
    radio_type="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="none",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_AZHL.pdu_ports[9],
)


_ahfb = RU(
    ru_hw_group="LTE_RADIO",
    radio_type=RadioTypes.AHFB.value,
    serial_number="AH192700280",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_common_pdu.pdu_ports[6],
)

_abil_5g = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1190611698",
    rus=[_azhl],
)


_abia_4g = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9174326868",
    rus=[_ahfb],
)

_lmp_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_asil = CommonUnit(
    lmp_connection=_lmp_ssh,
    capacity_units=[_abil_5g],
    pdu_port=_common_pdu.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1204202776",
)

_asia = CommonUnit(
    lmp_connection=_lmp_ssh,
    capacity_units=[_abia_4g],
    pdu_port=_common_pdu.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="6Q174625867",
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.85.199",
        vlan_id=897,
        routing_v4=RoutingInformation(
            gateway="10.44.85.193", destIpAddr="255.255.255.192"
        ),
    ),
    oam_ssh_connection_details=_lmp_ssh,
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.86.7",
        vlan_id=898,
        routing_v4=RoutingInformation(
            gateway="10.44.86.1", destIpAddr="255.255.255.192"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.86.69",
        vlan_id=899,
        routing_v4=RoutingInformation(
            gateway="10.44.86.65", destIpAddr="255.255.255.192"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.86.133",
        vlan_id=900,
        routing_v4=RoutingInformation(
            gateway="10.44.86.129", destIpAddr="255.255.255.192"
        ),
    ),
)

_du = DU(airscale=Airscale(common_units=[_asil]))


_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.36", username="wro5gcloud", password="Secret2.022!"
)


_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.44.43.21",
)


_mediatek = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.44.72.36",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.44.43.21",
        interval=1,
    ),
)

# ugly workaround for not working properly TopYoung (the real Attenuator for this TL)
_attenuator = JFW(
    ip_addr="10.42.54.177", port=3001, attenuation_port_numbers=[3, 6, 11, 14]
)

_gnb = ClassicalBts(cu=_cu, dus=[_du], instance_id=50436, global_bts_id=50436)

_enb = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    rms=[_ahfb],
    instance_id=40436,
    global_bts_id=40436,
    oam_ip=NetworkAddress(v4="10.44.85.200"),
    x2_link_addr=NetworkAddress(v4="10.44.86.8"),
)


# 5G VM
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.29", username="ute", password="uteUTE!"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_lte = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.30", username="ute", password="uteUTE!"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIL_AZHL_UE",
    test_pc=_test_pc,
    attenuator=[_attenuator],
    test_pcs=[_test_pc, _test_pc_lte],
    gnbs=[_gnb],
    enbs=[_enb],
    pdus=[_common_pdu, _pdu_AZHL],
    ues=[_mediatek],
)

__all__ = ["tl"]
