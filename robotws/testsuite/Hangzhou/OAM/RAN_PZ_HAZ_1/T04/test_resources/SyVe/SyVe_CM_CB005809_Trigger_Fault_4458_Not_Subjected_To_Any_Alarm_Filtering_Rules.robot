*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{EXPECTED_ALARMS}    {'alarmId': 7115, 'faultId': 4458}

*** Keywords ***
SyVe_CM_CB005809_Trigger_Fault_4458_Not_Subjected_To_Any_Alarm_Filtering_Rules
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    To verify fault 4458 not subjected to any of alarm filtering rules
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Enable Fault 4458
    ...    - Check Alarm When Filtering Param Set To false
    ...    - Recovery SBTS
    ...    - Enable Fault 4458
    ...    - Check Alarm When Filtering Param Set To false
    ...    - Recovery SBTS
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.01.2023 - Add by Kang Lixin - New case
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: TC parameters check
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Enable Fault 4458
    Step 6: Check Alarm When Filtering Param Set To false
    Step 7: Recovery SBTS
    Step 8: Enable Fault 4458
    Step 9: Check Alarm When Filtering Param Set To true
    Step 10: Recovery SBTS
    Step 11: Check final alarms status from WebEM
    Step 12: Check final alarms status from Netact
    Step 13: Check final BTS state
    Step 14: Check final number and state of Cells and RMs

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${mo_id1}    Set Variable    ${MRBTS_DN}/MNL-1/MNLENT-1/FEATCADM-1
    ${mo_id2}    Set Variable    ${MRBTS_DN}/MNL-1/MNLENT-1/SECADM-1
    ${scf_distName1}    Set Variable     MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${scf_distName2}    Set Variable    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1
    ${parameter_systemAcctPermEnable}    Create Dictionary     systemAcctPermEnable=false
    ${parameter_actServiceAccountSsh}    Create Dictionary     actServiceAccountSsh=true
    Set Test Variable    ${parameter_systemAcctPermEnable}
    Set Test Variable    ${parameter_actServiceAccountSsh}
    Precondition Set Parameters     ${scf_distName1}    ${mo_id1}    ${parameter_systemAcctPermEnable}
    Precondition Set Parameters     ${scf_distName2}    ${mo_id2}    ${parameter_actServiceAccountSsh}

Precondition Set Parameters
    [Arguments]    ${scf_distName}   ${mo_id}   ${param_dic}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${preparation_plan_name}    MRBTS-${mrbts_id}_TC_preparation_${timestamp}
    ${same_values}    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${mo_id}
    ...    ui_values=true    &{param_dic}
    Run Keyword If    '${same_values}'=='True'    Log    TC parameters successfully checked    console=True
    ...    ELSE    Run Keywords    NetAct Create And Edit Plan    name=${preparation_plan_name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${mo_id}    scf_distName=${scf_distName}    &{param_dic}
    ...    AND    NetAct Provision Plan    plan_name=${preparation_plan_name}     dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=false    provisioning_operation=activate

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
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}
    ...    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Enable Fault 4458
    Log    Step ${index}: Enable Fault 4458    console=True
    Establish SSH to SBTS    ${SMOD1['IP']}
    SSHLibrary.Execute Command    systemctl stop sshd
    SSHLibrary.Close Connection
    Provision Plan SyVe With Param systemAcctPermEnable true
    Wait Until Keyword Succeeds    5 min    30 sec    Eval Current Alarms SyVe    expected_alarms=${EXPECTED_ALARMS}

Provision Plan SyVe With Param systemAcctPermEnable ${value}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${mo_id}    Set Variable    PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${mo_scfDN}    Set Variable    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable    ${mo_id}
    Set Test Variable    ${mo_scfDN}
    ${plan}    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}_value_${value}    mo_id=${mo_id}
    ...    scf_distName=${mo_scfDN}    systemAcctPermEnable=${value}
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Recovery SBTS
    Log    Step ${index}: Recovery SBTS    console=True
    coam.Reset_Site    timeout=300
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Provision Plan SyVe With Param systemAcctPermEnable false

Step ${index}: Check Alarm When Filtering Param Set To ${value}
    Log    Step ${index}: Check Alarm When Filtering Param Set To ${value}    console=True
    Generate Plan To Change Filtering Parameters    ${value}
    NetAct Provision Plan    plan_name=${filtering_plan_name}   dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Check Actual Filter Value After Provision    ${value}
    Eval Current Alarms SyVe    expected_alarms=${EXPECTED_ALARMS}

Generate Plan To Change Filtering Parameters
    [Arguments]    ${param_value}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${filtering_plan_name}    MRBTS-${mrbts_id}_${timestamp}_withfiltering_${param_value}
    ${filtering_plan}    NetAct Create Plan     ${filtering_plan_name}    alarm filtering ${param_value}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${mo_scfDN}"]
    NetAct Create Managed Object    plan=${filtering_plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_id}    actKpiAlarms=${param_value}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}
    ...    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1"]
    NetAct Create Managed Object    plan=${filtering_plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ...    actAlarmsInTestDedicatedState=${param_value}

Check Actual Filter Value After Provision
    [Arguments]    ${param_value}
    NetAct Check Actual Configuration Parameters    dist_name=${mo_id}    ui_values=true    systemAcctPermEnable=true
    NetAct Check Actual Configuration Parameters    dist_name=${mo_id}    ui_values=true    actKpiAlarms=${param_value}
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ...    ui_values=true    actAlarmsInTestDedicatedState=${param_value}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${filtering_plan_name}
    ${no_need_recovery}    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${mo_id}    ui_values=true
    ...    systemAcctPermEnable=false
    Run Keyword If    not ${no_need_recovery}    Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably Config Recovery was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
