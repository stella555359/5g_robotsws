*** Settings ***
Documentation  This suite contains WebEM__vDU__Activation_of_Event_Based_IQ_capture_and_L1_L2_interface_mirroring_in_parallel_for_Cloud_gNB TC

Resource  ../test_resources/WebEM__vDU__Activation_of_Event_Based_IQ_capture_and_L1_L2_interface_mirroring_in_parallel_for_Cloud_gNB.robot


*** Test Cases ***
WebEM__vDU__Activation_of_Event_Based_IQ_capture_and_L1_L2_interface_mirroring_in_parallel_for_Cloud_gNB
    [Setup]  TC Setup
    TC__WebEM__vDU__Activation_of_Event_Based_IQ_capture_and_L1_L2_interface_mirroring_in_parallel_for_Cloud_gNB
    [Teardown]  TC Teardown
