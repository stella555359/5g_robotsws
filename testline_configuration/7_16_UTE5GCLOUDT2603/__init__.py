__maintainer__ = "Dawid Lagiewka"
__team__ = "MN RAN RD VRF WRO2 6"
__email__ = "MN_RAN_RD_VRF_WRO2_6@internal.nsn.com"
__owner_email__ = "dawid.lagiewka@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import JFW
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import (
    NetworkAddress,
    RoutingInformation,
    TafUeDataTransferProtocol,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.flexi import Flexi
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer

_test_pc_asim_l = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.75.49", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_asim_r = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.75.50", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# PDU definition
# PORTS: 4 - ASIM
_pdu_1 = Gude(addr="10.44.200.190", port_numbers=[4],                   model="EPC",  version="8041-1")
# PORTS: 1, 3, 7 - AHLOBs | 2, 4, 8 - AHFIIs
_pdu_2 = Gude(addr="10.44.200.185", port_numbers=[1, 2, 3, 4, 7, 8],    model="EPC",  version="8041-1")
# PORTS: 5 - AEHC
_pdu_3 = Gude(addr="10.44.200.186", port_numbers=[5],                   model="EPC",  version="8041-1")
# PORTS: 5, 6 - AEHCs
_pdu_4 = Gude(addr="10.44.200.191", port_numbers=[5, 6],                model="EPC",  version="8041-1")
# PDUs LIST
_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_ue_pc_ssh = SshServiceDetails("10.42.224.231", "plwr4gsfe", password="ltesfe4@")

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
    expected_prompt="dummy_prompt",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_app_server_1,
    interval=1,
    version=2
)

_attenuator = JFW(
    ip_addr="10.42.221.159",
    port=3001,
    attenuation_port_numbers=range(1, 24),
    model="TAS_24T24ID_NSW_11_07_05",
)

# RUs definition
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[1],
    ru_hw_group="",
    radio_type="AHLOB",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHLOB",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[7],
    ru_hw_group="",
    radio_type="AHLOB",
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHFII",
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[4],
    ru_hw_group="",
    radio_type="AHFII",
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[8],
    ru_hw_group="",
    radio_type="AHFII",
)

_ru_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_3.pdu_ports[5],
    ru_hw_group="",
    radio_type="AEHC",
)

_ru_8 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_4.pdu_ports[5],
    ru_hw_group="",
    radio_type="AEHC",
)

_ru_9 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_4.pdu_ports[6],
    ru_hw_group="",
    radio_type="AEHC",
)

_abip_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6]
)
_abip_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    rus=[_ru_7, _ru_8, _ru_9]
)

_abia_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    rus=[_ru_1, _ru_2, _ru_3]
)
_abio_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    rus=[_ru_4, _ru_5, _ru_6]
)

_asim_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    pdu_port=_pdu_1.pdu_ports[4],
    capacity_units=[_abip_1, _abio_1, _abia_1]
)
_asim_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    pdu_port=_pdu_1.pdu_ports[4],
    capacity_units=[_abip_2]
)

_smods = Airscale([_asim_left, _asim_right])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.88.15"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(_smods)

_gnb = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=55270, instance_id=55270)

_test_pc_asim_l.connections.append(Connection(interface="eth1",
                                             device=_gnb.dus[0].airscale.common_units[0], interface_type="lmp"))
_test_pc_asim_r.connections.append(Connection(interface="eth1",
                                             device=_gnb.dus[0].airscale.common_units[1], interface_type="lmp"))

_core = RealCore5G(mcc=310, mnc=260)

_s23_1 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.231",
    serial_number="RFCW20DYZKR",
    capabilities=["RFCW20DYZKR", "REAL_UE", "SamsungS23"],
    data_transfer=[_data_transfer_iperf_1],
    service_call_attach="16",
    service_call_detach="16",
)

_s23_2 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.224.231",
    serial_number="RFCW21FQ70F",
    capabilities=["RFCW21FQ70F", "REAL_UE", "SamsungS23"],
    data_transfer=[_data_transfer_iperf_1],
    service_call_attach="16",
    service_call_detach="16",
)

tl = TestLine(
    test_pc=[_test_pc_asim_l],
    test_pcs=[_test_pc_asim_l, _test_pc_asim_r],
    gnbs=[_gnb],
    core=_core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ATT_ASIML_ASIMR_2xABIP_ABIA_ABIO_3xAHLOB_3xAHFII_3xAEHC",
    ues=[_s23_1, _s23_2],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
