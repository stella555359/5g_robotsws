*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO
...             CRT    RAN_5G    5G_RAN     SBTS00   CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Kshitij Tyagi
...              :contact: kshitij.tyagi@nokia.com
...         This user scenario describes multiple UEs attach/data transfer with the setup of FDD cell with 35MHz bandwidth followed by system
...         information transmission where max DL and Max UL throughput is verified
...         CB008152_B_B1_TC3_Verify_MultipleUE_with_35Mh_MaxDL_MaxUL_SAMode_ABIP

Resource         ./resources_keywords.resource

Suite Setup         Run keywords     Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Suite Teardown       Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report


Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords    Run Keyword and Ignore Error    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    MultiUE Deregister should be Successful   1   4
...                 AND      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_TC24.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${SCFC}=                  Bangalore/RRM/ET/CB008152/CB008152_B_TC24_scf.xml
${AP_XML}=                Bangalore/RRM/ET/CB008152/CB008152_B_TC24_iphy.xml


*** Test Cases ***
[1]CB008152_B_B1_TC24_Verify_MultipleUE_with_35Mh_MaxDL_MaxUL_SAMode_ABIP
    [Documentation]     This user scenario describes multiple UEs attach/data transfer with the setup of FDD cell with 35MHz
    ...         bandwidth followed by system    information transmission where max DL and Max UL throughput is verified

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
	start log     cprt   biptaf    btslog
    ${crnti_list}=      MultiUE Register should be Successful    1  4
    sleep   5s
    Trigger MAX DL throughput    1    4    2
    Trigger MAX UL throughput    1    4    2
	Stop Log   cprt   biptaf   btslog    test_scenario=DL_UL_Max_data
    sleep   30s
	Validate MAX DL throughput   1    4    175
	Validate MAX UL throughput   1    4    85
    Stop MultiUE Data Traffic for SA     1    4
    MultiUE Deregister should be Successful   1   4

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string       ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Trigger MAX DL throughput
   [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}
    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}+1
        MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=160
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    END

Trigger MAX UL throughput
    [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}
    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}+1
        MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=100
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    END

Validate MAX DL throughput
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_DL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_id}    scell_idx=0    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_DL_thp}
	END

Validate MAX UL throughput
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_UL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    load_based_validation_keywords.Get AVG UL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_UL_thp}
    END

