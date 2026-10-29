*** Settings ***

Documentation
...    CLOUD_5G_I_MP_AP_LOOO  VARIANT_SANSA_FS_CPRI_CMWV_FDD
...    Author: MN RAN RD VRF ULM 6 (L05)
...    Contact: OU_MN_RAN_RD_VRF_ULM_6_53244963@internal.nsn.com
...    Description: Test Suite for TranRob_Endurance_pooling_Fdd test based on CB007114-G-MAX
...    Test Plan: https://nokia.sharepoint.com/sites/mn-ran-productization/RAN%20Productization%20WoW/Shared%20Documents/Forms/AllItems.aspx
...    Directory: 6. Feature Documents >> CB007000-CB007199 >> CB007114 >> Testability >> Test_Plans >> Version 2 >> CB007114-G_Test_Plan_v2.pdf
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource   ../L2/resources/common_keywords.robot
Resource   ../L2/resources/robot/test_setup.robot
Resource   ../TranRobL2/resources/CB007114_scenario_modifications.robot
Resource   ../TranRobL2/resources/TranRob_Endurance_Pooling_validation.robot


Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot and restore config
Test Teardown   common_keywords.Stop Logs and Collect Traces


*** Variables ***
${NUM_SLOTS_PER_FRAME}                            ${20}
${PM_REPORTING_INTERVAL}                          5min
${RELATIVE_JSON_PATH}                             ../../TranRobL2/TranRob_Endurance_Pooling_Fdd.json
${MAX_NUM_SCHE_UE_PXSCH_L1_SP}                    ${8}      # Expected total number of UEs scheduled in 1 L1SP
${MAX_NUM_PXSCH_ALLOC_PER_SLOT}                   ${4}      # Set to 4 due to APoABIL FS FDD limitation
${FAIL_THRESHOLD}                                 ${1.0}    # percentage of failing instances should not exceed this value
${EXCESS_UE_THRESHOLD}                            ${1}
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***
[1]L3Call_MUE_Pooling
    [Tags]   CRT
    TranRob_Endurance_Pooling_validation.Get Resources Taken Before_Test
    common_keywords.Run Test Scenario
    TranRob_Endurance_Pooling_validation.Get Resources Taken After_Test
    TranRob_Endurance_Pooling_validation.Verify Resource Usage
    TranRob_Endurance_Pooling_validation.Generate Verdict For scenario_1 TC L3Call_MUE_Pooling_TC01 PMC Fdd nbrofpmcmi ${12} exptp ${20}
    TranRob_Endurance_Pooling_validation.Verify SYSLOG Trace For TransRob Endurance Pooling
