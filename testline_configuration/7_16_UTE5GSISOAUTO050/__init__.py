__team__ = "MN RAN RD VRF WRO1 4"
__maintainer__ = "Sylwia pawlak"
__email__ = "sylwia.pawlak@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, CoreUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
	TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.205.169", port_numbers=[7], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.205.158", port_numbers=[2, 5, 6, 9, 10], model="EPC", version="8221-1"
)

_ru_1 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="NQ232692079",
    product_code="476383A.108",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.255.33.207", port=3000)])
)

_ru_2 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="NQ232692062",
    product_code="476383A.108",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.255.33.206", port=3000)])
)

_ru_3 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="NQ232691554",
    product_code="476383A.108",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[2],
    lmi=SerialOverTcp(uart_mapping=[Remote(addr="10.255.33.205", port=3000)])    
)

_ru_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="K9200910586",
    product_code="474119A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[10],
)

_ru_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="K9194304163",
    product_code="474119A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)

_asoe_gnb_1 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_gnb.pdu_ports[7],
    hardware_type="ASOE",
    hardware_version="A103",
    serial_number="DH224811555",
	rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5]
)


_airscale_gnb_1 = Airscale(core_units=[_asoe_gnb_1])

_du_1_gnb_1 = DU(_airscale_gnb_1)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.78.40",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::3f1e", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::3f1e", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::3f1e", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50161, instance_id=50161
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.119", username="ute", password="uteUTE!"
    ),
    connections=[
    	Connection(
    		interface="eth1",
    		device=_cbts.dus[0].airscale.core_units[0],
    		interface_type="lmp",
    		)
    ],
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

_oneplus = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.236", username="plwrranvrf1", password="Diabetes3-Clash-Huff"
    ),
    serial_number="M9AIKN01N511F26",
    ue_pc_address="10.42.224.236",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    ue_pc_port="80",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    ues=[_oneplus],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_3xAQQJ+2xAHPB_SA_RIJO",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)
