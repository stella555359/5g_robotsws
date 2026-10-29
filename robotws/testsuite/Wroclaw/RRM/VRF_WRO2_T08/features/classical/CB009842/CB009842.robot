*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   contact: lukasz.klosinski@nokia.com

Library        taf.ue
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB009842/resources/test_specific_keywords_CB009842.py

Suite Setup       Set Counter Interval To 5min
Suite Teardown    Set Counter Interval To 15min

*** Test Cases ***
TC01_CB009842_A_B1_Activation
    [Setup]    Test Setup
    TC01 CB009842 A B1 Activation
        [Teardown]   Run Keywords    Run Keyword If Test Failed    Gather Snapshot    AND    Test Teardown

TC07_CB009842_A_EC2_Rejection_of_Periodic_Request
    [Setup]    Test Setup
    TC01 CB009842 A EC2 Rejection Of Periodic Request
    [Teardown]   Run Keywords    Run Keyword If Test Failed    Gather Snapshot    AND    Test Teardown

TC05 _CB009842_A_B6_Interaction_with_SS-RSRQ_Quantity_during_VoNR_call
    [Setup]    Test Setup
    TC05 CB009842 A B6 INTERACTION WITH SS RSRQ QUANTITY DURING VONR CALL
    [Teardown]   Run Keywords    Run Keyword If Test Failed    Gather Snapshot    AND    Test Teardown

TC09_CB009842_A_B3_Alt1_NR-TADV_request_with_CB008225_Inactive_UE_State_with_SS-RSRP_Quantity
    [Setup]    Run Keywords    Test Setup    AND   Activate RRC Inactive Flag
    TC09 CB009842 A B3 ALT1 NR TADV REQUEST WITH CB008225 INACTIVE UE STATE WITH SS RSRP QUANTITY
    [Teardown]   Run Keywords    Run Keyword If Test Failed    Gather Snapshot    AND
    ...                          Deactivate RRC Inactive Flag  AND
    ...                          Test Teardown
