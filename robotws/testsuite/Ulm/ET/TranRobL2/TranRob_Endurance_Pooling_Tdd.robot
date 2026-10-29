*** Settings ***

Documentation
...    Author: Ulm SQD 66
...    Contact: I_MN_RAN_L2_SW_ULM_SQD_66@internal.nsn.com
...    Description: Test Suite for TranRob_Endurance_pooling_Tdd test based on CB008847-E-MAX
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource   ../L2/resources/common_keywords.robot
Resource   ../L2/resources/robot/tracing.robot
Resource   ../TranRobL2/resources/CB008847_scenario_modifications.robot
Resource   ../TranRobL2/resources/TranRob_Endurance_Pooling_validation.robot


Suite Setup     test_setup.Initialize Test Suite
Suite Teardown  common_keywords.Capture Snapshot And Restore Config
Test Teardown   common_keywords.Stop Logs And Collect Traces



*** Variables ***
${num_slots_per_frame}             ${20}
${pm_reporting_interval}           5min
${relative_json_path}              ../../TranRobL2/TranRob_Endurance_Pooling_Tdd.json
${max_num_pxsch_alloc_per_slot}    ${16}
${duration_threshold}              ${1}
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***
[2]L3Call_MUE_Pooling
    [Tags]   CRT  CLOUD_5G_I_MP_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
    TranRob_Endurance_Pooling_validation.Get Resources Taken Before_test
    common_keywords.Run Test Scenario
    TranRob_Endurance_Pooling_validation.Get Resources Taken After_test
    TranRob_Endurance_Pooling_validation.Verify Resource Usage
    TranRob_Endurance_Pooling_validation.Generate verdict for scenario_1 TC L3Call_MUE_Pooling_TC02 PMC Tdd nbrofpmcmi ${12} exptp ${30}
    TranRob_Endurance_Pooling_validation.Verify SYSLOG Trace For TransRob Endurance Pooling
