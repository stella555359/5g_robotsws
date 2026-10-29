*** Settings ***
Documentation
...   author: Sara Nowak, Andrzej Pencak
...   contact: sara.nowak@nokia.com, andrzej.pencak@nokia.com
...   Test suite for CB014359 feature

Library    taf.ue                                                                                   WITH NAME    ue
Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Resource     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB014359/resources/suite_setup_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Suite Setup
*** Variables ***
${skip_commissioning}    true
${skip_common_steps}    false

@{critical_faults}       0010  0016  1806  1868  4341  4352  4383
@{ALLOWED_ALARMS}   61649   61648   7115   4420   4655    61524    61652    4654    62003    62001   7331   7311    7307
...                                 Failure in connection between BTS and 3rd party tool
...                                 LMP connectivity detected
${ITERATIONS}                    5
${BBMOD_RESET_TEST_ITERATION}    10


*** Test Cases ***

CB014359_Verify_Attach_Success_Rate_across_various_RSRP_ranges_in_non-overlapping_areas
    [Setup]       Test Setup

    Set cell area 1 attenuation to 0dB
    Verify Attach Success Rate    iterations=${ITERATIONS}    nr_cell_id=${nr_cell_12_id}
    Set cell area 2 attenuation to 0dB
    Verify Attach Success Rate    iterations=${ITERATIONS}    nr_cell_id=${nr_cell_12_id}

    Set cell area 1 attenuation to 20dB
    Verify Attach Success Rate    iterations=${ITERATIONS}    nr_cell_id=${nr_cell_12_id}
    Set cell area 2 attenuation to 20dB
    Verify Attach Success Rate    iterations=${ITERATIONS}    nr_cell_id=${nr_cell_12_id}

    Set cell area 1 attenuation to 40dB
    Verify Attach Success Rate    iterations=${ITERATIONS}    nr_cell_id=${nr_cell_12_id}
    Set cell area 2 attenuation to 40dB
    Verify Attach Success Rate    iterations=${ITERATIONS}    nr_cell_id=${nr_cell_12_id}

    [Teardown]    Test Teardown

General_SiSo_BB_sub-unit_reset_with_L3_call
     [Setup]       Test Setup
     Set cell area 1 attenuation to 0dB
     Start DL and UL data transmission for specified time
     ...    tput_dl_min=100 Mbits/sec
     ...    tput_ul_min=30 Mbits/sec

    Repeat keyword    ${BBMOD_RESET_TEST_ITERATION}times    Reset BBMOD and perform L3 call
    [Teardown]    Test Teardown
