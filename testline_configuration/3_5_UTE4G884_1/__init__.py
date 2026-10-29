# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "carlwu"
__email__ = "carl.wu@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.56.127.53", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.56.127.54", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.68.170.179", [1, 2, 3, 4, 5, 6, 7, 8], "FACOM", "")
_pdu_2 = Gude("10.68.170.185", [1, 2, 3, 4, 5, 6, 7, 8], "FACOM", "")
_pdu_3 = Gude("10.68.170.190", [1, 2, 3, 4, 5, 6, 7, 8], "FACOM", "")
_pdu_4 = Gude("10.68.179.200", [1, 2, 3, 4, 5, 6, 7, 8], "HBTE", "")

_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213014328",
)
_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213012521",
)
_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="DH200160121",
)
_fsp_4 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172409543",
)
_fsp_5 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172435189",
)
_fsp_6 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162608345",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1190206783",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1170412782",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="AHDB",
    radio_type=RadioTypes.AHDB,
    serial_number="6Q181107171",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.16.33", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="AHEGB",
    radio_type=RadioTypes.AHEGB,
    serial_number="EA203761430",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.34", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="AHCE",
    radio_type=RadioTypes.AHCE,
    serial_number="EB191760214",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.33", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="FZHM",
    radio_type=RadioTypes.FZHM,
    serial_number="RY152501299",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.33", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.68.179.224"),
    instance_id=884,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


# _rnc = RNC(rnc_id=36, oms_ip=NetworkAddress('10.44.44.218'), logging_ssh_connection_details=SshServiceDetails(addr='10.44.171.138', username='nokiadmin', password='system'))

# _bsc = BSC(name='BSC_mcBSC34', logging_telnet_connection_details=TelnetConnectionDetails(addr='10.44.139.2', username='SYSTEM', password='SYSTEM'))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NL_ASIB_1ABIO_1ABIN_1ABIL_ASIA_3ABIA_1AHEGB_1AHDB_1AHCE_1FZHM",
)

__all__ = ["tl"]
