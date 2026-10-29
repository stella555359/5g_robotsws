*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown     debug
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown      debug
#Force Tags        CLOUD_5G_I_MP_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    RAN_5G    RAN_5G_FDD    FR1    Owner_zbu
#...               SBTS00    SBTS23R1    SBTS22R4
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#
#
#*** Variables ***
#${DELTA_FILE}              Delta_Conf_CB008325.json
#@{LOG_NAME_LIST}           btslog    snapshot
#${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
#${WTS_CFG}                 wts_config_MO_AP_KL_FDD_CPRI_cmwv_SANSA_FS_2S_1CC.cfg
#${DL_MBPS}                 60
#${UL_MBPS}                 20
#${START_UE_NUM}             1
#${STOP_UE_NUM}              10
#
#
#*** Test Cases ***
#CB006667_B005_PDSCH_And_PUSCH_Reasource_Increasing_Per_Slot_SU_MIMO_2X2_15M_Pi_2_BPSK_NSA
#    SA Multi Continuous NonCA UE Attach    ${START_UE_NUM}    ${STOP_UE_NUM}
#    SA Multi Continuous UE Start UL Traffic  ${START_UE_NUM}    ${STOP_UE_NUM}    ${UL_MBPS}
#    SA Multi Continuous UE Start DL Traffic    ${START_UE_NUM}    ${STOP_UE_NUM}    ${DL_MBPS}
#    Start Ttitrace With Streaming Mode
#    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
#    Stop Ttitrace
#    Decode Ttitrace Log    ${OUTPUT_DIR}/ttitrace_streaming/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB008325.ini
#    ...    i    save_log_directory=${OUTPUT_DIR}/ttitrace_streaming/
