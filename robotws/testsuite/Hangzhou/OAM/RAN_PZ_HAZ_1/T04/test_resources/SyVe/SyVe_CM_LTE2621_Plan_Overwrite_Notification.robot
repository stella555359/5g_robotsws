*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{Plan_List}

*** Keywords ***
SyVe_CM_LTE2621_Plan_Overwrite_Notification
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20154
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing Plan overwrite notification from NetAct
    ...    The main steps performed for the test are:
    ...    - Prepare the Plan Infor
    ...    - TC parameters check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe Plan 1
    ...    - Download the Plan 1 Syve
    ...    - Download the Plan 1 Syve
    ...    - Check NON_Existed Expected Alarm
    ...    - Create and edit plan SyVe Plan 2
    ...    - Download the Plan 2 Syve
    ...    - Check Existed Expected Alarm
    ...    - Activate the Plan 1 Failed
    ...    - Reset SBTS
    ...    - Check NON_Existed Expected Alarm
    ...    - Create and edit plan SyVe Plan 3
    ...    - Download the Plan 3 Syve
    ...    - Create and edit plan SyVe Plan 4
    ...    - Provision the Plan 4 Syve
    ...    - Check modified parameter in Netact after provision Plan 4
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, download, activate, provision plan as expected, and overwirte alarm can raised as expected.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 09.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-20154 - SyVe_CM_Plan_Overwrite_Notification_LTE2621
    ...    - 28.04.2021 - https://jira3.int.net.nokia.com/browse/TAT-21283 - Modify case SyVe_CM_Plan_Overwrite_Notification_LTE2621
    ...    - 03.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.  Also update wait timer for alarm in step 19
    ...    - 20.01.2022 - Modified by Xu Yuyan  - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...    - 23.03.2022 - Modified by YuaGao:Discard using netact_plan.yaml
    ...    - 29.05.2024 - Modified by Kang Lixin - requirement change: any downloaded but not activated configuration plan will be overwritten
    ...    by next download operation and corresponding fault Previously downloaded plan overwritten will be raised
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/TAT-20154_SyVe_CM_Plan_Overwrite_Notification_LTE2621.png
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    Maintainer-I_NSB_MN_SRAN_PROD_HZH_OPER1_VRF@internal.nsn.com
    Step 1: Prepare the Plan Infor
    Step 2: TC parameters check
    Step 3: Check initial BTS state
    Step 4: Check initial alarms status from WebEM
    Step 5: Check initial alarms status from Netact
    Step 6: Upload configuration status
    Step 7: Create and Edit SyVe Plan 1
    Step 8: Download the Plan 1 SyVe
    Step 9: Download the Plan 1 SyVe
    Step 10: Check Existed Expected Alarm
    Step 11: Create and Edit SyVe Plan 2
    Step 12: Download the Plan 2 SyVe
    Step 13: Check Existed Expected Alarm
    Step 14: Activate the Plan 1 Failed
    Step 15: Reset SBTS
    Step 16: Check NON-Existed Expected Alarm
    Step 17: Create and Edit SyVe Plan 3
    Step 18: Download the Plan 3 SyVe
    Step 19: Create and Edit SyVe Plan 4
    Step 20: Provision the Plan 4 SyVe
    Step 21: Check modified parameter in Netact after provision Plan 4
    Step 22: Provision the backup plan
    Step 23: Check final alarms status from WebEM
    Step 24: Check final alarms status from Netact
    Step 25: Check final BTS state
    Step 26: Check final number and state of Cells and RMs

Step ${index}: Prepare the Plan Infor
    Log    Step ${index}: Prepare the Plan Infor    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    &{dic_btsName}    Create Dictionary    btsName=SyVeAuto-${mrbts_id}
    &{plan_info}    Create Dictionary    scf_distName=MRBTS-${mrbts_id}    mo_id=${MRBTS_DN}    parameter=${dic_btsName}
    Set Test Variable    ${plan_info}

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check  console=True
    ${parameter}    Create Dictionary    btsName=MRBTS-${mrbts_id}_Plan4
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...    &{parameter}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!
    ...    level=ERROR
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${same_values}

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
    ...    ELSE    Run Keywords    Wait Until Keyword Succeeds    10 min    30 sec    Get and Check Alarms SyVe
    ...    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    AND    Excepted Alarm Be Cleared From NetAct And WebEM    7115    4340
    Run Keyword If    "${Existed}" == "Existed"    Wait Until Keyword Succeeds    10 min    30 sec    Get and Check Alarms SyVe    source=Netact
    ...    expected_alarms=${EXPECTED_ALARMS}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}
    ...    ELSE    Wait Until Keyword Succeeds    10min    30 sec    Get and Check Alarms SyVe    source=Netact
    ...    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and Edit SyVe Plan ${number}
    Log    Step ${index}: Create and Edit SyVe Plan ${number}    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${Time_From}    ${year}.${month}.${day} ${hour}:${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name_${number}}    MRBTS-${mrbts_id}_Plan${number}
    Append To List    ${Plan_List}    ${name_${number}}
    Log    ${plan_info['parameter']}    console=True
    ${parameter}    Create Dictionary    btsName=${name_${number}}
    ${plan}    NetAct Create And Edit Plan    name=${name_${number}}    description=Automation SyVe for MRBTS-${mrbts_id}_Plan${number}
    ...    mo_id=${plan_info['mo_id']}    scf_distName=${plan_info['scf_distName']}    &{parameter}
    Set Test Variable    ${plan}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_${number}}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name_${number}}    operation_type=plan

Step ${index}: Download the Plan ${number} SyVe
    Log    Step ${index}: Download the Plan ${number} SyVe    console=True
    NetAct Provision Plan    plan_name=${name_${number}}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=preactivate

Step ${index}: Activate the Plan ${number} ${result}
    Log    Step ${index}: Activate the Plan ${number} ${result}    console=True
    ${rel_validate}    Run Keyword If    "${result}" == "Failed"    Run Keyword And Expect Error    *    netact.Activate Preactivated Plan
    ...    plan_name=${name_${number}}
    ...    dist_names=${MRBTS_DN}
    ...    ELSE    netact.Activate Preactivated Plan    plan_name=${name_${number}}    dist_names=${MRBTS_DN}
    Run Keyword If    "${result}" == "Failed"    Should Contain    ${rel_validate}    BTS is not ready due to no planId

Step ${index}: Provision the Plan ${number} SyVe
    Log    Step ${index}: Provision the Plan ${number} SyVe    console=True
    ${NA_index}    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmdstr1}    Set Variable    racclimx.sh -planName ${name_${number}} -DN ${MRBTS_DN} -createBackupPlan true -v -provisioningOperation activate
    ${cmdstr2}    Set Variable    -backupPlanName MRBTS-${mrbts_id}_Backup -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmdstr1} ${cmdstr2}
    Wait Until Keyword Succeeds    30x    0.5s    coam.Assert Alarm Active    faultId=4340
    Wait Until Keyword Succeeds    30x    1s    coam.Assert Alarm Inactive    faultId=4340
    ${NA_prov_result}    SSHLibrary.Read Command Output
    Should Not Contain    ${NA_prov_result}    FAILURE
    Should Contain    ${NA_prov_result}    Activation successful:Provision of the plan was successful

Step ${index}: Check modified parameter in Netact after provision Plan ${number}
    Log    Step ${index}: Check modified parameter in Netact after provision Plan ${number}    console=True
    ${parameter}    Create Dictionary    btsName=${name_${number}}
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    &{parameter}

Step ${index}: Reset SBTS
    Log    Step ${index}: Reset SBTS    console=True
    coam.Reset_Site    timeout=300
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=MRBTS-${mrbts_id}_Backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=MRBTS-${mrbts_id}_Backup    operation_type=plan
    NetAct Provision Plan    plan_name=MRBTS-${mrbts_id}_Backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

TC Setup
    Common Test Setup

TC Teardown
    Log    TC Teardown    console=True
    FOR    ${plan}    IN    @{Plan_List}
        Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan}
    END
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    MRBTS-${mrbts_id}_Backup
    Common Test Teardown
