__maintainer__ = "Mariusz Kozlowski"
__team__ = "DCM"
__email__ = "mariusz.kozlowski@nokia.com"


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

_pdu_gnb = Gude(addr="10.45.177.61", port_numbers=[12], model="EPC", version="8221-1")

_abio_gnb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1223310015",
)


_asil_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1203708998",
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.234.93", username="ute", password="ute"
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
    tl_cloud_topology="CLOUD_DCM_ASIL_1xABIO_1xORUSIM_MED_EPC",
    pdus=[_pdu_gnb],
)

class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.44.234.96"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.44.234.95"
        username = "labadmin"
        password = "uteadmin"
        dct_interface = "2"

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


setattr(tl, "oran_sim_pc_host", ["10.44.234.93"])
setattr(tl, "oran_sim_version", ["UE_APP-OAM-0.3630"])
setattr(tl, "oran_sim_container_id", ["ru_sim_0"])
setattr(tl, "oran_sim_pc_port", ["eth4"])
setattr(tl, "oran_sim_path", ["/home/ute/ru_sim_0"])
setattr(tl, "oran_sim_container_path", ["/rom/simmode/"])

setattr(tl, "mediator", Mediator)
setattr(tl, 'oam_airframe_mediator_guest', '192.168.129.3')
setattr(tl, 'oam_airframe_mediator_guest_user', 'toor4nsn')
setattr(tl, 'oam_airframe_mediator_guest_pwd', 'oZPS0POrRieRtu')
setattr(tl, "oam_airframe_mediator_host", "10.44.234.96")
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
setattr(tl, "ltesim_pc_host", "10.44.234.94")
setattr(tl, "ltesim_x2_addr", "172.16.11.5")
setattr(tl, "gnb_x2_addr", "172.16.11.200")
setattr(tl, "enb_type", "lrc")
setattr(tl, 'gnb_id_list', [1])
setattr(tl, "lmp_connection_addr", "192.168.255.129")
setattr(tl, "epc_sim_vm_ip_address", "10.44.234.94")


setattr(tl, "af_type", "AFRM")
setattr(tl, "af_bmc_ip", "10.45.175.80")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "admin")
setattr(tl, "enable_af_ssh_reset_WA", "yes")

setattr(tl, "windows_control_pc_user", "labadmin")
setattr(tl, "windows_control_pc_pwd", "uteadmin")
setattr(tl, "oam_airframe_mmt_host_user", "labadmin")
setattr(tl, "oam_airframe_mmt_host_password", "uteadmin")
setattr(tl, "specific_convert_mmt_dir", "/cygdrive/c/ute/MMT")
setattr(tl, "has_mmt_tool", "true")
setattr(tl, "oam_airframe_mmt_host", "10.44.234.95")
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
setattr(tl, "l3sim_host", "10.44.234.93")
setattr(tl, "tm500_lte_version", "HSUPA - E4.0.4")
setattr(tl, "rnc_3g_host", "10.44.234.93")
setattr(tl, "tm500_3g_host", "10.44.234.93")
setattr(tl, "enb_control_pc_user", "labadmin")
setattr(tl, "enb_control_pc_password", "uteadmin")
setattr(tl, "enb_control_pc_host", "0.0.0.0")
setattr(tl, "ute_control_pc_host", "10.44.234.93")
setattr(tl, "gnb_control_pc_host", ["10.44.234.93"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "epc_host", "10.44.234.94")
setattr(tl, "enb_dct_0", "1")
setattr(tl, "enb_dct_1", "2")
setattr(tl, "dct_host", "10.44.234.93")
setattr(tl, "oam_airframe_l3sim_host", "10.44.234.93")
setattr(tl, "iphy_pdu_ip", "0.0.0.0")
setattr(tl, "iphy_pdu_outlet", "0.0.0.0")
setattr(tl, "enb_pdu_ip", "0.0.0.0")
setattr(tl, "enb_pdu_type", "ATEN")

setattr(tl, "gnb_pdu_type", "epc")
setattr(tl, "gnb_pdu_ip", ["10.45.177.61"])
setattr(tl, "gnb_pdu_outlet", [12])
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




#tl = UTE_DCM(
#    ute_control_pc_host="10.44.234.93",
#    gnb_control_pc_host=["10.44.234.93"],
#    oam_airframe_l3sim_host="10.44.234.93",
#    oam_airframe_mmt_host="10.44.234.95",
#    oam_airframe_mmt_dct0="2",
#    enb_control_pc_user="labadmin",
#    enb_control_pc_password="uteadmin",
#    enb_lcp_list=[0],
#    enb_lsp_list=[],
#    enb_fan_list=[],
#    enb_lbr_list=[],
#    enb_lni_list=[],
#    enb_lps_list=[0],
#    gnb_pdu_type='epc',
#    gnb_pdu_ip=["10.45.177.61"],
#    gnb_pdu_outlet=[12],
#    gnb_id_list=[1],
#    gnb_card_slot=[[1, 2, 3]],
#    gnb_fh_connect=[[1]],
#    gnb_fh_bitrate=[[25]],
#    enb_type="lrc",
#)

#tl._set_attr("gnb_pdu_version", "8221-1")

#tl._set_attr("AS_TYPE", "ASIL_ABIO_ORAN")
#tl._set_attr("ltesim_pc_host", "10.44.234.94")

#tl._set_attr("af_type", "AFRM")
#tl._set_attr("af_bmc_ip", "10.45.175.80")
#tl._set_attr("af_bmc_bridge_ip", "10.44.234.93")
#tl._set_attr("af_bmc_username", "cdslabuser")
#tl._set_attr("af_bmc_passwd", "airframe4cds")
#tl._set_attr(
#    "ne3s_alarm_white_list", ["61029", "7115", "7107", "7116", "61050", "7220", "7100"]
#)
#tl._set_attr("oam_airframe_mediator_host", "10.44.234.96")
#tl._set_attr("oam_airframe_mediator_user", "root")
#tl._set_attr("oam_airframe_mediator_pwd", "uteadmin")
#tl._set_attr("oam_airframe_mediator_interface", "ens4f0")
#tl._set_attr("oam_airframe_mediator_sudo_pwd", "uteadmin")


#tl._set_attr("enable_af_ssh_reset_WA", "yes")

#tl._set_attr("gnb_logic_group", [[1]])

#tl._set_attr("oran_sim_pc_host", ["10.44.234.93"])
#tl._set_attr("oran_sim_version", ["UE_APP-OAM-0.1899"])

#tl._set_attr("oran_sim_startup_snapshot", "/etc/orusim/AZQI_FR1_6beams.xml")
#tl._set_attr("oran_sim_container_id", ["ute_oran_sim"])
#tl._set_attr("oran_sim_pc_port", ["eth4"])
#tl._set_attr("oran_sim_path", ["/home/ute/ute_oran_sim"])
#tl._set_attr("oran_sim_container_path", ["/etc/orusim/"])

#tl._set_attr("gnb_scard_name", "ASIL")
#tl._set_attr("gnb_bcard_name", "ABIO")

#tl._set_attr(
#    "gnb_radio_info",
#    {
#        tl.gnb_id_list[0]: {
#            "O-RU Sim": {
#                "1": 1,
#            }
#        }
#    },
#)

#tl._set_attr("gnb_control_pc_user", "ute")
#tl._set_attr("gnb_control_pc_pwd", "ute")
#tl._set_attr("ue_control_pc_user", "ute")
#tl._set_attr("ue_control_pc_pwd", "ute")
#tl._set_attr("windows_control_pc_user", "ute")
#tl._set_attr("windows_control_pc_pwd", "ute")

#tl._set_attr("oam_airframe_mmt_host_user", "labadmin")
#tl._set_attr("oam_airframe_mmt_host_password", "uteadmin")

#tl._set_attr("lmp_connection_addr", "192.168.255.129")
#tl._set_attr("lmp_connection_username", "toor4nsn")
#tl._set_attr("lmp_connection_pass", "oZPS0POrRieRtu")

#tl._set_attr('oam_airframe_mediator_guest', '192.168.129.3')  # MEDIATOR guest OS
#tl._set_attr('oam_airframe_mediator_guest_user', 'toor4nsn')
#tl._set_attr('oam_airframe_mediator_guest_pwd', 'oZPS0POrRieRtu')

#tl._set_attr('oam_airframe_mediator_interface', 'ens4f0')  # dcmnet
#tl._set_attr('oam_airframe_mediator_sudo_pwd', 'uteadmin')

#tl._set_attr('mrbts_id', '1')
#tl._set_attr('gnb_control_pc_user', 'ute')
#tl._set_attr('gnb_control_pc_pwd', 'ute')
#tl._set_attr("oam_http_addr", "192.168.255.129")
#tl._set_attr("oam_http_port", "443")
#tl._set_attr("oam_http_username", "Nemuadmin")
#tl._set_attr("oam_http_password", "nemuuser")

#tl._set_attr('lmp_connection_addr', '192.168.255.129')
#tl._set_attr('lmp_connection_username', 'toor4nsn')
#tl._set_attr('lmp_connection_pass', 'oZPS0POrRieRtu')
