__maintainer__ = "Wojciech Lika"
__team__ = "MN RAN DCM Vrf WRO 2 SG"
__email__ = "wojciech.lika@nokia.com"

from taf.config.testline.legacy import UTE_DCM
from taf.config.testline.ue import Prisma
from taf.config.testline.connection_details import SshServiceDetails,HttpConnectionDetails

__all__ = ["tl"]

tl = UTE_DCM(
    ute_control_pc_host="10.42.75.111",
    gnb_control_pc_host=["10.42.75.111"],
    oam_airframe_l3sim_host="10.42.75.111",
    oam_airframe_mmt_host="10.42.75.223",
    oam_airframe_mmt_dct0="2",
    enb_control_pc_user="labadmin",
    enb_control_pc_password="uteadmin",
    enb_lcp_list=[0],
    enb_lsp_list=[],
    enb_fan_list=[],
    enb_lbr_list=[],
    enb_lni_list=[],
    enb_lps_list=[0],
    # gnb_pdu_type="gude",
    # gnb_pdu_ip=["10.42.61.152"],
    # gnb_pdu_outlet=[5],
    # gnb_id_list=[50011],
    gnb_id_list=[1],
    gnb_card_slot=[[1]],
    gnb_fh_connect=[[1]],
    gnb_fh_bitrate=[[25]],
)


tl._set_attr("gnb_logic_group", [[1]])

tl._set_attr("specific_convert_mmt_dir", "/cygdrive/c/ute/MMT")

tl._set_attr("gnb_scard_name", "ASIL")
tl._set_attr("gnb_bcard_name", "ABIO")

tl._set_attr("gnb_control_pc_user", "ute")
tl._set_attr("gnb_control_pc_pwd", "ute")
tl._set_attr("ue_control_pc_user", "ute")
tl._set_attr("ue_control_pc_pwd", "ute")
tl._set_attr("windows_control_pc_user", "ute")
tl._set_attr("windows_control_pc_pwd", "ute")

tl._set_attr("oam_airframe_mmt_host_user", "labadmin")
tl._set_attr("oam_airframe_mmt_host_password", "uteadmin")

tl._set_attr("mrbts_id", "50011")
tl._set_attr('keysight_host', '10.42.221.148')
tl._set_attr('keysight_user', 'user')
tl._set_attr('keysight_pwd', 'user')

tl._set_attr('oam_http_addr', '192.168.255.129')
tl._set_attr('oam_http_port', '443')
tl._set_attr('oam_http_username', 'Nemuadmin')
tl._set_attr('oam_http_password', 'nemuuser')

tl._set_attr('lmp_connection_addr', '192.168.255.129')
tl._set_attr('lmp_connection_username', 'toor4nsn')
tl._set_attr('lmp_connection_pass', 'oZPS0POrRieRtu')
tl._set_attr('mplane_addr', '10.44.77.211')

tl._set_attr('keysight_host', '10.42.221.148')

tl._set_attr('ks_ctrl_pc', '10.42.75.223')

_keysight = Prisma(
    airmosaic_ssh_connection_details=SshServiceDetails(addr='10.42.75.111', username='ute', password='ute'),
    airmosaic_harness_connection_details=HttpConnectionDetails(addr='localhost', port=8090),
    lsu_uu_ssh_connection_details=SshServiceDetails(addr='10.42.221.148', username='user', password='user'),
    tstm_uu_ssh_connection_details=SshServiceDetails(addr='10.42.221.148', username='user', password='user'),
    )

tl._set_attr('ues', [_keysight])
