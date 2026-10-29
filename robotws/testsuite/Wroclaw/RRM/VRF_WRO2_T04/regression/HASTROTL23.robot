*** Settings ***
Documentation
...   Test cases run on 7_16_UTE5GHASTROTL23

Resource        ../5GC001167/resources/keywords.robot
Resource        ./regression_keywords.robot
Library        ./python_functions.py
Library        ../../VRF_WRO2_T07/resources/testline_preparation.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009408/CB009408.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009107/CB009107.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009543/CB009543.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py
Library         testsuite/Wroclaw/RRM/resources/csv4all_helpers.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils

Force Tags      CA_VRF_WRO2

Test Setup      Run Keywords
...    Set TESTNAME without spaces
...    Start Collecting Syslog


Test Teardown   Run Keywords
...    Collect Syslog    AND
...    Run Keyword If Test Failed    AdminUtils.Collect Snapshot    ${OUTPUT_DIR}/${TEST_NAME}/snapshot.zip    timeout=600    AND
...    Add Scout Data Info To Testcase    AND
...    Run Keyword If Test Passed    Find Suspicious Prints In Passed Test

Test Timeout    120 minutes


*** Test Cases ***
TC05_CB009408-B-B1_An_enbControlled_LNADJGNB_instance_with_conflicting_parameter_values_already_exists
    [Tags]    SCF_DEFAULT
    TC05_CB009408-B-B1_An_enbControlled_LNADJGNB_instance_with_conflicting_parameter_values_already_exists

TC03_CB009107-A_NR_supercell_and_LTE_supercell_work_on_same_two_sectors_with_RF_sharing_configuration_UE_is_in_static(0kmph)
    [Tags]    SCF_DEFAULT
    TC03_CB009107-A_NR_supercell_and_LTE_supercell_work_on_same_two_sectors_with_RF_sharing_configuration_UE_is_in_static(0kmph)

CB009543_C1_IWK1_03_SA_EIRP_Counters_FDD_Supercell_subcell_switch_through_all_subcells
    [Tags]    SCF_DEFAULT
    CB009543_C1_IWK1_03_SA_EIRP_Counters_FDD_Supercell_subcell_switch_through_all_subcells
