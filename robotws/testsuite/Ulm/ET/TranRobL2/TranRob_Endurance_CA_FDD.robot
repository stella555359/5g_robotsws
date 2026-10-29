*** Settings ***

Documentation
...    Author: L2 SW Ulm
...    Contact: I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com
...    Description: Test Suite for Transversal_Robustness of Endurance
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    OperatingSystem
Library    ../resources/SQD68/pmc_analysis.py    WITH NAME  validation

Resource   ../L2/resources/robot/test_setup.robot
Resource   ../L2/resources/common_keywords.robot
Resource   ../L2/resources/robot/tracing.robot
Resource   ../TranRobL2/resources/TranRob_scenario_modifications.robot
Resource   ../TranRobL2/resources/TranRob_validation.robot


Suite Setup     Run Keywords
...             OperatingSystem.Run    mkdir -p /home/ute/Downloads/btslog2    AND
#Streaming the syslogs in a different folder to avoid that tmp is running out of space
...             OperatingSystem.Run    ln -s /home/ute/Downloads/btslog2 /tmp    AND
...             Set Library Search Order  TranRob_scenario_modifications         AND
...             test_setup.Initialize Test Suite                                 AND
...             validation.Prepare For PM Counter Testing
Suite Teardown  Run Keywords
...             common_keywords.Capture Snapshot And Restore Config              AND
...             validation.Finalise PM Counter Testing
Test Teardown   common_keywords.Stop Logs And Collect Traces



*** Variables ***
${num_slots_per_frame}            ${20}
${pm_reporting_interval}          5min
${relative_json_path}             ../../TranRobL2/TranRob_Endurance_CA_FDD.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

L3Call_MUE_CA_FDD_FDD
    [Documentation]  Test if traffic is scheduled correctly with 8 UE's and Upling and Downlink Traffic.
    ...  Checks if the right amount of UE's is scheduled per slot.
    common_keywords.Run Test Scenario
    TranRob_validation.Generate Verdict On scenario_1 For L3Call_MUE_CA_FDD_FDD
    tracing.Check For Errors In Syslog



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE    robot:exclude
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/test_repository/CB008246/SBTS00_ENB_9999_230525_000008/20230526_081426
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    TranRob_validation.Generate Verdict On scenario_1 For L3Call_MUE_CA_FDD_FDD
