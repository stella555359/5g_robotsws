import logging
from ta_messaging.message_flows import get_flow
from ute_common_abstract_core.message import NotFoundKey

DEDICATED_BWP_ID = 1
POWER_SAVING_BWP_ID = 2


def find_el_on_bwp_list(msg, ie_name, bwp_id):
    bwp_list = msg.get_value_by_unique_key(ie_name)
    if len(bwp_list) != bwp_id:
        msg_name = list(msg.get_value_by_unique_key('c1'))[0]
        raise Exception('msg: {}, len({}): {} (must be equal to {})'.format(
            msg_name, ie_name, len(bwp_list), bwp_id))
    for bwp_el in bwp_list:
        if bwp_el['bwp-Id'] == bwp_id and bwp_el['bwp-Dedicated'] is not None:
            if ie_name == 'downlinkBWP-ToAddModList':
                return True
            elif ie_name == 'uplinkBWP-ToAddModList':
                if 'srs-Config' in bwp_el['bwp-Dedicated']:  # 5GC000937-8088
                    return True
                else:
                    raise Exception(
                        'bwp-Dedicated -> srs-Config not found for BWP_ID={}'.format(bwp_id))
    return False


def find_el_on_bwp_rel_list(msg, ie_name, bwp_id):
    bwp_list = msg.get_value_by_unique_key(ie_name)
    for bwp_el in bwp_list:
        if bwp_el == bwp_id:
            return True
    return False


def check_bwp_id_on_csi_resource_config_to_add_mod_list(msg, bwp_id):
    csi_list = msg.get_value_by_unique_key('csi-ResourceConfigToAddModList')
    for i in range(len(csi_list)):
        if csi_list[i]['bwp-Id'] != bwp_id:
            raise Exception('Line 48:CSI-ResourceConfig[{}] -> bwp-Id = {} (must be equal to {})'
                            .format(i, csi_list[i]['bwp-Id'], bwp_id))


def check_bwp_id_on_csi_resource_config_to_add_mod_list_during_ho(msg):
    csi_list = msg.get_value_by_unique_key('csi-ResourceConfigToAddModList')
    if (int(len(csi_list)) % 2) == 0:
        ho_double_list_check = int(len(csi_list) / 2)
        for i in range(ho_double_list_check):
            if csi_list[i]['bwp-Id'] != DEDICATED_BWP_ID:
                raise Exception('Line 58:CSI-ResourceConfig[{}] -> bwp-Id = {} (must be equal to {})'
                                .format(i, csi_list[i]['bwp-Id'], DEDICATED_BWP_ID))
        for i in range(ho_double_list_check, len(csi_list)):
            if csi_list[i]['bwp-Id'] != POWER_SAVING_BWP_ID:
                raise Exception('Line 62:CSI-ResourceConfig[{}] -> bwp-Id = {} (must be equal to {})'
                                .format(i, csi_list[i]['bwp-Id'], POWER_SAVING_BWP_ID))
    else:
        raise Exception('CSI-ResourceConfigToAddModList is incomplete it should have more than {} elements'
                        .format(len(csi_list)))


def check_csi_resource_config_to_add_mod_list_is_not_present(msg):
    try:
        msg.get_value_by_unique_key('csi-ResourceConfigToAddModList')
    except NotFoundKey:
        return True
    return False


def check_key_is_not_present(msg, key):
    try:
        msg.get_value_by_unique_key(key)
    except NotFoundKey:
        return True
    return False


def check_bwp_id_on_csi_report_config_to_add_mod_list(msg, bwp_id):
    uplink_bandwidth_part_ids = [DEDICATED_BWP_ID, POWER_SAVING_BWP_ID]
    csi_list = msg.get_value_by_unique_key('csi-ReportConfigToAddModList')
    if len(csi_list) != bwp_id:
        msg_name = list(msg.get_value_by_unique_key('c1'))[0]
        raise Exception('msg: {}, len(csi-ReportConfigToAddModList): {} (must be equal to {})'.format(msg_name,
                                                                                                      len(
                                                                                                          csi_list),
                                                                                                      bwp_id))
    for i in range(len(csi_list)):
        pucch_csi_list = csi_list[i].get_value_by_unique_key(
            'pucch-CSI-ResourceList')
        for pucch_csi_el in pucch_csi_list:
            if pucch_csi_el['uplinkBandwidthPartId'] != uplink_bandwidth_part_ids[i]:
                raise Exception('CSI-ReportConfig[{}] -> uplinkBandwidthPartId = {} (must be equal to {})'
                                .format(i, pucch_csi_el['uplinkBandwidthPartId'], uplink_bandwidth_part_ids[i]))


def check_bwp_id_on_csi_report_config_to_add_mod_list_with_beamforming(msg, bwp_id, beams):
    uplink_bandwidth_part_ids = []
    beams = int(beams)
    for i in range(bwp_id):
        for beam in range(beams):
            uplink_bandwidth_part_ids.append(i + 1)

    csi_list = msg.get_value_by_unique_key('csi-ReportConfigToAddModList')
    if len(csi_list) != bwp_id * beams:
        msg_name = list(msg.get_value_by_unique_key('c1'))[0]
        raise Exception('msg: {}, len(csi-ReportConfigToAddModList): {} (must be equal to {})'.format(msg_name,
                                                                                                      len(
                                                                                                          csi_list),
                                                                                                      bwp_id * beams))
    for i in range(len(csi_list)):
        pucch_csi_list = csi_list[i].get_value_by_unique_key(
            'pucch-CSI-ResourceList')
        for pucch_csi_el in pucch_csi_list:
            if pucch_csi_el['uplinkBandwidthPartId'] != uplink_bandwidth_part_ids[i]:
                raise Exception('CSI-ReportConfig[{}] -> uplinkBandwidthPartId = {} (must be equal to {})'
                                .format(i, pucch_csi_el['uplinkBandwidthPartId'], uplink_bandwidth_part_ids[i]))


def verify_power_saving_bwp_id_on_csi_config_to_add_mod_list(msg):
    logger = logging.getLogger('messaging.flows.logic')
    # CSI-ResourceConfig is duplicated in RRCReconfiguration only for UE eligible for power saving BWP pool
    # see: 5GC000937-8097
    check_bwp_id_on_csi_resource_config_to_add_mod_list(
        msg, POWER_SAVING_BWP_ID)
    logger.info(
        'CSI-ResourceConfigs point to Power Saving bwp-Id=2 for UE with Power Saving capabilities')
    check_bwp_id_on_csi_report_config_to_add_mod_list(msg, POWER_SAVING_BWP_ID)
    logger.info(
        'CSI-ReportConfigs point to proper uplinkBandwidthPartId for UE with Power Saving capabilities')
    return True


def verify_power_saving_bwp_id_on_csi_config_to_add_mod_list_bf(msg, number_of_beams):
    logger = logging.getLogger('messaging.flows.logic')
    # CSI-ResourceConfig is duplicated in RRCReconfiguration only for UE eligible for power saving BWP pool
    # see: 5GC000937-8097
    check_bwp_id_on_csi_resource_config_to_add_mod_list(
        msg, POWER_SAVING_BWP_ID)
    logger.info(
        'CSI-ResourceConfigs point to Power Saving bwp-Id=2 for UE with Power Saving capabilities')
    check_bwp_id_on_csi_report_config_to_add_mod_list_with_beamforming(
        msg, POWER_SAVING_BWP_ID, number_of_beams)
    logger.info(
        'CSI-ReportConfigs point to proper uplinkBandwidthPartId for UE with Power Saving capabilities')
    return True


def verify_full_and_power_saving_bwp_id_on_csi_config_to_add_mod_list(msg):
    logger = logging.getLogger('messaging.flows.logic')
    logger.debug(
        'start check_bwp_id_on_csi_resource_config_to_add_mod_list_during_ho')
    check_bwp_id_on_csi_resource_config_to_add_mod_list_during_ho(msg)
    logger.info('CSI-ResourceConfigs point to both Full and Power Saving BWPs for UE with Power Saving '
                'capabilities')
    check_bwp_id_on_csi_report_config_to_add_mod_list(msg, POWER_SAVING_BWP_ID)
    logger.info(
        'CSI-ReportConfigs point to proper uplinkBandwidthPartId for UE with Power Saving capabilities')


def verify_power_saving_bwp_deconfiguration_on_csi_config_to_add_mod_list_during_ho(msg):
    logger = logging.getLogger('messaging.flows.logic')
    check_bwp_id_on_csi_resource_config_to_add_mod_list(msg, DEDICATED_BWP_ID)
    logger.info(
        'CSI-ResourceConfigs point to Full bwp-Id=1 for UE with Power Saving capabilities')
    check_bwp_id_on_csi_report_config_to_add_mod_list(msg, DEDICATED_BWP_ID)
    logger.info(
        'CSI-ReportConfigs point to proper uplinkBandwidthPartId for UE with Power Saving capabilities')
    msg.get_value_by_unique_key('csi-ResourceConfigToReleaseList')
    logger.info('CSI-ResourceConfigs removes previous configuration')
    msg.get_value_by_unique_key('csi-ReportConfigToReleaseList')
    logger.info('CSI-ReportConfigs removes previous configuration')


def verify_power_saving_bwp_on_csi_and_bwp_to_add_mod_list(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    logger = logging.getLogger('messaging.flows.logic')
    try:
        bwp_dl_power_saving_found = find_el_on_bwp_list(
            msg, 'downlinkBWP-ToAddModList', POWER_SAVING_BWP_ID)
        bwp_ul_power_saving_found = find_el_on_bwp_list(
            msg, 'uplinkBWP-ToAddModList', POWER_SAVING_BWP_ID)
        bwp_id_on_csi_lists_found = verify_power_saving_bwp_id_on_csi_config_to_add_mod_list(
            msg)
        if bwp_dl_power_saving_found and bwp_ul_power_saving_found and bwp_id_on_csi_lists_found:
            return True
    except Exception as e:
        logger.error(
            'verify_power_saving_bwp_on_bwp_to_add_mod_list_and_csi_elements: No Power Saving BWP found')
        logger.error(e)
        raise Exception


def verify_power_saving_bwp_on_csi_and_bwp_to_add_mod_list_beamforming(flow_alias, message_alias, number_of_beams):
    msg = get_flow(flow_alias).get_message(message_alias)
    logger = logging.getLogger('messaging.flows.logic')
    try:
        bwp_dl_power_saving_found = find_el_on_bwp_list(
            msg, 'downlinkBWP-ToAddModList', POWER_SAVING_BWP_ID)
        bwp_ul_power_saving_found = find_el_on_bwp_list(
            msg, 'uplinkBWP-ToAddModList', POWER_SAVING_BWP_ID)
        bwp_id_on_csi_lists_found = verify_power_saving_bwp_id_on_csi_config_to_add_mod_list_bf(msg,
                                                                                                number_of_beams)
        if bwp_dl_power_saving_found and bwp_ul_power_saving_found and bwp_id_on_csi_lists_found:
            return True
    except Exception as e:
        logger.error(
            'verify_power_saving_bwp_on_bwp_to_add_mod_list_and_csi_elements: No Power Saving BWP found')
        logger.error(e)
        raise Exception


def verify_full_bwp_id_on_csi_config_to_add_mod_list(msg):
    logger = logging.getLogger('messaging.flows.logic')
    try:
        check_bwp_id_on_csi_report_config_to_add_mod_list(
            msg, DEDICATED_BWP_ID)
        logger.info(
            'CSI-ReportConfigs point to proper uplinkBandwidthPartId for UE without Power Saving capabilities')
        csi_resource_list_not_present = check_csi_resource_config_to_add_mod_list_is_not_present(
            msg)
        if csi_resource_list_not_present:
            return True
    except Exception as e:
        logger.error(e)
        raise Exception


def verify_full_bwp_id_on_csi_config_to_add_mod_list_bf(msg, number_of_beams):
    logger = logging.getLogger('messaging.flows.logic')
    try:
        check_bwp_id_on_csi_report_config_to_add_mod_list_with_beamforming(
            msg, DEDICATED_BWP_ID, number_of_beams)
        logger.info(
            'CSI-ReportConfigs point to proper uplinkBandwidthPartId for UE without Power Saving capabilities')
        csi_resource_list_not_present = check_csi_resource_config_to_add_mod_list_is_not_present(
            msg)
        if csi_resource_list_not_present:
            return True
    except Exception as e:
        logger.error(e)
        raise Exception


def verify_full_bwp_on_csi_and_bwp_to_add_mod_list(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    logger = logging.getLogger('messaging.flows.logic')
    try:
        bwp_dl_dedicated_found = find_el_on_bwp_list(
            msg, 'downlinkBWP-ToAddModList', DEDICATED_BWP_ID)
        bwp_ul_dedicated_found = find_el_on_bwp_list(
            msg, 'uplinkBWP-ToAddModList', DEDICATED_BWP_ID)
        bwp_id_on_csi_lists_found = verify_full_bwp_id_on_csi_config_to_add_mod_list(
            msg)
        if bwp_dl_dedicated_found and bwp_ul_dedicated_found and bwp_id_on_csi_lists_found:
            return True
    except Exception as e:
        logger.error(
            'verify_full_bwp_on_bwp_to_add_mod_list_and_csi_elements: ')
        logger.error(e)
        raise Exception


def verify_full_bwp_on_csi_and_bwp_to_add_mod_list_beamforming(flow_alias, message_alias, number_of_beams):
    msg = get_flow(flow_alias).get_message(message_alias)
    logger = logging.getLogger('messaging.flows.logic')
    try:
        bwp_dl_dedicated_found = find_el_on_bwp_list(
            msg, 'downlinkBWP-ToAddModList', DEDICATED_BWP_ID)
        bwp_ul_dedicated_found = find_el_on_bwp_list(
            msg, 'uplinkBWP-ToAddModList', DEDICATED_BWP_ID)
        bwp_id_on_csi_lists_found = verify_full_bwp_id_on_csi_config_to_add_mod_list_bf(
            msg, number_of_beams)
        if bwp_dl_dedicated_found and bwp_ul_dedicated_found and bwp_id_on_csi_lists_found:
            return True
    except Exception as e:
        logger.error(
            'verify_full_bwp_on_bwp_to_add_mod_list_and_csi_elements: ')
        logger.error(e)
        raise Exception


def verify_full_bwp_on_csi_and_bwp_to_add_mod_list_during_ho(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    logger = logging.getLogger('messaging.flows.logic')
    try:
        find_el_on_bwp_list(msg, 'downlinkBWP-ToAddModList', DEDICATED_BWP_ID)
        find_el_on_bwp_list(msg, 'uplinkBWP-ToAddModList', DEDICATED_BWP_ID)
        check_bwp_id_on_csi_resource_config_to_add_mod_list(
            msg, DEDICATED_BWP_ID)
        logger.info('CSI-ResourceConfigs point to Full bwp-Id=1')
        check_bwp_id_on_csi_report_config_to_add_mod_list(
            msg, DEDICATED_BWP_ID)
        logger.info('CSI-ReportConfigs point to proper uplinkBandwidthPartId')
    except Exception as e:
        logger.error(
            'verify_full_bwp_on_bwp_to_add_mod_list_and_csi_elements: ')
        logger.error(e)
        raise Exception


def verify_power_saving_bwp_on_csi_and_bwp_to_add_mod_list_during_ho(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    logger = logging.getLogger('messaging.flows.logic')
    try:
        bwp_dl_power_saving_found = find_el_on_bwp_list(
            msg, 'downlinkBWP-ToAddModList', POWER_SAVING_BWP_ID)
        bwp_ul_power_saving_found = find_el_on_bwp_list(
            msg, 'uplinkBWP-ToAddModList', POWER_SAVING_BWP_ID)
        bwp_id_on_csi_lists_found = verify_full_and_power_saving_bwp_id_on_csi_config_to_add_mod_list(
            msg)
        if bwp_dl_power_saving_found and bwp_ul_power_saving_found and bwp_id_on_csi_lists_found:
            return True
    except Exception as e:
        logger.error(
            'verify_full_bwp_on_bwp_to_add_mod_list_and_csi_elements: ')
        logger.error(e)
        raise Exception


def verify_rach_config_ps_bwp(flow_alias, message_alias, rach_should_be_present, setup_release='setup'):
    msg = get_flow(flow_alias).get_message(message_alias)
    logger = logging.getLogger('messaging.flows.logic')
    if rach_should_be_present.lower() == 'true':
        try:
            ps_bwp = msg.get_value_by_unique_key(
                'uplinkBWP-ToAddModList')[1]  # second element is PS-BWP
            rach = ps_bwp['bwp-Common']['rach-ConfigCommon']
            if setup_release.lower() == 'setup':
                assert 'setup' in rach
                logger.info(
                    'uplinkBWP-ToAddModList->bwp-Common->rach-ConfigCommon: setup is present in PS-BWP')
                return True
            elif setup_release.lower() == 'release':
                assert 'release' in rach
                logger.info(
                    'uplinkBWP-ToAddModList->bwp-Common->rach-ConfigCommon: release is present in PS-BWP')
                return True
            else:
                logger.error(
                    'Wrong value of setup_release, must be \'setup\' or \'release\'')
                raise Exception
        except Exception as e:
            logger.error('verify_rach_config_ps_bwp: RACH should be present')
            logger.error(e)
            raise Exception
    else:
        try:
            ps_bwp = msg.get_value_by_unique_key(
                'uplinkBWP-ToAddModList')[1]  # second element is PS-BWP
            assert 'rach-ConfigCommon' not in ps_bwp['bwp-Common']
            logger.info(
                'uplinkBWP-ToAddModList->bwp-Common->rach-ConfigCommon is not present in PS-BWP')
            return True
        except Exception as e:
            logger.error(
                'verify_rach_config_ps_bwp: RACH should not be present')
            logger.error(e)
            raise Exception
