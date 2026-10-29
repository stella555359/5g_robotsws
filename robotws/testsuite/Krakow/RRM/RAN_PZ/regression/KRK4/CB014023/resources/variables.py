import os
from taf.rfrl.utilities.robot.general import get_builtin_value
tl = get_builtin_value(param_name="tl")
ADMIN_ALIAS = 'default'
NOKIA_PASS = tl.gnbs[0].cu.oam_ssh_connection_details.password
NOKIA_LOGIN = tl.gnbs[0].cu.oam_ssh_connection_details.username
NOKIA_USERNAME = tl.gnbs[0].cu.oam_ssh_connection_details.username
GNB_IP = tl.gnbs[0].cu.backhaul_site_oam_ip
try:
    GNB2_IP = tl.gnbs[1].cu.backhaul_site_oam_ip
except IndexError:
    GNB2_IP = None
AP_IP = tl.ues[0].l1.common_units[0].lmp_connection.addr
AP_PASSWD = tl.ues[0].l1.common_units[0].lmp_connection.password
WEBEM_USERNAME = tl.gnbs[0].cu.oam_http_connection_details.username
WEBEM_PASSWORD = tl.gnbs[0].cu.oam_http_connection_details.password
TL_CLOUD_TOPOLOGY = tl.tl_cloud_topology


config_dir = os.path.join(os.path.dirname(__file__), 'configuration')
scf_RAN_sharing = os.path.join(config_dir, 'RAN_Sharing_Conf.xml')
IPHY_AWKUC = os.path.join(config_dir, 'iphy_AWKUC.xml')
wts_6_AMF = os.path.join(config_dir, 'wts_6_AMF.cfg')
ip_config = os.path.join(config_dir, 'ip.sh')

cells_to_validate_map_all_ues = {0: (52, 53, 54, 55, 56, 57, 58), 1: (52, 53, 54, 55, 56, 57, 58),
                                 2: (52, 53, 54, 55, 56, 57, 58), 3: (52, 53, 54, 55, 56, 57, 58),
                                 4: (52, 53, 54, 55, 56, 57, 58), 5: (52, 53, 54, 55, 56, 57, 58)}
cells_to_validate_map_ue_1 = {0: (52, 53, 54, 55, 56, 57, 58)}
cells_to_validate_map_ues_2_to_6 = {1: (52, 53, 54, 55, 56, 57, 58), 2: (52, 53, 54, 55, 56, 57, 58),
                                    3: (52, 53, 54, 55, 56, 57, 58), 4: (52, 53, 54, 55, 56, 57, 58),
                                    5: (52, 53, 54, 55, 56, 57, 58)}
