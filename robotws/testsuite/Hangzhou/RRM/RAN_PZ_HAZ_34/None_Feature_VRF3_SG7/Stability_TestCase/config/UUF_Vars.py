from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

tl = BuiltIn().get_variable_value("${tl}")
TESTLINE_IDENTITY = tl.gnbs[0].instance_id

ALL_CONFIG_INIT = {}
ALL_GNB_LIST = []
ALL_ENB_LIST = []
ALL_RU_LIST = []

ALL_GNB_WEBEM_ADDR_LIST = []
ALL_WEBEM_ADDR_LIST = []

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
    for common_unit_index in range(len(tl.gnbs[gnb_index].dus[0].airscale.common_units)):
        common_unit = tl.gnbs[gnb_index].dus[0].airscale.common_units[common_unit_index]
        print(common_unit)
        common_unit_details = {
            "index": common_unit_index,
            "test_pc_addr": tl.test_pc.default_ssh_connection_details.addr,
            "test_pc_username": tl.test_pc.default_ssh_connection_details.username,
            "test_pc_password": tl.test_pc.default_ssh_connection_details.password,
            "lmp_addr": common_unit.lmp_connection.addr,
            "lmp_username": common_unit.lmp_connection.username,
            "lmp_password": common_unit.lmp_connection.password,
        }
        common_units.append(common_unit_details)

    ru_list = []
    for ru_index in range(len(tl.gnbs[gnb_index].dus[0].rus)):
        ru_details = {
            "ru_type": tl.gnbs[gnb_index].dus[0].rus[ru_index].ru_hw_group,
            "ru_addr": tl.gnbs[gnb_index].dus[0].rus[ru_index].default_ssh_connection_details.addr,
            "ru_username": tl.gnbs[gnb_index].dus[0].rus[ru_index].default_ssh_connection_details.username,
            "ru_password": tl.gnbs[gnb_index].dus[0].rus[ru_index].default_ssh_connection_details.password,
            "ru_serial": tl.gnbs[gnb_index].dus[0].rus[ru_index].serial_number,
            "test_pc_addr": tl.gnbs[gnb_index].dus[0].rus[ru_index].lmp_connection.addr,
            "test_pc_username": tl.gnbs[gnb_index].dus[0].rus[ru_index].lmp_connection.username,
            "test_pc_password": tl.gnbs[gnb_index].dus[0].rus[ru_index].lmp_connection.password,
        }
        ru_list.append(ru_details)
    ALL_CONFIG_INIT[gnb_name] = {
        "instance_id": instance_id,
        "ssh_addr": ssh_addr,
        "ssh_username": ssh_username,
        "ssh_password": ssh_password,
        "webem_addr": webem_addr,
        "webem_username": webem_username,
        "webem_password": webem_password,
        "common_units": common_units,
        "ru_list": ru_list,
    }
    ALL_GNB_LIST.append(gnb_name)
    ALL_GNB_WEBEM_ADDR_LIST.append(webem_addr)
    ALL_WEBEM_ADDR_LIST.append(webem_addr)
    ALL_RU_LIST += ru_list

# Remove Duplicate
ALL_RU_LIST = [dict(t) for t in {tuple(d.items()) for d in ALL_RU_LIST}]

print("ALL_CONFIG_INIT:")
print(ALL_CONFIG_INIT)

print("ALL_GNB_LIST:")
print(ALL_GNB_LIST)

print("ALL_RU_LIST:")
print(ALL_RU_LIST)

print("ALL_GNB_WEBEM_ADDR_LIST:")
print(ALL_GNB_WEBEM_ADDR_LIST)

print("ALL_WEBEM_ADDR_LIST:")
print(ALL_WEBEM_ADDR_LIST)
