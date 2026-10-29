__maintainer__ = "???"
__team__ = "MN RAN Pz 1 WRO 4 SG"
__email__ = "dawid.1.urbanski@nokia.com"

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

_pdu_gnbs = Gude(addr="10.44.200.198", port_numbers=[3, 4], model="EPC", version="8221-1")
_pdu_rus = Gude(addr="10.44.200.195", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")


_ahfig_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHFIG",
    serial_number="BL2137W2PKA",
    product_code="475125A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="root",
        password="",
    ),
    pdu_port=_pdu_rus.pdu_ports[7],
)

_ahfig_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHFIG",
    serial_number="BL2220W2U01",
    product_code="475125A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="root",
        password="",
    ),
    pdu_port=_pdu_rus.pdu_ports[8],
)

_ahfig_ru_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHFIG",
    serial_number="BL2233W2DDD",
    product_code="475125A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="root",
        password="",
    ),
    pdu_port=_pdu_rus.pdu_ports[9],
)

_avqqa_ru_4 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQA",
    serial_number="L1241604988",
    product_code="476596A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    ),
    pdu_port=_pdu_rus.pdu_ports[4],
)

_avqqa_ru_5 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQA",
    serial_number="L1241908601",
    product_code="476596A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    ),
    pdu_port=_pdu_rus.pdu_ports[5],
)

_avqqa_ru_6 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AVQQA",
    serial_number="L1242002664",
    product_code="476596A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    ),
    pdu_port=_pdu_rus.pdu_ports[6],
)

_ahloa_ru_7 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHLOA",
    serial_number="BL1933G102N",
    product_code="474331A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="root",
        password="",
    ),
    pdu_port=_pdu_rus.pdu_ports[10],
)

_ahloa_ru_8 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHLOA",
    serial_number="BL2040G1M6R",
    product_code="474331A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="root",
        password="",
    ),
    pdu_port=_pdu_rus.pdu_ports[11],
)

_ahloa_ru_9 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AHLOA",
    serial_number="BL1933G10NV",
    product_code="474331A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="root",
        password="",
    ),
    pdu_port=_pdu_rus.pdu_ports[12],
)

_aehc_ru_10 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AEHC",
    serial_number="L1204708721",
    product_code="475124B.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="bdS%ztWG3v7%SjreCVA79wTPb",
    ),
    pdu_port=_pdu_rus.pdu_ports[1],
)

_aehc_ru_11 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AEHC",
    serial_number="K9223525805",
    product_code="475124B.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="bdS%ztWG3v7%SjreCVA79wTPb",
    ),
    pdu_port=_pdu_rus.pdu_ports[2],
)

_aehc_ru_12 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AEHC",
    serial_number="K9220328061",
    product_code="475124B.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="bdS%ztWG3v7%SjreCVA79wTPb",
    ),
    pdu_port=_pdu_rus.pdu_ports[3],
)


_abip_1_primary = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1233205604",
    rus=[_ahfig_ru_1, _ahfig_ru_2, _ahfig_ru_3, _ahloa_ru_7, _ahloa_ru_8, _ahloa_ru_9],
)

_abio_2_primary = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1214307727",
    rus=[_ahfig_ru_1, _ahfig_ru_2, _ahfig_ru_3],
)

_abia_3_primary = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIA",
    hardware_version="A102",
    serial_number="L1170111382",
    rus=[_ahloa_ru_7, _ahloa_ru_8, _ahloa_ru_9],
)

_abip_4_secondary = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1233105940",
    rus=[_aehc_ru_10, _aehc_ru_11, _aehc_ru_12],
)

_abip_5_secondary = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1233205605",
    rus=[_avqqa_ru_4, _avqqa_ru_5, _avqqa_ru_6],
)


_asim_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_1_primary, _abio_2_primary, _abia_3_primary],
    pdu_port=_pdu_gnbs.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A104",
    serial_number="L1233503514",
)

_asim_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_4_secondary, _abip_5_secondary],
    pdu_port=_pdu_gnbs.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="A104",
    serial_number="L1233503172",
)

_airscale_gnb_1 = Airscale(common_units=[_asim_gnb_primary, _asim_gnb_secondary])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1, rus=[_ahfig_ru_1, _ahfig_ru_2, _ahfig_ru_3,
                                   _avqqa_ru_4, _avqqa_ru_5, _avqqa_ru_6,
                                   _ahloa_ru_7, _ahloa_ru_8, _ahloa_ru_9,
                                   _aehc_ru_10, _aehc_ru_11, _aehc_ru_12],
)

_cu_gnb = CU(
    backhaul_site_oam_ip="10.44.207.22",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::3209", vlan_id=723),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::3209", vlan_id=723),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::3209", vlan_id=723),
)

_cbts = ClassicalBts(cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50612)


_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.147", username="ute", password="ute"
    ),
    connections=[_asim_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.148", username="ute", password="ute"
    ),
    connections=[_asim_gnb_secondary],
)


_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
)

_nokia_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_xiaomi = TafUeAndroid(
    ue_pc_address="10.42.22.48",
    serial_number="??????",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.167", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    data_transfer=[_nokia_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    is_rooted=True,
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],
    ues=[_xiaomi],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_FULLRACK_ASIMLR_ABIPB1B4B5_ABIOB2_ABIAB3_3xAHFIG_3xAVQQA_3xAHLOA_3xAEHC_TMO",
    pdus=[_pdu_gnbs, _pdu_rus],
)
