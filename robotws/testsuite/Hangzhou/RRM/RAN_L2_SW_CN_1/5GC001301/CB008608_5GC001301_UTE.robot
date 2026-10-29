*** Settings ***
Documentation    ...
#Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
#Library           taf.gnb.oam.coam.cu    WITH NAME    vcu
#Resource          ./../CUDU_L2_AIC/common_aic_setup_teardown.robot
#Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown    debug
#Force Tags        Classical    IPV4    FR1    Owner_xinwang    PRI-Medium    5GC001301    RAN_5G    RAN_5G_TDD
#...               CRT    CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    vDUCNF00
#
#*** Variables ***
#${GNB_INDEX}        0
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${ENB_ID}           1
#${GNB_ID}           2
#${UE_ID}            1
#${WTS_CFG}          basic_setup.cfg
#${SCF_dir}    ${CURDIR}/config
#
#*** Test Cases ***
#5GC001301_A020_Verify_PRACH_format_C2_with_30kHz_scs_80MHz_bandwith_5GC001116_0ms_frame_structure_index198
#    Update GNB    VDU_SCFC_PATH=${SCF_dir}/1301_A020.xml
#    Start WTS And Check OnAir
#    SA Set Traffic Type To Internal    ${UE_ID}
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    mbps=10
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    mbps=10
#    Sleep    20s
#    ${dl_tpt}    SA Get UE Average Traffic Internal    ${ue_id}    dl
#    ${ul_tpt}    SA Get UE Average Traffic Internal    ${ue_id}    ul
#    Should be true    ${dl_tpt}>8
#    Should be true    ${ul_tpt}>8
#
#5GC001301_A021_Verify_PRACH_format_C2_with_30kHz_scs_100MHz_bandwith_5GC001070_frame_structure_index189
#    Set Frame Structure 1070 100M Index 189
#    Update GNB    VDU_SCFC_PATH=${output_dir}/vdu_scf.xml
#    Start WTS And Check OnAir
#    SA Set Traffic Type To Internal    ${UE_ID}
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    mbps=10
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    mbps=10
#    Sleep    20s
#    ${dl_tpt}    SA Get UE Average Traffic Internal    ${ue_id}    dl
#    ${ul_tpt}    SA Get UE Average Traffic Internal    ${ue_id}    ul
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
#Update GNB
#    [Arguments]    ${VDU_SCFC_PATH}
#    VDU Full Commssion    ${VDU_SCFC_PATH}
#    #Wait Until Keyword Succeeds    10min    30s    VCU Verify F1 Setup
#    Process.Start Process    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.129 reboot    shell=True
#    VDU Reset
#    VCU Reset
#    Wait Until Keyword Succeeds    10min    30s    VCU Verify F1 Setup
#
#VDU Reset
#    VDU Login
#    vdu.reset_vdu
#    [teardown]    Run Keyword And Ignore Error    VDU Logout
#
#VCU Reset
#    [Arguments]   ${gnb_index}=0
#    VCU Login    ${gnb_index}
#    vcu.reset_cu
#    [Teardown]    Run Keyword And Ignore Error    VCU Logout
#
#Set Frame Structure 1070 100M Index 189
#    ${vdu_scf_file}    VDU Get current Plan File    ${output_dir}    vdu_scf.xml
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELLGRP-1    ssBurstSetPeriod    20
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    chBw    100MHz
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    frameStructureType    semiStatic
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    prachConfigurationIndex    189
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    guardPeriodLength    2Symbols
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    ulDlDataSlotRatio    3/7
#    Run Keyword And Ignore Error    Remove Single Value From Scf File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    lteToNrFrameShift
