__maintainer__ = "Joanna Kogut-Malarczyk"
__team__ = "RRM team"
__email__ = "joanna.kogut-malarczyk@nokia.com"
__owner_email__ = "joanna.kogut-malarczyk@nokia.com"

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

# _pdus = [_pdu1]

_rmod_1 = RU(
    ru_hw_group="FRMr3_6T6R",
    radio_type=RadioTypes.FRGP.value,
    serial_number="L6131012873",
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
    ru_hw_group="FRMr3_6T6R",
    radio_type=RadioTypes.FRHA.value,
    serial_number="L1121711916",
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

_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS195012648",
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
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223310047",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    # pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1223415148",
)

_core = RealCore5G(mcc=450, mnc=6)

_smod_1 = Airscale([_fct_1])

_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.44.70.142"),
    x2_link_addr=NetworkAddress(
        v4="10.44.70.142",
        # v6="2a00:8a00:6000:607c::300a",
        # vlan_id=921,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
    ),
    global_bts_id=40802,
    instance_id=40802,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.209.195", username="ute"),
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
    tl_cloud_topology="CLOUD_4G_CLASSICAL_ASIL_ABIO_FRGP_FRHA_AHCA",
    core=_core,
    enbs=[_enb_1],
    test_pcs=[_test_pc_1],
)

__all__ = ["tl"]
