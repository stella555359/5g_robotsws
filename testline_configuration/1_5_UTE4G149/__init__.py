__owner__ = "qling"
__maintainer__ = "qling"
__email__ = "ling>qin@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.94.119", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# _pdu_1 = FACOM(
#    addr="10.68.94.26",
#    port_numbers=[3, 4],
#    model="facom",
# )
_pdu_2 = HBTE(
    addr="10.68.94.87",
    port_numbers=[1, 2],
    model="hbte",
)
_pdu_3 = FACOM(
    addr="10.68.94.24",
    port_numbers=[4],
    model="facom",
)
_pdu_4 = FACOM(
    addr="10.106.173.12",
    port_numbers=[8],
    model="facom",
)


_rmod_1 = RU(
    ru_hw_group="AEHB:ECPRI_MPLANE",
    serial_number="L1213414034",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="AEHB:ECPRI_MPLANE",
    serial_number="L1203204640",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="AEHB:ECPRI_MPLANE",
    serial_number="L1212814012",
    pdu_port=_pdu_2.pdu_ports[2],
)
# _rmod_4 = RU(
#    ru_hw_group="AZNA:CPRI_RP1_4T4R",
#    serial_number="6Q174302322",
#    pdu_port=_pdu_1.pdu_ports[4],
# )
# _rmod_5 = RU(
#    ru_hw_group="AZNA:CPRI_RP1_4T4R",
#    serial_number="6Q172911044",
#    pdu_port=_pdu_1.pdu_ports[3],
# )

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA214652508",
    pdu_port=_pdu_4.pdu_ports[8],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_4.pdu_ports[8],
    hardware_type="ASOE",
    hardware_version="475587A",
    serial_number="EA214652508",
    capacity_units=[_fsp_1],
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_smod = Airscale([_fct_1])
_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_CB007506",
)

__all__ = ["tl"]
