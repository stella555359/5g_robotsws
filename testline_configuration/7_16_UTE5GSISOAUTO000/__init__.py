__maintainer__ = "Jakub Rychlik"
__team__ = "MN RAN Pz 1 WRO 4 SG"
__email__ = "jakub.rychlik@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.core import RealCore5G
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer

__all__ = ["tl"]

_pdu_gnb_L = Gude(addr="10.44.205.26", port_numbers=[1], model="EPC", version="8221-1")
_pdu_gnb_P = Gude(addr="10.44.205.26", port_numbers=[2], model="EPC", version="8221-1")

_pdu_gnb_ru1 = Gude(addr="10.44.205.81", port_numbers=[5, 7, 8, 9, 10, 12], model="EPC", version="8221-1")
_pdu_gnb_ru2 = Gude(addr="10.44.205.162", port_numbers=[1], model="EPC", version="8221-1")
_pdu_gnb_ru3 = Gude(addr="10.44.205.28", port_numbers=[2], model="EPC", version="8221-1")

_ru1 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AEQA",
    serial_number="6Q185221574",
    product_code="474212A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[9],
)

_ru2 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AEQN",
    serial_number="CV192400997",
    product_code="474736A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[5],
)

_ru3 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AKQJ",
    serial_number="1M222600204",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[12],
)

_ru4 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AZQS",
    serial_number="4H210530070",
    product_code="475664A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[10],
)

_ru5 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AZQW",
    serial_number="YK212300024",
    product_code="475742A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[8],
)

_ru6 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AZQU",
    serial_number="4H210530085",
    product_code="475665A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[1],
)

_ru7 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AREA",
    serial_number="EA201653451",
    product_code="474198A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[2],
)

_ru8 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AZTA",
    serial_number="1M214914361",
    product_code="475741A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[7],
)

_abil1_primary = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="A101",
    serial_number="EA194457579",
    rus=[_ru1],
)

_abil2_primary = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIL",
    hardware_version="A101",
    serial_number="L1200601046",
    rus=[_ru2],
)

_abil3_primary = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1192307427",
    rus=[_ru3, _ru4],
)

_abio1_secondary = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1222905766",
    rus=[_ru5],
)

_abio2_secondary = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1213905423",
    rus=[_ru6, _ru8],
)

_abin_secondary = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIN",
    hardware_version="A102",
    serial_number="L1213805971",
    rus=[_ru7],
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_primary, _abil2_primary, _abil3_primary],
    pdu_port=_pdu_gnb_L.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1213709165",
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_secondary, _abio2_secondary, _abin_secondary],
    pdu_port=_pdu_gnb_P.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1211012393",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_primary, _asil_gnb_secondary])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1, rus=[_ru1, _ru2, _ru3, _ru4, _ru5, _ru6, _ru7, _ru8]
)

_cu_gnb = CU(
    backhaul_site_oam_ip="10.44.67.219",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::2918", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::2918", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::2918", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50131)


_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.93", username="ute", password="ute"
    ),
    connections=[_asil_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.234", username="ute", password="ute"
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

_nokia_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
    server_close_delay=50,
)

# _asus = TafUeAndroid(
#     ue_pc_address="10.44.72.65",
#     serial_number="M6AIKN007092GMK",
#     ssh_connection_details=SshServiceDetails(
#         addr="10.42.22.167", username="wro5gsiso", password="oZPS0POrRieRtu"
#     ),
#     data_transfer=[_nokia_iperf],
#     capabilities=["REAL_UE", "REAL_ANDROID_UE"],
#     is_rooted=True,
# )

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],
    ues=[],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASILLR_ABILB1B3B5_ABIOB2B4B6_AHPB_AREA_AZQI_2xAZQJ_2xAZQO",
    pdus=[_pdu_gnb_L, _pdu_gnb_P, _pdu_gnb_ru1, _pdu_gnb_ru2, _pdu_gnb_ru3],
)