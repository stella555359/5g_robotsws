*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${ONAP_IP}                   100.70.230.210                                                     # IP to connect to ONAP
${WORKER_IP}                 100.70.230.229                                                     # Any WORKER IP can be chosen (from ONAP)
${ONAP_USERNAME}             root                                                               # User name for ONAP connection (usually ubuntu)
${ONAP_PASSWORD}             arthur                                                             # Password for ONAP connection (usually ubuntu)
${ONAP_ALIAS}                onap_connection                                                    # Alias for ssh connection on ONAP
${FINGERPRINT}               02:23:56:0B:8E:7B:83:6B:FA:E1:28:A0:D9:B4:E6:60:9B:E2:3B:58:C9     # Fingerprint key for netconf ONAP configuration
${RECOMMISSIONING_TIMEOUT}   600                                                                # Timeout for recommissioning
${EXPECTED_FAULT_ID}         1400                                                               # Expected fault ids that will be checked by test
${EXPECTED_FAULT_NAME}       EAC_1                                                              # Expected fault names that will be checked by test
${EXPECTED_ALARM_ID}         7103                                                               # Expected alarm ids that will be checked by test
${EXPECTED_ALARM_NAME}       BASE STATION EXTERNAL ALARM NOTIFICATION                           # Expected alarm names that will be checked by test
@{SEVERITY}                  Minor  Major  Critical                                             # List of expected severities that will be checked

*** Keywords ***
TC__FM__E_Check_VES_alarm_events_and_compare_with_NetConf
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24377
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test is to check 3GPP notificationId and alarmId usage in alarm events sent on VES interface.
    ...  The notificationId and alarmId shall be included in alarm events sent on VES interface as well as it shall be included
    ...  in _3gpp-common-fm.yang <alarmRecords>.notificationId and <alarmRecords>.alarmId on O-RAN O1 NetConf interface.
    ...  In addition to that, BTS shall be able to support concurrent alarm upload operations (reading alarm list)
    ...  on O-RAN O1 Netconf interface and alarm reporting (sending notifications) on O-RAN O1 VES interface.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24377 - Initial TAT creation
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  *******************

    Set Tags    CA-FM    OWNER-lucian.ciurel@nokia.com    AUTHOR-laura.craciunel@nokia.com    MAINTAINER-laura.craciunel@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS23

    Step0: Set initial variables
    Step1: Configure VESENDPOINT and NetConf server
    Step2: Trigger EAC fault minor severity
    Step3: Trigger EAC fault major severity
    Step4: Trigger EAC fault critical severity
    Step5: Clear EAC fault

Step0: Set initial variables
    Log  Step0: Set initial variables.  console=true
    ${BTS_ID}  Admin Get BTS ID
    Set test variable  ${BTS_ID}
    ${current_date}  Get current date
    ${current_date}  Fetch from left  ${current_date}  ${SPACE}
    Set test variable  ${CURRENT_DATE}  ${current_date}
    Connect to ONAP  ${ONAP_IP}  ${ONAP_USERNAME}  ${ONAP_PASSWORD}  ${ONAP_ALIAS}

Step1: Configure VESENDPOINT and NetConf server
    Log  Step1: Configure VESENDPOINT and NetConf server.  console=true
    Log  Configure VES Endpoint.  console=true
    ${object}  coam.Get Managed Objects  MPLANEONAP_R
    ${status}  Run Keyword And Return Status  Should Be Empty  ${object}
    Run Keyword If  ${status}
    ...  Create MPLANEONAP object
    ...  ELSE
    ...  Delete and recreate MPLANEONAP object  ${RECOMMISSIONING_TIMEOUT}
    Add certificates to CMP object
    Add VESENDPOINT-ID  1
    VES Endpoint reference change  vesFaultCollectorEndpointDN  1
    Change parameter activateSendingFmEvents  true
    Log  Configure NetConf server on BTS.  console=true
    Configure NetConf sever  ${BTS_ID}  ${FINGERPRINT}
    Wait until keyword succeeds  ${RECOMMISSIONING_TIMEOUT}  30  Check modules and cells

Step2: Trigger EAC fault minor severity
    Log  Step2: Trigger EAC fault minor severity.  console=true
    Perform recommissioning with EAC plan  1  ${SEVERITY}[0]
    Check alarm status in WebEM  active  ${EXPECTED_FAULT_ID}  ${EXPECTED_FAULT_NAME}  ${EXPECTED_ALARM_ID}  ${EXPECTED_ALARM_NAME}  ${SEVERITY}[0]
    ${notifier}  Get alarm notifier from alarm in WebEM  ${EXPECTED_FAULT_ID}
    Set Test Variable  ${NOTIFIER}  ${notifier}
    ${btsObservationTime}  Get alarm btsObservationTime from alarm in WebEM  ${EXPECTED_FAULT_ID}

    Log  Check fault management event in the VES Endpoint.  console=true
    ${first_event}  Get VES Event With Given Text  notifyNewAlarm  ${CURRENT_DATE}
    ${first_notification_id}  Set Variable  ${first_event['event']['stndDefinedFields']['data']['notificationId']}
    Set Test Variable  ${FIRST_ID}  ${first_notification_id}
    ${first_event_id}  Set Variable  ${first_event['event']['stndDefinedFields']['data']['alarmId']}
    Log  Notification id of alarm on VES endpoint is: ${FIRST_ID}.  console=true
    Log  Alarm id of alarm on VES endpoint is: ${first_event_id}.  console=true
    Check alarmId format  ${first_event_id}  ${EXPECTED_FAULT_ID}  ${EXPECTED_ALARM_ID}  ${CURRENT_DATE}  ${NOTIFIER}  ${btsObservationTime}

    Check if netconf server is running
    Log  Check fault management event on NetConf interface.  console=true
    ${alarmRecords}  Get AlarmList on Netconf  ${BTS_ID}  ${MPLANE_IP}  ${WORKER_IP}
    ${record_alarm_id}  ${record_notificationid}  Get alarmId and notificationId for specific alarm from alarmRecords
    ...  ${alarmRecords}  ${EXPECTED_ALARM_ID}_${EXPECTED_FAULT_ID}
    Log  Notification id of alarm on NetConf interface is: ${record_notificationid}.  console=true
    Log  Alarm id of alarm NetConf interface is: ${record_alarm_id}.  console=true
    Check alarmId format  ${record_alarm_id}  ${EXPECTED_FAULT_ID}  ${EXPECTED_ALARM_ID}  ${CURRENT_DATE}  ${NOTIFIER}  ${btsObservationTime}
    Log  Comparing notification ids beetween VES and NetConf.  console=true
    Compare notification ids   ${FIRST_ID}  ${record_notificationid}  Should Be Equal As Integers

Step3: Trigger EAC fault major severity
    Log  Step3: Trigger EAC fault major severity.  console=true
    Perform recommissioning with EAC plan  2  ${SEVERITY}[1]
    Check alarm status in WebEM  active  ${EXPECTED_FAULT_ID}  ${EXPECTED_FAULT_NAME}  ${EXPECTED_ALARM_ID}  ${EXPECTED_ALARM_NAME}  ${SEVERITY}[1]
    ${btsObservationTime}  Get alarm btsObservationTime from alarm in WebEM  ${EXPECTED_FAULT_ID}

    Log  Check fault management event in the VES Endpoint.  console=true
    ${second_event}  Get VES Event With Given Text  notifyChangedAlarmGeneral  ${CURRENT_DATE}
    ${second_notification_id}  Set Variable  ${second_event['event']['stndDefinedFields']['data']['notificationId']}
    Set Test Variable  ${SECOND_ID}  ${second_notification_id}
    ${second_event_id}  Set Variable  ${second_event['event']['stndDefinedFields']['data']['alarmId']}
    Log  Notification id of alarm on VES endpoint is: ${SECOND_ID}.  console=true
    Log  Alarm id of alarm on VES endpoint is: ${second_event_id}.  console=true
    Check alarmId format  ${second_event_id}  ${EXPECTED_FAULT_ID}  ${EXPECTED_ALARM_ID}  ${CURRENT_DATE}  ${NOTIFIER}  ${btsObservationTime}
    Compare notification ids  ${FIRST_ID}  ${SECOND_ID}  Should Not Be Equal As Integers

Step4: Trigger EAC fault critical severity
    Log  Step4: Trigger EAC fault critical severity.  console=true
    Perform recommissioning with EAC plan  3  ${SEVERITY}[2]
    Check alarm status in WebEM  active  ${EXPECTED_FAULT_ID}  ${EXPECTED_FAULT_NAME}  ${EXPECTED_ALARM_ID}  ${EXPECTED_ALARM_NAME}  ${SEVERITY}[2]
    ${btsObservationTime}  Get alarm btsObservationTime from alarm in WebEM  ${EXPECTED_FAULT_ID}

    Log  Check fault management event in the VES Endpoint.  console=true
    ${third_event}  Get VES Event With Given Text  notifyChangedAlarmGeneral  ${CURRENT_DATE}
    ${third_notification_id}  Set Variable  ${third_event['event']['stndDefinedFields']['data']['notificationId']}
    Set Test Variable  ${THIRD_ID}  ${third_notification_id}
    ${third_event_id}  Set Variable  ${third_event['event']['stndDefinedFields']['data']['alarmId']}
    Log  Notification id of alarm on VES endpoint is: ${THIRD_ID}.  console=true
    Log  Alarm id of alarm on VES endpoint is: ${third_event_id}.  console=true
    Check alarmId format  ${third_event_id}  ${EXPECTED_FAULT_ID}  ${EXPECTED_ALARM_ID}  ${CURRENT_DATE}  ${NOTIFIER}  ${btsObservationTime}
    Compare notification ids  ${SECOND_ID}  ${THIRD_ID}  Should Not Be Equal As Integers

Step5: Clear EAC fault
    Log  Step5: Clear EAC fault.  console=true
    Perform recommissioning to clear EAC fault
    Check alarm status in WebEM  inactive  ${EXPECTED_FAULT_ID}  ${EXPECTED_FAULT_NAME}  ${EXPECTED_ALARM_ID}  ${EXPECTED_ALARM_NAME}  ${SEVERITY}[2]
    Log  Check fault management event in the VES Endpoint.  console=true
    ${fourth_event}  Get VES Event With Given Text  notifyClearedAlarm  ${CURRENT_DATE}
    ${fourth_notification_id}  Set Variable  ${fourth_event['event']['stndDefinedFields']['data']['notificationId']}
    Set Test Variable  ${FOURTH_ID}  ${fourth_notification_id}
    ${fourth_event_id}  Set Variable  ${fourth_event['event']['stndDefinedFields']['data']['alarmId']}
    Log  Notification id of alarm on VES endpoint is: ${FOURTH_ID}.  console=true
    Log  Alarm id of alarm on VES endpoint is: ${fourth_event_id}.  console=true
    Compare notification ids  ${THIRD_ID}  ${FOURTH_ID}  Should Not Be Equal As Integers

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Step5: Clear EAC fault
    Common Test Teardown
