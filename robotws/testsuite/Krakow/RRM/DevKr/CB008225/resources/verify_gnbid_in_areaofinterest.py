import pprint
from ta_messaging.message_flows import get_flow as _get_flow


def verify_that_gNBId_corresponds_to_locationReportingReferenceID(message_alias, flow_alias, gnbid_value, ref_id):
    msg_content = _get_flow(flow_alias).get_message(message_alias)
    print('Got message content: \n{}'.format(pprint.pformat(msg_content)))
    configured_areas = msg_content.get_value_by_unique_key('areaOfInterestList')
    found = False
    for area in configured_areas:
        if 'areaOfInterestRANNodeList' in area:
            gnb_id_from_msg = area.get_value_by_unique_key('globalGNB-ID')['gNB-ID']['gNB-ID']
            ref_id_from_msg = area.get_value_by_unique_key('locationReportingReferenceID')
            if str(gnbid_value) == str(gnb_id_from_msg) and str(ref_id) == str(ref_id_from_msg):
                return
            else:
                found = True
                print('Found values, but not matching given: {} and {}\n{}'
                      .format(gnbid_value, ref_id, pprint.pformat(area)))
    if found is False:
        raise Exception('Not found any: {} in msg'.format("areaOfInterestRANNodeList"))
    raise Exception('None of found Ids are matching Ref Ids')
