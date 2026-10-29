*** Settings ***
Documentation    ...
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CB009169    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_suxu    CN1_SQ6    SBTS00
#Resource          Resources/CB009169_Common.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_BC902}               CB009169_BC902_scfc.xml
#${SCFC_BC1202}              CB009169_BC1202_scfc.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Resources/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_2F_2T}               ${CURDIR}/Resources/wts/iphy_2F_2T.xml
#${SWCONFIG_PARAM_GNB}       0x590105=1;0x580477=2;0x580264=0x1F;0x5900a8=1;0x580692=1
#${WTS_CFG}                  CB009169_BC1202.cfg
#${UE1_ID}                    1
#${UE2_ID}                    2
#@{2CC_DL_TPUT_LIST}          410    150
#@{2CC_UL_TPUT_LIST}          50    70
#@{2UE_DL_TPUT_LIST}          210    80
#@{2UE_UL_TPUT_LIST}          23    35
#${UL_PATTERN_ID}             1833,1752,0,0,1833,1752,0,0
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009169_ET_BC902_1TDD_1FDD_UL2CC_Blind_ScellAdd_BufferBaseScellAct_With_ParallelTransmissionOf_SrsAndOtherUplinkChannels
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_BC902}    iphy_file=${IPHY_2F_2T}
#    ...    swconfig_param=${SWCONFIG_PARAM_GNB}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    Set SRS Testmode    profile_id=3    init_pos=1
#    CUDU L2 Send Action To GNB    ue_id=${UE2_ID}   testmode=ue_srs_beam_pos    action=activate    profile_id=3
#    SA 5G CA Attach    ue_id=${UE2_ID}    pdu_id=1
#    SA Start UL Traffic Internal    ue_id=${UE2_ID}   pdu_id=1    mbps=150
#    Wait Until Keyword Succeeds    1min    6s   Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE2_ID}    ${2CC_UL_TPUT_LIST}    2
#    Capture Logs And Check TTitrace    log_idx=1
#    Check Srsreceivereq With A2A    BIP/1    CB009169_BC/srsreceivereq_bc902.ini
#    SA Start DL Traffic Internal    ue_id=${UE2_ID}    pdu_id=1    mbps=1000
#    Sleep    20s    reason=wait for data is stable
#    Wait Until Keyword Succeeds    1min    6s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE2_ID}    ${2CC_DL_TPUT_LIST}    2
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE2_ID}    ${2CC_UL_TPUT_LIST}    2
#    Capture Logs And Check TTitrace    log_idx=2
#    Check Srsreceivereq With A2A    BIP/2    CB009169_BC/srsreceivereq_bc902.ini
#    Check PatternID From Wirshark    /BIP/2    61    uldata_puschreceivereq    UlData_eCpriConfigStruct_t.patternId_item    1833,1752,0,0
#    #Check PatternID From Wirshark    /BIP/2    61    dldata_pdschsendreq    DlData_PdschGrant.patternId_item    1833,0
#    Check overlap Symbols From Wirshark    /BIP/2    52    12
#
#
#CB009169_ET_BC1202_1TDD_1FDD_UL2CC_IWK8247_SRS_DL_Beamfroming_UE_Specific_CSIRS_CsirsMultiplexing
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_BC1202}    iphy_file=${IPHY_2F_2T}
#    ...    swconfig_param=${SWCONFIG_PARAM_GNB}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    Attach And Start Ul Data Transfer For 2UEs
#    Wait Until Keyword Succeeds    1min    6s   Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE1_ID}    ${2UE_UL_TPUT_LIST}    2
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE2_ID}    ${2UE_UL_TPUT_LIST}    2
#    Capture Logs And Check TTitrace    log_idx=1
#    Check Srsreceivereq With A2A    BIP/1    CB009169_BC/srsreceivereq_bc1202.ini
#    Check PatternID From Wirshark    /BIP/1    61    uldata_puschreceivereq    UlData_eCpriConfigStruct_t.patternId_item    ${UL_PATTERN_ID}
#    SA Start DL Traffic Internal    ue_id=${UE1_ID}    pdu_id=1    mbps=700
#    SA Start DL Traffic Internal    ue_id=${UE2_ID}    pdu_id=1    mbps=700
#    Check 2UEs DLUL Tput
#    Capture Logs And Check TTitrace    log_idx=2
#    Check Srsreceivereq With A2A    BIP/2    CB009169_BC/srsreceivereq_bc1202.ini
#    Check PatternID From Wirshark    /BIP/2    61    uldata_puschreceivereq    UlData_eCpriConfigStruct_t.patternId_item    ${UL_PATTERN_ID}
#    #Check PatternID From Wirshark    /BIP/2    61    dldata_pdschsendreq    DlData_PdschGrant.patternId_item    1833,1833
#
#*** Keywords ***
#Attach And Start Ul Data Transfer For 2UEs
#    Set SRS Testmode    profile_id=3    init_pos=1
#    CUDU L2 Send Action To GNB    ue_id=${UE1_ID}   testmode=ue_srs_beam_pos    action=activate    profile_id=3
#    CUDU L2 Send Action To GNB    ue_id=${UE2_ID}   testmode=ue_srs_beam_pos    action=activate    profile_id=3
#    SA 5G CA Attach    ue_id=${UE1_ID}
#    SA 5G CA Attach    ue_id=${UE2_ID}
#    SA Start UL Traffic Internal    ue_id=${UE1_ID}   pdu_id=1    mbps=100
#    SA Start UL Traffic Internal    ue_id=${UE2_ID}   pdu_id=1    mbps=100
#
#Check 2UEs DLUL Tput
#    Wait Until Keyword Succeeds    1min    6s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE1_ID}    ${2UE_DL_TPUT_LIST}    2
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE2_ID}    ${2UE_DL_TPUT_LIST}    2
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE1_ID}    ${2UE_UL_TPUT_LIST}    2
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE2_ID}    ${2UE_UL_TPUT_LIST}    2
