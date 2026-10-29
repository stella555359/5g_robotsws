*** Settings ***
Documentation
...    Author:  liang.kong
...    Contact: liang.kong@nokia-sbell.com
...    Feature: CB007595
...    Release: 24R3
...    CB007595 is only to enable Ecpri72eUL. But it's not available because the actEcpri72e is enabled as cell level.
...    The configuration will be replaced by CB009170-G(Ecpri72eULDL).

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown

Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

Resource          ../resources/common_resources.robot

*** Variables ***
@{ALLOWED_FAULT}    8101
${scf_72e_file}      CB007595_ABIP_AVQL_NRTDD_100M_A1_gscn_636666_1xNRCELL_${btsid}.xml
${scf_72a_file}      ABIP_AVQL_NRTDD_100M_A1_gscn_636666_1xNRCELL_72a_${btsid}.xml

@{DU_EVENT_TARGET_FILE_NAMES}    NrFine_slot    nrSnapshotEventLog.bin
${RU_TARGET_ZIP_FILE_NAME}    fcpTriggeredCapture_thor.tar.gz
@{RU_EVENT_TARGET_FILE_NAMES}    fcpTriggeredCapture_*_rxArray*_FD_PUxCH.bin
@{RU_EVENT_TARGET_FILE_NAMES_UL_PROFILE_1}    fcpTriggeredCapture_*_rxArray3_0_*.bin    fcpTriggeredCapture_*_rxArray3_1_*.bin
...    fcpTriggeredCapture_*_rxArray3_2_*.bin    fcpTriggeredCapture_*_rxArray3_3_*.bin
${MIN_SIZE}     ${1024}
${ROTTA_PATH}    //eseefsn50.emea.nsn-net.net/rotta4internal/LTE_2/7_2e_regression
&{bts_PA_dict}    10386=&{PA_dict_10386}    11148=&{PA_dict_11148}
&{PA_dict_10386}    ip=10.108.241.5     init_value=1:10;2:10;3:10;4:10    target_value=1:60;2:60;3:60;4:60
...    rank_2to1_value=1:60;2:60;3:60;4:120
&{PA_dict_11148}    ip=10.108.241.44    init_value=1:35;3:35;5:35;7:35     target_value=1:85;3:85;5:85;7:85
...    rank_2to1_value=1:60;4:60;7:60;10:120

*** Test Cases ***
CB007595_C_TC01_NR_FR1_TDD_eCPRI_ABIP_72e_Basic_L3_call
    [Tags]    ABIP    SMAwave    CB007595_C    CB009170_G    72e    Trunk    QL3    TC01
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file}
    SMAwave L3 call    cell_id=1    dl_tput=1200M    ul_tput=155M    dl_deviation=10%    rat=5G    band=78    specific_UE_index=UE_1    duration=60

Testability_TC15_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_event_based_PuschNonMsg3CrcFailed_CP1_6
    [Tags]    SMAwave    CB009514_KC    CB009170_G    72e    event_iq_capture    Testability    Trunk    QL3    TC15
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file}

    ${CommonPhy_list}    Set Variable    [{'name': 'nbOfEventsToTrigAutoBTSSnapshot', 'value': '1'}]
    ${NrUlPhy_list}    Set Variable    [{'name': 'enableRespCapture', 'value': '290'}, {'name': 'phyEventEnable', 'value': '512'}]
    ${RAD_debug_paras_dict}    Create Dictionary    CommonPhy=${CommonPhy_list}    NrUlPhy=${NrUlPhy_list}

    SMAwave L3 call with 5G event IQ capture    10M    150M    5G    78    ${RAD_debug_paras_dict}    UL_PROFILE_1    PuschNonMsg3CrcFailed

Testability_TC16_CB007595_E_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_RU_L1_RT_application_crash
    [Documentation]    To be deprecated due to executing on another testline.
    [Tags]    SMAwave    CB007595_E    CB009170_G    72e    Crash_RU    Testability    Trunk    QL3    TC16
    Log    [ WARN ] [Deprecation Warning] case to be executed on another testline.    WARN
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file}
    Append To List    ${L1_ERR_whitelist}    FH response missing for subcellIndex    FH response missing cellPs
    connect_and_execute_command_on_ru    AVQL      ssh -t serviceuser@192.168.101.17 'sudo kill -s SEGV $(pgrep -f l1_application_rt)'
    sleep    60s
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    ${snapshot}    Save Snapshot Via WebUI
    Check RU L1 RT application crash Log    ${snapshot}
    Check MRI Message    ${snapshot}
    [Teardown]    Run Keywords    Append To List    ${ALLOWED_FAULT}    10    4590    # crash is triggerd in case, fault-10 and 4590 will be raised.
    ...    AND    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${ALLOWED_FAULT}    10    4590
    ...    AND    Remove Values From List    ${L1_ERR_whitelist}    FH response missing for subcellIndex    FH response missing cellPs

Testability_TC17_CB007595_E_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_RU_MHAB_crash
    [Documentation]    To be deprecated due to executing on another testline.
    [Tags]    SMAwave    CB007595_E    CB009170_G    72e    MHAB_RU    Testability    Trunk    QL3    TC17
    Log    [ WARN ] [Deprecation Warning] case to be executed on another testline.    WARN
    ## PR846643::WA to disable RU power on reset function, need to add a fime named por_executed in RU mars: /mnt/runtime/por_executed
    Connect And Execute Command On Ru    AVQL    sudo touch /mnt/runtime/por_executed
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file}
    Append To List    ${L1_ERR_whitelist}    FH response missing for subcellIndex    FH response missing cellPs
    connect_and_execute_command_on_ru    AVQL     ssh -t serviceuser@192.168.101.17 'sudo devmem 0X87E040041D00 64 1'
    sleep    60s
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    ${snapshot}    Save Snapshot Via WebUI
    Check MHAB crash Log    ${snapshot}
    Check MRI Message    ${snapshot}
    [Teardown]    Run Keywords    Append To List    ${ALLOWED_FAULT}    10    4590    # crash is triggerd in case, fault-10 and 4590 will be raised.
    ...    AND    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${ALLOWED_FAULT}    10    4590
    ...    AND    Remove Values From List    ${L1_ERR_whitelist}    FH response missing for subcellIndex    FH response missing cellPs

Testability_TC21_CB007595_D_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_event_trigger_SrsNonDtx
    [Documentation]    To be deprecated due to executing on another testline.
    [Tags]    SMAwave    CB007595_D    CB009170_G    72e    event_iq_capture    Testability    Trunk    QL3    TC21
    Log    [ WARN ] [Deprecation Warning] case to be executed on another testline.    WARN
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file}
    SMAwave L3 call with SrsNonDtx event IQ capture    150M    150M    5G    78

Testability_TC22_CB007595_D_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_event_trigger_PuschTbCrcFailedWithReTx
    [Documentation]    To be deprecated due to executing on another testline.
    [Tags]    SMAwave    CB007595_D    CB009170_G    72e    event_iq_capture    Testability    Trunk    QL3    TC22
    Log    [ WARN ] [Deprecation Warning] case to be executed on another testline.    WARN
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file}

    &{CommonPhy_dict}    Create Dictionary    name=nbOfEventsToTrigAutoBTSSnapshot    value=1
    &{NrUlPhy_dict_1}    Create Dictionary    name=enableRespCapture    value=290
    &{NrUlPhy_dict_2}    Create Dictionary    name=puschConsecutiveHarqTransmissionThreshold    value=2
    &{NrUlPhy_dict_3}    Create Dictionary    name=phyEventEnable    value=32
    @{CommonPhy_list}    Create List    ${CommonPhy_dict}
    @{NrUlPhy_list}    Create List    ${NrUlPhy_dict_1}    ${NrUlPhy_dict_2}    ${NrUlPhy_dict_3}
    ${RAD_debug_paras_dict}    Create Dictionary    CommonPhy=${CommonPhy_list}    NrUlPhy=${NrUlPhy_list}

    SMAwave L3 call with 5G event IQ capture    10M    10M    5G    78    ${RAD_debug_paras_dict}    UL_PROFILE_2    PuschTbCrcFailedWithReTx

Testability_TC23_CB007595_E_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_RU_MDAB_crash
    [Documentation]    To be deprecated due to executing on another testline.
    [Tags]    SMAwave    CB007595_E    CB009170_G    72e    MDAB_RU    Testability    Trunk    QL3    TC23
    Log    [ WARN ] [Deprecation Warning] case to be executed on another testline.    WARN
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file}
    Append To List    ${L1_ERR_whitelist}    FH response missing for subcellIndex    logIdCrashHandling/0x37000004    FH response missing cellPs
    connect_and_execute_command_on_ru    AVQL     ssh -t serviceuser@192.168.101.17 'sudo devmem 0x87E044701600 64 1'
    sleep    60s
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    ${snapshot}    Save Snapshot Via WebUI
    # Check MHAB crash Log    ${snapshot}    # it's not needed after L1-mdabautohealing enabled(CB009514)
    # Check MRI Message    ${snapshot}    # not needed after L1-mdabautohealing enabled
    [Teardown]    Run Keywords    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${L1_ERR_whitelist}
    ...    FH response missing for subcellIndex    logIdCrashHandling/0x37000004    FH response missing cellPs

Testability_TC24_CB007595_D_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_UL_FD_IQ_with_RAD_para
    [Tags]    SMAwave    CB007595_D    TC24    72e    Testability    Trunk    QL3    event_iq_capture
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file}
    SMAwave UE attach    rat=5G    cell_id=None    band=78    specific_UE_index=UE_1
    SMAwave Start Data Traffic    100M    20M    udp    1000
    LMI eth on
    LMI Execute Command via ssh    commands=sudo ccsShell.sh rad -mw 0xA6000B 0x828    passed_tag=written succesfully    ip=192.168.101.17
    ...    username=serviceuser    password=f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=

    ${response}    LMI Execute Command via ssh    commands=ls -l /ram/l1radio/*    passed_tag=l1trace0.dat    ip=192.168.101.17
    ...    username=serviceuser    password=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=

    SMAwave Verify throughput for DL and UL    100M    20M    10%    5G    78

    ## Check the iq logs, it should be 4 files and size shoulb be same and in [10240 : 214000000] ##
    # ${iq_local_path}    Set Variable    ${TEST_LOG_DIR}/bin
    # Run    mkdir ${iq_local_path}

    # LMI Transfer Files    remote=/ram/l1radio/*.bin    local=${iq_local_path}    operation=download
    # ...    ip=192.168.101.17    username=serviceuser    password=kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=

    # Check RU FD IQ logs    file_min_size=10240    file_max_size=214000000    iq_local_path=${iq_local_path}

    ${file_min_size}    ${file_max_size}    Set Variable    10240    214000000
    ${PATTERN}    Set Variable    \\s+(\\d+)\\s+\\w+\\s+\\d+\\s[\\d:-]+\\s/ram/l1radio/(l1radio_iq_capture_0[^\\s]+\.bin)

    ${sizes_dict}    Evaluate    {m.group(2): int(m.group(1)) for m in re.finditer(r'''${PATTERN}''', """${response}""")}
    ${size_list}    Get Dictionary Values   ${sizes_dict}
    ${size_set}    Remove Duplicates    ${size_list}
    ${number_of_set}    Get Length    ${size_set}
    Should Be True    ${number_of_set} == 1    [ ERROR ] The bin files are NOT the same size : ${sizes_dict}
    Should Be True    ${file_min_size} <= ${size_set}[0] <= ${file_max_size}
    ...    [ ERROR ] the bin size [${size_set}[0]] should be in [ ${file_min_size} : ${file_max_size}]


Testability_TC26_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_event_based_NrPucchFormat1DtxAtGoodSinr_CP1_6
    [Tags]    SMAwave    CB009514_KC    TC26    72e    Testability    Trunk    QL3    event_iq_capture
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file}
    SMAwave L3 call with NrPucch DtxAtGoodSinr event IQ capture    NrPucchFormat1DtxAtGoodSinr    1200M    0M    5G    78

Testability_TC27_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_IQ_Capture_event_based_NrPucchFormat3DtxAtGoodSinr_CP1_6
    [Tags]    SMAwave    CB009514_KC    TC27    72e    Testability    Trunk    QL3    event_iq_capture
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB007595/${scf_72e_file}
    SMAwave L3 call with NrPucch DtxAtGoodSinr event IQ capture    NrPucchFormat3DtxAtGoodSinr    1200M    0M    5G    78

*** Keywords ***
SMAwave L3 call with 5G event IQ capture
    [Arguments]    ${dl_tput}    ${ul_tput}    ${rat}    ${band}    ${RAD_debug_paras_dict}=${None}    ${profile_prefix}=UL_PROFILE_1
    ...    ${selected_SuspiciousEvent}=None    ${specific_UE_index}=UE_1    ${duration}=600    ${protocol}=udp
    ${bts_id}    Convert To String    ${bts_id}
    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}

    IQ Event capture configuration    profile_prefix=${profile_prefix}
    ADMIN Set Multiple RAD debug parameters    CommonPhy    ${RAD_debug_paras_dict}[CommonPhy]
    ADMIN Set Multiple RAD debug parameters    NrUlPhy    ${RAD_debug_paras_dict}[NrUlPhy]

    SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    15%    5G
    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][target_value]
    Wait Until Keyword Succeeds    150s    30s    Check If Alarm Appeared    8101
    ${snapshot}    Save Snapshot Via WebUI
    Restore IQ Event capture parameter

    Check Snapshot Without Error    ${snapshot}    ${selected_SuspiciousEvent}

    ${isUploaded}    Upload snapshot to ROTTA    ${snapshot}
    Run Keyword And Continue On Failure    Check DU IQ    ${snapshot}    ${isUploaded}    ${profile_prefix}
    Run Keyword And Continue On Failure    Check RU IQ    ${snapshot}    ${isUploaded}    ${profile_prefix}
    [Teardown]    Run Keywords    SMAwave Stop Data And Detach
    ...    AND    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]

SMAwave L3 call with SrsNonDtx event IQ capture
    [Arguments]    ${dl_tput}    ${ul_tput}    ${rat}    ${band}    ${specific_UE_index}=UE_1
    ...    ${duration}=600    ${protocol}=udp
    ${bts_id}    Convert To String    ${bts_id}
    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}

    IQ Event capture configuration    profile_prefix=UL_PROFILE_2
    ${rad_parameters_list}    Set Variable    [{'name':'enableRespCapture', 'value': '16'}, {'name':'phyEventEnableExt', 'value': '16384'}]
    ADMIN Set Multiple RAD debug parameters    NrUlPhy    ${rad_parameters_list}

    SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    15%    5G

    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][rank_2to1_value]
    Wait Until Keyword Succeeds    150s    30s    Check If Alarm Appeared    8101

    ${snapshot}    Save Snapshot Via WebUI
    Check Snapshot Without Error    ${snapshot}    SrsNonDtx
    Restore IQ Event capture parameter
    ${isUploaded}    Upload snapshot to ROTTA    ${snapshot}
    Run Keyword And Continue On Failure    Check SrsNonDtx RU IQ    ${snapshot}    ${isUploaded}
    Run Keyword And Continue On Failure    Check SrsNonDtx DU IQ    ${snapshot}    ${isUploaded}
    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]
    [Teardown]    Run Keywords    SMAwave Stop Data And Detach

SMAwave L3 call with NrPucch DtxAtGoodSinr event IQ capture
    [Arguments]    ${event_type}    ${dl_tput}    ${ul_tput}    ${rat}    ${band}    ${specific_UE_index}=UE_1
    ...    ${duration}=600    ${protocol}=udp
    Should Be True    '${event_type}' in ('NrPucchFormat1DtxAtGoodSinr', 'NrPucchFormat3DtxAtGoodSinr')
    ...    [ Error ] the ${event_type} should be NrPucchFormat1DtxAtGoodSinr | NrPucchFormat3DtxAtGoodSinr.

    ${event_id}    Set Variable If    '${event_type}'=='NrPucchFormat1DtxAtGoodSinr'    128    256
    ${bts_id}    Convert To String    ${bts_id}
    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    IQ Event capture configuration    profile_prefix=UL_PROFILE_1
    &{CommonPhy_dict}    Create Dictionary    name=nbOfEventsToTrigAutoBTSSnapshot    value=1
    &{NrUlPhy_dict_1}    Create Dictionary    name=enableRespCapture    value=12
    &{NrUlPhy_dict_2}    Create Dictionary    name=pucchGoodSinrThreshold    value=-15
    &{NrUlPhy_dict_3}    Create Dictionary    name=phyEventEnableExt    value=${event_id}
    @{CommonPhy_list}    Create List    ${CommonPhy_dict}
    @{NrUlPhy_list}    Create List    ${NrUlPhy_dict_1}    ${NrUlPhy_dict_2}    ${NrUlPhy_dict_3}
    ${RAD_debug_paras_dict}    Create Dictionary    CommonPhy=${CommonPhy_list}    NrUlPhy=${NrUlPhy_list}
    ADMIN Set Multiple RAD debug parameters    CommonPhy    ${RAD_debug_paras_dict}[CommonPhy]
    ADMIN Set Multiple RAD debug parameters    NrUlPhy    ${RAD_debug_paras_dict}[NrUlPhy]
    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][target_value]
    Wait Until Keyword Succeeds    150s    30s    Check If Alarm Appeared    8101
    ${snapshot}    Save Snapshot Via WebUI
    Restore IQ Event capture parameter
    Check Snapshot Without Error    ${snapshot}    ${event_type}
    ${isUploaded}    Upload snapshot to ROTTA    ${snapshot}
    Run Keyword And Continue On Failure    Check PucchDtxAtGoodSinr DU IQ    ${snapshot}    ${isUploaded}
    Run Keyword And Continue On Failure    Check PucchDtxAtGoodSinr RU IQ    ${snapshot}    ${isUploaded}
    [Teardown]    Run Keywords    SMAwave Stop Data And Detach    AND    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]
    ...    ${bts_PA_dict}[${bts_id}][init_value]

Check event trigger happen
    ${isTrigger}    Run Keyword And Return Status    ute_syslog.Message Should Exist In Syslog File
    ...    regexp=Detector 8101     alias=enb_testSetup
    Should Be True    ${isTrigger}    [ ERROR ] 'Detector 8101' is NOT filtered in syslog.

Restore IQ Event capture parameter
    ADMIN Reset All Rad Debug Parameters
    Sleep    10s
    Disable IQ capture via webUI
    Run    cd ${SUITE_LOG_DIRECTORY}; rm -rf *.bin *D_l1a_up_trace.tgz *fcpTriggeredCapture_thor.tar.gz *_part*.zip

IQ Event capture configuration
    [Arguments]    ${profile_prefix}
    ${ul_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 300][7-2e]NRCELL-1: Subcell 0
    Configure IQ capture via webUI     ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU and RU
    ...    profile_prefix=${profile_prefix}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}


Get File Size From String
    [Arguments]    ${string}
    @{str_list}=    Split String    ${string}    ${SPACE}
    ${size}    Set Variable    ${str_list}[4]
    [Return]    ${size}

Check Snapshot Without Error
    [Arguments]    ${snapshot}    ${selected_SuspiciousEvent}
    Log To Console    \n[INFO] captured snapshot file: ${snapshot}
    Extract trbl log and check du iq log    ${snapshot}    ${DU_EVENT_TARGET_FILE_NAMES}
    Extract trbl log and check ru iq log    ${snapshot}    ${selected_SuspiciousEvent}

Upload snapshot to ROTTA
    [Arguments]    ${snapshot}
    ${isUploaded}    Run Keyword And Return Status    jenkins_upload_file_to_ROTTA    ${snapshot}    ${ROTTA_PATH}
    [Return]    ${isUploaded}


Check DU IQ
    [Arguments]    ${snapshot}    ${isUploaded}=${False}    ${profile_prefix}=UL_PROFILE_1
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive.zip    target_board=DU    event_trigger_only=True
    ...    is_72e_ul=True    is_72e_dl=False
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=True | is_72e_dl=False |.

    Run Keyword If    '${profile_prefix.upper()}' in ('UL_PROFILE_1', 'DL_PROFILE_1')    Check ecpri.pcap file    ${TEST_LOG_DIR}/archive.zip
    ...    ELSE    Log To Console    [ WARN ] No ecpri_xx.pcap file for ${profile_prefix}, only to be checked for UL_PROFILE_1 or DL_PROFILE_1.

    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=RESP
    ...    target_endswith=RESP
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive.zip   target_startswith=REQ
    ...    target_endswith=REQ
    ${resp_size}    Get File Size    ${path1}/${resp_txt}
    Run Keyword And Continue On Failure    Should Be True    ${resp_size} > 0    The file size should be greater than 0
    ${req_size}    Get File Size    ${path2}/${req_txt}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} >0    The file size should be greater than 0

    ${msg}    Run    cat ${path1}/${resp_txt} | grep UlData_PuschReceiveRespPs_t.subcells\\\\[0\\\\].grants.*.crc\\ =\\ 0x01\\ =\\ 1

    Run Keyword And Continue On Failure    Should Not Be Empty    ${msg}

    ${pusch_bundled_summary.csv}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=pusch_bundled_summary.csv
    Check_UL_5Gmax    resp_file=${path1}/${resp_txt}    bundled_summary_file=${path4}/${pusch_bundled_summary.csv}

    Run    mv ${TEST_LOG_DIR}/archive.zip ${TEST_LOG_DIR}/archived_du.zip

Check RU IQ
    [Arguments]    ${snapshot}    ${isUploaded}=${False}    ${profile_prefix}=UL_PROFILE_1
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive.zip    target_board=rfsrm7-thor
    ...    event_trigger_only=True    is_72e_ul=True    is_72e_dl=False    iq_data_analyzer_branch=master
    ...    branch_5gmax=master
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=True | is_72e_dl=False |.

    Run Keyword If    '${profile_prefix.upper()}' in ('UL_PROFILE_1', 'DL_PROFILE_1')    Check ecpri.pcap file    ${TEST_LOG_DIR}/archive.zip
    ...    ELSE    Log To Console    [ WARN ] No ecpri_xx.pcap file for ${profile_prefix}, only to be checked for UL_PROFILE_1 or DL_PROFILE_1.

    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=RESP_RU
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive.zip   target_startswith=REQ_RU
    ${msg1}    Run    cat ${path1}/${resp_txt} | grep UlDataFH_PuschReceiveRespCellPs
    Should Not Be Empty    ${msg1}    [ERROR] ${msg1} is NOT found in <resp_txt>
    ${msg2}    Run    cat ${path2}/${req_txt} | grep UlDataFH_PuschReceiveReq
    Should Not Be Empty    ${msg2}    [ERROR] ${msg2} is NOT found in <req_txt>

    ${pusch_bundled_summary.csv}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=pusch_bundled_summary.csv
    Check_UL_5Gmax    resp_file=${path1}/${resp_txt}    bundled_summary_file=${path4}/${pusch_bundled_summary.csv}

    Run    mv ${TEST_LOG_DIR}/archive.zip ${TEST_LOG_DIR}/archived_ru.zip

Check PucchDtxAtGoodSinr DU IQ
    [Arguments]    ${snapshot}=None    ${isUploaded}=${True}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive.zip    target_board=DU    event_trigger_only=True
    ...    is_72e_ul=True    is_72e_dl=False
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=True | is_72e_dl=False |.

    Check ecpri.pcap file

    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=RESP
    ...    target_endswith=RESP
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive.zip   target_startswith=REQ
    ...    target_endswith=REQ
    ${resp_size}    Get File Size    ${path1}/${resp_txt}
    Run Keyword And Continue On Failure    Should Be True    ${resp_size} > 0    The file size should be greater than 0
    ${req_size}    Get File Size    ${path2}/${req_txt}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} >0    The file size should be greater than 0
    ${pucch_bundled_summary.csv}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=pucch_bundled_summary.csv
    Check_PUCCH_RESP    resp_file=${path1}/${resp_txt}    bundled_summary_file=${path4}/${pucch_bundled_summary.csv}

    Run    mv ${TEST_LOG_DIR}/archive.zip ${TEST_LOG_DIR}/archived_du.zip

Check PucchDtxAtGoodSinr RU IQ
    [Arguments]    ${snapshot}    ${isUploaded}=${False}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive.zip    target_board=rfsrm7-thor
    ...    event_trigger_only=True    is_72e_ul=True    is_72e_dl=False    iq_data_analyzer_branch=master
    ...    branch_5gmax=master
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=True | is_72e_dl=False |.

    Check ecpri.pcap file

    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=RESP_RU
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive.zip   target_startswith=REQ_RU
    ${msg1}    Run    cat ${path1}/${resp_txt} | grep UlData_PucchReceiveRespPsL1sw
    Should Not Be Empty    ${msg1}    [ERROR] ${msg1} is NOT found in <resp_txt>

    ${pucch_bundled_summary.csv}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive.zip    target_startswith=pucch_bundled_summary.csv
    Check_PUCCH_RESP    resp_file=${path1}/${resp_txt}    bundled_summary_file=${path4}/${pucch_bundled_summary.csv}

    Run    mv ${TEST_LOG_DIR}/archive.zip ${TEST_LOG_DIR}/archived_ru.zip

Check SrsNonDtx DU IQ
    [Arguments]    ${snapshot}    ${isUploaded}=${False}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive_du.zip    target_board=DU    event_trigger_only=True
    ...    is_72e_ul=True    is_72e_dl=False
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=True | is_72e_dl=False |.

    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_du.zip    target_startswith=RESP
    ...    target_endswith=RESP
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_du.zip   target_startswith=REQ
    ...    target_endswith=REQ
    ${resp_size}    Get File Size    ${path1}/${resp_txt}
    Run Keyword And Continue On Failure    Should Be True    ${resp_size} > 0    The file size should be greater than 0
    ${req_size}    Get File Size    ${path2}/${req_txt}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} >0    The file size should be greater than 0
    ${pattern1}    Set Variable    UlData_SrsReceiveRespPs_t.subcells\\\\[0\\\\].srsReceiveRespPsUes\\\\[0\\\\].dtx\\ =\\ 0x00\\ =\\ 0
    ${msg1}    Run    cat ${path1}/${resp_txt} | grep ${pattern1}
    Should Not Be Empty    ${msg1}    [ ERROR ] ${msg1} is NOT found in ${path1}/${resp_txt}
    # check CP1 IQ point on DU
    Check_SRS_SNR_RESP    resp_file=${path1}/${resp_txt}

Check SrsNonDtx RU IQ
    [Arguments]    ${snapshot}    ${isUploaded}=${False}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive_ru.zip    target_board=rfsrm7-thor
    ...    event_trigger_only=True    is_72e_ul=True    is_72e_dl=False    iq_data_analyzer_branch=master
    ...    branch_5gmax=master
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=True | is_72e_dl=False |.

    ## No ecpri_xx.pcap file for UL_PROFILE_2, only to be checked for UL_PROFILE_1 and DL_PROFILE_1
    # Check ecpri.pcap file

    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_ru.zip    target_startswith=RESP_RU
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_ru.zip   target_startswith=REQ_RU
    ${resp_size}    Get File Size    ${path1}/${resp_txt}
    Run Keyword And Continue On Failure    Should Be True    ${resp_size} > 0    The file size should be greater than 0
    ${req_size}    Get File Size    ${path2}/${req_txt}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} >0    The file size should be greater than 0
    # check CP6 IQ point on RU, will be available after sw update
    #${msg1}    Run    cat ${path1}/${resp_txt} | grep UlDataFH_SrsSuMimoReceiveRespPs_t.grants.*.dtx\\ =\\ 0x00\\ =\\ 0
    #Should Not Be Empty    ${msg1}    [ ERROR ] ${msg2} is NOT found in ${path1}/${resp_txt}

    # check 5gmax for SrsNonDtx
    ${srs_nondtx.dump}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_ru.zip    target_startswith=SrsNonDtx_01.dump
    ${NrRxMsmtSrsDtxDetect_value} =    Get_SRS_Dump_Value    ${path4}/${srs_nondtx.dump}    NrRxMsmtSrsDtxDetect
    ${NrRxMsmtSrsDtxDetect_int_value} =    Convert To Integer    ${NrRxMsmtSrsDtxDetect_value}
    Should Be True    ${NrRxMsmtSrsDtxDetect_int_value} == 0    The value of NrRxMsmtSrsDtxDetect is not equal as 0
    ${NrRxSrsMeasSinrDb_value} =    Get_SRS_Dump_Value    ${path4}/${srs_nondtx.dump}    NrRxSrsMeasSinrDb
    ${snr_dtx_results}=    Check SRS SNR RESP    resp_file=${path1}/${resp_txt}
    ${snr_resp_tuple}=    Get From List    ${snr_dtx_results}    0
    ${snr_resp_value}=    Get From List    ${snr_resp_tuple}    0
    ${snr_diff}=    Evaluate    abs(${snr_resp_value} - ${NrRxSrsMeasSinrDb_value})
    Should Be True    ${snr_diff} <= 0.1


Check RU L1 RT application crash Log
    [Arguments]    ${snapshot}
    ### Check the failurecollector_*_l1sw-rt-launcher_1.tar.gz
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    postmortem-part-3.tar
    ${postmortem_file}    ${path1}    Extract Target file From Compressed File    ${snapshot}    ${first_zip}[0]
    ${failurecollector_file}     ${path2}    Extract Target file From Compressed File     ${path1}/${postmortem_file}    failurecollector
    Run Keyword And Continue On Failure    File Should Exist    ${path2}/${failurecollector_file}
    ...    [ ERROR ] [ failurecollector_*_l1sw-rt-launcher_1.tar.gz ] is NOT EXIST in [ ${postmortem_file} -> ${failurecollector_file} ]

    ### Check the *RMOD_L_1_2011_rfsw-core-part0.tar.gz
    ${first_name}     ${path}     Get Target Logs From Snapshot    ${snapshot}    rfsw-core-part0
    Should Not Be Empty    ${first_name}    [ ERROR ] No Found [ *RMOD_L_1_2011_rfsw-core-part0.tar.gz ] in snapshot_files_list.txt
    IF    'BTS_part' in '${first_name}[0]'
        ${first_zip}    ${path2}    Extract Target file From Compressed File    ${snapshot}    ${first_name}[0]
        ${Coredump}    ${path3}    Extract Target file From Compressed File    ${path2}/${first_zip}    rfsw-core-part0
    ELSE
        ${Coredump}    ${path3}    Extract Target file From Compressed File    ${snapshot}    rfsw-core-part0
    END
    Run Keyword And Continue On Failure    File Should Exist    ${path3}/${Coredump}
    ...    [ ERROR ] No Found [ *RMOD_L_1_2011_rfsw-core-part0.tar.gz ] in [ ${Coredump} ]
    Run Keyword And Ignore Error    Remove Files    ${path1}/${postmortem_file}    ${path2}/${failurecollector_file}    ${path2}/${first_zip}
    ...    ${path3}/${Coredump}


Check MHAB crash Log
    [Arguments]    ${snapshot}
    ### Check the failurecollector_*_l1sw-rt-launcher_1.tar.gz
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    postmortem-part-3.tar
    ${postmortem_file}    ${path1}    Extract Target file From Compressed File    ${snapshot}    ${first_zip}[0]
    ${failurecollector_file}     ${path2}    Extract Target file From Compressed File     ${path1}/${postmortem_file}    failurecollector
    Run Keyword And Continue On Failure    File Should Exist    ${path2}/${failurecollector_file}
    ...    [ ERROR ] [ failurecollector_*_l1sw-rt-launcher_1.tar.gz ] is NOT EXIST in [ ${postmortem_file} -> ${failurecollector_file} ]

    ### Check the *RMOD_L_1_2011_rfsw-core-part0.tar.gz
    ${first_name}     ${path}     Get Target Logs From Snapshot    ${snapshot}    rfsw-core-part0
    Should Not Be Empty    ${first_name}    [ ERROR ] No Found [ *RMOD_L_1_2011_rfsw-core-part0.tar.gz ] in snapshot_files_list.txt
    IF    'BTS_part' in '${first_name}[0]'
        ${first_zip}    ${path2}    Extract Target file From Compressed File    ${snapshot}    ${first_name}[0]
        ${Coredump}    ${path3}    Extract Target file From Compressed File    ${path2}/${first_zip}    rfsw-core-part0
    ELSE
        ${Coredump}    ${path3}    Extract Target file From Compressed File    ${snapshot}    rfsw-core-part0
    END
    Run Keyword And Continue On Failure    File Should Exist    ${path3}/${Coredump}
    ...    [ ERROR ] No Found [ *RMOD_L_1_2011_rfsw-core-part0.tar.gz ] in [ ${Coredump} ]
    Run Keyword And Ignore Error    Remove Files    ${path1}/${postmortem_file}    ${path2}/${failurecollector_file}    ${path2}/${first_zip}
    ...    ${path3}/${Coredump}


Check MRI Message
    [Arguments]    ${snapshot}
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    UnitOAM_SOAP_Log.zip
    ${second_zip}    ${path1}    Extract Target file From Compressed File    ${snapshot}    ${first_zip}[0]
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    UnitOAM_SOAP_Log.zip
    ${forth_zip}     ${path3}    Extract Target file From Compressed File     ${path2}/${third_zip}    UnitOAM_SOAP_Startup_Autodetection_Log
    ${oam_soap_xml_gz}     ${path4}    Extract Target file From Compressed File     ${path3}/${forth_zip}    UnitOAM_SOAP_Startup_Autodetection_Log
    ${oam_soap_xml_info}    Run    gzip -l ${path4}/${oam_soap_xml_gz} | grep UnitOAM_SOAP_Startup_Autodetection_Log
    Run    gzip -df ${path4}/${oam_soap_xml_gz}
    ${mri_msg}    Run    cat ${path4}/${oam_soap_xml_info.split('/')[-1]} | grep SW_failure
    Run Keyword And Continue On Failure    Should Not Be Empty    ${mri_msg}
    Remove files    ${path2}/${third_zip}    ${path3}/${forth_zip}

Check ecpri.pcap file
    [Arguments]    ${archive_zip}=${TEST_LOG_DIR}/archive.zip
    ${ecpri_bin_pcap}    ${path0}    Extract Target file From Compressed File
    ...    compress_file=${archive_zip}    target_startswith=ecpri*    target_endswith=.pcap
    ${file_size}=    Get File Size    ${path0}/${ecpri_bin_pcap}
    Log    File size is: ${file_size}
    Run Keyword And Continue On Failure    Should Be True    ${file_size} > 0
    ...    [ ERROR ] ${ecpri_bin_pcap} size [file_size] should be greater than 0
