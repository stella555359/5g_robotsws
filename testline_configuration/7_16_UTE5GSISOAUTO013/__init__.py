__maintainer__ = "Rafal Sytyk"
__team__ = "MN RAN RD VRF WRO1 4"
__email__ = "rafal.sytyk@nokia.com"

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
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]


_pdu_gnb = Gude(addr="10.44.177.44", port_numbers=[3], model="EPC", version="8221-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.44.177.44", port_numbers=[1, 4, 7, 10, 12], model="EPC", version="8221-1"
)

_asoe_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASOE",
    serial_number="EA211854017",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.142", username="ute", password="UTE.debian12"
    ),
    connections=[_asoe_gnb_1],
)

_airscale_gnb_1 = Airscale(common_units=[_asoe_gnb_1])

_gnb_ru_1 = RU(
    ru_hw_group="5Ggen4_LowF_32T32R",
    radio_type="AVQA",
    serial_number="L1251502478",
    product_code="476457A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[7],
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.255.33.167", port=3000)
        # Remote(addr="10.255.33.167", port=3001)
    ]),
)

_gnb_ru_2 = RU(
    ru_hw_group="5Ggen4_LowF_32T32R",
    radio_type="AVQA",
    serial_number="L1251502479",
    product_code="476457A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.18",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[10],
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.255.33.166", port=3000)
        # Remote(addr="10.255.33.166", port=3001)
    ]),
)

_gnb_ru_3 = RU(
    ru_hw_group="5Ggen4_LowF_32T32R",
    radio_type="AVQA",
    serial_number="L1251502480",
    product_code="476457A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.22",
        username="serviceuser",
        password="kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[12],
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.255.33.193", port=3000)
        # Remote(addr="10.255.33.193", port=3001)
    ]),
)

_gnb_ru_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="DH244316282",
    product_code="474119A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129",
        username="root",
        password="",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[4],
)

_gnb_ru_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPJ",
    serial_number="K9233810289",
    product_code="476403A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128",
        username="root",
        password="",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[1],
)

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5],
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.78.216",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::290b", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::290b", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::290b", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=55222, instance_id=55222
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SISOAUTO013",
    pdus=[_pdu_gnb, _pdu_gnb_ru_1],
)
