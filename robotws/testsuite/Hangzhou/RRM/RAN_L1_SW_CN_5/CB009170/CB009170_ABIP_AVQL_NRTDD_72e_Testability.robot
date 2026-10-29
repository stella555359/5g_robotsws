*** Settings ***
Documentation
...    Author:  liang.kong
...    Contact: liang.kong@nokia-sbell.com
...    Feature: CB009170
...    Release: 24R3

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown

Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

Resource          ../resources/common_resources.robot
Library           ../resources/python/check_snapshot.py

*** Variables ***
@{ALLOWED_FAULT}    8101
${scf_file_72e}      CB009170_ABIP_AVQL_AVQC_NRTDD_100M_A1_gscn_636666_2xNRCELL_${btsid}.xml
${scf_file_72e_tc19}      CB009170_ABIP_AVQL_NRTDD_100M_A1_gscn_636666_1xNRCELL_${btsid}.xml
${scf_72e_file_tc28}      CB007595_ABIP_AVQL_NRTDD_100M_A1_gscn_636666_1xNRCELL_${btsid}.xml

@{BLIND_TARGET_FILE_NAMES}  124D_IqSamples.bin  5G_DL_124D_Fcp.bin  5G_UL_124D_Fcp.bin
${EVENT_TARGET_FILE_NAME}    *124D_l1a_contIqSnapshotBuffer.bin
${TARGET_ZIP_FILE_NAME}    124D_l1a_contIqSnapshotBuffer.bin.xz
${MIN_SIZE}     ${1024}

${ROTTA_PATH}    //eseefsn50.emea.nsn-net.net/rotta4internal/LTE_2/7_2e_regression

&{bts_PA_dict}    10386=&{PA_dict_10386}    11148=&{PA_dict_11148}    37667=&{PA_dict_37667}
&{PA_dict_10386}    ip=10.108.241.5     init_value=1:10;2:10;3:10;4:10    target_value=1:70;2:70;3:70;4:70
&{PA_dict_11148}    ip=10.108.241.44    init_value=1:35;3:35;5:35;7:35     target_value=1:85;3:85;5:85;7:85
&{PA_dict_37667}    ip=10.108.228.28    init_value=1:20;2:20;3:20;4:20     target_value=1:85;2:85;3:85;4:85

#${Pdsch_req_message}    DlData_PdschSendReqL1sw_t.grants.*.rnti
${dl_Pdsch_req_message}    DlDataFH_PdschSendReq
${dl_Pdcch_req_message}    DlDataFH_PdcchSendReq
${Pusch_req_message}    UlData_PuschReceiveReq
${Pusch_resp_crcok_message}    UlData_PuschReceiveRespPs_t.subcells.*.grants.*.crc\\ =\\ 0x00\\ =\\ 0

${tc19_snapshot}    ${Empty}

*** Test Cases ***
Testability_TC18_CB009170_G_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_blind_mode
    [Tags]    SMAwave    CB009170    TC18    Blind    72e    Trunk    Testability    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB009170/${scf_file_72e}
    SMAwave L3 call with 5G blind IQ capture    10M    10M    5G    78

Testability_TC19_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_event_based_NrDlPhyEvenPdschReTxBler_CP0_4
    [Tags]    SMAwave    CB009170    event_iq_capture    TC19    72e    Trunk    Testability    QL3Daily
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB009170/${scf_file_72e_tc19}

    ${CommonPhy_list}    Set Variable    [{'name': 'nbOfEventsToTrigAutoBTSSnapshot', 'value': '1'}]
    ${NrDlPhy_list}    Set Variable    [{'name': 'dlPhyEventEnable', 'value': '2'}]
    &{RAD_debug_paras_dict}    Create Dictionary    CommonPhy=${CommonPhy_list}    NrDlPhy=${NrDlPhy_list}

    SMAwave L3 call with 5G DL event IQ capture    1200M    150M    5G    78    ${RAD_debug_paras_dict}

Testability_TC30_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_event_trigger_NrDlPhyEvenPdschReTxBler_with_IQ_decode
    [Tags]    SMAwave    CB009170    event_iq_capture    TC30    72e    Trunk    Testability    QL3Weekly

    ${CommonPhy_list}    Set Variable    [{'name': 'nbOfEventsToTrigAutoBTSSnapshot', 'value': '1'}]
    ${NrDlPhy_list}    Set Variable    [{'name': 'dlPhyEventEnable', 'value': '2'}]
    &{RAD_debug_paras_dict}    Create Dictionary    CommonPhy=${CommonPhy_list}    NrDlPhy=${NrDlPhy_list}

    ${tc19_snapshot_exist}    Run Keyword And Return Status    File Should Exist    ${tc19_snapshot}
    Run Keyword If    ${tc19_snapshot_exist}    Check NrDlPhyEvenPdschReTxBler Event IQ and 5gmax    ${tc19_snapshot}
    ...    ELSE    Run Keywords    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB009170/${scf_file_72e_tc19}
    ...    AND    SMAwave L3 call with 5G DL event IQ capture    1200M    150M    5G    78    ${RAD_debug_paras_dict}
    ...    AND    Check NrDlPhyEvenPdschReTxBler Event IQ and 5gmax    ${tc19_snapshot}

Testability_TC28_CB009170_G_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_DL_FD_IQ_with_RAD_para
    [Tags]    SMAwave    CB009170_G    TC28    72e    Trunk    QL3    event_iq_capture    Testability
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file_tc28}
    SMAwave UE attach    rat=5G    cell_id=None    band=78    specific_UE_index=UE_1
    SMAwave Start Data Traffic    100M    20M    udp    3600

    ## updated rad parameters [ 0x01808 -> 0x03010, 0x01810 -> 0x03020, 0x01818 -> 0x03030, 0x01820 -> 0x03040 ] based on tips:
    ## https://confluence.ext.net.nokia.com/display/MNL1/2.+RU+Thor+IQ+capture#id-2.RUThorIQcapture-HowtosetRADflag
    LMI eth on
    LMI Execute Command via ssh    commands=sudo rm /ram/l1radio/*.bin    passed_tag=None   ip=192.168.101.17
    ...    username=serviceuser    password=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=
    LMI Execute Command via ssh    commands=sudo ccsShell.sh rad -mw 0xA6000B 0x03010    passed_tag=written succesfully    ip=192.168.101.17
    ...    username=serviceuser    password=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=
    ${snapshot}    Save Snapshot Via WebUI
    SMAwave Verify throughput for DL and UL    100M    20M    10%    5G    78
    ${isUploaded}    Run Keyword And Return Status    jenkins_upload_file_to_ROTTA    ${snapshot}    ${ROTTA_PATH}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ##iq data analysis for DL
    ${isDLAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive_dl.zip    target_board=rfsrm7-thor
    ...    event_trigger_only=False    is_72e_ul=False    is_72e_dl=True
    Should Be True    ${isDLAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=False | is_72e_ul=False | is_72e_dl=True |.
    ${target_file_list}    Create List    l1radio_iq_capture_.*\.bin.pcap
    Extract snapshot archives and check iq log    ${TEST_LOG_DIR}/archive_dl.zip    ${target_file_list}    ${TEST_LOG_DIR}
    #${dl_RU_bin.pcap}    ${path1}    Extract Target file From Compressed File
    #...    compress_file=${TEST_LOG_DIR}/archive_dl.zip    target_startswith=l1radio_iq_capture*
    #${dl_pcap_size}=    Get File Size    ${path1}/${dl_RU_bin.pcap}
    #Run Keyword And Continue On Failure    Should Be True    ${dl_pcap_size} > 0    [ ERROR ] ${dl_RU_bin.pcap} size [${dl_pcap_size}] == 0.
    ${REQ}    ${path2}    Extract Target file From Compressed File    compress_file=${TEST_LOG_DIR}/archive_dl.zip    target_startswith=REQ
    ${result}    Run    cat ${path2}/${REQ} | grep ${dl_Pdsch_req_message}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${result}    [ERROR] ${dl_Pdsch_req_message} is NOT found in <REQ>: ${result}.
    ${result}    Run    cat ${path2}/${REQ} | grep ${dl_Pdcch_req_message}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${result}    [ERROR] ${dl_Pdcch_req_message} is NOT found in <REQ>: ${result}.

    ##check 5gmax for DL
    ${pdsch_summary.csv}    ${path3}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_dl.zip    target_startswith=PDSCH_summary.csv
    Check_Dl_5Gmax    bundled_summary_file=${path3}/${pdsch_summary.csv}

    ## Check the iq logs, it should be 4 files and size shoulb be same and in [10240 : 214000000] ##
    ${iq_local_path}    Set Variable    ${TEST_LOG_DIR}/bin
    Run    mkdir ${iq_local_path}

    LMI eth on
    LMI Execute Command via ssh    commands=sudo rm /ram/l1radio/*.bin;sudo ccsShell.sh rad -mw 0xA6000B 0x0    passed_tag=None   ip=192.168.101.17
    ...    username=serviceuser    password=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=

    ${dl_cmd_list}    Create List    sudo ccsShell.sh rad -mw 0xA6000B 0x03010    sudo ccsShell.sh rad -mw 0xA6000B 0x03020
    ...    sudo ccsShell.sh rad -mw 0xA6000B 0x03030    sudo ccsShell.sh rad -mw 0xA6000B 0x03040
    FOR    ${cmd}    IN     @{dl_cmd_list}
        LMI Execute Command via ssh    commands=${cmd}    passed_tag=written succesfully    ip=192.168.101.17
        ...    username=serviceuser    password=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=
        LMI Transfer Files    remote=/ram/l1radio/*.bin    local=${iq_local_path}    operation=download
        ...    ip=192.168.101.17    username=serviceuser    password=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=
    END
    Check RU FD IQ logs    file_min_size=10240    file_max_size=214000000    iq_local_path=${iq_local_path}

*** Keywords ***
Extract snapshot archives and check iq log
    [Arguments]    ${snapshot}    ${target_file_list}    ${output_dir}
    ${output}=    search_and_extract_files_from_archive     ${snapshot}    ${target_file_list}    ${output_dir}
    FOR    ${pattern}    IN    @{target_file_list}
        ${file_dict}=    Get From Dictionary    ${output}    ${pattern}
        FOR    ${file_name}    IN    @{file_dict.keys()}
            ${file_info}=    Get From Dictionary    ${file_dict}    ${file_name}
            ${file_size}=    Get From Dictionary    ${file_info}    size
            ${output_path}=    Get From Dictionary    ${file_info}    output_path
            Run Keyword And Continue On Failure    Should Be True    ${file_size} > 0
            ...    [ ERROR ] ${file_name} size [ ${file_size} ] at [ ${output_path} ] should be greater than 0 KB.
        END
    END

SMAwave L3 call with 5G blind IQ capture
    [Arguments]    ${dl_tput}    ${ul_tput}    ${rat}    ${band}
    ...    ${specific_UE_index}=UE_1    ${duration}=300    ${protocol}=udp
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    ${params}=     set variable   69:895
    ADMIN Change Bts Rad Parameters    128    ${params}
    ${subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 300]NRCELL-1: Subcell 0
    Configure IQ capture via webUI    ul_subcell_index_list=${subcell_index_list}    dl_subcell_index_list=${subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Blind    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    Sleep    60s
    ${L1IQ}    Save IQ capture data via webUI
    Check fcpTriggeredCapture logs for blind mode IQ    ${L1IQ}
    Check Blind Capture IQ and 5gmax    ${L1IQ}
    [Teardown]    SMAwave Stop Data And Detach

SMAwave L3 call with 5G DL event IQ capture
    [Arguments]    ${dl_tput}    ${ul_tput}    ${rat}    ${band}    ${RAD_debug_paras_dict}=${None}
    ...    ${specific_UE_index}=UE_1    ${duration}=600    ${protocol}=udp
    ${bts_id}    Convert To String    ${bts_id}
    Adjust HBTE attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}

    IQ Event capture configuration
    ADMIN Set Multiple RAD debug parameters    CommonPhy    ${RAD_debug_paras_dict}[CommonPhy]
    ADMIN Set Multiple RAD debug parameters    NrDlPhy    ${RAD_debug_paras_dict}[NrDlPhy]

    Adjust HBTE attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][target_value]
    Wait Until Keyword Succeeds    150s    30s    Check If Alarm Appeared    8101

    ${snapshot}    Save Snapshot Via WebUI
    Set Suite Variable    ${tc19_snapshot}    ${snapshot}
    Check Snapshot Without Error    ${snapshot}

    Run Keyword And Continue On Failure    check L1low and L1sw logs in snapshot    ${snapshot}
    ADMIN Reset All Rad Debug Parameters
    [Teardown]    Run Keywords    SMAwave Stop Data And Detach
    ...    AND    Adjust HBTE attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]

IQ Event capture configuration
    ${dl_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 300][7-2e]NRCELL-1: Subcell 0
    ${random_antenna_group}      Evaluate    random.choice(['Group17', 'Group18', 'Group19', 'Group20'])    random
    ${antenna_list_group}=    Create Dictionary    Antenna list=${random_antenna_group}
    Configure IQ capture via webUI    ul_subcell_index_list=${None}    dl_subcell_index_list=${dl_subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU and RU
    ...    profile_prefix=dl_profile_1    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${antenna_list_group}

Extract trbl log and check iq log
    [Arguments]    ${snapshot}    ${zip_file_name}    ${TARGET_FILE_NAMES}
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${zip_file_name}
    ${second_zip}    ${path1}    Extract Target file From Compressed File     ${snapshot}    ${first_zip}[0]
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    ${zip_file_name}
    Log To Console    \ncaptured file path is ${path2}/${third_zip}
    ${TGZ_PATH}    Set Variable    ${path2}/${third_zip}
    ${compress_format}    Set Variable    ${TGZ_PATH.rsplit('.',1)[-1]}
    ${list_cmd}    Run Keyword If    '${compress_format}'=='xz'    Set Variable    xz -d ${TGZ_PATH}
    ${uncompress}    Run    ${list_cmd}
    ${TARGET_FILE}    Set Variable    ${path2}/${TARGET_FILE_NAMES}
    ${output}    Run    ls -l ${TARGET_FILE}
    Log To Console   \n${output}
    ${file_size}=    Get File Size From String    ${output}
    Log    File size is: ${file_size}
    Should Be True    ${file_size} > ${MIN_SIZE}    [ ERROR ] ${TARGET_FILE_NAMES} size should be greater than 1 MB :: ${file_size}
    Run    rm -rf ${TARGET_FILE}

Check Snapshot Without Error
    [Arguments]    ${snapshot}
    Log To Console    \n captured snapshot file: ${snapshot}
    Extract trbl log and check iq log    ${snapshot}    ${TARGET_ZIP_FILE_NAME}    ${EVENT_TARGET_FILE_NAME}
    Check L1 ERR and WRN in syslog

Get File Size From String
    [Arguments]    ${string}
    @{str_list}=    Split String    ${string}    ${SPACE}
    ${size}    Set Variable    ${str_list}[4]
    [Return]    ${size}

Check L1low And L1sw Logs In Snapshot
    [Arguments]    ${snapshot}
    ${build_info_dict}    Get L3 build from TargetBD file
    ${snapshot_documentation}    Get Snapshot Documentation    ${SUITE_LOG_DIRECTORY}    ${build_info_dict['PackageName']}
    ${documentation}    ${path}    Extract Target file From Compressed File    ${snapshot_documentation}    SBTS.*_trbl_log_list.csv
    check snapshot    avql    ${snapshot}    ${path}/${documentation}    bbu_type=THOR

Check Blind Capture IQ and 5gmax
    [Arguments]    ${L1IQ}
    ${isUploaded}    Run Keyword And Return Status    jenkins_upload_file_to_ROTTA    ${L1IQ}    ${ROTTA_PATH}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${L1IQ_name}    Split String From Right    ${L1IQ}    /    1

    # iq data analysis for UL
    ${isULAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${L1IQ_name}    local_file=${TEST_LOG_DIR}/archive_ul.zip    target_board=DU    event_trigger_only=False
    ...    is_72e_ul=True    is_72e_dl=False    slots_to_decode=20
    Should Be True    ${isULAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=False | is_72e_ul=True | is_72e_dl=False |.

    ${REQ_ul}    ${path1}    Extract Target file From Compressed File    compress_file=${TEST_LOG_DIR}/archive_ul.zip    target_startswith=REQ
    ...    target_endswith=REQ
    ${req_size}=    Get File Size    ${path1}/${REQ_ul}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} > 0    [ ERROR ] ${REQ_ul} size [ ${req_size} ] should be greater than 0.
    ${result}    Run    cat ${path1}/${REQ_ul} | grep ${Pusch_req_message}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${result}    [ERROR] ${Pusch_req_message} is NOT found in <REQ_ul>: ${result}.

    ${RESP_ul}    ${path2}    Extract Target file From Compressed File    compress_file=${TEST_LOG_DIR}/archive_ul.zip    target_startswith=RESP
    ...    target_endswith=RESP
    ${resp_size}=    Get File Size    ${path2}/${RESP_ul}
    Run Keyword And Continue On Failure    Should Be True    ${resp_size} > 0    [ ERROR ] ${RESP_ul} size [ ${resp_size} ] should be greater than 0.
    ${result}    Run    cat ${path2}/${RESP_ul} | grep ${Pusch_resp_crcok_message}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${result}    [ERROR]${Pusch_resp_crcok_message} is NOT found in <RESP_ul>:${result}
    # check 5gmax for UL
    ${pusch_bundled_summary.csv}    ${path2}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_ul.zip    target_startswith=pusch_bundled_summary.csv
    Check_UL_5Gmax    resp_file=${path2}/${RESP_ul}    bundled_summary_file=${path2}/${pusch_bundled_summary.csv}

    ${node_id}    Get Node Id    ABIP    thor_1
    ${Fcp_ecpri0.pcap}    ${path3}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_ul.zip    target_startswith=5G_UL_${node_id.strip('0x')}D_Fcp_ecpri*
    ${fcp_size}=    Get File Size    ${path3}/${Fcp_ecpri0.pcap}
    Run Keyword And Continue On Failure    Should Be True    ${fcp_size} > 0    [ ERROR ] ${Fcp_ecpri0.pcap} size [ ${fcp_size} ] == 0.

    ${dl_ecpri1.pcap}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_ul.zip    target_startswith=dl_ecpri*
    ${dl_pcap_size}=    Get File Size    ${path4}/${dl_ecpri1.pcap}
    Run Keyword And Continue On Failure    Should Be True    ${dl_pcap_size} > 0    [ ERROR ] ${dl_ecpri1.pcap} size [${dl_pcap_size}] == 0.

    ${ul.pcap}    ${path5}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_ul.zip    target_startswith=UL_${node_id.strip('0x')}D_IqSamples_ecpri
    ${ul.pcap_size}=    Get File Size    ${path4}/${ul.pcap}
    Run Keyword And Continue On Failure    Should Be True    ${ul.pcap_size} > 0    [ ERROR ] ${ul.pcap} size [ ${ul.pcap_size} ] should be > 0.

    # iq data analysis for DL
    ${isDLAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${L1IQ_name}    local_file=${TEST_LOG_DIR}/archive_dl.zip    target_board=DU    event_trigger_only=False
    ...    is_72e_ul=False    is_72e_dl=True    slots_to_decode=20
    Should Be True    ${isDLAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=False | is_72e_ul=False | is_72e_dl=True |.

    ${REQ_dl}    ${path1}    Extract Target file From Compressed File    compress_file=${TEST_LOG_DIR}/archive_dl.zip    target_startswith=REQ
    ...    target_endswith=REQ
#    ${req_size}=    Get File Size    ${path1}/${REQ_dl}
#    Run Keyword And Continue On Failure    Should Be True    ${req_size} > 0    [ ERROR ] ${REQ_dl} size [ ${req_size} ] should be greater than 0.
    ${result}    Run    cat ${path1}/${REQ_dl} | grep ${Pdsch_req_message}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${result}    [ERROR] ${Pdsch_req_message} is NOT found in <REQ_dl>: ${result}.

    ${snapshot}    ${path2}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_dl.zip    target_startswith=snapshot
    ${IqSamples.bin}    ${path3}    Extract Target file From Compressed File
    ...    compress_file=${path2}/${snapshot}    target_startswith=${node_id.strip('0x')}D_IqSamples
    ${IqSamples.bin_size}=    Get File Size    ${path3}/${IqSamples.bin}
    Run Keyword And Continue On Failure    Should Be True    ${IqSamples.bin_size} > 0
    ...    [ ERROR ] ${IqSamples.bin} size [ ${IqSamples.bin_size} ] should be > 0.

    ${RESP_dl}    ${path4}    Extract Target file From Compressed File    compress_file=${TEST_LOG_DIR}/archive_dl.zip    target_startswith=RESP
    ...    target_endswith=RESP
    ${resp_size}=    Get File Size    ${path4}/${RESP_dl}
    Run Keyword And Continue On Failure    Should Be True    ${resp_size} > 0    [ ERROR ] ${RESP_dl} size [ ${resp_size} ] should be greater than 0.

    # check 5gmax for DL
    ${pdsch_summary.csv}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_dl.zip    target_startswith=PDSCH_summary.csv
    Check_Dl_5Gmax    bundled_summary_file=${path4}/${pdsch_summary.csv}

Check NrDlPhyEvenPdschReTxBler Event IQ and 5gmax
    [Arguments]    ${snapshot}
    ${isUploaded}    Run Keyword And Return Status    jenkins_upload_file_to_ROTTA    ${snapshot}    ${ROTTA_PATH}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1

    # iq data analysis for DL DU
    ${rotta_link}    Set Variable    ${ROTTA_PATH}/${snapshot_name}
    Run Keyword If    ${isUploaded}    Check parsed DL event IQ data    rotta_link=${rotta_link}
    ...    target_board=DU    archived_zip=archive_du.zip

    # iq data analysis for DL RU
    Run Keyword If    ${isUploaded}    Check parsed DL event IQ data    rotta_link=${rotta_link}
    ...    target_board=rfsrm7-thor    archived_zip=archive_ru.zip

Check parsed DL event IQ data
    [Arguments]    ${rotta_link}    ${target_board}    ${archived_zip}
    ${isAnalyzed}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${rotta_link}    local_file=${TEST_LOG_DIR}/${archived_zip}
    ...    target_board=${target_board}    event_trigger_only=True    is_72e_ul=False    is_72e_dl=True
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=False | is_72e_ul=False | is_72e_dl=True |.

    ${REQ}    ${path1}    Extract Target file From Compressed File    compress_file=${TEST_LOG_DIR}/${archived_zip}    target_startswith=REQ
    ${req_size}=    Get File Size    ${path1}/${REQ}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} > 0    [ ERROR ] ${REQ} size [ ${req_size} ] should be greater than 0.

Check fcpTriggeredCapture logs for blind mode IQ
    [Arguments]    ${blind_iq_log}

    ${output_path}    Set Variable    ${TEST_LOG_DIR}/output
    ${merged_achived_iq}    Set Variable    ${TEST_LOG_DIR}/output/blind_iq.tar.gz

    Create Directory    ${output_path}
    ${result}    search_and_extract_files_from_archive    ${blind_iq_log}    ${BLIND_TARGET_FILE_NAMES}     ${output_path}

    FOR    ${pattern}    ${target}    IN    &{result}
        FOR    ${fname}    ${info}    IN    &{target}
            log to console    ${fname}
            log to console    ${info}
            Should Be True    ${info}[size]>1000    [ ERROR ] ${fname} size [ ${info}[size] ] is less than 1000 KB.
        END
    END
    # Remove Directory    ${output_path}    True
