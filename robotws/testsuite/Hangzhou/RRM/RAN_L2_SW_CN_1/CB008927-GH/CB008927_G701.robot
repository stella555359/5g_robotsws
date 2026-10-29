*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_CB008927_G701}    iphy_file=${IPHY}    swconfig_param=${SWCONFIG_PARAM}
#...                        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#...                        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    ST_SG11    CB008927
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          ./Resources/CB008927_G_H_Resource.robot
#
#
#*** Variables ***
#### Suite level ###
#${SWCONFIG_PARAM}        0x58090b=1;0x5806df=12
#${SCF_PATH}                     ${CURDIR}/Config
#${WTS_CFG}                      CB008927_G.cfg
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${IPHY}                         ${CURDIR}/Resources/wts/iphy_CB008927_G_H.xml
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${UEC_REACTION_TIME}            100
#### G701 ###
#${FULL_CB008927_G701}       Full_SCF_CB008927_G701.xml
#${START_NON_GBR_UE}             31
#${STOP_NON_GBR_UE}              40
#${START_GBR_UE}                 41
#${STOP_GBR_UE}                  45
#${START_VONR_UE}                51
#${STOP_VONR_UE}                 55
#${DL_DATA}                      10
#${UL_DATA}                      1
#${FILTER}                      uldata_puschreceivereq
#@{COLUMN}                      UlData_puschReceiveReqGrant_t.ulDmrsMappingType
#${TARGET_TP_DL}                 10
#${TARGET_TP_UL}                 1
#${TPUT_RATE}                    0.25
#${A2A_G701_NAME}              CB008927_G701.ini
#${A2A_PATH_G701}              G701
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB008927-ET-G701_Verify_GBR_VONR_NonGBR_MultiUE_DL_Scheduling_With_DL_RAT1
#    [Tags]    Owner_zbu    CRT
#    SA NoncaUE Attach AND PDU Session Setup    ${START_NON_GBR_UE}    ${STOP_NON_GBR_UE}    pdu_id=1    nwslice=1
#    SA NoncaUE Attach AND PDU Session Setup    ${START_GBR_UE}    ${STOP_GBR_UE}   pdu_id=2    nwslice=2
#    SA NoncaUE Attach AND PDU Session Setup    ${START_VONR_UE}    ${STOP_VONR_UE}   pdu_id=3    nwslice=2
#    NonGBR To GBR OR Vonr    ${START_VONR_UE}    ${STOP_VONR_UE}   pdu_id=3    qosflows_to_add=3
#    NonGBR To GBR OR Vonr    ${START_GBR_UE}    ${STOP_GBR_UE}   pdu_id=2    qosflows_to_add=4
#    SA Start NONGBR OR GBR OR VONR DLUL Traffic    ${START_NON_GBR_UE}    ${STOP_NON_GBR_UE}    pdu_id=1    trf_id=1    qfi_id=1
#    SA Start NONGBR OR GBR OR VONR DLUL Traffic    ${START_VONR_UE}    ${STOP_VONR_UE}   pdu_id=3    trf_id=1    qfi_id=2
#    SA Start NONGBR OR GBR OR VONR DLUL Traffic    ${START_GBR_UE}    ${STOP_GBR_UE}   pdu_id=2    trf_id=1    qfi_id=2
#    Check Non CA UE DL UL Tput With In Range    ${START_NON_GBR_UE}    ${STOP_NON_GBR_UE}    ${TARGET_TP_DL}    ${TARGET_TP_UL}    ${TPUT_RATE}
#    Check Non CA UE DL UL Tput With In Range    ${START_VONR_UE}    ${STOP_VONR_UE}    ${TARGET_TP_DL}    ${TARGET_TP_UL}    ${TPUT_RATE}
#    Check Non CA UE DL UL Tput With In Range    ${START_GBR_UE}    ${START_GBR_UE}    ${TARGET_TP_DL}    ${TARGET_TP_UL}    ${TPUT_RATE}
#    Capture Convert Format Ttitrace With Streaming Mode    2s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
