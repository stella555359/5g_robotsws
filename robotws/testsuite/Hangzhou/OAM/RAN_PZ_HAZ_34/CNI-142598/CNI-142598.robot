*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
#Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Variables     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CNI-142598/Resource/variable.py

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...
...    Feature CNI-142598: Descope CNI-131539 content in 25R3 - unhide 4 faults With this feature
...    Identified 4 faults should be sent to NMS and WebEM from 26R2:
...    4710	   FDD SyncE-Assisted Holdover period shorter than Adaptive Holdover period
...    4711    TDD-4G SyncE-Assisted Holdover period shorter than Adaptive Holdover period
...    4712    TDD-5G SyncE-Assisted Holdover period shorter than Adaptive Holdover period
...    6502    High memory consumption
...
...    Note: this case shall be associated with TPS1830

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all


*** Test Cases ***
[1]CNI-142598-A_01_Fault4711_can_be_raised_and_canceled_on_WebEM
    [Tags]    1S-2CC_CNI-142598    CRT_TRUNK
    [Setup]    SISO Coam Test Setup

    #ignore FID 4590 bts crash due to POWER_OFF runtime
    ${fault_list}    Create List    4711    4712    4590
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    add fault to the allowed fault list    faultId=${4711}
    add fault to the allowed fault list    faultId=${4712}
    add fault to the allowed fault list    faultId=${4590}
    add fault to allowed history fault list    faultId=${4711}
    add fault to allowed history fault list    faultId=${4712}
    add fault to allowed history fault list    faultId=${4590}

    #WA to clean Adaptive Holdover period which may trigger FID 4711/4712 esaily
    Log to console    \nPower reset bts after commissioning scf (see case tags)
    Perform Site Power Off
    Sleep    30s
    Perform Site Power On
    sleep    300s
    Wait until keyword succeeds    10 min    60 sec   verify all cells should be onair

    # #the other way: online modiry ssmAcceptanceLevel after recommissioning scf
    # log to console  \nOnline Change ssmAcceptanceLevel to trigger FID 4711/4712
    # @{split_version}    string.split string    ${Active_SW_version}    separator=_
    # ${stream}    set variable     ${split_version}[0]
    # Run Keyword And Ignore Error    Selenium Logout And Close Browser
    # Selenium Login And Disable Screen Lock    version=${stream}
    # ${orig_ssmvalue}    Get Single Parameter Value on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    # ...    filter_param=Acceptable SSM level for syncE source
    # Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    # ...    filter_param=Acceptable SSM level for syncE source    abbr=ssmAcceptanceLevel    new_value=ssmePRTC
    # Sleep    5s
    # Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    # ...    filter_param=Acceptable SSM level for syncE source    abbr=ssmAcceptanceLevel    new_value=ssmPRCorPRS

    Wait until keyword succeeds    5 min    30 sec   History Alarm Should Be Exist    checked_faults=${CHECKED_FAULT}

    [Teardown]    SISO Coam Test Teardown
    # [Teardown]    Run keywords    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    # ...    AND    wait until keyword succeeds    3x   20s    Selenium Login And Disable Screen Lock    version=${stream}
    # ...    AND    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    # ...           filter_param=Acceptable SSM level for syncE source    abbr=ssmAcceptanceLevel    new_value=${orig_ssmvalue}
    # ...    AND    Selenium Logout And Close Browser
    # ...    AND    SISO Coam Test Teardown

*** Keywords ***
History Alarm Should Be Exist
    [Documentation]
    ...    :param allowed_faults<list>: list contains dictionary, eg. [{'faultId':4711}, {'faultId': 4712}]
    [Arguments]   ${checked_faults}    ${connection}=GNB_OAM
    log to console  \nCheck history alarms on WebEM
    ${history_alarms_list}    coam.get_historic_alarms    connection=${connection}    timeout=300    load_history=${True}
    ${history_alarms_num}     Get Length    ${history_alarms_list}

    FOR  ${fault}  IN  @{checked_faults}
        Exit For Loop If   ${history_alarms_num}==${0}
        log to console  \nChecking History Alarm : ${fault['faultId']}
        ${found}=    Set Variable    ${False}
        FOR  ${alarm}  IN  @{history_alarms_list}
            Run Keyword If   '${alarm['faultId']}'=='${fault['faultId']}'
            ...    Run Keywords    Set Test Variable    ${found}    ${True}    AND    Exit For Loop
        END
        Run Keyword If   '${found}'=='${False}'
        ...    Fail    History Alarm : ${fault['faultId']} not exist on WebEM
        ...    ELSE    Log to console   \nHistory Alarm : ${fault['faultId']} exist on WebEM
    END
