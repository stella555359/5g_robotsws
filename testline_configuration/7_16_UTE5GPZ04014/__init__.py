__maintainer__ = "Krzysztof Matuszewski"
__team__ = "MN RAN K3"
__email__ = "krzysztof.matuszewski@nokia.com"

from taf.config.testline.legacy import UTE_DCM
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.ue import Android
from taf.config.testline.connection_details import SshServiceDetails

__all__ = ["tl"]

tl = UTE_DCM(enb_type='lrc',
             enb_pdu_ip='10.44.177.170',
             enb_pdu_outlet=2,
             epc_host='10.42.75.62',
             l3sim_host='10.42.75.62',
             secgw_host='10.42.75.62',
             enb_lcp_list=[0, 1],
             enb_lsp_list=[0, 1, 2, 3, 10, 11],
             enb_fan_list=[],
             enb_lbr_list=[0, 1, 2],
             enb_lps_list=[0, 1, 2, 3, 4, 5],
             enb_lni_list=[0, 1],
             enb_lca=1,
             enb_lbi=1,
             dct_host='10.42.224.6',
             enb_cpri_links=[1, 4, 14, 17, 27, 30, 7, 8, 9, 2],
             ute_control_pc_host='10.42.75.15',
             gnb_control_pc_host=['10.42.75.15'],
             oam_airframe_l3sim_host='10.42.75.15',
             gnb_pdu_ip=['10.44.177.166'],
             gnb_pdu_outlet=[7],
             gnb_id_list=[1],
             gnb_card_slot=[[1, 2, 3]],
             gnb_fh_connect=[[1]],
             gnb_fh_bitrate=[[25, 25]]
)

tl._set_attr('ltesim_pc_host', '10.42.75.15')
tl._set_attr('gnb_ru_pdu_type', 'EPC')

tl._set_attr('gnb_pdu_ip', '10.44.177.166')

tl._set_attr('gnb_pdu_outlet', '7')

tl._set_attr('gnb_fh_radio_type', 'cmW')

tl._set_attr('af_type', 'AF')
tl._set_attr('af_bmc_ip', '10.42.208.87')
tl._set_attr('af_bmc_username', 'admin')
tl._set_attr('af_bmc_passwd', 'admin')

tl._set_attr('enable_af_ssh_reset_WA', 'no')

tl._set_attr('gnb_logic_group', [[1]])

tl._set_attr('specific_convert_mmt_dir', '/cygdrive/c/ute/MMT')

tl._set_attr('gnb_ru_pdu_ip', ['10.44.177.172', '10.44.177.173'])
tl._set_attr('gnb_ru_pdu_outlet', [10, 6])

tl._set_attr('gnb_scard_name', 'ASIL')
tl._set_attr('gnb_bcard_name', 'ABIO')

_iperf_data_transfer = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(addr="10.42.61.65", username="5g", password="2019H@slo"),
    network_interface_address='10.42.197.170',
    iperf_path="/data/data/com.nokia.android.application/",
    port=59998
    )

_nuc_ue_pc_ssh = SshServiceDetails("10.42.224.6", username="plwrranpzk3", password="p_5PvX7#a3jz")

_qualcomm = Android(
    ssh_connection_details=_nuc_ue_pc_ssh,
    serial_number='HZQN1876AAKA2001490',
    server_dir='/cygdrive/c/pyro_server',
    python_path='C:/Python27/python.exe',
    qcat_path='C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe',
    diag_cfg_path='C:/pyro_server/DIAG.cfg',
    iperf_details=_iperf_data_transfer,
    capabilities=['REAL_ANDROID_UE','Qualcomm'],
    sec_key='00112233445566778899AABBCCDDEEFF',
    imsi='440:10:0100000001'
    )

tl._set_attr('ues', [_qualcomm])
# tl._set_attr('ues', [_hwmate30])
tl._set_attr('core', None)

gnb_pdu_idx_list = filter(lambda pdu_idx: (tl.gnb_pdu_outlet[pdu_idx] != -1),
                                         range(len(tl.gnb_pdu_outlet)))

gnb_pdu_idx_list = [item+1 for item in gnb_pdu_idx_list]
tl._set_attr('gnb_id_list', gnb_pdu_idx_list)
tl._set_attr("enb_control_pc_host", "10.42.224.6")
tl._set_attr("gnb_control_pc_user", "ute")
tl._set_attr("gnb_control_pc_pwd", "ute")
tl._set_attr("ue_control_pc_user", "ute")
tl._set_attr("ue_control_pc_pwd", "ute")
tl._set_attr("windows_control_pc_user", "ute")
tl._set_attr("windows_control_pc_pwd", "ute")

tl._set_attr('oam_airframe_mmt_host_user', 'labadmin')
tl._set_attr('oam_airframe_mmt_host_password', 'uteadmin')


tl._set_attr('nrcell_nam_host', '10.42.75.72')
tl._set_attr('nrcell1_nam_port', '1,2,3,4')
tl._set_attr('nrcell2_nam_port', '5,6,7,8')

tl._set_attr('dcm_dct_tshark_monitor3', '1')
