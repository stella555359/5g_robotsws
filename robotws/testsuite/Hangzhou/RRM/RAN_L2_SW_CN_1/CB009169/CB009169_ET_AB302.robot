*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580692=1
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    Owner_jshen
#...               SBTS00    SBTS23R2    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD    CRT    AP_REG
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${FULL_SCF}                       CB009169_Ab302_scfc.xml
#${DELTA_SCF_302}                  Delta_CB009169_Ab302.json
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_Ab302.xml
#${WTS_LOCAL}                      ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB009169_Ab302.cfg
#${2CC_DL_DATA}                    900
#${2CC_UL_DATA}                    175
#${NON_ULCA_EXP_TPUT}              90
#@{2CC_EXP_DL_TPUT_LIST}           600    160
#@{2CC_EXP_UL_TPUT_LIST}           90    65
#@{2CC_UE_LIST_1}                  3
#@{2CC_UE_LIST_2}                  4
#@{2CC_UE_LIST}                    3    4
#@{2CC_SCELL_PHYSICALID_1}         54
#@{2CC_SCELL_PHYSICALID_LIST}      ${2CC_SCELL_PHYSICALID_1}
#
#*** Test Cases ***
#CB009169_ET_AB302_T_F_100Mhz_20Mhz_SingleUE_Attach_With_PDU_Initial_Addition_Blind_Activation_Blind_BF_Pcell_WithBeanrefine
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell Blind Addition    ${2CC_UE_LIST_1}    ${2CC_SCELL_PHYSICALID_LIST}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST_1}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
#    Sleep    15s    reason=wair for data is stable
#    Check Multi UE DLCA And ULnonCA L1 Cell Tput    ${2CC_UE_LIST_1}    ${NON_ULCA_EXP_TPUT}    ${2CC_EXP_DL_TPUT_LIST}    2
#    Delta Commission With SCF File    ${DELTA_SCF_302}
#    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
#    Check Multi UE DLCA And ULnonCA L1 Cell Tput    ${2CC_UE_LIST_1}    ${NON_ULCA_EXP_TPUT}    ${2CC_EXP_DL_TPUT_LIST}    2
#    SA 5G Detach    ${2CC_UE_LIST_1[0]}
#    SA Multi UE Attach With Scell Blind Addition    ${2CC_UE_LIST_2}    ${2CC_SCELL_PHYSICALID_LIST}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST_2}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
#    Sleep    15s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_LIST_2}    ${2CC_EXP_UL_TPUT_LIST}    ${2CC_EXP_DL_TPUT_LIST}    2
#    Check SCellIndex Of ULCA UE From Tput    ${2CC_UE_LIST_2[0]}    1
#    SA 5G Detach    ${2CC_UE_LIST_2[0]}
#    [Teardown]    Common Test Teardown
