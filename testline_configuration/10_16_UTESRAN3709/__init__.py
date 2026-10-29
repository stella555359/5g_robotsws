# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "marek.starzyk@nokia.com"
__customer__ = "Generic"
__bucket__ = "Special"
__rack__ = "GTA-850"

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
from taf.config.testline.lmi import SerialOverHost, Local
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

# ASIL L port 2, ASIL P port 11
# rmods ports: 3, 4, 5, 6, 7, 8, 9, 10
_pdu_1 = Gude(
    addr="10.42.60.132",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type="FRGT",
    serial_number="F7170445666",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="F7163749537",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.207", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="F7172200700",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.210", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXEB",
    serial_number="NK170102493",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.211", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_5 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXEB",
    serial_number="NK170101610",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHDB",
    serial_number="6Q175002464",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHED",
    serial_number="6Q182504145",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHMA",
    serial_number="4H182630011",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184372554",
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173706545",
    rus=[_rmod_4, _rmod_5, _rmod_2, _rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1204301230",
    rus=[_rmod_7],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171216169",
    rus=[],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172908149",
    rus=[_rmod_6],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1203802685",
    rus=[_rmod_8],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1204505464",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1213506804",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_7],
    oam_ip=NetworkAddress("10.42.18.47"),
    instance_id=6002,
    global_bts_id=6002
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_6, _rmod_8], master=_enb_sbts_1)

_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.229", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.230", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1]

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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIL_2ABIA_1ABIO_1ASIL_2ABIA_1ABIN_1FRGT_2FXDB_2FXEB_1AHDB_1AHED_1AHMA_UTECA",
    pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
