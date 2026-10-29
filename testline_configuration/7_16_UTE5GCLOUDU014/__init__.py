__maintainer__ = "Vladislav Gusak"
__email__ = "vladislav.gusak@nokia.com"
__owner_email__ = "vladislav.gusak@nokia.com"
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

_pdu_1 = Gude("10.44.177.201", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.44.205.131", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

# RU objects define radio modules.

_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="DC2016000GF",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2035Y20OT",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="BL2037K20A0",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2035Y20QB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_5 = RU(
    ru_hw_group="FRMrRH5.1_6T6R",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M211902614",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.50.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_6 = RU(
    ru_hw_group="FRMrRH5.1_6T6R",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M221229087",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.50.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_7 = RU(
    ru_hw_group="FRMrRH5.1_6T6R",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M222319489",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.50.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1214403621",
    rus=[_rmod_1, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1192408894",
    rus=[_rmod_2, _rmod_4],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234301794",
    rus=[_rmod_5, _rmod_6, _rmod_7],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171106396",
    rus=[_rmod_1, _rmod_2],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171304436",
    rus=[_rmod_3, _rmod_4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503228",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503239",
)

_smod_1 = Airscale([_fct_1])    #gNB
_smod_2 = Airscale([_fct_2])    #eNB

_du_1 = DU(_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7])
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.207.222"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=55024, instance_id=55024)

_enb_sbts_1 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
    ],
    oam_ip=NetworkAddress("10.44.207.160"),
    global_bts_id=8387,
    instance_id=8387,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.142", username="ute", password="uteUTE!"),
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
    SshServiceDetails(addr="10.44.156.149", username="ute", password="uteUTE!"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_2xASIM_ABIL_ABIO_2xABIA_3xAEQE_2xAHBCC_2xAHFIC",
    pdus=[_pdu_1, _pdu_2],
)

__all__ = ["tl"]
