__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__maintainer__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__email__ = "I_EXT_5G_SISO_CRT@internal.nsn.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAt, TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.177.143", port_numbers=[12], model="EPC", version="8221-1")
_pdu_1 = Gude(addr="10.44.177.10", port_numbers=[1, 3], model="EPC", version="8221-1")
_pdu_2 = Gude(addr="10.44.177.56", port_numbers=[3, 9], model="EPC", version="8221-1")
_pdu_3 = Gude(addr="10.44.177.57", port_numbers=[4, 5, 12], model="EPC", version="8221-1")
_pdu_4 = Gude(addr="10.44.177.88", port_numbers=[1, 6, 7], model="EPC", version="8221-1")

_ru_1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHCA",
    serial_number="AS201201033",
    product_code="473966A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    ),
    pdu_port=_pdu_3.pdu_ports[12],
)

_ru_2 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="L1230314344",
    product_code="476136A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_ru_3 = RU(
    ru_hw_group="FHFB:CPRI_RRH_4T4R",
    radio_type="FHFB",
    serial_number="K9200801260",
    product_code="473042A.202",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="3Is6ezFJ7dFlB29cgs0yp3RCM3fUF1zNO1+6Z08tlAc=",
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)

_ru_4 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHCA",
    serial_number="AS200704292",
    product_code="473966A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_3.pdu_ports[4],
)

_ru_5 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHCA",
    serial_number="1M193018858",
    product_code="473966B.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_4.pdu_ports[7],
)

_ru_6 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHCA",
    serial_number="AS201205503",
    product_code="473966A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)

_ru_7 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type="AQQL",
    serial_number="L1230314347",
    product_code="476136A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_ru_8 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHCA",
    serial_number="AS194201745",
    product_code="473966A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_4.pdu_ports[6],
)

_ru_9 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHCA",
    serial_number="L1181205006",
    product_code="473966A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_4.pdu_ports[1],
)

_ru_10 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHCA",
    serial_number="1M193018828",
    product_code="473966B.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)

_asog_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[12],
    hardware_type="ASOG",
    serial_number="L1241503087",
)

_airscale_gnb_1 = Airscale(common_units=[_asog_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8, _ru_9, _ru_10],
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.45.178.19",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:b42b", vlan_id=909),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b42b", vlan_id=909),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b42b", vlan_id=909),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50103, instance_id=50103
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.129", username="ute", password="ute"
    ),
    connections=[_asog_gnb_1],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_appserver_ssh,
    interval=1,
)

_android = TafUeAndroid(
    serial_number="5cbdde0b",
    ue_pc_address="10.42.22.135",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.135", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_data_transfer_iperf],
    network_mode_switch_method='secretcode',
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    ues=[_android],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOG_2xAQQL_7xAHCA_AHFB",
    pdus=[_pdu_gnb, _pdu_1, _pdu_2, _pdu_3, _pdu_4],
)
