*** Settings ***

Documentation
...    CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...    Author: Ulm SQD 66
...    Contact: I_MN_RAN_L2_SW_ULM_SQD_66@internal.nsn.com
...    Description: Test Suite for CB008246-J subfeature of HR LA
#------------------------------------------------------------------------------------------------------------------------------------
Library    ../../resources/SQD68/pmc_analysis.py    WITH NAME  validation

Resource   ../../L2/resources/common_keywords.robot
Resource   ../../L2/resources/robot/test_setup.robot
Resource   ../../L2/resources/robot/tracing.robot
Resource   resources/CB008246-J_scenario_modifications.robot
Resource   resources/CB008246-J_scenario_validations.robot


Suite Setup     Run Keywords
...             test_setup.Initialize Test Suite                        AND
...             validation.Prepare For PM Counter Testing
Suite Teardown  Run Keywords
...             common_keywords.Capture Snapshot And Restore Config     AND
...             validation.Finalise PM Counter Testing
Test Teardown   common_keywords.Stop Logs And Collect Traces


*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB008246/CB008246-J/CB008246-J.json
${xlaBlerTarget_internal}         ${10}
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***
CB008246_J_ET_TC01_HrDrbPusch_SA_multiDRB_nonGBR_256QAM_TDD
    [Tags]    CRT    TDD    256QAM    TC01    robot:exclude
    common_keywords.Run Test Scenario
    Set Test Variable    @{dl_dtx_threshold}    0.1
    Set Test Variable    @{ul_dtx_threshold}    0.1
    CB008246-J_scenario_validations.Generate Verdict On scenario_TC01_256QAM_TDD

CB008246_J_ET_TC02_HrDrbPusch_SA_multiDRB_nonGBR_256QAM_FDD
    [Tags]    CRT    FDD    256QAM    TC02    robot:exclude
    common_keywords.Run Test Scenario
    Set Test Variable    @{dl_dtx_threshold}    0.1
    Set Test Variable    @{ul_dtx_threshold}    0.1
    CB008246-J_scenario_validations.Generate Verdict On scenario_TC02_256QAM_FDD

CB008246_J_ET_TC03_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_TDD
    [Tags]    CRT    TDD    DFTsOFDM    TC03
    common_keywords.Run Test Scenario
    Set Test Variable    @{dl_dtx_threshold}    0.2
    Set Test Variable    @{ul_dtx_threshold}    0.1
    CB008246-J_scenario_validations.Generate Verdict On xpmc_scenario_TC03_DFTsOFDM_TDD
    tracing.Check For Errors In Syslog

CB008246_J_ET_TC04_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_FDD
    [Tags]    CRT    FDD    DFTsOFDM    TC04
    common_keywords.Run Test Scenario
    Set Test Variable    @{dl_dtx_threshold}    0.15
    Set Test Variable    @{ul_dtx_threshold}    0.1
    CB008246-J_scenario_validations.Generate Verdict On xpmc_scenario_TC04_DFTsOFDM_FDD
    tracing.Check For Errors In Syslog

CB008246_J_ET_TC05_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_TDD
    [Tags]    CRT    TDD    DFTsOFDM    TC05    robot:exclude
    common_keywords.Run Test Scenario
    Set Test Variable    @{dl_dtx_threshold}    0.2
    Set Test Variable    @{ul_dtx_threshold}    0.1
    CB008246-J_scenario_validations.Generate Verdict On scenario_TC05_DFTsOFDM_TDD

CB008246_J_ET_TC06_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_FDD
    [Tags]    CRT    FDD    DFTsOFDM    TC06    robot:exclude
    common_keywords.Run Test Scenario
    Set Test Variable    @{dl_dtx_threshold}    0.1
    Set Test Variable    @{ul_dtx_threshold}    0.1
    CB008246-J_scenario_validations.Generate Verdict On scenario_TC06_DFTsOFDM_FDD
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

OFFLINE
    [Tags]    OFFLINE    robot:exclude
    # IMPORTANT: do not forget to comment out the Suite/Test Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/logs/CB008246-J/2025-06-12T10-24-15-F/CB008246-J/SBTS00_ENB_9999_250611_000009/20250612_102501
    Set Test Variable  ${CONFIGURATION_DIRECTORY}    ${result_base_dir}/Configs
    Set Test Variable  ${TS_LOG_DIR}                 ${result_base_dir}/Logs
    # PLease uncomment below 2 lines and adpat for pcap conversion to pickle
#    Extract TTI Trace and Convert to Pickle    path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_xpmc_scenario_TC04_DFTsOFDM_FDD_DFTS_OFDM_Param_on/
#    ...    ttitrace_streaming.pcap
    Set Test Variable    @{DL_DTX_THRESHOLD}    0.1
    Set Test Variable    @{UL_DTX_THRESHOLD}    0.1
    CB008246-J_scenario_validations.Generate Verdict On Xpmc_scenario_TC04_DFTsOFDM_FDD
