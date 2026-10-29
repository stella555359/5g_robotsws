*** Settings ***
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    owner_menzheng    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
#${GNB_SWCONFIG_NAME}    gnb_swconfig_case17.txt
#${AP_SWCONFIG_NAME}    ap_swconfig.txt
${SCFC_NAME}      SCFC_8305_frame1116_case17.xml
${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
${L1BYP_XML}    L1B_H10V10_H17V5_case17.xml
${WTS_NAME}    wts_8305.cfg
${UE1_ID}          1
${UE2_ID}          2
${UE3_ID}          3
${PDU_ID}         1
#${GW1_ID}          1
#${GW1_ID}          2
${GW1_ID}          3
${SLICE_ID}       1
${hi}	4
${SYSLOG_TAG}     after_onair
${COMAVALUE}    ${CURDIR}/coma/8305.txt

*** Test Cases ***
CB008305_A_B5_case17_1SU_withAperidicSRS_only_and_2MU_mixed_scheduled
    Prepare test
    Prepare gnb onair
    Start capture gnb and ap syslog in '${SYSLOG_TAG}' file
    Multi UE SA Register
    SEND DL data to 2UE
    Check 2UE throughput
    Start collect ttitrace
    Wait for '5s' to stop ttitrace with name'tti_mu'
	DL data to 3rdUE
    Check 3UE throughput
    Start collect ttitrace
    Wait for '5s' to stop ttitrace with name'tti_mu_su'
	Check ttitrace
	DeRegister UEs
    Stop capture only gnb syslog in '${SYSLOG_TAG}' file
	
*** Keywords ***

Multi UE SA Register
    FOR    ${num}    IN RANGE    1    ${hi}
       airphone_cleanup_egate_console_log
       Log To Console   ${\n}-----register UE ${num} ------
       Airphone SA Attach    ue_id=${num}
       Airphone Set Traffic Type    ${num}    1    internal
       Airphone Pdu Session Setup    ${num}    1    1    ${num}
       Wait '3s' for stabible
       check UE '${num}' SRS in RRC log
    END

check UE '${ue_id}' SRS in RRC log
    Log To Console   check UE ${ue_id} SRS in RRC log
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
    # t2r4_n2:codebook
    run keyword if    ${ue_id}<3   run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/RRC_ue1ue2_case17.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}
    # t2r4_n2: NO periodic SRS
    run keyword if    ${ue_id}==3   run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/RRC_ue3_case17.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}

Check 2UE throughput
     Wait '10s' for stabible
     ${ue1_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
     ${ue2_tp}=    airphone_get_throughput_on_specific_scell    2    0    type=pdsch    tput_type=ave
     should be true    ${ue1_tp}>450000
     should be true    ${ue2_tp}>450000

Check 3UE throughput
     Wait '10s' for stabible
     ${ue1_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
     ${ue2_tp}=    airphone_get_throughput_on_specific_scell    2    0    type=pdsch    tput_type=ave
     ${ue3_tp}=    airphone_get_throughput_on_specific_scell    3    0    type=pdsch    tput_type=ave
     should be true    ${ue1_tp}>290000
     should be true    ${ue2_tp}>290000
     should be true    ${ue3_tp}>160000

SEND DL data to 2UE
    FOR    ${ue_id}    IN RANGE    1    3
	   SEND data to '${ue_id}'
    END
	
SEND data to '${ue_id}'
	FOR    ${num}    IN RANGE    1    4	
	   SA send mutiple trf dl data    ${ue_id}    ${num}    175M    ${pdu_id}
    END

DL data to 3rdUE
    Airphone SA Start Data Traffic    ${UE3_ID}    DL   175M   pdu_id=${PDU_ID}   duration=3600   trf_id=1
    Airphone SA Start Data Traffic    ${UE3_ID}    DL   175M   pdu_id=${PDU_ID}   duration=3600   trf_id=2
    Wait '4s' for stabible

DeRegister UEs
    FOR    ${num}    IN RANGE    1    ${hi}
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '4s' for stabible
    END

Check ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_mu_case17.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_mu_su_case17.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Prepare test
    Modify l1bypass
    Active GNB L2 feature debug traces
	Modify 8305 Swconfig
	
Modify l1bypass
    copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
    Import Variables    ${test_log_directory()}/coma.py
    Modify airphone l1bypass coma value for eight ue
    ...    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex17}    ${Vindex5}    ${Hindex8}    ${Vindex0}
    ...    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
    ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex0}    ${Vindex0}    ${Hindex8}    ${Vindex0}

Modify 8305 Swconfig
	Add GNB swconfig    0x590128:0x4

