*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
@{SELECTED_TYPE}    NR_RAT_RESET
${NEED_TO_CHECK_LTE_RAT_STATUS}    True
${ACTIVE_5G_OUTAGE_DURATION_STANDARD}    105
${PROVISION_5G_RAT_OUTAGE_DURATION_STANDARD}    160

*** Keywords ***
SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-20852
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from NetAct with online parameter modification
    ...    based on random select parameter in json file
    ...    The main steps performed for the test are:
    ...    - Random Select Parameter
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check NR RAT reset
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Provision the backup plan
    ...    - Check final number and state of Cells and RMs
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.12.2020 - https://jira3.int.net.nokia.com/browse/TAT-20852
    ...    - SyVe_CM_Verify_RAT_Reset_After_Recommission_Via_NetAct_RP002956_5G
    ...    - 02.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking and add step 9 10 11
    ...    - 11.05.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22175
    ...    - [SyVe]Optimize case can read parameter value with units
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      Add logic: 'Run Keyword If  ${xxx_cell_ids} Check xxx RAT status' in KW: 'Check Other RAT Status Enabled',
    ...    means not check RAT status if RAT is not exist
    ...      Add logic in 'Check Reset LTE Behavior' to check other RAT will not be affect when LTE RAT resart.
    ...    - 08.10.2023 - Modified by Kang Lixin - Update to unify keyword to get json test data parameters for ui/non-ui mapping
    ...    - 09.04.2024 - Modified by Kang Lixin - Add time kpi for CB012145
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-20852_SyVe_CM_Verify_RAT_Reset_After_Recommission_Via_NetAct_RP002956_5G.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Random Select Parameter
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create and edit plan SyVe
    Step 6: Export the plan SyVe
    Step 7: Get initial BTS RESET info from blackbox file
    Step 8: Provision the plan SyVe
    Step 9: Check NR rat reset
    Step 10: Check Modified Parameter from Netact after Provision
    Step 11: Check Modified Parameter from Admin after Provision
    Step 12: Provision the backup plan
    Step 13: Get final BTS RESET info from blackbox file
    Step 14: Check BTS RESET behavior
    Step 15: Check final number and state of Cells and RMs
    Step 16: Check final alarms status from WebEM
    Step 17: Check final alarms status from Netact

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
    Admin Check Overall BTS Procedural State

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Wait Until Keyword Succeeds    10x    60 sec    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}
    ...    ignored_alarms=${IGNORED_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}     critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    unexpected_alarms=@{UNEXPECTED_ALARMS}     critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
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
    ${status}    Run Keyword And Return Status    netact.Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=${name}_backup    create_backup_plan=True
    ...    provisioning_operation=preactivate    ignore_errors=True
    Should Be True    ${status}
    ${start_time}    Get Time
    ${status}    Run Keyword And Return Status    netact.Activate Preactivated Plan  plan_name=${name}    dist_names=${MRBTS_DN}
    ${end_time}    Get Time
    Run Keyword If    ${status}    Log    Activate plan ${name} successfully done!    console=True
    ...    ELSE    Run Keywords    Log    Activate plan ${name} failed!    level=ERROR
    ...    AND    Fail    Activate plan ${name} failed!
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<${ACTIVE_5G_OUTAGE_DURATION_STANDARD}

Step ${index}: Check ${rat_techo} rat reset
    Log    Step ${index}: Check ${rat_techo} rat reset    console=True
    FOR    ${index}    IN RANGE    0    120
        sleep    3s
        ${result}    ${rat_status}=    run keyword and ignore error    Check ${rat_techo} RAT status
        Check Other RAT Status Enabled
        ${reset}    run keyword and return status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        exit for loop if    ${reset}
    END
    should be equal as strings    ${reset}    True
    FOR    ${index}    IN RANGE    0    120
        sleep    3s
        ${NRcells_Status}    Run Keyword And Return Status    coam.Assert Every    NRCEL    operationalState=${_Enabled_}
        Check Other RAT Status Enabled
        exit for loop if    ${NRcells_Status}
    END

Step ${index}: Check Modified Parameter from Netact after Provision
    Log    Step ${index}: Check Modified Parameter from Netact after Provision  console=True
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}

Step ${index}: Check Modified Parameter from Admin after Provision
    Log    Step ${index}: Check Modified Parameter from Admin after Provision   console=True
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
    Should Be True    ${time}<${PROVISION_5G_RAT_OUTAGE_DURATION_STANDARD}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Wait Until Keyword Succeeds    3x    10 sec    Final Checks SyVe

Check ${rat_techo} RAT status
    ${rat}    String.Convert To Lower Case    ${rat_techo}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Step ${index}: Get ${when} BTS RESET info from blackbox file
    [Documentation]    Get RESET info from blackbox file
    [Timeout]    15 min
    Log    Step ${index}: Get ${when} BTS RESET info from blackbox file    console=True
    Get BTS RESET info from blackbox file SyVe    when=${when}    target_ip=${SMOD1['TRS_IP']}

Check Other RAT Status Enabled
    ${gsm_state}    Run Keyword If    ${GSM_cell_ids}    Check GSM RAT status
    ${wcdma_state}    Run Keyword If    ${WCDMA_cell_ids}    Check WCDMA RAT status
    ${lte_state}    Run Keyword If    ${LTE_cell_ids} and ${NEED_TO_CHECK_LTE_RAT_STATUS}       Check LTE RAT status
    Run Keyword If    ${GSM_cell_ids}    Should Be Equal As Strings    ${gsm_state}    ALL_ENABLED
    Run Keyword If    ${WCDMA_cell_ids}    Should Be Equal As Strings    ${wcdma_state}    ALL_ENABLED
    Run Keyword If    ${LTE_cell_ids} and ${NEED_TO_CHECK_LTE_RAT_STATUS}    Should Be Equal As Strings
    ...    ${lte_state}    ALL_ENABLED

Step ${index}: Check BTS RESET behavior
    [Documentation]    Final RESET info is compared with initial RESET info: reset number is 0
    [Timeout]    10 min
    Log    Step ${index}: Check BTS RESET behavior    console=True
    Check BTS RESET behavior SyVe    0

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}
    Run Keyword If    ${plan_values}    Run Keywords
    ...    Log    Parameters were not reset to initial values! Probably backup plan was not provisioned!    level=WARN
    ...    AND    Log    Will perform commissioning with initial scf!    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
