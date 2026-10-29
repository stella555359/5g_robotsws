*** Settings ***

Documentation
...    CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...    Author: Ulm VRF6
...    Contact: I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com
...    Description: Test Suite for CB008409_B17 IWK with PRB Blanking

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
${relative_json_path}             ../../CB008409/CB008409-B_D/CB008409-B3_B5_B17_Dc/CB008409_B17.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB008409_B_ET_TC_B17_IWK_PRB_blanking
    [Tags]   CRT    B17
    Run Test Scenario
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_B17
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
    tracing.Check For Errors In Syslog


*** Keywords ***
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the *** Keywords ***
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/test_repository/20230206_173251
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    CB008409-B_D_scenario_validations.Prepare Variables For Validations    scenario=scenario_B17
    # Comment below 2 lines out for pcap to pickle conversion, if needed
    #Extract TTI Trace and Convert to Pickle    path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector_name}/
    #...    ttitrace_streaming.pcap
    CB008409-B_D_scenario_validations.Verify MaxNumberOfPRBperSlot
    CB008409-B_D_scenario_validations.Verify Power Boost For ReTx
