*** Settings ***
Documentation
...    Author:  Yanqing.li
...    Contact: yanqing.li@nokia-sbell.com
...    Feature: testability_eCPRI_72a
...    Release: 25R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../../resources/common_resources.robot
Library           ../../resources/python/iq_data_analyzer_handler.py
Library           ../../resources/python/rotta_file_transfer.py
Library           ../../resources/python/check_5gmax_csv.py
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    8101
${ROTTA_PATH}    //eseefsn50.emea.nsn-net.net/rotta4internal/LTE_2/7_2a_regression
${scfc_file}    Testability_ABIO_1xAZQP_NRTDD_1xNRCEL_72a_${btsid}.xml
${ue_index}    UE_2

&{PA_dict}    ip=10.108.228.24    init_value=1:30;2:30;3:30;4:30     target_value=1:120;2:120;3:120;4:120
...    rank_2to1_value=1:120;2:30;3:30;4:30

*** Test Cases ***
Testability_TC09_NR_FR1_TDD_eCPRI_ABIO_72a_DL_UL_IQ_Capture_Blind_mode
    [Tags]    ABIO    SMAwave    Trunk    Testability    Blind    72a    TC09
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Testability${/}${scfc_file}
    SMAwave UE attach    rat=5G    cell_id=None    band=78    specific_UE_index=${ue_index}
    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[init_value]
    SMAwave Start Data Traffic    100M    20M    udp    1000

    ${subcell_index_list}=    Create List    [BBMOD_R-1(ABIO)] [PCI: 100]${72a_flag}NRCELL-1: Subcell 0
    Configure IQ capture via webUI    ul_subcell_index_list=${subcell_index_list}    dl_subcell_index_list=${subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Blind    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}

    SMAwave Verify throughput for DL and UL    100M    20M    30%    5G    78
    ${L1IQ}    Save IQ capture data via webUI
    ${isUploaded}    Run Keyword And Return Status    jenkins_upload_file_to_ROTTA    ${L1IQ}    ${ROTTA_PATH}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${L1IQ_name}    Split String From Right    ${L1IQ}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${L1IQ_name}    local_file=${TEST_LOG_DIR}/archive.zip    is_blind=True    target_board=DU
    ...    event_trigger_only=False    is_72e_ul=False    is_72e_dl=False    slots_to_decode=50
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=False | is_72e_ul=False | is_72e_dl=False |.
    ${REQ}    ${path1}    Extract Target file From Compressed File    compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=REQ
    ${UL_dl_ecpri1_pcap}    ${path2}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=UL_dl_ecpri*
    ${5G_UL_134D_Fcp_ecpri0.pcap}    ${path3}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=5G_UL_124D_Fcp_ecpri*
    ${pcap_size}=    Get File Size    ${path2}/${UL_dl_ecpri1_pcap}
    ${fcp_size}=    Get File Size    ${path3}/${5G_UL_134D_Fcp_ecpri0.pcap}
    ${req_size}=    Get File Size    ${path1}/${REQ}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} > 0    [ ERROR ] The REQ file size [ ${req_size} ] should be greater than 0
    Run Keyword And Continue On Failure    Should Be True    ${pcap_size} > 0   [ ERROR ] The pcap file size [${pcap_size}] should be greater than 0
    Run Keyword And Continue On Failure    Should Be True    ${fcp_size} > 0    [ ERROR ] The Fcp file size [ ${fcp_size} ] should be greater than 0
    [Teardown]    Run Keywords    SMAwave Stop Data And Detach    AND    common_resource_suite.Common Test Teardown

Testability_TC10_NR_FR1_TDD_eCPRI_ABIO_72a_DU_RU_IQ_event_trigger_mode_EPhyEvent_PuschNonMsg3CrcFailed
    [Tags]    ABIO    SMAwave    Trunk    Testability    iq    tc10
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Testability${/}${scfc_file}
    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[init_value]
    Sleep    30s
    SMAwave UE attach    rat=5G    cell_id=None    band=78    specific_UE_index=${ue_index}
    SMAwave Start Data Traffic    100M    20M    udp    1000

    ${subcell_index_list}=    Create List    [BBMOD_R-1(ABIO)] [PCI: 100]${72a_flag}NRCELL-1: Subcell 0
    Configure IQ capture via webUI    ul_subcell_index_list=${subcell_index_list}    dl_subcell_index_list=${subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}

    ADMIN Set RAD debug parameters    CommonPhy    nbOfEventsToTrigAutoBTSSnapshot    1
    ${NrUlPhy_list}    Set Variable    [{'name': 'enableRespCapture', 'value': '34'}, {'name': 'phyEventEnable', 'value': '512'}]
    ADMIN Set Multiple RAD debug parameters    NrUlPhy    ${NrUlPhy_list}

    SMAwave Verify throughput for DL and UL    100M    20M    30%    5G    78
    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[target_value]
    Wait Until Keyword Succeeds    150s    30s    Check If Alarm Appeared    8101
    [Teardown]    Run keywords    SMAwave Stop Data And Detach
    ...    AND    Case Teardown And Check Log In IQ    'PuschNonMsg3CrcFailed'    True    True
    ...    AND    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[init_value]

Testability_TC11_NR_FR1_TDD_eCPRI_ABIO_72a_DU_RU_IQ_event_trigger_mode_EPhyEvent_PuschTbCrcFailedWithReTx
    [Tags]    ABIO    SMAwave    Trunk    Testability    iq    tc11
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Testability${/}${scfc_file}
    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[init_value]
    Sleep    60s
    SMAwave UE attach    rat=5G    cell_id=None    band=78    specific_UE_index=${ue_index}
    SMAwave Start Data Traffic    100M    20M    udp    1000

    ${subcell_index_list}=    Create List    [BBMOD_R-1(ABIO)] [PCI: 100]${72a_flag}NRCELL-1: Subcell 0
    Configure IQ capture via webUI    ul_subcell_index_list=${subcell_index_list}    dl_subcell_index_list=${subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}

    ADMIN Set RAD debug parameters    CommonPhy    nbOfEventsToTrigAutoBTSSnapshot    1
    &{NrUlPhy_sub_dict_1}    Create Dictionary    name=enableRespCapture    value=290
    &{NrUlPhy_sub_dict_2}    Create Dictionary    name=phyEventEnable    value=32
    &{NrUlPhy_sub_dict_3}    Create Dictionary    name=puschConsecutiveHarqTransmissionThreshold    value=2
    @{rad_parameters_list}    Create List    ${NrUlPhy_sub_dict_1}    ${NrUlPhy_sub_dict_2}    ${NrUlPhy_sub_dict_3}
    ADMIN Set Multiple RAD debug parameters    NrUlPhy    ${rad_parameters_list}

    SMAwave Verify throughput for DL and UL    100M    20M    30%    5G    78
    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[target_value]
    Wait Until Keyword Succeeds    150s    30s    Check If Alarm Appeared    8101
    [Teardown]    Run keywords    SMAwave Stop Data And Detach
    ...    AND    Case Teardown And Check Log In IQ    'PuschTbCrcFailedWithReTx'    True
    ...    AND    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[init_value]

Testability_TC12_NR_FR1_TDD_eCPRI_ABIO_72a_DU_RU_IQ_event_trigger_mode_EPhyEvent_SrsNonDtx
    [Tags]    ABIO    SMAwave    Trunk    Testability    iq    tc12
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Testability${/}${scfc_file}
    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[init_value]
    SMAwave UE attach    rat=5G    cell_id=None    band=78    specific_UE_index=${ue_index}
    SMAwave Start Data Traffic    150M    150M    udp    1000

    ${subcell_index_list}=    Create List    [BBMOD_R-1(ABIO)] [PCI: 100]${72a_flag}NRCELL-1: Subcell 0
    Configure IQ capture via webUI    ul_subcell_index_list=${subcell_index_list}    dl_subcell_index_list=${subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}

    ADMIN Set RAD debug parameters    CommonPhy    nbOfEventsToTrigAutoBTSSnapshot    1
    ${NrUlPhy_list}    Set Variable    [{'name': 'enableRespCapture', 'value': '16'}, {'name': 'phyEventEnableExt', 'value': '16384'}]
    ADMIN Set Multiple RAD debug parameters    NrUlPhy    ${NrUlPhy_list}

    SMAwave Verify throughput for DL and UL    150M    150M    30%    5G    78
    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[rank_2to1_value]
    Wait Until Keyword Succeeds    400s    30s    Check If Alarm Appeared    8101
    [Teardown]    Run keywords    Case Teardown And Check Log In IQ    'SrsNonDtx'    False    False    True
    ...    AND    SMAwave Stop Data And Detach
    ...    AND    Adjust TOPYOUNG attenuation values    ${PA_dict}[ip]    ${PA_dict}[init_value]

*** Keywords ***
Case Teardown And Check Log In IQ
    [Arguments]    ${event_type}    ${CRC_NOK}=False    ${5gMax}=False    ${Nondtx}=False
    Should Be True    ${event_type} in ('PuschNonMsg3CrcFailed', 'PuschTbCrcFailedWithReTx', 'SrsNonDtx','NdmSrsBlindGrasp')
    ...    [ERROR] ${event_type} should be 'blind' | 'PuschNonMsg3CrcFailed' | 'PuschTbCrcFailedWithReTx' | 'SrsNonDtx' | 'NdmSrsBlindGrasp'.
    ${isTrigger}    Run Keyword And Return Status    ute_syslog.Message Should Exist In Syslog File    regexp=recordEvent     alias=enb_testSetup
    Run Keyword If    ${isTrigger}    Log To Console    [ERROR] recordEvent is NOT filtered in syslog.

    Run Keyword And Ignore Error    Stop Collect GNB Syslog    ${TEST_LOG_DIR}
    Run Keyword And Ignore Error    ute_syslog.Teardown All Aliases For Syslog
    get alarms state
    Run Keyword And Ignore Error    sbts_admin.teardown    connection=${connection}
    Run Keyword And Ignore Error    WebUI disconnection    suite

    ${snapshot}    Save Snapshot Via WebUI
    Run Keyword And Continue On Failure    Filter And Check DU L1 Journal Log    ${snapshot}
    Run Keyword And Continue On Failure    Filter And Check RU L1 Runtime Log    ${snapshot}
    ${Nr_fine_flag}    Run Keyword And Return Status    Check NrFine slot    ${snapshot}
    Should Be True    ${Nr_fine_flag}    [ERROR] NrFine_slot file not found
    ${isUploaded}    Run Keyword If    ${Nr_fine_flag}    Run Keyword And Return Status    jenkins_upload_file_to_ROTTA
    ...    ${snapshot}    ${ROTTA_PATH}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive.zip    target_board=DU    event_trigger_only=True
    ...    is_72e_ul=False    is_72e_dl=False
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=False | is_72e_dl=False |.
    Check iq pcap
    Check iq REQ and RESP message    ${event_type}
    Run Keyword If    ${5gMax}    5G MAX Check
    Run Keyword If    ${CRC_NOK}    Crc not ok
    Run Keyword If    ${Nondtx}    Srs nonDTX Check

Check NrFine slot
    [Arguments]     ${snapshot}
    ${node_id}    Get Node Id    ABIO    loki_1
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${node_id.strip('0x')}D_l1a_up_trace.tgz
    ${second_zip}    ${path1}    Extract Target file From Compressed File    ${snapshot}    ${first_zip}[0]
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    ${node_id.strip('0x')}D_l1a_up_trace.tgz
    ${forth_zip}     ${path3}    Extract Target file From Compressed File     ${path2}/${third_zip}    NrFine_slot
    File Should Exist    ${path3}/${forth_zip}    [ ERROR ] filename NOT EXIST
    Remove files    ${path2}/${third_zip}    ${path3}/${forth_zip}

Check iq REQ and RESP message
    [Arguments]        ${event_type}    ${iq_log}=${TEST_LOG_DIR}/archive.zip
    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${iq_log}    target_startswith=RESP
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${iq_log}   target_startswith=REQ
    ${pusch_req_message_list}    Create List     UlData_PuschReceiveReq
    ${pusch_resp_message_list}    Create List    UlData_PuschReceiveRespPs    UlData_PuschReceiveRespHarqU
    ${srs_req_message_list}    Create List     UlData_SrsReceiveReq
    ${srs_resp_message_list}    Create List    UlData_SrsReceiveRespPs
    ${resp_message_list}    Set Variable If    ${event_type} in ('PuschNonMsg3CrcFailed','PuschTbCrcFailedWithReTx')
    ...    ${pusch_resp_message_list}    ${srs_resp_message_list}
    FOR    ${msg}    IN    @{resp_message_list}
        ${result}    Run    cat ${path1}/${resp_txt} | grep ${msg}
        Run Keyword And Continue On Failure    Should Not Be Empty    ${result}    [ERROR] ${msg} is NOT found in <resp_txt>: ${result}.
    END
    ${req_message_list}    Set Variable If    ${event_type} in ('PuschNonMsg3CrcFailed','PuschTbCrcFailedWithReTx')
    ...    ${pusch_req_message_list}    ${srs_req_message_list}
    FOR    ${msg}    IN    @{req_message_list}
        ${result}    Run    cat ${path2}/${req_txt} | grep ${msg}
        Run Keyword And Continue On Failure    Should Not Be Empty    ${result}    [ERROR] ${msg} is NOT found in <req_txt>: ${result}.
    END

Check iq pcap
    [Arguments]    ${iq_log}=${TEST_LOG_DIR}/archive.zip
    ${ecpri_bin_pcap}    ${path1}    Extract Target file From Compressed File    compress_file=${iq_log}    target_startswith=ecpri.*.pcap
    ${file_size}=    Get File Size    ${path1}/${ecpri_bin_pcap}
    Log    File size is: ${file_size}
    Should Be True    ${file_size} > 0    [ ERROR ] ${ecpri_bin_pcap} size should be greater than 0

Crc not ok
    [Arguments]    ${iq_log}=${TEST_LOG_DIR}/archive.zip
    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${iq_log}    target_startswith=RESP
    ${msg}    Run    cat ${path1}/${resp_txt} | grep UlData_PuschReceiveRespPs_t.subcells\\[0\\].grants.*.crc\ =\ 0x01\ =\ 1
    Should Not Be Empty    ${msg}

5G MAX Check
    [Arguments]    ${iq_log}=${TEST_LOG_DIR}/archive.zip
    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${iq_log}    target_startswith=RESP
    ${pusch_bundled_summary.csv}    ${path1}    Extract Target file From Compressed File
    ...    compress_file=${iq_log}    target_startswith=pusch_bundled_summary.csv
    Check_UL_5Gmax    resp_file=${path1}/${resp_txt}    bundled_summary_file=${path1}/${pusch_bundled_summary.csv}

Srs nonDTX Check
    [Arguments]    ${iq_log}=${TEST_LOG_DIR}/archive.zip
    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${iq_log}    target_startswith=RESP
    ${pattern}    Set Variable    UlData_SrsReceiveRespPs_t.subcells\\\\[0\\\\].srsReceiveRespPsUes\\\\[0\\\\].dtx\\ =\\ 0x00\\ =\\ 0
    ${msg}    Run    cat ${path1}/${resp_txt} | grep ${pattern}
    Should Not Be Empty    ${msg}

