*** Settings ***
Documentation
...  author:  Marcin Wachacki
...  contact: marcin.wachacki@nokia.com

Resource    ./resources/suite_specific_keywords.robot

Suite Setup    Suite Setup 8SK050


*** Test Cases ***

CB008294-W_101_5G_DL_peak_TPUT_per_UE_with_beamforming_prach175
    [Setup]    W 101 Test Setup

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured
    Run Downlink TCP Data Transmission for 60 seconds
    Verify 8CC Downlink TCP Data Transmission
    Detach UE

    [Teardown]    W 101 Test Teardown

CB010496_W_22_SA_DL_peak_Tput_FR2_8CCDL_4CCUL_prach_175_C2_CB008294_W
    [Setup]    W 22 CB010496 Test Setup

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured
    Run Downlink TCP Data Transmission for 60 seconds
    Verify 8CC Downlink TCP Data Transmission
    Detach UE

    [Teardown]    W 101 Test Teardown

CB008294-W_201_5G_UL_peak_TPUT_per_UE_with_beamforming_prach175
    [Setup]    W 201 Test Setup

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured
    Run Uplink TCP Data Transmission for 60 seconds
    Verify 4CC Uplink TCP Data Transmission
    Detach UE

    [Teardown]    W 201 Test Teardown

CB010496_W_23_SA_UL_peak_Tput_FR2_8CCDL_4CCUL_prach_175_C2_CB008294_W
    [Setup]    W 23 CB010496 Test Setup

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured
    Run Uplink TCP Data Transmission for 60 seconds
    Verify 4CC Uplink TCP Data Transmission
    Detach UE

    [Teardown]    W 201 Test Teardown

CB008294-C_101_C#B1_SCell_shutting_down_when_UE_attached
    [Setup]    C 101 Test Setup

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured
    Set State Of Cell 4 on gNB1 to Shutting Down
    Check If UE Was Released
    Check If Cell Is Locked
    Detach UE

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 2 Of gNB 1 and 6 Scells Are Configured
    Detach UE

    Set State Of Cell 4 on gNB1 to Unlocked

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured
    Detach UE

    [Teardown]    C 101 Test Teardown

CB008294-A_400_A#B4_UE_intra-band_CA_mmW_2_sub-blocks_non-contiguous
    [Setup]    A 400 Test Setup

    Collect A 400 PM Counters Before Test

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 3 Scells Are Configured
    Run Downlink TCP Data Transmission for 60 seconds
    Verify 4CC Downlink TCP Data Transmission
    Run Uplink TCP Data Transmission for 60 seconds
    Verify 2CC Uplink TCP Data Transmission
    Detach UE

    Collect A 400 PM Counters After Test
    Verify Counter Updates

    [Teardown]    A 400 Test Teardown

CB008294-A_100_A#B1_FR2_CA_for_SA_feature_activation
    [Setup]    A 100 Test setup

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and No Scells Are Configured
    Run Downlink TCP Data Transmission for 60 seconds
    Verify 1CC Downlink TCP Data Transmission
    Run Uplink TCP Data Transmission for 60 seconds
    Verify 1CC Uplink TCP Data Transmission
    Detach UE

    Enable FR2 CA on gNB 1

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured
    Run Downlink TCP Data Transmission for 60 seconds
    Verify 8CC Downlink TCP Data Transmission
    Run Uplink TCP Data Transmission for 60 seconds
    Verify 4CC Uplink TCP Data Transmission
    Detach UE

    [Teardown]    A 100 Test Teardown

CB008294-A_004_PMO#1_Counters_for_SA_FR2_CA_blind_Scell_activation
    [Setup]    A 004 PMO 1 Test Setup
    Collect A 004 PMO 1 PM Counters Before Test

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 3 Consecutive Scells Are Configured
    Run Downlink TCP Data Transmission for 60 seconds
    Verify 4CC Downlink TCP Data Transmission
    Run Uplink TCP Data Transmission for 60 seconds
    Verify 4CC Uplink TCP Data Transmission
    Detach UE

    Collect A 004 PMO 1 PM Counters After Test

    Prepare First Counters Collection To Verification
    Verify Counter Updates
    Prepare Second Counters Collection To Verification
    Verify If Counters Level Is 900


    [Teardown]    A 004 PMO 1 Test Teardown

CB008294-A_000_PMO#2_Counters_for_SA_FR2_CA_buffer_and_radio_link_quality_SCell_deactivation
    [Setup]    A 000 PMO 2 Test Setup

    Collect A 000 PMO 2 PM Counters Before Test

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Run Downlink TCP Data Transmission for 60 seconds
    Detach UE

    Collect A 000 PMO 2 PM Counters After Test
    Verify Counter Updates

    [Teardown]    A 000 PMO 2 Test Teardown
