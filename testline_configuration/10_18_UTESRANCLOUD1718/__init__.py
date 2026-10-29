# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Bogdan Boldurean"
__email__ = "bogdan.boldurean@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails

from taf.config.testline.testpc import TestPc, Connection

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.97", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.98", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.1.5", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.1.6", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164816616",
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="473096A.103",
    serial_number="L1213010346",
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA192071918",
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA192171673",
)

_fsp_5 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA192071705",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="L1214401576",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIA",
    serial_number="RW192007390",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="K9170422433",
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="K9173416088",
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEB.value,
    serial_number="EA193373427",
    pdu_port=_pdu_1.pdu_ports[11],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M174051490",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7164310627",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fsp_1.rus = ([_rmod_3, _rmod_4, _rmod_5])
_fsp_2.rus = ([_rmod_3])
_fsp_3.rus = ([_rmod_1, _rmod_2, _rmod_4, _rmod_5])
_fsp_4.rus = ([])
_fsp_5.rus = ([])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.15.236.118"),
    instance_id=10718,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_4, _rmod_5],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.27.141.158"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.141.158", username="Nemuadmin", password="systeM123!"
    ),
)

_bsc = BSC(
    name="BSC_ASTRA_SBTS",
        logging_telnet_connection_details=SshServiceDetails(
        addr="10.27.142.199", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1718_1ASIB_1ASIA_4ABIA_1ABIO_2FRGY_1AHEB_2FXDB",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
