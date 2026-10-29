*** Settings ***
Documentation
...  Tests for CB010415

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/LOGS_general.robot
Resource  ../resources/AIC_NetAct.robot
Library    taf.nms.netact     WITH NAME    netact
Library    taf.hw.fhgw.cli    WITH NAME    FHGW_SSH
Library    ../resources/python/utils.py
Library    SSHLibrary
Library     DateTime

Variables  ../resources/python/My_NetAct.py
#Variables  ../../common_resources/python_resources/common_variables.py

*** Variables ***

${FHGW_USERNAME}    toor4nsn
${FHGW_PASSWORD}    Fhgw@systeM!23


${alarm1}    70158  #  FILE SYSTEM USAGE OVER LIMIT
${alarm2}    165128    #  Diagnostic Check Error



${FILE SYSTEM USAGE OVER LIMIT}    dd if=/dev/zero of=/mnt/swm/dummy_file.bin bs=1G count=16
*** Keywords ***

TC__LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  DC failed with CP8
    ...  ******************
    ...  *AUTHOR*: dan.moldovan@nokia.com

    Set Tags  CA-WebEM  OWNER-dan.moldovan@nokia.com  AUTHOR-dan.moldovan@nokia.com    GROUP_IN_CHARGE-TIM_7_Vrf
    ...  PHASE-CRT  SW-SBTS25R1  FEATURE-CB10415-D


    Step 0: Precondition
    Step 1: Raise Alarm FILE SYSTEM USAGE OVER LIMIT
    Step 2: DC schedule

Step 0: Precondition
   [Documentation]
    ...   In this step Precond

    Log    \nStep 0: Precondition    console=${True}
#    ${date}  Get Current Date  result_format=datetime
#    Set Test Variable  ${START_TIME}  ${date}
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${start_time}
    Set Test Variable    ${alarm70158}    ${False}
#    Set Test Variable    ${TEST_RESULTS_DIR}  ${TEST_RESULTS_DIR}
    FHGW_SSH.Connect To    ip=${FHGW_IP}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}

#    ${FHGW_Exist}    Run Keyword And Return Status    Variable Should Exist    ${tl.gnbs[0].dus[0].fhgws[0]}
#    Run Keyword If        ${FHGW_Exist}    Run Keywords    Set Suite Variable    ${FHGW_IP}         ${tl.gnbs[0].dus[0].fhgws[0].ip}
#    ...    AND    Set Suite Variable    ${FHGW_USERNAME}   ${tl.gnbs[0].dus[0].fhgws[0].username}
#    ...    AND    Set Suite Variable    ${FHGW_PASSWORD}   ${tl.gnbs[0].dus[0].fhgws[0].password}


#    Create File        ${OUTPUT_DIR}/data_after_test.txt    ${EMPTY}
#    Check FHGW version
    FHGW Active Alarms Should Not Contain Alarm   ${alarm1}
#    FHGW Active Alarms Should Not Contain Alarm   ${alarm2}

#    Check if FaultID appeared on FHGW     165128    PLMN-PLMN/FHGW-138/MNL-1/TRBLCADM-1    False


Get time from FHGW
    [Documentation]
    ...   Get time from FHGW
    ${date_time}    FHGW_SSH.Execute    command=date +%F-%T    #connection=${alias}
    ${date_time_fhgw}    Strip String   ${date_time}    left    /r/n
    [Return]    ${date_time_fhgw}

Step 1: Raise Alarm FILE SYSTEM USAGE OVER LIMIT
   [Documentation]
    ...   In this step Raise Alarm 70158 FILE SYSTEM USAGE OVER LIMIT

    Log    \nStep1: Raise Alarm FILE SYSTEM USAGE OVER LIMIT    console=${True}

#    FHGW_SSH.Connect To    ip=${FHGW_IP138}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}

    ${ret_value_code}   Run keyword and return status    Ssh cmd FHGW    ${FILE SYSTEM USAGE OVER LIMIT}

    ${output}   FHGW_SSH.Execute   command=df -h /mnt/swm |awk '{print$5}'
    Should Contain      ${output}     100     ##because of:mnt/swm should be 100%

    FHGW Active Alarms Should Contain Alarm   ${alarm1}
    Set Test Variable    ${alarm70158}    ${True}

Step 2: DC schedule
    Log    \nStep 1: DC schedule    console=${True}

    DC schedule CheckTime Change    schedule_time=00:03:00
    Log to console    Sleep 5 min
    sleep    5m
    Log to console    Check if FaultID appeared on FHGW
    Check if FaultID appeared on FHGW and DC Nok result     165128    PLMN-PLMN/FHGW-${FHGW_id}/MNL-1/TRBLCADM-1


Add time to current time
    [Arguments]     ${time_to_add}

#    ${current_date}    AIC_NetAct.Generate Formatted Timestamp
    ${current_date}    Get time from FHGW
    ${current_date_plus}=     Add Time To Date    ${current_date}     ${time_to_add}   result_format=%H:%M:%S
    Log    current time is:${current_date} timeafter:${current_date_plus}   console=${True}
    Set test variable    ${schedule_time}    ${current_date_plus}

Ssh cmd FHGW
    [Arguments]   ${cmd}
    Run keyword and ignore error    FHGW_SSH.Execute   command=${cmd}



DC schedule CheckTime Change
    [Arguments]   ${schedule_time}
    Add time to current time   ${schedule_time}
    ${delta_plan_name_FHGW}    Set Variable    FHGW-${FHGW_id}-delta-plan

    #CM Upload
    NetAct CM Upload    dist_names=PLMN-PLMN/FHGW-${FHGW_id}/MNL-1/TRBLCADM-1

    ##CM Parameter Upload NOM Open API    ${integrated_ids_FHGW}
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_FHGW}    ${TEST_RESULTS_DIR}/${delta_plan_name_FHGW}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_FHGW}    ${TEST_RESULTS_DIR}/${delta_plan_name_FHGW}_backup_${timestamp}.xml


    Generate XML Plan    ${delta_plan_path_FHGW}    ${delta_plan_name_FHGW}    ${backup_delta_plan_path_FHGW}
    ...    PLMN-PLMN/FHGW-${FHGW_id}/MNL-1/TRBLCADM-1    checkTime    ${schedule_time}

    NetAct Import Plan    local_dir=${TEST_RESULTS_DIR}    file_name=${delta_plan_name_FHGW}_${timestamp}.xml
    ...    plan_name=${delta_plan_name_FHGW}_${timestamp}

    NetAct Provision Plan    plan_name=${delta_plan_name_FHGW}_${timestamp}    dist_names=PLMN-PLMN/FHGW-${FHGW_id}
    ...    backup_plan_name=${delta_plan_name_FHGW}_backup_${timestamp}    create_backup_plan=False    provisioning_operation=activate

#    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/FHGW-${FHGW_id}
#    ...    dist_name=PLMN-PLMN/FHGW-${FHGW_id}/MNL-1/TRBLCADM-1    checkTime=${checkTime}
    Log To Console    diagSnapDestinationValue Name update successfully!

DC schedule
    ${delta_plan_name_FHGW}    Set Variable    FHGW-${FHGW_id}-delta-plan
#    ${integrated_ids_FHGW}    Create List    FHGW-${FHGW_id}
    #CM Upload
    NetAct CM Upload    dist_names=PLMN-PLMN/FHGW-${FHGW_id}

    ##CM Parameter Upload NOM Open API    ${integrated_ids_FHGW}
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_FHGW}    ${TEST_RESULTS_DIR}/${delta_plan_name_FHGW}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_FHGW}    ${TEST_RESULTS_DIR}/${delta_plan_name_FHGW}_backup_${timestamp}.xml
#    ${fhgwName}    Generate Random OCFDN    FHGW-${FHGW_id}
#    Set Test Variable    ${fhgwName}   FHGW-${FHGW_id}-autotest1

    Set Test Variable    ${schedule_time}    16:30:00

#    Generate XML Plan   ${delta_plan_path_FHGW}    ${delta_plan_name_FHGW}_${timestamp}    ${backup_delta_plan_path_FHGW}
#    ...    PLMN-PLMN/FHGW-${FHGW_id}/MNL-1/TRBLCADM-1    diagnosticCheckSchedule/checkTime    ${schedule_time}

    Generate XML Plan   ${delta_plan_path_FHGW}    ${delta_plan_name_FHGW}    ${backup_delta_plan_path_FHGW}
    ...    PLMN-PLMN/FHGW-${FHGW_id}/MNL-1/TRBLCADM-1    diagSnapDestination    1



#    Generate XML Plan For Name Update    ${delta_plan_path_FHGW}    ${delta_plan_name_FHGW}    ${backup_delta_plan_path_FHGW}
#    ...    PLMN-PLMN/FHGW-${FHGW_id}    fhgwName    ${fhgwName}

    NetAct Import Plan    local_dir=${TEST_RESULTS_DIR}    file_name=${delta_plan_name_FHGW}_${timestamp}.xml
    ...    plan_name=${delta_plan_name_FHGW}_${timestamp}

    NetAct Provision Plan    plan_name=${delta_plan_name_FHGW}_${timestamp}    dist_names=PLMN-PLMN/FHGW-${FHGW_id}/MNL-1/TRBLCADM-1l
    ...    backup_plan_name=${delta_plan_name_FHGW}_backup_${timestamp}    create_backup_plan=True    provisioning_operation=activate

#    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/FHGW-${FHGW_id}
#    ...    dist_name=PLMN-PLMN/FHGW-${FHGW_id}/MNL-1/TRBLCADM-1     Diagnostic Check schedule/Structure 1/checkTime=${schedule_time}
#    Log To Console    FHGW Name update successfully!
#
#    NetAct Provision Plan    plan_name=${delta_plan_name_FHGW}_backup_${timestamp}    dist_names=PLMN-PLMN/FHGW-${FHGW_id}
#    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
#    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/FHGW-${FHGW_id}
#    ...    dist_name=PLMN-PLMN/FHGW-${FHGW_id}    fhgwName=${original_value}
#    Log To Console    FHGW Name recovery successfully!





Generate XML Plan
    [Arguments]   ${plan_path}     ${plan_name}    ${backup_plan_path}
    ...    ${distName}    ${param}    ${value}
    ${export_timestamp}    AIC_NetAct.Generate Formatted Timestamp
    ${output_actuals_file}    Set Variable     ${TEST_RESULTS_DIR}/actual_${export_timestamp}.xml

    #CM Export
    NetAct Export Plan    local_dir=${TEST_RESULTS_DIR}    file_name=actual_${export_timestamp}.xml
    ...    dist_names=${distName}    plan_name=${plan_name}    operation_type=actual
    ##CM Export Actual Configuration NOM Open API    ${integrated_ids}    ${output_actuals_file}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${output_actuals_file}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${distName}"]
    ${status}    ${current_value}    Run Keyword And Ignore Error   L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${distName}"]/p[@name="${param}"]
    ${original_value}    Set Variable If    '${status}'=='PASS'    ${current_value}    ${EMPTY}
    ${meta_version}   Set Variable    ${MO_items['version']}
    ${meta_class}    Set Variable    ${MO_items['class']}
    ${xml1}    Set Variable    <?xml version="1.0" encoding="UTF-8" standalone="yes"?><raml version="2.1" xmlns="raml21.xsd">
    ${xml2}    Set Variable    <cmData type="plan" scope="changes" name="${plan_name}"><header>
    ${xml3}    Set Variable    <log action="update" dateTime="2021-04-12T15:29:20+03:00">ModifyingMO</log></header>
    ${xml4}    Set Variable    <managedObject class="${meta_class}" version="${meta_version}" distName="${distName}" operation="update">
#    ${xml44}    Set Variable    <p name="diagSnapDestination">LSS</p>
    ${xml45}    Set Variable    <list name="diagnosticCheckSchedule">
    ${xml46}    Set Variable    <item>
    ${xml47}    Set Variable    <p name="checkDays">127</p>
    ${xml5}    Set Variable    <p name="${param}">${value}</p></item></list></managedObject></cmData></raml>
    ${xml6}    Set Variable    <cmData type="plan" scope="changes" name="${plan_name}_backup"><header>
    ${xml7}    Set Variable    <p name="${param}">${original_value}</p></item></list></managedObject></cmData></raml>
    ${xmlfile}    Set Variable    ${xml1}${xml2}${xml3}${xml4}${xml45}${xml46}${xml47}${xml5}
    ${backupxmlfile}    Set Variable    ${xml1}${xml6}${xml3}${xml4}${xml7}
    Create File    ${plan_path}    ${xmlfile}
    Create File    ${backup_plan_path}    ${backupxmlfile}
    Set Test Variable    ${original_value}

Check if FaultID appeared on FHGW
    [Arguments]   ${alarm_nr}     ${dn}    ${present}=True


	${time_from}=	Convert Date	${START_TIME}		result_format=datetime
    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime
    @{alarms}=    netact.Get Cleared Alarms    dist_name=${dn}     time_from=${time_from}		time_to=${time_to}   alias=None


    ${alarm_number}    Set variable    ${alarms[0]['specificProblem']}
    run keyword if    ${present} == True
    ...    should be equal as integers    ${alarm_number} 	${alarm_nr}
    ...    ELSE IF  ${present} == False    #not present
    ...    should not be equal as integers    ${alarm_number} 	${alarm_nr}

    Set Test variable    @{alarms_info}    @{alarms}

Check if FaultID appeared on FHGW and DC Nok result
    [Arguments]   ${alarm_nr}     ${dn}

    Check if FaultID appeared on FHGW     ${alarm_nr}     ${dn}

    ${result}    Set variable    ${alarms_info[0]['additionalText2']}
    Should Contain	${result}		NOK results:
    Should Contain	${result}		8     #DC error CP8
    Log   ${result}    console=${TRUE}

Check if FaultID 4681 appeared on NetAct
    Log    Step 3: Check if FaultID 4681 appeared on NetAct    console=${True}
    Sleep     60
    ${end_time}=    Get Current Date    result_format=datetime
    ${alarms}=    netact.Get Cleared Alarms    dist_name=PLMN-PLMN/MRBTS-1025   time_from=${start_time}
    ...                                 time_to=${end_time}    alias=None
    Log   ${alarms}    console=${TRUE}

    Set Test Variable  ${CONDITION_NOT_MET}  ${True}
    FOR  ${alarm}  IN  @{alarms}
      ${perceivedSeverity}=     Get From Dictionary    ${alarm}   perceivedSeverity
      ${additionalFaultID}=     Get From Dictionary    ${alarm}   additionalText3
      ${contains}    Run Keyword And Return Status
      ...    Should Contain    ${additionalFaultID}    additionalFaultID=4681
      ${DC_points_with_NOK_results}    Fetch From Right  ${additionalFaultID}  supplAlarmInfo=
      ${DC_points_with_NOK_results2}   Fetch From Left  ${DC_points_with_NOK_results}    .
      ${contains2}    Run Keyword And Return Status
      ...    Should Contain    ${DC_points_with_NOK_results2}    31
      Run Keyword If    '${contains}' == 'True' and '${contains2}' == 'True'    Run Keywords
      ...  Log    Fault 4681 was found on netact    console=${True}
      ...  AND    Set Test Variable  ${CONDITION_NOT_MET}  ${False}
      ...  AND    Exit For Loop
    END
    Run Keyword if    ${CONDITION_NOT_MET}   Set Test Failed    Fault 4681 was not found on netact.    ${True}

FHGW Active Alarms Should Not Contain Alarm
    [Arguments]   ${alarm_id}
    ${alarms}   FHGW Get Active Alarms
    list should not contain value  ${alarms}  ${alarm_id}

FHGW Active Alarms Should Contain Alarm
    [Arguments]   ${alarm_id}
    ${alarms}   FHGW Get Active Alarms
    list should contain value  ${alarms}  ${alarm_id}


FHGW Get Active Alarms
    [Documentation]  FHGW Get Acitve Alarms
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     master port configure dn list
    ...
    ...    Example
    ...    | ${dn_list} | FHGW Get ECpriMasterPortConfDNList |
    ...
#    ${alias}  Get Unique Id

#    FHGW_SSH.Connect To    ip=${FHGW_IP138}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}
#    ${out}   issh.Execute   command=fhgwcli alarms list active-detailed   check_result=${False}   alias=${alias}
#    ${out}  Strip Prompt  ${out}
    ${out}   FHGW_SSH.Execute   command=fhgwcli alarms list active-detailed |awk '{print$3}'
    ...  check_result=${False}   #alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${alarm_list}  Get Regexp Matches  ${out}  (\\d+)  1
    [Return]  ${alarm_list}

#Check FHGW version
##    [Tags]    FHGW_VERSION
#
#
#        FHGW_SSH.Connect To    ip=${FHGW_IP138}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}
#        ${output}=    FHGW_SSH.Execute    fhgwcli swm show status    check_result=${False}
#        ${is_cmd_not_supported}=    Run Keyword And Return Status    Should Contain    ${output}    is not a fhgwcli command
#        ${output}=     Run Keyword If    ${is_cmd_not_supported}
#        ...    FHGW_SSH.Execute    fhgwcli swm show node    check_result=${False}
#        ...    ELSE    Set Variable    ${output}
#        Log To Console      \nSW version:
#        log    \n${output}    console=true
#        ${FHGW_version}    Get Lines Containing String    ${output}    SW release    ignore_case=True
#        Append To File
#        ...    ${OUTPUT_DIR}/data_after_test.txt
#        ...    FHGW SW version: ${FHGW_version.replace('|', '').split()[-1].strip()}\n

Step3: Check Alarms In WebEM And Netact
    Log  \nStep3: Check alarms in WebEM and Netact  console=true
#    Verify RF Module Alarm In WebEM And Netact
    Verify Radio Autonomous Alarm In Webem And Netact

Verify Radio Autonomous Alarm In Webem And Netact
    Log  \nAlarms "${EXPECTED_FAULT_NAME_FIRST}" will be checked in Alarm History and should appear 3 times.  console=true
    ${no_of_alarms}  Set Variable  0
    ${historical_alarms}  vdu.Vdu Get Historical Alarms  sorted_by=appearTime  sort_order=desc  timeout=120s
    ${alarms}  Get From Dictionary  ${historical_alarms}  alarms
    FOR  ${alarm}  IN  @{alarms}
        ${alarm_time}  Replace String  ${alarm}[appear_time]  T  ${SPACE}
        ${time}  Fetch From Left  ${alarm_time}  +
        ${status_first_fault_name}  Run Keyword And Return Status
        ...  Should Contain  ${alarm}[fault_name]  ${EXPECTED_FAULT_NAME_FIRST}
        ${no_of_alarms}  Run Keyword If  '${time}' > '${START_TIME}' and ${status_first_fault_name}
        ...  Evaluate  ${no_of_alarms} + 1
        ...  ELSE
        ...  Continue For Loop
    END
    Run Keyword If  ${no_of_alarms} == 3
    ...  Log  "${EXPECTED_FAULT_NAME_FIRST}" is visible in alarms history in WebEM for ${no_of_alarms} times. [OK]  console=true
    ...  ELSE
    ...  Fail  "${EXPECTED_FAULT_NAME_FIRST}" is not visible in alarms history in WebEM.
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Fault Signature Of Alarm In WebEM  ${EXPECTED_FAULT_NAME_FIRST}
    ...  ${CATEGORY}
    ...  ${VDU_ACTIVE_SW_VERSION}
    ...  ${SCOPE}
    ...  ${RMOD_SN}
    ...  ${EXTRA_INFO}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Fault Signature Of Alarm In Netact  ${EXPECTED_FAULT_ID_FIRST}
    ...  ${START_TIME_NETACT}
    ...  ${CATEGORY}
    ...  ${SCOPE}
    ...  ${VDU_ACTIVE_SW_VERSION}
    ...  ${RMOD_SN}
    ...  ${EXTRA_INFO}
    Log  Fault ${EXPECTED_FAULT_ID_FIRST} "${EXPECTED_FAULT_NAME_FIRST}" is reported & cleared from NetAct.  console=true



Test Teardown
    [Documentation]
    ...   Teardown In this step Clear Alarm 70158 FILE SYSTEM USAGE OVER LIMIT

    Log    \nTeardown: Clear Alarm FILE SYSTEM USAGE OVER LIMIT    console=${True}

#    FHGW_SSH.Connect To    ip=${FHGW_IP138}    username=${FHGW_USERNAME}    password=${FHGW_PASSWORD}

    Run Keyword if    ${alarm70158}   FHGW_SSH.Execute   command=rm /mnt/swm/dummy_file.bin
    sleep    30

    ${output}   FHGW_SSH.Execute   command=df -h /mnt/swm |awk '{print$5}'
    Should Not Contain      ${output}     100     ##because of:mnt/swm should not be 100%

   wait until keyword succeeds    180    10    FHGW Active Alarms Should Not Contain Alarm     ${alarm1}

TC Setup
    Common VDU Setup
    Setup NetAct    ${netact}
#    AIC_NetAct.Get FHGW Id
#    VDU WebEM Setup
#
#
TC Teardown
#    Run Keyword If Test Failed
#    ...  Delete Actual Delta Plan Via WebEM
    Test Teardown
    Common VDU Teardown
    Logs To Rotta Copy

