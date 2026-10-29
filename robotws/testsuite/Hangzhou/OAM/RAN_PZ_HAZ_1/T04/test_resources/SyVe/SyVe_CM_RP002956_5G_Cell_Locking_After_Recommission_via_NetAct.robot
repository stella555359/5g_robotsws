*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRObject_Locking/CM_NR_Locking_para.yaml
@{SELECTED_TYPE}    NR_CELL_LOCK
${PROVISION_5G_RAT_OUTAGE_DURATION_STANDARD}    160

*** Keywords ***
SyVe_CM_RP002956_5G_Cell_Locking_After_Recommission_via_NetAct
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21107
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from NetAct with 5G cell locking parameter modification
    ...    based on random select parameter in json file
    ...    The main steps performed for the test are:
    ...    - Random Select Parameter
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
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.03.2021 - https://jira3.int.net.nokia.com/browse/TAT-21107
    ...    - SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_RP002956_5G
    ...    - 02.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking
    ...    - 11.05.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22175
    ...    - [SyVe]Optimize case can read parameter value with units
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    Remove ${lnbts_id} Fetch LNBTS ID
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...    - 01.11.2023 - Modified by Kang Lixin - Update to unify testdata and keyword to get json test data parameters for ui/non-ui mapping
    ...    - 09.04.2024 - Modified by Kang Lixin - Add time kpi for CB012145
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-21107_SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_RP002956_5G.png
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: Random Select Parameter
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check modified parameter in Netact after provision plan
    Step 10: Check modified parameter in Admin after provision plan
    Step 11: Provision the backup plan
    Step 12: Check final alarms status from WebEM
    Step 13: Check final alarms status from Netact
    Step 14: Check final BTS state
    Step 15: Check final number and state of Cells and RMs

Step ${index}: Random Select Parameter
    Log    Step ${index}: Random Select Parameter    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    ${plan_info}    ${plan_info_ui}    ${expect_status}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Set Test Variable    ${plan_info}
    ${NRCell_config}    Set Variable    ${plan_info["scf_distName"]}
    ${NRCells_list}    Fetch ID Mapping From Admin For Cells    NRBTS
    ${NRCells_Unlock_RTDN_list}    Create List
    Set Test Variable    ${NRCells_Unlock_RTDN_list}
    ${NRCELL_RT_DN}    Set Variable
    FOR    ${item}    IN    @{NRCells_list}
        ${config}    Get From Dictionary    ${item}    configuration
        ${RT_DN}    Get From Dictionary    ${item}    internal
        Run Keyword If    '${config}'=='${NRCell_config}'    Run Keywords    Set Test Variable     ${NRCELL_RT_DN}    ${RT_DN}
        ...    AND    Continue For Loop
        Append To List    ${NRCells_Unlock_RTDN_list}    ${RT_DN}
    END

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

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${plan_info['mo_id']}    scf_distName=${plan_info['scf_distName']}    &{plan_info['parameter']}
    Set Test Variable    ${plan}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${name}_backup -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command     ${cmd1} ${cmd2} ${cmd3}
    Log    Check Action    console=True
    ${result1}    Set Variable    ${False}
    ${result2}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    20
        sleep    3s
        ${result_tmp}    Run Keyword and Return Status    coam.Assert    NRCEL    ${NRCELL_RT_DN}    ${cells_NR_offline_state}
        ${result1}    Set Variable If    ${result1}    ${result1}    ${result_tmp}
        Check Other Objects On Air
    END
    FOR    ${index}    IN RANGE    0    20
        sleep    3s
        ${result_tmp}    Run Keyword and Return Status    coam.Assert    NRCEL    ${NRCELL_RT_DN}    ${cells_NR_expected_state}
        ${result2}    Set Variable    ${result_tmp}
        Check Other Objects On Air
        Exit For Loop If    ${result_tmp}
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful
    Should Be True    ${result1}
    Should Be True    ${result2}

Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}    console=True
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}
    ${parameter_names}    Get Dictionary Keys    ${plan_info['parameter']}
    ${status}    ${current_param_value}    Run Keyword And Ignore Error    Get Actual Parameter Value From NetAct
    ...    ${plan_info['mo_id']}    ${parameter_names[0]}    ui_values=true
    Set Test Variable    &{parameter_ui}    ${parameter_names[0]}=${current_param_value}

Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}    console=True
    Check WebEM After Modify Parameters    ${plan_info['scf_distName']}    &{parameter_ui}

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
    Final Checks SyVe

Check Other Objects On Air
    FOR    ${item}    IN    @{NRCells_Unlock_RTDN_list}
        coam.Assert    NRCEL    ${item}    ${cells_NR_expected_state}
    END
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
    ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every    GNCEL
    ...    ${cells_GSM_expected_state}       timeout=30
    ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every    WNCEL
    ...    ${cells_WCDMA_expected_state}        timeout=30
    ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status    coam.Assert Every    LNCEL
    ...    ${cells_LTE_expected_state}        timeout=30
    Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
    Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}
    Run Keyword If    ${plan_values}    Run Keywords
    ...    Log     Parameters were not reset to initial values! Probably backup plan was not provisioned!   level=WARN
    ...    AND    Log     Will perform commissioning with initial scf!      level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Log    TC Setup    console=True
    Common Test Setup

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown
