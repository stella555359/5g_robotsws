__maintainer__ = "Jaroslaw Wojczyszyn"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "jaroslaw.wojczyszyn@nokia.com"
__owner_email__ = "bartosz.zajac@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.attenuator import JFW
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import (
    NetworkAddress,
    RoutingInformation,
    TafUeDataTransferProtocol,
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import RRB
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
    expected_prompt="dummy_prompt",
)

_app_server_2 = TafUeAppServer(
    app_server_name="APP_2",
    address="10.42.62.62",
    user="syslab",
    password="system",
    bind_interface_ip="10.42.197.171",
    expected_prompt="dummy_prompt",
)

_rmod_5g_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1233602232",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    # pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_5g_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M210537937",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    # pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_5g_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1233602233",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    # pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_5g_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M210537958",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    # pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_5g_5 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="DH234520603",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    # pdu_port=_pdu_1.pdu_ports[2],
)

# BBMODs definition
_fsp_5g_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211506435",
    rus=[_rmod_5g_1],
)

# SMOD definition
_fct_5g = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5g_1],
    # pdu_port=_pdu_3.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1220403416",
)

_smod_5g = Airscale([_fct_5g])

_du_1 = DU(_smod_5g)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.68.169"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

# Real BTS definition
_cbts = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=51150, instance_id=51150)

# VirtualMachines definition
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.193", username="ute", password="ute"
    ),
    connections=[_cbts]
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIO_2xAEQY_2xAVQL_2xAQQL",
)

__all__ = ["tl"]
