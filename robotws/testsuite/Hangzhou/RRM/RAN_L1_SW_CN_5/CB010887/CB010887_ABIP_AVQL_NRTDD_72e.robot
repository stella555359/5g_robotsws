*** Settings ***
Documentation
...    Author:  liang.kong
...    Contact: liang.kong@nokia-sbell.com
...    Feature: CB010887
...    Release: 24R3
...    CB010887 is only to enable Ecpri72eUL. But it's not available because the actEcpri72e is enabled as cell level.
...    The configuration will be replaced by CB009170-G(Ecpri72eULDL).

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF
Resource          ../resources/common_resources.robot

*** Variables ***
@{ALLOWED_FAULT}    8101
${scf_file_72e}      CB010887_ABIP_AVQL_NRTDD_100M_A1_gscn_636666_1xNRCELL_${btsid}.xml
${scf_file_72a}      ABIP_AVQL_NRTDD_100M_A1_gscn_636666_1xNRCELL_72a_${btsid}.xml

@{DU_EVENT_TARGET_FILE_NAMES}    NrFine_slot    nrSnapshotEventLog.bin
${RU_TARGET_ZIP_FILE_NAME}    fcpTriggeredCapture_thor.tar.gz
@{RU_EVENT_TARGET_FILE_NAMES}    fcpTriggeredCapture_*_rxArray*_FD_SRS.bin
${MIN_SIZE}     ${1024}
${tc20_snapshot}    ${Empty}
${ROTTA_PATH}    //eseefsn50.emea.nsn-net.net/rotta4internal/LTE_2/7_2e_regression

*** Test Cases ***
Testability_TC20_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_event_based_NdmSrsBlindGrasp_CP1_B
    [Tags]    SMAwave    CB010887_E    CB009170-G    event_iq_capture    72e    Trunk    QL3Daily
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB010887/${scf_file_72e}
    SMAwave L3 call with 5G event IQ capture    1200M    120M    5G    78

Testability_TC36_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_event_trigger_NdmSrsBlindGrasp_with_IQ_decode
    [Tags]    SMAwave    CB010887_E    CB009170-G    event_iq_capture    72e    Trunk    QL3    TC36
    ${tc20_snapshot_exist}    Run Keyword And Return Status    File Should Exist    ${tc20_snapshot}
    Run Keyword If    ${tc20_snapshot_exist}    Check NrUlPhyEvenNdmSrsBlindGrasp Event IQ and 5gmax    ${tc20_snapshot}
    ...    ELSE    Run Keywords    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB010887/${scf_file_72e}
    ...    AND    SMAwave L3 call with 5G event IQ capture    1200M    120M    5G    78
    ...    AND    Check NrUlPhyEvenNdmSrsBlindGrasp Event IQ and 5gmax    ${tc20_snapshot}

*** Keywords ***
SMAwave L3 call with 5G event IQ capture
    [Arguments]    ${dl_tput}    ${ul_tput}    ${rat}    ${band}
    ...    ${specific_UE_index}=UE_1     ${duration}=600    ${protocol}=udp
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    IQ Event capture configuration
    Wait Until Keyword Succeeds    150s    30s    Check If Alarm Appeared    8101
    Check Snapshot Without Error
    [Teardown]    Run Keywords    SMAwave Stop Data And Detach    AND    Restore IQ Event capture parameter

Restore IQ Event capture parameter
    ADMIN Reset All Rad Debug Parameters
    Sleep    10s
    Disable IQ capture via webUI
    Run    cd ${SUITE_LOG_DIRECTORY}; rm -rf *.bin *D_l1a_up_trace.tgz *fcpTriggeredCapture_thor.tar.gz *_part*.zip

IQ Event capture configuration
    ${ul_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 300][7-2e]NRCELL-1: Subcell 0

    Configure IQ capture via webUI    ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU and RU
    ...    profile_prefix=ul_profile_2    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    ${CommonPhy_list}    Set Variable    [{'name': 'nbOfEventsToTrigAutoBTSSnapshot', 'value': '1'}]
    ${NrUlPhy_list}    Set Variable    [{'name':'enableRespCapture', 'value':'64'}, {'name': 'phyEventEnableExt', 'value': '32768'}]
    &{RAD_debug_paras_dict}    Create Dictionary    CommonPhy=${CommonPhy_list}    NrUlPhy=${NrUlPhy_list}

    ADMIN Set Multiple RAD debug parameters    CommonPhy    ${RAD_debug_paras_dict}[CommonPhy]
    ADMIN Set Multiple RAD debug parameters    NrUlPhy    ${RAD_debug_paras_dict}[NrUlPhy]


Get File Size From String
    [Arguments]    ${string}
    @{str_list}=    Split String    ${string}    ${SPACE}
    ${size}    Set Variable    ${str_list}[4]
    [Return]    ${size}

Check Snapshot Without Error
    Sleep    20s
    ${snapshot}    Save Snapshot Via WebUI
    Log To Console    \n captured snapshot file: ${snapshot}
    Set Suite Variable    ${tc20_snapshot}    ${snapshot}
    ${node_id}    Get Node Id    ABIP    thor_1
    Extract trbl log and check du iq log    ${snapshot}    ${DU_EVENT_TARGET_FILE_NAMES}
    Extract trbl log and check ru iq log    ${snapshot}    NdmSrsBlindGrasp
    Check L1 ERR and WRN in syslog

Upload snapshot to ROTTA
    [Arguments]    ${snapshot}
    ${isUploaded}    Run Keyword And Return Status    jenkins_upload_file_to_ROTTA    ${snapshot}    ${ROTTA_PATH}
    [Return]    ${isUploaded}

Check NrUlPhyEvenNdmSrsBlindGrasp Event IQ and 5gmax
    [Arguments]    ${snapshot}
    ${isUploaded}    Upload snapshot to ROTTA    ${snapshot}
    Run Keyword And Continue On Failure    Check DU CP1 IQ    ${snapshot}    ${isUploaded}
    Run Keyword And Continue On Failure    Check RU CPB IQ    ${snapshot}    ${isUploaded}

Check DU CP1 IQ
    [Arguments]    ${snapshot}    ${isUploaded}=${False}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive_du.zip    target_board=DU    event_trigger_only=True
    ...    is_72e_ul=True    is_72e_dl=False
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=True | is_72e_dl=False |.

    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_du.zip    target_startswith=RESP
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_du.zip   target_startswith=REQ
    ${resp_size}    Get File Size    ${path1}/${resp_txt}
    Run Keyword And Continue On Failure    Should Be True    ${resp_size} > 0    The file size should be greater than 0
    ${req_size}    Get File Size    ${path2}/${req_txt}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} >0    The file size should be greater than 0
    ${pattern1}    Set Variable    UlData_SrsReceiveRespBmPs_t.srsRespBmPsResources\\\\[0\\\\].dtx\\ =\\ 0x00\\ =\\ 0
    ${msg1}    Run    cat ${path1}/${resp_txt} | grep ${pattern1}
    Should Not Be Empty    ${msg1}    [ ERROR ] ${msg1} is NOT found in ${path1}/${resp_txt}

Check RU CPB IQ
    [Arguments]    ${snapshot}    ${isUploaded}=${False}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive_ru.zip    target_board=rfsrm7-thor
    ...    event_trigger_only=True    is_72e_ul=True    is_72e_dl=False    iq_data_analyzer_branch=master
    ...    branch_5gmax=master
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=True | is_72e_dl=False |.
    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_ru.zip    target_startswith=RESP_RU
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_ru.zip   target_startswith=REQ_RU
    ${resp_size}    Get File Size    ${path1}/${resp_txt}
    Run Keyword And Continue On Failure    Should Be True    ${resp_size} > 0    The file size should be greater than 0
    ${req_size}    Get File Size    ${path2}/${req_txt}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} >0    The file size should be greater than 0
    # check CPB IQ point on RU
    ${pattern1}    Set Variable    UlDataFH_SrsBmReceiveRespPs_t.srsRespBmPsResources\\\\[0\\\\].dtx\\ =\\ 0x00\\ =\\ 0
    ${msg1}    Run    cat ${path1}/${resp_txt} | grep ${pattern1}
    Should Not Be Empty    ${msg1}    [ ERROR ] ${msg1} is NOT found in ${path1}/${resp_txt}
    ${NdmSrsBlindGrasp.dump}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_ru.zip    target_startswith=NdmSrsBlindGrasp_.*\.dump
    ${NrSrsEigenGoBCoMaDtxUl} =    Get_SRS_Dump_Value    ${path4}/${NdmSrsBlindGrasp.dump}    NrSrsEigenGoBCoMaDtxUl
    FOR    ${val}    IN    @{NrSrsEigenGoBCoMaDtxUl}
            Should Be Equal As Numbers    ${val}    0.0
    END
    #Should Be True    ${NrRxMsmtSrsDtxDetect_int_value} == 0    The value of NrRxMsmtSrsDtxDetect is not equal as 0
