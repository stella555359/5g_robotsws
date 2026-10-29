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
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol


__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.251.17",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::fa10", vlan_id=38),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::fa10", vlan_id=38),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::fa10", vlan_id=38),
)

_pdu_gnb = Gude(addr="10.44.200.249", port_numbers=[11], model="EPC", version="8041-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.44.200.249", port_numbers=[6, 7, 8, 9, 10], model="EPC", version="8041-1"
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.177.146", port_numbers=[10, 11, 12], model="EPC", version="8221-1"
)

_gnb_ru_1 = RU(
    ru_hw_group="5Ggen4_LowF_32T32R",
    radio_type="AVQF",
    serial_number="1M251706793",
    product_code="476505A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[8],
)

_gnb_ru_2 = RU(
    ru_hw_group="5Ggen4_LowF_64T64R",
    radio_type="AEQP",
    serial_number="1M203239783",
    product_code="475238A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.6",
        username="serviceuser",
        password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[12],
)

_gnb_ru_3 = RU(
    ru_hw_group="5Ggen4_LowF_4T4R",
    radio_type="AZNA",
    serial_number="6Q190109590",
    product_code="473914A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129",
        username="root",
        password="",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[10],
)

_gnb_ru_4 = RU(
    ru_hw_group="5Ggen4_LowF_8T8R",
    radio_type="AZQO",
    serial_number="1M204519747",
    product_code="475288A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.10",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[9],
)

_gnb_ru_5 = RU(
    ru_hw_group="5Ggen4_LowF_64T64R",
    radio_type="AQNA",
    serial_number="L1224605017",
    product_code="093449A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.18",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[11],
)

_gnb_ru_6 = RU(
    ru_hw_group="5Ggen4_LowF_6R6T",
    radio_type="AREC",
    serial_number="L1252400860",
    product_code="476707A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129",
        username="serviceuser",
        password="WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[7],
)

_gnb_ru_7 = RU(
    ru_hw_group="5Ggen4_LowF_64T64R",
    radio_type="AEHC",
    serial_number="L1211203210",
    product_code="475124B.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.154",
        username="serviceuser",
        password="7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g=",
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[10],
)

_gnb_ru_8 = RU(
    ru_hw_group="5Ggen4_LowF_8T8R",
    radio_type="AKQZ",
    serial_number="K9252805624",
    product_code="475918A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.162",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[6],
)

_abio_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0101",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223303274",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5, _gnb_ru_6, _gnb_ru_7, _gnb_ru_8],
)

_abio_2 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0201",
    hardware_type="ABIO",
    hardware_version="475266B.102",
    serial_number="L1250309187",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5, _gnb_ru_6, _gnb_ru_7, _gnb_ru_8 ],
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1, _abio_2],
    pdu_port=_pdu_gnb.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1203903726",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.93", username="ute", password="ute"
    ),
    connections=[_asib_gnb_1],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50140, instance_id=50140
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

_nokia = TafUeAndroid(
    serial_number="HZQN1876BAK92100564",
    ue_pc_address="10.42.224.228",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.228", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    data_transfer=[_iperf],
    # is_rooted="yes",
    # airplane_mode_switcher_text="Tryb samolotowy",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    ues=[_nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_7_16_UTE5GSISOAUTO051",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2],
)
