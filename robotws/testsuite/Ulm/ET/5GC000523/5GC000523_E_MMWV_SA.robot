*** Settings ***

Documentation   Test cases for 5GC000523-E regression with Airphone(cmW) and CB008285 "FR2 Standalone PCell"
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource  ../5GC000523/resources/5G523_scenario_modifications.robot
Resource  ../L2/resources/robot/test_setup.robot
Resource  ../L2/resources/common_keywords.robot
Resource  ../L2/resources/robot/tracing.robot
Resource  resources/5G523_validation.robot

Library   resources/libraries/scheduling_request_analyzer.py     WITH NAME    sr_csi_analyzer
Library   resources/libraries/csi_report_verdict.py              WITH NAME    csi_report_analyzer
Library   String


Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces


*** Variables ***

${num_slots_per_frame}              ${20}
${pm_reporting_interval}            5min
${relative_json_path}               ../../5GC000523/5GC000523_E_MMWV_SA.json
${validation_preparation_complete}  ${False}
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}



*** Test Cases ***

5GC000523_E_US1_Handling_of_Scheduling_Request
    [Tags]   CRT
    common_keywords.Run Test Scenario
    5G523_validation.Generate Verdict For 5GC000523_E_US1_Handling_of_Scheduling_Request
    tracing.Check For Errors In Syslog



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***
OFFLINE
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/test_repository/5GC000523_E/SBTS00_ENB_9999_221212_000012/20221212_182022
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    5G523_validation.Generate Verdict For 5GC000523_E_US1_Handling_of_Scheduling_Request
