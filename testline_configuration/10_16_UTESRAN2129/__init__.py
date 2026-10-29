# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Anna Niedzwiecka"
__email__ = "anna.niedzwiecka@nokia.com"

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
    addr="10.42.80.104",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXCB",
    serial_number="L6134741240",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXCB",
    serial_number="1M154507630",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_2_2T4R_VirtWBs",
    radio_type="AHEGA",
    serial_number="K9181423212",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129 ", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEB",
    serial_number="L1181016677",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173706555",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211110915",
    rus=[_rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204706734",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1203506133",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.42.182.7"),
    instance_id=5083,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.30", username="ute"), 
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

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

_pdus = [_pdu_1]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIL_1ABIA_2ABIO_2FXCB_1AHEGA_1AHEB_UTECA",
    pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
