*** Settings ***
Documentation    Author: jun.8.chen@nokia-sbell.com
Suite Setup    12544_Suite_SetUp
Suite Teardown    12544_Suite_Teardown
Test Teardown    12544_Case_Teardown
Force Tags    PY36
Resource     Resources/CB012544_case_steps.robot

*** Test Cases ***
[1]CB012544-C_14_Verify_CN_Paging_Successful_Rate_for_eDRX_UE_with_different_eDRX_Cycle
    [Setup]    12544_Case_SetUp
    CB012544-C_14_Verify_CN_Paging_Successful_Rate_for_eDRX_UE_with_different_eDRX_Cycle

[1]CB012544-D_16_Verify_RAN_Paging_Successful_Rate_for_eDRX_UE
    [Setup]    12544_Case_SetUp
    CB012544-D_16_Verify_RAN_Paging_Successful_Rate_for_eDRX_UE
