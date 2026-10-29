*** Settings ***

Documentation
...    CLOUD_5G_I_MP_AP_LOOO  SANSA_FS_ECPRI_CMWV_TDD
...    Author: Ulm VRF6
...    Contact: I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
...    Description: Test Suite for CB008409_Dc IWK with DL RAT1 and PRB Pooling for TDD

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
${relative_json_path}             ../../CB008409/CB008409-B_D/CB008409-B3_B5_B17_Dc/CB008409_Dc3.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB008409_Dc_ET_TC03_TDD_IWK_with_DL_RAT1_and_PRB_Pooling
    [Tags]   CRT    Dc3
    common_keywords.Run Test Scenario
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_Dc3
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Max Number Of PRB Per Slot Not Exceeding DlAllocatedPooledResourcesData.numAllocCellPrbDl
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
    CB008409-B_D_scenario_validations.Verify DlAllocatedPooledResourcesDataNumAllocCellPrbDl Sfn Scheduling Interval Based On BbPoolEvalPeriod
    CB008409-B_D_scenario_validations.Verify If Only RAT1 Bitmap Is Present
    tracing.Check For Errors In Syslog


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the *** Keywords ***
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/logs/CB008409_Dc1/2024-09-23T12-54-31-F/
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_TC03
    # Comment below 2 lines out for pcap to pickle conversion, if needed
    #Extract TTI Trace and Convert to Pickle    path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector_name}/
    #...    ttitrace_streaming.pcap
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Max Number Of PRB Per Slot Not Exceeding DlAllocatedPooledResourcesData.numAllocCellPrbDl
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
    CB008409-B_D_scenario_validations.Verify DlAllocatedPooledResourcesDataNumAllocCellPrbDl Sfn Scheduling Interval Based On BbPoolEvalPeriod
    CB008409-B_D_scenario_validations.Verify If Only RAT1 Bitmap Is Present
