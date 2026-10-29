# This script was generated automatically, --None-- values indicate lacking data, please fill them manually
__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "marek.starzyk@nokia.com"
__customer__ = "Generic"
__bucket__ = "STRESSED_TEST_LINES"
__rack__ = "GTA-1558"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
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

# ASIA port4, FSMF port5
_pdu_1 = Gude(
    addr="10.42.199.225",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

# AHMA port7, AHEB port8
_pdu_2 = APC(
    addr="10.42.199.230",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    version="AP7922B",
)

# AHEGA port7, AHDB port8
_pdu_3 = APC(
    addr="10.42.199.229",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    version="AP7922B",
)

# AKHD port10
_pdu_4 = Gude(
    addr="10.42.80.61",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    radio_type="AKHD",
    serial_number="4H244360905",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.6", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_2T4R",
    radio_type="AHEGA",
    serial_number="K9180121446",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHDB",
    serial_number="6Q175110539",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHMA",
    serial_number="4H183630008",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEB",
    serial_number="L1181207095",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK154830488",
    rus=[],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK171031215",
    rus=[],
)
_fsp_3 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:123d",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163605483",
    rus=[_rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:133d",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163606713",
    rus=[_rmod_2, _rmod_4, _rmod_5],
)
_fsp_5 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0301",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233003863",
    rus=[_rmod_1],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1190601872",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="EA143761382",
    rus=[],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Flexi([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.182.114"),
    instance_id=5004,
    global_bts_id=5004
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2, _rmod_3], master=_enb_sbts_1)

_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.62", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.63", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_rnc = RNC(
    rnc_id=38,
    oms_ip=NetworkAddress("10.44.44.210"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.74", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_Leopard",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.89.4", username="SYSTEM", password="SYSTEM"
    ),
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_2ABIA_1ABIQ_1FSMF_2FBBC_1AKHD_1AHEGA_1AHDB_1AHMA_1AHEB_UUFWRO",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
