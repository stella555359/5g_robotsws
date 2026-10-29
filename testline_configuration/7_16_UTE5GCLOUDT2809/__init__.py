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
#
# _pdu1 = Gude(
#     addr="",
#     port_numbers=[],
#     model="EPC",
#     version="8221-1",
# )
#
# _pdus = [_pdu1]

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQS.value,
    serial_number="L1222907269",
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
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQS.value,
    serial_number="L1222907270",
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
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQS.value,
    serial_number="",
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
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQS.value,
    serial_number="L1222907268",
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
    radio_type=RadioTypes.AZQG.value,
    serial_number="NUJN02024N",
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

_rmod_6 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQG.value,
    serial_number="NUJN02042N",
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

_rmod_7 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQG.value,
    serial_number="NUJN00152N",
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
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQG.value,
    serial_number="L1193900236",
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
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQG.value,
    serial_number="EA214454728",
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

_rmod_10 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQG.value,
    serial_number="EA194754819",
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

_rmod_11 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQG.value,
    serial_number="EA200255435",
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

_rmod_12 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AZQG.value,
    serial_number="L1192906880",
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

_rmod_13 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP01",
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

_rmod_14 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP02",
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

_rmod_15 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP03",
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

_rmod_16 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP04",
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

_rmod_17 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP05",
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

_rmod_18 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP06",
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

_rmod_19 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP07",
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

_rmod_20 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP08",
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

_rmod_21 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP09",
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

_rmod_22 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP10",
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

_rmod_23 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP11",
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

_rmod_24 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP12",
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

_rmod_25 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP13",
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

_rmod_26 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP14",
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

_rmod_27 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP15",
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

_rmod_28 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP16",
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

_rmod_29 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP17",
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

_rmod_30 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP0818",
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

_rmod_31 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP19",
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

_rmod_32 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP20",
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

_rmod_33 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP0821",
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

_rmod_34 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP22",
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

_rmod_35 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP23",
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

_rmod_36 = RU(
    ru_hw_group="FRMr3.3_3T83",
    radio_type=RadioTypes.AQQT.value,
    serial_number="6Q18250AP24",
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
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232807177",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6,
         _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1232907278",
    rus=[_rmod_13, _rmod_14, _rmod_15, _rmod_16, _rmod_17, _rmod_18,
         _rmod_19, _rmod_20, _rmod_21, _rmod_22, _rmod_23, _rmod_24],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231803512",
    rus=[_rmod_25, _rmod_26, _rmod_27, _rmod_28, _rmod_29, _rmod_30,
         _rmod_31, _rmod_32, _rmod_33, _rmod_34, _rmod_35, _rmod_36],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    # pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233404834",
)

_core = RealCore5G(mcc=310, mnc=260)

_smod_1 = Airscale([_fct_1])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.61",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.224.1"),
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
        v4="10.44.224.125",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2b01"
        # ),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.189",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2c01"
        # ),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.253",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2d01"
        # ),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.253",
        vlan_id=919,
        routing_v4=RoutingInformation(gateway="10.44.225.1"),
        # routing_v6=RoutingInformation(
        #     gateway="2a00:8a00:6000:607c::2e01"
        # ),
    ),
)

_du = DU(_smod_1)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du], global_bts_id=55041, instance_id=55041)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.194.73", username="ute"),
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_3xABIP_6xAQQS_6xAZGQ_24xAQQT",
    core=_core,
    enbs=[],
    test_pcs=[_test_pc_1],
)

__all__ = ["tl"]
