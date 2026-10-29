*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTERatReset/CM_LTERatReset_para.yaml
@{SELECTED_TYPE}    LTE_RAT_RESET
${NEED_TO_CHECK_5G_RAT_STATUS}    True

*** Keywords ***
TC__SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18566
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from NetAct with LTE RAT reset modification
    ...    based on SELECTED_TYPE
    ...
    ...    The main steps performed for the test are:
    ...    - TC parameters check
    ...    - Random Select Parameter
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check Reset LTE Behavior
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Provision the backup plan
    ...    - Check Reset LTE Behavior
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
    ...    - 13.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18566
    ...    - SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification
    ...    - 02.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 02.23.2022 - Modified by Bin.7.Liu - https://jira3.ext.net.nokia.com/browse/TAT-22714
    ...    - Select MOs and Parameters randomly
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      Add logic in 'Check Reset LTE Behavior' to check other RAT will not be affect when LTE RAT resart.
    ...    - 08.10.2023 - Modified by Kang Lixin - Update to unify keyword to get json test data parameters for ui/non-ui mapping
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image::http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...     TAT-18566_SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_LTE_RAT_Reset_Modification.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: TC parameters check
    Step 2: Random Select Parameter
    Step 3: Check initial BTS state
    Step 4: Check initial alarms status from WebEM
    Step 5: Check initial alarms status from Netact
    Step 6: Upload configuration status
    Step 7: Create and edit plan SyVe
    Step 8: Export the plan SyVe
    Step 9: Provision the plan SyVe
    Step 10: Check Reset LTE Behavior
    Step 11: Check modified parameter in Netact after provision plan
    Step 12: Check modified parameter in Admin after provision plan
    Step 13: Provision the backup plan
    Step 14: Check Reset LTE Behavior
    Step 15: Check final alarms status from WebEM
    Step 16: Check final alarms status from Netact
    Step 17: Check final BTS state
    Step 18: Check final number and state of Cells and RMs

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check  console=True
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    ui_values=false    &{plan_info['parameter']}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${same_values}

Step ${index}: Random Select Parameter
    Log    Step ${index}: Random Select Parameter    console=True
    ${plan_info}    ${plan_info_ui}    ${expect_status}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Set Test Variable    ${plan_info}
    Set Test Variable    ${plan_info_ui}
    Log    ${plan_info}    console=True

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
    ...    critical_alarms=${CRITICAL_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}    dist_name=${MRBTS_DN}

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
    ${cmd1}    Set Variable   racclimx.sh -planName ${name} -DN ${MRBTS_DN}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${name}_backup
    ${cmd3}    Set Variable    -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    ui_values=false
    ...    &{plan_info['parameter']}

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan    console=True
    Check WebEM After Modify Parameters    ${plan_info_ui['scf_distName']}    &{plan_info_ui['parameter']}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable   racclimx.sh -planName ${name}_backup -DN ${MRBTS_DN}
    ${cmd2}    Set Variable    -createBackupPlan false -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Check Reset ${techno} Behavior
    Log    Step ${index}: Check Reset ${techno} Behavior    console=True
    FOR    ${index}    IN RANGE    0    800
        ${result}    ${rat_status}=    Run Keyword And Ignore Error    Check ${techno} RAT status
        Check Other RAT Status Enabled
        ${reset}    run keyword and return status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        Exit For Loop If    ${reset}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful
    Should Be Equal As Strings    ${reset}    True
    FOR    ${index}    IN RANGE    0    120
        ${cells_Status}    Run Keyword And Return Status    coam.Assert Every    LNCEL    operationalState=${_Enabled_}
        Check Other RAT Status Enabled
        Exit For Loop If    ${cells_Status}
    END


Check ${rat_techo} RAT status
    ${rat}    String.Convert To Lower Case    ${rat_techo}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Check Other RAT Status Enabled
    ${gsm_state}    Run Keyword If    ${GSM_cell_ids}    Check GSM RAT status
    ${wcdma_state}    Run Keyword If    ${WCDMA_cell_ids}    Check WCDMA RAT status
    ${nr_state}    Run Keyword If    ${NRBTS_cell_ids} and ${NEED_TO_CHECK_5G_RAT_STATUS}    Check NR RAT status
    Run Keyword If    ${GSM_cell_ids}    Should Be Equal As Strings    ${gsm_state}    ALL_ENABLED
    Run Keyword If    ${WCDMA_cell_ids}    Should Be Equal As Strings    ${wcdma_state}    ALL_ENABLED
    Run Keyword If    ${NRBTS_cell_ids} and ${NEED_TO_CHECK_5G_RAT_STATUS}    Should Be Equal As Strings
    ...    ${nr_state}    ALL_ENABLED

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}
    Run Keyword If    ${plan_values} and not ${same_values}    Run Keywords
    ...    Log    Parameters were not reset to initial values! Probably backup plan was not provisioned!     level=WARN
    ...    AND    Log     Will perform commissioning with initial scf!    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

Check ${techno} Cells Operational State ${state}
    Run Keyword If    ${${techno}_cell_ids}    coam.Assert Every    ${techno[0]}NCEL    operationalState=${state}

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
