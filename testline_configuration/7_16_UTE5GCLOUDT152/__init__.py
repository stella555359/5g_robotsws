__maintainer__ = "Wiktor Jarosiński"
__email__ = "wiktor.jarosinski@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import JFW
from taf.config.testline.lmi import SerialOverTcp, Remote
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
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.flexi import Flexi
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

_attenuator = JFW(
    ip_addr="10.42.54.118",
    port=3001,
    attenuation_port_numbers=range(1, 17),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

_test_pc_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.32", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.33", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

#PDU definition
_pdu1 = Gude(addr="10.44.206.13", port_numbers=[2], model="EPC", version="8221-1")
_pdu2 = Gude(addr="10.44.205.60", port_numbers=[1, 3, 4, 5], model="EPC", version="8221-1")
_pdu3 = Gude(addr="10.44.205.104", port_numbers=[6], model="EPC", version="8221-1")
_pdu4 = Gude(addr="10.44.205.59", port_numbers=[4], model="EPC", version="8221-1")
_pdu5 = Gude(addr="10.44.205.242", port_numbers=[3])
_pdus = [_pdu1, _pdu2, _pdu3, _pdu4, _pdu5]

#RUs definition
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[1],
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2106G10JI",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.31"), port=5001)]
    )
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[4],
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2048G1RDO",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.28"), port=5001)]
    )
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[5],
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2048G1RDS",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.29"), port=5001)]
    )
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.134", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu4.pdu_ports[4],
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL1945V00GE",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.32"), port=5001)]
    )
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.134", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="K9184922734",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.30"), port=5001)]
    )
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.134", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu5.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2231V05JG",
    lmi=SerialOverTcp(
        uart_mapping=[Remote(addr=NetworkAddress(v4="10.255.38.33"), port=5001)]
    )
)

#BBMOD
_abil = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1194704812",
    rus=[_ru_1, _ru_2, _ru_3]
)

_abia_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163900499",
    rus=[_ru_4, _ru_5, _ru_6]
)

_abia_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171212629",
    rus=[_ru_1, _ru_2, _ru_3]
)

#SMOD
_asik_gnb = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="L1191110020",
    pdu_port=_pdu1.pdu_ports[2],
    capacity_units=[_abil]
)
_asia_enb = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="K9170426206",
    pdu_port=_pdu3.pdu_ports[6],
    capacity_units=[_abia_1, _abia_2]
)

_smod_gnb = Airscale([_asik_gnb])
_smod_enb = Airscale([_asia_enb])

_cu_smod_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.68.140"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du_smod_gnb = DU(_smod_gnb)

_gnb_nr_1 = ClassicalBts(cu=_cu_smod_gnb, dus=[_du_smod_gnb], global_bts_id=50051, instance_id=50051)
_test_pc_gnb_1.connections.append(Connection(interface="eth1",
                                             device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))

_enb_sbts = RealEnb(
    system_module=_smod_enb,
    rms=[_ru_4, _ru_5, _ru_6],
    oam_ip=NetworkAddress("10.44.79.13"),
    global_bts_id=40051,
    instance_id=40051,
)

_enb_sbts.m = NetworkAddress(v4="10.44.79.13")

_test_pc_enb.connections.append(_enb_sbts.system_module.common_units[0])

_app_server = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
    expected_prompt="dummy_prompt",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server, interval=1, version=2
)

_Samsung_S24 = TafUeAndroid(
    serial_number="R5CRB21FPYW",
    capabilities=["REAL_UE", "REAL_UE_CA", "REAL_ANDROID_UE", "OPERATORO", "R5CRB21FPYW"],
    ue_pc_address="10.42.215.106",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.215.106", username="wro5grrm", password="5gpass!1"
    ),
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Off|On",
)

tl = TestLine(
    test_pc=_test_pc_gnb_1,
    test_pcs=[_test_pc_gnb_1, _test_pc_enb],
    enbs=[_enb_sbts],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1_ABIOB2B3_2xAEHC_AHFIB_3xAHLOA",
    ues=[_Samsung_S24],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
