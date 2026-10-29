from robot.libraries.BuiltIn import BuiltIn
import logging


def set_config_variables(tl):
    BuiltIn().set_test_variable('${testline}', tl)
    logging.info(tl)
    vdus = tl.gnbs[0].dus
    vcu = tl.gnbs[0].cu
    topology = tl.tl_cloud_topology
    BuiltIn().set_test_variable('${VDU_LIST}', vdus)
    BuiltIn().set_test_variable('${VCU}', vcu)
    BuiltIn().set_test_variable('${TOPOLOGY}', topology)
    vcu_connection = {
        'IP_ADDRESS': vcu.oam_http_connection_details.addr,
        'USERNAME': vcu.oam_http_connection_details.username,
        'PASSWORD': vcu.oam_http_connection_details.password,
        'PORT': vcu.oam_http_connection_details.port,
        'SSH_IP': vcu.oam_ssh_connection_details.addr,
        'SSH_USERNAME': vcu.oam_ssh_connection_details.username,
        'SSH_PASSWORD': vcu.oam_ssh_connection_details.password,
        'VCU_CRAN': tl.gnbs[0].cloud_deployment.cloud_hosting.namespace
    }
    BuiltIn().set_test_variable('${VCU_CONNECTION_DETAILS}', vcu_connection)

    vdu_vlan_ids_list = []
    vdu_connection_details_list = []
    for vdu in vdus:
        prerequisite_data = vdu.cloud_deployment.prerequisite.configuration_data
        if prerequisite_data.get('aic-intnet').get('VLANID') is not None:
            vlans = prerequisite_data.get('aic-intnet').get('VLANID')
        else:
            vlans = prerequisite_data.get('aic-intnet').get('VlanID')
        vdu_vlan_ids = {'vdu_id': vlans}
        vdu_vlan_ids_list.append(vdu_vlan_ids)
        vdu_connection = {
            'IP_ADDRESS': vdu.oam_http_connection_details.addr,
            'USERNAME': vdu.oam_http_connection_details.username,
            'PASSWORD': vdu.oam_http_connection_details.password,
            'PORT': vdu.oam_http_connection_details.port,
            'INSTANCE_ID': vdu.instance_id,
            'SSH_IP': vdu.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr,
            'SSH_USERNAME': vdu.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username,
            'SSH_PASSWORD': vdu.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password,
            'VDU_CRAN': tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace
        }
        vdu_connection_details_list.append({'VDU_ID': vdu_connection})
    BuiltIn().set_test_variable('${VDU_VLAN_IDS_LIST}', vdu_vlan_ids_list)
    BuiltIn().set_test_variable('${VDU_CONNECTION_DETAILS_LIST}', vdu_connection_details_list)

    test_pc_connection = {
        'IP_ADDRESS': tl.test_pc.default_ssh_connection_details.addr,
        'USERNAME': tl.test_pc.default_ssh_connection_details.username,
        'PASSWORD': tl.test_pc.default_ssh_connection_details.password,
        'PORT': tl.test_pc.default_ssh_connection_details.port
    }
    BuiltIn().set_test_variable('${TEST_PC_CONNECTION_DETAILS}', test_pc_connection)
