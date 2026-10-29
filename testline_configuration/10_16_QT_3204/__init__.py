__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT1"
__email__ = "I_AM_QT@internal.nsn.com"
__owner_email__ = "I_AM_QT@internal.nsn.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import PduPort, EPC, Gude



_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.48", username="ute", password="UTE.debian12"
    )
)

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)


_du_pdu = Gude(
    addr="10.44.177.212",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=11)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu = Gude(
    addr="10.44.177.236",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_ru_pdu_port = PduPort(pdu=_ru_pdu, port_no=9)

_ru = RU(
    ru_hw_group="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.150",
        username="serviceuser",
        password="7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g=",
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.0.150",
        username="serviceuser",
        password="7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g=",
    ),
    pdu_port=_ru_pdu_port,
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="192.168.255.129")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_ue_pdu = Gude(
    addr="10.44.177.98",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_ue_pdu_port = PduPort(pdu=_ue_pdu, port_no=9)

_real_ue = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.194.53", username="ute", password="Ut3pa5s#1be1"
    ),
    serial_number="None",
    server_dir=None,
    python_path=None,
    imsi="None",
    capabilities=["_4G"],
    pdu_port=_ue_pdu_port,
)

_real_ue.ue_type = "huawei_router"

tl = TestLine(
    test_pc=_test_pc,
    ues=[_real_ue],
    enbs=[_cbts],
    tl_cloud_topology="3204",
)

tl.UE = {
    "UE_ip": "10.0.3.1",
    "master_eth": "192.168.8.111",
    "core_network": "10.0.3.254",
    "router_ip": "192.168.8.1",
    "router_user": "admin",
    "router_password": "admin01",
    "lte_band": "2000000000",
    "S1_interface": "eth2",
    "UE_mode": "remote",
}

tl.target_traffic_4G = {
    "tput_dl_min": "40",  # Mbits/sec
    "tput_ul_min": "12",  # Mbits/sec
    "port_ul": "5110",
    "port_dl": "7010",
    "tput_time": "120",
    "tput_ul": "15M",
    "tput_dl": "50M",
    "interval": "1",
    "len_ul": "1320",
    "len_dl": "1470",
}

tl.scf_variables = {
    "btsid": "3204",
    "btsName": "QT-ASIB_ABIC_4G_TDD-WRO-3204",
    "positionInSubrack": "LeftSide",
    "mcc": "244",
    "mnc": "9",
    "phyCellId": "40",
    "tac": "3204",
    "ipAddrPrim": "10.0.1.1",
    "mplane_ip": "10.0.1.2",   
    "mplane_ip_prefix": "25",
    "mplane_gw": "10.0.1.1",
    "earfcn": "37950",
}

__all__ = ["tl"]
