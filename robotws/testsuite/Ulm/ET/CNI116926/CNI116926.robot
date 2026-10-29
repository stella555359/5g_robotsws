*** Settings ***

Documentation
...    Author: VRF_ULM_VT6
...    Contact: I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
...    Description: CNI-116926 RACH Troubleshooting Improvements in L2-PS TTI Traces
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ../resources/SQD68/pmc_analysis.py    WITH NAME  validation

Resource   ../L2/resources/robot/test_setup.robot
Resource   ../L2/resources/common_keywords.robot
Resource   ../L2/resources/robot/tracing.robot
Resource   ../CNI116926/resources/CNI116926_scenario_modifications.robot
Resource   ../CNI116926/resources/CNI116926_scenario_validations.robot



Suite Setup     Run Keywords
...             test_setup.Initialize Test Suite                        AND
...             validation.Prepare For PM Counter Testing
Suite Teardown  Run Keywords
...             common_keywords.Capture Snapshot And Restore Config     AND
...             validation.Finalise PM Counter Testing
Test Teardown   common_keywords.Stop Logs And Collect Traces



*** Variables ***
${num_slots_per_frame}            ${20}
${pm_reporting_interval}          5min
${relative_json_path}             ../../CNI116926/CNI116926.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

L3Call_MUE_on_SingleCell_with_Reesteblishments
    [Tags]  CRT
    common_keywords.Run Test Scenario
    CNI116926_scenario_validations.Verify L3Call_MUE_on_SingleCell_with_Reesteblishments
    tracing.Check For Errors In Syslog



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***
OFFLINE
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    # and do not forget to comment out *** Keywords ***
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/logs/CNI116926/2025-07-14T11-35-51-P/CNI116926/SBTS00_ENB_9999_250710_000006/20250714_113639
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CNI116926_scenario_validations.Verify L3Call_MUE_on_SingleCell_with_Reesteblishments
