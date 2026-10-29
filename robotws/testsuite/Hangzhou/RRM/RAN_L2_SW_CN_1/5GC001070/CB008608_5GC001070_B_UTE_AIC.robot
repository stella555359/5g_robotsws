*** Settings ***
Documentation    ...
#Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
#Library           taf.gnb.oam.coam.cu    WITH NAME    vcu
#Resource          ./../CUDU_L2_AIC/common_aic_setup_teardown.robot
#Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown    debug
#Force Tags        Classical    IPV4    FR1    Owner_krihu    PRI-Medium    5GC001070    RAN_5G    RAN_5G_TDD
#...               CRT    CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    vDUCNF00
#
#*** Variables ***
#${GNB_INDEX}        0
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${ENB_ID}           1
#${GNB_ID}           2
#${UE_ID}            1
#${WTS_CFG}          basic_setup.cfg
#
#*** Test Cases ***
#5GC001070-B-4008-Single UE scheduling with DBF in FR1-n78-100MHz with GP2Symbols with B4 prach 160 and 4ssb
#    Set vDU Parameters For SlotType1070
#    Update GNB SCF    VDU_SCFC_PATH=${output_dir}/vdu_scf.xml
#    Start WTS And Check OnAir
#    SA Set Traffic Type To Internal    ${UE_ID}
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    mbps=50
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    mbps=50
#    Sleep    20s
#    ${dl_tpt}    SA Get UE Average Traffic Internal    ${ue_id}    dl
#    ${ul_tpt}    SA Get UE Average Traffic Internal    ${ue_id}    ul
#    Should be true    ${dl_tpt}>5
#    Should be true    ${ul_tpt}>5
#
#*** Keywords ***
#Set vDU Parameters For SlotType1070
#    ${vdu_scf_file}    VDU Get current Plan File    ${output_dir}    vdu_scf.xml
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    frameStructureType    semiStatic
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    prachCo
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    ulDlDataSlotRatio    3/7
#    Run Keyword And Ignore Error    Remove Single Value From Scf File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    lteToNrFrameShift
#    Run Keyword And Ignore Error    Remove Single Value From Scf File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    tdLteUlDlConfig
#
#Modify Single Value In SCF FilenfigurationIndex    160
#    Modify Single Value In SCF File    ${vdu_scf_file}    MRBTS-1/NRBTS-1/NRCELL-1    guardPeriodLength    2Symbols

#    [Arguments]    ${scf_path}     ${dist_name}    ${para_name}    ${para_new_value}
#    ${para_old_value}    Get Single Value From Scf File    ${scf_path}    ${dist_name}    ${para_name}
#    Run Keyword If    '${para_old_value}'!='${para_new_value}'    Set Single Value From Scf File    ${scf_path}    ${dist_name}    ${para_name}
#    ...    ${para_new_value}
#
#Update GNB SCF
#    [Arguments]    ${VDU_SCFC_PATH}
#    VDU Full Commssion    ${VDU_SCFC_PATH}
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
