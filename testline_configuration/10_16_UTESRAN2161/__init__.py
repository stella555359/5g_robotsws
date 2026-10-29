# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Katarzyna Kot-Bartkowiak"
__email__ = "katarzyna.kot-bartkowiak@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.fhs import FHS
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
    addr="10.42.199.187",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.42.199.167",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHF",
    serial_number="F7182716513",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="cMAA_Gen4.0_8T8R_eCPRI",
    radio_type="AZQL",
    serial_number="EA203954296",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.255", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type="FXEF",
    serial_number="EA171312311",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type="FXEF",
    serial_number="EA171312316",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXEB",
    serial_number="NK170605536",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1_2T4R",
    radio_type="AHEGA",
    serial_number="K9181425766",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2032G1GNB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_fhs_1 = FHS(
    fhs_type="MDEA",
    pdu_port=_pdu_2.pdu_ports[1],
    serial_number="6Q193802629",
    product_code="473922A.102",
    rus=[_rmod_4, _rmod_5],
)
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173643971",
    rus=[_rmod_1],
    fhs=[_fhs_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233105844",
    rus=[_rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171401718",
    rus=[_rmod_6, _rmod_7],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204214696",
    rus=[_rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234308343",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1213605946",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.183.23"),
    instance_id=101006,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_6, _rmod_7, _rmod_9],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.206", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.207", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2]

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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIM_1ABIA_1ABIQ_1ASIL_1ABIA_1ABIN_1FXEB_1AHEGA_1AHLOA_1FRHF_2FXEF_1AZQL_UTECA",
    pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]