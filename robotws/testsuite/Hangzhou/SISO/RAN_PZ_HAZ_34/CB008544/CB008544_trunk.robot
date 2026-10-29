# *** Settings ***
# Documentation     author: Wu Jerry
# ...               contact: jerry.wu@nokia-sbell.com
# ...               squad group: MMW_02
# Suite Setup       Suite Setup 8544
# Suite Teardown    SISO Coam Suite Teardown
# Force Tags        STATE_SW_UPLOADED    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_MTK_SA_ASILL_ABILB1_AEQU
# ...   PY39
# ...               SBTS00
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_addition_in_BIM_and_WebUI.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
# Resource          ../common/siso_cloud_coam_common_keyword.robot
# 
# 
# 
# *** Variables ***
# ${TS_CASE_LOG_PATH}    /home/ute
# @{GNB_PS_CELL_INDEX_LIST}    1
# ${du_scf_name_A}    SBTS00_20M_trunk.xml
# ${du_scf_name_B}    SBTS00_30M.xml
# ${du_scf_name_sbts00}    SCF_SBTS00.xml
# 
# *** Test Cases ***
# [1][3.0] General_SiSo_NR-ARFCN_check
#     [Documentation]    General_SiSo_NR-ARFCN_check
#     [Tags]    CRT
#     [Setup]    SISO Coam Test Setup
#     Commission_DU    du_scf_name=${du_scf_name_A}
#     Connect to gnb coam via ssl
#     General_SiSo_NR-ARFCN_check
#     [Teardown]    SISO Coam Test Teardown
# 
# [2][1.0] General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Documentation]    General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Tags]    CRT
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_RF_module_addition_in_BIM_and_WebUI
#     [Teardown]    SISO Coam Test Teardown
# 
# [1][1.1] General_SiSo_Commissioning_BTS_Template_Commissioning
#     [documentation]    The purpose of this test case is to check if not commissioned gNB can
#     ...    be correctly configured using BTS Template, verify Managed Object Class in WebUI
#     ...    and update parameters via WebUI. bandwith is 100mhz
#     [Tags]    CRT
#     [Setup]    SISO Coam Test Setup
#     #Modify Bandwith Parameters In SCF And Commission    band_info=${band_info_20MHZ}
#     General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Teardown]    SISO Coam Test Teardown
# 
# [3][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Documentation]    
#     [Tags]    CRT
#     [Setup]    SISO Coam Test Setup
#     Commission_DU    du_scf_name=${du_scf_name_B}
#     sleep    5s
#     Connect to gnb coam via ssl
#     General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     Commission_DU    du_scf_name=${du_scf_name_sbts00}
#     [Teardown]    SISO Coam Test Teardown
# 
# *** Keywords ***
# Suite Setup 8544
#     Sleep    600s
#     SISO Coam Suite Setup
# 
# L3 call ULDL and check throughput
#     [Arguments]   ${cell_list}    ${ul_throughput}=100M    ${dl_throughput}=300M   ${ul_expect}=10    ${dl_expect}=100
#     ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#     Set Test Variable    ${ue_type}
#     power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
#     power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
#     ...    iperf_type=via_command    protocol=udp
#     sleep    1s          
#     power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
#     ...    protocol=udp    buffer_size=1400B    process_num=${2}    seg_size=1350    window=16M
#     sleep    2s
#     ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    filter=L2Lo
#     ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
#     ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cell_list}
#     ...    ultarget_throughput=${ul_expect}    dltarget_throughput=${dl_expect}    actCarrierAggregation=${True}
#     Set Test Variable    ${all_tp}    ${all_tp}
#     ${dl_avg}    set variable    ${all_tp[1][0]['average']}
#     ${ul_avg}    set variable    ${all_tp[0][0]['average']}
#     Run Keyword And Ignore Error    should be true    ${dl_avg}>=${dl_expect}
#     Run Keyword And Ignore Error    should be true    ${ul_avg}>=${ul_expect}
#     [Teardown]    L3 call case teardown
# 
# L3 call case teardown
#     Run Keyword And Ignore Error    Run keywords
#     ...    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
#     ...    AND    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
#     Run Keyword And Ignore Error    Power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}
