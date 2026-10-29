*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout      90 minutes

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
Resource     ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource     ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001178-A/Resource/5GC001178-AE-5GC001639-RA_common_KW.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000430_B_Master/Resource/5GC000430_B_Master_KW.robot
Resource     Resource/T061_KW.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001473-KF/TestData/variables.py
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000643/CB006154_AEQE/TestData/variables.py
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001465-A/TestData/variables.py
Library      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006293_AEQE/library/6293.py

Documentation
...    author: hu annie
...    contact: annie.hu@nokia-sbell.com
...    squad group: SG_05
...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE in TRUNK program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***
${miNrEcpriUpFCp}    5min
${ue_index}          0
${ru_type_init}      AEQE
${url}               https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${if_pdl_check}       False

*** Test Cases ***
### part-1: 5GC001178-A - 3 TCs ###
## move to Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG5/UTE_CLOUD/T061_OAM/T061_OAM_SA_ASIKL_ABILB1_AEQE.robot

### part-2: 5GC000430-B - 2 TCs ###
#[1][1.0] 5GC000430-B_01_04_Micro-DTX_deactivate_on_Master_cMAAr6.1_64T64R_Made_RRU
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]   SISO Coam Test Setup
#    General_Feature_Micro-DTX_deactivate_microDtxEnabled_false
#    [Teardown]   SISO Coam Test Teardown

#[1][1.0] 5GC000430-B_01_03_Micro-DTX_activate_on_Master_cMAAr6.1_64T64R_Made_RRU
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]   SISO Coam Test Setup
#    General_Feature_Micro-DTX_activate_microDtxEnabled_true
#    [Teardown]   SISO Coam Test Teardown

### part-3: 5GC000643-B - 1 TCs ###
#[1][1.0] 5GC000643-BG_01_5GRAU_RU_sync_error_and_recover
#    [Tags]   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE
##    [Setup]    run keywords    SISO Common Test Setup    coam_resource.Check Cell is UP
#    [Setup]    SISO Coam Test Setup
#    [Timeout]    120min
##    [Teardown]    Run Keywords    Recvoer parameter   case teardown   COAM Teardown gnb connections
#    [Teardown]    Run Keywords    Recvoer parameter   COAM Teardown gnb connections
#    Step1: Trigger RU sync error
#    Step2: Check cell disabled
#    Step3: Check fault raised on WebEM
#    Step4: Trigger RU recover sync
#    Step5: Check fault disapper on WebEM
#    Step6: Check cell onair

### part-4: 5GC001473-KF - 1 TCs ###
#[1][1.0] 5GC001473-KF_01_gnb can be on air with cBW 90Mhz_eCPRI
#    [Tags]   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_gnb_can_be_on_air_with_Given_Information    band=90    frame_structure=1116_0ms_GP1_A8

### part-5: 5GC002519_MA - 1 TCs ###
#[1][1.0] 5GC002519_MA_01_eCPRI_U-plane_and_Fast-C-Plane_message_reception_NIDD_PM_counters_M55318C00001_by_RAU
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]  SISO Coam Test Setup
#    #[Arguments]  ${miNrEcpriUpFCp}=5min
#    Modify miNrEcpriUpFCp Parameters via API   miNrEcpriUpFCp=${miNrEcpriUpFCp}
#    sleep  ${miNrEcpriUpFCp}
#    selenium login and disable screen lock
#    Wait Until Keyword Succeeds    3x    2min    Check M55318C00001 Counter    change_interval=${miNrEcpriUpFCp}
#    [Teardown]  run keywords  selenium logout and close browser    AND
#    ...    Modify miNrEcpriUpFCp Parameters via API  miNrEcpriUpFCp=disabled

### part-6: CB006154 - 1 TCs ###
#[1]CB007085_CB006154_01_AEQE_General_SiSo_Cell_lock_and_unlock
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]   SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_gnb_can_be_on_air_with_Given_Information    band=70   frame_structure=1116_0ms_GP1_A8    beamset=2 beams
#    General_SiSo_Cell_lock_and_unlock    with_call=${False}    with_peak=${False}

### part-7: CB006293 - 3 TCs ###
[1]CB006293_5G_AEQE_03_Initiate_RF_diagnostic_test_RSSI_test_withL3call
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
    [Setup]   SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call_AEQE

#[1]CB006293_5G_AEQE_09_Initiate_RF_Statistics_diagnostic_test_withL3call
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]   SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call_AEQE
#    ...   min_temperature=40   max_temperature=100   rf_port_id=0

[1][1.0]General_SiSo_Auto_RF_Module_Stability_Run
    [Tags]   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
    [Timeout]   180min
    [Setup]   SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    General_SiSo_Auto_RF_Module_Stability_Run

### part-8_1 : 5GC000643-C 1CC - 1 TC ###
### 2023-02-07: [1]5GC000643-CE_01 optimized from Trunk so case Tag 'CRT_UTE' removed
#[1]5GC000643-CE_01_gnb_can_be_on_air_with_cBW_60Mhz_eCPRI
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE
#    [Setup]    SISO Coam Test Setup
#    General_gnb_can_be_on_air_with_Given_Information    band=60   frame_structure=1070_GP1_B3
#    [Teardown]    run keywords    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'    AND
#    ...    SISO Coam Test Teardown

#[1]5GC000643-CD_01_gnb_can_be_on_air_with_cBW_80Mhz_eCPRI
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    General_gnb_can_be_on_air_with_Given_Information    band=80   frame_structure=1208_GP1_A1
#    [Teardown]    run keywords    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'    AND
#    ...    SISO Coam Test Teardown

### part-9: 5GC000643-CH - 2 TCs ###
#[1][1.0] 5GC000643-CH_07_Call_setup_with_A7_1116_0ms_frame_structure_prach 97_and_peak_Tput
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1116_0ms_GP2_A7    cell_id=1
#    ...    loop_times=3    duration=300    dl_ul_layer=4DL2UL    beamset=2 beams    prach_index=97

#[1]5GC000643-CH_10_A1_1208_frame_structure_and_prach_index_98
#    [Tags]    master_classicalbts_all    CRT_UTE   CRT_TRUNK   CRT_22R1   CRT_22R2   CRT_22R3   CRT_22R4
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_Peak_with_Given_Information    band=50    frame_structure=1208_GP1_A1    cell_id=1
#    ...    loop_times=3    duration=300    dl_ul_layer=4DL2UL    beamset=2 beams    prach_index=98

### part-10: 5GC001465-A - 1 TCs ###
#[1][1.0] 5GC001465_A_03_cell_on_air_with_frame_structure_1116_0ms_and_BW_30MHz_and_cutype_both
#    [Tags]    1S-1CC-4D2U_30M_both    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_gnb_can_be_on_air_with_Given_Information    band=30    frame_structure=1116_0ms_GP1_A8    enable_2197=False

### part-8_2 : 5GC000643-C 2CC - 2 TCs ###
#[1]5GC000643-CG_01_gnb_can_be_on_air_with_Dual_carrier_40+40Mhz_eCPRI
#    [Tags]    1S-2CC-4D2U_40-40M    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    General_gnb_can_be_on_air_with_Given_Information    band=40   frame_structure=1208_GP1_A1
#    [Teardown]   SISO Coam Test Teardown

#[1]5GC000643-DJ_01_gnb_can_be_on_air_with_Dual_carrier_50+50Mhz_eCPRI
#    [Tags]    1S-2CC-4D2U_40-40M    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    General_gnb_can_be_on_air_with_Given_Information    band=50   frame_structure=1070_GP1_A3
#    [Teardown]   SISO Coam Test Teardown

*** Keywords ***
