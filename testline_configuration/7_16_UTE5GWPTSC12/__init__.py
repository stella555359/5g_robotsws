__maintainer__ = "Paweł Wiśniewski"
__team__ = "VRF WRO2 T01"
__email__ = "I_5GSC_5G_PZ2_WRO_1@internal.nsn.com"
__owner_email__ = "pawel.1.winsiewski@nokia.com"


import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.attenuator import JFW
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.lmi import SerialOverTcp, Remote
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
from taf.config.testline.pdn import PDNTafUeAndroidDetails


# *** UEs ***  DONE
_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
    expected_prompt="dummy_prompt",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2  # OPTIONAL
)

_ue1 = TafUeAndroid(
    serial_number="b44d7098",
    capabilities=[
        "REAL_UE",
        "b44d7098",
    ],
    ue_pc_address="10.44.234.169",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.44.234.169", username="wro5grrm", password="5gpass!1"
    ),
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Off|On",
)

#pdus
_pdu1 = Gude(
    addr="10.45.177.28", port_numbers=[5], model="EPC", version="8221-1"
)  # --> ASIM

_pdu2 = Gude(
    addr="10.45.172.157", port_numbers=[10], model="EPC", version="8221-1"
)  # --> Dummy radio pdu - nothing is connected

_rmod1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type="AVQQB",
    serial_number="L1242503738",
    pdu_port=_pdu2.pdu_ports[10],
)

# BBMODs definition - DONE
_abip = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A",
    serial_number="L1240903873",
    rus=[_rmod1],
)

_abin = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIN",
    hardware_version="474824A",
    serial_number="L1214007344",
    rus=[],
)



# SMOD definition - DONE
_asim = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip, _abin],
    hardware_type="ASIM",
    hardware_version="475765A",
    serial_number="L1234204987",
    pdu_port=_pdu1.pdu_ports[5],
)

_smods = Airscale([_asim])


_du = DU(_smods)

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.45.173.41"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

# Real BTS definition - DONE
_gnb = ClassicalBts(cu=_cu_1, dus=[_du], global_bts_id=50008, instance_id=50008)


_test_pc = TestPc(
    SshServiceDetails(addr="10.45.172.21", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_gnb],
    tl_cloud_topology="CLOUD_7_16_WPT_WRO21_SEACONTAINER",
    ues=[_ue1],
    attenuators=[],
    pdus=[_pdu1, _pdu2],
)

__all__ = ["tl"]
