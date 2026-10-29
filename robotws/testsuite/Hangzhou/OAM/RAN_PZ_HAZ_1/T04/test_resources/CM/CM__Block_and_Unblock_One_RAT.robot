*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Keywords ***
CM__Block_and_Unblock_One_RAT
    [Documentation]    CM__Block_and_Unblock_One_RAT
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Block and unblock one RAT randomly.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.01.2024 - Bin.7.Liu - Commit to robotws.
    Step 1: Block One RAT
    Step 2: Unblock One RAT

Step ${index}: Block One RAT
    LOG    Step ${index}: Block One RAT    console=${True}
    SBTS WEM Block One RAT    ${RAT}
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    ${is_alarm_raised}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{alarms}
        Continue For Loop If    "${alarm['Alarm ID']}"!="7102"
        Continue For Loop If    "${alarm['Fault ID']}"!="4614"
        ${is_alarm_not_raised}    Run Keyword And Return Status    Should Not Contain    ${alarm['Configuration alarming object']}    ${RAT_MO_TYPE}
        Continue For Loop If    ${is_alarm_not_raised}
        ${is_alarm_raised}    Set Variable    ${True}
    END
    Should Be True    ${is_alarm_raised}

Step ${index}: Unblock One RAT
    LOG    Step ${index}: Unblock One RAT    console=${True}
    SBTS WEM Unblock One RAT    ${RAT}
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    ${is_alarm_raised}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{alarms}
        Continue For Loop If    "${alarm['Alarm ID']}"!="7102"
        Continue For Loop If    "${alarm['Fault ID']}"!="4614"
        ${is_alarm_not_raised}    Run Keyword And Return Status    Should Not Contain    ${alarm['Configuration alarming object']}    ${RAT_MO_TYPE}
        Continue For Loop If    ${is_alarm_not_raised}
        ${is_alarm_raised}    Set Variable    ${True}
    END
    Should Not Be True    ${is_alarm_raised}

Set Up
    LOG    Set Up    console=${True}
    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${False}
    Select One Commissioned RAT

Tear Down
    LOG    Tear Down    console=${True}
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Run Keyword If Test Failed    SBTS WEM Unblock One RAT    ${RAT}
    SBTS WEM Download Chrome Console Log
    Close All Browsers

Select One Commissioned RAT
    ${rat_status}    SBTS WEM Get RAT Status
    ${rat_list}    Get Dictionary Keys    ${rat_status}
    ${commissioned_rat_list}    Create List
    FOR    ${rat}    IN    @{rat_list}
        Continue For Loop If    "${rat_status['${rat}']}"=="Not commissioned"
        Append To List    ${commissioned_rat_list}    ${rat}
    END
    ${selected_rat}    Evaluate    random.choice(${commissioned_rat_list})    modules=random, sys
    Set Test Variable    ${RAT}    ${selected_rat}
    LOG    ${RAT} is selected.    console=${True}
    ${rat_mo_type_mapping}    Create Dictionary    NR=NRBTS    LTE=LNBTS    GSM=BCF    WCDMA=WBTS
    Set Test Variable    ${RAT_MO_TYPE}    ${rat_mo_type_mapping['${RAT}']}
