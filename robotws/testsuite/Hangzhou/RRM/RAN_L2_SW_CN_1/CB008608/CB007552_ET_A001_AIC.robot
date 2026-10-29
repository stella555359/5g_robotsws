*** Settings ***
Documentation    ...
#Resource          ../CUDU_L2_AIC/common_aic_setup_teardown.robot
#Force Tags        CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD
#...                FR1    Owner_melwu     master_vDU     SBTS00    SBTS23R1
#...               PRI-High    vDUCNF_0.300
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Update Aic GNB    VCU_SCFC_PATH=${CONFIG_FILE_PATH}/${BRANCH}/${7552_VCU_SCFC_PATH}
#...                      VDU_SCFC_PATH=${CONFIG_FILE_PATH}/${BRANCH}/${7552_VDU_SCFC_PATH}
#...               AND    Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown    debug
#
#*** Variables ***
#${CONFIG_FILE_PATH}         ${CURDIR}/config
#${7552_VCU_SCFC_PATH}       7552_vcu_scfc.xml
#${7552_VDU_SCFC_PATH}       7552_vdu_scfc.xml
#${GNB_INDEX}        0
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${WTS_CFG}          basic_setup_hz_TDD_NSA_OK.cfg
#${ENB_ID}           1
#${GNB_ID}           2
#${UE_ID}            11
#${PROFILE_ID}                   1
#${CELL_ID}                      1
#${BEARER_ID}                    2
#
#*** Test Cases ***
#CB007552_ET_A001_Verify_Feature_Activation_With_TDD_FR1_NSA_Mode
#    NSA LTE Attach    ${UE_ID}     ${profile_id}
#	NSA 5G Attach     ${ue_id}    ${gnb_id}    ${CELL_ID}    ${bearer_id}
#    NSA Start DL Traffic    ${ue_id}    ${bearer_id}    100
#    NSA Start UL Traffic    ${ue_id}    ${bearer_id}    5
#    Sleep    6s    reason=wait for traffic stable
#    ${dl_tpt}    NSA Get Average Throughput    ${ue_id}    ${bearer_id}      dl
#    ${ul_tpt}    NSA Get Average Throughput    ${ue_id}    ${bearer_id}      ul
#	Save Egate Log    ${OUTPUT_DIR}
#	Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007552-A_SingeUE${/}CB007552-A_SingleUE_SmallBWP.ini    p
#    ...    save_log_directory=${OUTPUT_DIR}
#    ${trace_id}    Start TTiTrace Log
#    Sleep    5s    reason=capture ttitrace
#    Stop TTiTrace Log   ${trace_id}
#    Decode TTiTrace Log
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007552-A_SingeUE${/}CB007552-A_SingleUE_SmallBWP.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}
#
