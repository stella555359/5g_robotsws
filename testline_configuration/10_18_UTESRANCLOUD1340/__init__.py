__maintainer__ = "Mohamad Al Hamwi"
__email__ = "mohamad.al_hamwi@nokia.com"

from taf.config.testline.airscale import Airscale, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.115", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_2 = Gude(
    addr="10.255.1.30",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1 = Gude(
    addr="10.255.1.31",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_3 = FPFH(
    addr="10.255.1.182",
    port_numbers=[1, 2, 3, 4, 5, 6],)


_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="K9234908764",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="K9234908770",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQJ.value,
    serial_number="K9234908765",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.10", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPB.value,
    serial_number="DH244316251",
    pdu_port=_pdu_2.pdu_ports[1],
)


_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9232737246",
    pdu_port=_pdu_2.pdu_ports[2],
)



_fct_1 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA213353938",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5]
)


_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.15.243.40"),
    instance_id=10340,
)


_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.core_units[0], interface_type="lmp"))

_bsc = BSC(
    name="BSC_AVENSIS_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.108", username="SYSTEM", password="SYSTEM"
    ),
)

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="Nemuadmin", password="Nokia@123"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_10340_1ASOE_2FRHC",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
