__maintainer__ = "Pawel Woloszyn"
__team__ = "MN RAN Pz 1 WRO 4 SG"
__email__ = "pawel.woloszyn@nokia.com"

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
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

__all__ = ["tl"]

_pdu_gnb = Gude(
    addr="10.44.205.244", port_numbers=[3, 10], model="EPC", version="8221-1"
)
_pdu_gnb_ru = Gude(
    addr="10.44.205.17", port_numbers=[5, 8], model="EPC", version="8221-1"
)

_ru1 = RU(
    ru_hw_group="5Ggen3_LowF_64T64R",
    radio_type="AQQL",
    serial_number="L1230301087",
    product_code="476136A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.107", port=3000, username=""),
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
)

_ru2 = RU(
    ru_hw_group="5Ggen3_LowF_4T4R",
    radio_type="AHFII",
    serial_number="BL2316N44XQ",
    product_code="475656A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.108", port=3000, username=""),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)

_abip1_primary = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="A101",
    serial_number="L1232004079",
    product_code="475792A.101",
    rus=[_ru1],
)

_abip2_primary = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="A101",
    serial_number="L1232004082",
    product_code="475792A.101",
    rus=[_ru1],
)

_abiq_secondary = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIQ",
    hardware_version="A102",
    serial_number="L1233003912",
    product_code="476397A.102",
    rus=[_ru1, _ru2],
)

_abin_secondary = CapacityUnit(
    addr="192.168.253.29",
    hardware_type="ABIN",
    hardware_version="A103",
    serial_number="L1213706093",
    product_code="474824A.103",
    rus=[_ru2],
)
_abia_secondary = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="A104",
    serial_number="EA193577551",
    product_code="473096A.104",
    rus=[_ru2],
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip1_primary, _abip2_primary],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH214945904",
    product_code="474767A.101",
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abiq_secondary, _abin_secondary, _abia_secondary],
    pdu_port=_pdu_gnb.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH220845013",
    product_code="474767A.101",
)

_airscale_gnb_1 = Airscale(
    common_units=[_asil_gnb_primary, _asil_gnb_secondary], 
    product_code="473098A",
)

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru1, _ru2])

_cu_gnb = CU(
    backhaul_site_oam_ip="10.44.67.217",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::292f", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::292f", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::292f", vlan_id=401),
)

_cbts = ClassicalBts(cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50522)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.137", username="ute", password="uteUTE!"
    ),
    connections=[_asil_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.138", username="ute", password="uteUTE!"
    ),
    connections=[_asil_gnb_secondary],
)
_core = RealCore5G()
_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.197.170",
    user="syslab",
    password="system",
    bind_interface_ip="10.42.197.170",
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_ue = TafUeAndroid(
    serial_number="HZQN1876BAK90102707",
    ue_pc_address="10.42.224.170",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.170", username="wro5goam", password="Uteadmin1@"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    data_transfer=[_iperf],
    # is_rooted="yes",
    # airplane_mode_switcher_text="Airplane mode",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],
    ues=[_ue],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_7_16_UTE5GSISOAUTO022",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
    core=_core,
)
