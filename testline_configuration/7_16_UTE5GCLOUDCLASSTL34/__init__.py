__maintainer__ = "Maciej Futyma"
__team__ = "MN 5G RAN I&V Cloud"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "maciej.futyma@nokia.com"

import os

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, Connection, RoutingInformation
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# PDUs
_pdu = Gude(addr="10.44.205.191", port_numbers=[7], model="EPC", version="8221-1")

_pdu_rmod_nr = Gude(
    addr="10.44.205.192", port_numbers=[4], model="EPC", version="8221-1"
)

# 5G radio modules
_gnb_rmod = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQO.value,
    serial_number="1M203309933",
    default_ssh_connection_details=SshServiceDetails(
        addr="placeholder",
        username="placeholder",
        password="placeholder",
    ),
    pdu_port=_pdu_rmod_nr.pdu_ports[4],
)

# Baseband modules
_capacity_unit = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204104755",
    rus=[_gnb_rmod],
)

# System modules
_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_asil = CommonUnit(
    _common_unit_ssh,
    capacity_units=[_capacity_unit],
    pdu_port=_pdu.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1213506788",
)

_smod = Airscale([_asil])

# 5G BTS
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.86.13",
        vlan_id="898",
        routing_v4=RoutingInformation(
            gateway="10.44.86.1", destIpAddr="255.255.255.192"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.86.72",
        vlan_id="899",
        routing_v4=RoutingInformation(
            gateway="10.44.86.65", destIpAddr="255.255.255.192"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.86.136",
        vlan_id="900",
        routing_v4=RoutingInformation(
            gateway="10.44.86.129", destIpAddr="255.255.255.192"
        ),
    ),
)

_du = DU(_smod)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du], instance_id=50449, global_bts_id=50449)

# NUC
_ue_pc_ssh = SshServiceDetails(
    addr="10.42.224.128", username="wro5gcloud", password="Secret2.022!"
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.52",
    user="syslab",
    password="system",
    bind_interface_ip="10.45.168.52",
)

# Attenuator
_attenuator = JFW(ip_addr="10.42.54.177", port=3001, attenuation_port_numbers=[23, 24])

# UEs
_mediatek = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.128",
    serial_number="0123456789ABCDEF",
    data_transfer=TafUeDataTransferProtocol(
        protocol_name="iperf",
        app_server=_appserver_ssh,
        binary_path="data/local/tmp/iperf",
        bind_ue_ip="10.45.168.52",
        interval=1,
    ),
)

# 5G VM
_test_pc_nr = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.51",
        username="ute",
        password="uteUTE!",
    ),
    connections=[Connection(interface="eth1", interface_type="lmp", device=_asil)],
)

# Testline
tl = TestLine(
    test_pc=_test_pc_nr,
    test_pcs=[_test_pc_nr],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_MEDIATEK_ASIL_ABIO_AZQO",
    attenuator=[_attenuator],
    pdus=[_pdu, _pdu_rmod_nr],
    ues=[_mediatek],
)

__all__ = ["tl"]
