# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Jakub Hirny"
__email__ = "jakub.hirny@nokia.com"

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


_pdu_1 = Gude(
    addr="10.44.177.162",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.44.177.190",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8041-1",
)
_pdu_3 = Gude(
    addr="10.44.205.120",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8041-1",
)
_pdu_4 = Gude(
    addr="10.44.205.66",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8041-1",
)
_pdu_5 = Gude(
    addr="10.44.200.175",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHDB",
    serial_number="EA201652707",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[10],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="F7172439395",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.125", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHMA",
    serial_number="4H183630010",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHDB",
    serial_number="EA201751265",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[9],
)
_rmod_5 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FRHG",
    serial_number="K9173265267",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2027G1AS8",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172821715",
    rus=[_rmod_4],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233206248",
    rus=[_rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204906162",
    rus=[_rmod_1],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1210302486",
    rus=[_rmod_2, _rmod_3],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204906193",
    rus=[_rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1203407141",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1203607113",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_4, _rmod_6],
    oam_ip=NetworkAddress("10.42.86.168"),
    instance_id=101022,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, 
    rms=[_rmod_2, _rmod_3, _rmod_5], 
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.169", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.149.170", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_rnc = RNC(
    rnc_id=25,
    oms_ip=NetworkAddress("10.44.44.218"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.28.72", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="mcBSCR2D2",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.245.38", username="SYSTEM", password="SYSTEM"
    ),
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIQ_1ABIN_1ASIB_1ABIO_1ABIN_1FRHC_1AHMA_2AHDB_1FRHG_1AHLOA_UTECA",
    pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
