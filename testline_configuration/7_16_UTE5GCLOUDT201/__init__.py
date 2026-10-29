__maintainer__ = "Wiktor Jarosinski"
__team__ = "MN RAN RD VRF WRO2 1"
__email__ = "MN_RAN_RD_VRF_WRO2_1@internal.nsn.com"
__owner_email__ = "wiktor.jarosinski@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import JFW
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.lmi import SerialOverTcp, Remote
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.ue import TafUeAndroid

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_ue_pc_ssh = SshServiceDetails("10.44.72.125", "wro5grrm", password="5gpass!1")

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
    expected_prompt="dummy_prompt",
)


_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_app_server_1,
    interval=1,
    version=2
)

_s24 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.44.72.125",
    serial_number="R3CX90HWCTK",
    capabilities=["R3CX90HWCTK", "REAL_UE", "SamsungS24"],
    data_transfer=[_data_transfer_iperf_1],
    service_call_attach="16",
    service_call_detach="16",
)

_attenuator = JFW(
    ip_addr="10.42.54.249",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

_test_pc_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.222", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu1 = Gude(addr="10.44.177.41", port_numbers=[1, 10,12], model="EPC", version="8221-1")


_pdu2 = Gude(addr="10.44.177.83", port_numbers=[1,2,3,4], model="EPC", version="8221-1")


_pdus = [_pdu1, _pdu2]


_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[10],
    ru_hw_group="",
    radio_type="AQQJ",
    serial_number="NQ233990051",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.53"), port=5001)]
    ),
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[1],
    ru_hw_group="",
    radio_type="AQQJ",
    serial_number="NQ233990043",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.54"), port=5001)]
    ),
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[12],
    ru_hw_group="",
    serial_number="NQ232490909",
    radio_type="AQQJ",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.55"), port=5001)]
    ),
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[4],
    ru_hw_group="",
    radio_type="AHPB",
    serial_number="K9191023953",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.50"), port=5001)]
    ),
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHPB",
    serial_number="K9194304168",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.51"), port=5001)]
    ),
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHPB",
    serial_number="NQ242611975",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.52"), port=5001)]
    ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ASOE",
    hardware_version="475587A.103",
    serial_number="DH224811539",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
)    

_asoe = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASOE",
    hardware_version="A.103",
    serial_number="DH224811539",
    pdu_port=_pdu2.pdu_ports[1],
    capacity_units=[_fsp_1],
)

_smods = Airscale([_asoe])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.88.65"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(_smods)

_gnb = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50043, instance_id=50043)

_test_pc_gnb_1.connections.append(Connection(interface="eth1",
                                             device=_gnb.dus[0].airscale.common_units[0], interface_type="lmp"))


_core = RealCore5G(mcc=244, mnc=8)

tl = TestLine(
    test_pc=_test_pc_gnb_1,
    test_pcs=[_test_pc_gnb_1],
    gnbs=[_gnb],
    core = _core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AHCA_AHFIB",
    ues=[_s24],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
