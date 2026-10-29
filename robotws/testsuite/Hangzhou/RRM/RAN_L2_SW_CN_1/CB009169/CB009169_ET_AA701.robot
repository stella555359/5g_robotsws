*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580692=1
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    Owner_jshen
#...               SBTS00    SBTS23R2    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD    CRT
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${FULL_SCF}                       CB009169_Aa701_scfc.xml
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_Aa701.xml
#${WTS_LOCAL}                      ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB009169_Aa701.cfg
#${2CC_UL_DATA}                    100
#${3CC_DL_DATA}                    400
#@{3CC_EXP_DL_TPUT_LIST}           3    3    3
#@{2CC_EXP_UL_TPUT_LIST}           3    3
#${NONCA_EXP_UL_TPUT}              3
#@{3CC_UE_LIST}                    6    7    8    9
#@{3CC_PCELL_ID_LIST}              55    55    55    55
#@{3CC_SCELL_PHYSICALID_1}         53    54
#@{3CC_SCELL_PHYSICALID_2}         53    54
#@{3CC_SCELL_PHYSICALID_3}         53    54
#@{3CC_SCELL_PHYSICALID_4}         53    54
#@{3CC_SCELL_PHYSICALID_5}         52    54
#@{3CC_SCELL_PHYSICALID_6}         52    54
#@{3CC_SCELL_PHYSICALID_7}         53    54
#@{3CC_SCELL_PHYSICALID_8}         52    53
#@{3CC_SCELL_PHYSICALID_LIST_1}    ${3CC_SCELL_PHYSICALID_1}    ${3CC_SCELL_PHYSICALID_2}    ${3CC_SCELL_PHYSICALID_3}    ${3CC_SCELL_PHYSICALID_4}
#@{3CC_SCELL_PHYSICALID_LIST_2}    ${3CC_SCELL_PHYSICALID_5}    ${3CC_SCELL_PHYSICALID_6}    ${3CC_SCELL_PHYSICALID_7}    ${3CC_SCELL_PHYSICALID_8}
#${LOW_A1THRESHOLD}                99
#${HIGH_A1THRESHOLD}               110
#
#*** Test Cases ***
#CB009169_ET_AA701_MultiUEs_Scell_Selection_With_ULCA
#    SA Multi UE Attach With Scell A1 Addition    ${3CC_UE_LIST}    ${3CC_PCELL_ID_LIST}
#    ...    ${3CC_SCELL_PHYSICALID_LIST_1}    ${LOW_A1THRESHOLD}    3
#    SA Multi UE Start DL And UL Traffic    ${3CC_UE_LIST}    ${3CC_DL_DATA}    ${2CC_UL_DATA}
#    Display Multi UE Throughput    ${3CC_UE_LIST}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${3CC_UE_LIST[0:3]}    ${2CC_EXP_UL_TPUT_LIST}    ${3CC_EXP_DL_TPUT_LIST}    3
#    Check SCellIndex Of ULCA UE From Tput    ${3CC_UE_LIST[0]}    1
#    Check SCellIndex Of ULCA UE From Tput    ${3CC_UE_LIST[1]}    2
#    Check SCellIndex Of ULCA UE From Tput    ${3CC_UE_LIST[2]}    1
#    Check Multi UE DLCA And ULnonCA L1 Cell Tput    ${3CC_UE_LIST[3:]}    ${NONCA_EXP_UL_TPUT}    ${3CC_EXP_DL_TPUT_LIST}    3
#    SA Multi UE Detach    ${3CC_UE_LIST}
#    SA Multi UE Attach With Scell A1 Addition    ${3CC_UE_LIST}    ${3CC_PCELL_ID_LIST}
#    ...    ${3CC_SCELL_PHYSICALID_LIST_2}    ${HIGH_A1THRESHOLD}    3
#    SA Multi UE Start DL And UL Traffic    ${3CC_UE_LIST}    ${3CC_DL_DATA}    ${2CC_UL_DATA}
#    Display Multi UE Throughput    ${3CC_UE_LIST}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${3CC_UE_LIST[0:3]}    ${2CC_EXP_UL_TPUT_LIST}    ${3CC_EXP_DL_TPUT_LIST}    3
#    Check Multi UE DLCA And ULnonCA L1 Cell Tput    ${3CC_UE_LIST[3:]}    ${NONCA_EXP_UL_TPUT}    ${3CC_EXP_DL_TPUT_LIST}    3
#    Check SCellIndex Of ULCA UE From Tput    ${3CC_UE_LIST[0]}    2
#    Check SCellIndex Of ULCA UE From Tput    ${3CC_UE_LIST[1]}    2
#    Check SCellIndex Of ULCA UE From Tput    ${3CC_UE_LIST[2]}    1
#    SA Multi UE Detach    ${3CC_UE_LIST}
