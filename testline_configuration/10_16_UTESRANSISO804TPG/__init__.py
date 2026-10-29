__maintainer__ = "Jedrzej Grzelak"
__team__ = "siso"
__email__ = "jedrzej.grzelak@nokia.com"
__owner_email__ = "jedrzej.grzelak@nokia.com"

from taf.config.testline.ue import TafUeAndroid
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.pdu import ATEN
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import TopYoung, JFW
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

_pdu_1 = Gude("10.44.167.116", [1, 5], "EPC", "")
_pdu_2 = Gude("10.44.167.104", [1, 2, 3, 4, 5, 6, 7], "EPC", "")
_pdu_3 = Gude("10.44.167.105", [9, 10, 11, 12], "EPC", "")
_pdu_4 = Gude("10.44.167.102", [4], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    serial_number="L1210903905",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIO",
    serial_number="L1210903899",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.29",
    hardware_type="ABIO",
    serial_number="L1215008503",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.37",
    hardware_type="ABIO",
    serial_number="L1214306548",
    pdu_port=_pdu_1.pdu_ports[5],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    serial_number="DH212898726",
    pdu_port=_pdu_1.pdu_ports[5],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="L1192308257",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    serial_number="L1192405971",
)

_node_1 = Airscale([_fct_1])
_node_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="cMAAr6_1_64T64R",
    serial_number="1M203905500",
    pdu_port=_pdu_3.pdu_ports[12],
    radio_type="AEQE",
)

_rmod_2 = RU(
    ru_hw_group="cMAAr6_1_64T64R",
    serial_number="1M213011757",
    pdu_port=_pdu_2.pdu_ports[1],
    radio_type="AEQE",
)

_rmod_3 = RU(
    ru_hw_group="cMAAr6_1_64T64R",
    serial_number="1M213011700",
    pdu_port=_pdu_2.pdu_ports[2],
    radio_type="AEQE",
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9214837452",
    pdu_port=_pdu_4.pdu_ports[4],
    radio_type="AHPCDB",
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9211616324",
    pdu_port=_pdu_3.pdu_ports[10],
    radio_type="AHPCDB",
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9211616327",
    pdu_port=_pdu_3.pdu_ports[11],
    radio_type="AHPCDB",
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA214454212",
    pdu_port=_pdu_2.pdu_ports[5],
    radio_type="AHEGC",
)
_rmod_8 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    serial_number="EA214454205",
    pdu_port=_pdu_2.pdu_ports[4],
    radio_type="AHEGC",
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA192576279",
    pdu_port=_pdu_3.pdu_ports[9],
    radio_type="AHEGC",
)
_rmod_10 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    serial_number="EA214551956",
    pdu_port=_pdu_2.pdu_ports[7],
    radio_type="AHEGC",
)
_rmod_11 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA214551953",
    pdu_port=_pdu_2.pdu_ports[6],
    radio_type="AHEGC",
)
_rmod_12 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    serial_number="EA214454210",
    pdu_port=_pdu_2.pdu_ports[3],
    radio_type="AHEGC",
)

_rnc = RNC(
    rnc_id=38,
    oms_ip=NetworkAddress("10.44.44.219"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.81", username="Nemuadmin", password="nemuuser"
    ),
)

_app_server_1 = TafUeAppServer(
    app_server_name="wg-srn-iperf-728",
    address="10.44.184.246",
    user="ranpz4",
    password="pass4Pezet$ry",
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
    serial_number="AQKSLVH028N50900170",
    ue_pc_address="10.42.36.45",
    data_transfer=[_data_transfer_iperf],
    capabilities=["AQKSLVH028N50900170"],
    ue_pc_port="9090",
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Aeroplane mode",
    is_rooted="no",
)

_enb_sbts_1 = RealEnb(
    system_module=_node_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
    ],
    global_bts_id=1093,
    oam_ip=NetworkAddress("10.44.166.85"),
    instance_id=1093,
)

_enb_sbts_2 = RealEnb(system_module=_node_2, rms=[], master=_enb_sbts_1)

_enb_sbts_1.slave = _enb_sbts_2
_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.223", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.121.251", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    rncs=[_rnc],
    ues=[_android1],
    tl_cloud_topology="CLOUD_RF_AIBLR_B1-5_UTESRANSISO804TPG",
)

__all__ = ["tl"]
