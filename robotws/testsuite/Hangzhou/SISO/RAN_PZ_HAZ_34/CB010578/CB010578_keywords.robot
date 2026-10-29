# @Time    : 2023/9/14 10:32
# @Author  : echo.xu
# @Email   : echo.xu@nokia-sbell.com
# @File    : CB010578_ABIP.robot
# @Software: PyCharm

*** Settings ***
Documentation        This is common keywords about CB010578
Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009181/CB009181_keywords.robot

*** Keywords ***
Manual_SiSo_SM_single_RF_Module_lock_unlock_NR_1.0
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2024/01/18
    [Arguments]    ${ru_index}=1
    Wait Until Keyword Succeeds    3x    15s    SISO Common L3 CALL
    Selenium Login And Disable Screen Lock
    Lock one RU SISO    ru_index=${ru_index}
    UnLock one RU SISO    ru_index=${ru_index}
    Verify BTS OnAir Ready For L3call
    Wait Until Keyword Succeeds    3x    15s    SISO Common L3 CALL
    [Teardown]    Selenium Logout And Close Browser

Manual_SiSo_SM_single_RF_Module_lock_unlock_LTE_1.0
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2024/01/18
    [Arguments]    ${ru_index}=1
    LTE UE Attach And Verify DL Throughput
    Selenium Login And Disable Screen Lock
    Lock one RU SISO    ru_index=${ru_index}
    UnLock one RU SISO    ru_index=${ru_index}
    Verify BTS OnAir Ready For L3call
    Wait Until Keyword Succeeds    3x    15s    LTE UE Attach And Verify DL Throughput
    [Teardown]    Selenium Logout And Close Browser

Lock one RU SISO
    [Arguments]    ${ru_index}    ${connection}=GNB_OAM
    log to console  \n***Lock RU***
    selenium_coam.lock_ru  ru_index=${ru_index}
    sleep  30
    connect to gnb coam via ssl
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${ru_index}    connection=${connection}

UnLock one RU SISO
    [Arguments]      ${ru_index}    ${connection}=GNB_OAM
    log to console  \n***Unlock RU***
    selenium_coam.unlock_ru  ru_index=${ru_index}
    sleep  30
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked    ru_index=${ru_index}    connection=${connection}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    connection=${connection}

SISO_Teardown_power_on_and_load_full_commission
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2024/01/29
    [Arguments]    ${RU_list}    ${target_SCF}
    MMW5 Rus Power On    RU_INDEX=${RU_list}
    Sleep    4m
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State
    COAM Commission with scf file    ${target_SCF}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    20min    15s    Verify BTS All Cells Status Is Normal State