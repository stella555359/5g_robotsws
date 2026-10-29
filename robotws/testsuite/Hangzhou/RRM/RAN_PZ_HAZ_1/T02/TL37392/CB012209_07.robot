*** Settings ***
Documentation
...   Author: mengli.yang@nokia-sbell.com
...   Contact: mengli.yang@nokia-sbell.com
...   Description: The user scenario related to CB012209.


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot



*** Test Cases ***
CB012209_07_Monitoring_PCMD_content_related_to_CB012209_with_XnAPSourceHO_Record
    Setup NetAct    ${SRNCLAB1015}
    Set CB012209 feature activation via Netact    value=0
    ${value}=    Get Actual Parameter Value From NetAct    dist_name=PLMN-PLMN/MRBTS-37392/NRBTS-37392    param=actVoNRPrioDuringHOPrep
    Should Be True  ${value}==0
    Set CB012209 feature activation via Netact    value=1
    ${value}=    Get Actual Parameter Value From NetAct    dist_name=PLMN-PLMN/MRBTS-37392/NRBTS-37392    param=actVoNRPrioDuringHOPrep
    Should Be True  ${value}==1
    Check Counter M55143C01504 In Netact
    Teardown NetAct

*** Keywords ***
Get Initial SCF
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    alias=SCF_ini
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${file_name}    Set Variable    SCF_${timestamp}.xml
    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}    file_name=${file_name}
    ...    connection=SCF_ini
    Run Keyword And Ignore Error    COAM_Admin.Logout    connection=SCF_ini
    [return]    ${file_name}

Set CB012209 feature activation via Netact
    [Arguments]    ${value}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${name}    MRBTS-37392_${timestamp}
    ${va}    Create List    ${value}
    ${parameter}    Create Dictionary    actVoNRPrioDuringHOPrep=${va}
    ${BTS_scf_initial}   Get Initial SCF
    ${plan}    NetAct Create And Edit Plan    BTS_scf_initial=${TEST_LOG_DIRECTORY}/${BTS_scf_initial}    name=${name}
    ...    description=Automation SyVe for MRBTS-${mrbts_id}_value_${va}    mo_id=PLMN-PLMN/MRBTS-37392/NRBTS-37392
    ...    scf_distName=MRBTS-37392/NRBTS-37392    &{parameter}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name}.csv    dist_names=PLMN-PLMN/MRBTS-37392
    ...    plan_name=${name}    operation_type=plan
    Set Test Variable    ${name_bu}    MRBTS-37392_${timestamp}_Backup
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-37392    backup_plan_name=${name_bu}    create_backup_plan=True
    ...    provisioning_operation=preactivate    ignore_errors=True

Get Actual Parameter Value From NetAct
    [Arguments]    ${dist_name}    ${param}    ${ui_values}=false
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}    Run Keyword And Return Status    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs
    ...    file_name=get_param_value_from_netact_plan.xml    dist_names=PLMN-PLMN/MRBTS-37392    ui_values=${ui_values}
    ${scf_xml}=    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/NetActLogs/get_param_value_from_netact_plan.xml
    ${actual_value}   L_XML.Get Element Text   ${scf_xml}   .//managedObject[@distName="${dist_name}"]/list[@name="${param}"]
    ${actual_value}     replace string     ${actual_value}    \n     ${SPACE}
    ${actual_value}    Strip String    ${actual_value}
    [Return]      ${actual_value}

Check Counter M55143C01504 In Netact
    Log To Console  Check Counter M55143C01504 In Netact
    ${start_time}  Evaluate   datetime.datetime.now()-datetime.timedelta(int(1))   modules=datetime
    ${end_time}  Evaluate   datetime.datetime.now()+datetime.timedelta(int(1))  modules=datetime
    Log To Console   ${start_time}
    Log To Console   ${end_time}
    ${counters}   Get_Counter_Value_From_NetAct
    ...   technology=NRBTS-Nokia AirScale BTS 5G
    ...   measurement=NR XN-C Interface signalling NRCELL level
    ...   counter=XN_HO_PREP_CNC_SRC_VONR_PRIO
    ...   filter_by=MRBTS
    ...   mo_names=PLMN-PLMN/MRBTS-37392
    ...   object_aggregation=NRCEL
    ...   time_aggregation=RAW
    ...   start_time=${start_time}
    ...   end_time=${end_time}
    ...   time_filter=absolute
    Netact Check Counter  counters=${counters}   counter_item=XN_HO_PREP_CNC_SRC_VONR_PRIO
    ...   expected_value=0   operator=ge

    Teardown NetAct

Netact Check Counter
    [Arguments]  ${counters}  ${counter_item}  ${expected_value}=100   ${operator}=ge

    ${operator}   set variable  ${operator.lower()}
    ${op}  Set Variable If  "${operator}"=="gt"    >
      ...    "${operator}"=="ge"   >=
      ...    "${operator}"=="lt"   <
      ...    "${operator}"=="le"   <=
      ...    "${operator}"=="ne"   !=
      ...    "${operator}"=="eq"   ==

    should not be empty    ${counters}
    ${status}=   set variable   False
    FOR    ${counter}    IN    @{counters[::-1]}
        ${counter_value}    set variable  ${counter['${counter_item}']}
        ${status}=   set variable if  ${counter_value}${op}${expected_value}   True
        Set Test Variable   ${counter_values_final}    ${counter_value}
        exit for loop if    ${counter_value}${op}${expected_value}
    END
    should be equal    ${status}  True   Check counter value failed!
    [Return]    ${counter_values_final}