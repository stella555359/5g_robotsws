# @Time    : 2023/8/4 13:29
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : Manual_SiSo_SM_NR_RAT_reset.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature Common SISO

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
Manual_SiSo_SM_NR_RAT_reset_2.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/08 14:08
    [Arguments]    ${attach_mode}=SA    ${ul_tp}=100M    ${dl_tp}=300M    ${delta_ul_tp}=20
    ...        ${delta_dl_tp}=20
    # Step 1: all services normal, check throughput
    ${ul_tp_1}    ${dl_tp_1}    SISO Common L3 CALL    ul_tp=${ul_tp}    dl_tp=${dl_tp}
    Wait until keyword succeeds    5min    30s    Verify BTS All Cells Status Is Normal State

    # Step 2: reset nr, support cancel, check ru offline and online
    Selenium Login And Disable Screen Lock
    selenium_sbts.reset_nr    cancel=${True}
    selenium_sbts.reset_nr    cancel=${False}
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Wait until keyword succeeds    10min    20s    Verify BTS 5G Cells Status Is Cell Reset State
    Wait until keyword succeeds    20min    20s    Verify BTS 5G Cells Status Is Normal State
    ${status}    Run Keyword And Return Status    Should Be Equal As Strings    ${attach_mode}    NSA
    Run Keyword If    ${status}    Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB

    # Step 3: all services normal, check throughput close to last result
    ${ul_tp_2}    ${dl_tp_2}    SISO Common L3 CALL    ul_tp=${ul_tp}    dl_tp=${dl_tp}
    Verify Two Throughputs Are Similar    ${ul_tp_1}    ${ul_tp_2}    ${delta_ul_tp}
    Verify Two Throughputs Are Similar    ${dl_tp_1}    ${dl_tp_2}    ${delta_dl_tp}

General_SiSo_RAT_Reset_1.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/24 14:10
    ...    https://rep-portal.ext.net.nokia.com/details/qc-case/3777531/
    [Arguments]    ${ul_tp}=100M    ${dl_tp}=1000M
    # Step1: Set the following parameter actRATResetEnhancement = True
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actRatResetEnhancement    value=true
    Wait until keyword succeeds    5min    30s    Verify BTS All Cells Status Is Normal State

    # Step2: Calls are made on all configured RATs – before RAT RESET operation. Calls are continued during next operations.
    ${ul_tp_1}    ${dl_tp_1}    SISO Common L3 CALL    ul_tp=${ul_tp}    dl_tp=${dl_tp}
    Wait until keyword succeeds    5min    30s    Verify BTS All Cells Status Is Normal State

    # Step3: Press NR RAT Reset button.
    Selenium Login And Disable Screen Lock
    selenium_sbts.reset_nr    cancel=${True}
    selenium_sbts.reset_nr    cancel=${False}
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Wait until keyword succeeds    10min    20s    Verify BTS 5G Cells Status Is Cell Reset State
    Wait until keyword succeeds    5min    20s    Verify BTS 5G Cells Status Is Normal State

    # Step4: Perform call on NR RAT on all configured cells and monitor calls on the other RATs.
    ${ul_tp_2}    ${dl_tp_2}    SISO Common L3 CALL    ul_tp=${ul_tp}    dl_tp=${dl_tp}
    assert_values_close    ${ul_tp_1}    ${ul_tp_2}    10
    assert_values_close    ${dl_tp_1}    ${dl_tp_2}    10
