"""
:copyright: Nokia Networks
:author: Mateusz Matusik <mateusz.matusik@nokia.com>
:maintainer: Mateusz Matusik <mateusz.matusik@nokia.com>
"""

from ta_messaging.message_flows import get_flow


def extract_ue_ran_id_from_ics(flow_alias, message_alias):
    msg = get_flow(flow_alias).get_message(message_alias)
    ue_ran_id = msg.get_value_by_unique_key('RAN-UE-NGAP-ID')
    return ue_ran_id
