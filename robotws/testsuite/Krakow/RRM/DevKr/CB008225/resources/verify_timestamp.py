from ta_messaging.message_verifiers import message_verifier
from ta_messaging.message_flows import get_flow

difference = int()


@message_verifier
def verify_difference_between_timestamp_inside_location_report_and_rrc_release_occurrence(message_alias, flow_alias,
                                                                                          rrc_release_timestamp):
    """Compare time of RRCRelease occurrence in NTP time and timestamp written in NGAP: LocationReport message"""
    global difference
    msg_content = get_flow(flow_alias).get_message(message_alias)
    location_report_timestamp = msg_content.get_value_by_unique_key('timeStamp')
    print('RRCRelease occurrence NTP timestamp: ', rrc_release_timestamp)
    print('NTP timestamp inside NGAP: Location Report: ', location_report_timestamp)
    difference = int(location_report_timestamp, 16) - int(rrc_release_timestamp, 16)
    difference = abs(difference)
    print('Difference between timestamp inside NGAP: Location Report and RRCRelease occurence [s] : ', difference)
    assert difference <= 3
    return True


def get_difference_between_timestamp_inside_location_report_and_rrc_release_occurrence():
    return difference
