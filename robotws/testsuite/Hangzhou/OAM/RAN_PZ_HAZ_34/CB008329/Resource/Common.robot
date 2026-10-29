*** Settings ***
Documentation
...  author: Nie Lei
...  contact: lei.nie@nokia-sbell.com
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh
Library     taf.selenium.sbts   WITH NAME   sbts
Library     SSHLibrary
Library     json
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/btslog_handle.py

Resource    ../../common/taf_coam.robot
Resource    ../../common/taf_log.robot
Resource    ../../common/qc_tag.robot
Resource    ../../common/gnb.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Variables   ../../libraries/global_vars.py

Resource   ../CaseResource/1_Netboot_Enable.robot
Resource   ../CaseResource/2_Detects_Missing_Files.robot
Resource   ../CaseResource/3_Scheduled_SC.robot


*** Variables ***
${SC_FLAG_ORG}
${SC_FLAG}

*** Keyword ***
Common Setup CB008329
    Log To Console   ${EMPTY}
    Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
    Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
    Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}

    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
    COAM Backup SCF
    COAM Backup Full SCF
    Get ALL Suite Variables
    # Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    # Run Keyword And Ignore Error   Start Syslog Collection

Get ALL Suite Variables
    Set Suite Variable   ${LOCAL_SSH_ADDR}   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Set Suite Variable   ${LOCAL_SSH_USER}   ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    Set Suite Variable   ${LOCAL_SSH_PWD}   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    Set Suite Variable   ${WEBEM_ADDR}   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
    Set Suite Variable   ${WEBEM_USERNAME}   ${tl.gnbs[0].cu.oam_http_connection_details.username}
    Set Suite Variable   ${WEBEM_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}


    ${SW_RELEASE}   COAM Get SW Release
    Set Suite Variable   ${SW_RELEASE}

    ${feature_flag}   Set Variable If
    ...   "${SW_RELEASE}"=="SBTS23R2" or "${SW_RELEASE}"=="SBTS23R3"   actSystemModuleSanityChecker
    ...   actDiagnosticCheck
    ${feature_schedule}   Set Variable If
    ...   "${SW_RELEASE}"=="SBTS23R2" or "${SW_RELEASE}"=="SBTS23R3"   sanityCheckSchedule
    ...   diagnosticCheckSchedule
    Set Suite Variable   ${FEATURE_FLAG}
    Set Suite Variable   ${FEATURE_SCHEDULE}


    csn.Connect To   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=LOCAL

    ${output}   csn.Execute   command=hostname   connection=LOCAL
    ${output}   Strip String   ${output}
    ${DUALCORE_HOST}   Set Variable If
    ...   '${output}'=='fct-0a'   fct-4a
    ...   '${output}'=='fct-4a'   fct-0a
    Set Suite Variable   ${DUALCORE_HOST}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=LOCAL




Common Teardown CB008329
    # Run Keyword And Ignore Error   Stop and Save Syslog Collection
    # Run Keyword And Ignore Error   Check Error Log From Syslog
    # Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Run keywords   Catch Snapshot COAM
    Run Keyword And Ignore Error   COAM Logout

Execute Command On gNB
    [Arguments]   ${command}
    ...           ${hostname}=${LOCAL_SSH_ADDR}
    ...           ${username}=${LOCAL_SSH_USER}
    ...           ${password}=${LOCAL_SSH_PWD}
    ...           ${alias}=LOCAL
    taf.transport.ssh.connect_to
    ...   hostname=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   alias=${alias}
    taf.transport.ssh.force reconnect
    ...    connection=${alias}
    ${reply}   Run Keyword And Return   taf.transport.ssh.execute
    ...   command=${command}
    ...   connection=${alias}
    [Teardown]   Run Keyword And Ignore Error   taf.transport.ssh.Disconnect   connection=${alias}
    [Return]   ${reply}

Trigger SC via Admin
    ${status}   Run Keyword And Return Status   coam.run_sanity_check   timeout=${500}   connection=COAM
    Run Keyword And Ignore Error   Run Keyword If   not ${status}   Run Keywords
    ...   Sleep   2m
    ...   AND
    ...   coam.run_sanity_check   timeout=${500}   connection=COAM

Trigger SC via WebEM
    Log To Console   "To be replaced while TAF KW ready"
    Login to WebEM
    ${status}   Run Keyword And Return Status   sbts.start_sanity_check
    Run Keyword If   '${status}'=='False'   Log To Console   "SC run failed"
    Wait Until Keyword Succeeds   2 min   10 sec   Get Sanity Check Results
    [Teardown]   Logout from WebEM

Get Sanity Check Results
    ${status}   sbts.check_sanity_status
    Should Not Contain   ${status}   Checking   ignore_case=True

Login to WebEM
    [Arguments]   ${timeout}=120
    ${timeout}=  Convert to number   ${timeout}
    ${browser}=  Set variable    Chrome
    sbts.enable_virtual_display
    sbts.login  url=https://${WEBEM_ADDR}
    ...        username=${WEBEM_USERNAME}
    ...        password=${WEBEM_PASSWORD}
    ...        timeout=${timeout}
    sbts.disable_message_box
    Run Keyword And Ignore Error  sbts.close_start_up_view_window    timeout=20
    sleep   10s

Logout from WebEM
    sbts.logout
    sbts.disable_virtual_display

Get SC Active Alarm
    ${active_alarms}   taf_coam.COAM Get Active Alarms
    ${supplAlarmInfo}   Set Variable   NONE
    ${severity}   Set Variable   NONE
    ${alarm_id}   Set Variable   NONE
    ${fault_id}   Set Variable   NONE
    FOR   ${alarm}   IN   @{active_alarms}
        Continue For Loop If   '${alarm['faultId']}'!='4681' or '${alarm['alarmId']}'!='7115'
        ${alarm_id}   Set Variable   ${alarm['alarmId']}
        ${fault_id}   Set Variable   ${alarm['faultId']}
        ${severity}   Set Variable   ${alarm['severity']}
        ${supplAlarmInfo}   Set Variable   ${alarm['supplAlarmInfo']}
        # ${supplAlarmInfo}   Get Regexp Matches   ${supplAlarmInfo}   {(.*)}
        # ${supplAlarmInfo}   Convert To String   ${supplAlarmInfo}
        Exit For Loop If   '${alarm['faultId']}'!='4681' or '${alarm['alarmId']}'!='7115'
    END
    [Return]   ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}

Disable SC Feature Flag
    ${sc_flag}    COAM Get Parameter Value
    ...   dist_name=${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=${FEATURE_FLAG}
    Run Keyword If   '${sc_flag}'!='false'   COAM Update Parameter
    ...   dist_name=${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=${FEATURE_FLAG}   value=false
    Set Suite Variable   ${SC_FLAG_ORG}   ${sc_flag}
    Set Suite Variable   ${SC_FLAG}   false

Enable SC Feature Flag
    ${sc_flag}    COAM Get Parameter Value
    ...   dist_name=${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=${FEATURE_FLAG}
    Run Keyword If   '${sc_flag}'!='true'   COAM Update Parameter
    ...   dist_name=${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=${FEATURE_FLAG}   value=true
    Set Suite Variable   ${SC_FLAG_ORG}   ${sc_flag}
    Set Suite Variable   ${SC_FLAG}   true

Restore SC Feature Flag
    Run Keyword If   '${SC_FLAG_ORG}'!='' and '${SC_FLAG_ORG}'!='${SC_FLAG}'
    ...   COAM Update Parameter
    ...   dist_name=${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=${FEATURE_FLAG}   value=${SC_FLAG_ORG}

Get SC Schedule Time
    ${timezone}   Set Variable If
    ...   "${SW_RELEASE}"=="SBTS23R2" or "${SW_RELEASE}"=="SBTS23R3"   0
    ...   8
    @{time}=   Get Time   hour min sec   UTC + ${timezone}h 2min 0s
    ${time_now}=   Catenate  SEPARATOR=:  ${time}[0]  ${time}[1]  ${time}[2]
    Log To Console   (${time_now})
    Set Suite Variable   ${SC_SCHEDULE_TIME}   [{"checkDays":127, "checkTime":"${time_now}"}]

Get SC Schedule Delta File
    Get SC Schedule Time
    ${delta}=   Catenate  SEPARATOR=   [
    ...   {"distName":"${MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1",
    ...   "operation":"update",
    ...   "parameters":[
    ...   {"parameterName":"${FEATURE_SCHEDULE}","value":${SC_SCHEDULE_TIME},"operation": "update"}
    ...   ]}]
    Set Suite Variable   ${SCHEDULE_DELTA}   ${delta}

Get SC Schedule Delete Delta File
    ${delta}=   Catenate  SEPARATOR=   [
    ...   {"distName":"${MRBTS}/MNL-1/MNLENT-1/TRBLCADM-1",
    ...   "operation":"update",
    ...   "parameters":[
    ...   {"parameterName":"${FEATURE_SCHEDULE}","operation": "delete"}
    ...   ]}]
    Set Suite Variable   ${SCHEDULE_DISA_DELTA}   ${delta}

Configure Scheduled SC
    Get SC Schedule Delta File
    Configure Delta Via Admin   ${SCHEDULE_DELTA}

Configure Delta Via Admin
    [Arguments]   ${delta}
    COAM Perform Delta Recommission   delta_file=${delta}   connection=COAM

Remove Configured Scheduled SC
    Run Keyword If   '${SC_FLAG}'=='false'
    ...   Run Keywords   Get SC Schedule Delete Delta File   AND
    ...   Configure Delta Via Admin   ${SCHEDULE_DISA_DELTA}

Check Fault In Blackbox Alarm
     ${blackbox_alarms}   Execute Command On gNB
     ...   command=cd /ffs/run/config/lifedata;cat blackbox_alarms
     @{alarms_split}=   Split String   ${blackbox_alarms}   \r\n
     FOR   ${alarm}   IN   @{alarms_split}
        ${status}   Run Keyword And Return Status   Should Contain   ${alarm}    4681
        Exit For Loop If   '${status}'=='True'
     END

Check Fault Not In Blackbox Alarm
     ${blackbox_alarms}   Execute Command On gNB
     ...   command=cd /ffs/run/config/lifedata;cat blackbox_alarms
     @{alarms_split}=   Split String   ${blackbox_alarms}   \r\n
     ${status}   Set Variable   True
     FOR   ${alarm}   IN   @{alarms_split}
        ${status}   Run Keyword And Return Status   Should Not Contain   ${alarm}    4681
        Exit For Loop If   '${status}'=='False'
     END
     Run Keyword If   '${status}'=='False'   Log To Console   "SC run failed"

Check SC Log From Syslog
    [Arguments]   ${syslog_path}=${ALL_SYSLOG_PATH}
    Log To Console   Start To Check Syslog Error.
    ${output}   OperatingSystem.Run
    ...   cat ${syslog_path} | grep -i "[SanityCheckMsgReceiver] isCheckerfailed = 0"
    ${status1}   Run Keyword And Return Status   Should Not Be Empty   ${output}
    ${output}   OperatingSystem.Run
    ...   cat ${syslog_path} | grep -i "Received StartSanityCheckResponse with operationstatus = 1"
    ${status2}   Run Keyword And Return Status   Should Not Be Empty   ${output}
    Run Keyword If   ${status1} and ${status2}   Fail
    Log To Console   Syslog Error Check Success.
