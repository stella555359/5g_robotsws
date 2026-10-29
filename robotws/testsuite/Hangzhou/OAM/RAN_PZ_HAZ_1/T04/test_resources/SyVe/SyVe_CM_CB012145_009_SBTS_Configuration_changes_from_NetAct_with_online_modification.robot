*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}
...   /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/Online/CM_Online_para.yaml
@{SELECTED_TYPE}    ONLINE
${PROVISION_4G_ONLINE_DURATION_STANDARD}    130

*** Keywords ***
SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-12663
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from NetAct with online modification
    ...    based on SELECTED_TYPE
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-12663
    ...     - SyVe_CM_Configuration changes from NetAct with online modification
    ...    - 15.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-14040
    ...    - Check modified parameter doesn't work after use backup provision plan
    ...    - 28.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-14098
    ...    - Update KWs name SyVe to NetAct
    ...    - 08.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14416
    ...    - Use static Firefox profile for the Jnlp download
    ...    - 20.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15310
    ...    - Add extra check in all TCs involving plan provisioning to alert when same parameters values are provisioned
    ...    - 03.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15603
    ...    - Remove backup plans from NetAct after test is done
    ...    - 14.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-15962
    ...    - New expected alarmId for "LMP access via port xxxxx" alarm
    ...    - 27.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16639
    ...    - Adapt and check Syve test running on FlatOAM, no BTS MED usage
    ...    - 19.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17475
    ...    - Update ignored alarms list.
    ...    - 02.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    Add check status in teardwon after fullcommission.
    ...    - 02.23.2022 - Modified by Bin.7.Liu - https://jira3.ext.net.nokia.com/browse/TAT-22714
    ...    - Select MOs and Parameters randomly
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...    - 21.06.2022 - Modified by Kang Lixin - remove steps about btsmed
    ...    - 09.04.2024 - Modified by Kang Lixin - Add time kpi for CB012145
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-12663_CM__SyVe_SBTS_Configuration_changes_from_NetAct_with_online_modification_01.png
    Set Tags    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    TC parameters check
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create and edit plan SyVe
    Step 6: Export the plan SyVe
    Step 7: Provision the plan SyVe
    Step 8: Check modified parameter in Netact after provision plan
    Step 9: Check modified parameter in Admin after provision plan
    Step 10: Provision the backup plan
    Step 11: Check final alarms status from WebEM
    Step 12: Check final alarms status from Netact
    Step 13: Check final BTS state
    Step 14: Check final number and state of Cells and RMs

TC parameters check
    Log    TC parameters check started    console=True
    ${plan_info}    ${plan_info_ui}    ${expect_status}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Set Test Variable    ${plan_info}
    Set Test Variable    ${plan_info_ui}
    ${same_values}=    Run Keyword And Return Status
    ...   Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...   ui_values=false    &{plan_info['parameter']}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}
    ...    Log     TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!   level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True     ${same_values}

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains
    ...    informations   such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...   critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...   critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${plan_info['mo_id']}    scf_distName=${plan_info['scf_distName']}    &{plan_info['parameter']}
    Set Test Variable    ${plan}
    Set Test Variable    ${mrbts_id}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true
    ${cmd2}    Set Variable    -backupPlanName ${name}_backup -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    ${NEED_SCF_RECOVERY_FLAG}    Set Variable    True
    Log    Check Action    console=True
    FOR    ${index}    IN RANGE    0    30
        sleep    2s
        ${gncell_onair}    Run Keyword If      ${GSM_cell_ids}      Run Keyword And Return Status
        ...    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}    timeout=30
        ${wncell_onair}    Run Keyword If      ${WCDMA_cell_ids}    Run Keyword And Return Status
        ...    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}    timeout=30
        ${lncell_onair}    Run Keyword If      ${LTE_cell_ids}      Run Keyword And Return Status
        ...    coam.Assert Every    LNCEL    ${cells_LTE_expected_state}    timeout=30
        ${nrcell_onair}    Run Keyword If      ${NRBTS_cell_ids}    Run Keyword And Return Status
        ...    coam.Assert Every    NRCEL    ${cells_NR_expected_state}    timeout=30
        Run Keyword If    ${GSM_cell_ids}      Should Be True    ${gncell_onair}
        Run Keyword If    ${WCDMA_cell_ids}    Should Be True    ${wncell_onair}
        Run Keyword If    ${LTE_cell_ids}      Should Be True    ${lncell_onair}
        Run Keyword If    ${NRBTS_cell_ids}    Should Be True    ${nrcell_onair}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Check modified parameter in Netact after provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Netact after provision ${plan_type}    console=True
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    ui_values=false
    ...    &{plan_info['parameter']}

Step ${index}: Check modified parameter in Admin after provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Admin after provision ${plan_type}    console=True
    Check WebEM After Modify Parameters    ${plan_info_ui['scf_distName']}    &{plan_info_ui['parameter']}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    ${start_time}    Get Time
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    ${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<${PROVISION_4G_ONLINE_DURATION_STANDARD}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}
    Run Keyword If    ${plan_values} and not ${same_values}    Run Keywords
    ...   Log   Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
