*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_without_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008578/Resources/CB008578_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource     Resources/CB009321_common_keywords.robot
Variables    Resources/variables_CB009321.py

Documentation
...    Author:shufei chen
...    contact:shufei.chen@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009321_AEQW in 5G00 program

Force Tags    5G_RAN_TDD    SBTS00    CRT_TRUNK    CRT_23R3    CRT_23R2    CRT_23R1    
...    PY36

*** Variables ***
${actDlSrsBm_scf}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/scf_actDlSrsBm.xml
${MAX_LOOP}    20
@{band}    100M
@{band_1}    50M    50M
@{band_2}    40M
@{band_3}    20M
@{band_5}    60M
@{band_6}    30M    40M
*** Test Cases ***

[1]General_SiSo_Cell_lock_and_unlock_2CC
    [Tags]    CRT_TRUNK    CRT_22R4
    Commission SCF With Specific Band If Needed    band=${band_1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    ${4G_check}    run keyword if    '${gNb_CuType}'=='NSA'    set variable    True    ELSE    set variable    False
    General_SiSo_Cell_lock_and_unlock_SG08    tput_self_define=${Cell_lock_unlock}    target_avg_percent=0.5    min_percent=0.3
#    CB009321_General_SiSo_Cell_lock_and_unlock    4G_check=${4G_check}

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_30Mhz_40Mhz
    [Tags]    CRT_TRUNK
    Commission SCF With Specific Band If Needed    band=${band_6}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    ${4G_check}    run keyword if    '${gNb_CuType}'=='NSA'    set variable    True    ELSE    set variable    False
    data_transfer_common    tput_self_define=${tput_define_30_40}    

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_50Mhz_50MHz
    [Tags]    CRT_TRUNK    CRT_22R4
    Commission SCF With Specific Band If Needed    band=${band_1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    ${4G_check}    run keyword if    '${gNb_CuType}'=='NSA'    set variable    True    ELSE    set variable    False
    data_transfer_common    tput_self_define=${tput_define_50_50}    

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_60MHz
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Commission SCF With Specific Band If Needed    band=${band_5}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
#    ${4G_check}    run keyword if    '${gNb_CuType}'=='NSA'    set variable    True    ELSE    set variable    False
#    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_0ms_GP2_A7    prach_index=194    enable_2197=${False}
#    ...    dl_ul_layer=4DL4UL    4G_check=${4G_check}
#
#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_40MHz
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Commission SCF With Specific Band If Needed    band=${band_2}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
#    ${4G_check}    run keyword if    '${gNb_CuType}'=='NSA'    set variable    True    ELSE    set variable    False
#    General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1208_GP1_A1    prach_index=192    enable_2197=${False}
#    ...    dl_ul_layer=4DL4UL    4G_check=${4G_check}
#
#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_20MHz
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Commission SCF With Specific Band If Needed    band=${band_3}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
#    ${4G_check}    run keyword if    '${gNb_CuType}'=='NSA'    set variable    True    ELSE    set variable    False
#    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1208_GP1_A1    prach_index=192    enable_2197=${False}
#    ...    dl_ul_layer=4DL4UL    4G_check=${4G_check}

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_100MHz
    [Tags]    CRT_TRUNK    CRT_22R4
    Commission SCF With Specific Band If Needed    band=${band}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    ${4G_check}    run keyword if    '${gNb_CuType}'=='NSA'    set variable    True    ELSE    set variable    False
    data_transfer_common    tput_self_define=${tput_define_100}    

[1]General_SiSo_RU_module_reset_from_GUI
   [Tags]    CRT_TRUNK    CRT_22R4
   Commission 1S1CC SCF If Needed
   General_SiSo_RF_module_reset_from_GUI

[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_TRUNK    CRT_22R4
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

#[1]General_SiSo_NR-ARFCN_check
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Commission 1S1CC SCF If Needed
#    General_SiSo_NR-ARFCN_check
#
#[1]General_SiSo_RF_alarms_with_recovery
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Commission 1S1CC SCF If Needed
#    General_SiSo_RF_alarms_with_recovery
#
#[1]General_SiSo_RF_alarms_without_recovery
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Commission 1S1CC SCF If Needed
#    General_SiSo_RF_alarms_without_recovery

[1]General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK    CRT_22R4
    Commission SCF With Specific Band If Needed    band=${band}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    ${4G_check}    run keyword if    '${gNb_CuType}'=='NSA'    set variable    True    ELSE    set variable    False
    General_SiSo_RU_lock_unlock_SG08    tput_self_define=${RU_lock_unlock}    target_avg_percent=0.5    min_percent=0.3
#    General_SiSo_RU_lock_unlock    4G_check=${4G_check}


#[1]General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Commission 1S1CC SCF If Needed
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#
#[1]General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Commission 1S1CC SCF If Needed
#    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

#[1]General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Commission 1S1CC SCF If Needed
#    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX


#[1]General_SiSo_RF_module_power_reset
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Commission 1S1CC SCF If Needed
#    General_SiSo_RF_module_power_reset


#[1]CB008247-A_Cell_on_air_after_actDlSrsBm_or_actCsirsMultiplexing_changed
#    [Tags]    CRT_TRUNK    CRT_22R4
#    COAM Commission with scf file    scf_file_path=${actDlSrsBm_scf}   timeout=15min
#    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air    connection=GNB_OAM
#    Cell_on_air_after_actDlSrsBm_or_actCsirsMultiplexing_changed

