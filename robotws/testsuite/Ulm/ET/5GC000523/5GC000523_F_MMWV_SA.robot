*** Settings ***
Documentation   Test cases for 5GC000523-F regression with Airphone(cmW) and CB008285 "FR2 Standalone PCell"
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../5GC000523/resources/5G523_scenario_modifications.robot
Resource    ../L2/resources/robot/test_setup.robot
Resource    ../L2/resources/common_keywords.robot
Resource    ../L2/resources/robot/tracing.robot
Resource    ./resources/5G523_validation.robot


Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces


*** Variables ***
${pm_reporting_interval}            5min
${relative_json_path}               ../../5GC000523/5GC000523_F_MMWV_SA.json
${validation_preparation_complete}  ${False}
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***
5GC000523_F_NR_Cell_Utilization_Counters
    [Tags]  CRT
    common_keywords.Run Test Scenario
    5G523_validation.Generate Verdict For 5GC000523_F_NR_Cell_Utilization_Counters
    5G523_validation.Generate Verdict For 5GC000523_F_NR_UL_Signal_Quality_Level_Measurements
    5G523_validation.Generate Verdict For 5GC000523_F_TA_Counters
    tracing.Check For Errors In Syslog


*** Keywords ***
5GC000523_F_TA_Counters
    [Tags]  CRT
    common_keywords.Run Test Scenario
    5G523_validation.Generate Verdict For 5GC000523_F_TA_Counters


5GC000523_F_NR_UL_Signal_Quality_Level_Measurements
    [Tags]  CRT
    common_keywords.Run Test Scenario
    5G523_validation.Generate Verdict For 5GC000523_F_NR_UL_Signal_Quality_Level_Measurements


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***
OFFLINE
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/test_repository/5GC000523_F_MMWV_SA/SBTS00_ENB_9999_240205_000010/20240207_095722
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    Set Suite Variable  ${pm_counters_dir}            ${result_base_dir}/Logs/PMC/gnb_pm_counters/
    ${pCell_dict}=  Create Dictionary
    Set To Dictionary  ${pCell_dict}  NRCELL-1=${50}   NRCELL-2=${51}
    Log  ${pCell_dict}
    Set Suite Variable   ${pCell_dict}
    test_setup.Set SW Wavelength Variable According To Nrarfcn
    5G523_scenario_modifications.Set SW POSTFIX Variable
    5G523_validation.Generate Verdict For 5GC000523_F_TA_Counters
    5G523_validation.Generate Verdict For 5GC000523_F_NR_UL_Signal_Quality_Level_Measurements
    5G523_validation.Generate Verdict For 5GC000523_F_NR_Cell_Utilization_Counters
