*** Settings ***
Documentation
...   Test cases for CB012268
...   author:       Jakub Matuszczyk, Dawid Chuchnowski
...   maintainer:   Jakub Matuszczyk
...   contact:      jakub.matuszczyk@nokia.com
...   team:         KRK6

Library        ./resources/counters_verification.py
Resource       testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB012268/resources/pm_counters_verification.robot
Resource       testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB012268/resources/suite_specific_keywords.robot

Suite Setup    Suite Setup
Suite Teardown   Unlock RU on neighbour BTS    bts_id=1  rmod_id=1

*** Test Cases ***
CB012268-SR-A_Counter_for_UL_tput_at_RLC_at_profile_level
    [Tags]    CRT
    [Setup]    Test Setup SA
    UE.Adjust Apn     UE_1    pdp_type=IP     apn_name=5qi56-krk
    Attach 5G SA UE
    Run Downlink And Uplink TCP Data Transmission    duration=20
    Wait for next full pm interval
    Verify NRPMQAP counters for Cell  ${CB012268_A_counters}    260    1
    Wait for next full pm interval
    Run Downlink And Uplink TCP Data Transmission    UL_port=5005    DL_port=5006    duration=20
    Wait for next full pm interval
    Verify NRPMQAP counters for Cell  ${CB012268_A_counters}    260    2
    [Teardown]  Test Teardown SA

CB012268-SR-B_#B1_Cell_Tput_per_Radio_Link_Quality
     [Tags]    CRT
     [Setup]    Test Setup SA
     Configure parameters for edge cell condition
     Wait for next full pm interval
     Attach 5G SA UE
     Run Downlink And Uplink TCP Data Transmission    duration=10
     Detach UE
     Wait for next full pm interval
     Check Cell Edge NR MAC PDU throughput counters

     Configure parameters for middle cell condition

     Attach 5G SA UE
     Run Downlink And Uplink TCP Data Transmission    duration=10
     Detach UE
     Wait for next full pm interval
     Check Cell Middle range NR MAC PDU throughput counters

     Configure parameters for near cell condition

     Attach 5G SA UE
     Run Downlink And Uplink TCP Data Transmission    duration=10
     Detach UE
     Wait for next full pm interval
     Check Cell Near range NR MAC PDU throughput counters

     [Teardown]  Test Teardown SA


CB012268-SR-C_#B2_DL_UL_PDCP_SDU_Cell_Level_Peak_Tput
     [Tags]    CRT
     [Setup]    Test Setup SA
     Wait for next full pm interval
     Attach 5G SA UE
     Run Downlink And Uplink UDP Data Transmission    duration=20    throughput=10M
     Detach UE
     Wait for next full pm interval
     Check DL and UL Cell PDCP throughput layer counters
     ...    expected_DL=400000-600000
     ...    expected_UL=400000-600000
     Wait for next full pm interval
     Attach 5G SA UE
     Run Downlink And Uplink UDP Data Transmission    duration=20    throughput=50M
     Detach UE
     Wait for next full pm interval
     Check DL and UL Cell PDCP throughput layer counters
     ...    expected_DL=1800000-2200000
     ...    expected_UL=1800000-2200000
     [Teardown]  Test Teardown SA


CB012268-SR-E_#B1_DL_PDCP_SDU_Packet_Size_Distribution_Bins
     [Tags]    CRT
     [Setup]    Test Setup SA
     Attach 5G SA UE
     Run Downlink And Uplink TCP Data Transmission    duration=20
     Detach UE
     Wait for next full pm interval
     Check DL PDCP SDU bin counters    counters_list=${CB012268_E_counters}    cell=260
     [Teardown]  Test Teardown SA


CB012268-SR-F_Online_Activation_of_Reporting_DL_MAC_SDU_User_Tput_Counters_SA
    [Tags]    CRT
    [Setup]    Test Setup SA
    Enable DL MAC SDU measurements
    Wait for next full pm interval
    Attach 5G SA UE
    Run Downlink TCP Data Transmission    duration=10
    Wait for next full pm interval
    Check DL throughput volume counters for CB012268-F are zeroed out
    Detach UE

    Set reporting of DL MAC SDU user throughput PM counters    value=true
    Attach 5G SA UE
    Run Downlink TCP Data Transmission    duration=10
    Wait for next full pm interval
    Check DL throughput volume counters for CB012268-F are incremented    cell_id=260    nrpmqap_profile=1
    [Teardown]    run keywords
    ...    Set reporting of DL MAC SDU user throughput PM counters    value=false
    ...    AND     Test Teardown SA