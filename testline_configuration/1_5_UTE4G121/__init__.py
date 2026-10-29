__owner__ = "Ding Lisa"
__maintainer__ = "Ding Lisa"
__email__ = "lisa.ding@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)


_pdu_1 = FACOM(
    addr="10.108.151.187",
    port_numbers=[4],
)

_pdu_2 = HBTE(
    addr="10.108.151.81",
    port_numbers=[1, 2],
)

_pdu_3 = FACOM(
    addr="10.108.164.133",
    port_numbers=[2],
)

_pdu_4 = FACOM(
    addr="10.106.198.104",
    port_numbers=[1, 4],
)

_pdu_5 = FACOM(
    addr="10.108.151.63",
    port_numbers=[2],
)
_pdu_6 = FACOM(
    addr="10.108.151.97",
    port_numbers=[1, 2],
)

_rmod_1 = RU(
    ru_hw_group="AEHB:ECPRI_RRH_64T64R",
    radio_type="AEHB",
    serial_number="L1213414034",
    pdu_port=_pdu_3.pdu_ports[2],
 )

_rmod_2 = RU(
    ru_hw_group="AEHC:ECPRI_RRH_64T64R",
    radio_type="AEHC",
    serial_number="L1202005432",
    pdu_port=_pdu_2.pdu_ports[1],
 )

_rmod_3 = RU(
    ru_hw_group="AEHB:ECPRI_RRH_64T64R",
    radio_type="AEHB",
    serial_number="L1213414036",
    pdu_port=_pdu_2.pdu_ports[2],
 )

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1214206711",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.101",
    serial_number="DH212971862",
    capacity_units=[_fsp_1],
)

_smod = Airscale([_fct_1])



#_rmod_4 = RU(
#    ru_hw_group="AZHA:CPRI_RRH_4T4R",
#    serial_number="6Q182105248",
#    pdu_port=_pdu_6.pdu_ports[1],
# )

#_rmod_5 = RU(
#    ru_hw_group="AZHA:CPRI_RRH_4T4R",
#    serial_number="6Q182105431",
#    pdu_port=_pdu_6.pdu_ports[2],
# )
 
_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3])


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.151.224", username="ute", password="ute"
    ),
    connections=[_enb_sbts.system_module.common_units[0], NetworkAddress(v4="192.168.255.126")],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIR_B4_CRT2_1121_AEHC",
)

__all__ = ["tl"]
