*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${SCF_FILE}
#...               iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CRT    FR1    Owner_naliu    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./FGCR2504_Resource.robot
#
#*** Variables ***
#${RD_PARAM}          0x58012B=1
#${RESOURCE_PATH}     ${CURDIR}/resources
#${WTS_LOCAL}         ${CURDIR}/resources/wts
#${WTS_CFG}           basic_setup_2504.cfg
#${IPHY_FILE}         ${CURDIR}/resources/wts/iphy_2504.xml
#${SCF_PATH}          ${CURDIR}/config
#${SCF_FILE}          SCF_2504_5.xml
#${UE_ID}             11
#${PROFILE_ID}        1
#${GNB_ID}            2
#${CELL_ID}           1
#${BEARER_ID}         2
#@{OLD_CFG_PARAMS}    plmn=[0-9]+:[0-9]+
#@{NEW_CFG_PARAMS}    plmn=302:610
#@{LOG_NAME_LIST}     btslog    snapshot
#
#
#*** Test Cases ***
#FGCR2504_ET_05_Check_10ms_TRS_Location_With_2SSB_Configured
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    100    2
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    100    1
#    Start Gnb BIP Log
#    Sleep    2s    reason=Capture BIP log
#    Stop Gnb BIP Log    ${OUTPUT_DIR}
#    Covert BIP To Csv
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}FGCR2504_ET_05.ini    i
#    ...    save_log_directory=${OUTPUT_DIR}
#
#
#
