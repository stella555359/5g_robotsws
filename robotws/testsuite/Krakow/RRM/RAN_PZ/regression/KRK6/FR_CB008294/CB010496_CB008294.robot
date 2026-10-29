*** Settings ***
Documentation
...  author:  Marcin Wachacki
...  contact: marcin.wachacki@nokia.com

Resource    ./resources/suite_specific_keywords.robot

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               prefix_tag=CB010496_CB008294
...               swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT4SK060/swconfig.txt


*** Test Cases ***

CB010496_W_22_SA_DL_peak_Tput_FR2_8CCDL_4CCUL_prach_175_C2_CB008294_W
    [Setup]    W 22 CB010496 Test Setup

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured
    Run Downlink TCP Data Transmission for 60 seconds
    Verify 8CC Downlink TCP Data Transmission
    Detach UE

    [Teardown]    W 101 Test Teardown

CB010496_W_23_SA_UL_peak_Tput_FR2_8CCDL_4CCUL_prach_175_C2_CB008294_W
    [Setup]    W 23 CB010496 Test Setup

    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1 and 7 Scells Are Configured
    Run Uplink TCP Data Transmission for 60 seconds
    Verify 4CC Uplink TCP Data Transmission
    Detach UE

    [Teardown]    W 201 Test Teardown
