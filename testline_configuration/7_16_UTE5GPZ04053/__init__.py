__maintainer__ = "Przemyslaw Lawniczak"
__team__ = "MN RAN K3"
__email__ = "przemyslaw.lawniczak@nokia.com"

from taf.config.testline.legacy import UTE_DCM
from taf.config.testline.ue import Android
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
    HttpConnectionDetails,
)
__all__ = ["tl"]

tl = UTE_DCM(enb_type='lrc',
             enb_pdu_ip='0.0.0.0',
             enb_pdu_type='EPC',
             enb_pdu_outlet=7,
             iphy_pdu_ip='0.0.0.0',
             iphy_pdu_outlet=5,
             ute_control_pc_host='10.42.75.118',
             enb_control_pc_host='10.42.75.225',
             epc_host='10.42.75.119',
             l3sim_host='10.42.75.119',
             secgw_host='10.42.75.119',
             dct_host='10.42.75.225',
             enb_dct_list=[0],
             enb_lcp_list=[0],
             enb_lsp_list=[0],
             enb_lbr_list=[0],
             enb_lps_list=[0,1,2],
             enb_lni_list=[0],
             enb_cpri_links=[1],
             cpri_links_type=[0],
             enb_control_pc_mmt_dct0='2',
             gnb_pdu_ip=['10.44.177.186'],
             gnb_pdu_outlet=[1],
             gnb_pdu_type='EPC',
             gnb_control_pc_host=['10.42.75.118'],
             gnb_id_list=[1],
             gnb_card_slot=[[1,2]],
             gnb_fh_connect=[[1]],
             gnb_fh_bitrate=[[25,25]]
             )

tl._set_attr('e500_host','10.42.224.147')
tl._set_attr('cli_arguments', '/home/ute/__init__.py')
tl._set_attr('e500_shernick_pc_host','10.42.224.147')
tl._set_attr('e500_shernick_partition','1')
tl._set_attr('e500_version','5G NR - NLA 6.24.0')
tl._set_attr('dcm_dct_tshark_monitor3','2')
tl._set_attr('e500_hls_host_ip',    '192.168.10.70')
tl._set_attr('e500_asc_access_ip',  '192.168.10.9')
tl._set_attr('e500_access_ip',      '192.168.10.10')
tl._set_attr('e500_fltlcs_host_ip', ['192.168.10.100', '192.168.10.110'])
tl._set_attr('e500_fltlcs_id',
[
    '000000000000000000000000000000000000000000000000000000000000000000000400D63BD597B545BE3985938911BA994F49',
    '00000000441800000300040000600000000008400030000000000000000000000000040004A35B110D81F70BE2B211EF1EFA5803'
])
tl._set_attr('e500_asc_pc_host',    '10.42.224.147')
tl._set_attr('e500_asc_test_group', '4CC_ORAN')

tl._set_attr('e500_rc_re_connect',         [] )
tl._set_attr('e500_rc_card_list',          ['T2-RC-A6', 'ORU1-P1', 'ORU1-P2'])
tl._set_attr('e500_rc_load_context',       ['0',        '1',           '1'])

tl._set_attr('enb_radio_type_list',['AEUD'])
tl._set_attr('dcm_dct_tshark_monitor3','2')
tl._set_attr('tl_setup_type','afm')

tl._set_attr('e500_fh_ctrl_pc_host', '10.42.224.147')
tl._set_attr('e500_oran_fh_access_ip', '192.168.10.50')
tl._set_attr('e500_oran_fh_hlp_access_ip', '192.168.10.70')
tl._set_attr('e500_oran_fh_asc_test_group', '4CC_ORAN')
tl._set_attr('e500_fh_ctrl_pc_ftp_ip_address', '192.168.10.100')

tl._set_attr('egen_server', {'host_ip': '10.42.75.245',
                             'egen_path': '/home/ute/eGen/eGen_v0.2.7',
                             'egen_instance': 'egen',
                             'dl_port_pci_addr': '0000:03:00.0',
                             'ul_port_pci_addr': '0000:03:00.1',
                             'dl_used_cores': '0-4',
                             'ul_used_cores': '5-8'})

tl._set_attr("gnb_control_pc_user", "ute")
tl._set_attr("gnb_control_pc_pwd", "ute")
tl._set_attr('Shernick_login', "ute")
tl._set_attr('Shernick_password', "ute")

tl._set_attr('mrbts_id', '1')
tl._set_attr('oam_http_addr', '192.168.255.129')
tl._set_attr('mplane_addr', '192.168.255.129')
tl._set_attr('oam_http_port', '443')
tl._set_attr('oam_http_port_22', '22')
tl._set_attr('oam_http_username', 'Nemuadmin')
tl._set_attr('oam_http_password', 'nemuuser')
tl._set_attr('oam_airframe_mmt_host_user', 'labadmin')
tl._set_attr('oam_airframe_mmt_host_password', 'uteadmin')
tl._set_attr('testline_name', 'TL53')
tl._set_attr('optical_switch_ip', '10.42.54.50')

RESETLRC = 0
RESETGNB = 0
RESETUE = 0
RESETIPHY = 0
RESETAP = 0
RESETFH = 1
KEEP_WTSSIM_CFG = 1

skip_airframe_log_collect = 1
skip_api_common_check = 1
skip_bts_scf_err_check = 0
skip_f1_check = 0

skip_snapshot_log_collect = 0
skip_case_log_zip = 0
skip_wtssim_teardown = 0
skip_wtssim_log_collect = 0
skip_alarm_out_of_tl_def = 0
skip_airscale_scf_recovery = 0
skip_alarm_check = 0

enable_webem_gui = 0
