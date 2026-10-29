*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO    CRT    RAN_5G    RAN_5G_TDD    FR1    Owner_minmluo
#...               SBTS00    SBTS23R4    SBTS24R1
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/resources/config
#${FULL_SCF}         CNI90881_scfc.xml
#${IPHY_FILE}        ${CURDIR}/resources/wts/new_iphy.xml
#${WTS_LOCAL}        ${CURDIR}/resources/wts
#${WTS_CFG}          wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
#${SWCONFIG}         0x58057C=0x200000;0x58057D=0x800;0x58057a=4
#${UE_ID}            1
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          2
#${BEARER_ID}        2
#@{LOG_NAME_LIST}    btslog    snapshot
#@{L2STREAM_COMPONENT_CONFIG}    &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CNI90881_ET_B001_Evaluation_Of_UL_TA_Grant_Reduction_By_PUCCH_Format_3
#    NSA LTE Attach    101
#    NSA 5G Attach    101    2    1    2
#    NSA LTE Attach    102
#    Sleep   3s
#    NSA 5G Attach    102    2    1    2
#    Sleep   3s
#    Trigger UE Timing Advance    101
#    Trigger UE Timing Advance    102
#    NSA Send DL Traffic    101
#    Capture Convert Format Ttitrace With Streaming Mode    capture_time=8s
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CNI90881_B001_TDD_ul.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#
#*** Keywords ***
#Trigger UE Timing Advance
#    [Arguments]    ${ue_id}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_ta_nr profile_id=1 nb_reps_ta_sim=255 ue_speed=5 ue_p_delay_max=28 ue_p_delay_min=0 ue_p_delay_initial=10
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${ue_id} testmode=ta action=activate profile_id=1
#    Sleep    10s    reason=wait timing advance is available
#
#NSA Send DL Traffic
#    [Arguments]    ${ue_id}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} dir=dl trf_id=1 protocol=udp ack_mode=off cl_trf_stats=on id=2 rtp_codec=custom
#    ...    rtp_ps=200 rtp_ts_step=1000 rtp_send_silence_period=0
#    Sleep    10s    reason=wait DL traffic is stable
