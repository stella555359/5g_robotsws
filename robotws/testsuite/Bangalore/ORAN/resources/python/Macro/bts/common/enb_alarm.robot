*** Settings ***

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.alarm.EnbAlarm    WITH NAME      enbalarm



*** Keywords ***
Verify Alarm is Active on eNB
    [Arguments]    ${alarm_id}    ${enb_id}=0  ${du_id}=${0}
    [Documentation]    Verify alarm is active.
    ...     :param alarm_id:   Id of alarm.
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enbalarm.verify_alarm_is_active    alarm_id=${alarm_id}    bts_id=${enb_id}  du_id=${du_id}

Verify Alarm is not Active on eNB
    [Arguments]    ${alarm_id}    ${enb_id}=0  ${du_id}=${0}
    [Documentation]    Verify alarm is not active.
    ...     :param alarm_id:   Id of alarm.
    ...     :param enb_id:    ENB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    enbalarm.verify_alarm_is_not_active    alarm_id=${alarm_id}    bts_id=${enb_id}  du_id=${du_id}
