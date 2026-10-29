*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${REPEAT_TIME}    10
${COMMISSIONING_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${ALARMS_BEFORE_TEST}    ${EMPTY}
${ALALRMS_AFTER_TEST}    ${EMPTY}
${REPEAT_TESTING_FAIL}    False
@{IGNORE_ALARM_FILTER_STRING}    {'faultId':61649}
${SKIP_PARAM_RELATION_ERRORS}    True
${test_data}    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/EDA02548333_Locking_para.yaml

*** Keywords ***
SyVe_CM_Repeat_Cells_Unlock_And_Plan_Operation_from_Locked_Startup_State
    [Documentation]    [CASE MRT]: RAN_SyVe_BTS start up with lock cells then perform plan operations after unlock
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    This case is designed to verify plan operations after cell unlocking with BTS start up with locked cells as precondition.
    ...    This is an EDA action for 02548333
    ...    The main steps performed for the test are:
    ...    . Select RAT To Lock And Rest Site
    ...    . Unlock All Cells Of Selected RAT
    ...    . Random Select Param And Create Plan For Cell Locking
    ...    . Check Modified Parameter After Provision
    ...    . Provision Plan And Check Locking State
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.11.2022 - Kang Lixin - New case

    Set Tags    CM    AUTHOR-lixin.kang@nokia-sbell.com     OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    ${REPEAT_TIME}    Evaluate    int(${REPEAT_TIME})
    ${failed_loops}    Create List
    FOR    ${index}    IN RANGE    1    ${REPEAT_TIME+1}
        Restart Infomodel And Syslog
        Set Test Variable    ${current_loop_index}    ${index}
        ${status}    Run Keyword And Return Status    Unlock Cells From Locked State And Update Cell Parameter
        Run Keyword If    not ${status}    Run Keywords
        ...    Log    Scenario failed at Loop${current_loop_index}    console=${True}    level=ERROR
        ...    AND    Append To List    ${failed_loops}    ${current_loop_index}
        ...    AND    LoopTearDown
        ...    AND    Set Test Variable    ${REPEAT_TESTING_FAIL}    True
        ...    AND    Continue For Loop
    END
    Run Keyword If    ${REPEAT_TESTING_FAIL}    Fail    Repeat testing failed at loop @{failed_loops}!

Unlock Cells From Locked State And Update Cell Parameter
    Step 0: Select RAT To Lock And Rest Site
    Step 1: Unlock All Cells Of Selected RAT
    Step 2: Random Select Param And Create Plan For Cell Locking
    Step 3: Provision Plan And Check Locking State
    Step 4: Check Modified Parameter After Provision
    Step 5: Provision the backup plan

Step ${index}: Select RAT To Lock And Rest Site
    Log To Console    Step ${index}: Select RAT To Lock And Rest Site
    ${tech}    Create List
    Run Keyword If    ${NRBTS_cell_ids}     Append To List    ${tech}    nr
    Run Keyword If    ${LTE_cell_ids}    Append To List    ${tech}    lte
    ${copy_tech}    Set Variable    ${tech}
    ${selected_rat}    Evaluate    random.choice(${tech})    modules=random, sys
    ${tech_cell}    Set Variable If    '${selected_rat}'=='nr'    NRCEL    LNCEL
    ${tech}    Set Variable If    '${selected_rat}'=='nr'    NR    LTE
    ${unlocked_status}    Set Variable If    '${selected_rat}'=='lte'    1    2
    Remove Values From List   ${copy_tech}    ${selected_rat}
    Set Test Variable    ${unlocked_status}
    Set Test Variable    ${tech}
    Set Test Variable    ${remain_tech}    ${copy_tech}
    Set Test Variable    ${tech_cell}
    ${all_cell_list}    coam.Get Cell List
    ${tech_cell_list}    Set Variable    ${all_cell_list['cells']['${selected_rat}']}
    ${selected_cell_list}    Create List
    ${selected_cell_id_list}    Create List
    FOR    ${item}    IN     @{tech_cell_list}
        Append To List    ${selected_cell_list}     ${item['id']['configuration']}
        Append To List    ${selected_cell_id_list}     ${item['id']['internal']}
    END
    Set Test Variable    ${selected_cell_list}
    Set Test Variable    ${selected_cell_id_list}
    coam.Lock    technology=${tech}    timeout=180
    coam.Reset    timeout=1200
    Wait Until Keyword Succeeds    20m    30s    Check SBTS Online
    coam.Assert Every    ${tech_cell}    ${cells_${tech}_locked_state}

Check SBTS Online
    ${sm}    ${smods_statuses}    Check If All Objects Are Online    SMOD    ${timeout}
    ${rm}    ${rmods_statuses}    Check If All Objects Are Online    RMOD    ${timeout}
    ${g_online}    ${gcells_statuses}    Check If All Objects Are Online    GNCEL    ${timeout}    ${False}
    ...    administrativeState=${_Com_Unlocked_}    blockingState=${_Unblocked_}    operationalState=${_Enabled_}
    ${w_online}    ${wcells_statuses}    Check If All Objects Are Online    WNCEL    ${timeout}    ${False}
    ...    blockingState=${_Unblocked_}    operationalState=${_Enabled_}
    Should Be True    "${sm}"=="PASS" and "${rm}"=="PASS" and "${g_online}"=="PASS" and "${w_online}"=="PASS"
    ...    Not all conditions were satisfied!
    FOR    ${item}    IN    @{remain_tech}
        ${btsinfo_list}    coam.Get Bts Info
        ${rat_status}    Set Variable    ${btsinfo_list['ratState']['${item}']}
        Should Be Equal As Strings    ${rat_status}    ALL_ENABLED
    END

Step ${index}: Random Select Param And Create Plan For Cell Locking
    Log To Console    Step ${index}: Random Select Param And Create Plan For Cell Locking
    ${TEST_DATA}    Load And Convert Json File    ${test_data}
    ${params_values}    Set Variable    ${TEST_DATA["${tech}"]}
    ${params}    Get Dictionary Keys  ${params_values}
    ${selected_param}    Evaluate    random.choice(${params})    modules=random, sys
    ${selected_cell}    Evaluate    random.choice(${selected_cell_list})    modules=random, sys
    Set Test Variable    ${selected_cell}
    ${id_mapping}    Fetch ID Mapping From Admin For Cells    identifier=${selected_cell}    identifier_type=configuration
    Set Test Variable    ${selected_cell_id}    ${id_mapping['internal']}
    ${current_value}     Get Actual Parameter Value From NetAct    PLMN-PLMN/${selected_cell}    ${selected_param}    true
    ${values}    Set Variable    ${params_values["${selected_param}"]}
    Remove Values From List    ${values}    ${current_value}
    ${selected_value}    Evaluate    random.choice(${values})    modules=random, sys
    ${param_dic}    Create Dictionary    ${selected_param}=${selected_value}
    Set Test Variable    ${param_dic}
    Create And Export NetAct Plan

Create And Export NetAct Plan
    Log To Console    Create And Export NetAct Plan
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=PLMN-PLMN/${selected_cell}   scf_distName=${selected_cell}    &{param_dic}
    Set Test Variable    ${plan}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Generate XML Plan For Cell Unlock
    [Arguments]   ${plan_path}     ${plan_name}
    Set Test Variable    ${xml_mo_param}    ${EMPTY}
    FOR    ${cell}    IN    @{selected_cell_list}
        Import Library    XML    use_lxml=True    WITH NAME    L_XML
        ${scf_xml}     L_XML.Parse xml    ${BTS_scf_initial}
        ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${cell}"]
        ${xml_mo}    Set Variable
        ...    <managedObject class="${MO_items['class']}" version="${MO_items['version']}" distName="PLMN-PLMN/${cell}" operation="update">
        ${xml_param}    Set Variable
        ...    <p name="administrativeState">${unlocked_status}</p></managedObject>
        ${xml_mo_param}    Set Variable    ${xml_mo}${xml_param}${xml_mo_param}
    END
    ${xml1}    Set Variable    <?xml version="1.0" encoding="UTF-8" standalone="yes"?><raml version="2.1" xmlns="raml21.xsd">
    ${xml2}    Set Variable    <cmData type="plan" scope="changes" name="${plan_name}"><header>
    ${xml3}    Set Variable    <log action="update" dateTime="2021-04-12T15:29:20+03:00">ModifyingMO</log></header>
    ${xml4}    Set Variable    <cmData type="plan" scope="changes" name="${plan_name}_backup"><header>
    ${xml5}    Set Variable    </cmData></raml>
    ${xmlfile}    Set Variable    ${xml1}${xml2}${xml3}${xml_mo_param}${xml5}
    Create File    ${plan_path}    ${xmlfile}

Generate And Import Plan SyVe
    Log To Console   Generate And Import Plan SyVe
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    Generate XML Plan For Cell Unlock    ${Test Results Dir}/NetActLogs/unlock_cells.xml    ${name}
    ${file_name}    Fetch From Right    ${plan_path}    /
    ${file_path}    Remove String    ${plan_path}    /${file_name}
    NetAct Import Plan    local_dir=${Test Results Dir}/NetActLogs/    file_name=unlock_cells.xml    plan_name=${name}

Step ${index}: Unlock All Cells Of Selected RAT
    Log To Console   Step ${index}: Unlock All Cells Of Selected RAT
    Check Alarm Before Test
    Generate And Import Plan SyVe
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    3m    5s  coam.Assert Every    ${tech_cell}    ${cells_${tech}_expected_state}

Step ${index}: Provision Plan And Check Locking State
    Log To Console   Step ${index}: Provision Plan And Check Locking State
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
     ${cmd1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true
    ${cmd2}    Set Variable    -backupPlanName ${name}_backup -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    Log    Check Action    console=True
    ${result}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    60
        sleep    3s
        ${result_tmp}    Run Keyword and Return Status    coam.Assert    ${tech_cell}    ${selected_cell_id}    ${cells_${tech}_offline_state}
        ${result}    Set Variable If    ${result}    ${result}    ${result_tmp}
        Check Other Objects On Air
    END
    Should Be True    ${result}
    FOR    ${index}    IN RANGE    0    60
        sleep    3s
        ${result_tmp}    Run Keyword and Return Status    coam.Assert    ${tech_cell}    ${selected_cell_id}    ${cells_${tech}_expected_state}
        ${result}    Set Variable    ${result_tmp}
        Check Other Objects On Air
        Exit For Loop If    ${result_tmp}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    ${provision_result}    Run Keyword And Return Status    Should Contain    ${result_Activate}    Provision of the plan was successful
    Should Be True    ${result} and ${provision_result}
    Check Alarm After Test

Step ${index}: Check Modified Parameter After Provision
    Log To Console   Step ${index}: Check Modified Parameter After Provision
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${selected_cell}    ui_values=false    &{param_dic}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Check Other Objects On Air
    Remove Values From List    ${selected_cell_id_list}    ${selected_cell_id}
    FOR    ${item}    IN    @{selected_cell_id_list}
        coam.Assert    ${tech_cell}    ${item}    ${cells_${tech}_expected_state}
    END
    ${gncell_onair}    Run Keyword If    ${GSM_cell_ids}    Run Keyword And Return Status    coam.Assert Every    GNCEL
    ...    ${cells_GSM_expected_state}
    ${wncell_onair}    Run Keyword If    ${WCDMA_cell_ids}    Run Keyword And Return Status    coam.Assert Every    WNCEL
    ...    ${cells_WCDMA_expected_state}
    Run Keyword If    ${GSM_cell_ids}    Should Be True    ${gncell_onair}
    Run Keyword If    ${WCDMA_cell_ids}   Should Be True    ${wncell_onair}
    FOR    ${item}    IN    @{remain_tech}
        ${btsinfo_list}    coam.Get Bts Info
        ${rat_status}    Set Variable    ${btsinfo_list['ratState']['${item}']}
        Should Be Equal As Strings    ${rat_status}    ALL_ENABLED
    END

Collect Infomodel With Timestamp
    Log To Console   IMS log will be collected
    ${timestamp}    Generate Formatted Timestamp
    ${ims_collected}=  Run keyword And Return Status    Save Infomodel Log
    ...    filename=${BTS Files}/IM/Loop${current_loop_index}_InfoModel_log_${timestamp}.ims2    timeout=300
    Run keyword if  ${ims_collected}  Log    IMS collected to 'BTS Files'  level=INFO  console=${TRUE}
    ...  ELSE  Log    IMS collection failed     level=ERROR     console=${TRUE}
    Teardown Infomodel

Collect Syslog When Fail
    Run Keyword If  ${SMOD1_syslog_started}    Collect Syslog For SMOD1 With Timestamp
    Run Keyword If  ${SMOD2_syslog_started}    Collect Syslog For SMOD2 With Timestamp

Collect Syslog For ${SMOD} With Timestamp
    Log To Console   ${SMOD} syslog will be collected
    ${timestamp}    Generate Formatted Timestamp
    ${syslog_collected}=  Run keyword And Return Status  Collect syslog results  alias=${SMOD}
    ...  destination=${UDP Logs}/Loop${current_loop_index}_${SMOD}_UDP_${timestamp}.tar.gz  unzip=false
    Run keyword if  ${syslog_collected}  Log  ${SMOD} syslog collected to 'UDP Logs'    level=INFO      console=${TRUE}
    ...  ELSE  Log  ${SMOD} syslog collection failed      level=ERROR    console=${TRUE}

SBTS Recovery
    ${status}     Run Keyword If    ${NRBTS_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Every    NRCEL    administrativeState=${_Com_Unlocked_}
    Run Keyword If    not ${status} and ${NRBTS_cell_ids}    coam.Unlock    technology=NR   timeout=180
    ${status}    Run Keyword If    ${LTE_cell_ids}    Run Keyword And Return Status
    ...    coam.Assert Every    LNCEL    administrativeState=${_Unlocked_}
    Run Keyword If    not ${status} and ${LTE_cell_ids}    coam.Unlock    technology=LTE   timeout=180
    ${status_nr}    Run Keyword And Return Status    coam.Assert Any    NRCEL   administrativeState=${_Com_Locked_}
    ${status_lte}    Run Keyword And Return Status    coam.Assert Any    LNCEL   administrativeState=${_Locked_}
    Run Keyword If    ${status_nr} or ${status_lte}    Run Keywords    Log    Will perform full commissioning with backup scf!    level=WARN
    ...    AND    coam.perform_commissioning    ${mrbts_id}    ${COMMISSIONING_PATH}
    ...    skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}    timeout=600
    ...    AND    Wait Until Keyword Succeeds    20m    30s    Check_SBTS_SMOD_RMOD_Cells_Alarms

Restart Infomodel And Syslog
    Run Keyword And Continue On Failure    Teardown All Aliases For Syslog
    Run Keyword And Continue On Failure    Teardown All Aliases For Infomodel
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start Infomodel
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD1
    Run Keyword If  ${SMOD2_exists}
    ...    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD2

Restart Admin
   Run Keyword And Continue On Failure    coam.Teardown All Aliases For Admin
   Run Keyword And Continue On Failure    Start Admin    bts_host=${SMOD1['TRS_IP']}

LoopTearDown
    Run Keyword And Continue On Failure    Admin Get Snapshot
    Run Keyword And Continue On Failure    Collect Infomodel With Timestamp
    Run Keyword And Continue On Failure    Collect Syslog When Fail
    SBTS Recovery

TC Setup
    Common Test Setup
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}

Check Alarm Before Test
    ${active_alarm}    coam.Get Alarms    alias=default
    Set Test Variable    ${ALARMS_BEFORE_TEST}    ${active_alarm}
    ${filter_list}    Create List
    FOR    ${str}    IN    @{IGNORE_ALARM_FILTER_STRING}
        &{filter}    Evaluate    ${str}
        Append To List    ${filter_list}    ${filter}
    END
    Set Test Variable    ${IGNORE_ALARM_FILTER}    ${filter_list}

Check Alarm After Test
    ${active_alarm}  coam.Get Alarms  alias=default
    Set Test Variable    ${ALARMS_AFTER_TEST}    ${active_alarm}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALARMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

TC Teardown
    SBTS Recovery
    Run Keyword And Ignore Error    Run Keyword If Test Passed    Report To Rep With SCF Id
    Teardown All Aliases For Syslog
    Teardown All Aliases For Infomodel
    coam.Teardown All Aliases For Admin
    Collect Swconfigs
    Collect RawAlarmHistory
    Teardown NetAct By TAF
    # hran_ta postcondititons:
    hran_general.Hran_ta Postconditions