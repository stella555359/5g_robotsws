__maintainer__ = "Michal Kubicki"
__team__ = "RRM team"
__email__ = "michal.kubicki@nokia.com"
__owner_email__ = "michal.kubicki@nokia.com"

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
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AEQY.value,
    serial_number="1M210537942",
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
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="DH234520601",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.35", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="L1233602232",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.36", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="1M210537937",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.37", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="DH234520603",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.38", username="root", password="umniedziala", port=2323
    ),
    # pdu_port=_pdu2.pdu_ports[3],
    # lmi=SerialOverTcp(
    #     uart_mapping=[
    #         Remote(addr="10.255.33.20", port=5001),
    #     ]
    # ),
)

_rmod_6 = RU(
    ru_hw_group="FRMr3.3_3T3R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="L1233000590",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.39", username="root", password="umniedziala", port=2323
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
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004109",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    # pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.Y13",
    serial_number="L1223306829",
)

_core = RealCore5G(mcc=450, mnc=6)

_smod_1 = Airscale([_fct_1])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.169",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2a01"
        # ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.68.169",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2b01"
        # ),
    ),
    x2u=NetworkAddress(
        v4="10.44.68.169",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2c01"
        # ),
    ),
    s1u=NetworkAddress(
        v4="10.44.68.169",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2d01"
        # ),
    ),
    ngu=NetworkAddress(
        v4="10.44.68.169",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2e01"
        # ),
    ),
)

_du = DU(_smod_1)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du], global_bts_id=50804, instance_id=50804)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.209.193", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)


tl = TestLine(
    test_pc=[_test_pc_1],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIO_2xAEQY_2xAQQL_2xAVQL",
    core=_core,
    test_pcs=[_test_pc_1],
)

__all__ = ["tl"]
