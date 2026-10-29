__maintainer__ = "Emilia Pawlaszek"
__team__ = "MN RAN Pz 1 WRO 9 SG"
__email__ = "emilia.pawlaszek@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.core import RealCore5G
from taf.config.testline.ue import Android


from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

__all__ = ["tl"]
_pdu_gnb = Gude(addr="10.44.200.105", port_numbers=[3], model="EPC", version="8221-1")
_pdu_enb = Gude(addr="10.44.200.105", port_numbers=[4], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.200.104", port_numbers=[9, 10], model="EPC", version="8220-1"
)
_pdu_enb_ru = Gude(addr="10.44.200.105", port_numbers=[5], model="EPC", version="8221-1")
_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQO",
    serial_number="1M204844256",
    product_code="475288A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[10],
    lmp_connection=SshServiceDetails(addr="10.42.142.54", port=2003, username="")
)
_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQO",
    serial_number="1M204844262",
    product_code="475288A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
    lmp_connection=SshServiceDetails(addr="10.42.142.53", port=2003, username="")
)
_abio_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="B101",
    serial_number="L1223310054",
    rus=[_ru_1, _ru_2],
)
_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A102",
    serial_number="L1230610666",

)
_airscale_gnb_1 = Airscale(common_units=[_asim_gnb_1])
_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2])
_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.84.252",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.42.84.252", vlan_id=517),
    x2u=NetworkAddress(v4="10.42.84.252", vlan_id=517),
    s1u=NetworkAddress(v4="10.42.84.252", vlan_id=517),
)
_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50197, instance_id=50197
)

_abia_enb_1 = CapacityUnit(addr="192.168.253.20")
_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[4],
    serial_number="L1173012627",
)
_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])
_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    airscale=_airscale_enb_1,
    global_bts_id=40197,
    instance_id=40197,
    rms=[
        RU(
            ru_hw_group="5Ggen3_HighF_2T2R",
            radio_type="AHGB",
            serial_number="EB232960268",
            default_telnet_connection_details=TelnetConnectionDetails(
                addr="172.16.9.129", port=2323
            ),
            pdu_port=_pdu_enb_ru.pdu_ports[5],
            attenuation_ports=[],
        )
    ],
    oam_ip=NetworkAddress(v4="10.42.84.253"),
)
_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.214", username="ute", password="ute"
    ),
    connections=[_asim_gnb_1],

)
_lmp_vm_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.201", username="ute", password="ute"
    ),
    connections=[_enb_1],
)
_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53", user="5g", password="2019H@slo",
    bind_interface_ip="10.45.168.53",


)

_one_plus_iperf = TafUeDataTransferProtocol(
    app_server=_appserver_ssh,
    protocol_name="iperf",


)

_one_plus = TafUeAndroid(
    serial_number="8bb57286",
    ue_pc_address="10.42.22.92",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.92", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_one_plus_iperf],
    is_rooted=True,
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb, _lmp_vm_enb],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_one_plus],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIML_ABIOB1_2xAZQO_ENB ",
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb, _pdu_enb_ru],
)
