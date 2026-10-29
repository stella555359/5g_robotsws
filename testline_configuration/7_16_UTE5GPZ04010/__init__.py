__maintainer__ = "Mariusz Kozlowski"
__team__ = "MN RAN K3"
__email__ = "mariusz.kozlowski@nokia.com"

from taf.config.testline.legacy import UTE_DCM
__all__ = ["tl"]

tl = UTE_DCM(ute_control_pc_host='10.42.75.11',
             gnb_control_pc_host=['10.42.75.11'],
             oam_airframe_l3sim_host='10.42.75.11',
             oam_airframe_mmt_host='10.42.75.29',
             oam_airframe_mmt_dct0='2',
             enb_control_pc_user='plwrranpzk3',
             enb_control_pc_password='p_5PvX7#a3jz',
             enb_lcp_list=[0],
             enb_lsp_list=[],
             enb_fan_list=[],
             enb_lbr_list=[],
             enb_lni_list=[],
             enb_lps_list=[0],
             gnb_pdu_type='aten',
             gnb_pdu_ip=['10.42.61.202'],
             gnb_pdu_outlet=[1],  # Bank A 1-6, Bank B 7-12
             gnb_id_list=[1],
             gnb_card_slot=[[1, 2]],
             gnb_fh_connect=[[1]],
             gnb_fh_bitrate=[[25]],
             )

tl._set_attr('ltesim_pc_host', '10.42.75.58')

tl._set_attr('af_type', 'AFRM')
tl._set_attr('af_bmc_ip', '10.42.208.106')
tl._set_attr('af_bmc_bridge_ip', '10.42.75.11')
tl._set_attr('af_bmc_username', 'admin')
tl._set_attr('af_bmc_passwd', 'admin')
tl._set_attr('ne3s_alarm_white_list', ['61029', '7115', '7107', '7116', '61050', '7220', '7100'])

tl._set_attr('enable_af_ssh_reset_WA', 'yes')

tl._set_attr("ue_control_pc_user", "ute")
tl._set_attr("ue_control_pc_pwd", "ute")

tl._set_attr('oam_airframe_mmt_host_user', 'plwrranpzk3')
tl._set_attr('oam_airframe_mmt_host_password', 'p_5PvX7#a3jz')

tl._set_attr('gnb_logic_group', [[1]])

tl._set_attr("oran_sim_pc_host", ["10.42.75.11"])
tl._set_attr("oran_sim_version", ["UE_APP-OAM-0.1908"])

tl._set_attr("oran_sim_container_id", ["ute_oran_sim"])
tl._set_attr("oran_sim_pc_port", ["eth4"])
tl._set_attr("oran_sim_path", ["/home/ute/ute_oran_sim"])
tl._set_attr("oran_sim_container_path", ["/etc/orusim/"])

tl._set_attr('gnb_scard_name', 'ASIL')
tl._set_attr('gnb_bcard_name', 'ABIO')

tl._set_attr('oam_airframe_mediator_host', '10.42.75.47')  # MEDIATOR HOST OS
tl._set_attr('oam_airframe_mediator_user', 'root')
tl._set_attr('oam_airframe_mediator_pwd', 'uteadmin')

tl._set_attr('oam_airframe_mediator_guest', '192.168.129.3')  # MEDIATOR guest OS
tl._set_attr('oam_airframe_mediator_guest_user', 'toor4nsn')
tl._set_attr('oam_airframe_mediator_guest_pwd', 'oZPS0POrRieRtu')

tl._set_attr('oam_airframe_mediator_interface', 'ens4f0')  # dcmnet
tl._set_attr('oam_airframe_mediator_sudo_pwd', 'uteadmin')

tl._set_attr('gnb_control_pc_user', 'ute')
tl._set_attr('gnb_control_pc_pwd', 'ute')

tl._set_attr("mrbts_id", "1")

tl._set_attr('gnb_radio_info',
             {
                 tl.gnb_id_list[0]:
                     {
                         'O-RU Sim':
                             {
                                 '1': 1,
                             }
                     }
             })
