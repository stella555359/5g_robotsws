__maintainer__ = "Juliusz Mizera"
__team__ = "MN RAN K3"
__email__ = "juliusz.mizera@nokia.com"

from taf.config.testline.legacy import UTE_DCM

__all__ = ["tl"]

tl = UTE_DCM(
    ute_control_pc_host="10.42.75.6",
    gnb_control_pc_host=["10.42.75.6"],
    oam_airframe_l3sim_host="10.42.75.6",
    enb_lcp_list=[0],
    enb_lsp_list=[0],
    enb_fan_list=[],
    enb_lbr_list=[],
    enb_lni_list=[],
    enb_lps_list=[0],
    gnb_pdu_ip=["10.44.177.169"],
    gnb_pdu_outlet=[3],
    gnb_id_list=[1],
    gnb_card_slot=[[1, 2, 3]],
    gnb_fh_connect=[[1, 2]],
    gnb_fh_bitrate=[[25, 25]],
)

tl._set_attr("ltesim_pc_host", "10.42.75.6")
tl._set_attr("bts_name", "TL05")
tl._set_attr("af_type", "AF")
tl._set_attr("af_bmc_ip", "10.44.196.75")
tl._set_attr("af_bmc_username", "admin")
tl._set_attr("af_bmc_passwd", "admin")

tl._set_attr("enable_af_ssh_reset_WA", "no")

tl._set_attr("gnb_logic_group", [[1]])
tl._set_attr("BTSID", "33")
tl._set_attr("mrbts_id", "33")

tl._set_attr('oam_http_addr', '192.168.255.129')
tl._set_attr('oam_http_port', '443')
tl._set_attr('oam_http_username', 'Nemuadmin')
tl._set_attr('oam_http_password', 'nemuuser')

tl._set_attr('lmp_connection_addr', '192.168.255.129')
tl._set_attr('lmp_connection_username', 'toor4nsn')
tl._set_attr('lmp_connection_pass', 'oZPS0POrRieRtu')



tl._set_attr("specific_convert_mmt_dir", "/cygdrive/c/ute/MMT")

tl._set_attr("oran_sim_pc_host", ["10.42.75.6"])
tl._set_attr("oran_sim_version", ["v2.1.32"])
tl._set_attr("oran_sim_container_id", ["ute_oran_sim0"])
tl._set_attr("oran_sim_pc_port", ["eth2"])
tl._set_attr("oru_to_gnb_fh_interface", "docker0")
tl._set_attr("oran_sim_path", ["/home/ute/ute_oran_sim0"])
tl._set_attr("oran_sim_container_path", ["/etc/orusim"])

tl._set_attr("gnb_scard_name", "ASIL")
tl._set_attr("gnb_bcard_name", "ABIO")

tl._set_attr("gnb_radio_info", {tl.gnb_id_list[0]: {"O-RU Sim": {"1": 9}}})

tl._set_attr("gnb_control_pc_user", "ute")
tl._set_attr("gnb_control_pc_pwd", "ute")
tl._set_attr("ue_control_pc_user", "ute")
tl._set_attr("ue_control_pc_pwd", "ute")
tl._set_attr("windows_control_pc_user", "ute")
tl._set_attr("windows_control_pc_pwd", "ute")

tl._set_attr('oam_airframe_mmt_host_user', 'labadmin')
tl._set_attr('oam_airframe_mmt_host_password', 'uteadmin')
tl._set_attr('debug_run', 'True')
tl._set_attr('dm_enable', 'True')
tl._set_attr('hwy_type', '10g')
tl._set_attr('tl_type', 'airframe')
tl._set_attr('oru_sim_pc_user', 'ute')
tl._set_attr('oru_sim_pc_password', 'ute')
tl._set_attr('oru_sim_pc_host', ['10.42.75.6'])

tl._set_attr('ne3s_af_switch_type', ['NO SWITCH'])
tl._set_attr('ne3s_gnb_switch_type', 'NO SWITCH')