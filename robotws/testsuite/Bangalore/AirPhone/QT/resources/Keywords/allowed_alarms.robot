*** Settings ***
Documentation     This contains keywords related to alarms
Library     BuiltIn
Library     OperatingSystem
Library     Collections
Library     String
Library     ute_admin_infomodel
Library     taf.sbts.oam.coam.admin   WITH NAME    coam

*** Variables ***
@{AP_ALLOWED_ALARMS}
...    4654    #Ethernet port security is disabled
...    4655    #Service account root access is enabled
...    61524   #SSH enabled
...    7300    #No X2 link available
...    61649   #LMP access via port 443
...    7523    #Cell Activation timeout at gNB-DU
...    7107    #Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...    7304    #NG SCTP endpoint broken
...    4592    #BTS Reset Cause
...    61652   #R&D Service Port enabled
...    7305    #NG SCTP setup fail
...    4681    #Sanity Check Error
...    2002    #Receiving failure in optical interface
...    4334    #Serial console activated
...    4657    #Nokia MN BTS SFP validation failure
...    4641    #SSH client authentication failure

*** Keywords ***
Check Alarms In Ims File
    [Arguments]  ${disconnect_infomodel}=True     ${name}=_    ${alias}=default    ${allowed_alarms}=${CLASSICAL_ALLOWED_ALARMS}
    ${timestamp}      Get Timestamp
    Save Infomodel Log  ${CURDIR}/${name}admin_infomodel_${timestamp}.ims2    timeout=300    alias=${alias}
    Check If Object Alarm_L Exist
    ${before_after}    set variable if    'before' in '${name}'    before
    ...    'all' in '${name}'    during whole
    ...    after
    ${alarms_after_test_status}=    Check Alarms in Test
    ...      ${CURDIR}/${name}admin_infomodel_${timestamp}.ims2
    ...      allowed_alarms=${allowed_alarms}
    ...      before_after=${before_after}
    ${msg}=  Catenate  Alarm: GPS receiver alarm: firmware upgrade ongoing --FaultId: 4420
    ${res_bool}=  Run Keyword And Return Status  Should Not Contain   ${alarms_ims}   ${msg}
    Run Keyword And Continue On Failure   Run Keyword If   '${res_bool}'=='False'    Wait Until Keyword Succeeds   6x   120s
    ...    Check if FID 4420 Exist
    Run Keyword If    '${alarms_after_test_status}'=='False' and '${before_after}'=='during whole'
    ...  Fail    msg=Not allowed alarms appeared. Test case has failed!
    Run Keyword If    '${alarms_after_test_status}'=='False' and '${before_after}'!='during whole'
    ...    Log    The alarms listed here occurs before gnb installation and so error is ignored!!!    console=True
    [Teardown]     Run Keyword if    ${disconnect_infomodel}    Run Keywords    Disconnect Infomodel    alias=${alias}
    ...            AND             Teardown Infomodel    alias=${alias}
    ...            ELSE            Reset Infomodel       alias=${alias}

Check Alarms In Ims File For Post Stability Test
    [Documentation]    This keyword use for AP_QT Stability Test
    ...                Modified Date: 03-April-2025
    ...                Last Modified by: dibyendu.samanta@nokia.com
    [Arguments]    ${disconnect_infomodel}=True    ${name}=_    ${alias}=default    ${allowed_alarms}=${CLASSICAL_ALLOWED_ALARMS}
    ${timestamp}      Get Timestamp
    Save Infomodel Log  ${CURDIR}/${name}admin_infomodel_${timestamp}.ims2    timeout=300    alias=${alias}
    Check If Object Alarm_L Exist
    ${before_after}    set variable if    'before' in '${name}'    before
    ...    'all' in '${name}'    during whole
    ...    after
    ${alarms_after_test_status}=    Check Alarms in Test
    ...      ${CURDIR}/${name}admin_infomodel_${timestamp}.ims2
    ...      allowed_alarms=${allowed_alarms}
    ...      before_after=${before_after}
    ${msg}=  Catenate  Alarm: GPS receiver alarm: firmware upgrade ongoing --FaultId: 4420
    ${res_bool}=  Run Keyword And Return Status  Should Not Contain   ${alarms_ims}   ${msg}
    Run Keyword And Continue On Failure   Run Keyword If   '${res_bool}'=='False'    Wait Until Keyword Succeeds   6x   120s
    ...    Check if FID 4420 Exist
    Run Keyword If    '${alarms_after_test_status}'=='False' and '${before_after}'=='during whole'
    ...  Fail    msg=Not allowed alarms appeared. Test case has failed!
    Run Keyword If    '${alarms_after_test_status}'=='False' and '${before_after}'!='during whole'
    ...    Log    The alarms listed here occurs before gnb installation and so error is ignored!!!    console=True
    [Teardown]     Run Keyword if    ${disconnect_infomodel}    Run Keywords    Disconnect Infomodel    alias=${alias}
    ...            AND             Teardown Infomodel    alias=${alias}
    ...            ELSE            Reset Infomodel       alias=${alias}

Check Alarms In Ims File For Pre Stability Test
    [Documentation]    This keyword use for AP_QT Stability Test
    ...                Modified Date: 03-April-2025
    ...                Last Modified by: dibyendu.samanta@nokia.com
    [Arguments]    ${disconnect_infomodel}=True     ${name}=_    ${alias}=default    ${allowed_alarms}=${CLASSICAL_ALLOWED_ALARMS}
    ${timestamp}      Get Timestamp
    Save Infomodel Log  ${CURDIR}/${name}admin_infomodel_${timestamp}.ims2    timeout=300    alias=${alias}
    Check If Object Alarm_L Exist
    ${before_after}    set variable if    'before' in '${name}'    before
    ...    'all' in '${name}'    during whole
    ...    after
    ${alarms_after_test_status}=    Check Alarms in Test
    ...      ${CURDIR}/${name}admin_infomodel_${timestamp}.ims2
    ...      allowed_alarms=${allowed_alarms}
    ...      before_after=${before_after}
    ${msg}=  Catenate  Alarm: GPS receiver alarm: firmware upgrade ongoing --FaultId: 4420
    ${res_bool}=  Run Keyword And Return Status  Should Not Contain   ${alarms_ims}   ${msg}
    Run Keyword And Continue On Failure   Run Keyword If   '${res_bool}'=='False'    Wait Until Keyword Succeeds   6x   120s
    ...    Check if FID 4420 Exist
    Run Keyword If    '${alarms_after_test_status}'=='False' and '${before_after}'=='during whole'
    ...  Fail    msg=Not allowed alarms appeared. Test case has failed!
    Run Keyword If    '${alarms_after_test_status}'=='False' and '${before_after}'!='during whole'
    ...    Log    The alarms listed here occurs before gnb installation and so error is ignored!!!    console=True
    Log To Console    ${disconnect_infomodel}

Setup And Connect IM
    [Arguments]  ${setup_timeout}=30  ${connect_timeout}=90    ${alias}=default
    Setup Infomodel      address=${GNB_ASIK.Ip}    port=443    admin_api_log_dir=${CURDIR}/ADMIN_INFOMODEL_API
    ...                  timeout=${setup_timeout}      alias=${alias}
    Connect Infomodel    timeout=${connect_timeout}    alias=${alias}

Read Ims File
    [Arguments]  ${IMS_FILE}  ${allowed_alarms}
    @{Not_allowed_alarms_ims}=  Create List
    @{alarms_ims}=  Create List
    Set Test Variable  @{Not_allowed_alarms_ims}
    Set Test Variable  @{alarms_ims}
    Run Keyword If  ${alarm_l_exists}  Set Test Variable  ${alarm_query}  //ALARM_L-*
    ...    ELSE IF  ${alarm_l_not_exist}  Set Test Variable  ${alarm_query}  //ALARM-*
    @{alarm_change_sets}=  Get Change Sets  ${IMS_FILE}  ${alarm_query}
    FOR   ${alarm_change_set}  IN  @{alarm_change_sets}
       Run Keyword If   '${alarm_change_set.action}' == 'Update' and '${alarm_query}' == '//ALARM_L-*'  Check Alarm_Query Allowed Alarms
       ...               alarm_query=${alarm_query}
       ...               allowed_alarms=${allowed_alarms}
       ...               list_of_alarms=${alarm_change_set}
       Run Keyword If   '${alarm_change_set.action}' == 'Update' and '${alarm_query}' == '//ALARM-*'    Check Alarm_Query Allowed Alarms
       ...               alarm_query=${alarm_query}
       ...               allowed_alarms=${allowed_alarms}
       ...               list_of_alarms=${alarm_change_set}
    END

Check If Object Alarm_L Exist
    ${alarm_l_exists}=  Run Keyword And Return Status  Query Infomodel  query=//ALARM_L-*  timeout=1
    ${alarm_l_not_exist}=  Run Keyword And Return Status  Query Infomodel  query=//ALARM-*  timeout=1
    Log  ${alarm_l_exists}
    Log  ${alarm_l_not_exist}
    BuiltIn.Set Global Variable    ${alarm_l_exists}
    BuiltIn.Set Global Variable    ${alarm_l_not_exist}

Check Alarms in Test
    [Arguments]  ${ims_file}  ${allowed_alarms}    ${before_after}
    Run Keyword If    '${CELL_BLOCK_UNBLOCK}' == 'True'    Read Ims File
    ...    ${ims_file}    ${AP_QT_ALLOWED_ALARMS}
    ...    ELSE    Read Ims File  ${ims_file}  ${allowed_alarms}
    Save Alarms To File  file_name=${CURDIR}/alarms_${before_after}_test.txt  list_of_alarms=@{alarms_ims}
    ${no_alarms}=  Run Keyword And Return Status  Should Be Empty  ${Not_allowed_alarms_ims}
    Run Keyword If  '${no_alarms}'=='False'    Run Keywords
    ...    Log To Console  \nNot allowed alarms ${before_after} test:
    ...    AND  List Not Allowed Alarms
    [Return]  ${no_alarms}

Check if FID 4420 Exist
    WA for coam connect    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${active_alarms}          coam.get_active_alarms    connection=coam_admin
    FOR    ${alarm}    IN    @{active_alarms}
       ${fault_id_final}    set variable if    '${alarm['faultId']}'=='N/A'    alarm_id    faultId
       ${fault_name_final}    set variable if    '${alarm['faultName']}'=='N/A'    alarm_name    faultName
       ${dict_fault_id}      Get From Dictionary       ${alarm}   ${fault_id_final}
       ${dict_fault_id}    Convert To String    ${dict_fault_id}
       ${bool_res}=  Run keyword and return status   should not be equal as integers   ${dict_fault_id}  4420
       Run Keyword If   '${bool_res}'=='False'  Run Keywords
       ...   Log To Console  -> GPS firmware upgrade is ongoing!
       ...   AND   should not be equal as integers   ${dict_fault_id}  4420
    END
    [Teardown]  Run Keyword and ignore error    coam.teardown    connection=coam_admin

List Not Allowed Alarms
    FOR  ${obj}  IN  @{Not_allowed_alarms_ims}
       Log   ${obj}   WARN
    END

Check Alarm_Query Allowed Alarms
    [Arguments]   ${alarm_query}   ${allowed_alarms}   ${list_of_alarms}
	${alarm_detail}    Set Variable If
	...    '${alarm_query}'=='//ALARM-*'      ${list_of_alarms.object.alarmText.alarmDetail}
    ...    '${alarm_query}'=='//ALARM_L-*'    ${list_of_alarms.object.alarmInformation.alarmText.alarmDetail}
	${faultId}         Set Variable If
	...    '${alarm_query}'=='//ALARM-*'      ${list_of_alarms.object.faultId}
    ...    '${alarm_query}'=='//ALARM_L-*'    ${list_of_alarms.object.alarmInformation.faultId}
	${alarm_source}    Set Variable If
	...    '${alarm_query}'=='//ALARM-*'      ${list_of_alarms.object.alarmingResourceDN}
    ...    '${alarm_query}'=='//ALARM_L-*'    ?
    ${alarm_supplAlarmInfo}    Set Variable If
    ...    '${faultId}' == '4681' and '${alarm_query}'=='//ALARM-*'
    ...     ${list_of_alarms.object.alarmText.alarmAdditionalInfo.supplAlarmInfo}
    ...    '${faultId}' == '4681' and '${alarm_query}'=='//ALARM_L-*'
    ...     ${list_of_alarms.object.additionalInformation.alarmText.alarmAdditionalInfo.supplAlarmInfo}
	${msg_2}=   Catenate  Alarm: ${alarm_detail}   --FaultId:  ${faultId}
	${msg}      Convert To String     ${list_of_alarms}
	${msg}      Get Regexp Matches    ${msg}     ([0-9\\-]+\\s[0-9\\:]+[0-9\\.]+)
    ${msg}=     Catenate  ${msg[0]}  Alarm:  ${list_of_alarms.object.alarmText.alarmDetail}  --FaultId:  ${list_of_alarms.object.faultId}
    ...                   --alarmingResource:  ${alarm_source}
    Append To List    ${alarms_ims}    ${msg_2}
    ${loop_status}=   Regexp Loop    ${faultId}    @{allowed_alarms}
    ${loop_status}=   Run Keyword If    '${loop_status}'=='FAIL' and '${faultId}' == '4681'
    ...    Run Keyword And Return Status     Should End With    ${alarm_supplAlarmInfo}    :{4}
    ...    ELSE IF    '${loop_status}'=='FAIL' and '${faultId}' == '4590'
    ...    Run Keyword And Return Status     Check Fault4590 Info    ${list_of_alarms}    ${alarm_query}
    ...    ELSE    Set Variable    ${loop_status}
    Run Keyword If    '${loop_status}'=='FAIL' or '${loop_status}'=='False'    Append To List    ${Not_allowed_alarms_ims}    ${msg}

Regexp Loop
    [Arguments]  ${input}  @{list}
    FOR   ${regex}   IN   @{list}
       ${regex}    Convert To String    ${regex}
       ${input}    Convert To String    ${input}
       ${check_regexp}  ${temp}=  Run Keyword And Ignore Error  Should Not Be Empty  ${regex}
       Run Keyword If  '${check_regexp}'=='FAIL'  Continue For Loop
       Log  \nregexp: ${regex}
       Log  current alarm: ${input}
       ${status_alarm}  ${value}=  Run Keyword And Ignore Error  Should Match Regexp  ${input}  ${regex}
       Run Keyword If  '${status_alarm}'=='FAIL'  Continue For Loop
       Run Keyword If  '${status_alarm}'=='PASS'  Exit For Loop
       Log  status alarm: ${status_alarm}
    END
    [Return]  ${status_alarm}

Check If Fid 10 Exist
    [Arguments]   @{Not_allowed_alarms_ims}
    FOR   ${alarm}   IN   @{Not_allowed_alarms_ims}
       ${fid_10}  ${value}=  Run Keyword And Ignore Error  Should Match Regexp  ${alarm}   .*Failure in optical interface --FaultId: 10.*
       Run Keyword If  '${fid_10}'=='FAIL'  Continue For Loop
       Run Keyword If  '${fid_10}'=='PASS'  Exit For Loop
       Log  status alarm: ${fid_10}
    END
    Set Global Variable  ${fid_10}

Save Alarms To File
    [Arguments]  ${file_name}  ${list_of_alarms}
    Create File  ${file_name}
    FOR   ${alarm}   IN   @{list_of_alarms}
       Append To File  ${file_name}  content=\t${alarm}\r\n
    END

Check Current Alarms
    [Arguments]  ${path}  ${allowed_alarms}
    ...          ${host}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    WA for coam connect    bts_host=${host}
    @{Actual_alarms_IM}=  Create List
    Check If Object Alarm_L Exist
    ${query_status}  @{temp_IM}=  Run Keyword And Ignore Error    coam.Get Alarms    connection=coam_admin    timeout=10
    Run Keyword If  '${query_status}'=='FAIL'  Append To List  ${Actual_alarms_IM}  No ALARM object available on BTS
    Run Keyword If  '${query_status}'=='PASS'  Loop If ALARM Exist  @{temp_IM}  ${Actual_alarms_IM}  ${path}  ${allowed_alarms}
    ...              BTS_alarms.txt  msg=Not allowed alarms
    [Teardown]       Run Keyword and ignore error    coam.teardown    connection=coam_admin

Loop If ALARM Exist
    [Arguments]  ${temp_IM}  ${Actual_alarms_IM}  ${path}  ${allowed_alarms}  ${actual_alarms_file}  ${msg}=Not allowed alarms before test
    FOR   ${object}   IN   @{temp_IM}
       ${msg1}=  Catenate  Alarm:  ${object['alarmInformation']['alarmDetail']}  --FaultId:  ${object['faultId']}
       Append To List  ${Actual_alarms_IM}  ${msg1}
    END
    Save Alarms To File  file_name=${path}/${actual_alarms_file}  list_of_alarms=@{Actual_alarms_IM}
    Check Allowed Alarms  allowed_alarms_filename=${allowed_alarms}  list_of_alarms=@{Actual_alarms_IM}  alarm_msg=${msg}

Check Allowed Alarms
    [Arguments]  ${allowed_alarms}  ${list_of_alarms}  ${alarm_msg}
    FOR   ${a}   IN   @{list_of_alarms}
       ${loop_status}=  Regexp Loop  ${a}  @{allowed_alarms}
       ${result}=  Run Keyword If  '${loop_status}'=='PASS'  Get Index From List  ${list_of_alarms}  ${a}
       Run Keyword If  '${loop_status}'=='PASS'  Remove From List  ${list_of_alarms}  ${result}
    END
    ${al_before_test_status}  ${value_petla}=  Run Keyword And Ignore Error  Should Be Empty  ${list_of_alarms}
    Run Keyword If  '${al_before_test_status}'=='FAIL'  Fail  msg=${alarm_msg}\n${list_of_alarms}.\n${Test NAME} test case has failed!

Get timestamp
    [Documentation]     Author: Ding Binmei HGZ_SG4
    ...                 Description: Get timestamp. Example return value is: 20181019073816
    @{time}             Get time    year month day hour min sec
    ${time_stamp}       Set variable    ${EMPTY}
    FOR    ${item}    IN    @{time}
        ${time_stamp}   Catenate    SEPARATOR=${EMPTY}    ${time_stamp}    ${item}
    END
    [Return]            ${time_stamp}

WA for coam connect
    [Documentation]   Switch to LMP ip if there is network issue on oam ip
    [Arguments]        ${bts_host}=${tl.gnbs[0].cu.oam_http_connection_details.addr}    ${time}=1min
    ${connect_status}=    Run Keyword and Return Status    Wait Until Keyword Succeeds    ${time}    15s    coam.connect to
    ...                bts_host=${bts_host}
    ...                update_interval=1000
    ...                name=coam_admin
    Run Keyword If   '${connect_status}' == 'False'    Run Keywords
    ...    Check Ping result    ${bts_host}
    ...    AND    Log    OAM mplane ip ping ok but TA connection failed, pls check!    WARN
    ...    AND    Wait Until Keyword Succeeds    1min    15s    coam.connect to
    ...                bts_host=192.168.255.129
    ...                update_interval=1000
    ...                name=coam_admin

Check Ping result
    [Documentation]   Check ping result of given ip
    [Arguments]    ${ip}
    ${rc}=    Run and return rc    ping ${ip} -c 10
    Should be True    ${rc}==0     Given ip ${ip} is not reachable!

Check Fault4590 Info
    [Arguments]    ${list_of_alarms}    ${alarm_query}
    ${info}    Set Variable If
    ...     '${alarm_query}'=='//ALARM-*'
    ...     ${list_of_alarms.object.alarmText.alarmAdditionalInfo.faultSignature.info}
    ...     '${alarm_query}'=='//ALARM_L-*'
    ...     ${list_of_alarms.object.alarmInformation.alarmText.alarmAdditionalInfo.info}
    Should Contain     ${info}    Unknown power reset.
