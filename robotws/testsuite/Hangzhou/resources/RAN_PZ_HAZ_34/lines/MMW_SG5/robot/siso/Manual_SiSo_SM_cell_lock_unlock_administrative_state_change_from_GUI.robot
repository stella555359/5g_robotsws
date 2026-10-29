# @Time    : 2023/8/4 13:29
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : Manual_SiSo_SM_cell_lock_unlock_administrative_state_change_from_GUI.robot
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
Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI_1.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/07/10 17:24
    [Arguments]    ${lock_times}=2    ${connection}=GNB_OAM
    FOR    ${count}    IN RANGE    ${lock_times}
        # Step 1: all services normal
        SISO Common L3 CALL

        # Step 2: lock nr cell
        coam.lock    technology=NR    timeout=60    connection=${connection}
        Wait Until Keyword Succeeds    10min    30s    Verify BTS 5G Cells Status Is Cell Lock State
        Verify BTS 4G Cells Status Is Normal State

        # Step 3: unlock nr cell
        coam.unlock    technology=NR    timeout=60    connection=${connection}
        Wait Until Keyword Succeeds    10min    30s    Verify BTS All Cells Status Is Normal State
        
        # Step 4: all services normal
        SISO Common L3 CALL
    END

Manual_SiSo_SM_LTE_cell_lock_unlock_administrative_state_change_from_GUI_1.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/17 13:33
    [Arguments]    ${technology}=LTE    ${connection}=GNB_OAM
    # Step 1: lte call normal
    ${ue_type1}    translate power ue type from testline    ue_index=0
    LTE UE Attach And Verify DL Throughput    ue_type=${ue_type1}

    # Step 2: lock lte cell, check lte cell locked
    coam.lock    technology=${technology}    timeout=600    connection=${connection}
    Wait Until Keyword Succeeds    10min    30s    Verify BTS 4G Cells Status Is Locked State

    # Step 3: unlock lte cell, check lte cell unlocked
    coam.unlock    technology=${technology}    timeout=600    connection=${connection}
    Wait Until Keyword Succeeds    10min    30s    Verify BTS 4G Cells Status Is Normal State

    # Step 4: lte call normal
    LTE UE Attach And Verify DL Throughput    ue_type=${ue_type1}
