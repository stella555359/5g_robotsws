*** Settings ***

Documentation
...    CLOUD_5G_I_LO_AP_LOOO  PRIVATE_SANSA_FS_CPRI_CMWV_FDD_AHFII_AHLOA_6CELLS
...    Author: Ulm VRF6
...    Contact: OU_MI_MN_RAN_RD_VRF_ULM_6_53244963
...    Description: Test Suite for CB008409_B5 IWK with PRB Pooling / CB008409_Dc IWK with DL RAT1 dynamic switch and PRB Pooling for FDD

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource   ../../../L2/resources/robot/test_setup.robot
Resource   ../../../L2/resources/common_keywords.robot
Resource   ../../../L2/resources/robot/tracing.robot
Resource   resources/CB008409_B3_B5_B17_Dc_scenario_modifications.robot
Resource   ../../CB008409-B_D/resources/CB008409-B_D_scenario_validations.robot


Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces


*** Variables ***
${pm_reporting_interval}          5min
${relative_json_path}             ../../CB008409/CB008409-B_D/CB008409-B3_B5_B17_Dc/CB008409_B5_Dc2.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB008409_B_ET_TC_B5_IWK_PRB_pooling
    [Tags]   CRT    B5
    common_keywords.Run Test Scenario
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_B5
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Max Number Of PRB Per Slot Not Exceeding dlAllocatedPooledResourcesData.numAllocCellPrbDl
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
    CB008409-B_D_scenario_validations.Verify dlAllocatedPooledResourcesDataNumAllocCellPrbDl Sfn Scheduling Interval Based On bbPoolEvalPeriod
    CB008409-B_D_scenario_validations.Verify BaseBand Pooling Window
    tracing.Check For Errors In Syslog


CB008409_Dc_ET_TC02_FDD_IWK_with_DL_RAT1_and_RAT_DynSwitch_and_PRB_Pooling
    [Tags]   CRT    Dc2
    common_keywords.Run Test Scenario
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_Dc2
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Max Number Of PRB Per Slot Not Exceeding dlAllocatedPooledResourcesData.numAllocCellPrbDl
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
    CB008409-B_D_scenario_validations.Verify RAT0 RAT1 Dynamic Switch
    CB008409-B_D_scenario_validations.Verify dlAllocatedPooledResourcesDataNumAllocCellPrbDl Sfn Scheduling Interval Based On bbPoolEvalPeriod
    CB008409-B_D_scenario_validations.Verify BaseBand Pooling Window
    tracing.Check For Errors In Syslog


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the *** Keywords ***
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration from JSON File
    ${result_base_dir}=    Set Variable    /home/ute/Downloads/test_results/CB008409_B5/SBTS00_ENB_9999_260104_000005/20260106_180218
    Set Suite Variable  ${CONFIGURATION_DIRECTORY}    ${result_base_dir}/Configs
    Set Suite Variable  ${TS_LOG_DIR}                 ${result_base_dir}/Logs
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_B5
    # Comment below 2 lines out for pcap to pickle conversion, if needed
    #Extract TTI Trace and Convert to Pickle    path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector_name}/
    #...    ttitrace_streaming.pcap
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Max Number Of PRB Per Slot Not Exceeding dlAllocatedPooledResourcesData.numAllocCellPrbDl
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
    CB008409-B_D_scenario_validations.Verify dlAllocatedPooledResourcesDataNumAllocCellPrbDl sfn Scheduling Interval Based On bbPoolEvalPeriod
    CB008409-B_D_scenario_validations.Verify BaseBand Pooling Window
    tracing.Check For Errors In Syslog
