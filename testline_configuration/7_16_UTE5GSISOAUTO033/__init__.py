__maintainer__ = "Pawel Woloszyn"
__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__email__ = "pawel.woloszyn@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.205.180", port_numbers=[8], model="EPC", version="8221-1")
_pdu_enb = Gude(addr="10.44.205.180", port_numbers=[8], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.205.180", port_numbers=[3, 5, 6], model="EPC", version="8221-1"
)
_pdu_enb_ru = Gude(
    addr="10.44.205.180", port_numbers=[12], model="EPC", version="8221-1"
)

_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AKQJ",
    serial_number="1M220117635",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
#    lmp_connection=SshServiceDetails(addr="10.255.33.197", port=3000, username=""),
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)

_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQJ",
    serial_number="YK203400392",
    product_code="475244A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
#    lmp_connection=SshServiceDetails(addr="10.255.33.198", port=3000, username=""),
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
)

_ru_3 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQS",
    serial_number="1M223231298",
    product_code="475664A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
#    lmp_connection=SshServiceDetails(addr="10.255.33.199", port=3000, username=""),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)


_abio_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIN",
    hardware_version="A103",
    serial_number="L1213706139",
    rus=[_ru_1, _ru_2, _ru_3],
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="A102",
    serial_number="L1190601915",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.251.9",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::fa05", vlan_id=38),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::fa05", vlan_id=38),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::fa05", vlan_id=38),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50104, instance_id=50104
)

_abia_enb_1 = CapacityUnit(addr="192.168.253.20")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[8],
    serial_number="L1172907964",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    airscale=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::fa04", vlan_id=38),
    rms=[
        RU(
            ru_hw_group="5Ggen3_HighF_2T2R",
            radio_type="AHEJ",
            serial_number="EB192761233",
            pdu_port=_pdu_enb_ru.pdu_ports[12],
        )
    ],
    global_bts_id=40104,
    instance_id=40104,
    oam_ip=NetworkAddress(v4="10.44.251.8"),
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.186", username="ute", password="ute"
    ),
    connections=[_asib_gnb_1],
)

_lmp_vm_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.187", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_core = RealCore5G()

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.197.170",
    user="syslab",
    password="system",
    bind_interface_ip="10.42.197.170",
)

_nokia_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_nokia = TafUeAndroid(
    serial_number="HZQN1876AAKA1500049",
    ue_pc_address="10.42.22.127",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.127", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    data_transfer=[_nokia_iperf],
    #    is_rooted="yes",
    #    airplane_mode_switcher_text="Tryb samolotowy",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb, _lmp_vm_enb],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_7_16_UTE5GSISOAUTO033",
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb, _pdu_enb_ru],
    core=_core,
)
