*** Settings ***
Documentation  This suite contains WebEM__LTE_NBIOT_Cell_L1_IQ_Capture TC

Resource  ../test_resources/WebEM__LTE_NBIOT_Cell_L1_IQ_Capture.robot


*** Test Cases ***
WebEM__LTE_NBIOT_Cell_L1_IQ_Capture
    [Setup]  TC Setup
    TC__WebEM__LTE_NBIOT_Cell_L1_IQ_Capture
    [Teardown]  TC Teardown
