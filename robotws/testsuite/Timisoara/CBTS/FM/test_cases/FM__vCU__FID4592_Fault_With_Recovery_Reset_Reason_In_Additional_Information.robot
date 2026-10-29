*** Settings ***
Documentation  This suite contains FM__vCU__FID4592_Fault_With_Recovery_Reset_Reason_In_Additional_Information TC

Resource  ../test_resources/FM__vCU__FID4592_Fault_With_Recovery_Reset_Reason_In_Additional_Information.robot


*** Test Cases ***
FM__vCU__FID4592_Fault_With_Recovery_Reset_Reason_In_Additional_Information
    [Setup]  TC Setup
    TC__FM__vCU__FID4592_Fault_With_Recovery_Reset_Reason_In_Additional_Information
    [Teardown]  TC Teardown
