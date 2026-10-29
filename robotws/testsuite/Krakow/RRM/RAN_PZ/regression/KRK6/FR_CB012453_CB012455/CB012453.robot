*** Settings ***
Documentation
...   author: Sara Nowak
...   contact: sara.nowak@nokia.com
...   maintainer: sara.nowak@nokia.com

Resource    ./resources/suite_specific_keywords.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

*** Test Cases ***
CB012453-E#B1_Mixed_1_sector_8ccDL4ccUL_and_2_sectors_4ccDL2ccUL_2T2R_100_Mhz_on_full_ASOH
    [Documentation]    TC: https://rep-portal.ext.net.nokia.com/details/qc-case/37188040/

    [Setup]    run keywords    Test Setup    AND    Prepare UEs for L3 Call

    Upload configuration CB012453-SR-E
    Verify Allowed Alarms

    Attach UE3 With Cell Verification
    Start and Verify UDP 8CC DL and 4CC UL data transfer for UE3

    Attach UE2 With Cell Verification
    Start and Verify UDP 4CC DL and 2CC UL data transfer for UE2
    Detach UEs

    [Teardown]    Test Teardown


CB012453-B#B1_2_sectors_8ccDL4ccUL_2T2R_100Mhz_full_ASOH
    [Documentation]    TC: https://rep-portal.ext.net.nokia.com/details/qc-case/38019945/

    [Setup]    run keywords    Test Setup    AND    Prepare UEs for L3 Call

    Upload configuration CB012453-SR-B
    Verify Allowed Alarms

    Attach UE3 With Cell Verification
    Start and Verify UDP 8CC DL and 4CC UL data transfer for UE3
    Detach UEs

    [Teardown]    Test Teardown


CB012453-W_01_02_Single_UE_NSA_DL_UL_peak_Tput_FR2_8CCDL_4CCUL_with_beamforming_prach_175

    [Setup]    run keywords    Test Setup    AND    Prepare UEs for L3 Call

    Upload configuration CB012453-SR-W
    Verify Allowed Alarms

    Attach UE3 With Cell Verification
    Start and Verify bidirectional 8CC DL and 4CC UL data transfer for UE3
    Detach UEs

    [Teardown]    Test Teardown
