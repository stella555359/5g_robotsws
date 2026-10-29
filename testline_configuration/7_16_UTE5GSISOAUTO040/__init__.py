__maintainer__ = "Pawel Woloszyn"
__team__ = "5G_PZ_1_WRO_8_SG"
__email__ = "pawel.woloszyn@nokia.com"

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
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import Android
from taf.config.testline import AppServer


__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.25.250",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef9", vlan_id=343),
    x2u=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef9", vlan_id=343),
    s1u=NetworkAddress(v6="2a00:8a00:6000:6f00::1:ef9", vlan_id=343),
)

_pdu_gnb = Gude(addr="10.45.167.51", port_numbers=[11], model="EPC", version="8220-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.45.167.51",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    model="EPC",
    version="8220-1",
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.167.206", port_numbers=[2, 3, 4, 5, 6, 7], model="EPC", version="8220-1"
)

_gnb_ru_1 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AHEGB",
    serial_number="K9200700026",
    product_code="474090A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[9],
)

_gnb_ru_2 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AHED",
    serial_number="6Q184674414",
    product_code="473807A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[10],
)

_gnb_ru_3 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="FRHC",
    serial_number="F7173766305",
    product_code="472656A.204",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.128",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[5],
)

_gnb_ru_4 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="FRHC",
    serial_number="F7190529730",
    product_code="472656A.204",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.129",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[6],
)

_gnb_ru_5 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AZQU",
    serial_number="4H210630106",
    product_code="475665A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.154",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
#    lmp_connection=SshServiceDetails(addr="10.255.31.62", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[7],
)

_gnb_ru_6 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AZQU",
    serial_number="4H210530088",
    product_code="475665A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.158",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
#    lmp_connection=SshServiceDetails(addr="10.255.31.63", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[8],
)

_gnb_ru_7 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AZQU",
    serial_number="1M222314681",
    product_code="475665A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.162",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
#    lmp_connection=SshServiceDetails(addr="10.255.31.59", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[5],
)

_gnb_ru_8 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AQQT",
    serial_number="L1230304402",
    product_code="093861A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.14",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
#    lmp_connection=SshServiceDetails(addr="10.255.31.56", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[2],
)

_gnb_ru_9 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AQQT",
    serial_number="L1224503356",
    product_code="093861A.X12",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.10",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
#    lmp_connection=SshServiceDetails(addr="10.255.31.57", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[3],
)

#_gnb_ru_10 = RU(
#    ru_hw_group="5Ggen4_LowF_2T2R",
#    radio_type="AQQT_removed",
#    serial_number="L1230304401",
#    product_code="093861A.101",
#    default_ssh_connection_details=SshServiceDetails(
#        addr="172.22.1.14",
#        username="serviceuser",
#        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
#    ),
#    lmp_connection=SshServiceDetails(addr="10.255.31.58", port=3000, username=""),
#    pdu_port=_pdu_gnb_ru_2.pdu_ports[4],
#)

_gnb_ru_11 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AZQS",
    serial_number="1M212701143",
    product_code="475664A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.154",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
#    lmp_connection=SshServiceDetails(addr="10.255.31.60", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[6],
)

_gnb_ru_12 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AZQS",
    serial_number="1M222504389",
    product_code="475664A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.158",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
#    lmp_connection=SshServiceDetails(addr="10.255.31.61", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[7],
)

_gnb_ru_13 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="FRGU",
    serial_number="AS190410251",
    product_code="472956A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.137",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[1],
)

_gnb_ru_14 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="FRGU",
    serial_number="AS174501500",
    product_code="472956A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.136",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[2],
)

_gnb_ru_15 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="FRGU",
    serial_number="K9164109258",
    product_code="472956A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.132",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[3],
)

_gnb_ru_16 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="FRGU",
    serial_number="K9163800848",
    product_code="472956A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.134",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[4],
)


_abio_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:101",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211506442",
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5, _gnb_ru_6, _gnb_ru_7],
)

_abio_2 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:201",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508103",
#    rus=[_gnb_ru_8, _gnb_ru_9, _gnb_ru_10, _gnb_ru_11, _gnb_ru_12],
    rus=[_gnb_ru_8, _gnb_ru_9, _gnb_ru_11, _gnb_ru_12],
)

_abio_3 = CapacityUnit(
    addr="fd5f:4268:2387:a881:40:43ff:fe80:301",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204907587",
    rus=[_gnb_ru_13, _gnb_ru_14, _gnb_ru_15, _gnb_ru_16],
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_abio_1, _abio_2, _abio_3],
    pdu_port=_pdu_gnb.pdu_ports[11],
    hardware_type="ASIM",
    hardware_version="475765A.102",
    serial_number="L1230610669",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[
        _gnb_ru_1,
        _gnb_ru_2,
        _gnb_ru_3,
        _gnb_ru_4,
        _gnb_ru_5,
        _gnb_ru_6,
        _gnb_ru_7,
        _gnb_ru_8,
        _gnb_ru_9,
#        _gnb_ru_10,
        _gnb_ru_11,
        _gnb_ru_12,
        _gnb_ru_13,
        _gnb_ru_14,
        _gnb_ru_15,
        _gnb_ru_16,
    ],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.121.112", username="ute", password="ute"
    ),
    connections=[_asib_gnb_1],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50688, instance_id=40688
)

_core = RealCore5G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_7_16_UTE5GSISOAUTO040",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2],
)
