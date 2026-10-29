*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown
#Force Tags        STATE_CONFIGURED    CRT    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    RAN_5G_TDD    RAN_5G    FR1    Owner_melwu
#...               master_classicalbts_all    RAN_5G_CRT       SBTS00    SBTS23R1       SBTS22R4
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          ./5GC001958_Resource.robot
#
#*** Variables ***
#${UE_ID}             11
#${PROFILE_ID}        1
#${GNB_ID}            2
#${FIRST_CELL_ID}     1
#${SECOND_CELL_ID}    2
#${BEARER_ID}         2
#@{LOG_NAME_LIST}     btslog    snapshot
#${COUNT}             0
#${LOCAL_WTS_DIR}     ${CURDIR}/resources/wts
#${WTS_CFG}           basic_setup.cfg
#
#
#*** Test Cases ***
#5GC001958_ET_A001_2Cells_2DL_2UL_Without_Beamforming_2_Cells_Under_Separate_RUs
#    NSA LTE Attach    ${ue_id}    ${profile_id}
#    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${FIRST_CELL_ID}    ${bearer_id}
#    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${ue_id}    ${bearer_id}    5
#    Start Gnb BIP Log    3000
#    Sleep    1s    reason=get BIP data
#    Stop Gnb BIP Log    ${test_log_directory}_1958
#	Convert BIP To CSV    ${test_log_directory}_1958    1958
#	Check Log With Au2anlysis    ${CURDIR}${/}A2A_1958_2DL2UL_CELL1/a2a.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}_1958
#
