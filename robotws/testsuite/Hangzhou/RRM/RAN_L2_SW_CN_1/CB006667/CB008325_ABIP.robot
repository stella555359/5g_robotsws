*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FUll_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_MP_AP_LOOO    CRT    RAN_5G    RAN_5G_FDD    FR1    Owner_zbu
#...               SBTS00    SBTS23R1    SBTS22R4
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config
#${FUll_FILE}              CB008325_ABIP_SCFC.xml
#${IPHY_FILE}                ${CURDIR}/resources/wts/iphy_MP_LOOO.xml
##${WTS_DIR}                  /opt/iphy/latest
#${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
#${WTS_CFG}                 CB008325_ABIP.cfg
#${DL_MBPS}                 20
#${UL_MBPS}                 10
#${START_UE_NUM}             1
#${STOP_UE_NUM}              10
#
#
#*** Test Cases ***
#CB006667_B005_PDSCH_And_PUSCH_Reasource_Increasing_Per_Slot_SU_MIMO_2X2_15M_Pi_2_BPSK_NSA_ABIP
#    SA Multi Continuous NonCA UE Attach    ${START_UE_NUM}    ${STOP_UE_NUM}
#    SA Multi Continuous UE Start UL Traffic  ${START_UE_NUM}    ${STOP_UE_NUM}    ${UL_MBPS}
#    SA Multi Continuous UE Start DL Traffic    ${START_UE_NUM}    ${STOP_UE_NUM}    ${DL_MBPS}
#    Capture Convert Format Ttitrace With Streaming Mode    2s    ${test_log_directory}/ttitrace_streaming/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB008325.ini
#    ...    i    save_log_directory=${test_log_directory}/ttitrace_streaming/
