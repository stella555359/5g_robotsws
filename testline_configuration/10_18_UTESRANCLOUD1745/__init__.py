__maintainer__ = "None"
__email__ = "None"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.123", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_2 = Gude(
    addr="10.255.1.41",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_1 = APC(
    addr="10.255.1.42",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173003803",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1210700869",
)

_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101524",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH204667825",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA,
    serial_number="RW201700129",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQA,
    serial_number="L1251502473",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB,
    serial_number="F7164314976",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.15.236.145"),
    instance_id=10745,
)


_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))


_rnc = RNC(
     rnc_id=252,
     oms_ip=NetworkAddress("10.92.249.149"),
     logging_ssh_connection_details=SshServiceDetails(
         addr="10.91.190.126", username="Nemuadmin", password="Nokia@123"
     ),
 )


_bsc = BSC(
     name="BSC_KAISA_SBTS",
     logging_telnet_connection_details=TelnetConnectionDetails(
         addr="10.92.249.36", username="SYSTEM", password="SYSTEM"
     ),
 )

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_NLWG_10745_ASIB_ABIA_ABIN_ABIO_AZNB_AEHC_FXDB",
     bscs=[_bsc],
     rncs=[_rnc],
)


__all__ = ["tl"]
