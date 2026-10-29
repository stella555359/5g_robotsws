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
    addr="10.42.199.226",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7154747243",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXFC",
    serial_number="F7144827056",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="L1155212991",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_4 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRMC",
    serial_number="F7141904319",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.138", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_5 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="L1140403252",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.134", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_6 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="L1140203720",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.135", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223310032",
    rus=[_rmod_5, _rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204214658",
    rus=[_rmod_1, _rmod_3, _rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824752",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH211074873",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.42.182.120"),
    instance_id=5008,
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

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.44", username="ute"), 
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_1ABIO_1ABIN_1ABIA_1FXED_1FXFC_1FRGU_1FRMC_2FRHC_UTECA",
    pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
