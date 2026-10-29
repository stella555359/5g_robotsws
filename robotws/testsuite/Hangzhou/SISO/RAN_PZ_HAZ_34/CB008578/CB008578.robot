*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_without_recovery.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource     Resources/CB008578_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007841_AQQK/Resources/CB007841_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Variables    Resources/variables_CB008578.py


Documentation
...    Author:shufei chen
...    contact:shufei.chen@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008578_AQQS in 5G00 program

Force Tags            RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36
...    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_AQQS_ENB

*** Variables ***
${actDlSrsBm_scf}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/scf_actDlSrsBm.xml
${actUlSrsBm_scf}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/scf_actUlSrsBm.xml
${SCF_SBTS00_100M_1116}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_100M_1116.xml
@{link_list}    'connected'
${MAX_LOOP}    20
@{band}    100M
@{band_1}    50M    50M
@{band_2}    60M    90M
@{band_3}    20M    20M
@{band_4}    100M    100M
@{band_5}    60M
@{nr_cell_2CC}    ${1}    ${2}
@{nr_cell_1CC}    ${1}
*** Test Cases ***

[1]General_SiSo_Cell_lock_and_unlock_2CC
    [Tags]    CRT_TRUNK    CRT_22R3    CDRT_22R3
    Commission SCF With Specific Band If Needed    band=${band_1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SISO_Cell_Lock_Unlock_SG08    tput_self_define=${Cell_lock_unlock}    target_avg_percent=0.5
    ...    min_percent=0.3    duration=${600}


[1]General_SiSo_Cell_lock_and_unlock_2CC_NO_TRUNK
    [Tags]    CRT_22R4    CRT_22R3    CRT_TRUNK
    Commission SCF With Specific Band If Needed    band=${band_1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SiSo_Cell_lock_and_unlock_SG08    tput_self_define=${Cell_lock_unlock}    target_avg_percent=0.5    min_percent=0.3


[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_TRUNK    CRT_22R3
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

#[1]General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    CRT_TRUNK    CRT_22R3
#    Commission 1S1CC SCF If Needed
#    General_SiSo_Commissioning_BTS_Template_Commissioning

[1]CB007841-5G-E_AQQK_01_The BTS shall support NIDD parameter (EQM APEQM-SFPOperatorMode) to enable and disable SFP+ or SFP28 compliance validation
    [Tags]    CRT_TRUNK    CRT_22R3
    Commission 1S1CC SCF If Needed
    CB007841-5G-E_AQQK_01_The BTS shall support NIDD parameter (EQM APEQM-SFPOperatorMode)    sfp_num=5

[1]CB007841-5G-E_AQQK_05_ the SFP information for fronthaul and backhaul interface
    [Tags]    CRT_TRUNK    CRT_22R3
    ${SCF_CB009260}    Replace String    ${Golden_SCF_Path}    SCF    SCF_CB009260
    COAM Commission with scf file    scf_file_path=${SCF_CB009260}   timeout=15min
    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air    connection=GNB_OAM
    Check sfp information   link_list=${link_list}

[1]CB009260-SR_3_BTS_startup_SFP_power_level_3-4_compatibility_validation
    [Tags]    CRT_TRUNK    CRT_23R2
    BTS startup SFP power level compatibility validation    RF_port=RF4    power=PL3

#[1]General_SiSo_RU_module_reset_from_GUI
#   [Tags]    CRT_TRUNK    CRT_22R3
#   Commission 1S1CC SCF If Needed
#   General_SiSo_RF_module_reset_from_GUI
#
#[1]General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#    [Tags]    CRT_TRUNK    CRT_22R3
#    Commission 1S1CC SCF If Needed
#    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

[1]General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    [Tags]    CRT_TRUNK    CRT_22R3
    Commission 1S1CC SCF If Needed
    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX

#[1]General_SiSo_NR-ARFCN_check
#    [Tags]    CRT_TRUNK    CRT_22R3
#    Commission 1S1CC SCF If Needed
#    General_SiSo_NR-ARFCN_check

#[1]General_SiSo_RF_module_power_reset
#    [Tags]    CRT_TRUNK    CRT_22R3
#    Commission 1S1CC SCF If Needed
#    General_SiSo_RF_module_power_reset

[1]General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK    CRT_22R3
    Commission SCF With Specific Band If Needed    band=${band}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SISO_RU_Lock_Unlock_loop_SG08    tput_self_define=${RU_lock_unlock}    target_avg_percent=0.5    min_percent=0.3
    ...    duration=${600}   

[1]General_SiSo_RU_lock_unlock_No_Trunk
    [Tags]    CRT_TRUNK    CRT_22R3
    Commission SCF With Specific Band If Needed    band=${band}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SiSo_RU_lock_unlock_SG08    tput_self_define=${RU_lock_unlock}    target_avg_percent=0.5    min_percent=0.3


[1]General_SiSo_RF_alarms_with_recovery
    [Tags]    CRT_TRUNK    CRT_22R3
    Commission 1S1CC SCF If Needed
    General_SiSo_RF_alarms_with_recovery

#[1]General_SiSo_RF_alarms_without_recovery
#    [Tags]    CRT_TRUNK    CRT_22R3
#    Commission 1S1CC SCF If Needed
#    General_SiSo_RF_alarms_without_recovery
#
#[1]Cell_on_air_after_actDlSrsBm_or_actCsirsMultiplexing_changed
#    [Tags]    CRT_TRUNK    CRT_22R3
#    COAM Commission with scf file    scf_file_path=${actDlSrsBm_scf}   timeout=15min
#    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air    connection=GNB_OAM
#    Cell_on_air_after_actDlSrsBm_or_actCsirsMultiplexing_changed

#[1]Cell_Setup_with_NDM_SRS_configuration_SRS_resource
#    [Tags]    CRT_TRUNK    CRT_22R3
#    COAM Commission with scf file    scf_file_path=${actUlSrsBm_scf}   timeout=15min
#    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air    connection=GNB_OAM
#    Cell_Setup_with_NDM_SRS_configuration_SRS_resource
#
#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_60MHz
#    [Tags]    CRT_TRUNK    CRT_22R3
#    Commission SCF With Specific Band If Needed    band=${band_5}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
#    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_3ms_GP2_A6    prach_index=98
#    ...    dl_ul_layer=8DL4UL

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_100MHz
#    [Tags]    CRT_TRUNK    CRT_22R3
#    COAM Commission with scf file    scf_file_path=${SCF_SBTS00_100M_1116}   timeout=15min
#    Wait until keyword succeeds    15 min    20 sec    COAM Check GNB cell on air    connection=GNB_OAM
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_3ms_GP2_A6    prach_index=98
#    ...    dl_ul_layer=8DL4UL

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_60Mhz_90Mhz
    [Tags]    CRT_TRUNK    CRT_22R3
    Commission SCF With Specific Band If Needed    band=${band_2}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    ${4G_check}    run keyword if    '${gNb_CuType}'=='NSA'    set variable    True    ELSE    set variable    False
    data_transfer_common    tput_self_define=${tput_define_60_90}    cell_id=${nr_cell_2CC}

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_20MHz_20MHz
#    [Tags]    CRT_TRUNK    CRT_22R3
#    Commission SCF With Specific Band If Needed    band=${band_3}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
#    ${bandlist}    create list    ${20}    ${20}
#    General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith    bandlist=${bandlist}
#    ...    ue_num_each_call=2    enable_2197=${False}    prach_index=192    dl_ul_layer=8DL4UL

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_100MHz_100MHz
#    [Tags]    CRT_TRUNK    CRT_22R3
#    Commission SCF With Specific Band If Needed    band=${band_4}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
#    ${bandlist}    create list    ${100}    ${100}
#    General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith    bandlist=${bandlist}
#    ...    ue_num_each_call=2    enable_2197=${False}    prach_index=98    dl_ul_layer=8DL4UL

#[1]General_SiSo_BTS_startup_with_delayed_RF_link_setup
#    [Tags]    CRT_TRUNK    CRT_22R3
#    Commission 1S1CC SCF If Needed
#    General_SiSo_BTS_startup_with_RF_delayed_startup
#    ${cell_list}    Get All Cell Id
#    start traffic all cells nsa    cell_list=${cell_list}
