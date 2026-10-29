__maintainer__ = "Urszula Plocienniczak"
__team__ = "MN RAN RD CIS CWO DCM Vrf WRO 2"
__email__ = "urszula.plocienniczak@nokia.com"

from taf.config.testline.legacy import UTE_DCM
from taf.config.testline.ue import Android
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import JFW
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
    HttpConnectionDetails,
)
from taf.config.testline import (
    NetworkAddress,
    RoutingInformation,
    TafUeDataTransferProtocol,
)

__all__ = ["tl"]

_attenuator = JFW(ip_addr="10.42.54.223",
                  port=3001,
                  attenuation_port_numbers=range(1, 25),
                  model="TAS_16T16_0_2G6_90_1S_DEJS"
                  )

# taf_ue prep:
_app_server = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server, interval=1, version=2
)

_nokia_83_1 = TafUeAndroid(
    serial_number="HZQN1876BAK92100554",
    capabilities=["REAL_ANDROID_UE", "Qualcomm"],
    ue_pc_address="10.42.224.5",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.5", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    qualcomm_prototype=True,
    service_call_attach="16",
    service_call_detach="16",
)


tl = UTE_DCM(enb_type='lrc',
             enb_pdu_ip='10.44.177.168',
             enb_pdu_outlet=7,
             epc_host='10.42.75.224',
             l3sim_host='10.42.75.224',
             secgw_host='10.42.75.224',
             enb_lcp_list=[0],
             enb_lsp_list=[0],
             enb_fan_list=[],
             enb_lbr_list=[0],
             enb_lps_list=[0, 1, 2],
             enb_lni_list=[0],
             enb_lca=1,
             enb_lbi=1,
             dct_host='10.42.75.21',
             enb_cpri_links=[1, 4, 14, 17, 27, 30, 7, 8, 9, 2],
             ute_control_pc_host='10.42.75.224',
             gnb_control_pc_host=['10.42.75.224'],
             oam_airframe_l3sim_host='10.42.75.224',
             gnb_pdu_ip=['10.44.177.166'],
             gnb_pdu_outlet=[8],
             gnb_id_list=[1],
             gnb_card_slot=[[1, 2]],
             gnb_fh_connect=[[1]],
             gnb_fh_bitrate=[[25, 25]]
             )

tl._set_attr('ltesim_pc_host', '10.42.75.224')
tl._set_attr('gnb_ru_pdu_type', 'EPC')
tl._set_attr('gnb_pdu_ip', '10.44.177.166')
tl._set_attr('mrbts_id', '1')

tl._set_attr('gnb_pdu_outlet', '8')

tl._set_attr('gnb_fh_radio_type', 'cmW')

tl._set_attr('af_type', 'AF')
tl._set_attr('af_bmc_ip', '10.42.210.92')
tl._set_attr('af_bmc_username', 'admin')
tl._set_attr('af_bmc_passwd', 'admin')

tl._set_attr('enable_af_ssh_reset_WA', 'no')

tl._set_attr('gnb_logic_group', [[1]])

tl._set_attr('specific_convert_mmt_dir', '/cygdrive/c/ute/MMT')

tl._set_attr('gnb_ru_pdu_ip', ['10.44.177.173', '10.44.177.172'])
tl._set_attr('gnb_ru_pdu_outlet', [6, 8])

tl._set_attr('gnb_scard_name', 'ASIL')
tl._set_attr('ue_ip', '3.7.11.1')

_iperf_data_transfer = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(addr="10.42.61.65", username="5g", password="2019H@slo"),
    network_interface_address='10.42.197.170',
    iperf_path="/data/data/com.nokia.android.application/iperf",
    port=59998
    )

_nuc_ue_pc_ssh = SshServiceDetails(addr="10.42.224.5", username="plwrranpzk3", password="p_5PvX7#a3jz")

_qualcomm = Android(
    ssh_connection_details=_nuc_ue_pc_ssh,
    serial_number='HZQN1876BAK92100554',
    server_dir='/cygdrive/c/pyro_server',
    python_path='C:/Python27/python.exe',
    qcat_path='C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe',
    diag_cfg_path='C:/pyro_server/DIAG.cfg',
    iperf_details=_iperf_data_transfer,
    capabilities=['REAL_ANDROID_UE', 'Qualcomm'],
    sec_key='00112233445566778899AABBCCDDEEFF',
    imsi='440:10:0100000002'
    )

tl._set_attr('ues', [_qualcomm, _nokia_83_1])
tl._set_attr('core', None)

gnb_pdu_idx_list = filter(lambda pdu_idx: (tl.gnb_pdu_outlet[pdu_idx] != -1),
                                         range(len(tl.gnb_pdu_outlet)))

gnb_pdu_idx_list = [item+1 for item in gnb_pdu_idx_list]
tl._set_attr('gnb_id_list', gnb_pdu_idx_list)
tl._set_attr("enb_control_pc_host", "10.42.75.21")

tl._set_attr("enb_control_pc_user", "labadmin")
tl._set_attr("enb_control_pc_password", "uteadmin")

tl._set_attr("gnb_radio_info", {tl.gnb_id_list[0]: {"AZQI": {"1": 1, "2": 1}}})

tl._set_attr("gnb_control_pc_user", "ute")
tl._set_attr("gnb_control_pc_pwd", "ute")
tl._set_attr("ue_control_pc_user", "ute")
tl._set_attr("ue_control_pc_pwd", "ute")
tl._set_attr("windows_control_pc_user", "ute")
tl._set_attr("windows_control_pc_pwd", "ute")

tl._set_attr('oam_airframe_mmt_host_user', 'labadmin')
tl._set_attr('oam_airframe_mmt_host_password', 'uteadmin')

tl._set_attr('nrcell_nam_host', '10.42.54.223')
tl._set_attr('nrcell1_nam_port', '1,2,3,4')
tl._set_attr('nrcell_nam_host_2', '10.42.54.223')
tl._set_attr('nrcell2_nam_port', '5,6,7,8')
tl._set_attr('nrcell1_nam_port_condacted', '13,14,15,16')
tl._set_attr('nrcell_nam_port_lte', '9,10')
tl._set_attr('eNB_mplane', '172.16.11.1')
tl._set_attr('attenuator_port_telnet', '3001')

tl._set_attr('attenuator', _attenuator)
tl._set_attr('optical_switch_ip', '10.42.61.43')

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
tl._set_attr('mplane_addr', '172.16.11.200')
