*** Settings ***
Documentation
...  author:  Kamil Bielecki
...  contact: kamil.bielecki@nokia.com
...  description: Test Cases for CB010636 NR CA counters FR2

Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB010636/resources/suite_specific_keywords.robot

Force Tags    STATE_SW_UPLOADED     CRT
...   PY36

Suite Setup      Run keywords
...              Suite Setup
...              AND    Block all cells on the second gNB
Suite Teardown   Run keywords
...              Common Suite Teardown
...              AND    Unblock all cells on the second gNB

*** Test Cases ***
CB010636-SR-A_15_RLC_PDU_volume_counters_for_NSA_CA_UE_in_FR2
    [Tags]    CRT
    [Setup]    Test Setup NSA
    Wait For Next PM measurements
    Attach 5G NSA UE to Cell A
    Start Uplink and Downlink TCP Data Transmission    duration=10s
    Stop Uplink and Downlink Data Transmission
    Detach UE
    Attach 5G NSA UE to Cell B
    Start Uplink and Downlink TCP Data Transmission    duration=10s
    Stop Uplink and Downlink Data Transmission
    Detach UE
    Wait For Next PM measurements
    Check PM counters for CB010636-A
    [Teardown]  UE Teardown

CB010636-SR-B_13_DL_MAC_layer_UE_throughput_at_profile_and_non-profile_level_SA_ASOE
    [Tags]    CRT
    [Setup]    Test Setup SA
    Wait For Next PM measurements
    Attach 5G SA UE
    Run Downlink FR2 SA TCP Data Transmission     duration=10s
    Detach UE
    Wait For Next PM measurements
    Check PM counters for CB010636-B-13
    [Teardown]  UE Teardown

CB010636-SR-B_19_Online_activation_of_reporting_DL_MAC_SDU_user_throughput_PM_counters_FR2_SA_different_discard_values
    [Tags]    CRT
    [Setup]    Test Setup SA
    Disable CB010636-B counters
    Wait For Next PM measurements
    Attach 5G SA UE
    Run Downlink FR2 SA TCP Data Transmission     duration=10s
    Detach UE
    Wait For Next PM measurements
    Check PM counters for CB010636-B-19 empty
    Enable CB010636-B counters
    Wait For Next PM measurements
    Attach 5G SA UE
    Run Downlink FR2 SA TCP Data Transmission     duration=10s
    Detach UE
    Wait For Next PM measurements
    Check PM counters for CB010636-B-19
    [Teardown]  UE Teardown

CB010636-SR-C_10_DL_Per_CC_UE_Throughput_Counters_NSA_ASOE
    [Tags]    CRT
    [Setup]    Test Setup NSA
    Wait For Next PM measurements
    Attach 5G NSA UE to Cell A
    Start Uplink and Downlink TCP Data Transmission    duration=10s
    Stop Uplink and Downlink Data Transmission
    Detach UE
    Wait For Next PM measurements
    Check PM counters for CB010636-C-10
    [Teardown]  UE Teardown

CB010636-SR-C_11_DL_Per_CC_UE_Throughput_Counters_SA_ASOF
    [Tags]    CRT
    [Setup]    Test Setup SA
    Wait For Next PM measurements
    Attach 5G SA UE
    Run Downlink FR2 SA TCP Data Transmission     duration=10s
    Detach UE
    Wait For Next PM measurements
    Check PM counters for CB010636-C-11
    [Teardown]  UE Teardown
