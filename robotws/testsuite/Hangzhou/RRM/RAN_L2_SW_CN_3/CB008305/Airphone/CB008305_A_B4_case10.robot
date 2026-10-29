*** Settings ***
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CRT    SBTS00   SBTS22R4   RAN_5G_TDD    RAN_5G   AP    owner_changyli
...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
Test Timeout      60 minutes
Resource          ../../resources/KISS/robot/common_resource.robot
Resource          ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_8305_case10.xml
${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
${L1BYP_XML}      L1ByPTestModeConfiguration_case10.xml
${WTS_NAME}       wts_1086_7_TAS.cfg
${UE_ID1}         1
${UE_ID2}         2
${UE_ID3}         3
${UE_ID4}         4
${GW_ID1}         1
${GW_ID2}         2
${PDU_ID}         1
${SLICE_ID}       1
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
${COMAVALUE}    ${CURDIR}/coma/8305.txt

*** Test Cases ***
CB008305_A_B4_case10_rank1_Ue_pair_with_rank4_Ue_and_SCID_and_power_check
    Modify l1bypass
#    Active GNB L2 feature debug traces
    Prepare on air and case check


CB008305_A_B4_case10_rank1_Ue_paire_with_rank4_Ue_and_SCID_and_power_check_32rtx
   ${SCFC_NAME}      set variable    SCFC_8305_case10_32rtx.xml
   set test variable    ${SCFC_NAME}
   ${L1BYP_XML}      set variable    L1ByPTestModeConfiguration_case10_32rtx.xml
   set test variable    ${L1BYP_XML}
   Upload airphone l1bypass to iphy
   Prepare on air and case check

*** Keywords ***
Prepare on air and case check
    Prepare gnb onair
    run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
    airphone_cleanup_egate_console_log
    UE SA Attach    ${UE_ID1}
    UE SA Attach    ${UE_ID2}
    run keyword and continue on failure    Check rrc log
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=0
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
    Send DL data to UE and check throughput
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti_mu'
    Check mupair in ttitrace
    Detach SA UE    ${UE_ID1}
    Detach SA UE    ${UE_ID2}

    UE SA Attach    ${UE_ID1}
    UE SA Attach    ${UE_ID2}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=0
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
    Send DL data to UE and check throughput-2
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti_su'
    Check su in ttitrace
    Detach SA UE    ${UE_ID1}
    Detach SA UE    ${UE_ID2}
    Stop capture gnb and ap syslog in 'after_onair' file

UE SA Attach
    [Arguments]    ${UE_ID}
    airphone_cleanup_egate_console_log
    Airphone SA Attach    ue_id=${UE_ID}
    Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${UE_ID}

Internal send DL data
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        Airphone SA Start Data Traffic    ${num}    DL    100M    pdu_id=1    duration=6000s
        ...    trf_id=${num}
        Wait '3s ' to stable
    END

Wait '${time} ' to stable
    sleep    ${time}

Send DL data to UE and check throughput
    SA send mutiple trf dl data    ${UE_ID1}    6   175M
    SA send mutiple trf dl data    ${UE_ID2}    6    175M
    Wait '20s ' to stable
    Check throughput

Detach SA UE
    [Arguments]    ${UE_ID}
    airphone_sa_detach    ue_id=${UE_ID}


Check mupair in ttitrace
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_mu_case10.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Check throughput
    Wait until keyword succeeds    60s    5s    Verify throughput

Check rrc log
    Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/rrc_case10_mu.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate

Verify throughput
    ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0
    ...    type=pdsch    tput_type=ave
    ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0
    ...    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_ue1}>250000
    should_be_true    ${dl_throughput_ue2}>900000

Send DL data to UE and check throughput-2
    SA send mutiple trf dl data    ${UE_ID1}    6    175M
    SA send mutiple trf dl data    ${UE_ID2}    6    175M
    Wait '20s ' to stable
    Check throughput-2

Check throughput-2
    Wait until keyword succeeds    60s    5s    Verify throughput-2

Verify throughput-2
    ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0
    ...    type=pdsch    tput_type=ave
    ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0
    ...    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_ue1}>120000
    should_be_true    ${dl_throughput_ue2}>500000

Check su in ttitrace
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_su_case10.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Modify l1bypass
    copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
    Import Variables    ${test_log_directory()}/coma.py
    Modify airphone l1bypass coma value for eight ue
    ...    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex17}    ${Vindex5}    ${Hindex8}    ${Vindex0}
    ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
    ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
    ...    ${Hindex0}    ${Vindex0}    ${Hindex8}    ${Vindex0}
