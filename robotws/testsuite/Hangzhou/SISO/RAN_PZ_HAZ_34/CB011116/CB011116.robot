*** Settings ***
Suite Setup          Run keywords    SISO Coam Suite Setup    AND    create dir for spark log
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     Resources/CB011116_common_keyword.robot
Library    lib/CB011116.py
Variables    TestData/1116_variables.py

Documentation
...    Author: jiangjing.lin
...    Contact: jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB011116

Force Tags            RAN_5G_TDD    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CRT_UTE	   STATE_SW_UPLOADED
...   PY36
...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_5GC002374

*** Variables ***
@{cells_2CC}    ${301}    ${302}
@{cells_2CC_9527}    ${302}    ${304}
@{cells_3CC}    ${301}    ${302}    ${303}
@{cells_4CC}    ${301}    ${302}    ${303}    ${304}
@{ue_indexes}    ${0}    ${2}
@{cell_4}    ${304}

*** Test Cases ***
#[1]CB011116_SR_AA_Verify_L3call and beam fallback_With_1CC_8DL
#    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#    CB011116_SR_AA_Verify_L3call and beam fallback_With_1CC_8DL    cell_id=301    tput=${TPUT_1CC_8DL}

[1]CNI-116383_Verify_Beam_Fallback_With_Downlink_Scheduling
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    CB011116_SR_AA_Verify_L3call and beam fallback_With_1CC_8DL    cell_id=301    tput=${TPUT_1CC_8DL}

[1]CB011116_SR_AB_Verify_L3call and beam fallback_With_2CC_8DL
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    CB011116_3_Verify_Cell_Setup_And_L3call_With_2CC    config=2CC_8DL    cell_id=${cells_2CC}    tput=${TPUT_2CC_8DL}

[1]CB011116_SR_AA+B_Verify_L3call and beam fallback_With_2CC_16DL
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    CB011116_3_Verify_Cell_Setup_And_L3call_With_2CC    config=2CC_16DL    cell_id=${cells_2CC}    tput=${TPUT_2CC_16DL}

[1]CB011116_SR_C_Verify_L3call and beam fallback_With_2CC_16DL
    CB011116_3_Verify_Cell_Setup_And_L3call_With_2CC    config=2CC_16DL_C    cell_id=${cells_2CC}    tput=${TPUT_2CC_16DL_C}

#[1]CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_100M_16RX_RZF
#    load swconfig file and sign    flag_0x5901BD=${0}
#    scf commission with cell status and unexpected fault check    scf_ends_with=_100M_16RX_RZF.xml
#    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS    ue_indexes=${ue_indexes}    tput=${TPUT_RZF_SVD}

#[1]CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_100M_16RX_SVD
#    load swconfig file and sign    flag_0x5901BD=${1}
#    scf commission with cell status and unexpected fault check    scf_ends_with=_100M_16RX_SVD.xml
#    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS    ue_indexes=${ue_indexes}    tput=${TPUT_RZF_SVD}

[1]CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Multiple_Ues_2CC_8DL
#    load swconfig file and sign    flag_0x5901BD=${0}
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_2CC_8DL_1116_0.xml
    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_MULTI_CC    tput=${TPUT_RZF_SVD_2CC_1116}    cells_all=${cells_2CC_9527}

#[1]CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Multiple_Ues_2CC_8DL
#    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_2CC_8DL_1116_0.xml
#    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_2CC_2UE    tput=${TPUT_RZF_SVD_2CC_2UE_1116}    cells_all=${cells_2CC_9527}

[1]CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Multiple_Ues_3CC_4DL
#    load swconfig file and sign    flag_0x5901BD=${0}
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_3CC_16DL_1116_3.xml
    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_MULTI_CC     tput=${TPUT_RZF_SVD_3CC}    cells_all=${cells_3CC}

#[1]CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Multiple_Ues_2CC_16DL
##    load swconfig file and sign    flag_0x5901BD=${0}
#    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_2CC_16DL_1208.xml
#    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_MULTI_CC    tput=${TPUT_RZF_SVD_2CC_1208}    cells_all=${cells_2CC_9527}

#[1]CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Multiple_Ues_2CC_16DL
##    load swconfig file and sign    flag_0x5901BD=${0}
#    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_2CC_16DL_1208.xml
#    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_2CC_2UE    tput=${TPUT_RZF_SVD_2CC_2UE_1208}    cells_all=${cells_2CC_9527}

[1]CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Multiple_Ues_2CC_16DL
#    load swconfig file and sign    flag_0x5901BD=${0}
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_2CC_16DL_1208.xml
    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_1CC_1UE    tput=${TPUT_RZF_SVD_2CC_1UE_1208}    cells_all=${cells_2CC_9527}
    ...    target_avg_percent=0.98    min_percent=0.85

#[1]CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Multiple_Ues_4CC_4DL
##    load swconfig file and sign    flag_0x5901BD=${0}
#    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_4CC_4DL_1070.xml
#    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_MULTI_CC     tput=${TPUT_RZF_SVD_4CC}    cells_all=${cells_4CC}

[1]CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Multiple_Ues_4CC_4DL
#    load swconfig file and sign    flag_0x5901BD=${0}
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_4CC_4DL_1070.xml
    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_1CC_1UE     tput=${TPUT_RZF_SVD_4CC_1UE}    cells_all=${cells_4CC}

[1]CB009527_B_4_SB_BF_Counters_Verify
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_2CC_16DL_1208.xml
    Based_SB_BF_Counter_Verify        tput=${TPUT_RZF_SVD_2CC_1208}    cells_all=${cells_2CC_9527}
    ...    power_basic=${power_basic}    sinr_basic=${sinr_basic}

[1]CB009527_E_4_Interworking_With_Power_Saving_Mode_Mute
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_2CC_16DL_1208.xml
    Interworking_With_Power_Saving_Mode_Mute    tput=${TPUT_RZF_SVD_2CC_1208}    cells_all=${cells_2CC_9527}    cell_call=${302}

[1]CB009527_E_11_Capture_L1_Antenna_Snapshot_Triggered_By_L2-RT
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_2CC_16DL_1208.xml
    Capture_L1_Antenna_Snapshot_Triggered_By_L2-RT    tput=${TPUT_RZF_SVD_2CC_1208}    cells_all=${cells_2CC_9527}    cell_call=${302}

[1]CB009527_E_1_Interworking_With_DL_MU-MIMO_8DL
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_2CC_16DL_1208.xml
    Interworking_With_DL_MU-MIMO_8DL    tput=${TPUT_RZF_SVD_2CC_1208_MIMO}    cells_all=${cells_2CC_9527}

[1]CB009527_E_3_Interworking_With_EIRP_Control_Functionalities
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_4CC_4DL_1070.xml
    Interworking_With_EIRP_Control_Functionalities    tput=${TPUT_RZF_SVD_4CC}    cells_all=${cells_4CC}

[1]CB009527_E_4_Interworking_With_CA
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_3CC_16DL_1116_3.xml
    Interworking_With_CA    tput=${TPUT_RZF_SVD_3CC_CA}    cells_all=${cells_3CC}

[1]CB009527_O1_Interworking_With_11117_HO
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_3CC_16DL_1116_3.xml
    Interworking_With_11117_HO    tput=${TPUT_RZF_SVD_3CC}    cells_all=${cells_3CC}

[1]CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Single_Ue_4CC_16DL
#   load swconfig file and sign    flag_0x5901BD=${0}
    scf commission with cell status and unexpected fault check    scf_ends_with=_9527_4CC_16DL_1070.xml
    CB009527_SVD_RZF_Based_SB_BF_with_SB_SRS_1CC_1UE_Q     tput=${TPUT_RZF_SVD_4CC_1UE}    cells_all=${cell_4}