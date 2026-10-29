*** Settings ***
Documentation    ...
#Test Teardown      Common Test Teardown
#Suite Teardown     Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    CN1_SG06_SM1    CB009169    owner_qiaren
#Resource          Resources/CB009169_Common.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                CB009169_BC1101_scfc.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Resources/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_2F_2T}               ${CURDIR}/Resources/wts/iphy_2F_2T.xml
#${SWCONFIG_PARAM_GNB}       0x58057F=16;0x580641=1;0x58057a=3;0x58062d=1;0x580692=1
#${WTS_CFG}                  CB009169_BC1101.cfg
#${UE_ID}                    2
#@{2CC_DL_TPUT_LIST}          440    180
#@{2CC_UL_TPUT_LIST}          50    75
#
#*** Test Cases ***
#CB009169_ET_BC1101_1TDD_1FDD_UL2CC_IWK1086_SRS_UL_Beamfroming_1116
#    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_2F_2T}    swconfig_param=${SWCONFIG_PARAM_GNB}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    Set SRS Testmode    profile_id=3    init_pos=0
#    CUDU L2 Send Action To GNB    ue_id=2   testmode=ue_srs_beam_pos    action=activate    profile_id=3
#    SA 5G CA Attach    ue_id=2    pdu_id=1
#    SA Start UL Traffic Internal    ue_id=2    pdu_id=1    mbps=150
#    Wait Until Keyword Succeeds    1min    5s   Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_ID}    ${2CC_UL_TPUT_LIST}    2
#    Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/1
#    CUDU_L2 Capture And Decode TTitrace    log_id=1    duration=3
#    Check Srsreceivereq With A2A    BIP/1    CB009169_BC/srsreceivereq_bc1101.ini
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    SA Start UL Traffic Internal    ue_id=2    pdu_id=1    mbps=150
#    SA Start DL Traffic Internal    ue_id=2    pdu_id=1    mbps=700
#    Wait Until Keyword Succeeds    1min    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${2CC_DL_TPUT_LIST}    2
#    Wait Until Keyword Succeeds    1min    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_ID}    ${2CC_UL_TPUT_LIST}    2
#    Capture Logs And Check TTitrace    log_idx=2
#    Check PatternID From Wirshark    /BIP/2    61    uldata_puschreceivereq    UlData_eCpriConfigStruct_t.patternId_item    1361,1280,0,0
#
#*** Keywords ***
