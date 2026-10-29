# *** Settings ***
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   SISO
# 
# #Suite Setup    suite_setup
# Suite Setup    Run keywords    suite_setup    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Resource    ./resources/comm_7750A.robot
# Resource    ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# *** Variable ***
# @{cell_info_1}    ${1}
# @{cell_info_2}    ${2}
# @{all_cell_info}    ${0}    ${1}
# 
# *** Test Cases ***
# [1][1.0] General_SiSo_Cell_block_and_unblock
#     [Documentation]
#     ...    The purpose of this test case is to verify cell and group cell block/unblock functionality.
#     ...    -09.11.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CB007750
#     [Setup]
#     Check BTS Should Be Normal
#     SBTS Login
#     run keyword and continue on failure    Block Cell And Check Cell Status    cell_idx=${1}    cell_info=${cell_info_1}
#     wait until keyword succeeds    10s    1s    Check Expected Alarm    faultID=${49}    expected_alarmid=${7102}
#     ...    expected_objectname=${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
#     run keyword and continue on failure    Block Cell And Check Cell Status    cell_idx=${2}    cell_info=${cell_info_2}
#     wait until keyword succeeds    10s    1s    Check Expected Alarm    faultID=${49}    expected_alarmid=${7102}
#     ...    expected_objectname=${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
#     wait until keyword succeeds    3min    10s    Check Expected Alarm    faultID=${7300}    expected_alarmid=${7107}
#     ...    expected_objectname=${BTS_ID}/NRBTS-${NRBTS_ID}
#     Unblock Cell And Check Cell Status    cell_idx=${1}    cell_info=${cell_info_1}
#     Unblock Cell And Check Cell Status    cell_idx=${2}    cell_info=${cell_info_2}
#     wait until keyword succeeds    5min    10s    Check No Expected Alarm    fault_id=${49}
#     wait until keyword succeeds    5min    10s    Check No Expected Alarm    fault_id=${7300}
#     Single UE Attach And Start Traffic And Check Throughput
#     [Teardown]    run keywords    SBTS Logout    AND    CI_interface.Common Case Teardown
# 
# [1][1.0] General_SiSo_RF_module_power_reset
#     [Documentation]
#     ...    The objective of the test case is to verify RU recovery after power reset during normal operation (OnAir state).
#     ...    -15.11.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CRT_TRUNK    CRT_22R3    CRT_22R4    CB007750
#     [Setup]    Modify Bandwidth    cell_idx=${1}   Actual_value=80MHz
#     SBTS Login
#     Power Off Both RU
#     run keyword and continue on failure    Check Both RU Alarm And Status
#     Power On Both RU
#     Wait Until BTS Should Be Normal
#     Check Mate30pro Peak Throughput    throughput=1024MKbits/sec    target_tp_ul=100    target_tp_dl=1100
#     [Teardown]    run keywords    SBTS Logout    AND    RF_POWER_teardown
# 
# [1][1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#     [Documentation]
#     ...    This test case based on General_SiSo_Auto_gNB_Site_Reset_From_WebUI test case.
#     ...    The purpose of this test case is to verify success rate of gNB site reset activated from WebUI interface.
#     ...    -17.11.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CB007750
#     [Setup]
#     Check BTS Should Be Normal
#     SBTS Login
#     FOR    ${item}    IN RANGE    ${20}
#         Reset BTS And Wait Until On Air
#     END
#     [Teardown]    run keywords    SBTS Logout    AND    CI_interface.Common Case Teardown
# 
# [1]OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
#     [Documentation]
#     ...    This test case based on General_SiSo_Auto_RF_module_reset_from_WebUI test case.
#     ...    The purpose of this test case is to verify success rate of Radio Unit reset activated from WebUI interface.
#     ...    -17.11.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CB007750
#     [Setup]
#     Check BTS Should Be Normal
#     SBTS Login
#     ${status}    run keyword and return status    Reset RMOD FOR Keyword
#     run keyword if    '${status}' == 'False'    Save Snapshot Log
#     run keyword if    '${status}' == 'False'    Fail
#     [Teardown]    run keywords    SBTS Logout    AND    CI_interface.Common Case Teardown
# 
# [1][1.0] General_SiSo_RU_lock_unlock
#     [Documentation]
#     ...    The purpose of this test case is to verify that radio module and OAM behaves correctly during procedure of locking and unlocking.
#     ...    -18.11.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CRT_TRUNK    CRT_22R3    CB007750
#     [Setup]    Modify BWP_list And Bandwidth    cell_idx=${1}    Bandwidth_value=20MHz
#     ...    bwpDN_value=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-50
#     sleep    5min
#     SBTS Login
#     ${faultid_list1}    Get Active Alarm List
#     run keyword and continue on failure    Lock Both RU And Check Status
#     ${faultid_list2}    Get Active Alarm List
#     run keyword and continue on failure    lists should be equal    ${faultid_list1}    ${faultid_list2}
#     Unlock Both RU And Check Status
#     ${faultid_list3}    Get Active Alarm List
#     run keyword and continue on failure    lists should be equal    ${faultid_list2}    ${faultid_list3}
#     Check Mate30pro Peak Throughput    throughput=1024MKbits/sec    target_tp_ul=23.5    target_tp_dl=260
#     [Teardown]    run keywords    SBTS Logout    AND    Recover_BWP_list_And_Bandwidth_teardown
# 
# [1][2.0] General_SiSo_BTS_startup_with_delayed_RF_link_setup
#     [Documentation]
#     ...    The purpose of this test case is to check of establishing connection between the RU to the BTS in a reliable time,
#     ...    when fronthaul link was connected, with delay, between RAU and RU, after BTS (RAC and RAU) is online, connected and RU is powered on.
#     ...    -23.11.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CB007750
#     [Setup]
#     Check BTS Should Be Normal
#     SBTS Login
#     ${faultid_list1}    Get Active Alarm List
#     Power Off Both RU And Check Status
#     run keyword and continue on failure    Reset BTS And Wait Until Login
#     run keyword and continue on failure    Check Both RU Alarm And Status
#     Power On Both RU
#     wait until keyword succeeds    5min    10s    Check No Expected Alarm    fault_id=${10}
#     wait until bts should be normal
#     ${faultid_list2}    Get Active Alarm List
#     lists should be equal    ${faultid_list1}    ${faultid_list2}
#     Single UE Attach And Start Traffic And Check Throughput    throughput=2048MKbits/sec    ultarget_tp=100    dltarget_tp=100
#     [Teardown]    run keywords    SBTS Logout    AND    CI_interface.Common Case Teardown
# 
# [1]CB007750_A_5GC000702_AWHQE_02_General_SiSo_RF_module_reset_from_GUI
#     [Documentation]
#     ...    The purpose of this test case is to check if not commissioned gNB can be correctly configured using BTS Template,
#     ...    verify Managed Object Class in WebUI and update parameters via WebUI.
#     ...    -02.12.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CRT_TRUNK    CB007750
#     [Setup]    Modify BWP_list And Bandwidth    cell_idx=${1}    Bandwidth_value=40MHz
#     ...    bwpDN_value=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-51
#     Check BTS Should Be Normal
#     SBTS Login
#     ${expect_operate_status}    set variable if    ${if_22R2_version}    Enabled    enabled
#     Check RMOD Status    expected_RU=EB2125R0146    expect_operate_status=${expect_operate_status}
#     Reset Rmod And Check Cell Status
#     ${operational_status}    set variable if    ${if_22R2_version}    Enabled    enabled
#     wait until keyword succeeds    2min    10s    Check Cells Status    cell_info=${cell_info_1}    operational_status=${operational_status}
#     Check Mate30pro Peak Throughput    throughput=1024MKbits/sec    target_tp_ul=48.5    target_tp_dl=540
#     [Teardown]    run keywords    SBTS Logout    AND    Recover_BWP_list_And_Bandwidth_teardown
# 
# [1]CB007750_A_5GC000702_AWHQE_03_General_SiSo_Cell_lock_unlock
#     [Documentation]
#     ...    The purpose of this test case is to check if not commissioned gNB can be correctly configured using BTS Template,
#     ...    verify Managed Object Class in WebUI and update parameters via WebUI
#     ...    -06.12.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CRT_TRUNK    CRT_22R3    CRT_22R4    CB007750
#     [Setup]    Modify BWP_list And Bandwidth    cell_idx=${1}    Bandwidth_value=50MHz
#     ...    bwpDN_value=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-52
#     Check BTS Should Be Normal
#     SBTS Login
#     run keyword and continue on failure    Lock Cell And Check Cell Status    cell_idx=${1}    cell_info=${cell_info_1}
#     run keyword and continue on failure    Lock Cell And Check Cell Status    cell_idx=${2}    cell_info=${cell_info_2}
#     Unlock Cell And Check Cell Status    cell_idx=${1}    cell_info=${cell_info_1}
#     Unlock Cell And Check Cell Status    cell_idx=${2}    cell_info=${cell_info_2}
#     run keyword and continue on failure    Lock Cell And Check Cell Status    cell_idx=${2}    cell_info=${cell_info_2}
#     Check Mate30pro Peak Throughput    throughput=1024MKbits/sec    target_tp_ul=61.5    target_tp_dl=670
#     Unlock Cell And Check Cell Status    cell_idx=${2}    cell_info=${cell_info_2}
#     [Teardown]    run keywords    SBTS Logout    AND    Recover_BWP_list_And_Bandwidth_teardown
# 
# [1]CB007750_A_5GC000702_AWHQE_04_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#     [Documentation]
#     ...    The purpose of this test case is to check if not commissioned gNB can be correctly configured using BTS Template,
#     ...    verify Managed Object Class in WebUI and update parameters via WebUI.
#     ...    -13.12.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CRT_TRUNK    CRT_22R3    CB007750
#     [Setup]    case_setup_commission_scf
#     Check BTS Should Be Normal
#     run keyword and ignore error    Attach Test
#     Check Mate30pro Peak Throughput    throughput=1024MKbits/sec    target_tp_ul=125    target_tp_dl=1370    duration=300s
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1.0] General_SiSo_RF_alarms_without_recovery
#     [Documentation]
#     ...    The purpose of this test case is verification of RU connection and lack of attempt of RU recovery from fault state.
#     ...    RU should be affected by unrecoverable error triggered during normal BTS run.
#     ...    -27.12.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CB007750
#     [Setup]
#     Check BTS Should Be Normal
#     SBTS Login
#     Reset BTS And Wait Until On Air
#     Trigger Fault1937 On RMOD
#     wait until keyword succeeds    5min    10s    Check Expected Alarm    faultID=${1937}    expected_alarmid=${7116}
#     ...    expected_objectname=${BTS_ID}/EQM-1/APEQM-1/RMOD
#     Cancle Fault1937 On RMOD
#     wait until keyword succeeds    5min    10s    Check No Expected Alarm    fault_id=${1937}
#     wait until bts should be normal
#     [Teardown]    run keywords    SBTS Logout    AND    CI_interface.Common Case Teardown
# 
# [2.0] General_SiSo_RF_alarms_with_recovery
#     [Documentation]
#     ...    The purpose of this test case is verification of RU connection and fault reporting in WebUI.
#     ...    RU should be affected by recoverable error triggered during normal BTS run.
#     ...    -28.12.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CB007750
#     [Setup]
#     Check BTS Should Be Normal
#     SBTS Login
#     Reset BTS And Wait Until On Air
#     Trigger Fault 1901 On RMOD
#     wait until keyword succeeds    15min    15s    Check Expected Alarm    faultID=${1901}    expected_alarmid=${7111}
#     ...    expected_objectname=${BTS_ID}/EQM-1/APEQM-1/RMOD
#     Check Number Of Times Of Alarm    expect_faultid=${1901}    expected_alarmid=${7101}    expect_objiectname=${BTS_ID}/EQM-1/APEQM-1/RMOD
#     Cancel Fault 1901 On RMOD
#     wait until keyword succeeds    15min    15s    Check No Expected Alarm    fault_id=${1901}
#     wait until bts should be normal
#     [Teardown]    run keywords    SBTS Logout    AND    CI_interface.Common Case Teardown
# 
# [1]CB007750_A_5GC000702_AWHQE_01_General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Documentation]
#     ...    The purpose of this test case is to check if not commissioned gNB can be correctly configured using BTS Template,
#     ...    verify Managed Object Class in WebUI and update parameters via WebUI.
#     ...    -29.12.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CB007750
#     [Setup]
#     ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00_7750A.xml    Branch_scf_name=SCF_SBTS22R2_7750A.xml
#     Commission Default SCF    default_scf=${default_scf}
#     SBTS Login
#     Modify Parameter Success    Actual_value=(GMT+1) Poland
#     Check Parameter    expected_value=(GMT+1) Poland
#     ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-${BTS_ID}/MNL_A-1/MNLENT_A-1/SYNC_A-1/TIME_A-1    pattern=timeZone
#     Modify Parameter Fail    Actual_value=${880}
#     Check Parameter    expected_value=${38}
#     ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-${BTS_ID}/NRBTS_A-${NRBTS_ID}/NRCELL_A-1    pattern=pMax
#     Modify Parameter Success    Actual_value=(GMT+8) Asia/Shanghai
#     [Teardown]    run keywords    SBTS Logout    AND    CI_interface.Common Case Teardown
# 
# [1.0] General_SiSo_Online_Sector_Addition_Deletion
#     [Documentation]
#     ...    The purpose of this test case is to perform online sector (with min. one cell) addition and deletion from WebUI under
#     ...    tested configuration (which is capable of adding another sector
#     ...    -31.12.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_22R2    CRT_TRUNK    CRT_22R3    CRT_22R4    CB007750
#     [Setup]
#     Check BTS Should Be Normal
#     Start Traffic And Check Peak Throughput    throughput=1024MKbits/sec    target_tp_ul=125    target_tp_dl=1370    duration=2000
#     Delete RMOD-2 And Relevant Object
#     Check Only RMOD-2 Status
#     Check NRCELL-1 And Check Peak Throughput
#     Add RMOD-2 And Relevant Object
#     Check BTS Normal And Check Peak Throughput
#     [Teardown]    run keywords    Stop Traffic And UE Detach    AND    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Block Cell And Check Cell Status
#     [Arguments]    ${cell_idx}    ${cell_info}    ${usage_status}=Idle    ${block_status}=Blocked
#     block_cell    cell_idx=${cell_idx}
#     ${operational_status}    set variable if    ${if_22R2_version}    Disabled    disabled
#     wait until keyword succeeds    5min    10s    Check Cells Status    cell_info=${cell_info}    connection=default
#     ...    operational_status=${operational_status}    usage_status=${usage_status}    block_status=${block_status}
# 
# Unblock Cell And Check Cell Status
#     [Arguments]    ${cell_idx}    ${cell_info}    ${usage_status}=Active    ${block_status}=Unblocked
#     unblock_cell    cell_idx=${cell_idx}
#     ${operational_status}    set variable if    ${if_22R2_version}    Enabled    enabled
#     wait until keyword succeeds    5min    10s    Check Cells Status    cell_info=${cell_info}    connection=default
#     ...    operational_status=${operational_status}    usage_status=${usage_status}    block_status=${block_status}
# 
# Power Off Both RU
#     [Arguments]    ${expected_RU1}=EB2125R0146    ${expected_RU2}=EB2126R0067
#     Power Off RU    model=HBTE    RU_PDU_IP=${AWHQE1_PDU_IP}    RU_PDU_PORT=${AWHQE1_PDU_PORT}
#     Power Off RU    model=HBTE    RU_PDU_IP=${AWHQE2_PDU_IP}    RU_PDU_PORT=${AWHQE2_PDU_PORT}
#     sleep    30s
# 
# Power Off Both RU And Check Status
#     [Arguments]    ${expected_RU1}=EB2125R0146    ${expected_RU2}=EB2126R0067
#     Power Off RU    model=HBTE    RU_PDU_IP=${AWHQE1_PDU_IP}    RU_PDU_PORT=${AWHQE1_PDU_PORT}
#     Power Off RU    model=HBTE    RU_PDU_IP=${AWHQE2_PDU_IP}    RU_PDU_PORT=${AWHQE2_PDU_PORT}
#     sleep    30s
#     ${expect_operate_status}    set variable if    ${if_22R2_version}    Disabled    disabled
#     Check RMOD Status    expected_RU=${expected_RU1}    connection=default    expect_admin_status=Unlocked
#     ...    expect_operate_status=${expect_operate_status}    expect_usage_status=Idle    expect_procedure_status=not initialized
#     Check RMOD Status    expected_RU=${expected_RU2}    connection=default    expect_admin_status=Unlocked
#     ...    expect_operate_status=${expect_operate_status}    expect_usage_status=Idle    expect_procedure_status=not initialized
# 
# Check Both RU Alarm And Status
#     [Arguments]    ${expected_RU1}=EB2125R0146    ${expected_RU2}=EB2126R0067
#     wait until keyword succeeds    20min    20s    Check Expected Alarm    faultID=${10}    expected_alarmid=${7116}
#     ...    expected_objectname=${BTS_ID}/EQM-1/APEQM-1/RMOD-1
#     wait until keyword succeeds    5min    10s    Check Expected Alarm    faultID=${10}    expected_alarmid=${7116}
#     ...    expected_objectname=${BTS_ID}/EQM-1/APEQM-1/RMOD-2
#     ${expect_operate_status}    set variable if    ${if_22R2_version}    Disabled    disabled
#     Check RMOD Status    expected_RU=${expected_RU1}    connection=default    expect_admin_status=Unlocked
#     ...    expect_operate_status=${expect_operate_status}    expect_usage_status=Idle    expect_procedure_status=not initialized
#     Check RMOD Status    expected_RU=${expected_RU2}    connection=default    expect_admin_status=Unlocked
#     ...    expect_operate_status=${expect_operate_status}    expect_usage_status=Idle    expect_procedure_status=not initialized
# 
# Power On Both RU
#     Power On RU   model=HBTE    RU_PDU_IP=${AWHQE1_PDU_IP}    RU_PDU_PORT=${AWHQE1_PDU_PORT}
#     Power On RU   model=HBTE    RU_PDU_IP=${AWHQE2_PDU_IP}    RU_PDU_PORT=${AWHQE2_PDU_PORT}
# 
# Lock Both RU And Check Status
#      [Arguments]    ${expected_RU1}=EB2125R0146    ${expected_RU2}=EB2126R0067
#     Log To Console    Lock RU And Check Status
#     Lock RMOD    RMOD_idx=${1}
#     ${expect_operate_status}    set variable if    ${if_22R2_version}    Enabled    enabled
#     Check RMOD Status    expected_RU=${expected_RU1}    connection=default    expect_admin_status=Locked
#     ...    expect_operate_status=${expect_operate_status}    expect_usage_status=Idle    expect_procedure_status=configured
#     Lock RMOD    RMOD_idx=${2}
#     Check RMOD Status    expected_RU=${expected_RU2}    connection=default    expect_admin_status=Locked
#     ...    expect_operate_status=${expect_operate_status}    expect_usage_status=Idle    expect_procedure_status=configured
# 
# Unlock Both RU And Check Status
#     [Arguments]    ${expected_RU1}=EB2125R0146    ${expected_RU2}=EB2126R0067
#     Log To Console    Unlock RU And Check Status
#     ${expect_operate_status}    set variable if    ${if_22R2_version}    Enabled    enabled
#     Unlock RMOD   RMOD_idx=${1}
#     Check RMOD Status    expected_RU=${expected_RU1}    expect_operate_status=${expect_operate_status}    expect_usage_status=Idle
#     Unlock RMOD   RMOD_idx=${2}
#     Check RMOD Status    expected_RU=${expected_RU2}    expect_operate_status=${expect_operate_status}    expect_usage_status=Idle
#     Log To Console    wait until bts should be normal
#     wait until bts should be normal
# 
# RF_POWER_teardown
#     Modify Bandwidth    cell_idx=${1}   Actual_value=100MHz
#     CI_interface.Common Case Teardown
# 
# Recover_BWP_list_And_Bandwidth_teardown
#     Modify BWP_list And Bandwidth    cell_idx=${1}    Bandwidth_value=100MHz
#     ...    bwpDN_value=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-54
#     CI_interface.Common Case Teardown
# 
# Reset Rmod And Check Cell Status
#     [Arguments]    ${RU_index}=${1}    ${expected_RU1}=EB2125R0146    ${cell_info}=${1}
#     Reset RMOD    RU_index=${RU_index}
#     ${operational_status}    set variable if    ${if_22R2_version}    Disabled    disabled
#     Check Cells Status    cell_info=${cell_info}    connection=default    operational_status=${operational_status}    usage_status=Idle
#     ${expect_operate_status}    set variable if    ${if_22R2_version}    Enabled    enabled
#     wait until keyword succeeds    5min    10s    Check RMOD Status    expected_RU=${expected_RU1}
#     ...    expect_operate_status=${expect_operate_status}    connection=default
# 
# Lock Cell And Check Cell Status
#     [Arguments]    ${cell_idx}    ${cell_info}    ${usage_status}=Idle    ${lock_status}=Locked
#     lock_cell    cell_idx=${cell_idx}
#     ${operational_status}    set variable if    ${if_22R2_version}    Disabled    disabled
#     wait until keyword succeeds    5min    10s    Check Cells Status    cell_info=${cell_info}    connection=default
#     ...    operational_status=${operational_status}    usage_status=${usage_status}    lock_status=${lock_status}
# 
# Unlock Cell And Check Cell Status
#     [Arguments]    ${cell_idx}    ${cell_info}    ${usage_status}=Active    ${lock_status}=Unlocked
#     unlock_cell    cell_idx=${cell_idx}
#     ${operational_status}    set variable if    ${if_22R2_version}    Enabled   enabled
#     wait until keyword succeeds    5min    10s    Check Cells Status    cell_info=${cell_info}    connection=default
#     ...    operational_status=${operational_status}    usage_status=${usage_status}    lock_status=${lock_status}
# 
# Reset RMOD FOR Keyword
#     FOR    ${item}    IN RANGE    ${34}
#         ${faultid_list1}    Get Active Alarm List
#         Reset RMOD    RU_index=${1}
#         Reset RMOD    RU_index=${2}
#         Log To Console     wait until bts should be normal
#         wait until bts should be normal
#         ${faultid_list2}    Get Active Alarm List
#         run keyword and continue on failure    lists should be equal    ${faultid_list1}    ${faultid_list2}
#         Single UE Attach And Start Traffic And Check Throughput    throughput=2048MKbits/sec    ultarget_tp=100    dltarget_tp=1000
#     END
# 
# Check Number Of Times Of Alarm
#     [Arguments]    ${expect_faultid}    ${expected_alarmid}    ${expect_objiectname}
#     sleep    10s
#     ${number}    Number Of Times To Get History Alarm    expect_faultid=${expect_faultid}    expected_alarmid=${expected_alarmid}
#     ...    expect_objiectname=${expect_objiectname}
#     should be equal    ${number}    ${3}
# 
# Check Only RMOD-2 Status
#     SBTS Login
#     ${expect_operate_status}    set variable if    ${if_22R2_version}    Enabled    enabled
#     Check RMOD Status    expected_RU=EB2126R0067    connection=default    expect_admin_status=Unlocked
#     ...    expect_operate_status=${expect_operate_status}    expect_usage_status=Idle    expect_procedure_status=configured
#     [Teardown]    SBTS Logout
# 
# Check NRCELL-1 And Check Peak Throughput
#     SBTS Login
#     ${operational_status}    set variable if    ${if_22R2_version}    Enabled   enabled
#     ${cell_info}    create list    ${0}
#     FOR    ${item}    IN RANGE    ${20}
#         Check Cells Status    cell_info=${cell_info_1}    all_cell_info=${cell_info}    operational_status=${operational_status}
#         sleep    2s
#     END
#     Check Peak Throughput Only    target_tp_ul=125    target_tp_dl=1370
#     [Teardown]    SBTS Logout
# 
# Check BTS Normal And Check Peak Throughput
#     Check BTS Should Be Normal
#     SBTS Login
#     ${operational_status}    set variable if    ${if_22R2_version}    Enabled   enabled
#     FOR    ${item}    IN RANGE    ${20}
#         Check Cells Status    cell_info=${all_cell_info}    operational_status=${operational_status}
#         sleep    2s
#     END
#     Check Peak Throughput Only    target_tp_ul=125    target_tp_dl=1370
#     [Teardown]    SBTS Logout
# 
# case_setup_commission_scf
#     ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00_7750A.xml    Branch_scf_name=SCF_SBTS22R2_7750A.xml
#     Commission Default SCF    default_scf=${default_scf}
# 
# suite_setup
#     ${default_scf}    suite setup to prepare default scf    SBTS_scf_name=SCF_SBTS00_7750A.xml    Branch_scf_name=SCF_SBTS22R2_7750A.xml
#     Commission Default SCF    default_scf=${default_scf}
#     Judge Version If 22R2_version
