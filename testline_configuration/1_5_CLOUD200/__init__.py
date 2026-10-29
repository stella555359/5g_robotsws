__maintainer__ = "Lei Bibo"
__email__ = "bibo.lei@nokia-sbell.com"

from taf.config.testline.ue import Android
from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.flexi import Flexi
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails


_pdu_1 = HBTE(
    addr="10.108.190.35",
    port_numbers=[1],
)


_pdu_2 = HBTE(
    addr="10.108.190.34",
    port_numbers=[1, 2, 3],
)

_rmod_1 = RU(
    ru_hw_group="CPRI_IR_RRH_8T8R",
    radio_type="FZFF-e",
    serial_number="10YSV10E9004088",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="CPRI_IR_RRH_8T8R",
    radio_type="FZFF-e",
    serial_number="11BYU6TF8400592",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="CPRI_IR_RRH_8T8R",
    radio_type="FZFF-e",
    serial_number="11BYU6TF8400455",
    pdu_port=_pdu_2.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="FBIH",
    hardware_version="A.101",
    serial_number="EA174511973",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSIH",
    hardware_version="A",
    serial_number="EA170136273",
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

_smod = Flexi([_fct_1])

_ue_pc_ssh = SshServiceDetails(
    addr="10.106.208.177", username="siso2-tester", password="Nokia123!"
)
_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.196",
    iperf_path="iperf",
)
_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="UQG5T20A29004523",
    server_dir="C:/Program Files (x86)/DingLi/Pilot Pioneer10.5.9.54---05161057/Pioneer.exe",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM31",
    iperf_details=_android_iperf,
    capabilities=["REAL_ANDROID_UE", "REAL_UE"],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.224", username="ute", password="UTE.debian12"
    ),
    connections=[_enb_sbts.system_module.common_units[0], NetworkAddress(v4="192.168.255.126")],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    ues=[_android_ue],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_4G_CLASSICAL_FSIH_FBIH_3xFZFF-e",
)

__all__ = ["tl"]
