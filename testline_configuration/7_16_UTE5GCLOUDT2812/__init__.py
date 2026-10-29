__maintainer__ = "Marcin Bednarski"
__team__ = "5G_PZ_2_WRO_8_SG"
__email__ = "marcin.bednarski@nokia.com"
__owner_email__ = "marcin.bednarski@nokia.com"

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
from taf.config.testline import DU, RU, RadioTypes, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.lmi import LMI, SerialOverTcp, Remote, Local, SerialOverHost

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_core = RealCore5G(mcc=550, mnc=10)

_pdu1 = Gude(
    addr="10.44.205.83",
    port_numbers=[7, 9],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.206.179",
    port_numbers=[4, 10],
    model="EPC",
    version="8221-1",
)

_pdu3 = Gude(
    addr="10.44.206.169",
    port_numbers=[8, 9],
    model="EPC",
    version="8221-1",
)

_pdu4 = Gude(
    addr="10.44.177.32",
    port_numbers=[10],
    model="EPC",
    version="8221-1"
)

_pdu5 = Gude(
    addr="10.44.177.32",
    port_numbers=[2, 4],
    model="EPC",
    version="8221-1"
)

_pdu6 = Gude(
    addr="10.44.177.32",
    port_numbers=[12],
    model="EPC",
    version="8221-1"
)

_pdu7 = Gude(
    addr="10.44.206.12",
    port_numbers=[1, 3, 9],
    model="EPC",
    version="8226-1"
)

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4, _pdu5, _pdu6, _pdu7]

_ue_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails("10.42.22.132", "wro5grrm", password="5gpass!1", port=22))

_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2040G1M4E",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu7.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1930G11QC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.35", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu7.pdu_ports[9],
)

_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2106G10AM",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.36", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu7.pdu_ports[1],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2049V0V9S",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.37", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu5.pdu_ports[2],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2049V0V9R",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.38", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu6.pdu_ports[12],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2049V0V9P",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.39", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu5.pdu_ports[4],
)

_rmod_7 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1251001333",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.40", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[4],
)

_rmod_8 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1251001334",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.40", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu2.pdu_ports[10],
)

_rmod_9 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1251300125",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.40", username="root", password="umniedziala", port=2323
    ),
    pdu_port=_pdu4.pdu_ports[10],
)


_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:53c4:40:43ff:fe80:101",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222605429",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162818414",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004118",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240104999",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu1.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="	L1233406387",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu1.pdu_ports[7],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1243204171",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du_1 = DU(_smod_1)
_du_2 = DU(_smod_2)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.4",
        v6="2a00:8a00:6000:607c::2a06",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.224.1"),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2a01"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.224.4", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.68",
        v6="2a00:8a00:6000:607c::2b06",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65"),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.132",
        v6="2a00:8a00:6000:607c::2c06",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129"),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.196",
        v6="2a00:8a00:6000:607c::2d06",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193"),
    ),
)

_gnb_1 = ClassicalBts(cu=_cu, dus=[_du_1], global_bts_id=55121, instance_id=55121)
_gnb_2 = ClassicalBts(cu=_cu, dus=[_du_2])
_gnb_1.slave = _gnb_2


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.42.53.247", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.195.237", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnb_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

test_config_yaml = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml")

tl = TestLine(
    test_pc=_test_pc_1,
    gnbs=[_gnb_1, _gnb_2],
    ues=[test_config_yaml],
    tl_cloud_topology="VRF_WRO2_T08_2xASIM_2xABIP_ABIA_ABIO_3xAHLOA_3xAHFIB_3xAVHA",
    core=_core,
    pdus=_pdus,
    test_pcs=[_test_pc_1, _test_pc_2],
)

__all__ = ["tl"]
