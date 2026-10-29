*** Settings ***
Documentation  This suite contains FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case TC

Resource  ../test_resources/FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case.robot


*** Test Cases ***
FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case
    [Setup]  TC Setup
    TC__FM__vDU_RU_resiliency_to_BTS_DU_RANNIC_reset_Uncontrolled_case
    [Teardown]  TC Teardown
