__maintainer__ = "Monika Szczeciak"
__team__ = "DCM"
__email__ = "monika.szczeciak@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import ATEN, Gude, EPC


__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    )
)

_pdu_gnb = Gude(addr="10.44.200.92", port_numbers=[5, 6], model="EPC", version="8221-1")

_abio_gnb_1_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="105",
    serial_number="L1232103669",
)

_abio_gnb_2_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="105",
    serial_number="L1232101284",
)

_abio_gnb_2_2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="101",
    serial_number="L1223310010",
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1_1],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH220746873",
    pdu_port=_pdu_gnb.pdu_ports[5],
)

_asil_gnb_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_2_1, _abio_gnb_2_2],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1231602334",
    pdu_port=_pdu_gnb.pdu_ports[6],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.234", username="ute", password="ute"
    ),
    connections=[_asil_gnb_1, _asil_gnb_2],
)

_ru1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQI",
    serial_number="1M222634117",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
)

_airscale_gnb_1 = Airscale([_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

_core = RealCore5G()


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_2xASIL_2xABIO_4xRUSIM_MED_EPC",
    core=_core,
    pdus=[_pdu_gnb],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.61.22"
        username = "root"
        password = "uteadmin"
        dcmnet_interface = "ens43f0"

    class MMT:
        hostname = "10.42.221.236"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = 2

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


setattr(tl, "mediator", Mediator)

setattr(tl, "mrbts_id", "50029")
# setattr(tl, "epc_sim_vm_ip_address", "10.42.221.235")
# setattr(tl, "ltesim_pc_host", "10.42.221.235")

setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")

setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.42.210.194")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "admin")

setattr(tl, "sw_builds_ftp_address", "10.68.251.31")
setattr(tl, "sw_builds_ftp_username", "ute")
setattr(tl, "sw_builds_ftp_password", "Nemuuser#365")

setattr(tl, "specific_convert_mmt_dir", "/cygdrive/c/BS4001_Tools/MMT")
setattr(tl, "gnb_radio_info", {1: {"O-RU Sim": {"1": 1}}})

setattr(tl, "enable_af_ssh_reset_WA", "no")
setattr(tl, "enb_type", "epc")
setattr(tl, 'gnb_id_list', [1])
setattr(tl, "tm500_ver", "HSUPA - E4.0.4")
setattr(tl, "enb_cpri_links", "[1, 4, 14, 17, 27, 30, 7, 8, 9, 2]")
setattr(tl, "has_mmt_tool", "false")
setattr(tl, "windows_control_pc_user", "ute")
setattr(tl, "windows_control_pc_pwd", "ute")
setattr(tl, "oam_airframe_mmt_host_user", "labadmin")
setattr(tl, "oam_airframe_mmt_host_password", "uteadmin")
setattr(tl, 'oam_http_addr', '192.168.255.129')
setattr(tl, 'oam_http_port', '443')
setattr(tl, 'oam_http_username', 'Nemuadmin')
setattr(tl, 'oam_http_password', 'nemuuser')
setattr(tl, "enb_control_pc_user", "ute")
setattr(tl, "enb_control_pc_password", "ute")
setattr(tl, "enb_control_pc_host", "10.42.221.234")
setattr(tl, "ute_control_pc_host", "10.42.221.234")
setattr(tl, "gnb_control_pc_host", ["10.42.221.234"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "iphy_pdu_ip", "0.0.0.0")
setattr(tl, "iphy_pdu_outlet", "0.0.0.0")
setattr(tl, "epc_host", "10.42.221.234")
setattr(tl, "enb_dct_0", "1")
setattr(tl, "l3sim_host", "10.42.221.234")
setattr(tl, "tm500_lte_version", "HSUPA - E4.0.4")
setattr(tl, "dct_host", "10.42.221.234")
setattr(tl, "rnc_3g_host", "10.42.221.234")
setattr(tl, "tm500_3g_host", "10.42.221.234")
setattr(tl, "oam_airframe_l3sim_host", "10.42.221.234")
setattr(tl, "enb_pdu_ip", "0.0.0.0")
setattr(tl, "enb_pdu_type", "ATEN")
setattr(tl, "oam_airframe_mmt_host", "0.0.0.0")
setattr(tl, "gnb_card_slot", [[1, 2]])
setattr(tl, "gnb_fh_connect", [[1]])
setattr(tl, "gnb_fh_bitrate", [[25, 25]])
