__maintainer__ = "Pawel Wisniewski"
__team__ = "MN RAN RD VRF WRO2 1"
__email__ = "MN_RAN_RD_VRF_WRO2_1@internal.nsn.com"
__owner_email__ = "pawel.wisniewski@nokia.com"


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

_ue_pc_ssh = SshServiceDetails("10.42.22.148", "wro5grrm", password="5gpass!1")

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
    version=2,
    interface_name="internet"
)

_pdn1 = PDNTafUeAndroidDetails(
    entryName="APN", apnName="internet", apnType=["DEFAULT"], protocol="IPV4"
)


_s25 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.148",
    serial_number="RFCY22599MF",
    capabilities=["RFCY22599MF", "REAL_UE", "S25", "REAL_UE_SA"],
    data_transfer=[_data_transfer_iperf_1],
    qualcomm_prototype=True,
    service_call_attach="16",
    service_call_detach="16",
    pdns=[_pdn1],
)


_s25_2 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.148",
    serial_number="R5CRB21FPYW",
    capabilities=["R5CRB21FPYW", "S25_2", "REAL_UE"],
    data_transfer=[_data_transfer_iperf_1],
    qualcomm_prototype=True,
    service_call_attach="16",
    service_call_detach="16",
    pdns=[_pdn1],
)

_attenuator = JFW(
    ip_addr="10.42.54.100",
    port=3001,
    attenuation_port_numbers=range(1, 17),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

_test_pc_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.178", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.177", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu1 = Gude(addr="10.44.205.59", port_numbers=[1, 10], model="EPC", version="8221-1")


_pdu2 = Gude(addr="10.44.205.8", port_numbers=[7], model="EPC", version="8221-1")


_pdu4 = Gude(addr="10.44.177.63", port_numbers=[10, 11, 12], model="EPC", version="8221-1")


_pdu5 = Gude(addr="10.44.177.9", port_numbers=[4, 11, 12], model="EPC", version="8221-1")


_pdu6 = Gude(addr="10.44.206.13", port_numbers=[4, 6], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2, _pdu4, _pdu5, _pdu6]

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[1],
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2317N4515",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.6"), port=5001)]
    )
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[7],
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2331N4789",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.7"), port=5001)]
    )
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[10],
    ru_hw_group="",
    serial_number="BL2241D50OZ",
    radio_type="AHLOB",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.5"), port=5001)]
    )
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu5.pdu_ports[11],
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251001320",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr=NetworkAddress(v4="10.255.38.10"), port=5001),
            Remote(addr=NetworkAddress(v4="10.255.38.10"), port=5002),
        ]
    )
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu5.pdu_ports[4],
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251001319",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr=NetworkAddress(v4="10.255.38.8"), port=5001),
            Remote(addr=NetworkAddress(v4="10.255.38.8"), port=5002),
        ]
    )

)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu5.pdu_ports[12],
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251510239",
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr=NetworkAddress(v4="10.255.38.9"), port=5001),
            Remote(addr=NetworkAddress(v4="10.255.38.9"), port=5002),
        ]
    )
)

_ru_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu4.pdu_ports[10],
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="AH242902691",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.3"), port=5001)]
    )
)

_ru_8 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu4.pdu_ports[11],
    ru_hw_group="",
    radio_type="AHLOB",
    serial_number="AH242902859",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.4"), port=5001)]
    )
)

_ru_9 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="None", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu4.pdu_ports[12],
    ru_hw_group="",
    radio_type="AHFII",
    serial_number="BL2217N401Y",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.2"), port=5001)]
    )
)

_abip_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    rus=[_ru_1, _ru_2, _ru_3]
)
_abip_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    rus=[_ru_4, _ru_5, _ru_6]
)
_abip_3 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    rus=[_ru_7, _ru_8, _ru_9]
)

_asim_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    pdu_port=_pdu6.pdu_ports[6],
    capacity_units=[_abip_1]
)
_asim_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIM",
    pdu_port=_pdu6.pdu_ports[4],
    capacity_units=[_abip_2, _abip_3]
)

_smods = Airscale([_asim_left, _asim_right])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.68.138"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(_smods)

_gnb = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50067, instance_id=50067)

_test_pc_gnb_1.connections.append(Connection(interface="eth1",
                                             device=_gnb.dus[0].airscale.common_units[0], interface_type="lmp"))
_test_pc_gnb_2.connections.append(Connection(interface="eth1",
                                             device=_gnb.dus[0].airscale.common_units[1], interface_type="lmp"))


_core = RealCore5G(mcc=310, mnc=260)

tl = TestLine(
    test_pc=_test_pc_gnb_1,
    test_pcs=[_test_pc_gnb_1, _test_pc_gnb_2],
    gnbs=[_gnb],
    core = _core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1B2B3_3xAEQN_FRGU",
    ues=[_s25, _s25_2],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
