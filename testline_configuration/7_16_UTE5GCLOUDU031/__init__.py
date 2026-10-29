__maintainer__ = "Oleksandr Kulieshov"
__email__ = "oleksasndr.kulieshov@nokia.com"
__owner_email__ = "oleksasndr.kulieshov@nokia.com"
__team__ = "pz2wro3"

import os

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import RRB


# testline config variables

_pdu = Gude("10.44.128.79", [6, 7, 8, 9, 10, 11, 12], "EPC", "")

# RU objects define radio modules.

_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M193119526",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.36", port=2323
    ),
    pdu_port=_pdu.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS200704320",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.33", port=2323
    ),
    pdu_port=_pdu.pdu_ports[9],
)

_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9175224480",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.37", port=2323
    ),
    pdu_port=_pdu.pdu_ports[10],
)

_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9175116250",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.34", port=2323
    ),
    pdu_port=_pdu.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="FRMrRH5.1_6T6R",
    radio_type=RadioTypes.ARDB.value,
    serial_number="L1194707348",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.35", port=2323
    ),
    pdu_port=_pdu.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204008365",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204003830",
    rus=[_rmod_5],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204604555",
    rus=[_rmod_1, _rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH220344999",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu.pdu_ports[12],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1203700843",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du_1 = DU(_smod_2)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.25.249"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=4103, instance_id=4103)

_enb_sbts_2 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
    ],
    oam_ip=NetworkAddress("10.42.24.249"),
    global_bts_id=14248,
    instance_id=14248,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.188", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnbs_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.121.187", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIO_2xAHCA_ENB",
    pdus=[_pdu],
)

__all__ = ["tl"]
