*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{EXPECTED_ALARMS}    {'alarmId': 7220, 'faultId': 4654}

*** Keywords ***
SyVe_CM_CB005809_Trigger_Alarm_DisabledEthernetPortSecurityAl_With_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21199
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing Plan provision and check alarm 4654 from NetAct.
    ...    The main steps performed for the test are:
    ...    - TC parameters check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Check Existed Expected Alarm
    ...    - Reset SBTS
    ...    - Check Existed Expected Alarm
    ...    - Provision the plan to enable EthernetPortSecurity
    ...    - Check EthernetPortSecurity in Netact after set parameter_true
    ...    - Check NON-Existed Expected Alarm
    ...    - Provision the plan to disable EthernetPortSecurity
    ...    - Check EthernetPortSecurity in Netact after set parameter_false
    ...    - Check Existed Expected Alarm
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: Provision plan as expected, and alarm can raised as expected.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21199
    ...    - SyVe_CM_Trigger_Alarm_DisabledEthernetPortSecurityAl_With_NetAct_CB005809
    ...    - 04.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-21199_SyVe_CM_Trigger_Alarm_DisabledEthernetPortSecurityAl_With_NetAct_CB005809.png
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ_1_HAZ_OPER_1_VRF@internal.nsn.com
    Step 1: TC parameters check
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Check Existed Expected Alarm
    Step 6: Reset SBTS
    Step 7: Check Existed Expected Alarm
    Step 8: Provision the plan to enable EthernetPortSecurity
    Step 9: Check EthernetPortSecurity in Netact after set parameter_true
    Step 10: Check NON-Existed Expected Alarm
    Step 11: Provision the plan to disable EthernetPortSecurity
    Step 12: Check EthernetPortSecurity in Netact after set parameter_false
    Step 13: Check Existed Expected Alarm
    Step 14: Check final alarms status from WebEM
    Step 15: Check final alarms status from Netact
    Step 16: Check final BTS state
    Step 17: Check final number and state of Cells and RMs

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${mo_id}    ${MRBTS_DN}/MNL-1/MNLENT-1/SECADM-1
    Set Test Variable    ${scf_distName}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1
    ${parameter_true}    Create Dictionary     ethernetPortSecurityEnabled=true
    ${parameter_false}    Create Dictionary     ethernetPortSecurityEnabled=false
    Set Test Variable    ${parameter_true}
    Set Test Variable    ${parameter_false}
     ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable     ${timestamp}
    ${same_values}=    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${mo_id}
    ...    ui_values=true    &{parameter_false}
    Set Test Variable    ${same_values}
    Set Test Variable    ${preparation_plan_name}    MRBTS-${mrbts_id}_TC_preparation_${timestamp}
    Run Keyword If    '${same_values}'=='True'    Log    TC parameters successfully checked    console=True
    ...    ELSE    Run Keywords    NetAct Create And Edit Plan     name=${preparation_plan_name}
    ...    description=Automation SyVe for MRBTS-${mrbts_id}    mo_id=${mo_id}    scf_distName=${scf_distName}    &{parameter_false}
    ...    AND    NetAct Provision Plan    plan_name=${preparation_plan_name}     dist_names=${MRBTS_DN}
    ...    backup_plan_name=${preparation_plan_name}_backup    create_backup_plan=false    provisioning_operation=activate

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

Step ${index}: Check ${Existed} Expected Alarm
    Log    Step ${index}: Check ${Existed} Expected Alarm    console=True
    Run Keyword If    "${Existed}" == "Existed"    Wait Until Keyword Succeeds    10 min    30 sec    Get and Check Alarms SyVe    source=Bts
    ...    expected_alarms=${EXPECTED_ALARMS}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    ELSE    Wait Until Keyword Succeeds    3 min    30 sec    Get and Check Alarms SyVe    source=Bts
    ...    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    Run Keyword If    "${Existed}" == "Existed"    Wait Until Keyword Succeeds    10 min    30 sec    Get and Check Alarms SyVe    source=Netact
    ...    expected_alarms=${EXPECTED_ALARMS}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}
    ...    ELSE    Wait Until Keyword Succeeds    3 min    30 sec    Get and Check Alarms SyVe    source=Netact
    ...    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}
    Run Keyword If    "${Existed}" != "Existed"    Excepted Alarm Be Cleared From NetAct And WebEM    7220    4654

Create NetAct CM Plan
    [Documentation]    Create and edit plan SyVe based on arguments
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}    mo_id=${mo_id}
    ...    scf_distName=${scf_distName}    &{parameter_true}
    Set Test Variable    ${plan}
    Set Test Variable    ${mrbts_id}

Step ${index}: Provision the plan to enable EthernetPortSecurity
    Log    Step ${index}: Provision the plan SyVe    console=True
    Create NetAct CM Plan
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}    plan_name=${name}
    ...    operation_type=plan
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup    create_backup_plan=True
    ...    provisioning_operation=activate

Step ${index}: Check EthernetPortSecurity in Netact after set ${parameter_value}
    Log    Step ${index}: Check EthernetPortSecurity in Netact after enable    console=True
    NetAct Check Actual Configuration Parameters    dist_name=${mo_id}    ui_values=true    &{${parameter_value}}

Step ${index}: Reset SBTS
    Log    Step ${index}: Reset SBTS    console=True
    coam.Reset_Site    timeout=300
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Provision the plan to disable EthernetPortSecurity
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${preparation_plan_name}
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown

