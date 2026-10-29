# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Tomasz Marchewka"
__email__ = "tomasz.marchewka@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline import Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = Gude(
    addr="10.42.80.238",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHMA",
    serial_number="4H183630006",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.34", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type="AZNA",
    serial_number="6Q190504534",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.36", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type="AZHA",
    serial_number="RW191507801",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.35", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="1M190819365",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.33", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHED",
    serial_number="6Q181610581",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.32", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204003841",
    rus=[_rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164817868",
    rus=[_rmod_1, _rmod_4, _rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1210804452",
    rus=[_rmod_1, _rmod_4, _rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233503529",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.18.46"),
    instance_id=5070,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.144", username="ute"), 
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIM_1ABIN_1ABIO_1ABIA_1AHMA_1AZNA_1AZHA_1AHCA_1AHED_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
