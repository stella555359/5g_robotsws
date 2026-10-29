__maintainer__ = "Jaroslaw Wojczyszyn"
__email__ = "jaroslaw.wojczyszyn@nokia.com"

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

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

#PDU definition
_pdu_1 = Gude("10.44.206.13", [5], "EPC", "8221-1") # ---> SMOD: ASIB, A5
_pdu_2 = Gude("10.44.205.59", [3], "EPC", "8221-1") # ---> RMOD: AHLOA, A3
_pdu_3 = Gude("10.44.205.81", [6], "EPC", "8221-1") # ---> RMOD: AHLOA, B1

_pdus = [_pdu_1, _pdu_2, _pdu_3]

#RU definition
_rmod_5g_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2003G10PA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_5g_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1919G10I6",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)

# BBMOD definition
_fsp_5g_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104686",
    rus=[_rmod_5g_1, _rmod_5g_2],
)

#SMOD definition
_fct_5g = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5g_1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1203709788",
)

_smod_5g = Airscale([_fct_5g])

#IP and network
_du_1 = DU(_smod_5g)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.68.168"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

#Real BTS definition
_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=50046, instance_id=50046)

#VirtualMachines definition
_test_pc_5g = TestPc(
    SshServiceDetails(addr="10.42.53.69", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnbs_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

#taf_ue prep:
_app_server = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server, interval=1, version=3
)

#ALL Test Line
tl = TestLine(
    test_pc=_test_pc_5g,
    test_pcs=[_test_pc_5g],
    gnbs=[_gnbs_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_",
    pdus=_pdus,
)

__all__ = ["tl"]
