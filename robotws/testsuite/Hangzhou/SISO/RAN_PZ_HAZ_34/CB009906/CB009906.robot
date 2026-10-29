# @Time    : 2023/1/13 17:11
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB009906.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB009906

Suite Setup     SISO Coam Suite Setup
Suite Teardown  SISO Coam Suite Teardown
Test Setup          MMW5 Common Case Setup
Test Teardown       MMW5 Common Case Teardown
Force Tags      CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Variables ***
${if_commissioning}    True
${SCF_20M}    ${CURDIR}/20M.xml
${SCF_100M}    ${CURDIR}/100M.xml


*** Test Cases ***
[3.0] General_SiSo_stability_with_L3Call
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c011
    SISO Common L3 CALL    call_time=1800    log_time=25m

[2.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c005
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_2.0

[2.0] General_SiSo_RU_module_reset_from_GUI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c001
    General_SiSo_RU_module_reset_from_GUI_2.0

[2.1] General_SiSo_Cell_block_and_unblock
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Tags]    c004
    General_SiSo_Cell_block_and_unblock_2.1

Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Tags]    c007
    Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module_1.0

[1.0] Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c002
    Manual_SiSo_SM_BTS_Site_Reset_1.0

[1.0] Manual_SiSo_STARTUP_BTS_Power_Reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c003
    MMW5_Manual_SiSo_STARTUP_BTS_Power_Reset

[1.0] Manual_SiSo_REC_Radio_Module_power_reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c009
    MMW5_Manual_SiSo_REC_Radio_Module_power_reset

[1.0] Manual_Siso_PM_5G_uDTX
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c010
    MMW5_Manual_Siso_PM_5G_uDTX

[2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Tags]    c006
    Manual_SiSo_SM_RF_Module_lock_unlock_2.0

[2.0] Manual_SiSo_SM_NR_RAT_reset
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Tags]    c008
    Manual_SiSo_SM_NR_RAT_reset_2.0

CB009906-I_2_Peak throughput with UL 256QAM Modulation on different bandwidth - NR20 - UDP and TCP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/31 15:45 need lock cell-1 and cell-3
    ...    ul=37.13542    dl=268.3505
    COAM Commission with scf file    ${SCF_20M}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    parameter=administrativeState    value=Locked
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    parameter=administrativeState    value=Locked
    Wait Until Keyword Succeeds   3x   10s    UE Attach And Check Throughput With Detach    global_cell_id=1
    ...    ul_tp=50M    ul_tp_threshold=33
    ...    dl_tp=300M   dl_tp_threshold=255
    Wait Until Keyword Succeeds   3x   10s    UE Attach And Check TCP Throughput    global_cell_id=1
    ...    ul_tp_threshold=33    dl_tp_threshold=255
    [Teardown]    Run Keywords
    ...    COAM Commission with scf file    ${SCF_20M}    is_pdl_checking_needed=${False}    timeout=900
    ...    AND    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online

CB009906-I_5_Peak throughput with DL 256QAM Modulation on different bandwidth - NR100 - UDP and TCP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/31 15:45 need lock cell-1 and cell-3
    ...    ul=222.5128    dl=1527.943
    COAM Commission with scf file    ${SCF_100M}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=administrativeState    value=Locked
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    parameter=administrativeState    value=Locked
    Wait Until Keyword Succeeds   3x   10s    UE Attach And Check Throughput With Detach    global_cell_id=2
    ...    ul_tp=250M    ul_tp_threshold=210
    ...    dl_tp=1500M   dl_tp_threshold=1450
    Wait Until Keyword Succeeds   3x   10s    UE Attach And Check TCP Throughput    global_cell_id=2
    ...    ul_tp_threshold=210    dl_tp_threshold=1450
    [Teardown]    Run Keywords
    ...    COAM Commission with scf file    ${SCF_100M}    is_pdl_checking_needed=${False}    timeout=900
    ...    AND    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
