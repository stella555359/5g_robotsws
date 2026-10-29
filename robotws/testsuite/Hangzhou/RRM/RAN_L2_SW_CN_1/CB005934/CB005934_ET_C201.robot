*** Settings ***
Documentation    ...
#Suite Setup       Suit Setup For 8140
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Force Tags    CLOUD_5G_I_[LO][LO]_AP_[LOO]    owner_qiaren    CRT    SBTS00
#
#*** Variables ***
#${LOCAL_WTS_DIR}     ${CURDIR}/Config/LOLO/
#${SCF_PATH}          ${CURDIR}/Config/LOLO/
#${SCF_IWK_8140_GNB1}    ${SCF_PATH}/5934_C_8140_gnb1.xml
#${SCF_IWK_8140_GNB2}    ${SCF_PATH}/5934_C_8140_gnb2.xml
#${IPHY_8140}        ${SCF_PATH}/iphy_5934_C_8140.xml
#${WTS_CFG}           5934_C_8140.cfg
#@{LOG_NAME_LIST}     btslog    egatelog
#${force_reboot}      ${True}
#${UE_ID}                 1
#@{4CC_DL_TPUT_LIST}      100    100    100    100
#
#*** Test Cases ***
#
#CB005934_ET_C_IWK201_InterGNB_FDD_DL_4CC_Bufferbased_Scell_Active_IniNumSCellsToActivate_2
#    [Documentation]
#    ...    CB008140 para:
#    ...                 actInterNumerologyCa = true
#    ...                 actInterGnbCa = true
#    ...                 actK1OptForDPA =true
#    ...                 add mo: MNL/MNLENT/XPAP,MNL/MNLENT/XPAP/XPIF,MNL/MNLENT/XPAP/XPIF/XPIFREMOTE
#    ...   Test Steps:
#    ...                 Step1: UE attach
#    ...                 Step2: Start engough DL traffic to make scell activated.
#    [Setup]    Run Keywords    Create Test Directory
#    ...    AND    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log    log=${False}    gnb_num=2
#	...    AND    Sleep    60s    Wait for interGNB communication interface established stable
#    SA 5G CA Attach    ue_id=${UE_ID}    pdu_id=1
#    Trigger A1 Scell Addition    ue_id=${UE_ID}    phycell_id=50    srsrp_nr=120    meas_id=3
#	SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=900
#    Verify Scells Are Activation    cell_nums=4
#	Wait Until Keyword Succeeds    1min    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${4CC_DL_TPUT_LIST}    4
#	SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=150
#	Wait Until Keyword Succeeds    1min    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${4CC_DL_TPUT_LIST}    4
#	Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}     ul    pcell    0    100
#    [Teardown]    Common Test Teardown 2
#
#*** Keywords ***
#Suit Setup For 8140
#    Import Testline Variables For 2 GNBs
#    Create Suite Directory
#    Backup And Update Iphy Swconfig File    ${IPHY_8140}
#    log to console    Send scf to gnb2...
#    Full Commission SCF File Through Mplane With Admin    ${SCF_IWK_8140_GNB2}    1    10.0.1.3
#    log to console    Send scf to gnb1...
#    Full Commission SCF File Through Mplane With Admin    ${SCF_IWK_8140_GNB1}    1    10.0.1.2
#    Reboot TL And Check Configured For 2 GNBs
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG}
