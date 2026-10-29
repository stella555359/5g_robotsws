__maintainer__ = "Anna Miklis"
__team__ = "MN RAN K3"
__email__ = "anna.miklis@nokia.com"

from taf.config.testline.legacy import UTE_DCM
__all__ = ["tl"]

tl = UTE_DCM(ute_control_pc_host='10.42.221.242',
             gnb_control_pc_host=['10.42.221.242'],
             oam_airframe_l3sim_host='10.42.221.242',
             oam_airframe_mmt_host='10.42.221.243',
             oam_airframe_mmt_dct0='2',
             enb_control_pc_user='labadmin',
             enb_control_pc_password='uteadmin',
             enb_lcp_list=[0],
             enb_lsp_list=[],
             enb_fan_list=[],
             enb_lbr_list=[],
             enb_lni_list=[],
             enb_lps_list=[0],
             gnb_pdu_type='aten',
             gnb_pdu_ip=['10.44.177.183'],
             gnb_pdu_outlet=[9],  # Bank A 1-6, Bank B 7-12
             gnb_id_list=[1],
             gnb_card_slot=[[1, 2]],
             gnb_fh_connect=[[1]],
             gnb_fh_bitrate=[[25]],
             )

tl._set_attr('ltesim_pc_host', '10.42.221.242')

tl._set_attr('mrbts_id', '1')

tl._set_attr('af_type', 'AFRM')
tl._set_attr('af_bmc_ip', '10.42.210.169')
tl._set_attr('af_bmc_bridge_ip', '10.42.221.242')
tl._set_attr('af_bmc_username', 'admin')
tl._set_attr('af_bmc_passwd', 'admin')
tl._set_attr('ne3s_alarm_white_list', ['61029', '7115', '7107', '7116', '61050', '7220', '7100'])

tl._set_attr('enable_af_ssh_reset_WA', 'yes')

tl._set_attr("ue_control_pc_user", "ute")
tl._set_attr("ue_control_pc_pwd", "ute")

tl._set_attr('oam_airframe_mmt_host_user', 'labadmin')
tl._set_attr('oam_airframe_mmt_host_password', 'uteadmin')

tl._set_attr('gnb_logic_group', [[1]])

# tl._set_attr("oran_sim_pc_host", ["10.42.221.242"])
# tl._set_attr("oran_sim_version", ["v2.1.20"])
#
# tl._set_attr("oran_sim_container_id", ["ute_oran_sim"])
# tl._set_attr("oran_sim_pc_port", ["eth4"])
# tl._set_attr("oran_sim_path", ["/home/ute/ute_oran_sim"])
# tl._set_attr("oran_sim_container_path", ["/etc/orusim/"])

# tl._set_attr('specific_convert_mmt_dir', '/cygdrive/c/ute/MMT') kasu kasu

tl._set_attr('gnb_scard_name', 'ASIL')
tl._set_attr('gnb_bcard_name', 'ABIO')

tl._set_attr('oam_airframe_mediator_host', '10.42.221.202')  # MEDIATOR HOST OS
tl._set_attr('oam_airframe_mediator_user', 'root')
tl._set_attr('oam_airframe_mediator_pwd', 'uteadmin')

tl._set_attr('oam_airframe_mediator_guest', '192.168.129.3')  # MEDIATOR guest OS
tl._set_attr('oam_airframe_mediator_guest_user', 'root')
tl._set_attr('oam_airframe_mediator_guest_pwd', 'uteadmin')

tl._set_attr('oam_airframe_mediator_interface', 'ens43f0')  # dcmnet
tl._set_attr('oam_airframe_mediator_sudo_pwd', 'uteadmin')

# tl._set_attr('ne3s_af_switch_type', 'NO SWITCH')
# tl._set_attr('ne3s_gnb_switch_type', 'NO SWITCH')

tl._set_attr('gnb_control_pc_user', 'ute')
tl._set_attr('gnb_control_pc_pwd', 'ute')

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
tl._set_attr('oam_http_addr', '192.168.255.129')
tl._set_attr('oam_http_port', '443')
tl._set_attr('oam_http_username', 'Nemuadmin')
tl._set_attr('oam_http_password', 'nemuuser')

tl._set_attr('lmp_connection_addr', '192.168.255.129')
tl._set_attr('lmp_connection_username', 'toor4nsn')
tl._set_attr('lmp_connection_pass', 'oZPS0POrRieRtu')


tl._set_attr('iug_ip_addr', '10.42.221.92')
tl._set_attr('iug_connection_username', 'admin')
tl._set_attr('iug_connection_pass', 'admin1234')

tl._set_attr('hdbde_vm_ip_addr', '10.42.75.198')
tl._set_attr('hdbde_vm_connection_username', 'labadmin')
tl._set_attr('hdbde_vm_connection_pass', 'uteadmin')

tl._set_attr('hdbde_x2_ip_addr', '10.42.221.252')
tl._set_attr('hdbde_x2_connection_username', 'ute')
tl._set_attr('hdbde_x2_connection_pass', 'ute')

tl._set_attr('pdu_iug_ip_addr', '10.44.177.183')
tl._set_attr('pdu_iug_model', 'EPC')
tl._set_attr('pdu_iug_port', '7')

tl._set_attr('ru_info', [
    {'id': 1, 'RMOD_R': 1, 'cell_id': [1], 'bbmod_port': 1, 'iug_port': 1, 'iug': 'yes', 'fhm': 'yes',
     'hdbde_cell': {'exist': 'yes', 'cell_id': 1}}])

tl._set_attr('bbmod_info',[{'id': 1, 'BBMOD_R': 3}, {'id': 2, 'BBMOD_R': 2}, {'id': 3, 'BBMOD_R': 1}])

tl._set_attr("mediator_uec_port", "10000")
tl._set_attr("mediator_edaemon_port", "10010")
tl._set_attr("mediator_l3_sim_port", "10020")
tl._set_attr("mediator_egate_port", "20000")
