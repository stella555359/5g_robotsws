__maintainer__ = "Tomasz Godlewski"
__team__ = "VRF_WRO2_T04"
__email__ = "tomasz.1.godlewski@nokia.com"
__owner_email__ = "tomasz.1.godlewski@nokia.com"

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
from taf.config.testline import (
    DU,
    RU,
    RadioTypes,
    RealEnb,
    NetworkAddress,
    RoutingInformation,
)
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.appserver import TafUeAppServer


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(
    addr="10.44.200.188",
    port_numbers=[1, 2, 5, 6, 7],
    model="EPC",
    version="8041-1",
)

_pdu2 = Gude(
    addr="10.44.200.189",
    port_numbers=[1, 2, 5, 7],
    model="EPC",
    version="8041-1",
)

_pdu3 = Gude(
    addr="10.44.200.190",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="EPC",
    version="8041-1",
)

_pdus = [_pdu1, _pdu2, _pdu3]

_rmod_1 = RU(
    ru_hw_group="FRMr5_8T8R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2045V0RNF",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1926V0E94",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2044V0QUC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[7],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2106G10JE",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1933G10PI",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9182710204",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[7],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9224912840",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[5],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="AH231900701",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[6],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9223130069",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.34", username="root", password="umniedziala", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[5],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="",
    serial_number="L1224904540",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="",
    serial_number="L1230709199",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="",
    serial_number="K9173824689",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="",
    serial_number="L1223400359",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="",
    serial_number="L1230709204",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu3.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="",
    serial_number="DH222244803",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu3.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="",
    serial_number="L1204505485",
)

_core = RealCore5G(mcc=310, mnc=260)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.88.14",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="10.42.88.1"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.88.14", port="443", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.89.205",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="10.42.89.1"),
    ),
    x2u=NetworkAddress(
        v4="10.42.89.205",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="10.42.89.1"),
    ),
    s1u=NetworkAddress(
        v4="10.42.89.140",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="10.42.89.1"),
    ),
    ngu=NetworkAddress(
        v4="10.42.89.140",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="10.42.89.1"),
    ),
)

_du1 = DU(
    _smod_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_du2 = DU(
    _smod_2,
    rus=[
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du1], global_bts_id=55269, instance_id=55269)
_gnb_2 = ClassicalBts(cu=_cu_1, dus=[_du2], global_bts_id=55269, instance_id=55269)

_enb_1 = RealEnb(
    oam_ip=NetworkAddress("10.42.89.14"),
    x2_link_addr=NetworkAddress(
        v4="10.42.89.205",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="10.42.89.1"),
    ),
    global_bts_id=55269,
    instance_id=8814,
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.168", username="ute", password="ute"
    ),
    connections=[_gnb_1.dus[0].airscale.common_units[0]],
)

_lmp_vm_gnb_1_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.169", username="ute", password="ute"
    ),
    connections=[_gnb_2.dus[0].airscale.common_units[0]],
)


_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_attenuator = JFW(
    ip_addr="10.42.221.115",
    port=3001,
    attenuation_port_numbers=[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
    ],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master, _lmp_vm_gnb_1_slave],
    gnbs=[_gnb_1, _gnb_2],
    core=_core,
    pdus=_pdus,
    attenuator=_attenuator,
    ues=[_ues],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROMUTANT3_FULLRACK_ASIL_ABIO_ABIA_3xAHFIB_3xAHLOA_3xAEHC_MRAT",
)

__all__ = ["tl"]
