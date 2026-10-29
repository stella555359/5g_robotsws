__maintainer__ = "Luca Nicolae Carabenciov"
__email__ = "luca_nicolae.carabenciov@nokia.com"
__owner_email__ = "mihai.rusu@nokia.com"

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
from taf.config.testline.testpc import TestPc, Connection


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.17", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.1.69",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)


_pdu_2 = Gude(
    addr="10.255.1.70",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
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
    addr="", hardware_type="FBBC", hardware_version="A.101", serial_number="AS172233398"
)
_fsp_2 = CapacityUnit(
    addr="", hardware_type="FBBC", hardware_version="A.101", serial_number="AS172531389"
)
# _fsp_1 = CapacityUnit(addr='None', hardware_type='FBBC', hardware_version='472797A.101',  serial_number='AS172233398')


# _fct_1 = CommonUnit(SshServiceDetails(addr='192.168.255.1', username='toor4nsn', password='oZPS0POrRieRtu'), capacity_units=[_fsp_1], pdu_port=_pdu_2.pdu_ports[3], hardware_type='FSMF', hardware_version='A.104',serial_number='EA161260472')
_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="A",
    serial_number="EA161260472",
)

_smod_1 = Flexi([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9190103654",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.232", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.2_3T6R",
    radio_type=RadioTypes.FXFA.value,
    serial_number="F7144106789",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.207", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9190103644",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.233", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9193230035",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.231", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="FRMr2.2_3T6R",
    radio_type=RadioTypes.FXFA.value,
    serial_number="L6114739665",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.5.38.88"),
    instance_id=10088,
)


_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.120", username="", password=""
    ),
)

_bsc = BSC(
    name="BSC_ANNA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.41.117.108", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_LWG_1FSMF_2FBBC_3AHEGB_2FXFA",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
