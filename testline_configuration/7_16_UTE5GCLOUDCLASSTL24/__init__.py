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
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.attenuator import JFW
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdu import Gude
from taf.config.testline import RealEnb
from taf.config.testline.appserver import TafUeAppServer

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_common_pdu = Gude(
    addr="10.44.205.191",
    port_numbers=[9, 4, 5],
    model="EPC",
    version="8221-1",
)

_radio_pdu = Gude(
    addr="10.44.205.192",
    port_numbers=[1, 2, 3],
    model="EPC",
    version="8221-1",
)

_azqo1 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203917136",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_radio_pdu.pdu_ports[1],
)

_azqo2 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203917133",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2324
    ),
    pdu_port=_radio_pdu.pdu_ports[2],
)

_azqo3 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203917160",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2325
    ),
    pdu_port=_radio_pdu.pdu_ports[3],
)

_fxed1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7172531740",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_common_pdu.pdu_ports[4],
)

_abio_5g = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104913",
    rus=[_azqo1, _azqo2, _azqo3],
)

_abia_4g = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9174326819",
    rus=[_fxed1],
)

_lmp_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)


_asil = CommonUnit(
    lmp_connection=_lmp_ssh,
    capacity_units=[_abio_5g],
    pdu_port=_common_pdu.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1213511582",
)


_asia = CommonUnit(
    lmp_connection=_lmp_ssh,
    capacity_units=[_abia_4g],
    pdu_port=_common_pdu.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="6Q174625685",
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.85.197",
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
        v4="10.44.86.5",
        vlan_id=898,
        routing_v4=RoutingInformation(
            gateway="10.44.86.1", destIpAddr="255.255.255.192"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.86.68",
        vlan_id=899,
        routing_v4=RoutingInformation(
            gateway="10.44.86.65", destIpAddr="255.255.255.192"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.86.132",
        vlan_id=900,
        routing_v4=RoutingInformation(
            gateway=" 10.44.86.129", destIpAddr="255.255.255.192"
        ),
    ),
)

_du = DU(airscale=Airscale(common_units=[_asil]))

# UEPC
_mtk_host_ssh = SshServiceDetails(
    addr="10.44.72.37", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_ue1 = TafUeAndroid(
    ssh_connection_details=_mtk_host_ssh,
    ue_pc_address="10.44.72.37",
    serial_number="418478c9",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="/data/local/tmp/iperf",
        bind_ue_ip="10.45.168.53",
        interval=1,
    ),
)

_enb = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    rms=[_fxed1],
    instance_id=40435,
    global_bts_id=40435,
    oam_ip=NetworkAddress(v4="10.44.85.198"),
    x2_link_addr=NetworkAddress(v4="10.44.86.6"),
)

_gnb = ClassicalBts(cu=_cu, dus=[_du], instance_id=50435, global_bts_id=50435)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.25", username="ute", password="ute"
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


_enb_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.26", username="ute", password="ute"
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

# ugly workaround for not working properly TopYoung (the real Attenuator for this TL)
_attenuator = JFW(
    ip_addr="10.42.54.177", port=3001, attenuation_port_numbers=[17, 18, 21, 22]
)


tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABIOB1_3xAZQO",
    test_pc=_test_pc,
    gnbs=[_gnb],
    enbs=[_enb],
    ues=[_ue1],
    test_pcs=[_test_pc, _enb_pc],
    attenuator=[_attenuator],
    pdus=[_common_pdu, _radio_pdu],
)

__all__ = ["tl"]
