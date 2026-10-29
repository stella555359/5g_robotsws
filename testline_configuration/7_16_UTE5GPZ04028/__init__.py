__maintainer__ = "Piotr Paw³owski"
__team__ = "MN RAN Pz DCM WRO 3"
__email__ = "piotr.2.pawlowski@nokia.com"

from taf.config.testline.legacy import UTE_DCM

__all__ = ["tl"]

tl = UTE_DCM(
    ute_control_pc_host="10.42.75.201",
    gnb_control_pc_host=["10.42.75.201"],
    oam_airframe_l3sim_host="10.42.75.201",
    enb_lcp_list=[0],
    enb_lsp_list=[],
    enb_fan_list=[],
    enb_lbr_list=[],
    enb_lni_list=[],
    enb_lps_list=[0],
    gnb_pdu_ip=["10.42.61.105"],
    gnb_pdu_outlet=[8],
    gnb_id_list=[1],
    gnb_card_slot=[[1, 2]],
    gnb_fh_connect=[[1]],
    gnb_fh_bitrate=[[25, 25]],
)

tl._set_attr("ltesim_pc_host", "10.42.75.201")

tl._set_attr("af_type", "AF")
tl._set_attr("af_bmc_ip", "10.44.196.75")
tl._set_attr("af_bmc_username", "admin")
tl._set_attr("af_bmc_passwd", "admin")

tl._set_attr("enable_af_ssh_reset_WA", "no")
tl._set_attr("debug_run", "True")

tl._set_attr("gnb_logic_group", [[1]])
tl._set_attr("BTSID", "1")
tl._set_attr("mrbts_id", "1")

tl._set_attr("specific_convert_mmt_dir", "/cygdrive/c/ute/MMT")

tl._set_attr("oran_sim_pc_host", ["10.42.75.201", "10.42.75.201"])
tl._set_attr("oran_sim_version", ["v2.0.19", "v2.0.19"])
tl._set_attr("oran_sim_container_id", ["docker2", "docker3", "docker4", "docker5", "docker6", "docker7"])
tl._set_attr("oran_sim_container_serial_numbers", ["S000001", "S000002", "S000003", "S000004", "S000005", "S000006"])
tl._set_attr("oran_sim_pc_port", ["eth2", "eth3", "eth4", "eth5", "eth6", "eth7"])
tl._set_attr("oran_sim_path", ["/home/ute/ute_oran_sim"])
tl._set_attr("oran_sim_container_path", ["/etc/orusim"])

tl._set_attr("gnb_scard_name", "ASIL")
tl._set_attr("gnb_bcard_name", "ABIO")

tl._set_attr("gnb_radio_info", {tl.gnb_id_list[0]: {"O-RU Sim": {"1": 1, "2": 2, "3": 3, "4": 4}}})

tl._set_attr("gnb_control_pc_user", "ute")
tl._set_attr("gnb_control_pc_pwd", "ute")
tl._set_attr("ue_control_pc_user", "ute")
tl._set_attr("ue_control_pc_pwd", "ute")
tl._set_attr("windows_control_pc_user", "ute")
tl._set_attr("windows_control_pc_pwd", "ute")

tl._set_attr("dhcp_ip", "10.42.75.114")
tl._set_attr("dhcp_user", "root")
tl._set_attr("dhcp_pwd", "uteadmin")

tl._set_attr('oam_airframe_mmt_host_user', 'labadmin')
tl._set_attr('oam_airframe_mmt_host_password', 'uteadmin')
tl._set_attr('dm_enable', 'True')
tl._set_attr("hwy_type", "10g")
tl._set_attr('tl_type', 'airframe')
tl._set_attr("oru_to_gnb_fh_interface", ["docker2", "docker3", "docker4", "docker5", "docker6", "docker7"])
tl._set_attr("oru_from_gnb_fh_interface","1/0")
tl._set_attr("oru_sim_pc_user","ute")
tl._set_attr("oru_sim_pc_password","ute")
tl._set_attr("oru_sim_pc_host", ["10.42.75.201"])
tl._set_attr("tps_vpls_list", ["3101", "3102", "3103", "3104"])
tl._set_attr("tps_vpls_card", "t24ps2")
tl._set_attr("tps_vpls_slot", "1/4")


tl._set_attr('oam_http_addr', '192.168.255.129')
tl._set_attr('oam_http_port', '443')
tl._set_attr('oam_http_username', 'Nemuadmin')
tl._set_attr('oam_http_password', 'nemuuser')

tl._set_attr('lmp_connection_addr', '192.168.255.129')
tl._set_attr('lmp_connection_username', 'toor4nsn')
tl._set_attr('lmp_connection_pass', 'oZPS0POrRieRtu')

tl._set_attr('debug_run', 'True')
tl._set_attr('dm_enable', 'True')
tl._set_attr("hwy_type", "10g")
tl._set_attr('tl_type', 'airframe')
