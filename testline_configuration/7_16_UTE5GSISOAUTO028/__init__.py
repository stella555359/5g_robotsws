__maintainer__ = "Michal Tryba"
__team__ = "I_5G_SISO_CRT_GMS"
__email__ = "michal.tryba@nokia.com"

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
from taf.config.testline import RealEnb, TopYoung, Leoni
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::473b", vlan_id="525"),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::473b", vlan_id="525"),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::473b", vlan_id="525"),
)


_pdu_enb = Gude(addr="10.44.177.174", port_numbers=[2], model="EPC", version="8221-1")
_pdu_gnb = Gude(addr="10.44.177.174", port_numbers=[1], model="EPC", version="8221-1")
_pdu_enb_ru = Gude(
    addr="10.44.177.174", port_numbers=[7], model="EPC", version="8221-1"
)
_pdu_gnb_ru = Gude(
    addr="10.44.177.174", port_numbers=[5, 12], model="EPC", version="8221-1"
)


_ru1 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AZHL",
    serial_number="YK203400055",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[12],
)


_ru2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHCE",
    serial_number="EA185110068",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.129", username="root", password=""
    ),
    pdu_port=_pdu_enb_ru.pdu_ports[7],
)


_ru3 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AZHL",
    serial_number="AH211600354",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.2.6",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[5],
)


_abia_enb_1_loner = CapacityUnit(
    addr="192.168.253.36", hardware_type="ABIA", serial_number="L1181620120"
)

_abip_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22", hardware_type="ABIP", serial_number="L1241203008"
)

_abiq_gnb_1_loner = CapacityUnit(
    addr="192.168.253.26", hardware_type="ABIQ", serial_number="L1241505063"
)


_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1_loner],
    pdu_port=_pdu_enb.pdu_ports[2],
    hardware_type="ASIA",
    serial_number="EA194754296",
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_gnb_1_loner, _abiq_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[1],
    hardware_type="ASIL",
    serial_number="L1220710056",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])
_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru1, _ru3])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50537
)

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::473c", vlan_id="525"),
    global_bts_id=40537,
    instance_id=40537,
    oam_ip=NetworkAddress(v4="10.42.220.187"),
    rms=[_ru2],
)


_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.217", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1],
)


_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.218", username="ute", password="ute"
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
)

# NOKIA
_nokia = TafUeAndroid(
    serial_number="HZQN1876BAKB2500306",
    ue_pc_address="10.42.22.195",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.195", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    data_transfer=[_nokia_iperf],
)

_core = RealCore5G()

_optical_switch = Leoni(addr="10.42.75.137", model="mol 6x(2x6)", port=3001)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASKEY_ASILL_ABINB1_AZQO_ECPRI_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb, _pdu_enb_ru],
    optical_switches=[_optical_switch]
)
