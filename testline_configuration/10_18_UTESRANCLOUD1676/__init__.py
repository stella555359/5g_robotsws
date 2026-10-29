__maintainer__ = "Mohamad Al Hamwi"
__email__ = "mohamad.al_hamwi@nokia.com"


from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes, FujitsuRadioTypes, FujitsuRU
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CoreUnit, Airscale
from taf.config.testline.connection_details import SshServiceDetails


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.47.11", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.131", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.1.60",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.1.122",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    product_code="476401A.101",
    serial_number="1M241500380",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_2 = FujitsuRU(
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00359",
    hw_version="0100",
    product_code="TA08029-B312/01",
    pdu_port=_pdu_2.pdu_ports[1],
    netconf_ssh_configuration=SshServiceDetails(
        addr="10.1.1.9", username="fjncuser0", password="ncCl2fjRu+autH0"
    )
)

_fct_1 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASOG",
    hardware_version="A.102",
    serial_number="L1250203728",
    rus=[_rmod_2],
)

_fct_2 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASOG",
    hardware_version="A.102",
    serial_number="L1250203731",
    rus=[_rmod_1],
)

_smod_1 = Airscale(core_units=[_fct_1])
_smod_2 = Airscale(core_units=[_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_2,
    ],
    oam_ip=NetworkAddress("10.15.232.76"),
    instance_id=10676,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_1, 
    ],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.core_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.core_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_N_10676_2ASOG_1OFEGSA_1AVQC",
)

__all__ = ["tl"]
