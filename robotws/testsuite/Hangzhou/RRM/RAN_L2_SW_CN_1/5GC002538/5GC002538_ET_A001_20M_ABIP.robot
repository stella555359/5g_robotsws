*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_MP_AP_LO_SANSA_FS_CPRI_CMWV_FDD    FR1    CIT    CDRT    RAN_5G_FDD    Owner_fanjin
#...               SBTS00    SBTS23R1    SBTS22R4    RAN_5G
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#
#*** Variables ***
#${DELTA_FILE}       Delta_Conf_5GC002538_ABIP.json
#${UE_ID}            11
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          1
#${BEARER_ID}        2
#${DL_TRAFFIC}       175
#@{LOG_NAME_LIST}    btslog    snapshot
#
#*** Test Cases ***
#5GC002538_ET_A001_PDSCH_In_SSB_And_TRS_Slot_DL_Mimo_2x2_1UE_20M_NSA_ABIP
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    Set PDSCH Test Mode
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    ${DL_TRAFFIC}
#    Sleep    5s    reason=get *L2TtiTrace_EventsSnapshot
#    Start Ttitrace With Streaming Mode
#    Sleep    5s    reason=get *L2TtiTrace_EventsSnapshot
#    Stop Ttitrace
#    Decode Ttitrace Log    ${OUTPUT_DIR}/ttitrace_streaming/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}5GC002538.ini
#    ...    i    save_log_directory=${OUTPUT_DIR}/ttitrace_streaming/
#
#*** Keywords ***
#Set PDSCH Test Mode
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_decode_muxphychan decode_mux_phy_chan\=decode_PDSCH