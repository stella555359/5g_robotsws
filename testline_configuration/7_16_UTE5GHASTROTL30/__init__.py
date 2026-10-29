__maintainer__ = "Tomasz Niedzwiedzki"
__team__ = "VRF_WRO2_T04"
__email__ = "tomasz.niedzwiedzki@nokia.com"
__owner_email__ = "tomasz.niedzwiedzki@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, NetworkAddress, RealEnb, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_attenuator24 = JFW(
    ip_addr="10.42.61.100", port=3001, attenuation_port_numbers=range(1, 25)
)

_pdu_smod = Gude(addr="10.44.205.189", port_numbers=[3], model="EPC", version="8221-1")

_pdu_1 = Gude(
    addr="10.44.177.38", port_numbers=[5, 8, 11], model="EPC", version="8221-1"
)

_pdu_2 = Gude(
    addr="10.44.177.28", port_numbers=[7, 8, 9], model="EPC", version="8221-1"
)

_pdu_3 = Gude(
    addr="10.44.177.36", port_numbers=[3], model="EPC", version="8221-1"
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.133", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[8],
    ru_hw_group="",
    radio_type="AHEGC",
    serial_number="EA205155451",
)
_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[7],
    ru_hw_group="",
    radio_type="AHEGC",
    serial_number="EA205155473",
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_2.pdu_ports[9],
    ru_hw_group="",
    radio_type="AHEGC",
    serial_number="EA205152693",
)

_ru4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.132", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[5],
    ru_hw_group="",
    radio_type="AHPMDB",
    serial_number="AS205305038",
)

_ru5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[8],
    ru_hw_group="",
    radio_type="AHPMDB",
    serial_number="AS205305050",
)

_ru6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.131", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[11],
    ru_hw_group="",
    radio_type="AHPMDB",
    serial_number="AS205301578",
)

_ru7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.131", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_3.pdu_ports[3],
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1234004327",
)

_fsp1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184674557",
    rus=[_ru1, _ru2, _ru3],
)

_fsp2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171106449",
    rus=[_ru4, _ru5, _ru6],
)

_fsp3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231803511",
    rus=[_ru1, _ru2, _ru3, _ru4, _ru5, _ru6, _ru7],
)

_common_unit = CommonUnit(
    hardware_type="ASIB",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp1, _fsp2, _fsp3],
    pdu_port=_pdu_smod.pdu_ports[3],
    serial_number="L1214405285",
    hardware_version="473764A.102",
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="10.42.41.10",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_cu.m = NetworkAddress(
    v4="10.42.41.10",
    vlan_id=540,
    routing=RoutingInformation(gateway="10.42.41.1", ip_prefix_length=26),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=41810, instance_id=51810)

_real_core = RealCore5G(mcc=234, mnc=30)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.85", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0]],
)

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_lte = RealEnb(
    system_module=_airscale,
    x2_link_addr=NetworkAddress(
        v4="10.42.41.138",
        vlan_id=541,
        routing=RoutingInformation(gateway="10.42.41.1", ip_prefix_length=26),
    ),
    global_bts_id=41810,
    oam_ip=NetworkAddress(v4="192.168.255.1"),
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    enbs=[_lte],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL30_ASIB_ABIP_ABIA_3xAHEGC_3xAHPMDB_AVHA_MRAT",
    attenuators=[_attenuator24],
    core=_real_core,
    ues=[_ues],
    pdus=[_pdu_smod, _pdu_1, _pdu_2, _pdu_3],
)

tl.max_atten_value = 90

_cells_atten = {
    "0_1/2": [311, 317, 116, 119],
    "0_3/4": [310, 316, 115, 118],
    "0_5/6": [309, 315, 114, 117],
    "0_7/8": [301, 113],
    "0_9/10": [300, 112],
    "0_11/12": [302, 111],
}

tl.cells_atten = _cells_atten

__all__ = ["tl"]
