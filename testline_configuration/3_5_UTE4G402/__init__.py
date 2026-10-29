# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "zefxu"
__email__ = "zefang.xu@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.ue import (
    AirphoneCloud,
    Airphone,
    Prisma,
    TM500,
    Qualcomm,
    QualcommUeType,
    Android,
)  # added in taf.meta.5.4
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, FACOM
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.70.87.23", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# FACOM & APC
_pdu_1 = FACOM(
    addr="10.108.228.6",
    port_numbers=[6],
    model="facom",
)
_pdu_2 = FACOM(
    addr="10.108.228.6",
    port_numbers=[5],
    model="FACOM",
)

# BBMODs
_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q183209078",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9173257929",
)

_pdu_3 = Gude("10.108.228.22", [5], "APC", "")

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.108.228.10",
    username="ute",
    password="ute",
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.108.228.10",
    iperf_path="/usr/bin/iperf",
    port="43033",
)

_appserver = AppServer(_iperf)

# Qualcomm (ipaddr, username, password?)
_ue1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.68.86.137", username="nokia5G", password="noki@123"
    ),
    serial_number="5CG51711SD",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["RRM3_Qualcomm8250", "Qualcomm"],
    # capabilities=['REAL_ANDROID_UE']
)

# SMOD
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1163606831",
)

_smod_1 = Airscale([_fct_1])

# RMOD (ipaddr?)
_rmod_1 = RU(
    ru_hw_group="cMAA_Gen3.14_64T64R",
    radio_type=RadioTypes.AAHF,
    serial_number="6Q190330145",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.17.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    global_bts_id=823,
    oam_ip=NetworkAddress("10.70.87.31"),
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    # ues=[_ue1],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIL_B1_B2_CRT_1402",
)

__all__ = ["tl"]
