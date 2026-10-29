*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource     ../AZQR_SG08/Resources/CB006487_keyword.robot
Resource     Resources/CB007262_common_keywords.robot
Variables    Resources/variables_7262.py

Documentation
...    Author:shufei chen
...    contact:shufei.chen@nokia-sbell.com
...    squad group:SG_08
...    Feature CB007262 in 5G00 program

Force Tags            RAN_5G    RAN_5G_TDD    5G_RAN_TDD    5G_RAN    SBTS00    CRT_22R3    STATE_SW_UPLOADED
...    PY36
...    CLOUD_5G_CLASSICAL_ANDROID_SA_ASILL_ABIOB1B2_AEHC_AHLOA    CRT_22R4    CRT_23R1

*** Variables ***
${MAX_LOOP}    20
@{band_3CC}    20M  20M  100M
@{band_2CC}    20M  100M
@{band_3CC_1}    50M  40M  20M
@{cell_id_call}    ${1}    ${2}
*** Test Cases ***
[1]CB007262-5G-A-B4_003_General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_UTE
    Commission SCF With Specific Band If Needed    band=${band_3CC}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SiSo_RF_module_reset_from_GUI

[1]CB007262-5G-A-B4_006_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_UTE
    Commission SCF With Specific Band If Needed    band=${band_3CC}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]CB007262-5G-B-A1_003_General_SiSo_Cell_lock_and_unlock
    [Tags]    CDRT_22R1    CRT_TRUNK    CRT_22R2    CRT_UTE
    Commission SCF With Specific Band If Needed    band=${band_2CC}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SiSo_Cell_lock_and_unlock

[1]CB007262-5G-A-B4_005_General_SiSo_RU_lock_unlock
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_UTE
    Commission SCF With Specific Band If Needed    band=${band_2CC}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SiSo_RU_lock_unlock

[1]CB007262-5G-B-A1_001_General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    CRT_22R1    CIT_TRUNK    CDRT_22R2
    Commission SCF With Specific Band If Needed    band=${band_3CC}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SiSo_Commissioning_BTS_Template_Commissioning
    data_transfer_common    tput_self_define=${tput}    cell_id=${cell_id_call}    tput_from=self_define    process_num_ul=5

[1]CB007262-5G-B-A1_005_General_SiSo_BB_sub-unit_reset_with_L3_call
    [Tags]    CDRT_22R1    CRT_TRUNK    CRT_22R2    CRT_UTE
    Commission SCF With Specific Band If Needed    band=${band_3CC_1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    General_SiSo_BB_sub-unit_reset_with_L3_call    tput_info=${tput_1635_peak}

[1]CB007262-5G-B-A1_004_General_SiSo_BB_sub-unit_lock_and_unlock_with_L3_call
    [Tags]    CDRT_22R1    CRT_TRUNK    CRT_22R2    CRT_UTE
    Commission SCF With Specific Band If Needed    band=${band_3CC_1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    CB007262-5G-B-A1_004_General_SiSo_BB_sub-unit_lock_and_unlock_with_L3_call

[1]CB007262-5G-B-A1_009_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_UTE
    Commission SCF With Specific Band If Needed    band=${band_3CC}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
