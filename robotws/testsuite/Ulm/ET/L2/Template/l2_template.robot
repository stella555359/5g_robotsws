*** Settings ***
Documentation
...    This is a Template Robot Framework file which might be used for
...       - new Sqd68's Features and
...       - "manual" execution collecting all possible logs
...    Author: Ulm SQD 68
...    Contact: I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource   ./../resources/common_keywords.robot
Resource   ./resources/scenario_modifications.robot
Resource   ./resources/scenario_validations.robot


Suite Setup     Initialize Test Suite
Suite Teardown  Capture Snapshot and restore config
Test Teardown   Stop Logs and Collect Traces



*** Variables ***
${num_slots_per_frame}            ${20}
${pm_reporting_interval}          5min
${relative_json_path}             ../../../L2/Template/l2_template.json
${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${True}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${True}


*** Test Cases ***

Test Execution
    [Tags]   test
    Run Test Scenario
