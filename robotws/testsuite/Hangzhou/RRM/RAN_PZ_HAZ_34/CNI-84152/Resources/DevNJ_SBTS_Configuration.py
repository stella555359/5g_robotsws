# from robot.libraries.BuiltIn import BuiltIn

sbts_ip = '192.168.255.129'
sbts_lmp_ip = '192.168.255.129'
sbts_lmp_user = 'toor4nsn'
sbts_lmp_password = 'oZPS0POrRieRtu'

#
# builtin_obj = BuiltIn()
#
# tl = builtin_obj.get_variable_value('${tl}')
# master_node = 'gnb'
#
# if hasattr(tl, "master_bts"):
#     if tl.master_bts.lower() == 'enb':
#         sbts_ip = tl.enbs[0].system_module.common_units[0].lmp_connection.addr
#         sbts_lmp_ip = tl.enbs[0].system_module.common_units[0].lmp_connection.addr
#         sbts_lmp_user = tl.enbs[0].system_module.common_units[0].lmp_connection.username
#         sbts_lmp_password = tl.enbs[0].system_module.common_units[0].lmp_connection.password
#         device_name = 'ENB0'
#         master_node = 'enb'
#     else:
#         sbts_ip = tl.gnbs[0].cu.oam_ssh_connection_details.addr
#         sbts_lmp_ip = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
#         sbts_lmp_user = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username
#         sbts_lmp_password = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password
#         device_name = 'GNB0'
#         master_node = 'gnb'
# else:
#     if hasattr(tl, "gnbs") and tl.gnbs and not tl.enbs:
#         sbts_ip = tl.gnbs[0].cu.oam_ssh_connection_details.addr
#         sbts_lmp_ip = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
#         sbts_lmp_user = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username
#         sbts_lmp_password = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password
#         device_name = 'GNB0'
#         master_node = 'gnb'
#     elif hasattr(tl, "enbs") and tl.enbs and tl.gnbs:
#         sbts_ip = tl.enbs[0].system_module.common_units[0].lmp_connection.addr
#         sbts_lmp_ip = tl.enbs[0].system_module.common_units[0].lmp_connection.addr
#         sbts_lmp_user = tl.enbs[0].system_module.common_units[0].lmp_connection.username
#         sbts_lmp_password = tl.enbs[0].system_module.common_units[0].lmp_connection.password
#         device_name = 'ENB0'
#         master_node = 'enb'
#     else:
#         sbts_ip = tl.gnbs[0].cu.oam_ssh_connection_details.addr
#         sbts_lmp_ip = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
#         sbts_lmp_user = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username
#         sbts_lmp_password = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password
#         device_name = 'GNB0'
#         master_node = 'gnb'
