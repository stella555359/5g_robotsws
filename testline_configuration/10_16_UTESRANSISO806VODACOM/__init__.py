__maintainer__ = "Roksana Spychala-Malolepsza"
__team__ = "siso"
__email__ = "roksana.spychala-malolepsza@nokia.com"
__owner_email__ = "roksana.spychala-malolepsza@nokia.com"

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
from taf.config.testline.testpc import TestPc, Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = Gude("10.44.167.125", [2, 6], "EPC", "8221-1")  # SM Full Rack: 2 - Left (primary), 6 - Right (secondary)
_pdu_2 = Gude("10.44.167.34", [1, 2, 3], "EPC", "8220-1")  # RUs: AHPMDA_899_RSA; AEHC_765_RSA; AHPMDA_893_RSA
_pdu_3 = Gude("10.44.167.113", [12], "EPC", "8220-1")  # RUs: AEHC_389_RSA
_pdu_4 = Gude("10.44.167.105", [3, 7], "EPC", "8220-1")  # RUs: AHEGC_233_RSA; AHPMDA_060_RSA
_pdu_5 = Gude("10.44.167.106", [10, 11], "EPC", "8220-1")  # RUs: AHEGC_832_RSA; AHEGC_829_RSA
_pdu_6 = Gude("10.44.167.112", [1], "EPC", "8221-1")  # RUs: AEHC_766_RSA; 

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="K9182709893",
    pdu_port=_pdu_2.pdu_ports[3],
    product_code="473997A.101",
    radio_type="AHPMDA",
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="K9182709899",
    pdu_port=_pdu_2.pdu_ports[1],
    product_code="473997A.101",
    radio_type="AHPMDA",
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    serial_number="K9174723060",
    pdu_port=_pdu_4.pdu_ports[7],
    product_code="473997A.101",
    radio_type="AHPMDA",
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA222657829",
    pdu_port=_pdu_5.pdu_ports[11],
    product_code="474914A.101",
    radio_type="AHEGC",
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA222657832",
    pdu_port=_pdu_5.pdu_ports[10],
    product_code="474914A.101",
    radio_type="AHEGC",
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA222658233",
    pdu_port=_pdu_4.pdu_ports[3],
    product_code="474914A.101",
    radio_type="AHEGC",
)
_rmod_7 = RU(
    ru_hw_group="cMAArChile_64T64R",
    serial_number="K9223200765",
    pdu_port=_pdu_2.pdu_ports[2],
    product_code="475124B.101",
    radio_type="AEHC",
)
_rmod_8 = RU(
    ru_hw_group="cMAArChile_64T64R",
    serial_number="L1213514389",
    pdu_port=_pdu_3.pdu_ports[12],
    product_code="475124B.101",
    radio_type="AEHC",
)
_rmod_9 = RU(
    ru_hw_group="cMAArChile_64T64R",
    serial_number="K9223200766",
    pdu_port=_pdu_6.pdu_ports[1],
    product_code="475124B.101",
    radio_type="AEHC",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    serial_number="L1204806014",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1173606413",
    pdu_port=_pdu_1.pdu_ports[2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    serial_number="L1163810636",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIA",
    serial_number="L1164812232",
    pdu_port=_pdu_1.pdu_ports[6],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    serial_number="L1171608889",
    pdu_port=_pdu_1.pdu_ports[6],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1190608720",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201102956",
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_rnc = RNC(
    rnc_id=25,
    oms_ip=NetworkAddress("10.44.44.219"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.28.75", username="Nemuadmin", password="Nokia@123"     #10.42.91.82
    ),
)

_bsc = BSC(
    name="BSC21",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.28.126", username="PZUSER4", password="Ut3pa5s#1be1"
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
    serial_number="2ac9ac8e",
    capabilities=["2ac9ac8e"],
    ue_pc_address="10.42.36.154",
    proxy_mngr_port=9955,
    data_transfer=[_data_transfer_iperf],
    network_mode_switch_method="adb",
    is_rooted="no",
)

_android2 = TafUeAndroid(
    serial_number="R3CW5071B4J",
    capabilities=["R3CW5071B4J"],
    ue_pc_address="10.42.36.154",
    proxy_mngr_port=9955,
    data_transfer=[_data_transfer_iperf],
    network_mode_switch_method="adb",
    is_rooted="no",
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    oam_ip=NetworkAddress("10.42.24.59"),
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    instance_id=1239,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_5, _rmod_6],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.134", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.121.166", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp")],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[_android1, _android2],
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO806VODACOM",
)
__all__ = ["tl"]
