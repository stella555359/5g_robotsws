*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580692=1
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown    debug
#Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_xiapzhan
#...               SBTS00    SBTS23R2    CN1_SQ6    CB012149    RAN_5G    RAN_5G_TDD    CRT
## Resource        Resources/CB012149_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF}                     CB012149_AB101_scfc.xml
#${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_AB.xml
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      CB012149_AB101.cfg
#${2CC_DL_DATA}                  900
#${2CC_UL_DATA}                  250
#${NON_ULCA_EXP_TPUT}            90
#@{2CC_EXP_DL_TPUT_LIST}         751    81
#@{2CC_EXP_ZERO_TPUT_LIST}       0    0
#@{2CC_EXP_UL_TPUT_LIST}         190    30
#@{2CC_UE_LIST_1}                6
#@{2CC_UE_LIST_2}                4
#@{2CC_UE_LIST}                  3    4
#@{2CC_SCELL_PHYSICALID_1}       51
#@{2CC_SCELL_PHYSICALID_LIST}    ${2cc_scell_physicalid_1}
#
#*** Test Cases ***
#CB012149_ET_AB101_1T_1F_DL_Data_Scheduling_With_UL_Tx_Switching_For_Scell_Activation_Deactivation
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Multi UE Attach With Scell Blind Addition    ${2cc_ue_list_1}    ${2cc_scell_physicalid_list}    2
#    SA Multi UE Start DL Traffic    ${2cc_ue_list_1}    ${2CC_DL_DATA}
#    Sleep    10s    reason=wair for data is stable
#    Run Keyword And Continue On Failure    Check Multi UE DLCA Cell L1 Tput    ${2cc_ue_list_1}    ${2cc_exp_dl_tput_list}    2
#    Capture Convert Format Ttitrace With Streaming Mode    3s
#    Sleep    2s
#    Save Coam SnapShot    log_dir=${TEST_LOG_DIRECTORY}
#    # SA Multi UE Stop DL Traffic    ${2cc_ue_list_1}
#    # Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    1min    3s    SA Check CA Multi UE Cell Average DL Tput Equal To Target
#    # ...    ${2cc_ue_list_1}    ${2cc_exp_zero_tput_list}    2
#    # Sleep    5s
#    # SA 5G Detach    ${2CC_UE_LIST_1[0]}
#    [Teardown]    Common Test Teardown    debug
#
#
