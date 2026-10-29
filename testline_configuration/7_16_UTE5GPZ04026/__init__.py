__maintainer__ = "Michal Dyrda"
__team__ = "MN RAN K3"
__email__ = "michal.dyrda@nokia.com"

from taf.config.testline.legacy import UTE_DCM

__all__ = ["tl"]

tl = UTE_DCM(ute_control_pc_host='10.42.75.177',
             gnb_control_pc_host=['10.42.75.177'],
             oam_airframe_l3sim_host='10.42.75.177',
             oam_airframe_mmt_host='10.42.75.181',
             oam_airframe_mmt_dct0='2',
             enb_lcp_list=[0],
             enb_fan_list=[],
             enb_lbr_list=[],
             enb_lni_list=[],
             enb_lps_list=[0],
             gnb_id_list=[1],
             gnb_card_slot=[[1,2,3]],
             gnb_fh_connect=[[1]],
             gnb_fh_bitrate=[[25,25]]
)

tl._set_attr('ltesim_pc_host', '10.42.75.177')
tl._set_attr('ne3s_alarm_white_list',['61029', '7115', '7107', '7116', '7220', '7100'])
tl._set_attr('ne3s_alarm_grey_list',['7222'])
tl._set_attr('tl_type', 'airframe')
tl._set_attr('oru_sim_pc_host', ['10.42.75.177'])
tl._set_attr('oru_to_gnb_fh_interface', 'docker1')
tl._set_attr('oru_sim_pc_user', 'ute')
tl._set_attr('oru_sim_pc_password', 'ute')
tl._set_attr('BTSID', '1')
tl._set_attr('af_type', 'AF')
tl._set_attr('af_bmc_ip', '10.42.210.120')
tl._set_attr('af_bmc_username', 'admin')
tl._set_attr('af_bmc_passwd', 'admin')
tl._set_attr('AF_hostOS_host','10.42.75.183')
tl._set_attr('oam_airframe_mediator_host','10.42.75.181')
tl._set_attr('oam_airframe_mediator_user','labadmin')
tl._set_attr('oam_airframe_mediator_pwd','uteadmin')
tl._set_attr('enb_control_pc_host', '10.42.75.181')
tl._set_attr('dcm_control_pc_user', 'labadmin')
tl._set_attr('dcm_control_pc_password', 'uteadmin')
tl._set_attr('dct_pc_user', 'ute')
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
tl._set_attr('oran_sim_pc_host', ['10.42.75.177'])
tl._set_attr('oran_sim_container_id', ['ute_oran_sim1'])
tl._set_attr('oran_sim_version', ['v2.1.16'])
tl._set_attr('oran_sim_pc_port',['eth4'])
tl._set_attr('gnb_scard_name', 'ASIL')
tl._set_attr('gnb_bcard_name', 'ABIO')
tl._set_attr('debug_run','True')
tl._set_attr('dm_enable','True')
tl._set_attr('hwy_type','10g')

RESETGNB = 0
RESETUE = 0
RESETIPHY = 0
RESETAP = 0
RESETFH = 1
KEEP_WTSSIM_CFG = 0


skip_airframe_log_collect = 1
skip_alarm_check = 1
skip_api_common_check = 1
skip_bts_scf_err_check = 1
skip_f1_check = 1

skip_snapshot_log_collect = 0
skip_case_log_zip = 0
skip_wtssim_teardown = 0
skip_wtssim_log_collect = 0
skip_alarm_out_of_tl_def = 0
skip_airscale_scf_recovery = 1
skip_pm_counter_enable = 0

enable_webem_gui = 0
