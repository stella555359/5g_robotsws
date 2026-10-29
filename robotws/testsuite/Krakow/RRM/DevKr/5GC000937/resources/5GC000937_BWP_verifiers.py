"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>, Mateusz Matusik <mateusz.matusik@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>, Mateusz Matusik <mateusz.matusik@nokia.com>
"""

import logging
from ta_messaging.message_verifiers import message_verifier
from ta_messaging.message_flows import get_flow
from ta_messaging.message_containers import _parse_container
from ute_common_abstract_core.message import NotFoundKey

DEDICATED_BWP_ID = 1
POWER_SAVING_BWP_ID = 2
POWER_SAVING_C_SRS = 20


def find_el_on_bwp_list(msg, ie_name, bwp_id):
    logger = logging.getLogger('messaging.flows.logic')
    bwp_list = msg.get_value_by_unique_key(ie_name)
    if len(bwp_list) != bwp_id:
        msg_name = msg.get_value_by_unique_key('c1').keys()[0]
        raise Exception('msg: {}, len({}): {} (must be equal to {})'.format(msg_name, ie_name, len(bwp_list), bwp_id))
    for bwp_el in bwp_list:
        if bwp_el['bwp-Id'] == bwp_id and bwp_el['bwp-Dedicated'] is not None:
            if ie_name == 'downlinkBWP-ToAddModList':
                return True
            elif ie_name == 'uplinkBWP-ToAddModList':
                if 'srs-Config' in bwp_el['bwp-Dedicated']:  # 5GC000937-8088
                    return True
                else:
                    raise Exception('bwp-Dedicated -> srs-Config not found for BWP_ID={}'.format(bwp_id))
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
    logger = logging.getLogger('messaging.flows.logic')
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
        msg_name = msg.get_value_by_unique_key('c1').keys()[0]
        raise Exception('msg: {}, len(csi-ReportConfigToAddModList): {} (must be equal to {})'.format(msg_name,
                                                                                                      len(csi_list),
                                                                                                      bwp_id))
    for i in range(len(csi_list)):
        pucch_csi_list = csi_list[i].get_value_by_unique_key('pucch-CSI-ResourceList')
        for pucch_csi_el in pucch_csi_list:
            if pucch_csi_el['uplinkBandwidthPartId'] != uplink_bandwidth_part_ids[i]:
                raise Exception('CSI-ReportConfig[{}] -> uplinkBandwidthPartId = {} (must be equal to {})'
                                .format(i, pucch_csi_el['uplinkBandwidthPartId'], uplink_bandwidth_part_ids[i]))


@message_verifier
def verify_power_saving_bwp_id_on_csi_config_to_add_mod_list(msg):
    logger = logging.getLogger('messaging.flows.logic')
    try:
        # CSI-ResourceConfig is duplicated in RRCReconfiguration only for UE eligible for power saving BWP pool
        # see: 5GC000937-8097
        check_bwp_id_on_csi_resource_config_to_add_mod_list(msg, POWER_SAVING_BWP_ID)
        logger.info('CSI-ResourceConfigs point to Power Saving bwp-Id=2 for UE with Power Saving capabilities')
        check_bwp_id_on_csi_report_config_to_add_mod_list(msg, POWER_SAVING_BWP_ID)
        logger.info('CSI-ReportConfigs point to proper uplinkBandwidthPartId for UE with Power Saving capabilities')
    except Exception as e:
        logger.error(e)
        return False
    return True


@message_verifier
def verify_full_and_power_saving_bwp_id_on_csi_config_to_add_mod_list(msg):
    logger = logging.getLogger('messaging.flows.logic')
    try:
        logger.debug('start check_bwp_id_on_csi_resource_config_to_add_mod_list_during_ho')
        check_bwp_id_on_csi_resource_config_to_add_mod_list_during_ho(msg)
        logger.info('CSI-ResourceConfigs point to both Full and Power Saving BWPs for UE with Power Saving '
                    'capabilities')
        check_bwp_id_on_csi_report_config_to_add_mod_list(msg, POWER_SAVING_BWP_ID)
        logger.info('CSI-ReportConfigs point to proper uplinkBandwidthPartId for UE with Power Saving capabilities')
    except Exception as e:
        logger.error('verify_full_and_power_saving_bwp_id_on_csi_config_to_add_mod_list: ')
        logger.error(e)
        return False
    return True


@message_verifier
def verify_power_saving_bwp_deconfiguration_on_csi_config_to_add_mod_list_during_ho(msg):
    logger = logging.getLogger('messaging.flows.logic')
    try:
        check_bwp_id_on_csi_resource_config_to_add_mod_list(msg, DEDICATED_BWP_ID)
        logger.info('CSI-ResourceConfigs point to Full bwp-Id=1 for UE with Power Saving capabilities')
        check_bwp_id_on_csi_report_config_to_add_mod_list(msg, DEDICATED_BWP_ID)
        logger.info('CSI-ReportConfigs point to proper uplinkBandwidthPartId for UE with Power Saving capabilities')
        msg.get_value_by_unique_key('csi-ResourceConfigToReleaseList')
        logger.info('CSI-ResourceConfigs removes previous configuration')
        msg.get_value_by_unique_key('csi-ReportConfigToReleaseList')
        logger.info('CSI-ReportConfigs removes previous configuration')
    except Exception as e:
        logger.error('verify_power_saving_bwp_deconfiguration_on_csi_config_to_add_mod_list_during_ho: ')
        logger.error(e)
        return False
    return True


@message_verifier
def verify_power_saving_bwp_on_csi_and_bwp_to_add_mod_list(msg):
    logger = logging.getLogger('messaging.flows.logic')
    try:
        bwp_dl_power_saving_found = find_el_on_bwp_list(msg, 'downlinkBWP-ToAddModList', POWER_SAVING_BWP_ID)
        bwp_ul_power_saving_found = find_el_on_bwp_list(msg, 'uplinkBWP-ToAddModList', POWER_SAVING_BWP_ID)
        bwp_id_on_csi_lists_found = verify_power_saving_bwp_id_on_csi_config_to_add_mod_list(msg)
        if bwp_dl_power_saving_found and bwp_ul_power_saving_found and bwp_id_on_csi_lists_found:
            return True
    except Exception as e:
        logger.error('verify_power_saving_bwp_on_bwp_to_add_mod_list_and_csi_elements: No Power Saving BWP found')
        logger.error(e)
        return False
    else:
        logger.error('bwp_dl_power_saving_found = {}, bwp_ul_power_saving_found = {}, bwp_id_on_csi_lists_found = {}'
                     .format(bwp_dl_power_saving_found,
                             bwp_ul_power_saving_found,
                             bwp_id_on_csi_lists_found))
        return False


@message_verifier
def verify_full_bwp_id_on_csi_config_to_add_mod_list(msg):
    logger = logging.getLogger('messaging.flows.logic')
    try:
        check_bwp_id_on_csi_report_config_to_add_mod_list(msg, DEDICATED_BWP_ID)
        logger.info('CSI-ReportConfigs point to proper uplinkBandwidthPartId for UE without Power Saving capabilities')
        csi_resource_list_not_present = check_csi_resource_config_to_add_mod_list_is_not_present(msg)
        if csi_resource_list_not_present:
            return True
    except Exception as e:
        logger.error(e)
        return False
    return False


@message_verifier
def verify_full_bwp_on_csi_and_bwp_to_add_mod_list(msg):
    logger = logging.getLogger('messaging.flows.logic')
    try:
        bwp_dl_dedicated_found = find_el_on_bwp_list(msg, 'downlinkBWP-ToAddModList', DEDICATED_BWP_ID)
        bwp_ul_dedicated_found = find_el_on_bwp_list(msg, 'uplinkBWP-ToAddModList', DEDICATED_BWP_ID)
        bwp_id_on_csi_lists_found = verify_full_bwp_id_on_csi_config_to_add_mod_list(msg)
        if bwp_dl_dedicated_found and bwp_ul_dedicated_found and bwp_id_on_csi_lists_found:
            return True
    except Exception as e:
        logger.error('verify_full_bwp_on_bwp_to_add_mod_list_and_csi_elements: ')
        logger.error(e)
        return False
    else:
        logger.error('bwp_dl_dedicated_found = {}, bwp_ul_dedicated_found = {}, bwp_id_on_csi_lists_found = {}'
                     .format(bwp_dl_dedicated_found,
                             bwp_ul_dedicated_found,
                             bwp_id_on_csi_lists_found))
        return False


@message_verifier
def verify_full_bwp_on_csi_and_bwp_to_add_mod_list_during_ho(msg):
    logger = logging.getLogger('messaging.flows.logic')
    try:
        bwp_dl_dedicated_found = find_el_on_bwp_list(msg, 'downlinkBWP-ToAddModList', DEDICATED_BWP_ID)
        bwp_ul_dedicated_found = find_el_on_bwp_list(msg, 'uplinkBWP-ToAddModList', DEDICATED_BWP_ID)
        bwp_dl_release_found = find_el_on_bwp_rel_list(msg, 'downlinkBWP-ToReleaseList', POWER_SAVING_BWP_ID)
        bwp_ul_release_found = find_el_on_bwp_rel_list(msg, 'uplinkBWP-ToReleaseList', POWER_SAVING_BWP_ID)
        bwp_deconfiguration_on_csi_lists_found = \
            verify_power_saving_bwp_deconfiguration_on_csi_config_to_add_mod_list_during_ho(msg)
        if (bwp_dl_dedicated_found and
                bwp_ul_dedicated_found and
                bwp_dl_release_found and
                bwp_ul_release_found and
                bwp_deconfiguration_on_csi_lists_found):
            return True
    except Exception as e:
        logger.error('verify_full_bwp_on_bwp_to_add_mod_list_and_csi_elements: ')
        logger.error(e)
        return False
    else:
        logger.error('bwp_dl_dedicated_found = {}, bwp_ul_dedicated_found = {}, bwp_dl_release_found = {}, '
                     'bwp_ul_release_found = {}, bwp_deconfiguration_on_csi_lists_found = {}'
                     .format(bwp_dl_dedicated_found,
                             bwp_ul_dedicated_found,
                             bwp_dl_release_found,
                             bwp_ul_release_found,
                             bwp_deconfiguration_on_csi_lists_found))
        return False


@message_verifier
def verify_power_saving_bwp_on_csi_and_bwp_to_add_mod_list_during_ho(msg):
    logger = logging.getLogger('messaging.flows.logic')
    try:
        bwp_dl_power_saving_found = find_el_on_bwp_list(msg, 'downlinkBWP-ToAddModList', POWER_SAVING_BWP_ID)
        bwp_ul_power_saving_found = find_el_on_bwp_list(msg, 'uplinkBWP-ToAddModList', POWER_SAVING_BWP_ID)
        bwp_id_on_csi_lists_found = verify_full_and_power_saving_bwp_id_on_csi_config_to_add_mod_list(msg)
        if bwp_dl_power_saving_found and bwp_ul_power_saving_found and bwp_id_on_csi_lists_found:
            return True
    except Exception as e:
        logger.error('verify_full_bwp_on_bwp_to_add_mod_list_and_csi_elements: ')
        logger.error(e)
        return False
    else:
        logger.error('bwp_dl_power_saving_found = {}, bwp_ul_power_saving_found = {}, bwp_id_on_csi_lists_found = {}'
                     .format(bwp_dl_power_saving_found,
                             bwp_ul_power_saving_found,
                             bwp_id_on_csi_lists_found))
        return False


def decode_handoverpreparationinformation_ie_and_verify_it(flow_alias, message_alias, pwr_svg_status_in_source):
    msg = get_flow(flow_alias).get_message(message_alias)
    if pwr_svg_status_in_source == 'enabled':
        verify_full_and_power_saving_bwp_id_on_csi_config_to_add_mod_list(msg)
    elif pwr_svg_status_in_source == 'disabled':
        verify_full_bwp_id_on_csi_config_to_add_mod_list(msg)
    else:
        raise Exception('Variable pwr_svg_enabled_in_source is not set to expected value, but to: {}'
                        .format(pwr_svg_status_in_source))


def check_ue_capabilities(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    try:
        if check_key_is_not_present(msg, 'bwp-SwitchingDelay'):
            msg.get_value_by_unique_key('bwp-SameNumerology')
        elif check_key_is_not_present(msg, 'bwp-SameNumerology'):
            msg.get_value_by_unique_key('bwp-SwitchingDelay')
        else:
            msg.get_value_by_unique_key('bwp-SwitchingDelay')
            msg.get_value_by_unique_key('bwp-SameNumerology')
    except NotFoundKey:
        return False
    return True


def verify_freqhopping_c_srs_value(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    bwp_ul_list = msg.get_value_by_unique_key('uplinkBWP-ToAddModList')
    for bwp in bwp_ul_list:
        if bwp.get_value_by_unique_key('bwp-Id') == POWER_SAVING_BWP_ID:
            c_srs = bwp.get_all_values_by_key('c-SRS')[0]
            if c_srs == POWER_SAVING_C_SRS:
                return True
            raise Exception('freqHopping.c-SRS = {} in Power Saving BWP UL profile (must be equal to {})'
                            .format(c_srs, POWER_SAVING_C_SRS))
    raise Exception('No suitable Power Saving BWP Profile was found in the message')
