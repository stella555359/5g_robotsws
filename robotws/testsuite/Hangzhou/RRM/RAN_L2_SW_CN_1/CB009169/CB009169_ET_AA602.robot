*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580692=1
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    Owner_jshen
#...               SBTS00    SBTS23R2    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${FULL_SCF}                       CB009169_Aa602_scfc.xml
#${DELTA_SCF_602}                  Delta_CB009169_Aa602.json
#${DELTA_SCF_603}                  Delta_CB009169_Aa603.json
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_Aa701.xml
#${WTS_LOCAL}                      ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB009169_Ab502.cfg
#${WTS_DIR}                        /opt/wts/latest
#${2CC_DL_DATA}                    300
#${2CC_UL_DATA}                    100
#${4CC_DL_DATA}                    500
#@{2CC_EXP_DL_TPUT_LIST}           3    3
#@{2CC_EXP_UL_TPUT_LIST}           3    3
#@{4CC_EXP_DL_TPUT_LIST_1}         3    3    3    3
#@{2CC_EXP_UL_TPUT_LIST_1}         3    3
#@{4CC_EXP_DL_TPUT_LIST_2}         3    3    3    3
#@{2CC_EXP_UL_TPUT_LIST_2}         3    3
#@{2CC_UE_LIST}                    6
#@{4CC_UE_LIST_1}                  7
#@{4CC_UE_LIST_2}                  8
#@{2CC_PCELL_ID_LIST}              55
#@{4CC_PCELL_ID_LIST}              55
#@{2CC_SCELL_PHYSICALID_1}         54
#@{4CC_SCELL_PHYSICALID_1}         50    51    52
#@{4CC_SCELL_PHYSICALID_2}         50    51    54
#@{2CC_SCELL_PHYSICALID_LIST}      ${2CC_SCELL_PHYSICALID_1}
#@{4CC_SCELL_PHYSICALID_LIST_1}    ${4CC_SCELL_PHYSICALID_1}
#@{4CC_SCELL_PHYSICALID_LIST_2}    ${4CC_SCELL_PHYSICALID_2}
#${LOW_A1THRESHOLD}                99
#${HIGH_A1THRESHOLD}               110
#
#*** Test Cases ***
#CB009169_ET_AA602_2T_2F_SingleUE_Scell_Selection_DlToUlContributionRatio_100_With_ULCA
#    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_SCF_602}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell A1 Addition    ${2CC_UE_LIST}    ${2CC_PCELL_ID_LIST}
#    ...    ${2CC_SCELL_PHYSICALID_LIST}    ${LOW_A1THRESHOLD}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
#    Display Multi UE Throughput    ${2CC_UE_LIST}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${2CC_EXP_DL_TPUT_LIST}    2
#    Check SCellIndex Of ULCA UE From Tput    ${2CC_UE_LIST[0]}    1
#    SA 5G Detach    ${2CC_UE_LIST[0]}
#    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST_1}    ${4CC_PCELL_ID_LIST}
#    ...    ${4CC_SCELL_PHYSICALID_LIST_1}    ${HIGH_A1THRESHOLD}    4
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST_1}    ${4CC_DL_DATA}    ${2CC_UL_DATA}
#    Display Multi UE Throughput    ${4CC_UE_LIST_1}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST_1}    ${2CC_EXP_UL_TPUT_LIST_1}    ${4CC_EXP_DL_TPUT_LIST_1}    4
#    Check SCellIndex Of ULCA UE From Tput    ${4CC_UE_LIST_1[0]}    2
#    Save Egate Log    ${output_dir}
#    A2A Check RRC Log    ${CURDIR}${/}A2A/CB009169_Aa${/}CB009169_Aa602_ul.ini    ${output_dir}/egate_console.log
#    Capture Convert Format Ttitrace With Streaming Mode    2s
#    [Teardown]    Common Test Teardown    detach_ue_id=${4CC_UE_LIST_1[0]}
#
#CB009169_ET_AA603_T_3F_SingleUE_Scell_Selection_DlToUlContributionRatio_50_With_ULCA
#    [Setup]    Run Keywords    Delta Commission With SCF File   ${DELTA_SCF_603}
#    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST_2}    ${4CC_PCELL_ID_LIST}
#    ...    ${4CC_SCELL_PHYSICALID_LIST_2}    ${LOW_A1THRESHOLD}    4
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST_2}    ${4CC_DL_DATA}    ${2CC_UL_DATA}
#    Display Multi UE Throughput    ${4CC_UE_LIST_2}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST_2}    ${2CC_EXP_UL_TPUT_LIST_2}    ${4CC_EXP_DL_TPUT_LIST_2}    4
#    Check SCellIndex Of ULCA UE From Tput    ${4CC_UE_LIST_2[0]}    3
#    SA 5G Detach    ${4CC_UE_LIST_2[0]}
#    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST_2}    ${4CC_PCELL_ID_LIST}
#    ...    ${4CC_SCELL_PHYSICALID_LIST_2}    ${HIGH_A1THRESHOLD}    4
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST_2}    ${4CC_DL_DATA}    ${2CC_UL_DATA}
#    Display Multi UE Throughput    ${4CC_UE_LIST_2}
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST_2}    ${2CC_EXP_UL_TPUT_LIST_2}    ${4CC_EXP_DL_TPUT_LIST_2}    4
#    Check SCellIndex Of ULCA UE From Tput    ${4CC_UE_LIST_2[0]}    3
#    Capture Convert Format Ttitrace With Streaming Mode    2s
#    [Teardown]    Common Test Teardown    detach_ue_id=${4CC_UE_LIST_2[0]}
#
