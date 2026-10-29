# @Time    : 2023/8/4 13:29
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : Manual_SiSo_CM_Recommissioning.robot
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

*** Variables ***
# Recovery reset delay    recoveryResetDelay
# MRBTS-2045/MNL-1/MNLENT-1    range(0~1200)
${NO_RESET_DIST}        MRBTS-${MRBTS_ID}/MNLENT-1
${NO_RESET_FILTER}      Recovery reset delay
${NO_RESET_ABBR}        recoveryResetDelay
${NO_RESET_OUT_RANGE_VALUE}    ${1201}
${NO_RESET_MODIFY_VALUE}    ${1}
# modify timezone will cause site reset
${RESET_DIST}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
${RESET_FILTER}      Time zone
${RESET_ABBR}        timeZone
${RESET_MODIFY_VALUE}    (GMT+8) Asia/Taipei
${RESET_ORIGIN_VALUE}    (GMT+8) Asia/Shanghai

*** Keywords ***
Manual_SiSo_CM_Recommissioning_2.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/04 16:28    https://rep-portal.ext.net.nokia.com/qc/instance/details/33246790/
    Selenium Login And Disable Screen Lock
    Connect to gnb coam via ssl


    ${RESET_DIST}    Set Variable If
    ...     '24R2'=='${Active_SW_version[4:8]}'        MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...     '24R3'=='${Active_SW_version[4:8]}'        MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...     MRBTS-${MRBTS_ID}/MNL-1

    # Step 1,2: ignore
    # Step 3,4,5,6: modify online and reset succeed
    Modify Single Parameter Value on WebUI  dist_name=${RESET_DIST}   filter_param=${RESET_FILTER}
    ...    abbr=${RESET_ABBR}   new_value=${RESET_MODIFY_VALUE}
    Wait until keyword succeeds    5min    1s    RU Should Be Offline
    Wait until keyword succeeds    5min    30s    RU Should Be Online
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair
    Close Start Up View Window
    Modify Single Parameter Value on WebUI  dist_name=${RESET_DIST}   filter_param=${RESET_FILTER}
    ...    abbr=${RESET_ABBR}   new_value=${RESET_ORIGIN_VALUE}
    Wait until keyword succeeds    5min    1s    RU Should Be Offline
    Wait until keyword succeeds    5min    30s    RU Should Be Online
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair
    Close Start Up View Window

    # Step 7,8,9,10: modify online success
    ${origin_value}    Get Single Parameter Value on WebUI   dist_name=${NO_RESET_DIST}   filter_param=${NO_RESET_FILTER}
    Run Keyword If    '${origin_value}'=='1 (sec)'    Set Test Variable    ${NO_RESET_MODIFY_VALUE}    0
    Modify and Check Single Parameter Value without reset  dist_name=${NO_RESET_DIST}   filter_param=${NO_RESET_FILTER}
    ...    abbr=${NO_RESET_ABBR}   new_value=${NO_RESET_MODIFY_VALUE}

    # Step 11: Save and check commissioning report
    ${report_file}    selenium_coam.save_report
    ${unzip_folder}    Remove String    ${report_file}    .zip
    Run Process    unzip ${report_file} -d ${unzip_folder}    shell=True
    ${report_data}    Get File    ${unzip_folder}/report-data.txt
    Should Contain    ${report_data}    BTS plan validation result:   Operation finished successfully
    Should Contain    ${report_data}    BTS plan activation result:   Operation finished successfully

    # Step 12,13: modify online to wrong value out range and undo change
    Verify Out Range Single Parameter Value And Undo Change   dist_name=${NO_RESET_DIST}   filter_param=${NO_RESET_FILTER}
    ...    abbr=${NO_RESET_ABBR}   new_value=${NO_RESET_OUT_RANGE_VALUE}

    Selenium Logout And Close Browser

Manual_SiSo_CM_Recommissioning_1.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/04 17:09    https://rep-portal.ext.net.nokia.com/qc/instance/details/32555648/
    Selenium Login And Disable Screen Lock
    Connect to gnb coam via ssl

    ${RESET_DIST}    Set Variable If
    ...     '24R2'=='${Active_SW_version[4:8]}'        MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...     '24R3'=='${Active_SW_version[4:8]}'        MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...     MRBTS-${MRBTS_ID}/MNL-1
    
    # Step 1,2: ignore
    # Step 3,4,5,6: modify online and reset succeed
    Modify Single Parameter Value on WebUI  dist_name=${RESET_DIST}   filter_param=${RESET_FILTER}
    ...    abbr=${RESET_ABBR}   new_value=${RESET_MODIFY_VALUE}
    Wait until keyword succeeds    5min    1s    RU Should Be Offline
    Wait until keyword succeeds    10min    30s    RU Should Be Online
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair
    Close Start Up View Window
    Modify Single Parameter Value on WebUI  dist_name=${RESET_DIST}   filter_param=${RESET_FILTER}
    ...    abbr=${RESET_ABBR}   new_value=${RESET_ORIGIN_VALUE}
    Wait until keyword succeeds    5min    1s    RU Should Be Offline
    Wait until keyword succeeds    10min    30s    RU Should Be Online
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair
    Close Start Up View Window

    # Step 7: Perform L3 call
    SISO Common L3 CALL
    Verify UE Voice Call Can Be Performed

    # Step 8,9,10,11: modify online success
    ${origin_value}    Get Single Parameter Value on WebUI   dist_name=${NO_RESET_DIST}   filter_param=${NO_RESET_FILTER}
    Run Keyword If    '${origin_value}'=='1 (sec)'    Set Test Variable    ${NO_RESET_MODIFY_VALUE}    0
    Modify and Check Single Parameter Value without reset  dist_name=${NO_RESET_DIST}   filter_param=${NO_RESET_FILTER}
    ...    abbr=${NO_RESET_ABBR}   new_value=${NO_RESET_MODIFY_VALUE}

    # Step 13: Save and check commissioning report
    ${report_file}    selenium_coam.save_report
    ${unzip_folder}    Remove String    ${report_file}    .zip
    Run Process    unzip ${report_file} -d ${unzip_folder}    shell=True
    ${report_data}    Get File    ${unzip_folder}/report-data.txt
    Should Contain    ${report_data}    BTS plan validation result:   Operation finished successfully
    Should Contain    ${report_data}    BTS plan activation result:   Operation finished successfully

    # Step 12: Perform L3 call
    SISO Common L3 CALL
    Verify UE Voice Call Can Be Performed

    # Step 13,14: modify online to wrong value out range and undo change
    Verify Out Range Single Parameter Value And Undo Change   dist_name=${NO_RESET_DIST}   filter_param=${NO_RESET_FILTER}
    ...    abbr=${NO_RESET_ABBR}   new_value=${NO_RESET_OUT_RANGE_VALUE}

    Selenium Logout And Close Browser
