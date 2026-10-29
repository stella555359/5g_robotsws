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
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.core import RealCore5G
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


__all__ = ["tl"]

# AppServer to download Factory RFSW Package
_appserver_siso_ssh = SshServiceDetails(
    addr="10.42.54.121", username="ute", password="oZPS0POrRieRtu"
)
_iperf_siso = IperfDataTransferDetails(ssh_connection_details=_appserver_siso_ssh)
_appserver_siso = AppServer(iperf_details=_iperf_siso)

_pdu_gnb = Gude(addr="10.44.205.26", port_numbers=[5], model="EPC", version="8221-1")
_pdu_enb = Gude(addr="10.44.205.26", port_numbers=[8], model="EPC", version="8221-1")
_pdu_gnb_ru1 = Gude(
    addr="10.44.205.44", port_numbers=[1, 2], model="EPC", version="8221-1"
)
_pdu_gnb_ru2 = Gude(
    addr="10.44.205.162", port_numbers=[8], model="EPC", version="8221-1"
)
_pdu_enb_ru = Gude(addr="10.44.205.28", port_numbers=[1], model="EPC", version="8221-1")

_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AEQP",
    serial_number="1M213624052",
    product_code="475238A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.119", port=3000, username=""),
    pdu_port=_pdu_gnb_ru1.pdu_ports[1],
)

_ru_2 = RU(
    ru_hw_group="cMAAr6.2_8T8R",
    radio_type="AKQJ",
    serial_number="1M220223975",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.6",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.120", port=3000, username=""),
    pdu_port=_pdu_gnb_ru1.pdu_ports[2],
)

_ru_3 = RU(
    ru_hw_group="cMAA_Gen4.0_32T32R",
    radio_type="AZQJ",
    serial_number="1M222400716",
    product_code="475244A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.158",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.121", port=3000, username=""),
    pdu_port=_pdu_gnb_ru2.pdu_ports[8],
)

_abio_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211200999",
    rus=[_ru_1, _ru_2, _ru_3],
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A102",
    serial_number="DH203665927",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.203",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2913", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2913", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2913", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50173
)

_abia_enb_1 = CapacityUnit(addr="192.168.253.20")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[8],
    serial_number="AH184015002",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c:0000:0000:0000:2914", vlan_id=401
    ),
    rms=[
        RU(
            ru_hw_group="5Ggen3_HighF_2T2R",
            radio_type="FRGS",
            serial_number="L6150767459",
            pdu_port=_pdu_enb_ru.pdu_ports[1],
        )
    ],
    global_bts_id=40173,
    instance_id=40173,
    oam_ip=NetworkAddress(v4="10.44.67.233"),
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.126", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1],
)

_lmp_vm_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.242", username="ute", password="ute"
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
    serial_number="HZQN1876AAKA1500131",
    ue_pc_address="10.42.22.168",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.168", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    data_transfer=[_nokia_iperf],
    # is_rooted="yes",
    # airplane_mode_switcher_text="Tryb samolotowy",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb, _lmp_vm_enb],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_7_16_UTE5GSISOAUTO008",
    pdus=[_pdu_gnb, _pdu_gnb_ru1, _pdu_gnb_ru2, _pdu_enb, _pdu_enb_ru],
    appservers=[_appserver_siso],
    core=_core,
)
