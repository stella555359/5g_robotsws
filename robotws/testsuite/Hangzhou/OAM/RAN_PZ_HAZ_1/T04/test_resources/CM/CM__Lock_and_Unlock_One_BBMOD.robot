*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Keywords ***
CM__Lock_and_Unlock_One_BBMOD
    [Documentation]    CM__Lock_and_Unlock_One_BBMOD
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Lock and unlock one BBMOD randomly.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.01.2024 - Bin.7.Liu - Commit to robotws.
    Step 1: Lock BBMOD
    Step 2: Unlock BBMOD

Step ${index}: Lock BBMOD
    LOG    Step ${index}: Lock BBMOD    console=${True}
    SBTS WEM Lock Units    ${BBMODS}

Step ${index}: Unlock BBMOD
    LOG    Step ${index}: Unlock BBMOD    console=${True}
    SBTS WEM Unlock Units    ${BBMODS}

Set Up
    LOG    Set Up    console=${True}
    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${True}    setup_value=false
    Select One BBMOD

Tear Down
    LOG    Tear Down    console=${True}
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    SBTS WEM Download Chrome Console Log
    Close All Browsers

Select One BBMOD
    SBTS WEM Open RunTime View    SV
    ${all_bbmods}    SBTS WEM Filt Object On Navigation Panel Under Runtime View    BBMOD-
    ${count}    Get Length    ${all_bbmods}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${text}    Get Text    ${all_bbmods[${index}]}
    ${BBMODS}    Create List    ${text}
    Set Test Variable    ${BBMODS}
