*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BLLL_AP_LOO    CRT    RAN_5G    RAN_5G_FDD    FR1    Owner_zbu
#...               SBTS00    SBTS23R1    SBTS22R4
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./CB006667_B_E_Resource.robot
#
#
#
#*** Variables ***
#${FULL_SCF}                SCFC_BLLL_LOO_20M.xml
#@{LOG_NAME_LIST}           btslog    snapshot
#${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
#${WTS_CFG}                 BLLL_AP_LOO.cfg
#&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=12    bearer_id=2    dl_traffic=60M    ul_traffic=20M
#${UE_NUM}                  8
#
#*** Test Cases ***
#CB006667_B005_PDSCH_And_PUSCH_Reasource_Increasing_Per_Slot_SU_MIMO_2X2_15M_Pi_2_BPSK_NSA
#    NSA MultiUE Attach And Do Traffic    max_ue_num=${UE_NUM}    ue_info=${UE_INFO}
#    Capture Convert Format Ttitrace With Streaming Mode    2s    ${test_log_directory}/ttitrace_streaming/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB006667_A2A${/}CB006667-B05.ini
#    ...    i    save_log_directory=${test_log_directory}/ttitrace_streaming/
#
