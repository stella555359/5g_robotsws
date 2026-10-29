__owner__ = "linlen"
__maintainer__ = "linlen"
__email__ = "len.lin@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import  Gude, FACOM, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_pdu_1 = FPFH(
    addr="10.108.190.74",
    port_numbers=[5, 6],
)

_pdu_2 = FPFH(
    addr="10.108.190.75",
    port_numbers=[1, 2, 3, 4, 5],
)

_rmod_1 = RU(
    ru_hw_group="AZHL:CPRI_RP1",
    radio_type="AZHL",
    serial_number="AH220201219",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="AHFIB:CPRI_RP1",
    radio_type="AHFIB",
    serial_number="BL2249V0EDZ",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="AHFIB:CPRI_RP1",
    radio_type="AHFIB",
    serial_number="K9182845210",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="AHFIB:CPRI_RP1",
    radio_type="AHFIB",
    serial_number="K9182845206",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="AZHL:CPRI_RP1",
    radio_type="AZHL",
    serial_number="AH211900758",
    pdu_port=_pdu_2.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="EA200950279",
    pdu_port=_pdu_1.pdu_ports[5],
    rus=[_rmod_3, _rmod_4],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1192906296",
    pdu_port=_pdu_1.pdu_ports[5],
    rus=[_rmod_2],
)


_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="DH220846050",
    pdu_port=_pdu_1.pdu_ports[6],
    rus=[_rmod_1, _rmod_5],
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="DH232142049",
    capacity_units=[_fsp_1, _fsp_2],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="DH224041019",
    capacity_units=[_fsp_4],
)

_smod1 = Airscale([_fct_1])
_smod2 = Airscale([_fct_2])

_enb_sbts1 = RealEnb(system_module=_smod1, rms=[_rmod_2, _rmod_3, _rmod_4])
_enb_sbts2 = RealEnb(system_module=_smod2, rms=[_rmod_1, _rmod_5])


_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.36", username="ute", password="ute"
    ),
    connections=[_enb_sbts1.system_module.common_units[0], NetworkAddress(v4="192.168.255.126")],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.37", username="ute", password="ute"
    ),
    connections=[_enb_sbts2.system_module.common_units[0], NetworkAddress(v4="192.168.255.126")],
)


tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    enbs=[_enb_sbts1, _enb_sbts2],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AILR_B1_B4_AHFIB_AZHL_TMO",
)

__all__ = ["tl"]
