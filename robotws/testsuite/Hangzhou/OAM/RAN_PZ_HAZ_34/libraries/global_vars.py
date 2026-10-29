from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from testsuite.Hangzhou.OAM.RAN_PZ_HAZ_34.libraries.nms_vars import DICT__netact_global_configuration

tl = BuiltIn().get_variable_value("${tl}")
netact_ip = BuiltIn().get_variable_value("${NETACT_IP}")
gnb_type = 'classical'

du_0 = tl.gnbs[0].dus[0]
cu_def = tl.gnbs[0].cu
cu_addr = cu_def.oam_ssh_connection_details.addr
WEBUI_ADDR = cu_def.oam_http_connection_details.addr
WEBUI_USER = cu_def.oam_http_connection_details.username
WEBUI_PASSWORD = cu_def.oam_http_connection_details.password
oam_addr = cu_def.oam_ssh_connection_details.addr
oam_username = cu_def.oam_ssh_connection_details.username
oam_password = cu_def.oam_ssh_connection_details.password
if "cloud_deployment" in dir(tl.gnbs[0]) and tl.gnbs[0].cloud_deployment:
    gnb_type = 'cloud'
    logger.info("GNB type: cloud", also_console=True)
    ctrl_addr = tl.cloud_hostings[0].control_nodes[0].default_ssh_connection_details.addr
    ctrl_username = tl.cloud_hostings[0].control_nodes[0].default_ssh_connection_details.username
    ctrl_password = tl.cloud_hostings[0].control_nodes[0].default_ssh_connection_details.password
    ncir_version = tl.cloud_hostings[0].version.replace("_", "")
    asik_addr = du_0.airscale.common_units[0].lmp_connection.addr
    asik_username = du_0.airscale.common_units[0].lmp_connection.username
    asik_password = du_0.airscale.common_units[0].lmp_connection.password
else:
    if du_0.rus:
        RU_PASSWORD = du_0.rus[0].default_ssh_connection_details.password
        if du_0.rus[0].pdu_port:
            ru_powerstation_ip = du_0.rus[0].pdu_port.pdu.addr
            ru_powerstation_asik_port = du_0.rus[0].pdu_port.port_no
            ru_powerstation_model = du_0.rus[0].pdu_port.pdu.__class__.__name__
            if ru_powerstation_model == "HBTE":
                ru_powerstation_port = 5000
            else:
                ru_powerstation_port = 4001
        ru_list = du_0.rus
        rus = []
        for ru in ru_list:
            ru_info = {}
            ru_info['addr'] = ru.default_ssh_connection_details.addr
            ru_info['username'] = ru.default_ssh_connection_details.username
            ru_info['password'] = ru.default_ssh_connection_details.password
            ru_info['ru_type'] = ru.ru_hw_group
            if ru.serial_number:
                ru_info['serial_number'] = ru.serial_number
            if ru.lmp_connection:
                ru_info['ctrl_addr'] = ru.lmp_connection.addr
                ru_info['ctrl_username'] = ru.lmp_connection.username
                ru_info['ctrl_password'] = ru.lmp_connection.password
            rus.append(ru_info)

    asik_addr = cu_def.oam_ssh_connection_details.addr
    asik_username = cu_def.oam_ssh_connection_details.username
    asik_password = cu_def.oam_ssh_connection_details.password

if du_0.airscale.common_units[0].pdu_port:
    powerstation_ip = du_0.airscale.common_units[0].pdu_port.pdu.addr
    powerstation_asik_port = du_0.airscale.common_units[0].pdu_port.port_no
    powerstation_model = du_0.airscale.common_units[0].pdu_port.pdu.__class__.__name__
    if powerstation_model == "HBTE":
        powerstation_port = 5000
    else:
        powerstation_port = 4001

if tl.switches:
    switch_addr = tl.switches[0].default_ssh_connection_details.addr
    switch_port = tl.switches[0].default_ssh_connection_details.port
    switch_username = tl.switches[0].default_ssh_connection_details.username
    switch_password = tl.switches[0].default_ssh_connection_details.password

real_enb = None
if ("enbs" in dir(tl)) and tl.enbs:
    Enb_ip = tl.enbs[0].airscale.common_units[0].lmp_connection.addr
    Enb_username = tl.enbs[0].airscale.common_units[0].lmp_connection.username
    Enb_password = tl.enbs[0].airscale.common_units[0].lmp_connection.password
    real_enb = tl.enbs

if netact_ip:
    netact_nodeip = netact_ip
elif tl.nms:
    netact_nodeip = tl.nms.addr
else:
    netact_nodeip = ""
if netact_nodeip:
    if netact_nodeip in DICT__netact_global_configuration.keys():
        netact_nodeusername = DICT__netact_global_configuration[netact_nodeip]["ssh_username"]
        netact_nodepassword = DICT__netact_global_configuration[netact_nodeip]["ssh_password"]
        netact_account = DICT__netact_global_configuration[netact_nodeip]["http_username"]
        netact_pwd = DICT__netact_global_configuration[netact_nodeip]["http_password"]
        netact_url = DICT__netact_global_configuration[netact_nodeip]["url"]
        netact_name = DICT__netact_global_configuration[netact_nodeip]["name"]
if du_0.airscale.common_units[0].lmp_connection:
    LMP_ADDR = du_0.airscale.common_units[0].lmp_connection.addr
if tl.test_pc:
    TESTPC_ADDR = tl.test_pc.default_ssh_connection_details.addr
    TESTPC_user = tl.test_pc.default_ssh_connection_details.username
    TESTPC_pwd = tl.test_pc.default_ssh_connection_details.password
if tl.gnbs[0].instance_id:
    MRBTS_ID = tl.gnbs[0].instance_id
if tl.gnbs[0].global_bts_id:
    GLOBAL_BTS_ID = tl.gnbs[0].global_bts_id
