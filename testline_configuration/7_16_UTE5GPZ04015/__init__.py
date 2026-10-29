__maintainer__ = "Dalia Cygan"
__team__ = "MN RAN K3"
__email__ = "dalia.cygan@nokia.com"

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
             epc_host='10.42.75.16',
             l3sim_host='10.42.75.16',
             secgw_host='10.42.75.16',
             dct_host='10.42.75.16',
             ute_control_pc_host='10.42.75.16',
             gnb_control_pc_host=['10.42.75.16'],
             oam_airframe_l3sim_host='10.42.75.16',
             gnb_pdu_ip=['10.44.177.167'],
             gnb_pdu_outlet=[1],
             gnb_id_list=[1],
             gnb_card_slot=[[1, 2]],
             gnb_fh_connect=[[1]],
             gnb_fh_bitrate=[[25, 25]]
             )

tl._set_attr('ltesim_pc_host', '10.42.75.16')
tl._set_attr('gnb_ru_pdu_type', 'EPC')
tl._set_attr('gnb_pdu_ip', '10.44.177.167')
tl._set_attr('mrbts_id', '1')

tl._set_attr('gnb_pdu_outlet', '1')

tl._set_attr('gnb_fh_radio_type', 'cmW')

tl._set_attr('af_type', 'AF')
tl._set_attr('af_bmc_ip', '10.42.210.90')
tl._set_attr('af_bmc_username', 'admin')
tl._set_attr('af_bmc_passwd', 'admin')

tl._set_attr('enable_af_ssh_reset_WA', 'no')

tl._set_attr('gnb_logic_group', [[1]])

tl._set_attr('specific_convert_mmt_dir', '/cygdrive/c/ute/MMT')

tl._set_attr('gnb_scard_name', 'ASIL')
tl._set_attr('ue_ip', '3.7.11.1')

#_iperf_data_transfer = IperfDataTransferDetails(
#    ssh_connection_details=SshServiceDetails(addr="10.42.61.65", username="5g", password="2019H@slo"),
#    network_interface_address='10.42.197.170',
#    iperf_path="/data/data/com.nokia.android.application/iperf",
#    port=59998
#    )


tl._set_attr('core', None)

gnb_pdu_idx_list = filter(lambda pdu_idx: (tl.gnb_pdu_outlet[pdu_idx] != -1),
                                         range(len(tl.gnb_pdu_outlet)))

gnb_pdu_idx_list = [item+1 for item in gnb_pdu_idx_list]
tl._set_attr('gnb_id_list', gnb_pdu_idx_list)
tl._set_attr("enb_control_pc_host", "10.42.75.16")

tl._set_attr("enb_control_pc_user", "labadmin")
tl._set_attr("enb_control_pc_password", "uteadmin")

tl._set_attr("gnb_control_pc_user", "ute")
tl._set_attr("gnb_control_pc_pwd", "ute")
tl._set_attr("ue_control_pc_user", "ute")
tl._set_attr("ue_control_pc_pwd", "ute")
tl._set_attr("windows_control_pc_user", "ute")
tl._set_attr("windows_control_pc_pwd", "ute")

tl._set_attr('oam_airframe_mmt_host_user', 'labadmin')
tl._set_attr('oam_airframe_mmt_host_password', 'uteadmin')

#tl._set_attr('nrcell_nam_host', '10.42.54.223')
#tl._set_attr('nrcell1_nam_port', '1,2,3,4')
#tl._set_attr('nrcell_nam_host_2', '10.42.54.223')
#tl._set_attr('nrcell2_nam_port', '5,6,7,8')
#tl._set_attr('nrcell1_nam_port_condacted', '13,14,15,16')
#tl._set_attr('nrcell_nam_port_lte', '9,10')
#tl._set_attr('eNB_mplane', '172.16.11.1')

tl._set_attr('dcm_dct_tshark_monitor3', '1')
# tl._set_attr('webem_ip_addr', '192.168.255.129')
# tl._set_attr('webem_port', '3600')

tl._set_attr('oam_http_addr', '192.168.255.129')
tl._set_attr('oam_http_port', '443')
tl._set_attr('oam_http_username', 'Nemuadmin')
tl._set_attr('oam_http_password', 'nemuuser')

tl._set_attr('lmp_connection_addr', '192.168.255.129')
tl._set_attr('lmp_connection_username', 'toor4nsn')
tl._set_attr('lmp_connection_pass', 'oZPS0POrRieRtu')
