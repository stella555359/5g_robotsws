__maintainer__ = "Artem Azamatow"
__team__ = "DCM WRO 3"
__email__ = "artem.azamatow@nokia.com"
__all__ = ["tl"]
from taf.config.testline.legacy import UTE_DCM
tl = UTE_DCM(ute_control_pc_host='10.42.75.124',
             gnb_control_pc_host=['10.42.75.124'],
             oam_airframe_l3sim_host='10.42.75.124',
             oam_airframe_mmt_host='10.42.75.128',
             oam_airframe_mmt_dct0='2',
             enb_lcp_list=[0],
             enb_fan_list=[],
             enb_lbr_list=[],
             enb_lni_list=[],
             enb_lps_list=[0],
             gnb_pdu_ip=['10.44.177.168'],
             gnb_pdu_outlet=[3],
             gnb_id_list=[1],
             gnb_card_slot=[[1,2,3]],
             gnb_fh_connect=[[1]],
             gnb_fh_bitrate=[[25,25]]
)

tl._set_attr('ltesim_pc_host', '10.42.75.126')
tl._set_attr('guest_OS_IP', '192.168.129.3')
tl._set_attr('host_guest_OS_Username', 'root')
tl._set_attr('host_guest_OS_Password', 'uteadmin')
tl._set_attr('host_OS_IP', '10.42.75.130')

tl._set_attr('ne3s_alarm_white_list',['61029', '7115', '7107', '7116', '7220', '7100'])
tl._set_attr('ne3s_alarm_grey_list',['7222'])
tl._set_attr('tl_type', 'airframe')
tl._set_attr('oru_sim_pc_host', ['10.42.75.124'])
tl._set_attr('oru_to_gnb_fh_interface', 'docker1')
tl._set_attr('oru_sim_pc_user', 'ute')
tl._set_attr('oru_sim_pc_password', 'ute')
tl._set_attr('BTSID', '1')


tl._set_attr('af_type', 'AF')
tl._set_attr('af_bmc_ip', '10.42.208.83')
tl._set_attr('af_bmc_username', 'admin')
tl._set_attr('af_bmc_passwd', 'admin')
tl._set_attr('AF_hostOS_host','10.42.75.130')

tl._set_attr('secgw2_user', 'root')
tl._set_attr('secgw2_password', 'uteadmin')
tl._set_attr('secgw2_host', '10.42.75.199')
tl._set_attr('secgw2_user', 'root')
tl._set_attr('secgw2_password', 'uteadmin')
tl._set_attr('dcm_control_pc_user', 'labadmin')
tl._set_attr('dcm_control_pc_password', 'uteadmin')
tl._set_attr('dct_pc_user', 'labadmin')
tl._set_attr('dct_pc_password', 'uteadmin')
tl._set_attr('oam_airframe_mmt_user', 'labadmin')
tl._set_attr('oam_airframe_mmt_password', 'uteadmin')
tl._set_attr('oam_airframe_l3sim_user', 'ute')
tl._set_attr('oam_airframe_l3sim_password', 'ute')
tl._set_attr('secgw2_to_af_interface','eth3')
tl._set_attr('secgw2_to_uec_interface','eth1')
tl._set_attr('secgw2_to_gnb_interface','eth1')
tl._set_attr('secgw2_to_epc_interface','eth1')


tl._set_attr('enb_control_pc_user','labadmin')
tl._set_attr('enb_control_pc_password','uteadmin')

tl._set_attr('oam_airframe_mmt_host_user', 'labadmin')
tl._set_attr('oam_airframe_mmt_host_password', 'uteadmin')

tl._set_attr('enable_af_ssh_reset_WA', 'no')

tl._set_attr('gnb_logic_group', [[1]])

tl._set_attr('specific_convert_mmt_dir', '/cygdrive/c/ute/MMT')

tl._set_attr('oran_sim_pc_host', ['10.42.75.124'])
tl._set_attr('oran_sim_container_id', ['ute_oran_sim1'])
tl._set_attr('oran_sim_version', ['v2.1.25'])
tl._set_attr('oran_sim_pc_port',['eth4'])

tl._set_attr('gnb_scard_name', 'ASIL')
tl._set_attr('gnb_bcard_name', 'ABIO')
tl._set_attr('debug_run','True')
tl._set_attr('dm_enable','True')
tl._set_attr('hwy_type','10g')
tl._set_attr('gnb_control_pc_pwd','ute')
tl._set_attr('gnb_control_pc_user','ute')
tl._set_attr('ru_type_list',['O-RU','O-RU','O-RU','O-RU','O-RU','O-RU','O-RU','O-RU'])
tl._set_attr('gnb_radio_info',
             {
                 tl.gnb_id_list[0]:
                     {
                         'O-RU Sim':
                             {
                                 '1': 1
                             }
                     }
             })
