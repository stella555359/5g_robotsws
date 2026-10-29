*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown    debug
#Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_jshen
#...               SBTS00    CB012149    RAN_5G    RAN_5G_TDD    CRT
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SWCONFIG_PARAM}               0x590072=1;0x890001=1;0x890003=1;0x890004=1
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF}                     CB012149_BA303_A1A2_scfc.xml
#${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_AB.xml
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      CB012149_BA301.cfg
#${3CC_DL_DATA}                  1000
#${3CC_UL_DATA}                  170
#${NONCA_DL_DATA}                1100
#${NONCA_UL_DATA}                100
#${UE_ID}                        1
#${NO_12149_UE_ID}               2
#${AGAIN_12149_UE_ID}            3
#${EXP_DL_TPUT}                  140
#${EXP_UL_TPUT}                  16
#${NON_ULCA_EXP_TPUT}            90
#@{3CC_EXP_DL_TPUT_LIST}         140    40    215
#@{2CC_EXP_UL_TPUT_LIST}         34    9
#@{2CC_EXP_UL_TPUT_LIST_2}       15    9
#@{3CC_UE_LIST}                  1    2
#@{3CC_UE_LIST_1}                6
#@{3CC_UE_LIST_2}                8
#@{PCELL_ID_LIST}                55    55
#@{3CC_SCELL_PHYSICALID_1}       50    52
#@{3CC_SCELL_PHYSICALID_2}       50    52
#@{3CC_SCELL_PHYSICALID_LIST}    ${3CC_SCELL_PHYSICALID_1}    ${3CC_SCELL_PHYSICALID_2}
#${A1THRESHOLD}                  105
#@{2CC_UL_TPUT_LIST}             15    60
#@{NO_12149_2CC_UL_TPUT_LIST}    20    38
#@{RECOVER_12149_2CC_UL_TPUT_LIST_THREE_UE1}    7    60
#@{RECOVER_12149_2CC_UL_TPUT_LIST_THREE_UE2}    20    38
#@{RECOVER_12149_2CC_UL_TPUT_LIST_THREE_UE3}    4    35
#@{RECOVER_12149_2CC_UL_TPUT_LIST_THREE_UE1_LAST}    4    35
#@{RECOVER_12149_2CC_UL_TPUT_LIST_THREE_UE2_LAST}    16    38
#${3CC}                          3
#${SCF_FILE_DEACTIVE_12149}      Delta_REMOVE_12149.json
#${SCF_FILE_RECOVER_12149}       Delta_ADD_12149.json
#
#*** Test Cases ***
#CB012149_ET_BA101_1F_1T_UL_TX_Switching_Deactive_Active_MultiUE_With_ULCA
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID}    1
#    Send A1 report    ${UE_ID}    100    50
#    SA Start UL Traffic Internal    ${UE_ID}    1    ${NONCA_UL_DATA}
#	SA Start DL Traffic Internal    ${UE_ID}    1    ${NONCA_DL_DATA}
#    Check Scell activated
#	Check 3CCDL 2CCUL Pcell Scell TP    ${UE_ID}
#	Delta Commission With SCF File    ${SCF_FILE_DEACTIVE_12149}
#    Sleep    120s    reason=wait online changed succssfully
#	Check 3CCDL 2CCUL Pcell Scell TP    ${UE_ID}
#	SA 5G CA Attach    ${NO_12149_UE_ID}    1
#    Send A1 report    ${NO_12149_UE_ID}    100    50
#    SA Start UL Traffic Internal    ${NO_12149_UE_ID}    1    ${NONCA_UL_DATA}
#	SA Start DL Traffic Internal    ${NO_12149_UE_ID}    1    ${NONCA_DL_DATA}
#    Check Scell activated
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${NO_12149_UE_ID}    ${NO_12149_2CC_UL_TPUT_LIST}    ${3CC}
#    Delta Commission With SCF File    ${SCF_FILE_RECOVER_12149}
#    Sleep    120s    reason=wait online changed succssfully
#	Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_ID}             ${RECOVER_12149_2CC_UL_TPUT_LIST_THREE_UE1}    ${3CC}
#	Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${NO_12149_UE_ID}    ${RECOVER_12149_2CC_UL_TPUT_LIST_THREE_UE2}    ${3CC}
#	SA 5G CA Attach    ${AGAIN_12149_UE_ID}    1
#    Send A1 report    ${AGAIN_12149_UE_ID}    100    50
#    SA Start UL Traffic Internal    ${AGAIN_12149_UE_ID}    1    ${NONCA_UL_DATA}
#	SA Start DL Traffic Internal    ${AGAIN_12149_UE_ID}    1    ${NONCA_DL_DATA}
#    Check Scell activated
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${AGAIN_12149_UE_ID}    ${RECOVER_12149_2CC_UL_TPUT_LIST_THREE_UE3}    ${3CC}
#	Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_ID}             ${RECOVER_12149_2CC_UL_TPUT_LIST_THREE_UE1_LAST}    ${3CC}
#	Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${NO_12149_UE_ID}    ${RECOVER_12149_2CC_UL_TPUT_LIST_THREE_UE2_LAST}    ${3CC}
#    [Teardown]    Common Test Teardown    debug
#
#*** Keywords ***
#
#Check 3CCDL 2CCUL Pcell Scell TP
#    [Arguments]    ${UE_ID}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_ID}    ${2CC_UL_TPUT_LIST}    ${3CC}
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    pcell    0    90
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    1    90
#    Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    scell    2    440
#
#Check NONCA Pcell TP
#	Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    dl    pcell    0    0
#	Check CA UE Pcell Scell Cell TPut On Target    ${UE_ID}    ul    pcell    0    0
#
#Check Scell activated
#    Wait Until Keyword Succeeds    1min    7s     Check Latest Egate Log With Message    SCellIndex 1 activated successfully
#	Wait Until Keyword Succeeds    1min    7s     Check Latest Egate Log With Message    SCellIndex 2 activated successfully
#	Sleep    30s    reason=wair for data is stable
