*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   common.robot


*** Keywords ***
COAM VDU Check Active Alarms
    [Arguments]   ${connection}=COAM_VDU
    ${active_alarms}   COAM VDU Get Active Alarms   connection=${connection}
    ${active_alarm_list}   Set Variable   ${active_alarms['alarms']}
    FOR   ${active_alarm_info}   IN   @{active_alarm_list}
        ${fault_id}   Set Variable   ${active_alarm_info['fault_id']}
        Run Keyword If   ${fault_id} not in ${ALLOWED_ACTIVE_FAULTS}   FAIL   msg=Unexpected Active Alarms.
    END


COAM VDU Check History Alarms
    [Arguments]   ${connection}=COAM_VDU
    ${CASE_START_TIMESTAMP}   Get Variable Value   ${CASE_PROCESS_START}
    ${history_alarms}   COAM VDU Get History Alarms   connection=${connection}
    ${history_alarm_list}   Set Variable   ${history_alarms['alarms']}
    FOR   ${history_alarm_info}   IN   @{history_alarm_list}
        ${isoutctime_list}   Get Regexp Matches      ${history_alarm_info['appear_time']}
        ...    \\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d
        ${isoutctime}   Set Variable   ${isoutctime_list[0]}
        ${status}   Run Keyword And Return Status
        ...   Should Match Regexp   ${isoutctime}   \\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d
        Continue For Loop If   not ${status}
        ${datetime}   DateTime.Convert Date   date=${isoutctime}   result_format=datetime   date_format=%Y-%m-%dT%H:%M:%S
        ${timestamp}   Evaluate   dateutil.parser.parse("${datetime.isoformat()}").timestamp()   dateutil.parser,dateutil
        Continue For Loop If    ${timestamp} < ${CASE_START_TIMESTAMP}
        ${fault_id}   Set Variable   ${history_alarm_info['fault_id']}
        Run Keyword If   ${fault_id} not in ${ALLOWED_HISTORY_FAULTS}   FAIL   msg=Unexpected Active Alarms.
    END


