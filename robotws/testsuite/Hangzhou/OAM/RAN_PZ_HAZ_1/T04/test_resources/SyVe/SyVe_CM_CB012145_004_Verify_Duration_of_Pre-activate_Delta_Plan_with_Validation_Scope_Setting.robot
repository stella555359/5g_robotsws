*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${EXPECED_PDL_ERROR_FULL_CHECK}
...   Assertion not met: MNLENT(fipsStartupSelfTestEnable = 'true')/FEATCADM have actFipsMode = 'true'
${EXPECED_PDL_ERROR_DELTA_CHECK}
...   it is required that then one and only one SYNC instance with profileType set to RAC is defined
${VALIDATE_SUCC_FULL_CHECK_DURATION_STANDARD}    140
${PREACTIVE_SUCC_FULL_CHECK_DURATION_STANDARD}    150
${PREACTIVE_ERR_FULL_CHECK_DURATION_STANDARD}    280
${PREACTIVE_ERR_DELTA_CHECK_DURATION_STANDARD}    90

*** Keywords ***
SyVe_CM_CB012145_004_Verify_Duration_of_Pre-activate_Delta_Plan_with_Validation_Scope_Setting
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Verify delta plan online validation for activate operation in Netact, cover validation scope: full check.
    ...    Verify MNL.validationScope in actual configuration after activation.
    ...    Verify PDL error feedback order showing in Netact
    ...
    ...    The main steps performed for the test are:
    ...    -
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create Plan With Fullcheck ValidateScope Without PDL Error
    ...    - Pre-Activate Plan And Check Duration
    ...    - Validate Plan And Check Duration
    ...    - Activate the plan Syve
    ...    - Check Modified Parameter And ValidateScope From NetAct
    ...    - Site Preparation
    ...    - Create Plan With Deltacheck ValidateScope With PDL Error
    ...    - Pre-Activate Plan And Check Feedback Delta
    ...    - Create Plan With Fullcheck ValidateScope With PDL Error
    ...    - Pre-Activate Plan And Check Feedback Full
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...
    ...    Pass criteria: Value “full check” will not be saved to validationScope in actual configuration
    ...    Only errors related to parameters from delta plan shall be shown in Netact.
    ...    PDL warnings shall not be displayed in Netact side.
    ...    No error from actual configuration should be reported if existing in active configuration
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 27.03.2024 - Modified by Kang Lixin - add new checkpoints for CB012145
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_MN_SRAN_HZ_PROD_SRAN_SQUAD3@internal.nsn.com
    TC parameters check
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create Plan With Fullcheck ValidateScope Without PDL Error
    Step 6: Pre-Activate Plan And Check Duration
    Step 7: Validate Plan And Check Duration
    Step 8: Activate the plan Syve
    Step 9: Check Modified Parameter And ValidateScope From NetAct
    Step 10: Site Preparation
    Step 11: Create Plan With Deltacheck ValidateScope With PDL Error
    Step 12: Pre-Activate Plan And Check Feedback Delta
    Step 13: Create Plan With Fullcheck ValidateScope With PDL Error
    Step 14: Pre-Activate Plan And Check Feedback Full
    Step 15: Provision the backup plan
    Step 16: Check final alarms status from WebEM
    Step 17: Check final alarms status from Netact
    Step 18: Check final BTS state
    Step 19: Check final number and state of Cells and RMs

TC parameters check
    Log    TC parameters check started    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${mo_id}    Set Variable    PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1
    ${mo_dn}    Set Variable    MRBTS-${mrbts_id}/MNL-1
    Set Test Variable    ${mo_id}
    Set Test Variable    ${mo_dn}
    ${check_validationScope}    Run Keyword And Return Status     Check Actual Configuration Parameters
    ...    dist_name=${mo_id}
    ...    validationScope=0
    Run Keyword If    ${check_validationScope}   Fail   TC parameters check failed: Parameters validationScope value should not be displayed on NMS!
    ...    ELSE    Log    TC parameters successfully checked    console=True
    ${check_delta_modify_param}    Run Keyword And Return Status     Check Actual Configuration Parameters
    ...    dist_name=${mo_id}/MNLENT-1
    ...    recoveryResetDelay=60
    ...    fipsStartupSelfTestEnable=1
    Run Keyword If    ${check_delta_modify_param}    Run Keywords    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    AND    Recovery Parameter Value   ${mo_id}/MNLENT-1     ${mo_dn}/MNLENT-1    recoveryResetDelay=0    fipsStartupSelfTestEnable=0
    ...    ELSE    Log    TC parameters successfully checked    console=True

Step ${index}: Site Preparation
    Log    Step ${index}: Site Preparation  console=True
    coam.perform_parameter_recommissioning    ${mo_dn}/MNLENT-1    fipsStartupSelfTestEnable    update    true    skip_parameter_relation_errors=True

Recovery Parameter Value
    [Arguments]     ${mo_id}    ${scf_dn}    &{param_dic}
    ${timestamp}    Generate Formatted Timestamp
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

Step ${index}: Create Plan With ${what} ValidateScope ${when} PDL Error
    [Documentation]     Create Plan With MNL:validationScope as “full check”
    Log    Step ${index}: Create Plan With ValidateScope ${when} PDL Error    console=True
    ${timestamp}    Generate Formatted Timestamp
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}    NetAct Create Plan     ${name}    Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${mo_dn}"]
    ${validationScope}   Set Variable If   '${what.lower()}'=='fullcheck'    1    0
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_id}    validationScope=${validationScope}
    ${param_dic1}    Create Dictionary    recoveryResetDelay=60
    ${param_dic2}    Create Dictionary    targetDNType=0
    &{param_value}    Set Variable If    '${when.lower()}'=='without'    ${param_dic1}    ${param_dic2}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${mo_dn}/MNLENT-1"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_id}/MNLENT-1
    ...    &{param_value}
    Set Test Variable    ${plan}

Step ${index}: Validate Plan And Check Duration
    Log    Step ${index}: Validate Plan And Check Duration   console=True
    ${status}    ${feedback}   ${time}    Validate Plan And Get Status    ${name}
    Should Be True    '${status}'=='PASS'
    Should Be True    ${time}<${VALIDATE_SUCC_FULL_CHECK_DURATION_STANDARD}

Step ${index}: Pre-Activate Plan And Check Duration
    Log    Step ${index}: Pre-Activate Plan And Check Duration  console=True
    Set Test Variable   ${backup_plan}    ${name}_backup
    ${status}    ${feedback}   ${time}    Preactive Plan And Get Status   ${name}    True    ${backup_plan}
    Should Be True    '${status}'=='PASS'
    Should Be True    ${time}<${PREACTIVE_SUCC_FULL_CHECK_DURATION_STANDARD}

Step ${index}: Activate the plan Syve
    Log    Step ${index}: Activate the plan Syve   console=True
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.activate_preactivated_plan  plan_name=${name}    dist_names=${MRBTS_DN}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${backup_plan}.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${backup_plan}    operation_type=plan

Step ${index}: Pre-Activate Plan And Check Feedback Delta
    Log    Step ${index}: Pre-Activate Plan And Check Feedback    console=True
    ${status}    ${feedback}   ${time}    Preactive Plan And Get Status    plan_name=${name}
    Should Contain    ${feedback}    ${EXPECED_PDL_ERROR_DELTA_CHECK}
    Should Contain    ${feedback}    Error\n\t5G/LTE/SRAN plan validate failed
    Should Not Contain    ${feedback}    Non-delta error
    Should Not Contain    ${feedback}    Warning
    Should Be True    ${time}<${PREACTIVE_ERR_DELTA_CHECK_DURATION_STANDARD}

Step ${index}: Pre-Activate Plan And Check Feedback Full
    Log    Step ${index}: Pre-Activate Plan And Check Feedback    console=True
    ${status}    ${feedback}   ${time}    Preactive Plan And Get Status    plan_name=${name}
    Should Contain    ${feedback}    ${EXPECED_PDL_ERROR_FULL_CHECK}
    Should Contain    ${feedback}    Error\n\t5G/LTE/SRAN plan validate failed
    Should Contain    ${feedback}    Non-delta error
    Should Not Contain    ${feedback}    Warning
    Should Be True    ${time}<${PREACTIVE_ERR_FULL_CHECK_DURATION_STANDARD}

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
    NetAct Check Actual Configuration Parameters    dist_name=${mo_id}/MNLENT-1   recoveryResetDelay=60
    ${status}    Run Keyword And Return Status    NetAct Check Actual Configuration Parameters    dist_name=${mo_id}   validationScope=1
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
    ${current_value}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${mo_id}/MNLENT-1    fipsStartupSelfTestEnable=0
    Run Keyword If    not ${current_value}    Recovery Parameter Value   ${mo_id}/MNLENT-1     ${mo_dn}/MNLENT-1   fipsStartupSelfTestEnable=0
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown


