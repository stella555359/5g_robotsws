*** Settings ***
Documentation   This is a keyword file for 5GC000710-A, part parameter settings
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

prepare counters and expected values t1
    [Documentation]    [PRIVATE]    set expected counter values for default mobility profile test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00032}    NRMOP_NSA_PROFILE_SELECTED_32	     1    ${cell_distName}   NRMOP
    set test variable    ${actSPID}       true


prepare counters and expected values t2
    [Documentation]    [PRIVATE]    set expected counter values for A2 with mobility test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00002}    NRMOP_NSA_PROFILE_SELECTED_02	     1    ${cell_distName}   NRMOP
    set test variable    @{M55157C00003}    NRMOP_NSA_PROFILE_SELECTED_03      1    ${cell_distName}   NRMOP
    set test variable    ${actSPID}       true


prepare counters and expected values t3
    [Documentation]    [PRIVATE]    set expected counter values for A1 with mobility test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00002}    NRMOP_NSA_PROFILE_SELECTED_02	     1    ${cell_distName}   NRMOP
    set test variable    ${actSPID}       true


prepare counters and expected values t4
    [Documentation]    [PRIVATE]    set expected counter values for no SPID test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00004}    NRMOP_NSA_PROFILE_SELECTED_04	     1    ${cell_distName}   NRMOP
    set test variable    ${actSPID}       false


prepare counters and expected values t5
    [Documentation]    [PRIVATE]    set expected counter values for interGnb_interFreq_PSCell_change test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55157C00002}    NRMOP_NSA_PROFILE_SELECTED_02	     1    ${cell_distName}   NRMOP
    set test variable    ${actSPID}       true


prepare counters and expected values t6
    [Documentation]    [PRIVATE]    set expected counter values for SgNB_modification test
    ...       :Autor: Sylvia Schneider
    set test variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ          4    ${cell_distName}   RACCU
    set test variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC         4    ${cell_distName}   RACCU
    set test variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ           4    ${cell_distName}   RACCU
    set test variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC          4    ${cell_distName}   RACCU
    set test variable    @{M55114C00006}    SGNB_NSA_RAC_REJ_DUE_TO_NSA     0    ${cell_distName}   RACCU
    set test variable    @{M55114C00007}    SGNB_NSA_RAC_REJ_DUE_TO_NGBR    0    ${cell_distName}   RACCU
    set test variable    @{M55114C00020}    SGNB_CU_NSA_ADMISSION_UNSUCC    0    ${cell_distName}   RACCU
    set test variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ       4    ${cell_distName}   RACDU
    set test variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC      4    ${cell_distName}   RACDU
    set test variable    @{M55112C04001}    X2_SGNB_MOD_REQ_RECEIVD         2    ${cell_distName}   NX2CC
    set test variable    @{M55112C04002}    X2_SGNB_MOD_REQ_ACK_SNT         2    ${cell_distName}   NX2CC
    set test variable    ${actSPID}       true
