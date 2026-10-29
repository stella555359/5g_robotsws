*** Settings ***

Documentation
...    This is a Template Robot Framework file which might be used for
...       - new Sqd68's Features and to veryfy the impact of changes to Common Keywords.
...    Author: Ulm SQD 68
...    Contact: I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Variables  TEAL_resources/tti_test.py

Resource   ../../../ET/L2/resources/common_keywords.robot
Resource   TEAL_resources/scenario_modifications.robot
Resource   TEAL_resources/scenario_validations.robot


Suite Setup     Initialize Test Suite
Suite Teardown  Capture Snapshot And Restore Config
Test Teardown   Stop Logs And Collect Traces



*** Variables ***
${num_slots_per_frame}            ${20}
${pm_reporting_interval}          5min
${relative_json_path}             ${EMPTY}

*** Test Cases ***

Test TTI
    [Tags]   TEAL   test
    Run Test Scenario
    scenario_validations.Test TTI Not EMPTY
