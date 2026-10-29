__owner__ = "Liu Xiaoyi"
__maintainer__ = "Liu Xiaoyi"
__email__ = "xiaoyi.liu@nokia-sbell.com "

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FACOM
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.ran import BSC, RNC
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

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.213.87", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.106.211.82",
    port_numbers=[7],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.56.7.222",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="facom",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS172932920",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS172932903",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="FSMF",
    hardware_version="084792A.102",
    serial_number="L6132016615",
)

_smod = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRHA:FRMr2.1_3T6R",
    serial_number="L1103509587",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FRHA:FRMr2.1_3T6R",
    serial_number="L1103605782",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="FHEB:FRMr2.3_2T2R_Reno",
    serial_number="L1131802572",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FHEB:FRMr2.3_2T2R_Reno",
    serial_number="L6143128409",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="FHEB:FRMr2.3_2T2R_Reno",
    serial_number="L6143145050",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="FHEB:FRMr2.3_2T2R_Reno",
    serial_number="L6143145049",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="FHEB:FRMr2.3_2T2R_Reno",
    serial_number="L6143033699",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_8 = RU(
    ru_hw_group="FHEB:FRMr2.3_2T2R_Reno",
    serial_number="L6143145028",
    pdu_port=_pdu_2.pdu_ports[8],
)

_enb_sbts = RealEnb(
    system_module=_smod,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)


tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_FCC_CRT2_1015_F2605",
)


__all__ = ["tl"]
