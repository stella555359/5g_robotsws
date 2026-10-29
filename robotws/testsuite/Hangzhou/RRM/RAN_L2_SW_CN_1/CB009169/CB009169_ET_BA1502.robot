*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    Owner_jshen
#...               SBTS00    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD    CRT
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${FULL_SCF}                       CB009169_Ba1502_scfc.xml
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_Ba1603.xml
#${WTS_LOCAL}                      ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB009169_Ba1502.cfg
#${1T_1F_DL_DATA}                  1400
#${1T_1F_UL_DATA}                  160
#@{1T_1F_EXP_DL_TPUT_LIST}         280    50
#@{1T_1F_EXP_UL_TPUT_LIST}         10    10
#@{2CC_PCELL_ID_LIST}              52
#@{2CC_SCELL_PHYSICALID_1}         50
#@{2CC_SCELL_PHYSICALID_LIST_1}    ${2CC_SCELL_PHYSICALID_1}
#@{2CC_UE_LIST}                    3
#${LOW_A1THRESHOLD}                95
#${DELTA_SCF_BA1502}               Delta_CB009169_Ba1502.json
#
#*** Test Cases ***
#CB009169_ET_BA1502_Veriy_UE_Should_Be_Configured_With_TDD_80Mhz_FDD_30Mhz_UL_CA_5GC001116_Fr1UlCaPreferred_Set_To_DataRateBased
#    SA Multi UE Attach With Scell A1 Addition    ${2CC_UE_LIST}    ${2CC_PCELL_ID_LIST}
#    ...    ${2CC_SCELL_PHYSICALID_LIST_1}    ${LOW_A1THRESHOLD}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    ${1T_1F_DL_DATA}    ${1T_1F_UL_DATA}
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And ULnonCA L1 Cell tput    ${2CC_UE_LIST}    100    ${1T_1F_EXP_DL_TPUT_LIST}    2
#    SA 5G Detach    ${2CC_UE_LIST[0]}
#    Delta Commission With SCF File    ${DELTA_SCF_BA1502}
#    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
#    SA Multi UE Attach With Scell A1 Addition    ${2CC_UE_LIST}    ${2CC_PCELL_ID_LIST}
#    ...    ${2CC_SCELL_PHYSICALID_LIST_1}    ${LOW_A1THRESHOLD}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    ${1T_1F_DL_DATA}    ${1T_1F_UL_DATA}
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_LIST}    ${1T_1F_EXP_UL_TPUT_LIST}    ${1T_1F_EXP_DL_TPUT_LIST}    2
#    SA 5G Detach    ${2CC_UE_LIST[0]}
