# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Paulina Zachorodna"
__email__ = "paulina.zachorodna@nokia.com"


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
    addr="10.44.200.81",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_2 = Gude(
    addr="10.44.177.163",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.44.177.164",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_rmod_1 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type="AZQI",
    serial_number="1M224530029",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.10", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[10],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type="AZQI",
    serial_number="1M212323172",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.158", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=" AZQI",
    serial_number="1M224530017",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.154", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=" ARGA",
    serial_number="K9221667795",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_5 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRMF",
    serial_number="F7164423586",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_6 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7192316810",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.134", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_7 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="1M143924972",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_8 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXDB",
    serial_number="F7163712127",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="RW192200212",
    rus=[_rmod_7, _rmod_8],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204109001",
    rus=[_rmod_5, _rmod_6, _rmod_7, _rmod_8],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="EA194551783",
    rus=[_rmod_4],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223915489",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1190608754",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1190601875",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_5, _rmod_6,_rmod_7, _rmod_8],
    oam_ip=NetworkAddress("10.42.86.164"),
    instance_id=8793,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2,_rmod_3, _rmod_4 ],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.211", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.149.212", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_rnc = RNC(
    rnc_id=25,
    oms_ip=NetworkAddress("10.42.28.72"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.28.75", username="nokiadmin", password="system"
    ),
)
_bsc = BSC(
    name="BSC-25",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.245.38", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIO_1ASIB_1ABIL_1ABIO_3AZQI_1ARGA_1FRMF_1FXED_2FXDB_UTECA",
    pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
