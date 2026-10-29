*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    iphy_file=${IPHY_FILE}    scf_file=${FULL_FILE}    swconfig_param_AP=${AP_SWCONFIG}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD    CRT    FR1     7_5_UTE5GCLASSICAL11671
#...               Owner_MINMLUO    CN1_SQ    SBTS00    SBTS23R1    SBTS22R4    SBTS22R2    RAN_5G    RAN_5G_TDD
#Resource          ${CURDIR}/../CUDU_L2/common_setup_teardown.robot
#Resource          ${CURDIR}/5GC001917_Resource.robot
#
#*** Variables ***
#${FULL_FILE}         Configuration_scf_MRBTS-1_7_5_UTE5GCLASSICAL11671.xml
#${IPHY_FILE}         ${CURDIR}/Resource/wts/new_iphy.xml
#${AP_SWCONFIG}       0x70678=1
#${LOCAL_WTS_DIR}     ${CURDIR}/Resource/wts
#${LOCAL_A2A_DIR}     ${CURDIR}/Resource/a2a
#${WTS_CFG}           basic_setup.cfg
#${SCF_PATH}          ${CURDIR}/Resource/Config
#${FILTER}            SEPARATOR=${EMPTY}    (3gpp.subcellid == 0)||(3gpp.subcellid == 1)and(uldataue_puschsendreq)
#@{CSV_TITLE_LIST}    3gpp.sfn    3gpp.slot    3gpp.subcellid
#
#*** Test Cases ***
#5GC001917_A_ET_001_Verify_UE_Attach_In_Overlapping_Area_With_4DL2UL
#    SA UE Register    ${UE_ID_1}    ${OVERLAP}
#    SA Start DL Traffic Internal    ${UE_ID_1}    ${PDU_ID}    10    ${TRF_ID}
#    SA Start UL Traffic Internal    ${UE_ID_1}    ${PDU_ID}    10    ${TRF_ID}
#    Sleep    5s    reason=Wait For Data Transmission
#    SA UE Check Throughput    ${UE_ID_1}    1    1
#    Check UE Is Served In Overlapping Area
#
#*** Keywords ***
#Check UE Is Served In Overlapping Area
#    Start AP BIP Log On ABIL
#    Sleep    1s    reason=get BIP data
#    Stop AP BIP Log On ABIL    log_dir=${TEST_LOG_DIRECTORY}/
#    ${bip_log}    Set Variable    ${TEST_LOG_DIRECTORY}/tcpdumpapL2L1_gulp_filtering_off.pcap000
#    Convert BIP To CSV By AP MCShark    ${bip_log}    ${OUTPUT_DIR}/bip_log.csv    ${FILTER}    ${CSV_TITLE_LIST}
#    ta_a2a.Check Log With Au2anlysis    ${LOCAL_A2A_DIR}/1917_TC001.ini    i    save_log_directory=${OUTPUT_DIR}
