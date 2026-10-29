__maintainer__ = "Krzysztof Kulibab"
__team__ = "MN RAN K3"
__email__ = "krzysztof.kulibab@nokia.com"

from taf.config.testline.legacy import UTE_DCM

__all__ = ["tl"]

tl = UTE_DCM(
    ute_control_pc_host='10.42.75.133'
)

#connectivity
tl._set_attr('oam_http_addr', '192.168.255.129')
tl._set_attr('oam_http_port', '443')
tl._set_attr('oam_http_username', 'Nemuadmin')
tl._set_attr('oam_http_password', 'nemuuser')
tl._set_attr('mplane_addr', '10.44.77.220')

#common
tl._set_attr('mrbts_id', '50006')
tl._set_attr('nrbts_id', '50006')

tl._set_attr('ue_pc_addr', '10.42.224.58')
tl._set_attr('ue_pc_username', 'plwrranpzk3')
tl._set_attr('ue_pc_password', 'p_5PvX7#a3jz')

tl._set_attr('lmp_connection_addr', '192.168.255.129')
tl._set_attr('lmp_connection_username', 'toor4nsn')
tl._set_attr('lmp_connection_pass', 'oZPS0POrRieRtu')

tl._set_attr('gnb_control_pc_user', 'ute')
tl._set_attr('gnb_control_pc_pwd', 'ute')

tl._set_attr('appserver_addr', '10.42.61.61')
tl._set_attr('appserver_f1_addr', '10.42.197.171')
tl._set_attr('appserver_username', 'syslab')
tl._set_attr('appserver_password', 'system')


