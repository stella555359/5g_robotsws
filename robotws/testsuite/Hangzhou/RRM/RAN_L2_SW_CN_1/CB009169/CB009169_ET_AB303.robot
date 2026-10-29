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
#${FULL_SCF}                       CB009169_Ab303_scfc.xml
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_Aa701.xml
#${WTS_LOCAL}                      ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB009169_Ab303.cfg
#${2CC_UL_DATA}                    40
#${4CC_DL_DATA}                    330
#@{4CC_EXP_DL_TPUT_LIST}           80    5    90    15
#@{2CC_EXP_UL_TPUT_LIST}           10    10
#@{4CC_UE_LIST}                    6    7    8    9    10
#@{4CC_PCELL_ID_LIST}              55    55    55    55    55
#@{2T_2F_SCELL_PHYSICALID_1}       51    52    54
#@{2T_2F_SCELL_PHYSICALID_LIST}    ${2T_2F_SCELL_PHYSICALID_1}    ${2T_2F_SCELL_PHYSICALID_1}    ${2T_2F_SCELL_PHYSICALID_1}
#...                               ${2T_2F_SCELL_PHYSICALID_1}    ${2T_2F_SCELL_PHYSICALID_1}
#${LOW_A1THRESHOLD}                95
#${HIGH_A1THRESHOLD}               105
#
#*** Test Cases ***
#CB009169_ET_AB303_Verify_Ul256Qam_With_Blind_Scell_Addition_And_Activation_With_BF_With_5GC002200_Enable
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST}    ${4CC_PCELL_ID_LIST}
#    ...    ${2T_2F_SCELL_PHYSICALID_LIST}    ${HIGH_A1THRESHOLD}    4
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST}    ${4CC_DL_DATA}    ${2CC_UL_DATA}
#    Display Multi UE Throughput    ${4CC_UE_LIST}
#    Sleep    200s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${4CC_EXP_DL_TPUT_LIST}    4
#    Check SCellIndex Of ULCA UE From Tput    ${4CC_UE_LIST[0]}    3
#    Check SCellIndex Of ULCA UE From Tput    ${4CC_UE_LIST[1]}    1
#    Check SCellIndex Of ULCA UE From Tput    ${4CC_UE_LIST[2]}    3
#    Check SCellIndex Of ULCA UE From Tput    ${4CC_UE_LIST[3]}    3
#    Check SCellIndex Of ULCA UE From Tput    ${4CC_UE_LIST[4]}    1
#    SA Multi UE Detach    ${4CC_UE_LIST}
#    [Teardown]    Common Test Teardown
