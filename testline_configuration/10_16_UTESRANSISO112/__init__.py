__maintainer__ = "Anna Plecha"
__team__ = "siso"
__email__ = "anna.plecha@nokia.com"
__owner_email__ = "anna.plecha@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CoreUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

from taf.config.testline.testpc import TestPc, Connection


_pdu_1 = Gude("10.42.169.6", [7], "EPC", "8220-1")  # SMOD
_pdu_2 = Gude("10.42.168.100", [2, 7, 8, 10], "EPC", "8220-1")  #AHPE , AHFB, AHPB, AVQA
_pdu_3 = Gude("10.42.168.101", [6, 7, 9, 10], "EPC", "8220-1") #AHFII chain, AVQA, AVQA
_pdu_4 = Gude("10.42.168.7", [5, 6], "EPC", "8220-1") #AREA chain


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    serial_number="K9194404904",
    pdu_port=_pdu_2.pdu_ports[8],
    product_code="474119A.101",
    radio_type="AHPB",
)  # AHPB
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    serial_number="EA171512576",
    pdu_port=_pdu_2.pdu_ports[7],
    product_code="474036A.101",
    radio_type="AHFB",
)  # AHFB
#_rmod_3 = RU(
#    ru_hw_group="FRMr5.1_1_2T4R",
#    serial_number="1M211903984",
#    pdu_port=_pdu_2.pdu_ports[1],
#    product_code="475208A.101",
#    radio_type="AHPE",
#)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    serial_number="1M211806933",
    pdu_port=_pdu_2.pdu_ports[2],
    product_code="475208A.101",
    radio_type="AHPE",
)
# _rmod_5 = RU(
#     ru_hw_group="FRMr6.2_4T4R",
#     serial_number="BL2227N40NN",
#     pdu_port=_pdu_3.pdu_ports[10],
#     product_code="475208A.101",
#     radio_type="AHFII",
#)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="K9245128936",
    pdu_port=_pdu_3.pdu_ports[6],
    product_code="475208A.101",
    radio_type="AHFII",
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    serial_number="EA192474309",
    pdu_port=_pdu_4.pdu_ports[5],
    product_code="475208A.101",
    radio_type="AREA",
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    serial_number="EA191273977",
    pdu_port=_pdu_4.pdu_ports[6],
    product_code="475208A.101",
    radio_type="AREA",
)
_rmod_9 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    serial_number="L1251403408",
    pdu_port=_pdu_3.pdu_ports[9],
    product_code="476457A.101",
    radio_type="AVQA",
)
_rmod_10 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    serial_number="L1251403410",
    pdu_port=_pdu_2.pdu_ports[10],
    product_code="476457A.101",
    radio_type="AVQA",
)
_rmod_11 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    serial_number="L1251403409",
    pdu_port=_pdu_3.pdu_ports[7],
    product_code="476457A.101",
    radio_type="AVQA",
)


#_fsp_1 = CapacityUnit(
#    addr="192.168.253.20",
#    hardware_type="ABIN",
#    serial_number="L1204707973",
#    pdu_port=_pdu_1.pdu_ports[7],
#    rus=[_rmod_1, _rmod_2, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11],
#)
# FAKE BBMOD!


_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASOE",
    serial_number="DH224715642",
    rus=[_rmod_1, _rmod_2, _rmod_4, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11],
)

_smod_1 = Airscale(core_units=[_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_4,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
    ],
    oam_ip=NetworkAddress("10.42.175.8"),
    instance_id=1440,
)

_app_server_1 = TafUeAppServer(
    app_server_name="IPERF_TMP_WG",
    address="10.44.184.246",
    user="ranpz",
    password="Pass4Testers!",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50,
    # bind_ue_ip='10.42.197.171',
    version=3,
)


_android1 = TafUeAndroid(
    serial_number="M9AIKN01N630S33",
    ue_pc_address="10.42.172.33",
    data_transfer=[_data_transfer_iperf],
    capabilities=["M9AIKN01N630S33"],
    ue_pc_port="9091",
    proxy_mngr_port=9955,
    network_mode_switch_method="adb",
    # airplane_mode_switcher_text='Airplane mode',
    is_rooted="no",
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.132", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    ues=[_android1],
)

__all__ = ["tl"]