# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Katarzyna Kot-Bartkowiak"
__team__ = "MN_RAN_PZ_OPER_WRO_1_VRF"
__email__ = "I_MN_RAN_PZ_OPER_WRO_1_VRF@internal.nsn.com"
__owner_email__ = "katarzyna.kot-bartkowiak@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CoreUnit
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
    addr="10.44.200.177",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.44.200.124",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.44.205.126",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_4 = Gude(
    addr="10.44.205.209",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_5 = Gude(
    addr="10.44.200.134",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="L1174815287",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="AS195012603",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2215V011F",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[7],
)

_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="F7172125130",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="F7153842928",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_6 = RU(
    ru_hw_group="FRMTDr5.1_4T4R",
    radio_type="AZNA",
    serial_number="K9183004613",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[10],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1_2T4R",
    radio_type="AHEGA",
    serial_number="K9175039254",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)


_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASOG",
    hardware_version="A.101",
    serial_number="L1241503059",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)
_fct_2 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASOG",
    hardware_version="A.101",
    serial_number="L1241503049",
    rus=[_rmod_6, _rmod_7],
)
_smod_1 = Airscale(core_units=[_fct_1])
_smod_2 = Airscale(core_units=[_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.86.166"),
    instance_id=8071,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_6, _rmod_7],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.178.29", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.178.30", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.core_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5]

_rnc = RNC(
    rnc_id=36,
    oms_ip=NetworkAddress("10.44.44.218"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.171.138", username="nokiadmin", password="system"
    ),
)
_bsc = BSC(
    name="BSC_mcBSC33",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.44.146.2", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_2ASOG_2AHCA_1AHFIB_2FXDB_1AZNA_1AHEGA_UTECA",
    pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
