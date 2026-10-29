*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Set CP Debug log
#...               AND    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    force_reboot=${True}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD    master_classicalbts_all    STATE_CONFIGURED    CRT
#...               RAN_5G_FDD    RAN_5G    FR1    Owner_andsun    SBTS00    SBTS23R1    SBTS22R4
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          ./FGCR8144_Resource.robot
#
#*** Variables ***
#${RD_PARAM}         0x590072=1;0x41001b=1    # CP Debug
#${SCF_PATH}         ${CURDIR}/resources/config
#${DELTA_FILE}       ${CURDIR}/resources/config/5G20B/Delta_Conf_8144_with_ulSched_150ms.json
#${DELTA_PATH_001}    Delta_Conf_8144.json
#${DELTA_PATH_003}    Delta_Conf_8144_with_ulSched_150ms.json
#${JSON_PATH}        ${CURDIR}/resources/config/
#${UE_ID}            151
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          3
#${BEARER_ID}        2
#@{LOG_NAME_LIST}    btslog    snapshot
#${COUNT}            0
#${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
#${WTS_CFG}          basic_fullstack_nsa_call_fdd_cmwv.cfg
#${WTS_AP_XML}       AirPhoneConfig_fullstack_fdd_nsa_cmwv.xml
#${LOG_DIR}          ${CURDIR}/results/
#@{OLD_CFG_PARAMS}      plmn=[0-9]+:[0-9]+
#@{NEW_CFG_PARAMS}      plmn=302:610
#
#*** Test Cases ***
#FGCR-8144-ET-003_UlProGrantTimer_Enable_NSA_FDD_FR1_With_Bigsize_Packets
#    ${UE_ID}=    Set Variable If    "${GNBCUTYPE}"=="SANSA"    151    ${UE_ID}
#    Set Suite Variable    ${UE_ID}    ${UE_ID}
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Sleep    1s    reason=wait LTE attach
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Start UL Traffic For CR8144    ${UE_ID}    2    100    2
#    Sleep    1s    reason=wait UL traffic become stable
#    NSA Verify If Attach Passed
#    Start Gnb BIP Log
#    Sleep    3s
#    Traffic For CR8144    ${UE_ID}
#    Stop Gnb BIP Log    ${output_dir}
#	Covert BIP To Csv
#	Verify 8144 function
