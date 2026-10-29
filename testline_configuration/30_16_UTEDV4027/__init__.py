__maintainer__ = "Mateusz Kowalczyk"
__team__ = "DCM"
__email__ = "mateusz.kowalczyk@nokia.com"


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

_pdu_gnb = Gude(addr="10.45.177.61", port_numbers=[11], model="EPC", version="8221-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1211903521",
)

_abio_gnb_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1211508070",
)

_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1, _abio_gnb_2],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="DH222244811",
    pdu_port=_pdu_gnb.pdu_ports[11],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.234.97", username="ute", password="ute"
    ),
    connections=[_asil_gnb],
)

_airscale_gnb_1 = Airscale([_asil_gnb])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=27
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_ASIL_2xABIO_2xORUSIM_MED_EPC",
    pdus=[_pdu_gnb],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.44.234.101"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.44.234.99"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = "2"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


setattr(tl, "oran_sim_pc_host", ["10.44.234.97"])
setattr(tl, "oran_sim_version", ["UE_APP-OAM-0.2742"])
setattr(tl, "oran_sim_container_id", ["ru_sim_0"])
setattr(tl, "oran_sim_pc_port", ["eth4"])
setattr(tl, "oran_sim_path", ["/home/ute/ru_sim_0"])
setattr(tl, "oran_sim_container_path", ["/rom/simmode/"])


setattr(tl, "mediator", Mediator)
setattr(tl, 'oam_airframe_mediator_guest', '192.168.129.3')
setattr(tl, 'oam_airframe_mediator_guest_user', 'toor4nsn')
setattr(tl, 'oam_airframe_mediator_guest_pwd', 'oZPS0POrRieRtu')
setattr(tl, "oam_airframe_mediator_host", "10.44.234.101")
setattr(tl, "oam_airframe_mediator_user", "root")
setattr(tl, "oam_airframe_mediator_pwd", "uteadmin")
setattr(tl, "oam_airframe_mediator_interface", "ens4f0")
setattr(tl, "oam_airframe_mediator_sudo_pwd", "uteadmin")

setattr(tl, "gnb_scard_name", "ASIL")
setattr(tl, "gnb_bcard_name", "ABIO")
setattr(tl, "mrbts_id", "1")
setattr(tl, 'oam_http_addr', '192.168.255.129')
setattr(tl, 'oam_http_port', '443')
setattr(tl, 'oam_http_username', 'Nemuadmin')
setattr(tl, 'oam_http_password', 'nemuuser')
setattr(tl, "ltesim_pc_host", "10.44.234.98")
setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")
setattr(tl, "enb_type", "lrc")
setattr(tl, 'gnb_id_list', [1])
setattr(tl, "lmp_connection_addr", "192.168.255.129")
setattr(tl, "epc_sim_vm_ip_address", "10.44.234.98")

setattr(tl, "af_type", "AFRM")
setattr(tl, "af_bmc_ip", "10.45.175.89")
setattr(tl, "af_bmc_username", "cdslabuser")
setattr(tl, "af_bmc_passwd", "airframe4cds")
setattr(tl, "enable_af_ssh_reset_WA", "yes")

setattr(tl, "windows_control_pc_user", "labadmin")
setattr(tl, "windows_control_pc_pwd", "uteadmin")
setattr(tl, "oam_airframe_mmt_host_user", "labadmin")
setattr(tl, "oam_airframe_mmt_host_password", "uteadmin")
setattr(tl, "specific_convert_mmt_dir", "/cygdrive/c/ute/MMT")
setattr(tl, "has_mmt_tool", "true")
setattr(tl, "oam_airframe_mmt_host", "10.44.234.99")
setattr(tl, "oam_airframe_mmt_dct0", "2")

setattr(tl, "gnb_card_slot", [[1, 2, 3]])
setattr(tl, "gnb_fh_connect", [[1]])
setattr(tl, "gnb_fh_bitrate", [[25]])
setattr(tl, "enb_lcp_list", [0])
setattr(tl, "enb_lsp_list", [])
setattr(tl, "enb_fan_list", [])
setattr(tl, "enb_lbr_list", [])
setattr(tl, "enb_lni_list", [])
setattr(tl, "enb_lps_list", [0])
setattr(tl, "enb_lbi", "0")
setattr(tl, "enb_lca", "0")

setattr(tl, "enb_cpri_links", "[1, 4, 14, 17, 27, 30, 7, 8, 9, 2]")
setattr(tl, "tm500_ver", "HSUPA - E4.0.4")
setattr(tl, "l3sim_host", "10.44.234.97")
setattr(tl, "tm500_lte_version", "HSUPA - E4.0.4")
setattr(tl, "rnc_3g_host", "10.44.234.97")
setattr(tl, "tm500_3g_host", "10.44.234.97")
setattr(tl, "enb_control_pc_user", "labadmin")
setattr(tl, "enb_control_pc_password", "uteadmin")
setattr(tl, "enb_control_pc_host", "0.0.0.0")
setattr(tl, "ute_control_pc_host", "10.44.234.97")
setattr(tl, "gnb_control_pc_host", ["10.44.234.97"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "epc_host", "10.44.234.98")
setattr(tl, "enb_dct_0", "1")
setattr(tl, "enb_dct_1", "2")
setattr(tl, "dct_host", "10.44.234.97")
setattr(tl, "oam_airframe_l3sim_host", "10.44.234.97")
setattr(tl, "iphy_pdu_ip", "0.0.0.0")
setattr(tl, "iphy_pdu_outlet", "0.0.0.0")
setattr(tl, "enb_pdu_ip", "0.0.0.0")
setattr(tl, "enb_pdu_type", "ATEN")

setattr(tl, "gnb_pdu_type", "epc")
setattr(tl, "gnb_pdu_ip", ["10.45.177.61"])
setattr(tl, "gnb_pdu_outlet", [11])
setattr(tl, "ue_control_pc_user", "labadmin")
setattr(tl, "ue_control_pc_pwd", "uteadmin")


setattr(tl, "mediator_uec_port", "10000")
setattr(tl, "mediator_edaemon_port", "10010")
setattr(tl, "mediator_l3_sim_port", "10020")
setattr(tl, "mediator_egate_port", "20000")


setattr(tl,
    "gnb_radio_info",
    {
        tl.gnb_id_list[0]: {
            "O-RU Sim": {
                "1": 1,
            }
        }
    },
)
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
