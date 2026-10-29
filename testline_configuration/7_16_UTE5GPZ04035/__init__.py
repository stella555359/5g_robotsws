__maintainer__ = "Patryk Dabrowa"
__team__ = "MN RAN Pz 1 WRO 10 SG"
__email__ = "patryk.dabrowa@nokia.com"

from taf.config.testline.legacy import UTE_DCM

__all__ = ["tl"]

tl = UTE_DCM(
    ute_control_pc_host="10.42.75.236",
    gnb_control_pc_host=["10.42.75.236"],
    oam_airframe_l3sim_host="10.42.75.236",
    oam_airframe_mmt_host="10.42.75.240",
    oam_airframe_mmt_dct0="2",
    enb_control_pc_user="labadmin",
    enb_control_pc_password="uteadmin",
    enb_lcp_list=[0],
    enb_lsp_list=[],
    enb_fan_list=[],
    enb_lbr_list=[],
    enb_lni_list=[],
    enb_lps_list=[0],
    gnb_pdu_type="aten",
    gnb_pdu_ip=["10.44.206.118"],
    gnb_pdu_outlet=[5],
    gnb_id_list=[1],
    gnb_card_slot=[[1, 2, 3]],
    gnb_fh_connect=[[1]],
    gnb_fh_bitrate=[[25]],
)

tl._set_attr("ltesim_pc_host", "10.42.75.238")

tl._set_attr("af_type", "AFOE")
tl._set_attr("af_bmc_ip", "10.42.210.115")
tl._set_attr("af_bmc_bridge_ip", "10.42.75.236")
tl._set_attr("af_bmc_username", "admin")
tl._set_attr("af_bmc_passwd", "Airframe4cds!dcm")

tl._set_attr("enable_af_ssh_reset_WA", "yes")

tl._set_attr("gnb_logic_group", [[1]])

tl._set_attr("oran_sim_pc_host", ["10.42.75.236"])
tl._set_attr("oran_sim_version", ["UE_APP-OAM-0.1914"])

tl._set_attr("oran_sim_startup_snapshot", "/etc/orusim/AZQI_FR1_6beams.xml")

tl._set_attr("oran_sim_container_id", ["ute_oran_sim"])
tl._set_attr('oran_sim_pc_port', ['eth5'])
tl._set_attr("oran_sim_path", ["/home/ute/ute_oran_sim"])
tl._set_attr("oran_sim_container_path", ["/etc/orusim"])

tl._set_attr("gnb_scard_name", "ASIL")
tl._set_attr("gnb_bcard_name", "ABIO")

tl._set_attr("oam_airframe_mediator_host", "10.42.75.242")
tl._set_attr("oam_airframe_mediator_user", "ute")
tl._set_attr("oam_airframe_mediator_pwd", "Ut3pa5s#1be1")
tl._set_attr("oam_airframe_mediator_interface", "ens43f0")
tl._set_attr("oam_airframe_mediator_sudo_pwd", "Ut3pa5s#1be1")

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
tl._set_attr("mrbts_id", "1")
tl._set_attr("nrbts_id", "1")

tl._set_attr('oam_airframe_mediator_guest', '192.168.129.3')  # MEDIATOR guest OS
tl._set_attr('oam_airframe_mediator_guest_user', 'toor4nsn')
tl._set_attr('oam_airframe_mediator_guest_pwd', 'oZPS0POrRieRtu')

tl._set_attr("edaemon_port", "10000")
tl._set_attr("egate_port", "20000")

tl._set_attr("oam_http_addr", "192.168.255.129")
tl._set_attr("oam_http_port", "443")
tl._set_attr("oam_http_username", "Nemuadmin")
tl._set_attr("oam_http_password", "nemuuser")
