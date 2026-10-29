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
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="DC2013000JD",
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
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV194000768",
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
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193401817",
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
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193300347",
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
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV194000758",
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
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193801163",
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
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193301045",
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

_rmod_8 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV194000693",
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

_rmod_9 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193201515",
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

_rmod_10 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV194700035",
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

_rmod_11 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV194000684",
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

_rmod_12 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV192401169",
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


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1200401559",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1200401564",
    rus=[_rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203900936",
    rus=[_rmod_9, _rmod_10, _rmod_11, _rmod_12],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    # pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="L1200104523",
)

_core = RealCore5G(mcc=450, mnc=6)

_smod_1 = Airscale([_fct_1])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.70.141",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
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
        v4="10.44.70.141",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2b01"
        # ),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.141",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2c01"
        # ),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.141",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01"
        ),
    ),
    ngu=NetworkAddress(
        v4="10.44.70.141",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.0"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2e01"
        ),
    ),
)

_du = DU(_smod_1)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du], global_bts_id=50803, instance_id=50803)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.209.192", username="ute"),
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIK_3xABIL_12xAEQN",
    core=_core,
    test_pcs=[_test_pc_1],
)

__all__ = ["tl"]
