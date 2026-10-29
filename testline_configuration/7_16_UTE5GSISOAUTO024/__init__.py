__maintainer__ = "Urszula Plocienniczak"
__team__ = "MN RAN Pz 1 WRO 4 SG"
__email__ = "urszula.plocienniczak@nokia.com"

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
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]

_pdu_enb = Gude(addr="10.44.205.27", port_numbers=[2], model="EPC", version="8221-1")
_pdu_gnb_L = Gude(addr="10.44.205.27", port_numbers=[3], model="EPC", version="8221-1")
_pdu_gnb_P = Gude(addr="10.44.205.27", port_numbers=[4], model="EPC", version="8221-1")
_pdu_enb_ru = Gude(addr="10.44.205.28", port_numbers=[10], model="EPC", version="8221-1")
_pdu_enb_ru2 = Gude(addr="10.44.205.28", port_numbers=[9], model="EPC", version="8221-1")
_pdu_gnb_ru1 = Gude(addr="10.44.205.28", port_numbers=[7], model="EPC", version="8221-1")
_pdu_gnb_ru2 = Gude(addr="10.44.205.80", port_numbers=[9, 10, 11], model="EPC", version="8221-1")
_pdu_gnb_ru3 = Gude(addr="10.44.205.81", port_numbers=[1, 2, 3, 4], model="EPC", version="8221-1")

_lte_ru = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHGB",
    serial_number="EB211260249",
    product_code="474514A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_enb_ru.pdu_ports[10],
)

_ru1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQJ",
    serial_number="YK203400324",
    product_code="475244A.101",
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.255.33.184", port=3000)
    ]), 
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[10],
)

_ru2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQP",
    serial_number="1M203439991",
    product_code="475198A.102",
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.255.33.196", port=3000)
    ]), 
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[1],
)

_ru3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AKQJ",
    serial_number="1M222600292",
    product_code="475824A.101",
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.255.33.98", port=3000)
    ]), 
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[4],
)

_ru4 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AREA",
    serial_number="EA201653453",
    product_code="474198A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[7],
)

_ru5 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQI",
    serial_number="1M203838367",
    product_code="475243A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[3],
)

_ru6 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQJ",
    serial_number="1M222701742",
    product_code="475244A.101",
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.255.33.192", port=3000)
    ]), 
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[2],
)

_ru7 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHPB",
    serial_number="K9191623363",
    product_code="474119A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[9],
)

_ru8 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQS",
    serial_number="4H210530066",
    product_code="475664A.101",
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.42.142.38", port=3000)
    ]),
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[11],
)

_abil1_primary = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="A102",
    serial_number="L1184207718",
    product_code="474020A.102",
    rus=[_ru1],
)

_abio2_primary = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211508265",
    product_code="475266A.103",
    rus=[_ru2, _ru3, _ru8],
)

_abil3_primary = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIL",
    hardware_version="A102",
    serial_number="L1184207716",
    product_code="474020A.102",
    rus=[_ru4],
)

_abio4_secondary = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211508263",
    product_code="475266A.103",
    rus=[_ru5],
)

_abil5_secondary = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIL",
    hardware_version="A101",
    serial_number="L1182314237",
    product_code="474020A.101",
    rus=[_ru6],
)

_abio6_secondary = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1205102685",
    product_code="475266A.102",
    rus=[_ru7],
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_primary, _abio2_primary, _abil3_primary],
    pdu_port=_pdu_gnb_L.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1213704461",
    product_code="474767A.101",
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio4_secondary, _abil5_secondary, _abio6_secondary],
    pdu_port=_pdu_gnb_P.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1224505489",
    product_code="474767A.103",
)

_airscale_gnb_1 = Airscale(
    common_units=[_asil_gnb_primary, _asil_gnb_secondary],
    product_code="473098A",
)

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
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2933", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2933", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2933", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50524)

_abia_enb = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A103",
    serial_number="L1172902570",
    rus=[_lte_ru],
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb],
    pdu_port=_pdu_enb.pdu_ports[2],
    serial_number="6Q174625776",
    hardware_type="ASIA",
    hardware_version="A203",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    rms=[_lte_ru],
    system_module=_airscale_enb_1,
    airscale=_airscale_enb_1,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c:0000:0000:0000:2934", vlan_id=401
    ),
    global_bts_id=40524,
    instance_id=40524,
    oam_ip=NetworkAddress(v4="10.44.67.249"),
)

_enb_2 = RealEnb(
    system_module=_airscale_enb_1,
    airscale=_airscale_enb_1,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c:0000:0000:0000:292b", vlan_id=370
    ),
    rms=[
        RU(
            ru_hw_group="5Ggen3_HighF_2T2R",
            radio_type="AHGB",
            serial_number="EB211660410",
            pdu_port=_pdu_enb_ru2.pdu_ports[9],
        )
    ],
    global_bts_id=40520,
    instance_id=40520,
    oam_ip=NetworkAddress(v4="10.44.67.245"),
)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.190", username="ute", password="ute"
    ),
    connections=[_asil_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.191", username="ute", password="ute"
    ),
    connections=[_asil_gnb_secondary],
)

_lmp_vm_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.220", username="ute", password="ute"
    ),
    connections=[_enb_1],
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

_asus = TafUeAndroid(
    ue_pc_address="10.42.22.167",
    serial_number="M6AIKN009189BLZ",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.167", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    data_transfer=[_nokia_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    is_rooted=True,
)

# NOKIA
_nokia = TafUeAndroid(
    serial_number="a83be7f8",
    ue_pc_address="10.42.22.161",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.161", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_nokia_iperf],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary, _lmp_vm_enb],
    gnbs=[_cbts],
    enbs=[_enb_1, _enb_2],
    ues=[_asus, _nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASILLR_ABILB1B3B5_ABIOB2B4B6_AHPB_AREA_AZQI_2xAZQJ_2xAZQO_ENB",
    pdus=[_pdu_gnb_L, _pdu_gnb_P, _pdu_enb, _pdu_enb_ru, _pdu_enb_ru2, _pdu_gnb_ru1, _pdu_gnb_ru2, _pdu_gnb_ru3],
)
