__maintainer__ = "Sebastian Jakubik"
__team__ = "RRM team"
__email__ = "sebastian.jakubik@nokia.com"
__owner_email__ = "sebastian.jakubik@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RadioTypes, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid, TafUeMtk
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.lmi import SerialOverTcp, Remote


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.205.86",
    port_numbers=[5, 11],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1]

_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA171810032",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFB.value,
    serial_number="AH192700097",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA171912194",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFB.value,
    serial_number="AH192700075",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_5 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHIB.value,
    serial_number="EA174410285",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_6 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFB.value,
    serial_number="EA175112699",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.19", port=5001),
    #     ]
    # ),
)

_rmod_7 = RU(
    ru_hw_group="FRMr5_2T2R",
    radio_type=RadioTypes.AZRB.value,
    serial_number="1M185214864",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_8 = RU(
    ru_hw_group="FRMr5_2T2R",
    radio_type=RadioTypes.AZRB.value,
    serial_number="1M181319963",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_9 = RU(
    ru_hw_group="FRMr5_2T2R",
    radio_type=RadioTypes.AZRB.value,
    serial_number="1M185214851",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181513501",
    rus=[],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193577562",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181514943",
    rus=[_rmod_5, _rmod_6],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162808083",
    rus=[_rmod_7],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171213597",
    rus=[_rmod_1, _rmod_2],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172902306",
    rus=[],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    # pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1172915775",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    # pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173009685",
)

_core = RealCore5G(mcc=310, mnc=260)

_smod_1 = Airscale([_fct_1, _fct_2])

_du = DU(_smod_1)

_enb_1 = RealEnb(
    system_module=_smod_1,
    oam_ip=NetworkAddress("10.44.225.154"),
    x2_link_addr=NetworkAddress(
        v4="10.44.225.154",
        # v6="2a00:8a00:6000:607c::300a",
        vlan_id=921,
        routing_v4=RoutingInformation(gateway="10.44.225.129"),
    ),
    global_bts_id=45117,
    instance_id=45117,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.194.134", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.195.175", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[1],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    tl_cloud_topology="VRF_WRO2_T08_2xASIA_6xABIA_3xAHIB_3xAHFB_3xAZRB",
    core=_core,
    pdus=_pdus,
    enbs=[_enb_1],
    test_pcs=[_test_pc_1, _test_pc_2],
)

__all__ = ["tl"]
