__maintainer__ = "Konrad Koziol"
__team__ = "siso"
__email__ = "konrad.koziol@nokia.com"
__owner_email__ = "konrad.koziol@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.airscale import Airscale  # CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.172", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.121.74", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_3 = TestPc(
    SshServiceDetails(addr="10.44.40.11", username="ute"),  # GNB
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    "10.44.167.116", [8, 10, 11], "EPC", ""
)  # SM Full Rack: 11 - Left, 10 - Right
_pdu_2 = Gude("10.44.167.104", [9, 10, 11, 12], "EPC", "")
_pdu_3 = Gude("10.44.167.106", [5, 6, 7, 8, 9], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1162608153",
    pdu_port=_pdu_1.pdu_ports[11],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    serial_number="L1162615471",
    pdu_port=_pdu_1.pdu_ports[11],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIA",
    serial_number="L1171216190",
    pdu_port=_pdu_1.pdu_ports[10],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    serial_number="L1171218656",
    pdu_port=_pdu_1.pdu_ports[10],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    serial_number="L1171212673",
    pdu_port=_pdu_1.pdu_ports[10],
)
_fsp_7 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIO",
    serial_number="L1211505205",
    pdu_port=_pdu_1.pdu_ports[8],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    serial_number="K9185008777",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIA",
    serial_number="L1173423669",
)
_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_7],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIB",
    serial_number="L1204202687",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
_smod_3 = Airscale([_fct_3])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="K9193553193",
    pdu_port=_pdu_2.pdu_ports[9],
    product_code="473997A.101",
    radio_type="AHPMDA",
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="K9193553155",
    pdu_port=_pdu_2.pdu_ports[10],
    product_code="473997A.101",
    radio_type="AHPMDA",
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="K9184238625",
    pdu_port=_pdu_2.pdu_ports[11],
    product_code="473997A.101",
    radio_type="AHPMDA",
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9183840617",
    pdu_port=_pdu_2.pdu_ports[12],
    product_code="474090A.101",
    radio_type="AHEGB",
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9182928230",
    pdu_port=_pdu_3.pdu_ports[5],
    product_code="474090A.101",
    radio_type="AHEGB",
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9182928264",
    pdu_port=_pdu_3.pdu_ports[6],
    product_code="474090A.101",
    radio_type="AHEGB",
)
_rmod_7 = RU(
    ru_hw_group="cMAAr6_1_64T64R",
    serial_number="1M201202432",
    pdu_port=_pdu_3.pdu_ports[7],
    product_code="474413A.102",
    radio_type="AEQB",
)
_rmod_8 = RU(
    ru_hw_group="cMAAr6_1_64T64R",
    serial_number="1M200710753",
    pdu_port=_pdu_3.pdu_ports[8],
    product_code="474413A.101",
    radio_type="AEQB",
)
_rmod_9 = RU(
    ru_hw_group="cMAAr6_1_64T64R",
    serial_number="1M201202439",
    pdu_port=_pdu_3.pdu_ports[9],
    product_code="474413A.102",
    radio_type="AEQB",
)

_rnc = RNC(
    rnc_id=3000,
    oms_ip=NetworkAddress("10.44.44.218"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.81", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC22",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.4.132", username="PZUSER4", password="Ut3pa5s#1be1"
    ),
)

_app_server_1 = TafUeAppServer(
    app_server_name="IPERF_TMP_GT",
    address="10.44.184.204",
    user="ranpz",
    password="Pass$Tests",
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
    serial_number="AQKSLVH028N50900139",
    ue_pc_address="10.42.36.46",
    data_transfer=[_data_transfer_iperf],
    capabilities=["AQKSLVH028N50900139"],
    ue_pc_port="9090",
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Aeroplane mode",
    is_rooted="no",
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.44.166.90"),
    instance_id=1098,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_5, _rmod_6],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_enb_sbts_3 = RealEnb(
    system_module=_smod_3,
    rms=[_rmod_7, _rmod_8, _rmod_9],
    oam_ip=NetworkAddress("10.44.166.87"),  # GNB
    instance_id=1095,
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_sbts_1, _enb_sbts_2, _enb_sbts_3],
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[_android1],
)


__all__ = ["tl"]
