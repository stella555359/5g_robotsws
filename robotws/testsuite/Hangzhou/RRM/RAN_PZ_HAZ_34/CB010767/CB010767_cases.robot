*** Settings ***
Documentation    Author: stella.lin@nokia-sbell.com
Suite Setup    10767_Suite_SetUp
Suite Teardown    10767_Suite_Teardown
Force Tags    PY36
Resource     Resources/CB010767_common.robot
Resource     Resources/CB010767_case_steps.robot


*** Test Cases ***
[1]CB009568-A_51_RedCap_UE_handover_from_TDD_cell_to_FDD_cell
    [Setup]    10767_Case_SetUp
    CB009568-A_51_RedCap_UE_handover_from_TDD_cell_to_FDD_cell
    [Teardown]    10767_Case_Teardown

[1]CB009568-A_40_2RX_Successful_Inter_gNB_NG_based_Handover_based_on_A3_measurements_XnHoNotAllowed_different_AMF_longSN
    [Setup]    10767_Case_SetUp    second_gnb_commission=${True}
    CB009568-A_40_2RX_Successful_Inter_gNB_NG_based_Handover_based_on_A3_measurements_XnHoNotAllowed_different_AMF_longSN
    [Teardown]    10767_Case_Teardown    second_gnb_commission=${True}

