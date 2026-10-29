*** Settings ***
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/bts_states.robot

*** Variables ***
${LSS_IP}          10.5.20.200
${LSS_USERNAME}    coam
${LSS_PASSWORD}    zO&n1W*ktp7!
${RSYSLOG_PORT}    51001

*** Keywords ***
TC__LOGS__Remote_Syslog
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21513
    ...  ******************
    ...  Author: Mateusz Jelen
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2021-07-21 - https://jira3.ext.net.nokia.com/browse/TAT-21513 - test creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-16-05 - TAT-23140 - Change path to remote VM
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2022-08-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23582 - added steps checking remoteSyslogTransmissionStatus
    ...                 due to EDA 02482118
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 26.09.2023 - TAT-26158 - adapting new parameter name on 24R1
    ...  - 05.02.2024 - added KW Get External VM Password instead of hardcoded password.
    ...  - 02.05.2024 - change external VM to LSS, add random trainsmission duration, checking start/stop time, proprietary format and
    ...                 reset/change duration during transmission.

    Set Tags    CA-LOGS    OWNER-mateusz.jelen@nokia.com   AUTHOR-mateusz.jelen@nokia.com
    ...    MAINTAINER-jakub.ozierski@nokia.com   GROUP_IN_CHARGE-WRO_5_Oper

    Step 0: Preconditions
    Step1: Clean Rsyslog on LSS and Start Netcat Listen Process
    Step2: Set Remote Syslog Parameters And Start Transmission Using Format RFC5424
    Step3: Set Remote Syslog Parameters And Start Transmission Using Proprietary Format
    Step4: Check Rsyslog Is Restarted After BTS Reset
    Step5: Check Rsyslog Is Restarted After Changing Duration While Rsyslog is Ongoing
    Step6: Change Unrelated Parameter act8EpsBearers And Check That Remote Syslog Remains Deactivated
    Step7: Set Back act8EpsBearers To Initial Value And Check That Remote Syslog Remains Deactivated


Step 0: Preconditions
    Log    ${\n}Step0: Preconditions    console=${TRUE}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${TRBL_MNLENT_DISTNAME}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    Set Test Variable  ${TRBL_MNLENT_DISTNAME}
    Set Test Variable  ${actRemoteSyslogTransmission}  ${False}
    ${SW}  coam.Get Sw Version
    ${SW_version}  Get Substring  ${SW}  4  6
    Run Keyword If  ${SW_version}>=24  Set Test Variable   ${remoteSyslogServer}    remoteSyslogServerHost
    ...  ELSE   Set Test Variable   ${remoteSyslogServer}    remoteSyslogServerIPaddress
    ${RAND_SYSLOG_DURATION}=  Evaluate  random.randint(3, 10)  modules=random
    Set Test Variable  ${RAND_SYSLOG_DURATION}
    Log    Remote syslog duration will be set to ${RAND_SYSLOG_DURATION} minutes    console=${TRUE}
    Set Back Syslog Parameters

Step1: Clean Rsyslog on LSS and Start Netcat Listen Process
    Log  ${\n}Step1: Remove Rsyslog File If Exists On LSS and start Netcat listen process on port ${RSYSLOG_PORT}  console=${TRUE}
    Login To LSS
    Remove Rsyslog File If Exists On LSS
    SSHLibrary.Start Command    nc -lu ${RSYSLOG_PORT} > /tmp/syslogtest/${BTS_ID}_syslog.log
    Log    Saving remote syslog output on LSS to file /tmp/syslogtest/${BTS_ID}_syslog.log    console=${TRUE}

Step2: Set Remote Syslog Parameters And Start Transmission Using Format RFC5424
    Log  ${\n}Step2: Set Remote Syslog Parameters with RFC5424  console=${TRUE}

    Recommission With Rsyslog Parameters  Remote_Syslog_Parameters_on_rfc  RFC5424  ${RAND_SYSLOG_DURATION}
    Set Test Variable  ${actRemoteSyslogTransmission}  ${TRUE}

    Log    Waiting for syslog usageState=Busy    console=${True}
    Wait Until Keyword Succeeds  1m  15s  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/ASM-*/SYSLOG_L-1 is [stateInfo.usageState=Busy]
    ${remote_started}=    SSHLibrary.Execute Command    ls -l /tmp/syslogtest/${BTS_ID}_syslog.log
    Set Test Variable  ${remote_started}
    Check syslog start time
    Log  Remote syslog started. Waiting for transmission to finish.  console=${TRUE}
    Sleep  ${RAND_SYSLOG_DURATION} minutes
    Wait Until Keyword Succeeds  1m  15s  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/ASM-*/SYSLOG_L-1 is [stateInfo.usageState=Idle]
    ${Remote_stopped}=    SSHLibrary.Execute Command    ls -l /tmp/syslogtest/${BTS_ID}_syslog.log
    Set Test Variable  ${Remote_stopped}
    SSHLibrary.Execute Command    pkill nc
    Check Syslog Transmission Output And Time
    SSHLibrary.Get File  /tmp/syslogtest/${BTS_ID}_syslog.log  ${BTS Files}/step2_syslog.log
    Set Back Syslog Parameters

Step3: Set Remote Syslog Parameters And Start Transmission Using Proprietary Format
    Log  ${\n}Step3: Set Remote Syslog Parameters with Proprietary format  console=${TRUE}
    Remove Rsyslog File If Exists On LSS
    SSHLibrary.Start Command    nc -lu ${RSYSLOG_PORT} > /tmp/syslogtest/${BTS_ID}_syslog.log

    Recommission With Rsyslog Parameters  Remote_Syslog_Parameters_on_prop  Proprietary  ${RAND_SYSLOG_DURATION}
    Set Test Variable  ${actRemoteSyslogTransmission}  ${TRUE}

    Log    Waiting for syslog usageState=Busy    console=${True}
    Wait Until Keyword Succeeds  1m  15s  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/ASM-*/SYSLOG_L-1 is [stateInfo.usageState=Busy]
    ${remote_started}=    SSHLibrary.Execute Command    ls -l /tmp/syslogtest/${BTS_ID}_syslog.log
    Set Test Variable  ${remote_started}
    Check syslog start time
    Log  Remote syslog started. Waiting for transmission to finish.  console=${TRUE}
    Sleep  ${RAND_SYSLOG_DURATION} minutes
    Wait Until Keyword Succeeds  1m  15s  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/ASM-*/SYSLOG_L-1 is [stateInfo.usageState=Idle]
    ${Remote_stopped}=    SSHLibrary.Execute Command    ls -l /tmp/syslogtest/${BTS_ID}_syslog.log
    Set Test Variable  ${Remote_stopped}
    SSHLibrary.Execute Command    pkill nc
    Check Syslog Transmission Output And Time
    SSHLibrary.Get File  /tmp/syslogtest/${BTS_ID}_syslog.log  ${BTS Files}/step3_syslog.log
    Set Back Syslog Parameters

Step4: Check Rsyslog Is Restarted After BTS Reset
    Log    ${\n}Step4: Check Rsyslog Is Restarted After BTS Reset    console=${TRUE}
    Remove Rsyslog File If Exists On LSS
    SSHLibrary.Start Command    nc -lu ${RSYSLOG_PORT} > /tmp/syslogtest/${BTS_ID}_syslog.log

    Recommission With Rsyslog Parameters  Remote_Syslog_Parameters_on_reset  Proprietary  ${RAND_SYSLOG_DURATION}
    Set Test Variable  ${actRemoteSyslogTransmission}  ${TRUE}

    Log    Waiting for syslog usageState=Busy    console=${True}
    Wait Until Keyword Succeeds  1m  15s  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/ASM-*/SYSLOG_L-1 is [stateInfo.usageState=Busy]
    Log    Site reset ongoing    console=${True}
    coam.Reset Site
    SSHLibrary.Start Command    nc -lu ${RSYSLOG_PORT} > /tmp/syslogtest/${BTS_ID}_syslog.log
    Log    Waiting for syslog usageState=Busy    console=${True}
    Wait Until Keyword Succeeds  3m  15s  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/ASM-*/SYSLOG_L-1 is [stateInfo.usageState=Busy]
    ${remote_started}=    SSHLibrary.Execute Command    ls -l /tmp/syslogtest/${BTS_ID}_syslog.log
    Set Test Variable  ${remote_started}
    Check syslog start time
    Log  Remote syslog started. Waiting for transmission to finish.  console=${TRUE}
    Sleep  ${RAND_SYSLOG_DURATION} minutes
    Wait Until Keyword Succeeds  1m  15s  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/ASM-*/SYSLOG_L-1 is [stateInfo.usageState=Idle]
    ${Remote_stopped}=    SSHLibrary.Execute Command    ls -l /tmp/syslogtest/${BTS_ID}_syslog.log
    Set Test Variable  ${Remote_stopped}
    SSHLibrary.Execute Command    pkill nc
    Check Syslog Transmission Output And Time
    SSHLibrary.Get File  /tmp/syslogtest/${BTS_ID}_syslog.log  ${BTS Files}/step4_syslog.log
    Set Back Syslog Parameters

Step5: Check Rsyslog Is Restarted After Changing Duration While Rsyslog is Ongoing
    Log    ${\n}Step5: Check Rsyslog Is Restarted After Changing Duration While Rsyslog is Ongoing    console=${TRUE}
    Remove Rsyslog File If Exists On LSS
    SSHLibrary.Start Command    nc -lu ${RSYSLOG_PORT} > /tmp/syslogtest/${BTS_ID}_syslog.log
    Recommission With Rsyslog Parameters  Remote_Syslog_Parameters_on_duration_change  Proprietary  15
    Set Test Variable  ${actRemoteSyslogTransmission}  ${TRUE}

    Log    Waiting for syslog usageState=Busy    console=${True}
    Wait Until Keyword Succeeds  1m  15s  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/ASM-*/SYSLOG_L-1 is [stateInfo.usageState=Busy]

    Log    Changing remoteSyslogTransmitDuration    console=${TRUE}
    Recommission With Rsyslog Parameters  Remote_Syslog_Parameters_on_duration_change2  Proprietary  ${RAND_SYSLOG_DURATION}

    Log    Waiting for syslog usageState=Busy    console=${True}
    SSHLibrary.Start Command    nc -lu ${RSYSLOG_PORT} > /tmp/syslogtest/${BTS_ID}_syslog.log
    Wait Until Keyword Succeeds  1m  15s  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/ASM-*/SYSLOG_L-1 is [stateInfo.usageState=Busy]
    ${remote_started}=    SSHLibrary.Execute Command    ls -l /tmp/syslogtest/${BTS_ID}_syslog.log
    Set Test Variable  ${remote_started}
    Check syslog start time
    Log  Remote syslog started. Waiting for transmission to finish.  console=${TRUE}
    Sleep  ${RAND_SYSLOG_DURATION} minutes
    Wait Until Keyword Succeeds  1m  15s  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/ASM-*/SYSLOG_L-1 is [stateInfo.usageState=Idle]
    ${Remote_stopped}=    SSHLibrary.Execute Command    ls -l /tmp/syslogtest/${BTS_ID}_syslog.log
    Set Test Variable  ${Remote_stopped}
    SSHLibrary.Execute Command    pkill nc
    Check Syslog Transmission Output And Time
    SSHLibrary.Get File  /tmp/syslogtest/${BTS_ID}_syslog.log  ${BTS Files}/step5_syslog.log
    Set Back Syslog Parameters

Step6: Change Unrelated Parameter act8EpsBearers And Check That Remote Syslog Remains Deactivated
    Log    ${\n}Step6: Change Unrelated Parameter act8EpsBearers And Check That Remote Syslog Remains Deactivated    console=${TRUE}
    ${LNBTS_CONF}=    Query Infomodel    query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${BTS_ID}/LNBTS_A-${BTS_ID}
    set test variable    ${LNBTS_CONF}
    Run Keyword If    '${LNBTS_CONF.act8EpsBearers}' == 'False'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
    ...  parameter=act8EpsBearers
    ...  operation=update
    ...  value=true
    ...  skip_parameter_relation_errors=True
    ...  timeout=1200
    ...  AND  Log    Parameter act8EpsBearers changed from false to true    console=${TRUE}
    ...  ELSE    Run Keywords
    ...  coam.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
    ...  parameter=act8EpsBearers
    ...  operation=update
    ...  value=false
    ...  skip_parameter_relation_errors=True
    ...  timeout=1200
    ...  AND  Log    Parameter act8EpsBearers changed from true to false    console=${TRUE}
    Check If Remote Syslog Is Deactivated

Step7: Set Back act8EpsBearers To Initial Value And Check That Remote Syslog Remains Deactivated
    Log    ${\n}Step7: Set Back act8EpsBearers To Initial Value And Check That Remote Syslog Remains Deactivated    console=${TRUE}
    coam.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
    ...  parameter=act8EpsBearers
    ...  operation=update
    ...  value=${LNBTS_CONF.act8EpsBearers}
    ...  skip_parameter_relation_errors=True
    ...  timeout=1200
    Log    Parameter act8EpsBearers set back to ${LNBTS_CONF.act8EpsBearers}    console=${TRUE}
    Check If Remote Syslog Is Deactivated

Recommission With Rsyslog Parameters
    [Arguments]    ${deltaID}  ${remoteSyslogFormat}  ${remoteSyslogTransmitDuration}

    coam.Create Delta  ${deltaID}
    ${deltaDict}  Create Dictionary
    ...  list_name=remoteSyslogConfig
    ...  remoteSyslogDSCP=1
    ...  remoteSyslogFormat=${remoteSyslogFormat}
    ...  ${remoteSyslogServer}=${LSS_IP}
    ...  remoteSyslogServerPortNo=${RSYSLOG_PORT}
    ...  remoteSyslogTransmitDuration=${remoteSyslogTransmitDuration}
    ...  remoteSyslogTransportProtocol=UDP
    coam.Append Parameter Update To Delta
    ...  ${TRBL_MNLENT_DISTNAME}  actRemoteSyslogTransmission  true  delta_id=${deltaID}
    coam.Append Complex Item To Delta  ${TRBL_MNLENT_DISTNAME}    list_name=remoteSyslogConfig
    ...  &{deltaDict}  delta_id=${deltaID}
    coam.Get Delta  ${deltaID}
    coam.Save Delta  ${BTS Files}/${deltaID}.json  ${deltaID}
    coam.Perform Delta Recommissioning  ${BTS Files}/${deltaID}.json   skip_parameter_relation_errors=${TRUE}

Set Back Syslog Parameters
    ${Remote_Syslog_Parameters_delta_off}  Set Variable  Remote_Syslog_Parameters_off
    coam.Create Delta  ${Remote_Syslog_Parameters_delta_off}

    coam.Append Parameter Update To Delta
    ...  ${TRBL_MNLENT_DISTNAME}  actRemoteSyslogTransmission  false  delta_id=${Remote_Syslog_Parameters_delta_off}

    coam.Append Parameter Delete To Delta   ${TRBL_MNLENT_DISTNAME}    remoteSyslogConfig    delta_id=${Remote_Syslog_Parameters_delta_off}

    coam.Get Delta  ${Remote_Syslog_Parameters_delta_off}
    coam.Save Delta  ${BTS Files}/Remote_Syslog_Parameters_delta_off.json  ${Remote_Syslog_Parameters_delta_off}
    coam.Perform Delta Recommissioning  ${BTS Files}/Remote_Syslog_Parameters_delta_off.json   skip_parameter_relation_errors=${TRUE}
    Set Test Variable  ${actRemoteSyslogTransmission}  ${False}

Check If Remote Syslog Is Deactivated
    Log    Checking if remote syslog is deactivated    console=${TRUE}

    ${infomodel_path}  Set Variable  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/TRBLCADM_CONF_M-1/TRBLCADM_R-1
    ${Syslog_condition}=  Query Infomodel  check ${infomodel_path} is [remoteSyslogTransmissionStatus=false]    allow_negative_result=True
    Run Keyword If    '${Syslog_condition}' == 'True'
    ...  Log    remoteSyslogTransmissionStatus: false    console=${TRUE}
    ...  ELSE    Run Keywords
    ...  Log    remoteSyslogTransmissionStatus: true    console=${TRUE}    level=ERROR
    ...  AND    Fail    Parameter remoteSyslogTransmissionStatus value: True    console=${TRUE}

Login To LSS
    SSHLibrary.Open Connection    ${LSS_IP}
    SSHLibrary.Login    username=${LSS_USERNAME}    password=${LSS_PASSWORD}

Remove Rsyslog File If Exists On LSS
    SSHLibrary.Execute Command    rm /tmp/syslogtest/${BTS_ID}_syslog.log
    SSHLibrary.Execute Command    sudo iptables -F
    SSHLibrary.Execute Command    mkdir -p /tmp/syslogtest
    SSHLibrary.Execute Command    sudo chmod 777 /tmp/syslogtest
    ${rsyslog_present}=    SSHLibrary.Execute Command    ls -l /tmp/syslogtest/ | grep ${BTS_ID}_syslog.log
    Should Be Equal  ${EMPTY}  ${rsyslog_present}

Check Syslog Transmission Output And Time
    Log    Checking rsyslog transmission output size    console=${TRUE}
    ${syslog_size}=    SSHLibrary.Execute Command    du -hsb /tmp/syslogtest/${BTS_ID}_syslog.log
    ${syslog_size}=    Fetch From Left    ${syslog_size}    /
    Should Be True    ${syslog_size} > 0
    Log  Size of remote syslog is ${syslog_size} bytes  console=${TRUE}
    Check Syslog Stop Time
    Should not be equal as strings  '${Remote_stop_time}'  '${Remote_start_time}'  msg=Remote start time can't be equal to remote remote stop time
    Log    Start time: ${Remote_start_time}${\n}End time: ${Remote_stop_time}    console=${TRUE}
    ${file_content}    SSHLibrary.Execute Command    head -c 10000 /tmp/syslogtest/${BTS_ID}_syslog.log
    Should Not Be Empty    ${file_content}
    Log    /tmp/syslogtest/${BTS_ID}_syslog.log is not empty and contains prints    console=${TRUE}

Check Syslog Start Time
    [Documentation]
    ...  This KW check syslog start time

    ${Split}=   Split string      ${remote_started}   separator=\
    ${Remote_start_time}=   Get from list     ${Split}    7
    log    Remote syslog started at: ${Remote_start_time}
    Set Test Variable  ${Remote_start_time}

Check Syslog Stop Time
    [Documentation]
    ...  This KW check syslog stop time

    ${Split}=   Split string      ${Remote_stopped}   separator=\
    ${Remote_stop_time}=   Get from list     ${Split}    7
    log    Remote syslog stopped at: ${Remote_stop_time}
    Set Test Variable  ${Remote_stop_time}

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${TRUE}

    Run Keyword If  ${actRemoteSyslogTransmission}  Run Keywords
    ...  Log  Set Back Syslog Parameters    console=${TRUE}
    ...  AND  Set Back Syslog Parameters

    SSHLibrary.Execute Command    rm /tmp/syslogtest/${BTS_ID}_syslog.log
    SSHLibrary.Close All Connections

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
