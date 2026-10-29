__maintainer__ = "Tomasz Mozola"
__team__ = "MN RAN RD VRF WRO2 1"
__email__ = "tomasz.mozola@nokia.com"
__owner_email__ = "tomasz.mozola@nokia.com"


import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.attenuator import JFW
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
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
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.lmi import SerialOverTcp, Remote
from taf.config.testline.pdn import PDNTafUeAndroidDetails

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)


_pdn1 = PDNTafUeAndroidDetails(
    entryName="APN", apnName="internet", apnType=["DEFAULT"], protocol="IPV4"
)


_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    binary_path="/data/data/com.nokia.android.application/",
    interface_name="internet",
)


_UE_1 = TafUeAndroid(
    serial_number="dcc8dc1c",
    capabilities=["UE_QM", "UE_dcc8dc1c"],
    ue_pc_address="10.42.215.88",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.215.88", username="wro5grrm", password="5gpass!1"
    ),
    network_mode_switch_method="keyevents",
    path_to_network_mode_type="SIMs/Preferred network type",
    pdns=[_pdn1],
)


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_attenuator1 = TopYoung(
    ip_addr="10.42.75.86",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_24T24_02G6_90_1S_EJS",
)


_pdu_1 = Gude(
    addr="10.44.200.207",
    port_numbers=[5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)


_pdus = [_pdu_1]


# RUs
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[6],
    ru_hw_group="",
    radio_type="ARMA",
    serial_number="1M222101796",
)


_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[7],
    ru_hw_group="",
    radio_type="AREA",
    serial_number="EA191771361",
)


_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[8],
    ru_hw_group="",
    radio_type="ARGA",
    serial_number="K9224010603",
)


_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[10],
    ru_hw_group="",
    radio_type="AHPD",
    serial_number="6Q194505190",
)


_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[11],
    ru_hw_group="",
    radio_type="AHPD",
    serial_number="6Q190435462",
)


_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[12],
    ru_hw_group="",
    radio_type="AHPD",
    serial_number="6Q190435460",
)

_ru_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[5],
    ru_hw_group="",
    radio_type="ARCA",
    serial_number="F7194708291",
)

# BBMODs
_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214608118",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="	473096A.103",
    serial_number="L1172911437",
    rus=[_ru_7],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1241204345",
    rus=[],
)

# SMODs
_smod_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1215007749",
)


_smods = Airscale([_smod_left])

_test_pc_Master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.183", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.88.60"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(_smods)

_gnb = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=55197, instance_id=55197)

_test_pc_Master.connections.append(
    Connection(
        interface="eth1",
        device=_gnb.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)


_core = RealCore5G(mcc=310, mnc=260)

tl = TestLine(
    test_pc=_test_pc_Master,
    test_pcs=[_test_pc_Master],
    gnbs=[_gnb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ATT_ARMA_AREA_ARGA_3xAHPD_ARCA",
    ues=[_UE_1],
    attenuator=_attenuator1,
    attenuators=[_attenuator1],
    pdus=_pdus,
)

__all__ = ["tl"]
