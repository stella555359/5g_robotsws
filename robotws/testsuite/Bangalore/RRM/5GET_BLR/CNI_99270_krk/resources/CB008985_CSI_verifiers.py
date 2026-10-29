"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>, Mateusz Matusik <mateusz.matusik@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>, Mateusz Matusik <mateusz.matusik@nokia.com>
"""

import logging
from ta_messaging.message_verifiers import message_verifier
from ta_messaging.message_flows import get_flow
from robot.libraries.BuiltIn import BuiltIn
from ute_common_abstract_core.message import NotFoundKey


@message_verifier
def verify_that_ue_has_csi_ssb_resources_configured_by_supercell(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)

    verify_csi_ssb_resource_set_list_contains_id_for_element_with_csi_resource_config_id(msg, 0, 10)
    verify_csi_report_config_to_add_mod_list_contains_report_quantity(msg, 0, 'cri-RI-PMI-CQI')
    verify_csi_report_config_to_add_mod_list_contains_report_quantity(msg, 2, 'ssb-Index-RSRP')

    return True


def verify_csi_ssb_resource_set_list_contains_id_for_element_with_csi_resource_config_id(msg,
                                                                                         csi_ssb_resource_set_id,
                                                                                         csi_resource_config_id):
    # logger = logging.getLogger('messaging.flows.logic')
    pcell_config_list = msg.get_value_by_unique_key('spCellConfig')
    # scell_config_list = msg.get_value_by_unique_key('sCellToAddModList')
    # scsi_resource_config_to_add_mod_list = scell_config_list.get_value_by_unique_key('csi-ResourceConfigToAddModList')
    csi_resource_config_to_add_mod_list = pcell_config_list.get_value_by_unique_key('csi-ResourceConfigToAddModList')

    for csi_resource_config in csi_resource_config_to_add_mod_list:
        # BuiltIn().log_to_console(csi_resource_config)
        if csi_resource_config['csi-ResourceConfigId'] == csi_resource_config_id:
            for res_id in csi_resource_config['csi-RS-ResourceSetList']['nzp-CSI-RS-SSB']['csi-SSB-ResourceSetList']:
                if res_id == csi_ssb_resource_set_id:
                    return

    raise AssertionError('CSI-SSB-ResourceSetId={} not found \
                        for csi-ResourceConfigId={}'.format(csi_ssb_resource_set_id, csi_resource_config_id))


def verify_csi_report_config_to_add_mod_list_contains_report_quantity(msg, report_config_id, report_quantity):
    # logger = logging.getLogger('messaging.flows.logic')
    csi_report_config_to_add_mod_list = msg.get_value_by_unique_key('csi-ReportConfigToAddModList')

    for csi_report_config in csi_report_config_to_add_mod_list:
        # BuiltIn().log_to_console(csi_report_config)
        if csi_report_config['reportConfigId'] == report_config_id:
            if csi_report_config['reportQuantity'][report_quantity] is None:
                return

    raise AssertionError('reportQuantity={} is not set for reportConfigId={}'.format(report_quantity, report_config_id))


def verify_pair_of_ues_is_allocated_in_the_same_first_ofdm_symbol_in_time_domain(flow_ue1, flow_ue2):
    msg_ue1 = get_flow(flow_ue1).get_message('RRCSetup')
    msg_ue2 = get_flow(flow_ue2).get_message('RRCSetup')

    nzp_csi_rs_resource_zero_id_for_first_ue = msg_ue1.get_value_by_unique_key('nzp-CSI-RS-ResourceToAddModList')[0]
    nzp_csi_rs_resource_zero_id_for_second_ue = msg_ue2.get_value_by_unique_key('nzp-CSI-RS-ResourceToAddModList')[0]

    return nzp_csi_rs_resource_zero_id_for_first_ue == nzp_csi_rs_resource_zero_id_for_second_ue


def verify_pair_of_ues_is_allocated_in_the_same_first_ofdm_symbol_in_time_domain_in_nsa_mode(nsa_flows):
    msg_ue1 = get_flow(nsa_flows).get_message('SgNBAdditionRequestAcknowledge_1')
    msg_ue2 = get_flow(nsa_flows).get_message('SgNBAdditionRequestAcknowledge_2')

    nzp_csi_rs_resource_zero_id_for_first_ue = msg_ue1.get_value_by_unique_key('nzp-CSI-RS-ResourceToAddModList')[0]
    nzp_csi_rs_resource_zero_id_for_second_ue = msg_ue2.get_value_by_unique_key('nzp-CSI-RS-ResourceToAddModList')[0]

    return nzp_csi_rs_resource_zero_id_for_first_ue == nzp_csi_rs_resource_zero_id_for_second_ue
