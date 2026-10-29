from ta_messaging.message_flows import get_flow as _get_flow
import pprint

# SCHEDUL_PRIO means NRDRB_MAC.schedulPrio related to NRDRB_5QI.fiveqiValueList
FIVEQI_TO_SCHEDUL_PRIO = {'5': '4', '6': '9', '7': '10', '8': '11', '9': '12', '128': '13', '170': '14', '254': '15'}


def verify_that_correct_nrdrb_was_applied_for_drb(
        message_alias, flow_alias, pdu_id, qfi_id, fiveqi_id):
    assert FIVEQI_TO_SCHEDUL_PRIO.get(fiveqi_id), \
        f'5QI{fiveqi_id} is not expected to be configured for QFI'
    msg_content = _get_flow(flow_alias).get_message(message_alias)
    # print('Got message content: \n{}'.format(pprint.pformat(msg_content)))
    drb_add_list = msg_content.get_value_by_unique_key('drb-ToAddModList')
    drb_id = 0
    for drb in drb_add_list:
        if str(drb.get_value_by_unique_key('pdu-Session')) == pdu_id:
            if str(drb.get_value_by_unique_key('mappedQoS-FlowsToAdd')[0]) == qfi_id:
                drb_id = drb.get_value_by_unique_key('drb-Identity')
            break
    assert drb_id, f'Field \'pdu-Session\' = {pdu_id} is not present'

    rlc_bearer_add_list = msg_content.get_value_by_unique_key('rlc-BearerToAddModList')
    priority = 0
    for rlc_bearer in rlc_bearer_add_list:
        if rlc_bearer.get_value_by_unique_key('drb-Identity') == drb_id:
            priority = str(rlc_bearer.get_value_by_unique_key('priority'))
            assert priority == FIVEQI_TO_SCHEDUL_PRIO[fiveqi_id], \
                f'Not correct NRDRB_MAC.schedulPrio for QFI{qfi_id}\n ' \
                f'expexted: {FIVEQI_TO_SCHEDUL_PRIO[fiveqi_id]}, received: {priority}'
            break
    assert priority, f'No rlc-BearerConfig related to QFI{qfi_id} found'


def verify_that_ids_of_setup_bearers_are_higher_than_released(message_alias, flow_alias):
    msg_content = _get_flow(flow_alias).get_message(message_alias)
    print('Got message content: \n{}'.format(pprint.pformat(msg_content)))
    drb_add_list = msg_content.get_value_by_unique_key('drb-ToAddModList')
    rlc_add_list = msg_content.get_value_by_unique_key('rlc-BearerToAddModList')
    drb_add_ids = drb_add_list.get_all_values_by_key('drb-Identity')
    drb_rel_ids = msg_content.get_value_by_unique_key('drb-ToReleaseList')
    rlc_add_ids = rlc_add_list.get_all_values_by_key('logicalChannelIdentity')
    rlc_rel_ids = msg_content.get_value_by_unique_key('rlc-BearerToReleaseList')

    print(f'drb-ToAddModList, drb-Identity: {drb_add_ids}')
    print(f'rlc-BearerToAddModList, logicalChannelIdentity: {rlc_add_ids}')
    print(f'drb-ToReleaseList, drb-Identity: {drb_rel_ids}')
    print(f'rlc-BearerToReleaseList, logicalChannelIdentity: {rlc_rel_ids}')
    assert drb_add_ids and drb_rel_ids and rlc_add_ids and rlc_rel_ids, f'One of above list is empty'
    assert max(drb_rel_ids) < min(drb_add_ids), f'drb-Identity of setup DRB is not higher than released one'
    assert max(rlc_rel_ids) < min(rlc_add_ids), f'logicalChannelIdentity of setup rlc-Bearer is not higher ' \
                                                f'than released one'
