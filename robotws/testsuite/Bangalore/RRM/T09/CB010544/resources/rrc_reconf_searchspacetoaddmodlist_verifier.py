"""
:copyright: Nokia Networks
:author: Konrad Bem <konrad.bem@nokia.com>
:maintainer: Konrad Bem <konrad.bem@nokia.com>
:Description: "
:Description:
:Example 1: "

"""

# import logging
from ta_messaging.message_flows import get_flow


def check_search_spaces_to_add_mod_list_elements_bwp_dedicated_2elements(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    # logger = logging.getLogger('messaging.flows.logic')
    assert len(
        msg.get_value_by_unique_key('downlinkBWP-ToAddModList')) == 2, "downlinkBWP-ToAddModList is not equal to 2"

    ps_bwp = msg.get_value_by_unique_key('downlinkBWP-ToAddModList')[1]
    assert len(ps_bwp['bwp-Dedicated']['pdcch-Config']['setup'][
                   'searchSpacesToAddModList']) == 2, "searchSpacesToAddModList is not equal to 2"
