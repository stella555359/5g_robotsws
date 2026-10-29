__maintainer__ = "Igor Wertepny"
__team__ = "RRM team"
__email__ = "igor.wertepny@nokia.com"
__owner_email__ = "igor.wertepny@nokia.com"

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

# _pdu1 = Gude(
#     addr="",
#     port_numbers=[],
#     model="EPC",
#     version="8221-1",
# )
#
# _pdus = [_pdu1]

_rmod_1 = RU(
    ru_hw_group="FRMr3_2T2R",
    radio_type=RadioTypes.FRCG.value,
    serial_number="K9154711331",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu3.pdu_ports[7],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3_2T2R",
    radio_type=RadioTypes.FRHB.value,
    serial_number="EA152762337",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3_2T2R",
    radio_type=RadioTypes.FRGY.value,
    serial_number="K9162240913",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK161830402",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK154830459",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    # pdu_port=_pdu1.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="AS183501066",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_core = RealCore5G(mcc=450, mnc=6)

_smod_1 = Airscale([_fct_1])

_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.44.70.14"),
    x2_link_addr=NetworkAddress(
        v4="10.44.70.14",
        # v6="2a00:8a00:6000:607c::300a",
        vlan_id=921,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
    ),
    global_bts_id=40801,
    instance_id=40801,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.209.186", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)


tl = TestLine(
    test_pc=[_test_pc_1],
    tl_cloud_topology="CLOUD_4G_CLASSICAL_FSMF_2xFBBC_FRCG_FRHB_FRGY",
    core=_core,
    enbs=[_enb_1],
    test_pcs=[_test_pc_1],
)

__all__ = ["tl"]
