*** Settings ***
Documentation  This suite contains WebEM__vDU__Interface_for_Mirroring_activation_in_5G_vDU TC

Resource  ../test_resources/WebEM__vDU__Interface_for_Mirroring_activation_in_5G_vDU.robot


*** Test Cases ***
WebEM__vDU__Interface_for_Mirroring_activation_in_5G_vDU
    [Setup]  TC Setup
    TC__WebEM__vDU__Interface_for_Mirroring_activation_in_5G_vDU
    [Teardown]  TC Teardown
