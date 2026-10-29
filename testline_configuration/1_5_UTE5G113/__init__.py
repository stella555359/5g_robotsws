__maintainer__ = "qianzhou"
__owner_email__ = "qiang.1.zhou@nokia-sbell.com"
__email__ = "qiang.1.zhou@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import FACOM
from taf.config.testline.radio import RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline import DU, RU, NetworkAddress
from taf.config.testline.ue import Android
from taf.config.testline.radio import RU
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails


_pdu_1 = FACOM(addr="10.69.67.120", port_numbers=[1, 2, 5, 6])

# 3*AWHTA
_rmod_1 = RU(
    ru_hw_group="CPRI_mRRH_4T4R",
    radio_type=RadioTypes.AWHTA.value,
    serial_number="EB2131R0113",
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="CPRI_mRRH_4T4R",
    radio_type=RadioTypes.AWHTA.value,
    serial_number="EB2150R0903",
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="CPRI_mRRH_4T4R",
    radio_type=RadioTypes.AWHTA.value,
    serial_number="EB2147R0439",
    pdu_port=_pdu_1.pdu_ports[2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOE",
    hardware_version="A.102",
    serial_number="EA214652546",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_du_1 = DU(
    Airscale(common_units=[_fct_1]),
    rus=[_rmod_1, _rmod_2, _rmod_3],
    f1_m_ip_addr="10.106.208.44",
)

_cu_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=10105, instance_id=10105)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.108.144.107",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)


_ue_pc_ssh = SshServiceDetails(
    addr="10.106.211.124", username="siso1-tester", password="Nokia123!"
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196",
    username="tdlte-tester",
    password="btstest",
)
_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.108.144.107",
    iperf_path="iperf",
)
_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="9YS0220804012673",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    dmc_path="C:/Users/user-lab0/adam.dmc",
    diag_com="COM11",
    iperf_details=_android_iperf,
    capabilities=["REAL_ANDROID_UE", "REAL_UE"],
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.242", username="ute", password="ute"
    ),
    connections=[_classical_bts_1.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    ues=[_android_ue],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASOE_3xAWHTA_113",
    pdus=[_pdu_1],
)

__all__ = ["tl"]
