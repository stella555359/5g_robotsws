*** Settings ***
Documentation    ...
#Resource          ./../CUDU_L2_AIC/common_aic_setup_teardown.robot
#Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown    debug
#Force Tags        Classical    IPV4    FR1    Owner_lilidong    PRI-Medium    5GC001301    RAN_5G    RAN_5G_TDD
#...               CRT    CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    master_vDU
#
#*** Variables ***
#${GNB_INDEX}        0
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${ENB_ID}           1
#${GNB_ID}           2
#${SA_UE_ID}         1
#${NSA_UE_ID}        11
#${WTS_CFG}          basic_setup.cfg
#
#*** Test Cases ***
#5GC001301_A025_Verify_PRACH_format_C2_with_30kHz_scs_80MHz_bandwith_5GC001070_frame_structure_index202
#    Set Frame Structure 1070 80M Index 202
#    Update Aic GNB    VDU_SCFC_PATH=${output_dir}/vdu_scf.xml
#    Start WTS And Check OnAir
#    #Setup X2 Connection
#    NSA LTE Attach    ${NSA_UE_ID}
#    NSA 5G Attach    ${NSA_UE_ID}    ${GNB_ID}    cell_id=1    bearer_id=2
#    NSA Start DL Traffic    ${NSA_UE_ID}    bearer_id=2    mbps=10
#    NSA Start UL Traffic    ${NSA_UE_ID}    bearer_id=2    mbps=10
#    Sleep    20s
#    ${dl_tpt}    NSA Get Average Throughput    ${NSA_UE_ID}    bearer_id=2    dir=dl
#    ${ul_tpt}    NSA Get Average Throughput    ${NSA_UE_ID}    bearer_id=2    dir=ul
#    Should be true    ${dl_tpt}>8
#    Should be true    ${ul_tpt}>8
#
#*** Keywords ***
#Modify Single Value In SCF File
#    [Arguments]    ${scf_path}     ${dist_name}    ${para_name}    ${para_new_value}
#    ${para_old_value}    Get Single Value From Scf File    ${scf_path}    ${dist_name}    ${para_name}
#    Run Keyword If    '${para_old_value}'!='${para_new_value}'
#    ...    Set Single Value From Scf File    ${scf_path}    ${dist_name}    ${para_name}    ${para_new_value}
#
#Set Frame Structure 1070 80M Index 202
#    ${vdu_scf_file}    VDU Get current Plan File    ${output_dir}    vdu_scf.xml
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELLGRP-1    ssBurstSetPeriod    20
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    chBw    80MHz
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    frameStructureType    semiStatic
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    prachConfigurationIndex    202
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    guardPeriodLength    2Symbols
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    ulDlDataSlotRatio    3/7
#    Run Keyword And Ignore Error    Remove Single Value From Scf File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    lteToNrFrameShift
#    Run Keyword And Ignore Error    Remove Single Value From Scf File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    tdLteUlDlConfig
