*** Settings ***
Documentation    Suite containing tests for features:
...              CB008053

Resource        ../CB009854/CB008053_A_B3.robot
Resource        ./regression_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py


Suite Setup    Run Keywords
...                 Initialise Attenuator

Test Setup      Run Keywords
...                 Start Collecting Syslog
...                 AdminUtils.wait_for_all_cells_on_air_state

Test Teardown   Run Keywords
...                 Clear Cache
...                 Collect and Verify Syslog
...                 Make Snapshot In Case Of Error
...                 Add Scout Data Info To Testcase

Test Timeout    120 minutes

*** Test Cases ***
CB008053_B3_Interaction_between_1F_3T_DL_CA_and_1F_1T_UL_CA
    [Tags]    SCF_8053
    CB008053_B3_Interaction_between_1F_3T_DL_CA_and_1F_1T_UL_CA
