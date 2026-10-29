*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580692=1
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    Owner_jshen
#...               SBTS00    SBTS23R2    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD    CRT
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${FULL_SCF}                       CB009169_Ab402_scfc.xml
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_Aa701.xml
#${WTS_LOCAL}                      ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB009169_Ab402.cfg
#${1T_2F_DL_DATA}                  1000
#${1T_2F_UL_DATA}                  175
#@{1T_2F_EXP_DL_TPUT_LIST}         500    70    150
#@{1T_2F_EXP_UL_TPUT_LIST}         50    30
#${2T_1F_DL_DATA}                  1400
#${2T_1F_UL_DATA}                  100
#@{2T_1F_EXP_DL_TPUT_LIST}         460    320    100
#@{2T_1F_EXP_UL_TPUT_LIST}         50    30
#@{3CC_UE_LIST_1}                  6
#@{3CC_UE_LIST_2}                  7
#@{3CC_UE_LIST}                    6    7
#@{1T_2F_SCELL_PHYSICALID_1}       51    53
#@{1T_2F_SCELL_PHYSICALID_LIST}      ${1T_2F_SCELL_PHYSICALID_1}
#@{2T_1F_SCELL_PHYSICALID_1}       52    53
#@{2T_1F_SCELL_PHYSICALID_LIST}      ${2T_1F_SCELL_PHYSICALID_1}
#@{3CC_PCELL_ID_LIST}              55
#${LOW_A1THRESHOLD}                95
#${HIGH_A1THRESHOLD}               105
#
#*** Test Cases ***
#CB009169_ET_AB402_T_2F_SingleUE_Addition_A1_Activation_UL_Buffer_Release_A2
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell A1 Addition    ${3CC_UE_LIST_1}    ${3CC_PCELL_ID_LIST}
#    ...    ${1T_2F_SCELL_PHYSICALID_LIST}    ${LOW_A1THRESHOLD}    3
#    SA Multi UE Start DL And UL Traffic    ${3CC_UE_LIST_1}    ${1T_2F_DL_DATA}    ${1T_2F_UL_DATA}
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${3CC_UE_LIST_1}    ${1T_2F_EXP_UL_TPUT_LIST}    ${1T_2F_EXP_DL_TPUT_LIST}    3
#    Check SCellIndex Of ULCA UE From Tput    ${3CC_UE_LIST[0]}    2
#    Trigger A2 Scell Release    ${3CC_UE_LIST_1[0]}    2    ${LOW_A1THRESHOLD}    ${1T_2F_SCELL_PHYSICALID_1[1]}
#    SA 5G Detach    ${3CC_UE_LIST[0]}
#    SA Multi UE Attach With Scell A1 Addition    ${3CC_UE_LIST_2}    ${3CC_PCELL_ID_LIST}
#    ...    ${2T_1F_SCELL_PHYSICALID_LIST}    ${HIGH_A1THRESHOLD}    3
#    Check SCellIndex Of ULCA UE From Tput    ${3CC_UE_LIST[1]}    2
#    SA 5G PDU Session Setup For NewDRB    ${3CC_UE_LIST[1]}
#    SA Multi UE Start DL And UL Traffic    ${3CC_UE_LIST_2}    ${2T_1F_DL_DATA}    ${2T_1F_UL_DATA}
#    Start And Check Throughput For CaseAB402 With NewDRB    ${3CC_UE_LIST[1]}
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${3CC_UE_LIST_2}    ${2T_1F_EXP_UL_TPUT_LIST}    ${2T_1F_EXP_DL_TPUT_LIST}    3
#    SA 5G Detach    ${3CC_UE_LIST[1]}
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Start And Check Throughput For CaseAB402 With NewDRB
#    [Arguments]    ${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=15    mbps=175    trf_id=3
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=15    mbps=100    trf_id=4
#    SA Check UE Cell TPut On Target    ${UE_ID}    1    dl    90
#    SA Check UE Cell TPut On Target    ${UE_ID}    15    dl    90
#    SA Check UE Cell TPut On Target    ${UE_ID}    1    ul    20
#    SA Check UE Cell TPut On Target    ${UE_ID}    15    ul    20
