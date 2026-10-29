*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTE_Cell_Locking/CM_LTE_Cell_Locking_para.yaml
@{SELECTED_TYPE}    LTE_CELL_LOCK
${PROVISION_4G_RAT_OUTAGE_DURATION_STANDARD}    180

*** Keywords ***
TC__SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    [Documentation]    [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23549
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from NetAct with cell lock unlock
    ...    based on selected parameter from test data file.
    ...
    ...    The main steps performed for the test are:
    ...    - TC parameters check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe And Check SBTS Action
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; lock/unlock LNCEL work as expected;
    ...    states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23549 - SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G
    ...    - 06.12.2023 - Updated by kang lixin - update wireshark collection logic and add checkpoint for
    ...      RmtOAM_CM_Delta_configuration_plan_to_provision_operation_from_WebEM_for_cOAM_SBTS_RP002086_036_Automated
    ...    - 21.2.2025 - Updated By Xu Yuyan for LTE NBIOT cell
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-23549_SyVe_CM_Cell_Locking_After_Recommission_via_NetAct_4G.png
    Set Tags    SyVe    AUTHOR-bin.7.liu@nokia.com    PHASE-CRT    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 0: TC parameters check
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create and edit plan SyVe
    Step 6: Export the plan SyVe
    Step 7: Provision the plan SyVe And Check SBTS Action
    Step 8: Check modified parameter in Netact after provision plan
    Step 9: Check modified parameter in Admin after provision plan
    Step 10: Provision the backup plan
    Step 11: Check final alarms status from WebEM
    Step 12: Check final alarms status from Netact
    Step 13: Check final BTS state
    Step 14: Check final number and state of Cells and RMs

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check    console=True
    ${plan_info}    ${plan_info_ui}    ${expect_status}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Set Test Variable    ${plan_info}
    Set Test Variable    ${plan_info_ui}
    Set Test Variable    ${expect_status}
    Log    ${plan_info}    console=True
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...    &{plan_info['parameter']}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!
    ...    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${same_values}
    ${LTE_IOTCell_mapping_dic}    Admin Get LTE CELL IOT mapping list
    log    ${LTE_IOTCell_mapping_dic}
    ${LTE_IOTCell_mapping_keys}    Get Dictionary Keys    ${LTE_IOTCell_mapping_dic}
    ${additional_cell_dn}    Set Variable    None
    FOR    ${host_cell}    IN    @{LTE_IOTCell_mapping_keys}
        ${nbiot_cell_rt}    Set Variable   ${LTE_IOTCell_mapping_dic["${host_cell}"]}
        Run Keyword If    "${nbiot_cell_rt}"!="None" and "${plan_info["scf_distName"].split("-")[-1]}"=="${host_cell.split("-")[-1]}"
        ...    Run Keywords    Set Test Variable    ${additional_cell_dn}    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${nbiot_cell_rt.split("-")[-1]}
        ...    AND    Exit For Loop
        Run Keyword If    "${nbiot_cell_rt}"!="None" and "${plan_info["scf_distName"].split("-")[-1]}"=="${nbiot_cell_rt.split("-")[-1]}"
        ...    Run Keywords    Set Test Variable    ${additional_cell_dn}    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${host_cell.split("-")[-1]}
        ...    AND    Exit For Loop
    END
    return from keyword If    "${additional_cell_dn}"=="None"
    ${MOes_status}    Set Variable    ${expect_status.split(";")}
    FOR    ${MO_Status}    IN    @{MOes_status}
        Set Test Variable    ${expect_status}    ${expect_status};${additional_cell_dn}:${MO_Status.split(":")[1]}:${MO_Status.split(":")[2]}
    END
    Log    ${expect_status}

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

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}    mo_id=${plan_info['mo_id']}
    ...    scf_distName=${plan_info['scf_distName']}    &{plan_info['parameter']}
    Set Test Variable    ${plan}
    Set Test Variable    ${mrbts_id}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}    plan_name=${name}
    ...    operation_type=plan

Step ${index}: Provision the plan SyVe And Check SBTS Action
    Log    Step ${index}: Provision the plan SyVe And Check SBTS Action    console=True
    Start TCPDump On SBTS Common
    SSHLibrary.Open Connection    ${NETACT['was_host']}    alias=provision
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmdstr1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true -backupPlanName ${name}_backup
    ${cmdstr2}    Set Variable   -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command     ${cmdstr1} ${cmdstr2}
    ${list_record_of_change1}    Get BTS Key MOs Status Duration Until Expected Changes    ${expect_status}
    ${list_record_of_change2}    Get BTS Key MOs Status Duration Until All Online
    ${list_record_of_change}    Combine Lists    ${list_record_of_change1}    ${list_record_of_change2}
    ${dic_key_MOs_status_duration}    Combine Changes Of BTS Key MOs Status    ${list_record_of_change}
    ${ignore_type}    Create List    site    rmod    bbmod
    Check BTS Key MOs Status Duration    ${dic_key_MOs_status_duration}    ${expect_status}    @{ignore_type}
    Sleep    10s    #Time for the delay of CCN for parameter changed.
    Stop TCPDump And Check CCN Messages For Param Update    ${plan_info_ui['parameter']}
    SSHLibrary.Switch Connection    provision
    [Teardown]    SSHLibrary.Read Command Output    return_rc=${True}    return_stderr=${True}

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan   console=True
    Check WebEM After Modify Parameters    ${plan_info['scf_distName']}    &{plan_info['parameter']}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    ${start_time}    Get Time
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    ${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<${PROVISION_4G_RAT_OUTAGE_DURATION_STANDARD}
    Wait Until Keyword Succeeds    10 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${same_values}    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...    &{plan_info['parameter']}
    Run Keyword If    ${same_values}    Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Log    TC Setup    console=True
    Common Test Setup

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown
