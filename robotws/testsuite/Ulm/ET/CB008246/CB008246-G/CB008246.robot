*** Settings ***
Documentation
...    CLOUD_5G_I_LO_AP_LO  VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...    Author: Ulm SQD 68
...    Contact: I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com
...    Description: Test Suite for CB008246-G subfeature of HR LA
#------------------------------------------------------------------------------------------------------------------------------------
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
${relative_json_path}             ../../CB008246/CB008246-G/CB008246.json
${dllaBlerTargetHR_1}             5
${dllaBlerTargetHR_2}             10
${NRPDSCHHRLA_1_5QI6}             NRPDSCHHRLA-1
${NRPUSCHHRLA_1_5QI6}             NRPUSCHHRLA-1
${NRPDSCHHRLA_2_5QI2}             NRPDSCHHRLA-1
${NRPUSCHHRLA_2_5QI2}             NRPUSCHHRLA-1
${NRPDSCHHRLA_3_5QI3}             NRPDSCHHRLA-1
${NRPUSCHHRLA_3_5QI3}             NRPUSCHHRLA-1
${NRPDSCHHRLA_4_5QI9}             NRPDSCHHRLA-2
${NRPUSCHHRLA_4_5QI9}             NRPUSCHHRLA-2
${NRPDSCHHRLA_5_5QI7}             NRPDSCHHRLA-2
${NRPUSCHHRLA_5_5QI7}             NRPUSCHHRLA-2
${NRPDSCHHRLA_6_5QI71}            NRPDSCHHRLA-1
${NRPUSCHHRLA_6_5QI71}            NRPUSCHHRLA-1
${NRPDSCHHRLA_7_5QI80}            NRPDSCHHRLA-2
${NRPUSCHHRLA_7_5QI80}            NRPUSCHHRLA-2
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

CB008246_G_TC01_HrDrbPdsch_SA_multiDRB_nonGBR_MultiUE
    [Tags]   CRT
    common_keywords.Run Test Scenario
    Generate Verdict On scenario_TC01 For CB008246_G_TC01_HrDrbPdsch_SA_multiDRB_nonGBR_MultiUE
    tracing.Check For Errors In Syslog


CB008246_G_TC10_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_IWK_NACKflood_DLFB_BRDRB_PMC
    [Tags]   CRT
    common_keywords.Run Test Scenario
    Generate Verdict On scenario_TC10 For CB008246_G_TC10_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_IWK_NACKflood_DLFB_BRDRB_PMC
    tracing.Check For Errors In Syslog



*** Keywords ***
CB008246_G_TC09_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_OnlineModify_NRBTS_multiUE
    [Tags]   CRT
    common_keywords.Run Test Scenario
    Generate Verdict On scenario_TC09 for CB008246_G_TC09_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_OnlineModify_NRBTS_multiUE

CB008246_G_TC11_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_HRDRB_PMC
    [Tags]   CRT
    common_keywords.Run Test Scenario
    Generate Verdict On scenario_TC11 for CB008246_G_TC11_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_HRDRB_PMC


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Offline_Verification
    [Tags]  OFFLINE
    # IMPORTANT: do not forget to comment out the "*** Keywords ***" line
    # IMPORTANT: do not forget to comment out the Suite Setup/Teardown KWs on top of this file!
    test_setup.Read Test Configuration From JSON File
    ${result_base_dir}=    Set Variable    /home/ute/test_repository/20230206_173251
    Set Suite Variable  ${configuration_directory}    ${result_base_dir}/Configs
    Set Suite Variable  ${ts_log_dir}                 ${result_base_dir}/Logs
    Generate Verdict On scenario_TC01 for CB008246_G_TC01_HrDrbPdsch_SA_multiDRB_nonGBR_MultiUE
    Generate Verdict On scenario_TC09 for CB008246_G_TC09_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_OnlineModify_NRBTS_multiUE
    Generate Verdict On scenario_TC10 for CB008246_G_TC10_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_IWK_NACKflood_DLFB_BRDRB_PMC
    Generate Verdict On scenario_TC11 for CB008246_G_TC11_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_HRDRB_PMC
