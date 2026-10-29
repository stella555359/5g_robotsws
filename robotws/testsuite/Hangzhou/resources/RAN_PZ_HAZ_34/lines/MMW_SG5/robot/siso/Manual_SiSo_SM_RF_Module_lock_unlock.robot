# @Time    : 2023/8/4 13:29
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : Manual_SiSo_SM_RF_Module_lock_unlock.robot
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
Manual_SiSo_SM_RF_Module_lock_unlock_2.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/15 22:51
    ${ru_index_list}    get all ru index
    Selenium Login And Disable Screen Lock
    FOR    ${ru_index}    IN    @{ru_index_list}
        Wait Until Keyword Succeeds    3x    15s    SISO Common L3 CALL
        ${operate_list}    create list    ${ru_index}
        Lock all RUs SISO    ru_index_list=${operate_list}
        Unlock all RUs SISO    ru_index_list=${operate_list}
        Verify BTS OnAir Ready For L3call
        Wait Until Keyword Succeeds    3x    15s    SISO Common L3 CALL
    END
    [Teardown]    Selenium Logout And Close Browser

Manual_SiSo_SM_RF_Module_lock_unlock_2.0_new
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/08 14:41
    ...    https://rep-portal.ext.net.nokia.com/details/qc-case/3655892/
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    # Step 1 Call: Ongoing call is made via the tested RF module.
    SISO Common L3 CALL

    # Step 2 RF transmission check: The RF transmission is checked with a spectrum analyzer (RF transmission power).
    # Step 3 Lock RF module: Lock module command in WebEM is given for tested radios and confirmation message is accepted.
    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru    ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    20s    RU Should Be Locked    ru_index=${ru_index}    connection=${connection}
    Wait Until Keyword Succeeds    5min    20s    Verify BTS Single RU's Cells Status Is RU Lock State    ru_index=${ru_index}

    # Step 4 RF transmission check: The RF transmission is checked with a spectrum analyzer (RF transmission power).
    # Step 5 RF module unlock: RM unlock command is given from WebEM on tested radios.
    selenium_coam.unlock_ru    ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    20s    RU Should Be Unlocked    ru_index=${ru_index}    connection=${connection}
    Wait until keyword succeeds    5min    20s    verify all cells should be onair    connection=${connection}

    # Step 6 RF transmission check: The RF transmission is checked with a spectrum analyzer (RF transmission power).
    # Step 7 Cancel RF module lock procedure

    # Step 8  Call: Call is made via the tested RF module.
    SISO Common L3 CALL
    Selenium Logout And Close Browser
