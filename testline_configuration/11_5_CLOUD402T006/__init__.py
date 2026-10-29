import os

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline import DU, RU
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.pdu import FACOM
from taf.config.testline.ue import Android
from taf.config.testline.core import EPCSim, RealCore4G
from taf.config.testline import RealEnb

__maintainer__ = "LuoFei Tu"
__team__ = "I_NSB_MN_CRAN_PZ_SYSTEM_INT_SISO_TRS1_VRF_GMS <I_NSB_MN_CRAN_PZ_SYSTEM_INT_SISO_TRS1_VRF@internal.nsn.com>"
__email__ = "luofei.tu@nokia-sbell.com"
__owner_email__ = "luofei.tu@nokia-sbell.com"


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


# Test PC
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.57.157.21", username="ute", password="ute"
    )
)

# #RealEnb
_real_enb_pdu = FACOM(addr="10.108.227.9", port_numbers=[3])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.108.227.9", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[3],
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

##5GRU for classicalBTS
_ru_pdu = FACOM(addr="10.108.227.131", port_numbers=[3])

_ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="user", password="pass"
    ),
    lmp_connection=SshServiceDetails(addr="1.1.1.1", username="user", password="pass"),
    pdu_port=_ru_pdu.pdu_ports[3],
)

##DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="10.108.227.134", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="6.6.6.6")

_gnb_pdu = FACOM(addr="10.108.227.134", port_numbers=[4])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[4],
)

_airscale = Airscale(common_units=[_common_unit_0])

_du = DU(airscale=_airscale, rus=[_ru])


##CU
_cu = CU(
    backhaul_site_oam_ip="",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.227.134", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.108.227.134", username="Nemuadmin", password="nemuuser"
    ),
)


##cloud_topology
_tl_cloud_topology = "CLOUD_5G_BB3"

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu)

_appserver_ssh = SshServiceDetails(
    addr="10.70.33.130", username="root", password="nokia123"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.70.33.130",
    iperf_path="/opt/bin/iperf",
)

_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.108.227.15", username="miller.liu", password="nokiaE2E@"
    ),
    serial_number="90b918c0",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
)

tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    enbs=[_lte_real_enb],
    ues=[_android],
    tl_cloud_topology=_tl_cloud_topology,
)

__all__ = ["tl"]
