*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=0x580692=1    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    Owner_y7li
#...               SBTS00    SBTS23R2    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD    CRT
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config
#${DELTA_FILE}               Delta_full_pwr_04_05_06.json
#${WTS_LOCAL}                ${CURDIR}/Resources/wts
#${WTS_CFG}                  CB009169_BD004.cfg
#${WTS_DIR}                  /opt/wts/latest
#${2CC_UL_DATA}              40
#${2CC_DL_DATA}              300
#@{COUNTER_ID_LIST}          ${COUNTER_1}    ${COUNTER_2}    ${COUNTER_3}
#&{COUNTER_1}                counter_id=M55114C01501    counter_path=CELLS/NRCELL-3/RACCU    min_value=295    max_value=305
#&{COUNTER_2}                counter_id=M55114C01502    counter_path=CELLS/NRCELL-3/RACCU    min_value=295    max_value=305
#&{COUNTER_3}                counter_id=M55114C01503    counter_path=CELLS/NRCELL-3/RACCU    min_value=295    max_value=305
#@{2CC_UE_LIST}              1    2    3
#@{2CC_PCELL_ID_LIST}        52    52    52
#@{SCELL_PHYSICALID_1}       50
#@{SCELL_PHYSICALID_2}       50
#@{SCELL_PHYSICALID_3}       50
#@{SCELL_PHYSICALID_LIST}    ${SCELL_PHYSICALID_1}    ${SCELL_PHYSICALID_2}    ${SCELL_PHYSICALID_3}
#${A1THRESHOLD}              75
#@{2CC_EXP_DL_TPUT_LIST}     20    20
#@{2CC_EXP_UL_TPUT_LIST}     3    3
#
#*** Test Cases ***
#CB009169_ET_BD004_Full_TX_power_in_UL_transmission_support_with_UE_capability_FullPwrMode_0_over_UL_CA_Call
#    SA Multi UE Attach With Scell A1 Addition    ${2CC_UE_LIST}    ${2CC_PCELL_ID_LIST}
#    ...    ${SCELL_PHYSICALID_LIST}    ${A1THRESHOLD}    2
#    SA Multi UE Start DL And UL Traffic    ${2CC_UE_LIST}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
#    Sleep    5s    reason=wait DL/UL traffic is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${2CC_EXP_DL_TPUT_LIST}    2
#    Trigger A2 Scell Release    1    1    11    50
#    Sleep    2s    reason=wait A2 release success
#    Trigger A2 Scell Release    2    1    11    50
#    Sleep    2s    reason=wait A2 release success
#    Trigger A2 Scell Release    3    1    11    50
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    ${time}    Evaluate     600+${time}
#    Sleep    ${time}    reason=wait for counter
#    Check Multi PM Counters Latest Value From Admin    ${COUNTER_ID_LIST}
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate/
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BD${/}CB009169_BD004.ini    p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}/egate/
