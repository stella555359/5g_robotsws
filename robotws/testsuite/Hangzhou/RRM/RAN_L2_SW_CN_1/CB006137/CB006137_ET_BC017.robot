*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    swconfig_param=${RD_PARAM}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    RAN_5G_TDD    RAN_5G    Owner_naliu    CN1_SQ6    CB006137
#...               CRT    SBTS00    SBTS23R1
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./resources/CB006137_BC_resource.robot
#
#*** Variables ***
#${RD_PARAM}                     0x580497=1;0x450027=1;0x420056=1;0x58056B=1;0x420062=1;0x580611=1;0x580641=1;0x420068=6
#${SCF_PATH}                     ${CURDIR}/config
#${SCF_FILE}                     CB006137_3F_3T_TDD_BBP_BC017.xml
#${IPHY_FILE}                    ${CURDIR}/config/WTS/CB006137_3F_3T_TDD_BBP_BC017_iphy.xml
#${DELTA_FILE}
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${COUNT}                        0
#${WTS_LOCAL}                    ${CURDIR}/config/WTS
#${WTS_CFG}                      CB006137_3F_3T_TDD_BBP_BC017.cfg
#${DL_TPUT_TARGET}               400
#${UL_TPUT_TARGET}               50
#@{PM_EXPEC_VALUES}              M55308C18001    960000    M55308C18002    8
#${PM_CELID}                     3
#${COUNTER_PATH_NAME}            NCELA
#
#*** Test Cases ***
#CB006137-ET-BC017_Multi_UE__UL_CA__Call_with_baseband_pooling_of_scheduled_UE_per_slot
#    Multi UE Attach And Do UL DL Traffic    1    16    10    10
#    Sleep    10s    reason=wait tput stable
#    Run Keyword And Ignore Error    Check Multiple CA UEs Scell Throughput    1    16    0    1    1
#    Multi UE Attach And Do UL DL Traffic    21    28    10    10
#    Check Multiple NonCA UEs Throughput    21    28    ul    1
#    Multi UE Attach And Do UL DL Traffic    31    38    10    10
#    Check Multiple NonCA UEs Throughput    31    38    ul    1
#    Sleep    300s    reason=wait PM Counter updated 5min
#    Get And Verify PM Counters    ${PM_CELID}    ${COUNTER_PATH_NAME}    ${PM_EXPEC_VALUES}
#
#*** Keywords ***
