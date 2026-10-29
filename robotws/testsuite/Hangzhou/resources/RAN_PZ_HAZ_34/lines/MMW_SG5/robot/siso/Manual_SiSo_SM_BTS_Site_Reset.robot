# @Time    : 2023/8/4 13:29
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : Manual_SiSo_SM_BTS_Site_Reset.robot
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
Manual_SiSo_SM_BTS_Site_Reset_1.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/15 22:10
    [Arguments]      ${range_time}=${3}
    FOR	   ${i}    IN RANGE    ${range_time}
        Perform BTS Site Reset
        Sleep    180s
        Verify BTS OnAir Ready For L3call    wait_time=20min
        Wait Until Keyword Succeeds    5x    3s    SISO Common L3 CALL    ul_tp=5M    dl_tp=5M
        Selenium Logout And Close Browser
    END

Manual_SiSo_SM_BTS_Site_Reset_2.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/24 11:25
    Manual_SiSo_SM_BTS_Site_Reset_1.0
