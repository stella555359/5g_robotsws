# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Igor Kleschenok"
__email__ = "igor.kleschenok@nokia.com"
__owner_email__ = "igor.kleschenok@nokia.com"
__team__ = "pz2wro3"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation


# testline config variables


# _test_pc_1 = TestPc(
#     SshServiceDetails(addr="10.42.121.39", username="ute"),
#     connections=[NetworkAddress(v4="192.168.255.126")],
# )
#
# _test_pc_2 = TestPc(
#     SshServiceDetails(addr="10.42.121.218", username="ute"),
#     connections=[NetworkAddress(v4="192.168.255.126")],
# )
#
# _test_pc_3 = TestPc(
#     SshServiceDetails(addr="10.42.121.189", username="ute"),
#     connections=[NetworkAddress(v4="192.168.255.126")],
# )

_pdu_1 = Gude("10.44.143.62", [5, 6, 7, 8, 9], "EPC", "")

_pdu_2 = Gude("10.44.143.63", [4, 5, 6], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163406011",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193577694",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173313375",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163606701",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1192408892",
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203605161",
)
_fsp_7 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203605163",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173104619",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1173009708",
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5, _fsp_6, _fsp_7],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="DH201161280",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
_smod_3 = Airscale([_fct_3])


_rmod_1 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB,
    serial_number="BL2108V05C1",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB,
    serial_number="BL2045V0RPB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHFIB,
    serial_number="BL2040V0MVJ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA,
    serial_number="BL2002G106X",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA,
    serial_number="K9190800028",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5_4T4R",
    radio_type=RadioTypes.AHLOA,
    serial_number="BL2004G1007",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_du_1 = DU(_smod_3, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6])
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.25.248"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_cbts_4055 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=4055, instance_id=4055)

_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
    ],
    oam_ip=NetworkAddress("10.42.24.248"),
    global_bts_id=5250,
    instance_id=5250,
)

_lte_5250 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_4,
        _rmod_5,
        _rmod_6,
    ],
    oam_ip=NetworkAddress(v4="10.42.24.248"),
    global_bts_id=5250,
    instance_id=5250,
    master=_lte_1,
)

_lmp_vm_enb_1 = TestPc(
    SshServiceDetails(addr="10.42.121.189", username="ute"),
    connections=[_lte_1],
)

_lmp_vm_enb_5250 = TestPc(
    SshServiceDetails(addr="10.42.121.218", username="ute"),
    connections=[_lte_5250],
)

_lmp_vm_gnb_4055 = TestPc(
    SshServiceDetails(addr="10.42.121.39", username="ute"),
    connections=[_cbts_4055],
)

_lte_1.slave = _lte_5250

tl = TestLine(
    test_pc=[_lmp_vm_enb_1],
    test_pcs=[_lmp_vm_enb_1, _lmp_vm_gnb_4055, _lmp_vm_enb_5250],
    gnbs=[_cbts_4055],
    enbs=[_lte_1, _lte_5250],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIK_3xABIL_3xAHFIB_3xAHLOA_ENB",
    pdus=[_pdu_1, _pdu_2],
)

__all__ = ["tl"]
