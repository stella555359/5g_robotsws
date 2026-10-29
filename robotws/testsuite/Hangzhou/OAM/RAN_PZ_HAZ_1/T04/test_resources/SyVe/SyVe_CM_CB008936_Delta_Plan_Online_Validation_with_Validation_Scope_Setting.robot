*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${nr_pdl_error}    Distname parameter 'voNRNrDrxDN' references non-existing 'NRDRX-10' object
${lte_pdl_error}    ulpcOptRachPwr (list of 0 items) is configured
${VALIDATE_SUCC_DELTA_CHECK_DURATION_STANDARD}    50
${PREACTIVE_SUCC_DELTA_CHECK_DURATION_STANDARD}    70
${PREACTIVE_ERR_DELTA_CHECK_DURATION_STANDARD}    90
&{modify_nr_info}    rat=nr      param_name=dedicatedSib1   param_value=true    backup_param_value=false    err_param_name=voNRNrDrxDN
...    err_param_value=NRDRX-10    expected_pdl_error=${nr_pdl_error}
&{modify_lte_info}    rat=lte     param_name=actAir2Ground   param_value=true    backup_param_value=false   err_param_name=actUlpcRachPwrCtrl
...    err_param_value=true   expected_pdl_error=${lte_pdl_error}

*** Keywords ***
SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Verify delta plan online validation for activate operation in Netact, cover validation scope: delta check.
    ...    Verify MNL.validationScope in actual configuration after activation.
    ...    Verify PDL error feedback order showing in Netact
    ...
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create Plan With ValidateScope Without PDL Error
    ...    - Preactive the plan Syve
    ...    - Validate the plan Syve
    ...    - Activate the plan Syve
    ...    - Check Modified Parameter And ValidateScope From NetAct
    ...    - Create Plan With ValidateScope With PDL Error
    ...    - Pre-Activate Plan And Check Feedback
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: Value “delta check” will not be saved to validationScope in actual configuration
    ...    Only errors related to parameters from delta plan shall be shown in Netact.
    ...    PDL warnings shall not be displayed in Netact side.
    ...    No error from actual configuration should be reported if existing in active configuration
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.01.2023 - Modified by Kang Lixin - new case
    ...    - 27.03.2024 - Modified by Kang Lixin - add new checkpoints for CB012145
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_MN_SRAN_HZ_PROD_SRAN_SQUAD3@internal.nsn.com
    TC parameters check
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create Plan With ValidateScope Without PDL Error
    Step 6: Pre-Activate Plan And Check Duration
    Step 7: Validate Plan And Check Duration
    Step 8: Activate the plan Syve
    Step 9: Check Modified Parameter And ValidateScope From NetAct
    Step 10: Create Plan With ValidateScope With PDL Error
    Step 11: Pre-Activate Plan And Check Feedback
    Step 12: Provision the backup plan
    Step 13: Check final alarms status from WebEM
    Step 14: Check final alarms status from Netact
    Step 15: Check final BTS state
    Step 16: Check final number and state of Cells and RMs

TC parameters check
    Log    TC parameters check started    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${mo_id}    Set Variable    PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1
    ${mo_dn}    Set Variable    MRBTS-${mrbts_id}/MNL-1
    Set Test Variable    ${mo_id}
    Set Test Variable    ${mo_dn}
    ${testdata_list}    Create List     ${modify_nr_info}    ${modify_lte_info}
    ${plan_info}    Evaluate    random.choice(${testdata_list})    modules=random, sys
    Set Test Variable    ${plan_info}
    ${cell_list}    coam.Get Cell List
    ${selected_cell}    Evaluate    random.choice(${cell_list['cells']['${plan_info['rat']}']})    modules=random, sys
    Set Test Variable    ${selected_cell_dn}    ${selected_cell['id']['configuration']}
    ${same_values1}    Run Keyword And Return Status     Check Actual Configuration Parameters
    ...    dist_name=${mo_id}
    ...    validationScope=0
    Run Keyword If    ${same_values1}    Fail    TC parameters check failed: Parameters validationScope value should not be displayed on NMS!
    ...    ELSE    Log    TC parameters successfully checked    console=True
    ${same_values2}    Run Keyword And Return Status     Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${selected_cell_dn}
    ...    ${plan_info['param_name']}=${plan_info['param_value']}
    Run Keyword If    ${same_values2}    Run Keywords    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    AND    Recovery Parameter Value    PLMN-PLMN/${selected_cell_dn}     ${selected_cell_dn}
    ...    ${plan_info['param_name']}=${plan_info['backup_param_value']}
    ...    ELSE    Log    TC parameters successfully checked    console=True
    ${same_values}    Set Variable If   (${same_values1} or ${same_values2})    True    False
    Set Test Variable    ${same_values}

Recovery Parameter Value
    [Arguments]     ${mo_id}    ${scf_dn}    &{param_dic}
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    ${plan}    NetAct Create And Edit Plan    name=MRBTS-${mrbts_id}_${timestamp}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${mo_id}   scf_distName=${scf_dn}   &{param_dic}
    NetAct Provision Plan    plan_name=MRBTS-${mrbts_id}_${timestamp}    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create Plan With ValidateScope ${when} PDL Error
    [Documentation]     Create Plan With MNL:validationScope as “delta check”
    Log    Step ${index}: Create Plan With ValidateScope Without PDL Error    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}    NetAct Create Plan     ${name}    Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${mo_dn}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_id}    validationScope=0
    ${param_dic1}    Create Dictionary    ${plan_info['param_name']}=${plan_info['param_value']}
    ${param_dic2}    Create Dictionary    ${plan_info['err_param_name']}=${plan_info['err_param_value']}
    ${param_value}    Set Variable If    '${when}'=='Without'    ${param_dic1}    ${param_dic2}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${selected_cell_dn}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${selected_cell_dn}
    ...    &{param_value}
    Set Test Variable    ${plan}

Step ${index}: Validate Plan And Check Duration
    Log    Step ${index}: Validate the plan Syve   console=True
    ${status}    ${feedback}   ${time}    Validate Plan And Get Status    ${name}
    Should Be True    '${status}'=='PASS'
    Should Be True    ${time}<${VALIDATE_SUCC_DELTA_CHECK_DURATION_STANDARD}

Step ${index}: Pre-Activate Plan And Check Duration
    Log    Step ${index}: Preactive the plan Syve   console=True
    Set Test Variable   ${backup_plan}    ${name}_backup
    ${status}    ${feedback}   ${time}    Preactive Plan And Get Status   ${name}    True    ${backup_plan}
    Should Be True    '${status}'=='PASS'
    Should Be True    ${time}<${PREACTIVE_SUCC_DELTA_CHECK_DURATION_STANDARD}

Step ${index}: Activate the plan Syve
    Log    Step ${index}: Activate the plan Syve   console=True
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.activate_preactivated_plan  plan_name=${name}    dist_names=${MRBTS_DN}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${backup_plan}.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${backup_plan}    operation_type=plan

Step ${index}: Pre-Activate Plan And Check Feedback
    Log    Step ${index}: Pre-Activate Plan And Check Feedback    console=True
    ${status}    ${feedback}   ${time}    Preactive Plan And Get Status    plan_name=${name}
    Should Contain    ${feedback}    ${plan_info['expected_pdl_error']}
    Should Contain    ${feedback}    Error\n\t5G/LTE/SRAN plan validate failed
    Should Not Contain    ${feedback}    Warning
    Should Not Contain    ${feedback}    Non-delta error
    Should Be True    ${time}<${PREACTIVE_ERR_DELTA_CHECK_DURATION_STANDARD}

Validate Plan And Get Status
    [Arguments]     ${plan_name}
    ${start_time}    Get Time
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.validate_plan    plan_name=${plan_name}    dist_names=${MRBTS_DN}
    ${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    [Return]     ${status}    ${feedback}    ${time}

Preactive Plan And Get Status
    [Arguments]     ${plan_name}    ${backup_plan}=False    ${backup_plan_name}=None
    ${start_time}    Get Time
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${plan_name}    dist_names=${MRBTS_DN}
    ...    create_backup_plan=${backup_plan}    backup_plan_name=${backup_plan_name}   provisioning_operation=preactivate
    ${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    [Return]   ${status}    ${feedback}    ${time}

Step ${index}: Check Modified Parameter And ValidateScope From NetAct
    Log    Step ${index}: Check Modified Parameter And ValidateScope From NetAct    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${selected_cell_dn}
    ...    ${plan_info['param_name']}=${plan_info['param_value']}
    ${status}    Run Keyword And Return Status    NetAct Check Actual Configuration Parameters    dist_name=${mo_id}   validationScope=0
    Should Not Be True    ${status}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=check_netact_plan.xml    dist_names=${dist_name}    ui_values=${ui_values}
    ${xml_content}    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/check_netact_plan.xml
    ${status}    ${msg}    Run Keyword And Ignore Error     L_XML.Get Element Text    ${xml_content}
    ...    .//managedObject[@distName="${mo_id}"]/p[@name="validationScope"]
    Should Contain    ${msg}    No element matching './/managedObject[@distName="${mo_id}"]/p[@name="validationScope"]' found

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Provision Plan    plan_name=${backup_plan}    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${backup_plan}
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown


