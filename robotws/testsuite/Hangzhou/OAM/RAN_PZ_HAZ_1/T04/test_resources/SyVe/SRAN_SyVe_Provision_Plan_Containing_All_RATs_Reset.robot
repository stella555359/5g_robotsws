*** Settings ***
Documentation       Test case for SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset
...                 Author: Liu Bin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/Multi/test_data.yaml
@{SELECTED_TYPE}    LTE_RAT_RESET    GSM_RAT_RESET    WCDMA_RAT_RESET    NR_RAT_RESET
${COMMISSIONING_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml

*** Keywords ***
TC__SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21836
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from NetAct with all RATs reset parameter modification based on
    ...    random select parameter in json file.
    ...    Cases for EDA 01741150. Supplement the test of parallel restart scenarios of different rat and cell services.
    ...    Manual test case please see the attachments of JIRA ticket TAT-21836
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Get And Check SBTS Key MOs
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe And Check SBTS Action
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...
    ...    Pass criteria: All RATs reset successfully.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 22.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21836
    ...    - SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset
    ...    - 20.01.2022 - Modified by Liu Bin  - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      fix: Get Plan ->netact.Get Plan Configuration
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    image::
    ...    https://tatools.emea.nsn-net.net/static/hran_doc/
    ...    testsuite/SYVE/TAT-21836_SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset.png
    Set Tags    SyVe    AUTHOR-bin.7.liu@nokia.com    PHASE-CRT    OWNER-I_NSB_MN_RAN_PZ1_HAZ_OPER1_VRF@internal.nsn.com
    Step 1: Get And Check SBTS Key MOs
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create and edit plan SyVe
    Step 6: Export the plan SyVe
    Step 7: Provision the plan SyVe And Check SBTS Action
    Step 8: Provision the backup plan
    Step 9: Check final alarms status from WebEM
    Step 10: Check final alarms status from Netact

TC Setup
    Log    TC Setup    console=True
    Common Test Setup

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${scf_runtime_name_mapper}    ${dic_bts_infor}    Get BTS Key MOs Status
    ${is_all_service_ok}    Run Keyword And Return Status    Check BTS Key MOs Status All Online    ${dic_bts_infor}
    ${all_key_MOs_DN}    Get Dictionary Keys    ${scf_runtime_name_mapper}
    ${key_MOs_as_initial}    Run Keyword And Return Status    Lists Should Be Equal    ${INITIAL_KEY_MOs}
    ...    ${all_key_MOs_DN}
#    Run Keyword Unless    ${is_all_service_ok} and ${key_MOs_as_initial}    coam.Perform Commissioning
    Run Keyword If    not ${is_all_service_ok} or not ${key_MOs_as_initial}    coam.Perform Commissioning
    ...    bts_id=${mrbts_id}    scf_file=${COMMISSIONING_PATH}    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

Step ${index}: Get And Check SBTS Key MOs
    Log    Step ${index}: Get And Check SBTS Key MOs    console=True
    ${scf_runtime_name_mapper}    ${dic_bts_infor}    Get BTS Key MOs Status
    Check BTS Key MOs Status All Online    ${dic_bts_infor}
    ${all_key_MOs_DN}    Get Dictionary Keys    ${scf_runtime_name_mapper}
    ${gNbCuType}    Pop From Dictionary    ${dic_bts_infor}    gNbCuType    SA
    ${tmp_list}    Get Dictionary Keys    ${dic_bts_infor["site"]}    mrbtsID
    Set Test Variable    ${MRBTS_ID}    ${tmp_list[0].split('-')[1]}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/MRBTS-${MRBTS_ID}
    Set Test Variable    ${INITIAL_KEY_MOs}    ${all_key_MOs_DN}
    Set Test Variable    ${GNB_CU_TYPE}    ${gNbCuType}
    ${rats}    Get Dictionary Keys    ${dic_bts_infor['rat']}
    FOR    ${rat}    IN    @{rats}
        Continue For Loop If    "${dic_bts_infor['rat']['${rat}']}"!="NO_CELLS"
        ${type}    Convert To Upper Case    ${rat}
        Remove Values From List    ${SELECTED_TYPE}    ${type}_RAT_RESET
    END

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Check SBTS SMOD RMOD Cells Alarms
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    Set Test Variable    ${NAME}    ${TEST_NAME}_${mrbts_id}
    ${status}    ${plan}    Run Keyword And Ignore Error   netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    ${expect_status}    ${list_param_for_create_plan}    Get Parameters For NetAct Plan Due To Json File
    ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}    ${BTS_scf_initial}
    FOR    ${param}    IN    @{list_param_for_create_plan}
        LOG Dictionary    ${param['parameters']}
        ${managed_object}    netact.Create Managed Object    plan=${plan}    meta_class=${param['meta_class']}
        ...    meta_version=${param['meta_version']}    mo_id=PLMN-PLMN/${param['mo_id']}
        ...    operation=${param['operation']}    &{param['parameters']}
    END
    Set Test Variable    ${EXPECT_STATUS}    ${expect_status}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${NAME}.csv    dist_names=${MRBTS_DN}
   ...    plan_name=${NAME}    operation_type=plan

Step ${index}: Provision the plan SyVe And Check SBTS Action
    Log    Step ${index}: Provision the plan SyVe And Check SBTS Action    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}    alias=provision
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmd1}    Set Variable     racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true
    ${cmd2}    Set Variable     -backupPlanName ${name}_backup -v -provisioningOperation activate
    ${cmd3}    Set Variable     -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    ${list_record_of_change1}    Get BTS Key MOs Status Duration Until Expected Changes    ${EXPECT_STATUS}
    ${list_record_of_change2}    Get BTS Key MOs Status Duration Until All Online
    ${list_record_of_change}    Combine Lists    ${list_record_of_change1}    ${list_record_of_change2}
    ${dic_key_MOs_status_duration}    Combine Changes Of BTS Key MOs Status    ${list_record_of_change}
    ${ignore_type}    Create List    site    smod    rmod    bbmod
    Check BTS Key MOs Status Duration    ${dic_key_MOs_status_duration}    ${EXPECT_STATUS}    @{ignore_type}
    [Teardown]    SSHLibrary.Read Command Output    return_rc=${True}    return_stderr=${True}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
