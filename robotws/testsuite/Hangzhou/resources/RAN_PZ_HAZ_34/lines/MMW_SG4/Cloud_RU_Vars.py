from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

tl = BuiltIn().get_variable_value("${tl}")

ALL_RU_LIST = []


for gnb_index in range(len(tl.gnbs)):
    gnb_name = "gnb_" + str(gnb_index)
    instance_id = tl.gnbs[gnb_index].instance_id
    ssh_addr = tl.gnbs[gnb_index].cu.oam_ssh_connection_details.addr
    ssh_username = tl.gnbs[gnb_index].cu.oam_ssh_connection_details.username
    ssh_password = tl.gnbs[gnb_index].cu.oam_ssh_connection_details.password
    webem_addr = tl.gnbs[gnb_index].cu.oam_http_connection_details.addr
    webem_username = tl.gnbs[gnb_index].cu.oam_http_connection_details.username
    webem_password = tl.gnbs[gnb_index].cu.oam_http_connection_details.password
    common_units = []
    ru_list = []
    for ru_index in range(len(tl.gnbs[gnb_index].dus[0].rannics[0].rus)):
        ru_details = {
            "ru_type": tl.gnbs[gnb_index].dus[0].rannics[0].rus[ru_index].ru_hw_group,
            "ru_addr": tl.gnbs[gnb_index].dus[0].rannics[0].rus[ru_index].default_ssh_connection_details.addr,
            "ru_username": tl.gnbs[gnb_index].dus[0].rannics[0].rus[ru_index].default_ssh_connection_details.username,
            "ru_password": tl.gnbs[gnb_index].dus[0].rannics[0].rus[ru_index].default_ssh_connection_details.password,
            "ru_serial": tl.gnbs[gnb_index].dus[0].rannics[0].rus[ru_index].serial_number,
            "test_pc_addr": tl.gnbs[gnb_index].dus[0].rannics[0].rus[ru_index].lmp_connection.addr,
            "test_pc_username": tl.gnbs[gnb_index].dus[0].rannics[0].rus[ru_index].lmp_connection.username,
            "test_pc_password": tl.gnbs[gnb_index].dus[0].rannics[0].rus[ru_index].lmp_connection.password,
        }
        ru_list.append(ru_details)
    ALL_RU_LIST += ru_list

print("ALL_RU_LIST:")
print(ALL_RU_LIST)
