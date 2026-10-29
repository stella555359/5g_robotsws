__maintainer__ = "Paweł Cymbor"
__team__ = "MN RAN K3"
__email__ = "pawel.cymbor@nokia.com"

from taf.config.testline.legacy import UTE_DCM

__all__ = ["tl"]
tl = UTE_DCM(enb_type='lrc',
             ute_control_pc_host='10.42.75.12',
             gnb_control_pc_host=['10.42.75.12'],
             oam_airframe_l3sim_host='10.42.75.12',
             oam_airframe_mmt_host='10.42.75.30',
             oam_airframe_mmt_dct0='1',
             enb_control_pc_user='ute',
             enb_control_pc_password='ute',
             enb_lcp_list=[0],
             enb_lsp_list=[1],
             enb_fan_list=[],
             enb_lbr_list=[],
             enb_lni_list=[],
             enb_lps_list=[0],
             gnb_pdu_type='gude',
             gnb_pdu_ip=['10.44.177.167'],
             gnb_pdu_outlet=[2],
             gnb_id_list=[1],
             gnb_card_slot=[[1, 2]],
             gnb_fh_connect=[[1]],
             gnb_fh_bitrate=[[25]],
             dct_host='10.42.75.30',
             secgw_host='10.42.75.107',
             )

tl._set_attr('oam_airframe_mmt_host_user', 'labadmin')
tl._set_attr('gnb_control_pc_pwd', '10.42.75.12')
tl._set_attr('oam_airframe_mmt_host_password', 'uteadmin')
tl._set_attr('debug_run', 'True')
tl._set_attr('dm_enable', 'False')
tl._set_attr('hwy_type', '10g')
tl._set_attr('gnb_hwy_type', ['10g', '10g', '10g', '10g', '10g', '10g', '10g', '10g'])
tl._set_attr('secgw2_host', '10.42.75.107')
tl._set_attr('secgw2_user', 'root')
tl._set_attr('secgw2_password', 'uteadmin')
tl._set_attr('oam_airframe_mmt_user', 'labadmin')
tl._set_attr('oam_airframe_mmt_password', 'uteadmin')
tl._set_attr('dcm_control_pc_user', 'labadmin')
tl._set_attr('dcm_control_pc_password', 'uteadmin')
tl._set_attr('dct_pc_user', 'labadmin')
tl._set_attr('dct_pc_password', 'uteadmin')
tl._set_attr('oam_airframe_l3sim_user', 'ute')
tl._set_attr('oam_airframe_l3sim_password', 'ute')
tl._set_attr('ltesim_pc_host', '10.42.75.58')
tl._set_attr('secgw2_to_af_interface','eth1')
tl._set_attr('secgw2_to_uec_interface','eth3')
tl._set_attr('secgw2_to_gnb_interface','eth2')
tl._set_attr('secgw2_to_epc_interface','eth2')

tl._set_attr('secgw_host', '10.42.75.221')
tl._set_attr('secgw_user', 'root')
tl._set_attr('secgw_password', 'uteadmin')
tl._set_attr('secgw_config_file_path','/usr/local/etc/')
tl._set_attr('secgw_ip_config_file_path','/opt/script/')
tl._set_attr('secgw_to_epc_interface','eth1')
tl._set_attr('secgw_to_enb_interface1','eth2')
tl._set_attr('secgw_to_enb_interface2','eth3')
tl._set_attr('secgw_to_enb_interface3','eth4')
tl._set_attr('secgw_to_enb_interface4','eth5')
tl._set_attr('secgw_to_gnb_interface','eth3')
tl._set_attr('secgw_to_uec_interface','eth1')
tl._set_attr("oru_to_gnb_fh_interface", "docker0")
tl._set_attr('oru_sim_pc_host', ['10.42.75.12'])
tl._set_attr('oru_sim_pc_user', 'ute')
tl._set_attr('oru_sim_pc_password', 'ute')
tl._set_attr('ne3s_gnb_switch_port_list', '0/39')
tl._set_attr('ne3s_gnb_switch_port_eif1', '0/11')
tl._set_attr('ne3s_gnb_switch_port_eif2', '0/39')
tl._set_attr('ne3s_gnb_switch_ip', ['10.42.186.69'])
tl._set_attr('ne3s_gnb_switch_type', ['quanta'])
tl._set_attr('af_cfg_file','/opt/iphy/latest/LRC_airframe.cfg')

tl._set_attr('af_type', 'AFRM')
tl._set_attr('af_bmc_ip', '10.42.208.86')
tl._set_attr('af_bmc_bridge_ip', '10.42.75.12')
tl._set_attr('af_bmc_username', 'cdslabuser')
tl._set_attr('af_bmc_passwd', 'airframe4cds')

tl._set_attr('enable_af_ssh_reset_WA', 'yes')

tl._set_attr('gnb_logic_group', [[1]])

tl._set_attr('oran_sim_pc_host', ['10.42.75.12'])
tl._set_attr('oran_sim_version', ['v2.0.18'])

tl._set_attr('gnb_scard_name', 'ASIL')
tl._set_attr('gnb_bcard_name', 'ABIO')

tl._set_attr('oam_airframe_mediator_host', '10.42.75.48')
tl._set_attr('oam_airframe_mediator_user', 'root')
tl._set_attr('oam_airframe_mediator_pwd', 'uteadmin')
tl._set_attr('oam_airframe_mediator_interface', 'ens4f0')
tl._set_attr('oam_airframe_mediator_sudo_pwd', 'ute')
tl._set_attr('ne3s_alarm_white_list',['61029', '7115', '7107', '7116', '61050', '7220', '7100'])
tl._set_attr('ru_type_list',['O-RU','O-RU','O-RU','O-RU','O-RU','O-RU','O-RU','O-RU'])
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
