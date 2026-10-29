*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: Shifu Lan
...              Contact: shifu.lan@nokia-sbell.com

Library           taf.rfrl.cbts.utilities.generic_utils
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/cloud_analysis.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          taf/rfrl/cbts/robot/ru/ru_operations.robot
Resource          taf/rfrl/cbts/robot/vcu/vcu_fm.robot
Resource          taf/rfrl/cbts/robot/vdu/vdu_fm.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot

*** Keywords ***
Cloud Suite Setup
    [Documentation]    This keyword sets up the cloud suite.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first logs the start of the suite setup, generates a log path, and sets it as a suite variable.
    ...    It then gets the paths of the golden SCF files for the vDU and vCU and sets them as suite variables.
    ...    If commissioning is True, it performs a full commission operation for the cloud suite.
    ...    It then gets the BTS ID from the SCF file and logs it.
    ...    Finally, suite_setup_flag sets to True if suite setup was successful.
    ...    if_commissioning: Default value is True, Can be covered by variables definition in test cases file
    ...    update by jie.2.li@nokia-sbell.com: 2024-08-01 https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10335
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...
    ...    | =Return Values= | =Description= |
    log to console    ******Cloud Setup Suite******
    set suite variable    ${suite_setup_flag}    ${False}
    ${SUITE_LOG_PATH}    generic_utils.generate_log_path_with_log_type
    Set Suite Variable    ${SUITE_LOG_PATH}
    set suite variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    ${Golden_VDU_SCF_Path}    Cloud Get Golden SCF Path    cu_or_du=DU
    set suite variable    ${Golden_VDU_SCF_Path}
    ${Golden_CU_SCF_Path}    Cloud Get Golden SCF Path    cu_or_du=CU
    set suite variable    ${Golden_CU_SCF_Path}
    set suite variable    ${suite_setup_fail_flag}    ${True}
    run keyword if     ${if_commissioning}    Cloud Full Commission    cu_scf_path=${Golden_CU_SCF_Path}    vdu_scf_path=${Golden_VDU_SCF_Path}
    ${mrbts_id}   ${nrbts_id}    Cloud Get BTS ID From SCF    scf_path=${Golden_VDU_SCF_Path}
    Set Suite Variable    ${mrbts_id}
    Set Suite Variable    ${nrbts_id}
    log to console    vdu mrbts_id is ${mrbts_id}, vdu nrbts_id is ${nrbts_id}
    ${mrbts_id_cu}   ${nrbts_id_cu}    Cloud Get BTS ID From SCF    scf_path=${Golden_CU_SCF_Path}
    Set Suite Variable    ${mrbts_id_cu}
    Set Suite Variable    ${nrbts_id_cu}
    log to console    cu mrbts_id is ${mrbts_id_cu}, cu nrbts_id is ${nrbts_id_cu}
    set suite variable    ${suite_setup_flag}    ${True}
    Run Keyword And Ignore Error    Fix OCP Syslog Format    # https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10335

Cloud Suite Teardown
    [Documentation]    This keyword performs the teardown operations for the cloud suite.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first logs the start of the suite teardown.
    ...    If the save_snapshot flag is set and the suite setup was not successful, it saves a snapshot and logs.
    ...    Otherwise, it logs that no snapshot will be collected in the suite teardown.
    ...    Finally, it terminates all processes.
    ...    save_snapshot: Default value is True, Can be covered by variables definition in test cases file
    ...    suite_setup_flag: Value from 'Cloud Setup Suite', if the suite setup was successful, the value is True, otherwise False
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...
    ...    | =Return Values= | =Description= |
    log to console    *****Cloud Suite Teardown*****
    run keyword if    ${save_snapshot} and not ${suite_setup_flag}    Cloud Save Snapshot and Log
    ...    ELSE
    ...    log to console    don't collect snapshot in suite teardown!!!
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

Cloud Test Setup
    [Documentation]    This keyword sets up the cloud test.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first logs the start of the test setup and generates a log path, which is then set as a test variable.
    ...    It then checks if all Rmods and cells are on air for the vDU and vCU.
    ...    If not, it performs a full commission operation for the cloud suite.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...
    ...    | =Return Values= | =Description= |
    log to console    *****Cloud Test Setup*****
    ${TS_CASE_LOG_PATH}    generic_utils.generate_log_path_with_log_type
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    log to console  case log path:${TS_CASE_LOG_PATH}
    ${vdu_ru_status}    run keyword and return status    All Rmods Should Be Onair For One Specific vDU
    ${vdu_cell_status}    run keyword and return status    All Cells Should Be Onair For One Specific vDU
    ${cu_cell_status}    run keyword and return status    All Cells Should Be Onair For One Specific vCU
    ${Status}    ${key}   run keyword and ignore error   Get Customized Scf From Tag
    ${CU_SCF_Path}    set variable if    '${Status}'=='PASS'    ${key}[0]    ${Golden_CU_SCF_Path}
    ${vDU_SCF_Path}    set variable if    '${Status}'=='PASS'    ${key}[1]    ${Golden_VDU_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[2]    ${False}
    Set Test Variable    ${Case_CU_SCF_Path}    ${CU_SCF_Path}
    Set Test Variable    ${Case_vDU_SCF_Path}    ${vDU_SCF_Path}
    run keyword if    not (${vdu_ru_status} and ${vdu_cell_status} and ${cu_cell_status}) or ${SCF_Status}
    ...    Cloud Full Commission    cu_scf_path=${CU_SCF_Path}    vdu_scf_path=${vDU_SCF_Path}

Cloud Test Teardown
    [Documentation]    This keyword performs the teardown operations for the cloud test.
    ...    *Author* tingting.zhong@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *Detail*
    ...    It first logs the start of the test teardown.
    ...    It then checks if all Rmods and cells are on air for the vDU and vCU.
    ...    If not, it raises an error.
    ...    It then checks if there are any unexpected active alarms raised in vDU and vCU.
    ...    If the test failed and the save_snapshot flag is True, it saves a snapshot and logs..
    ...    Otherwise, it logs that no snapshot will be collected in the test teardown.
    ...    Vdu/cu default not allowed fault in taf.rfrl.cbts: '0010', '0016', '1806', '1868', '4341', '4352', '4383', '4350'
    ...    Other faults are allowed to be raised in the test.
    ...    save_snapshot: Default value is True, Can be covered by variables definition in test cases file
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...
    ...    | =Return Values= | =Description= |
    log to console    *****Cloud Test Teardown *****
    All Rmods Should Be Onair For One Specific vDU
    All Cells Should Be Onair For One Specific vDU
    All Cells Should Be Onair For One Specific vCU
    vdu_fm.Checking No unexpected Active Alarms Raised    user_unexpected_alarms=@{EMPTY}
    vcu_fm.Checking No unexpected Active Alarms Raised    user_unexpected_alarms=@{EMPTY}
    ${test_result_flag}    run keyword if test failed    set variable    ${false}    ${True}
    run keyword if    ${save_snapshot} and ${test_result_flag}    Cloud Save Snapshot and Log
    ...    ELSE
    ...    log to console    don't collect snapshot in test teardown!!!
    CI_interface.Common Case Teardown
