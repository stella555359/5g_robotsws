__maintainer__ = "Dawid Urbanski"
__team__ = "MN RAN RD VRF WRO1 4"
__email__ = "dawid.1.urbanski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.attenuator import TopYoung

__all__ = ["tl"]


_pdu_gnb = Gude(
    addr="10.44.200.105", port_numbers=[1, 2], model="EPC", version="8221-1"
)
_pdu_gnb_ru = Gude(
    addr="10.44.200.104",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 12],
    model="EPC",
    version="8220-1",
)
_pdu_gnb_ru2 = Gude(
    addr="10.44.200.105",
#    port_numbers=[7, 8, 9, 10, 11, 12],
    port_numbers=[7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_ru1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHGB",
    serial_number="EB195260132",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[12],
)
_ru2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHFIA",
    serial_number="K9192534006",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)
_ru3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHFIA",
    serial_number="K9192534001",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
)
_ru4 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQJ",
    serial_number="1M222701711",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
)
# Pożyczone do 1_5
# _ru5 = RU(
#     ru_hw_group="5Ggen3_HighF_2T2R",
#     radio_type="AHEJ",
#     serial_number="EB192761156",
#     default_ssh_connection_details=SshServiceDetails(
#         addr="",
#         username="rfsw",
#         password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
#     ),
#     pdu_port=_pdu_gnb_ru2.pdu_ports[9],
#)
_ru6 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQI",
    serial_number="1M223114029",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
)
_ru7 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHFIB",
    serial_number="BL2240V0BFK",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)
_ru8 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHFB",
    serial_number="AH192700297",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[11],
)
_ru9 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHFIB",
    serial_number="BL2240V0BFM",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)
_ru10 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHEB",
    serial_number="EA194755008",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
)
_ru11 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHEJ",
    serial_number="EB191760016",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[10],
)
_ru12 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHHA",
    serial_number="EA190410025",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[7],
)
_ru13 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHHA",
    serial_number="EA190410034",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[8],
)
_ru14 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHEB",
    serial_number="EA192970470",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[7],
)

_ru15 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQI",
    serial_number="1M223114019",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[12],
)

_abin1_primary = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="A103",
    serial_number="L1213615840",
    rus=[_ru1],
)

_abiq2_primary = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIQ",
    hardware_version="A101",
    serial_number="L1232102428",
    rus=[_ru2, _ru3, _ru4],
)

_abip3_primary = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1232907332",
#    rus=[_ru5, _ru6],
    rus=[_ru6],
)

_abia4_secondary = CapacityUnit(
    addr="192.168.253.29",
    hardware_type="ABIA",
    hardware_version="A103",
    serial_number="L1181620162",
    rus=[_ru7, _ru8, _ru9],
)
_abip5_secondary = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1232907333",
    rus=[_ru10, _ru11],
)
_abio6_secondary = CapacityUnit(
    addr="192.168.253.27",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211508290",
    rus=[_ru12, _ru13, _ru14],
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abin1_primary, _abiq2_primary, _abip3_primary],
    pdu_port=_pdu_gnb.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1224805754",
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia4_secondary, _abip5_secondary, _abio6_secondary],
    pdu_port=_pdu_gnb.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH220345102",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_primary, _asil_gnb_secondary])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[
        _ru1,
        _ru2,
        _ru3,
        _ru4,
        # _ru5,
        _ru6,
        _ru7,
        _ru8,
        _ru9,
        _ru10,
        _ru11,
        _ru12,
        _ru13,
        _ru14,
        _ru15,
    ],
)

_cu_gnb = CU(
    backhaul_site_oam_ip="10.42.84.44",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:600c::1b12", vlan_id=517),
    x2u=NetworkAddress(v6="2a00:8a00:6000:600c::1b12", vlan_id=517),
    s1u=NetworkAddress(v6="2a00:8a00:6000:600c::1b12", vlan_id=517),
)

_cbts = ClassicalBts(cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50113)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.70", username="ute", password="uteUTE!"
    ),
    connections=[_asil_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.71", username="ute", password="uteUTE!"
    ),
    connections=[_asil_gnb_secondary],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_asus = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.122", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="NAAIOC190156GDM",
    ue_pc_address="10.44.72.122",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    network_mode_switch_method="secretcode",
    ue_pc_port="80",
    secret_code="*#*#4636#*#*",
    airplane_mode_switcher_text="Airplane mode",
)


_attenuator = TopYoung(
    ip_addr="10.42.54.157", port=3001, attenuation_port_numbers=range(1, 24), serial_number="30022062923"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],
    ues=[_asus],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASILLR_ABINB1_ABIQB2_ABIPB3B5_ABIAB4_ABIOB6"
    "_2xAHEB_2xAHEJ_2xAHFIA_2xAHFIB_AHGB_2xAHHA_2xAZQI_AZQJ_SA",
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_gnb_ru2],
    attenuators=[_attenuator],
)
