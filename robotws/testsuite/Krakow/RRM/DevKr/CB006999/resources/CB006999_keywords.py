import logging
from ta_egate_cmd_parser import ta_egate_cmd_parser
from ta5g_egate.interface import ta5g_egate
from ta_messaging.message_flows import get_flow
from robot.api.deco import keyword


@keyword("Verify AMFStatusIndication payload with partial GUAMI")
def verify_partial_guami_asi_payload(flow_alias, message_alias, backup, timer_approach):
    msg = get_flow(flow_alias).get_message(message_alias)
    guami_list = msg.get_value_by_unique_key('UnavailableGUAMIList')
    assert len(guami_list) == 1
    msg = str(msg)

    if backup != '0':
        assert msg.count('backupAMFName') == 1
    else:
        assert msg.count('backupAMFName') == 0
    if timer_approach == 'on':
        assert msg.count('timerApproachForGUAMIRemoval') == 1
    else:
        assert msg.count('timerApproachForGUAMIRemoval') == 0


@keyword("Verify AMFStatusIndication payload with full GUAMI")
def verify_full_guami_asi_payload(flow_alias, message_alias, bkp1, ta1, bkp2, ta2):
    msg = get_flow(flow_alias).get_message(message_alias)
    guami_list = msg.get_value_by_unique_key('UnavailableGUAMIList')
    assert len(guami_list) == 2
    msg = str(msg)

    if bkp1 != '0' and bkp2 != '0':
        assert msg.count('backupAMFName') == 2
    elif (bkp1 == '0' and bkp2 != '0') or (bkp1 != '0' and bkp2 == '0'):
        assert msg.count('backupAMFName') == 1
    else:
        assert msg.count('backupAMFName') == 0
    if ta1 == 'on' and ta2 == 'on':
        assert msg.count('timerApproachForGUAMIRemoval') == 2
    elif (ta1 == 'on' and ta2 != 'on') or (ta1 != 'on' and ta2 == 'on'):
        assert msg.count('timerApproachForGUAMIRemoval') == 1
    else:
        assert msg.count('timerApproachForGUAMIRemoval') == 0
