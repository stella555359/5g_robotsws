*** Settings ***
Suite Setup       Common Suite Setup
Suite Teardown    #Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     #Common Test Teardown
Force Tags        owner_menzheng    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
...               CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
Test Timeout      600 minutes
Resource          ../../resources/KISS/robot/common_resource.robot
Resource          ../../resources/sg10/internal_resource/internal_resource.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_8701_case1.xml
${AIRPHONE_NAME}    IPHY_AQQL_2ABIL_1CELL.xml
${L1BYP_XML}      L1ByPTestModeConfiguration_case25_8ue.xml
${WTS_NAME}       wts_8701_case1.cfg
${COMAVALUE}      ${CURDIR}/coma/8701_coma_dft.txt
${UE_NUM}         4
${UE_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog

*** Test Cases ***
CB008701_A_B1_case01_4UEs_rank_4_4_4_4with_nonGBR_paired_with_dlMuMimoRankAdaption_Disabled_4TAS_no_tapering_SA
    Modify 8701 Swconfig
    Modify l1bypass
    #Active GNB L2 feature debug traces
    Prepare gnb onair
    Set multiue traffic type to internal
    airphone_cleanup_egate_console_log
    run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
    Attach '4' ue with ''capability to 5g cell
    run keyword and continue on failure    Check rrc log
    Internal send DL data
    run keyword and continue on failure    Check throughput
    Start collect ttitrace
    Wait for '5s' to stop ttitrace with name'tti'
    run keyword and continue on failure    Check mupair in ttitrace
    Wait '1800s' for stabible
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti'
    run keyword and continue on failure    Check mupair in ttitrace
    Wait '1800s' for stabible
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti'
    run keyword and continue on failure    Check mupair in ttitrace
    Detach SA UEs
    Trigger block and unblock cell
    Stop capture gnb and ap syslog in 'after_onair' file
    Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
    #Check counters

*** Keywords ***
Internal send DL data
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        SA send mutiple trf dl data    ${num}    4    175M    pdu_id=${num}
        Wait '3s ' to stable
    END

Wait '${time} ' to stable
    sleep    ${time}

Send DL data to UE and check throughput
    SA send mutiple trf dl data    ${UE_ID1}    4    175M
    SA send mutiple trf dl data    ${UE_ID2}    1    100M
    Wait '20s ' to stable
    Check throughput

Detach SA UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        airphone_sa_detach    ue_id=${num}
        Wait '3s' for stabible
    END

Check mupair in ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Check throughput
    Wait until keyword succeeds    60s    5s    Verify throughput

Check rrc log
    Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_case1.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate

Verify throughput
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        ${sa_dl_tput}=    Airphone SA Get Throughput    ${num}    DL    ${num}
        run keyword and continue on failure    Should be true    ${sa_dl_tput}>30000
    END

Send DL data to UE and check throughput-2
    SA send mutiple trf dl data    ${UE_ID1}    4    175M
    SA send mutiple trf dl data    ${UE_ID2}    4    175M
    Wait '20s ' to stable
    Check throughput-2

Check throughput-2
    Wait until keyword succeeds    60s    5s    Verify throughput

Verify throughput-2
    ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
    ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_ue1}>550000
    should_be_true    ${dl_throughput_ue2}>550000

Set multiue traffic type to internal
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        Airphone Set Traffic Type    ${num}    ${num}    internal
    END

Check mupair in ttitrace-2
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case20-2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Modify l1bypass
    copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
    Import Variables    ${test_log_directory()}/coma.py
    Modify airphone l1bypass coma value for eight ue
    ...    ${Hindex12}    ${Vindex8}    ${Hindex12}    ${Vindex8}
    ...    ${Hindex6}    ${Vindex4}    ${Hindex6}    ${Vindex4}
    ...    ${Hindex23}    ${Vindex9}    ${Hindex23}    ${Vindex9}
    ...    ${Hindex16}    ${Vindex7}    ${Hindex16}    ${Vindex7}
    ...    ${Hindex12}    ${Vindex8}    ${Hindex12}    ${Vindex8}
    ...    ${Hindex6}    ${Vindex4}    ${Hindex6}    ${Vindex4}
    ...    ${Hindex23}    ${Vindex9}    ${Hindex23}    ${Vindex9}
    ...    ${Hindex16}    ${Vindex7}    ${Hindex16}    ${Vindex7}

Block cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'    Run Keywords
        ...    TAF_ADMIN.block    ${nrcel.id}    timeout=60    connection=${alias}
        ...    AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

Unblock cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}'    Run Keywords    TAF_ADMIN.unblock    ${nrcel.id}    timeout=60
        ...    connection=${alias}
        ...    AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}
	
Trigger block and unblock cell	
    FOR    ${num}    IN RANGE    1    20+1
        Block cell    50    gnb
        Unblock cell    50    gnb
        airphone_cleanup_egate_console_log
        Attach '4' ue with ''capability to 5g cell
        Internal send DL data
        run keyword and continue on failure    Check throughput
        Start collect ttitrace
        Wait for '1s' to stop ttitrace with name'tti'
        run keyword and continue on failure    Check mupair in ttitrace
        Detach SA UEs
    END

Modify 8701 Swconfig
    Add GNB swconfig    0x420062:1    0x800057:0
