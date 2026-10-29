*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_LPQ_AP_LOO    Owner_jshen
#...               SBTS00    SBTS24R3    CB012149    RAN_5G    RAN_5G_TDD    CRT    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SWCONFIG_PARAM}               0x580692=1;0x590072=1;0x890001=1;0x890003=1;0x890004=1
#${SCF_PATH}                     ${CURDIR}/Config
#${FULL_SCF}                     CB012149_AA301_302_scfc.xml
#${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4F_2T_AB.xml
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${WTS_CFG}                      CB012149_AA301.cfg
#${4CC_DL_DATA}                  1000
#${4CC_UL_DATA}                  250
#${NON_ULCA_EXP_TPUT}            90
#@{4CC_EXP_DL_TPUT_LIST}         530    140    140    50
#@{4CC_EXP_ZERO_TPUT_LIST}       0    0    0    0
#@{2CC_EXP_UL_TPUT_LIST}         130    40
#@{4CC_UE_LIST_1}                6
#@{PCELL_ID_LIST}                55
#@{4CC_SCELL_PHYSICALID_1}       50      51      53
#@{4CC_SCELL_PHYSICALID_LIST}    ${4cc_scell_physicalid_1}
#${A1THRESHOLD}                  105
#@{L2STREAM_COMPONENT_CONFIG}    &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB012149_ET_AA302_Connection_Setup_With_T_F_UL_Tx_Switching_SingleUE_With_A2_Scell_Release
#    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ue_id=6
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=6 meas_id=1 event=A1 srsrp_nr=105 phycell_id=55
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST_1}    ${4CC_DL_DATA}    ${4CC_UL_DATA}
#    sleep    10s    reason=wair for data is stable
#    Run Keyword And Continue On Failure    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
#    ...    ${4CC_UE_LIST_1}    ${2CC_EXP_UL_TPUT_LIST}    ${4CC_EXP_DL_TPUT_LIST}    4
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    Sleep    3s
#    Trigger A2 Scell Release    ue_id=6    scell_id=1    scell_rsrp=30    phycell_id=50    meas_id=2
#    Trigger A2 Scell Release    ue_id=6    scell_id=2    scell_rsrp=30    phycell_id=51    meas_id=3
#    Trigger A2 Scell Release    ue_id=6    scell_id=3    scell_rsrp=30    phycell_id=53    meas_id=4
#    Sleep    3s
#    Save Coam SnapShot    log_dir=${TEST_LOG_DIRECTORY}
#    SA 5G Detach    ${4CC_UE_LIST_1[0]}
#    [Teardown]    Common Test Teardown
#
