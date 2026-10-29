*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{EXPECTED_ALARMS}    {'alarmId': 7220, 'faultId': 4655}

*** Keywords ***
SyVe_CM_CB005809_Trigger_Alarm_EnableServiceAccoutRootAccess_With_NetAct
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21214
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision systemAcctPermEnable to true to trigger alarm and login with account toor4nsn from NetAct.
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Set Parameters Value
    ...    - Check Login SBTS Is ${Login_Result_Initial}
    ...    - Create and edit plan SyVe With Set
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe With Alarm Filtering Check Set
    ...    - Check Login SBTS Is ${Login_Result_Set}
    ...    - Create and edit plan SyVe With Recovery
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe With Alarm Filtering Check Recovery
    ...    - Check Login SBTS Is ${Login_Result_Recovery}
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 22.04.2021 - https://jira3.int.net.nokia.com/browse/TAT-21214
    ...    - SyVe_CM_Trigger_Alarm_EnableServiceAccoutRootAccess_With_NetAct_CB005809
    ...    - 04.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...    - 19.12.2022 - Modified by Kang Lixin to add scenario for BOAM_ET case CB005809: Fault 4655 not subjected to any of alarm filtering rules
    ...    -      Change Step9 and Step13 name to  Provision the plan SyVe With Alarm Filtering Check Recovery,
    ...    -      Add KW Check Alarm When Filtering Param Changing, add steps in KW Set Parameters Value
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-21214_SyVe_CM_Trigger_Alarm_EnableServiceAccoutRootAccess_With_NetAct_CB005809.png
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Set Parameters Value
    Step 6: Check Login SBTS Is ${Login_Result_Initial}
    Step 7: Create and edit plan SyVe With Set
    Step 8: Export the plan SyVe
    Step 9: Provision the plan SyVe With Alarm Filtering Check Set
    Step 10: Check Login SBTS Is ${Login_Result_Set}
    Step 11: Create and edit plan SyVe With Recovery
    Step 12: Export the plan SyVe
    Step 13: Provision the plan SyVe With Alarm Filtering Check Recovery
    Step 14: Check Login SBTS Is ${Login_Result_Recovery}
    Step 15: Check final alarms status from WebEM
    Step 16: Check final alarms status from Netact
    Step 17: Check final BTS state
    Step 18: Check final number and state of Cells and RMs

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
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Set Parameters Value
    Log    Step ${index}: Set Parameters Value    console=True
    ${scf}    coam.Get Scf
    ${mo_para_initial}    XML.Get Element Text    ${scf}    .//p[@name="systemAcctPermEnable"]
    Set Test Variable    ${mo_para_initial}
    ${mo_para_set}    Set Variable If    "${mo_para_initial}"=="false"    true    false
    ${mo_para_recovery}    Set Variable    ${mo_para_initial}
    &{mo_parameter_Set}    Create Dictionary
    &{mo_parameter_Recovery}    Create Dictionary
    Set Test Variable    &{mo_parameter_Set}    systemAcctPermEnable=${mo_para_set}
    Set Test Variable    &{mo_parameter_Recovery}    systemAcctPermEnable=${mo_para_recovery}
    ${Login_Result_Initial}    Set Variable If    "${mo_para_initial}"=="false"    success    failed
    ${Login_Result_Set}    Set Variable If    "${mo_para_initial}"=="false"    failed    success
    ${Login_Result_Recovery}    Set Variable If    "${mo_para_initial}"=="false"    success    failed
    ${Alarm_Filtering_Check_Set}    Set Variable If    "${mo_para_initial}"=="false"     False     True
    ${Alarm_Filtering_Check_Recovery}    Set Variable If    "${Alarm_Filtering_Check_Set}"=="False"    True    False
    Set Test Variable    ${Login_Result_Initial}
    Set Test Variable    ${Login_Result_Set}
    Set Test Variable    ${Login_Result_Recovery}
    Set Test Variable    ${Alarm_Filtering_Check_Set}
    Set Test Variable    ${Alarm_Filtering_Check_Recovery}

Step ${index}: Create and edit plan SyVe With ${When}
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe With ${When}    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}_${When}
    ${mo_id}    Set Variable    PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${mo_scfDN}    Set Variable    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    Set Test Variable    ${mo_id}
    Set Test Variable    ${mo_scfDN}
    ${plan}    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}_${When}    mo_id=${mo_id}
    ...    scf_distName=${mo_scfDN}    &{mo_parameter_${When}}
    Set Test Variable    ${plan}
    Set Test Variable    ${mrbts_id}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}    plan_name=${name}
    ...    operation_type=plan

Step ${index}: Provision the plan SyVe With Alarm Filtering Check ${When}
    Log    Step ${index}: Provision the plan SyVe With Alarm Filtering Check ${When}    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Run Keyword If    ${Alarm_Filtering_Check_${When}}    Check Alarm When Filtering Param Changing

Check Alarm When Filtering Param Changing
    Wait Until Keyword Succeeds    5 min    30 sec    Eval Current Alarms SyVe    expected_alarms=${EXPECTED_ALARMS}
    Generate Plan For Alarm Filter Checking    disable    false
    NetAct Provision Plan    plan_name=${filtering_plan_name}   dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Check Actual Filter Value After Provision    false
    Eval Current Alarms SyVe    expected_alarms=${EXPECTED_ALARMS}
    Generate Plan For Alarm Filter Checking    enable    true
    NetAct Provision Plan    plan_name=${filtering_plan_name}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Check Actual Filter Value After Provision    true
    Eval Current Alarms SyVe    expected_alarms=${EXPECTED_ALARMS}

Generate Plan For Alarm Filter Checking
    [Arguments]    ${operation}    ${param_value}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${filtering_plan_name}    MRBTS-${mrbts_id}_${timestamp}_${operation}filtering
    ${filtering_plan}    NetAct Create Plan     ${filtering_plan_name}    alarm filtering ${operation}
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
    NetAct Check Actual Configuration Parameters    dist_name=${mo_id}    ui_values=true    systemAcctPermEnable=false
    NetAct Check Actual Configuration Parameters    dist_name=${mo_id}    ui_values=true    actKpiAlarms=${param_value}
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ...    ui_values=true    actAlarmsInTestDedicatedState=${param_value}

Step ${index}: Check Login SBTS Is ${Result}
    Log    Step ${index}: Check Login SBTS Is ${Result}    console=True
    SSHLibrary.Open Connection    ${SMOD1['TRS_IP']}
    ${mo2_provision}    ${mo2_message}    Run Keyword And Ignore Error    SSHLibrary.Login    ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    Run Keyword If    "${Result}"=="success"    Run Keywords    Should Start With    ${mo2_message}    Last login:
    ...    AND    Should Be True    "${mo2_provision}" == "PASS"
    ...    ELSE    Run Keywords    Should Contain    ${mo2_message}    Authentication failed for user 'toor4nsn'
    ...    AND    Should Be True    "${mo2_provision}" == "FAIL"
    Run Keyword If    "${Result}"=="success"    Wait Until Keyword Succeeds    5 min    30 sec    Get and Check Alarms SyVe    source=Bts
    ...    expected_alarms=${EXPECTED_ALARMS}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    Run Keyword If    "${Result}"=="success"    Wait Until Keyword Succeeds    5 min    30 sec    Get and Check Alarms SyVe    source=Netact
    ...    expected_alarms=${EXPECTED_ALARMS}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}
    Run Keyword If    "${Result}"=="success"    Run Keywords    coam.Reset_Site    timeout=300
    ...    AND    Wait Until Keyword Succeeds    30min    60s    Check SBTS SMOD RMOD Cells Alarms
    ...    AND    Wait Until Keyword Succeeds    10 min    30 sec    Get and Check Alarms SyVe    source=Netact
    ...    expected_alarms=${EXPECTED_ALARMS}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}
    ...    AND    SSHLibrary.Login    ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    Run Keyword If    "${Result}"=="failed"    Wait Until Keyword Succeeds    5 min    30 sec    Get and Check Alarms SyVe    source=Bts
    ...    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    Run Keyword If    "${Result}"=="failed"    Wait Until Keyword Succeeds    10 min    30 sec    Get and Check Alarms SyVe    source=Netact
    ...    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}
    Run Keyword If    "${Result}"=="failed"    Excepted Alarm Be Cleared From NetAct And WebEM    7220    4655

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${no_need_recovery}    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${mo_id}    ui_values=true
    ...    &{mo_parameter_Recovery}
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
