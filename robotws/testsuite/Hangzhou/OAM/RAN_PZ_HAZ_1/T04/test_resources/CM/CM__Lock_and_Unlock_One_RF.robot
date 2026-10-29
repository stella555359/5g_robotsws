*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Keywords ***
CM__Lock_and_Unlock_One_RF
    [Documentation]    CM__Lock_and_Unlock_One_RF
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Lock and unlock one RF randomly.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.01.2024 - Bin.7.Liu - Commit to robotws.
    Step 1: Lock RMOD
    Step 2: Unlock RMOD

Step ${index}: Lock RMOD
    LOG    Step ${index}: Lock RMOD    console=${True}
    SBTS WEM Lock Units    ${RMODS}

Step ${index}: Unlock RMOD
    LOG    Step ${index}: Unlock RMOD    console=${True}
    SBTS WEM Unlock Units    ${RMODS}

Set Up
    LOG    Set Up    console=${True}
    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${True}    setup_value=false
    Select One RF

Tear Down
    LOG    Tear Down    console=${True}
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    SBTS WEM Download Chrome Console Log
    Close All Browsers

Select One RF
    SBTS WEM Open RunTime View    SV
    ${all_rmods}    SBTS WEM Filt Object On Navigation Panel Under Runtime View    RMOD-
    ${count}    Get Length    ${all_rmods}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${text}    Get Text    ${all_rmods[${index}]}
    ${RMODS}    Create List    ${text}
    Set Test Variable    ${RMODS}
