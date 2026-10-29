__maintainer__ = "Lukasz Gajewski"
__team__ = "MN RAN DCM Vrf WRO 4 SG"
__email__ = "lukasz.gajewski@nokia.com"

from taf.config.testline.legacy import UTE_DCM
from taf.config.testline.pdu import Gude
from taf.config.testline.connection_details import SshServiceDetails, HttpConnectionDetails
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.gnb import DU, CU
from taf.config.testline.gnb.gnb import ClassicalBts

__all__ = ["tl"]

tl = UTE_DCM(
    ute_control_pc_host="10.44.234.49",
    gnb_control_pc_host=["10.44.234.49"],
    oam_airframe_l3sim_host="10.44.234.49",
    oam_airframe_mmt_host="10.44.234.51",
    oam_airframe_mmt_dct0="2",
    enb_control_pc_user="labadmin",
    enb_control_pc_password="uteadmin",
    enb_lcp_list=[0],
    enb_lsp_list=[],
    enb_fan_list=[],
    enb_lbr_list=[],
    enb_lni_list=[],
    enb_lps_list=[0],
    enb_type="lrc",
    gnb_pdu_ip=["10.45.177.43"],
    gnb_pdu_outlet=[2],
    gnb_id_list=[1],
    gnb_card_slot=[[1, 2]],
    gnb_fh_connect=[[1]],
    gnb_fh_bitrate=[[25]],
)
tl._set_attr("gnb_pdu_type", "GUDE")
tl._set_attr("gnb_pdu_version", "8221-1")

tl._set_attr("AS_TYPE", "ASIL_ABIO_ORAN")
tl._set_attr("ltesim_pc_host", "10.44.234.50")

tl._set_attr("af_type", "AFRM")
tl._set_attr("af_bmc_ip", "10.45.175.86")
tl._set_attr("af_bmc_bridge_ip", "10.44.234.49")
tl._set_attr("af_bmc_username", "admin")
tl._set_attr("af_bmc_passwd", "admin")
tl._set_attr(
    "ne3s_alarm_white_list", ["61029", "7115", "7107", "7116", "61050", "7220", "7100"]
)
tl._set_attr("oam_airframe_mediator_host", "10.44.234.52")
tl._set_attr("oam_airframe_mediator_user", "root")
tl._set_attr("oam_airframe_mediator_pwd", "uteadmin")
tl._set_attr("oam_airframe_mediator_interface", "ens4f0")
tl._set_attr("oam_airframe_mediator_sudo_pwd", "uteadmin")


tl._set_attr("enable_af_ssh_reset_WA", "yes")

tl._set_attr("gnb_logic_group", [[1]])

tl._set_attr("oran_sim_pc_host", ["10.44.234.49"])
tl._set_attr("oran_sim_version", ["v2.1.27"])

tl._set_attr("oran_sim_startup_snapshot", "/etc/orusim/AZQI_FR1_6beams.xml")
tl._set_attr("oran_sim_container_id", ["ute_oran_sim"])
tl._set_attr("oran_sim_pc_port", ["eth4"])
tl._set_attr("oran_sim_path", ["/home/ute/ute_oran_sim"])
tl._set_attr("oran_sim_container_path", ["/etc/orusim/"])

tl._set_attr("gnb_scard_name", "ASIL")
tl._set_attr("gnb_bcard_name", "ABIO")

tl._set_attr(
    "gnb_radio_info",
    {
        tl.gnb_id_list[0]: {
            "O-RU Sim": {
                "1": 1,
            }
        }
    },
)

tl._set_attr("gnb_control_pc_user", "ute")
tl._set_attr("gnb_control_pc_pwd", "ute")
tl._set_attr("ue_control_pc_user", "ute")
tl._set_attr("ue_control_pc_pwd", "ute")
tl._set_attr("windows_control_pc_user", "ute")
tl._set_attr("windows_control_pc_pwd", "ute")

tl._set_attr("oam_airframe_mmt_host_user", "labadmin")
tl._set_attr("oam_airframe_mmt_host_password", "uteadmin")

tl._set_attr("lmp_connection_addr", "192.168.255.129")
tl._set_attr("lmp_connection_username", "toor4nsn")
tl._set_attr("lmp_connection_pass", "oZPS0POrRieRtu")

tl._set_attr('oam_airframe_mediator_guest', '192.168.129.3')  # MEDIATOR guest OS
tl._set_attr('oam_airframe_mediator_guest_user', 'toor4nsn')
tl._set_attr('oam_airframe_mediator_guest_pwd', 'oZPS0POrRieRtu')

tl._set_attr("oam_http_addr", "192.168.255.129")
tl._set_attr("oam_http_port", "443")
tl._set_attr("oam_http_username", "Nemuadmin")
tl._set_attr("oam_http_password", "nemuuser")

_lmp_connection = SshServiceDetails(addr='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu')

_gnb_pdu = Gude(addr='10.45.177.43', port_numbers=[2], version="8221-1")

tl._set_attr('pdus', [_gnb_pdu])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[],
    pdu_port=_gnb_pdu.pdu_ports[2])

_airscale = Airscale(
    common_units=[_common_unit_0])

_du = DU(airscale=_airscale)

_cu = CU(
    backhaul_site_oam_ip='192.168.255.129',
    oam_ssh_connection_details=SshServiceDetails(
        addr='192.168.255.129',
        username='toor4nsn',
        password='oZPS0POrRieRtu'),
    oam_http_connection_details=HttpConnectionDetails(
        addr='192.168.255.129',
        username='Nemuadmin',
        password='nemuuser'))

_classicalbts = ClassicalBts(dus=[_du], cu=_cu)

tl._set_attr('gnbs', [_classicalbts])
