*** Settings ***

Documentation
...    Author: Ulm SQD 66
...    Contact: I_MN_RAN_L2_SW_ULM_SQD_66@internal.nsn.com
...    Description: Offline analysis for CB008246-J subfeature of HR LA
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource   ./../../L2/resources/robot/test_setup.robot
Resource   ./../../L2/resources/common_keywords.robot
Resource   ./resources/CB008246-J_scenario_validations.robot
Resource   ./resources/CB008246-J_scenario_modifications.robot

Suite Setup     Prepare TL for Testing
Suite Teardown  Teardown TL
Test Setup      Perform Preconditions for Offline Analysis
Test Teardown   Perform Postconditions for Offline Analysis


*** Variables ***
${relative_json_path}             ../../CB008246/CB008246-J/CB008246-J.json
${xlaBlerTarget_internal}         ${10}


*** Test Cases ***

CB008246_J_ET_TC01_HrDrbPusch_SA_multiDRB_nonGBR_256QAM_TDD
    [Documentation]    This Test Scenario performs offline analysis of testcase results
    Set test variable    @{dl_dtx_threshold}    0.01
    Set test variable    @{ul_dtx_threshold}    0.01
    Generate verdict on scenario_TC01_256QAM_TDD for CB008246_J_ET_TC01_HrDrbPusch_SA_multiDRB_nonGBR_256QAM_TDD


CB008246_J_ET_TC02_HrDrbPusch_SA_multiDRB_nonGBR_256QAM_FDD
    [Documentation]    This Test Scenario performs offline analysis of testcase results
    Set test variable    @{dl_dtx_threshold}    0.01
    Set test variable    @{ul_dtx_threshold}    0.01
    Generate verdict on scenario_TC02_256QAM_FDD for CB008246_J_ET_TC02_HrDrbPusch_SA_multiDRB_nonGBR_256QAM_FDD


CB008246_J_ET_TC03_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_TDD
    [Documentation]    This Test Scenario performs offline analysis of testcase results
    Set test variable    @{dl_dtx_threshold}    0.06
    Set test variable    @{ul_dtx_threshold}    0.03
    Generate verdict on xpmc_scenario_TC03_DFTsOFDM_TDD for CB008246_J_ET_TC03_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_TDD


CB008246_J_ET_TC04_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_FDD
    [Documentation]    This Test Scenario performs offline analysis of testcase results
    Set test variable    @{dl_dtx_threshold}    0.06
    Set test variable    @{ul_dtx_threshold}    0.02
    Generate verdict on xpmc_scenario_TC04_DFTsOFDM_FDD for CB008246_J_ET_TC04_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_FDD


CB008246_J_ET_TC05_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_TDD
    [Documentation]    This Test Scenario performs offline analysis of testcase results
    Set test variable    @{dl_dtx_threshold}    0.05
    Set test variable    @{ul_dtx_threshold}    0.02
    Generate verdict on scenario_TC05_DFTsOFDM_TDD for CB008246_J_ET_TC05_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_TDD


CB008246_J_ET_TC06_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_FDD
    [Documentation]    This Test Scenario performs offline analysis of testcase results
    Set test variable    @{dl_dtx_threshold}    0.05
    Set test variable    @{ul_dtx_threshold}    0.01
    Generate verdict on scenario_TC06_DFTsOFDM_FDD for CB008246_J_ET_TC06_HrDrbPusch_SA_multiDRB_nonGBR_DFTsOFDM_256QAM_FDD


*** Keywords ***

Prepare TL for Testing
    Log Variables


Perform Preconditions for Offline Analysis
    test_setup.Read Test Configuration from JSON File
    Log Variables
    Log to console    Offline analysis start


Perform Postconditions for Offline Analysis
    Log to console    Offline analysis end!


Teardown TL
    connect.Disconnect all available ssh connections
