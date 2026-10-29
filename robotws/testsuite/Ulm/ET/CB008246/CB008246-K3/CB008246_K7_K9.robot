*** Settings ***

Documentation
...    Author: Ulm SQD 68
...    Contact: I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com
...    Description: Test Suite for CB008246-K#7 and CB008246-K#9 subfeatures of HR LA
...    UTE Topology: CLOUD_5G_I_LO_AP_LO
...    Variant: VARIANT_PRIVATE_4S_2CC_FDD_TDD_CA
...    Reference config feature:
...         USCB006137-BA#1: FDD - TDD UL CA feature
...         USCB007220-B#2: Aperiodic CSI handling for UE configured with FDD-TDD CA
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ../../resources/SQD68/pmc_analysis.py    WITH NAME  validation

Resource   ../../L2/resources/robot/test_setup.robot
Resource   ../../L2/resources/common_keywords.robot
Resource   ../../L2/resources/robot/tracing.robot
Resource   resources/CB008246_scenario_modifications.robot
Resource   resources/CB008246_scenario_validations.robot


Suite Setup     Run Keywords
...             test_setup.Initialize Test Suite                        AND
...             validation.Prepare For PM Counter Testing
Suite Teardown  Run Keywords
...             common_keywords.Capture Snapshot And Restore Config     AND
...             validation.Finalise PM Counter Testing
Test Teardown   common_keywords.Stop Logs And Collect Traces


*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB008246/CB008246-K3/CB008246.json
${ullaBlerTargetHR_1}             5
${ullaBlerTargetHR_2}             10
${NRPUSCHHRLA_1_5QI6}             NRPUSCHHRLA-1
${NRPUSCHHRLA_2_5QI3}             NRPUSCHHRLA-1
${NRPUSCHHRLA_3_5QI9}             NRPUSCHHRLA-1
${NRPUSCHHRLA_4_5QI7}             NRPUSCHHRLA-1
${NRPUSCHHRLA_5_5QI71}            NRPUSCHHRLA-1
${NRPUSCHHRLA_6_5QI80}            NRPUSCHHRLA-1
${dllaBlerTargetHR_1}             5
${dllaBlerTargetHR_2}             10
${NRPDSCHHRLA_1_5QI6}             NRPDSCHHRLA-1
${NRPDSCHHRLA_2_5QI3}             NRPDSCHHRLA-1
${NRPDSCHHRLA_3_5QI9}             NRPDSCHHRLA-1
${NRPDSCHHRLA_4_5QI7}             NRPDSCHHRLA-1
${NRPDSCHHRLA_5_5QI71}            NRPDSCHHRLA-1
${NRPDSCHHRLA_6_5QI80}            NRPDSCHHRLA-1
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB008246_K_TC07_HR_IWK_CA_UL_SA_DFT-s-OFDM
    [Tags]   CRT
    common_keywords.Run Test Scenario
    CB008246_scenario_validations.Generate Verdict On scenario_TC07_TC09 For CB008246_K_TC07_HR_IWK_CA_UL_SA_DFT-s-OFDM
    tracing.Check For Errors In Syslog


*** Keywords ***
CB008246_K_TC09_HR_IWK_CA_UL_ACSI_enabled
    [Tags]   CRT
    common_keywords.Run Test Scenario
    Generate verdict on scenario_TC07_TC09 for CB008246_K_TC09_HR_IWK_CA_UL_ACSI_enabled


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/robotws/CB008246/SBTS00_ENB_9999_230712_000003/20230713_133700
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB008246_scenario_validations.Generate Verdict On scenario_TC07_TC09 For CB008246_K_TC07_HR_IWK_CA_UL_SA_DFT-s-OFDM
    CB008246_scenario_validations.Generate Verdict On scenario_TC07_TC09 For CB008246_K_TC09_HR_IWK_CA_UL_ACSI_enabled
