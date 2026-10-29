__maintainer__ = "MN ECE ULM R&D"
__team__ = "MN ECE ULM R&D"
__email__ = ""

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RealEnb
from taf.config.testline.core import EPCSim
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import Android
from taf.config.testline.radio import RU
from taf.config.testline.attenuator import JFW
from taf.config.testline.appserver import AppServer


# **********************************************************************************
cfg_dir = os.path.dirname(os.path.abspath(__file__))
# ********************************TestPc********************************************
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.202.161", username="ute", password="ute"
    )
)

_core_iperf_details = IperfDataTransferDetails(
    network_interface_address="192.168.60.254",
    ssh_connection_details=SshServiceDetails(
        addr="10.47.202.161", username="ute", password="ute"
    ),
    iperf_path="",
)

_core_appserver = AppServer(iperf_details=_core_iperf_details)

# *******************************Attenuator*****************************************
_gnb_rf_att = JFW(
    ip_addr="10.46.133.94",
    port="3001",
    attenuation_port_numbers=[2],
    model="",
    mode="blocks",
)
_gnb_du_rm1 = RU(ru_hw_group="", attenuation_ports=[_gnb_rf_att.attenuator_ports[2]])
# **********************************Core********************************************
_epcsim = EPCSim(
    mme_ip="192.168.4.1",
    mcc=777,
    mnc=44,
    tac=777,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.202.161", username="ute", password="ute"
    ),
    dir_path="/opt/wts/latest",
    cfg_filename="TL101_basic_cfg_realLteEnb.cfg",
    edaemon_port="22222",
    egate_port="20021",
)
# ********************************gNB***********************************************
_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
)
_gNB_capacity_unit = CapacityUnit(addr="192.168.253.20")
_gNB_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB_capacity_unit],
)
_gnb_airscale = Airscale(common_units=[_gNB_common_unit])
_du = DU(airscale=_gnb_airscale, rus=[_gnb_du_rm1])
_gnb = ClassicalBts(cu=_cu, dus=[_du])
# ********************************eNB***********************************************
_eNB_capacity_unit = CapacityUnit(addr="192.168.253.36")
_eNB_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.4.121", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB_capacity_unit],
)
_enb_airscale = Airscale(common_units=[_eNB_common_unit])
_enb = RealEnb(system_module=_enb_airscale)
# *********************************UE*********************************************
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.134.63", username="deul5g", password="Nuc2Ue4PzLab!"
)

_iperf_details = IperfDataTransferDetails(
    network_interface_address="",
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    iperf_path="",
)

_ue1 = Android(
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    serial_number="401478b0",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    iperf_details=_iperf_details,
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
)
# ******************************************************************************
tl = TestLine(
    test_pc=_host,
    gnbs=[_gnb],
    enbs=[_enb],
    core=_epcsim,
    ues=[_ue1],
    appserver=_core_appserver,
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)

__all__ = ["tl"]
