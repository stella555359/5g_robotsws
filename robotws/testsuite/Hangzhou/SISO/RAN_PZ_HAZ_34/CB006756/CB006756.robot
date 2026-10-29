*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_without_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource     Resources/CB006756_common_keywords.robot
Resource     Resources/CB008562_AQQQ_keywords.robot
Resource     Resources/CB008941_common_keyword_AB.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Variables    Resources/variables_CB006756.py



Documentation
...    Author:shufei chen
...    contact:shufei.chen@nokia-sbell.com
...    squad group:SG_08
...    Feature CB006756 in 5G00 program

Force Tags            5G_RAN_TDD    SBTS00    CRT_22R4    CRT_23R1
...    PY36

*** Variables ***
${MAX_LOOP}    20
@{band_2CC}    50M  50M
@{band_1CC_20}    20M
@{band_1CC_90}    90M
*** Test Cases ***
[1]General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
    RU_lock_unlock_for_spark    ue_index_list=${ue_list_1}    tput_expect=${tput_peak}

[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R3
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]General_SiSo_RF_alarms_with_recovery
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R3
    General_SiSo_RF_alarms_with_recovery

[1]CB012469_Static_DVM_Check_With_Multiple_Pmax_Change
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}  
    PAPSU check with SDVM for AQQQ

[1]General_SiSo_Cell_lock_and_unlock_2CC
    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
    Commission SCF With Specific Band If Needed    band=${band_2CC}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    Cell_lock_and_unlock_for_spark    ue_index_list=${ue_list_2}    tput_expect=${tput_peak}

[1]General_SiSo_Cell_block_and_unblock_2CC
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
    Commission SCF With Specific Band If Needed    band=${band_2CC}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    Cell_block_and_unblock_for_spark    tput_expect=${peak_info_2}

[1]General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R3
    Commission 1S1CC SCF If Needed
    General_SiSo_Commissioning_BTS_Template_Commissioning

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_90MHz
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R3
    Commission SCF With Specific Band If Needed    band=${band_1CC_90}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    Sigspark_L3call    ue_index_list=${ue_list_1}    tput_expect=${peak_info_1}

[1]General_SiSo_NR-ARFCN_check
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R3
    Commission 1S1CC SCF If Needed
    General_SiSo_NR-ARFCN_check

[1]General_SiSo_RF_alarms_without_recovery
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R3
    Commission 1S1CC SCF If Needed
    General_SiSo_RF_alarms_without_recovery

[1]General_SiSo_BTS_startup_with_RF_delayed_startup
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R3
    Commission 1S1CC SCF If Needed
    General_SiSo_BTS_startup_with_RF_delayed_startup

[1]General_SiSo_RF_module_power_reset
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
    Commission 1S1CC SCF If Needed
    General_SiSo_RF_module_power_reset

[1]General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R3
    Commission 1S1CC SCF If Needed
    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_50Mhz_50MHz
   [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CDRT_22R2    CRT_22R3
   Commission SCF With Specific Band If Needed    band=${band_2CC}
   COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
   ${release}    Get program version based on gNB active version
   log to console    ${release}
#   ${status}    run keyword and return status     Should contain    ${release}    master
#   run keyword if    ${status}    Sigspark_L3call    ue_index_list=${ue_list_2}    tput_expect=${peak_info_3}
#   ...    ELSE    Sigspark_L3call    ue_index_list=${ue_list_2}    tput_expect=${peak_info_2}
#   Sigspark_L3call    ue_index_list=${ue_list_2}    tput_expect=${peak_info_3}
   Sigspark_L3call_from_tool    ue_index_list=${ue_list_2}    tput_expect=${tput_peak}    cell_list=${cell_list}

[1][1.0] General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break
    [Tags]    CRT_TRUNK    CRT_23R1
    Commission SCF With Specific Band If Needed    band=${band_2CC}
    General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_call_AQQQ

[1]CB008941-SR-AB-1_Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF-AB-1

[1]CB008941-SR-AB-8_L3call_Loki_based_DU_with_short_PUCCH_FDBF
    L3call_Loki_based_DU_with_short_PUCCH_FDBF-AB-8

[1]CB010766-SR-A-3 Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431
    [Tags]    CRT_TRUNK
    Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431

[1][1.0] CB010471_B_TX_Switch_Off_IWK
    [Tags]    CRT_TRUNK
    CB010471_B_TX_Switch_Off_IWK

*** Keywords ***
