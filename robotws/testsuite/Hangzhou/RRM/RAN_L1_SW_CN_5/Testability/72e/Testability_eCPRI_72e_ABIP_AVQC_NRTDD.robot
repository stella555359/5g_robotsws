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

Resource          ../../resources/common_resources.robot
Library          ../../resources/python/tracefastdecoder_wrapper.py


*** Variables ***
@{ALLOWED_FAULT}    8101
${scf_72e_file}      Testability_ABIP_1xAVQC_NRTDD_1xNRCEL_72e_${btsid}.xml
${MAX_SIZE}     ${104857600}
#MAX_SIZE is 102400KB,equal to 104857600bytes

${MIN_SIZE}     ${1024}
${IQ_PCAP_MIN_SIZE}     ${10}
${ROTTA_PATH}    //eseefsn50.emea.nsn-net.net/rotta4internal/LTE_2/7_2e_regression

&{bts_PA_dict}    10386=&{PA_dict_10386}    11148=&{PA_dict_11148}    10994=&{PA_dict_10994}
&{PA_dict_10386}    ip=10.108.241.5     init_value=1:10;2:10;3:10;4:10    target_value=1:60;2:60;3:60;4:60
...    rank_2to1_value=1:60;2:60;3:60;4:120
&{PA_dict_11148}    ip=10.108.241.44    init_value=1:35;3:35;5:35;7:35     target_value=1:85;3:85;5:85;7:85
...    rank_2to1_value=1:60;4:60;7:60;10:120
&{PA_dict_10994}    ip=10.108.228.24    init_value=13:30;14:30;15:30;16:30     target_value=13:120;14:120;15:120;16:120
...    rank_2to1_value=13:70;14:70;15:70;16:120    bler_value=13:80;14:80;15:80;16:80

@{DU_EVENT_TARGET_FILE_NAMES}    NrFine_slot    nrSnapshotEventLog.bin
${RU_EVENT_TARGET_ZIP_NAMES}     fcpTriggeredCapture_thor.tar.gz
@{RU_EVENT_TARGET_FILE_NAMES}    fcpTriggeredCapture_*_rxArray*_FD_PUxCH.bin
@{RU_EVENT_TARGET_FILE_NAMES_SRS}    fcpTriggeredCapture_*_rxArray*_FD_SRS.bin
@{RU_EVENT_TARGET_FILE_NAMES_UL_PROFILE_1}    fcpTriggeredCapture_*_rxArray3_0_*.bin    fcpTriggeredCapture_*_rxArray3_1_*.bin
...    fcpTriggeredCapture_*_rxArray3_2_*.bin    fcpTriggeredCapture_*_rxArray3_3_*.bin

@{TC25_IQ_FILE_IN_SNAPSHOT}    124D_l1a_contIqSnapshotBuffer    fcpTriggeredCapture_.*\.bin
@{DLUL_FD_POSTBF_IQ}    fcpTriggeredCapture_.*\.bwv    fcpTriggeredCapture_.*\.hb
@{IQ_DATA_ANALYZER_FILE_NAME}    fcpTriggeredCapture_.*\.bin\.pcap    ecpri_du_.*\.bin\.pcap
@{IQ_FILE_NAME}    fcpTriggeredCapture_.*\.bin
@{UL_BLIND_IQ_FILE_NAMES}    124D_IqSamples.bin    5G_UL_124D_Fcp.bin
@{DL_BLIND_IQ_FILE_NAMES}    124D_IqSamples.bin    5G_DL_124D_Fcp.bin

*** Test Cases ***
Testability_TC16_CB007595_E_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_RU_L1_RT_application_crash
    [Tags]    SMAwave    CB007595_E    CB009170_G    72e    Crash_RU    Testability    Trunk    QL3    TC16
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}

    # Added some ERR in {L1_ERR_whitelist} for crash testing -- ERR/ctrlNrUlSrs::logIdSrsRespPs ... No fragment received
    Append To List    ${L1_ERR_whitelist}    FH response missing cellPs    No fragment received
    # during RU reset No fragment received is ok, but not normaly during onair according to PR857614
    connect_and_execute_command_on_ru    AVQC      ssh -t serviceuser@192.168.101.17 'sudo kill -s SEGV $(pgrep -f l1_application_rt)'
    sleep    60s
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    ${snapshot}    Save Snapshot Via WebUI
    Check RU L1 RT application crash Log    ${snapshot}
    Check MRI Message    ${snapshot}
    [Teardown]    Run Keywords    Append To List    ${ALLOWED_FAULT}    10    4590    # crash is triggerd in case, fault-10 and 4590 will be raised.
    ...    AND    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${ALLOWED_FAULT}    10    4590
    ...    AND    Remove Values From List    ${L1_ERR_whitelist}    FH response missing cellPs    No fragment received

Testability_TC17_CB009514_KB_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_RU_MHAB_crash
    [Tags]    SMAwave    CB007595_E    CB009170_G    72e    MHAB_RU    Testability    Trunk    QL3    TC17
    ## PR846643::WA to disable RU power on reset function, need to add a fime named por_executed in RU mars: /mnt/runtime/por_executed
    Connect And Execute Command On Ru    AVQC    sudo touch /mnt/runtime/por_executed

    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}

    # Added some ERR in {L1_ERR_whitelist} for crash testing -- ERR/ctrlNrUlSrs::logIdSrsRespPs ... No fragment received
    Append To List    ${L1_ERR_whitelist}    FH response missing cellPs    No fragment received
    connect_and_execute_command_on_ru    AVQC     ssh -t serviceuser@192.168.101.17 'sudo devmem 0X87E040041D00 64 1'
    sleep    60s
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    ${snapshot}    Save Snapshot Via WebUI
    Check MHAB crash Log    ${snapshot}
    search_and_extract_files_from_archive    ${snapshot}    l1_journal.txt    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_*_PSMLog_ctrl.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_*_PSMLog_entries.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    historyBufferL1CommonMabLog1    ${TEST_LOG_DIR}
    Check MRI Message    ${snapshot}
    [Teardown]    Run Keywords    Append To List    ${ALLOWED_FAULT}    10    4590    # crash is triggerd in case, fault-10 and 4590 will be raised.
    ...    AND    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${ALLOWED_FAULT}    10    4590
    ...    AND    Remove Values From List    ${L1_ERR_whitelist}    FH response missing cellPs    No fragment received

Testability_TC21_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_IQ_Capture_event_based_SrsNonDtx_CP1_A
    [Tags]    SMAwave    CB007595_D    CB009170_G    72e    event_iq_capture    Testability    Trunk    QL3    TC21
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}
    SMAwave L3 call with SrsNonDtx event IQ capture    150M    150M    5G    78

Testability_TC22_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_IQ_Capture_event_based_PuschTbCrcFailedWithReTx_CP1_A
    [Tags]    SMAwave    CB007595_D    CB009170_G    72e    event_iq_capture    Testability    Trunk    QL3    TC22
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}

    &{CommonPhy_dict}    Create Dictionary    name=nbOfEventsToTrigAutoBTSSnapshot    value=1
    &{NrUlPhy_dict_1}    Create Dictionary    name=enableRespCapture    value=290
    &{NrUlPhy_dict_2}    Create Dictionary    name=puschConsecutiveHarqTransmissionThreshold    value=2
    &{NrUlPhy_dict_3}    Create Dictionary    name=phyEventEnable    value=32
    @{CommonPhy_list}    Create List    ${CommonPhy_dict}
    @{NrUlPhy_list}    Create List    ${NrUlPhy_dict_1}    ${NrUlPhy_dict_2}    ${NrUlPhy_dict_3}
    ${RAD_debug_paras_dict}    Create Dictionary    CommonPhy=${CommonPhy_list}    NrUlPhy=${NrUlPhy_list}

    SMAwave L3 call with 5G event IQ capture    10M    10M    5G    78    ${RAD_debug_paras_dict}    UL_PROFILE_2    PuschTbCrcFailedWithReTx

Testability_TC23_CB009514_KB_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_RU_MDAB_crash
    [Tags]    SMAwave    CB007595_E    CB009170_G    CB009514_KD    72e    MDAB_RU    Testability    Trunk    QL3Daily    TC23
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}
    Log To Console    [INFO] start to get ru debug paramters
    ${output}=    get_ru_rad_debug_parameters    MRBTS-10994/EQM-1/APEQM-1/RMOD-1
    ${param_names}=    Create List    COMMON_ARM    COMMON_CEVA
    ${values}=    Get Ru Rad Param Current Value    ${output}    ${param_names}
    Should Be Equal    ${values['COMMON_ARM']}    3    [ERROR] COMMON_ARM currentValue is not '3 - Info'!
    Should Be Equal    ${values['COMMON_CEVA']}    3    [ERROR] COMMON_CEVA currentValue is not '3 - Info'!
    ${param1}=    Create Dictionary    name=COMMON_ARM    value=1    persistency=NotPersistent
    ${param2}=    Create Dictionary    name=COMMON_CEVA    value=1    persistency=NotPersistent
    ${param_list}=    Create List    ${param1}    ${param2}
    Log To Console    [INFO] start to modify ru debug paramters
    Set RU RAD Debug Parameters With L1 Domain    MRBTS-10994/EQM-1/APEQM-1/RMOD-1    @{param_list}
    SMAwave UE attach    rat=5G    cell_id=None    band=78
    SMAwave Start Data Traffic    1200M    200M    udp    1000
    ${onair_time}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%S
    connect_and_execute_command_on_ru    AVQC     ssh -t serviceuser@192.168.101.17 'sudo devmem 0x87E044701600 64 1'
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    SMAwave Verify throughput for DL and UL    1200M    200M    60%    5G    78
    ${output}    Message Should Exist In Syslog File    regexp=Fault2941    alias=enb_testSetup
    ${snapshot}    Save Snapshot Via WebUI
    search_and_extract_files_from_archive    ${snapshot}    l1_journal.txt    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_00004000_PSMLog_ctrl.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_00004000_PSMLog_entries.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_00004000_copyMdabCrashBuffer.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    historyBufferL1CommonMabLog1    ${TEST_LOG_DIR}
    # Check MHAB crash Log    ${snapshot}    # it's not needed after L1-mdabautohealing enabled(CB009514)
    # Check MRI Message    ${snapshot}    # not needed after L1-mdabautohealing enabled
    @{all_log_paths}=    Get All l1_runtime Log Paths From Snapshot    ${snapshot}    ${TEST_LOG_DIR}
    Check No Keyword After Time    ${all_log_paths}    handleMdabFatalError    /INF RT    ${onair_time}
    [Teardown]    Run Keywords    Append To List    ${L1_ERR_whitelist}    FH response missing for subcellIndex
    ...    FH response missing cellPs    logIdCrashHandling
    ...    AND    SMAwave Stop Data And Detach
    ...    AND    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${L1_ERR_whitelist}    FH response missing for subcellIndex
    ...    FH response missing cellPs    logIdCrashHandling

Testability_TC25_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_IQ_Capture_event_based_rdAbnormalEventRlfEnabled_CP0_4
    [Tags]    SMAwave    Testability    72e    Trunk    QL3    CB007595_D    TC25
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}
    SMAwave L3 call with rdAbnormalEventRlfEnabled event IQ capture    1200M    200M    5G    78
    [Teardown]    Run Keywords    Append To List    ${L1_WRN_whitelist}    Snapshot is not configured for subcellIndex
    ...    AND    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${L1_ERR_whitelist}    Snapshot is not configured for subcellIndex

Testability_TC31_CB009514_KB_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_DU_MDAB_crash
    [Tags]    ABIP    SMAwave    Trunk    QL3Daily    TC31
    Append To List    ${L1_ERR_whitelist}    logIdCrashHandling
    Append To List    ${L1_WRN_whitelist}    preparePuschRespPs    checkPuschExpiredEvents    Setting it to EM_EVENT_UNDEF
    ${swconfig_flags}    Create Dictionary    0x87002A=1
    modify swconfig file    ${swconfig_flags}
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}
    SMAwave UE attach    rat=5G    cell_id=None    band=78
    SMAwave Start Data Traffic    100M    20M    udp    2000
    #SMAwave Verify throughput for DL and UL    100M    20M    30%    5G    78
    execute command on BTS via ssh    rm /tmp/RD.BTS* /tmp/PM.BTS*
    connect_and_execute_command_on_bbmod    ABIP    thor_1    devmem 0x87E044701600 64 1
    Check Autohealing In Logs
    SMAwave Verify throughput for DL and UL    100M    20M    30%    5G    78
    ${snapshot}    Save Snapshot Via WebUI
    search_and_extract_files_from_archive    ${snapshot}    l1_journal.txt    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_*_PSMLog_ctrl.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_*_PSMLog_entries.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_*_copyMdabCrashBuffer.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    historyBufferL1CommonMabLog1    ${TEST_LOG_DIR}
    [Teardown]    Run keywords    SMAwave Stop Data And Detach    AND    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${L1_ERR_whitelist}    logIdCrashHandling
    ...    AND    Remove Values From List    ${L1_WRN_whitelist}    preparePuschRespPs    checkPuschExpiredEvents    Setting it to EM_EVENT_UNDEF

Testability_TC18_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_IQ_Capture_blind_mode_UL_CP1_6
    [Tags]    SMAwave    CB009514_KC    72e    blind_iq_capture    Testability    Trunk    QL3    TC18
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}
    SMAwave L3 call with 5G blind IQ capture    500M    135M    5G    78    UL_PROFILE_1

Testability_TC32_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_IQ_Capture_blind_mode_UL_CP1_A_B
    [Tags]    SMAwave    CB009514_KC    72e    blind_iq_capture    Testability    Trunk    QL3    TC32
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}
    SMAwave L3 call with 5G blind IQ capture    500M    135M    5G    78    UL_PROFILE_2

Testability_TC33_CB009514_KC_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_IQ_Capture_blind_mode_DL_CP0_4
    [Tags]    SMAwave    CB009514_KC    72e    blind_iq_capture    Testability    Trunk    QL3    TC33
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}
    SMAwave L3 call with 5G blind IQ capture    500M    135M    5G    78    DL_PROFILE_1

Testability_TC37_CB009514_KD_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_L1_Radio_Fronthaul_Statistics_Counters
    [Tags]    SMAwave    CB009514_KD    72e    Testability    Trunk    QL3    TC37
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    ${onair_time}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%S
    Sleep    30s
    ${snapshot}    Save Snapshot Via WebUI
    @{all_log_paths}=    Get All l1_runtime Log Paths From Snapshot    ${snapshot}    ${TEST_LOG_DIR}/step1
    FOR    ${runtime_log_path}    IN    @{all_log_paths}
        ${rfoe_rx}=    Grep debug paramters In l1_runtime File    ${runtime_log_path}    dumpRfoePktLogRxEntry
        Check Log After Time    ${rfoe_rx}    ${onair_time}    dumpRfoePktLogRxEntry    False
        ${rfoe_tx}=    Grep debug paramters In l1_runtime File    ${runtime_log_path}    dumpRfoePktLogTxEntry
        Check Log After Time    ${rfoe_tx}    ${onair_time}    dumpRfoePktLogTxEntry    False
        ${tx_stat}=    Grep debug paramters In l1_runtime File    ${runtime_log_path}    printRpmTxLmac
        Check Log After Time    ${tx_stat}    ${onair_time}    printRpmTxLmac    False
        ${rx_stat}=    Grep debug paramters In l1_runtime File    ${runtime_log_path}    printEthernetIfRxStat
        Check Log After Time    ${rx_stat}    ${onair_time}    printEthernetIfRxStat    False
    END
    Log To Console    [INFO] start to get ru debug paramters
    ${output}=    get_ru_rad_debug_parameters    MRBTS-10994/EQM-1/APEQM-1/RMOD-1
    ${param_names}=    Create List    FH_RFOE_TRACE    FH_ECPRI_STATS
    ${values}=    Get Ru Rad Param Current Value    ${output}    ${param_names}
    Should Be Equal    ${values['FH_RFOE_TRACE']}    0    [ERROR] FH_RFOE_TRACE currentValue is not '0 - Disabled'!
    Should Be Equal    ${values['FH_ECPRI_STATS']}    0    [ERROR] FH_ECPRI_STATS currentValue is not '0 - Disabled'!
    ${param1}=    Create Dictionary    name=FH_RFOE_TRACE    value=5    persistency=NotPersistent
    ${param2}=    Create Dictionary    name=FH_ECPRI_STATS    value=4    persistency=NotPersistent
    ${param_list}=    Create List    ${param1}    ${param2}
    Log To Console    [INFO] start to modify ru debug paramters
    Set RU RAD Debug Parameters With L1 Domain    MRBTS-10994/EQM-1/APEQM-1/RMOD-1    @{param_list}
    Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
    ${onair_time2}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%S
    Sleep    60s
    ${snapshot2}    Save Snapshot Via WebUI
    ${all_log_paths}=    Get All l1_runtime Log Paths From Snapshot    ${snapshot2}    ${TEST_LOG_DIR}/step2
    Log To Console    [INFO] start to check log print Interval
    FOR    ${log_path}    IN    @{all_log_paths}
        ${grep_result1}=    Grep debug paramters In l1_runtime File    ${log_path}    printRpmTxLmac
        check_log_print_interval_after_time    ${grep_result1}    30    ${onair_time2}
        ${grep_result2}=    Grep debug paramters In l1_runtime File    ${log_path}    printEthernetIfRxStat
        check_log_print_interval_after_time    ${grep_result2}    30    ${onair_time2}
        ${grep_result3}=    Grep debug paramters In l1_runtime File    ${log_path}    dumpRfoePktLogRxEntry
        check_log_print_interval_after_time    ${grep_result3}    10    ${onair_time2}
        ${grep_result4}=    Grep debug paramters In l1_runtime File    ${log_path}    dumpRfoePktLogTxEntry
        check_log_print_interval_after_time    ${grep_result4}    10    ${onair_time2}
    END

Testability_TC38_CB009514_KD_NR_FR1_TDD_eCPRI_ABIP_AVQC_72e_L1_Radio_BF_Trace_Collection
    [Tags]    SMAwave    CB009514_KD    72e    Testability    Trunk    QL3    TC38
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}
    Log To Console    [INFO] start to get ru debug paramters
    ${output}=    get_ru_rad_debug_parameters    MRBTS-10994/EQM-1/APEQM-1/RMOD-1
    ${param_names}=    Create List    DL_BF_TRACE    UL_BF_TRACE
    ${values}=    Get Ru Rad Param Current Value    ${output}    ${param_names}
    Should Be Equal    ${values['DL_BF_TRACE']}    0    [ERROR] DL_BF_TRACE currentValue is not '0 - Disabled'!
    Should Be Equal    ${values['UL_BF_TRACE']}    0    [ERROR] UL_BF_TRACE currentValue is not '0 - Disabled'!
    ${param1}=    Create Dictionary    name=DL_BF_TRACE    value=1    persistency=NotPersistent
    ${param2}=    Create Dictionary    name=UL_BF_TRACE    value=3    persistency=NotPersistent
    ${param_list}=    Create List    ${param1}    ${param2}
    Log To Console    [INFO] start to modify ru debug paramters
    Set RU RAD Debug Parameters With L1 Domain    MRBTS-10994/EQM-1/APEQM-1/RMOD-1    @{param_list}
    SMAwave UE attach    rat=5G    cell_id=None    band=78
    SMAwave Start Data Traffic    1200M    0M    udp    1000
    Sleep    30s
    SMAwave Stop Data And Detach
    SMAwave UE attach    rat=5G    cell_id=None    band=78
    SMAwave Start Data Traffic    0M    200M    udp    1000
    Sleep    30s
    ${snapshot}    Save Snapshot Via WebUI
    ${target_file}=    Get All l1trace Dat Paths From Snapshot    ${snapshot}    ${TEST_LOG_DIR}
    ${decoded_results}=    Decode All l1trace Files    ${target_file}    ${TEST_LOG_DIR}
    [Teardown]    Run Keywords    SMAwave Stop Data And Detach
    ...    AND    common_resource_suite.Common Test Teardown

Testability_TC39_NR_FR1_TDD_eCPRI_ABIP_72e_several_times_RU_MDAB_crash
    [Tags]    ABIP    72e    Trunk    QL3    TC39    Testability
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Testability/${scf_72e_file}
    connect_and_execute_command_on_ru    AVQC     ssh -t serviceuser@192.168.101.17 'sudo devmem 0x87E044701600 64 1'
    sleep    60s
    Check If All Cells Are OnAir
    connect_and_execute_command_on_ru    AVQC     ssh -t serviceuser@192.168.101.17 'sudo devmem 0X87E044E01600 64 1'
    sleep    60s
    Check If All Cells Are OnAir
    sleep    600s
    connect_and_execute_command_on_ru    AVQC     ssh -t serviceuser@192.168.101.17 'sudo devmem 0x87E044701600 64 1'
    sleep    60s
    Check If All Cells Are OnAir
    ${output}    Message Should Exist In Syslog File    regexp=Fault2941    alias=enb_testSetup
    ${snapshot}    Set Variable    ${None}
    ${snapshot}    Save Snapshot Via WebUI
    Check crash log file size    ${snapshot}
    search_and_extract_files_from_archive    ${snapshot}    l1_journal.txt    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_00004000_PSMLog_ctrl.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_00004000_PSMLog_entries.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    ID_00004000_copyMdabCrashBuffer.bin    ${TEST_LOG_DIR}
    search_and_extract_files_from_archive    ${snapshot}    historyBufferL1CommonMabLog1    ${TEST_LOG_DIR}
    [Teardown]    Run Keywords    Append To List    ${L1_ERR_whitelist}    FH response missing cellPs
    ...    AND    common_resource_suite.Common Test Teardown
    ...    AND    Remove Values From List    ${L1_ERR_whitelist}    FH response missing cellPs

*** Keywords ***
Check crash log file size
    [Arguments]    ${snapshot}
    ${crash_tgz}    ${path0}    Extract Target file From Compressed File
    ...    compress_file=${snapshot}    target_startswith=RMOD_L_1_2011_l1a_crash.tgz
    ${file_size}=    Get File Size    ${path0}/${crash_tgz}
    Log    File size is: ${file_size}
    Run Keyword And Continue On Failure    Should Be True    ${MAX_SIZE} > ${file_size} > 0
    ...    [ ERROR ] ${crash_tgz} size [file_size] should be greater than 0 and lesser than MAX_SIZE.

Check Autohealing In Logs
    #${output}    Message Should Exist In Syslog File    regexp=FaultDetector9101    alias=enb_testSetup
    #ute_syslog.Message Should Exist In Syslog File    regexp=FaultDetector9101    alias=enb_testSetup
    verify NUM of RDCounter

verify NUM of RDCounter
    Log To Console    [ INFO ] check RDcounter value
    ${RD_counter_file}=    Get RD Counter File    15
    ${DSP_L1_AUTO_HEALING_BTS}=    get_counter_value_from_counter_file    ${RD_counter_file}    DSP_L1_AUTO_HEALING_BTS
    Should Be True    ${DSP_L1_AUTO_HEALING_BTS} >= 1    [ ERROR ] ${DSP_L1_AUTO_HEALING_BTS} is 0.

Get RD Counter File
    [Arguments]    ${refresh_period}
    ${remain_time}=    get_counter_file_remaining_time    counter_refresh_period=${refresh_period}min

    ${sleep_time}=    evaluate    ${remain_time}+30
    ## add 30s, in order to get the latest rd counter file correct
    Log To Console    \n[INFO]:Start to get latest RD file, Waiting ${sleep_time}s ...
    sleep    ${sleep_time}
    ${rd_counter_file}=    Download RD counter file    local_path=${TEST_LOG_DIR}/
    [Return]    ${rd_counter_file}

Download RD counter file
    [Arguments]    ${local_path}=${TEST_LOG_DIR}
    Log To Console    [ INFO ] Downloading latest RD.BTS*.ANY.xml.gz
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/RD.BTS*.ANY.xml.gz ${local_path}
    Run    gunzip ${local_path}/RD.BTS*.gz
    ${isExist}    Run    ls ${local_path}/RD.BTS*.ANY.xml
    File Should Exist    ${isExist}    [ ERROR ] [ RD.BTS*.ANY.xml ] is NOT found in [ ${local_path} ]
    [Return]    ${isExist}

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
    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][bler_value]
    Wait Until Keyword Succeeds    150s    30s    Check If Alarm Appeared    8101
    ${snapshot}    Save Snapshot Via WebUI
    Restore IQ Event capture parameter

    Check Snapshot Without Error    ${snapshot}    ${selected_SuspiciousEvent}
    Run Keyword And Continue On Failure    Extract snapshot archives and check iq log    ${snapshot}
    ...    ${DLUL_FD_POSTBF_IQ}    ${TEST_LOG_DIR}    20
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
    ${NrUlPhy_list}    Set Variable    [{'name':'enableRespCapture', 'value': '16'}, {'name':'phyEventEnableExt', 'value': '16384'}]
    ${CommonPhy_list}    Set Variable    [{'name':'nbOfEventsToTrigAutoBTSSnapshot', 'value': '1'}]
    &{RAD_debug_paras_dict}    Create Dictionary    CommonPhy=${CommonPhy_list}    NrUlPhy=${NrUlPhy_list}
    ADMIN Set Multiple RAD debug parameters    CommonPhy    ${RAD_debug_paras_dict}[CommonPhy]
    ADMIN Set Multiple RAD debug parameters    NrUlPhy    ${RAD_debug_paras_dict}[NrUlPhy]

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
    ...    AND    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]

Restore IQ Event capture parameter
    ADMIN Reset All Rad Debug Parameters
    Sleep    10s
    Disable IQ capture via webUI
    Run    cd ${SUITE_LOG_DIRECTORY}; rm -rf *.bin *D_l1a_up_trace.tgz *fcpTriggeredCapture_thor.tar.gz *_part*.zip

IQ Event capture configuration
    [Arguments]    ${profile_prefix}
    ${ul_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 1][7-2e]NRCELL-0: Subcell 0
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
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive_du.zip    target_board=DU    event_trigger_only=True
    ...    is_72e_ul=True    is_72e_dl=False
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=True | is_72e_dl=False |.

    Run Keyword If    '${profile_prefix.upper()}' in ('UL_PROFILE_1', 'DL_PROFILE_1')    Check ecpri.pcap file    ${TEST_LOG_DIR}/archive_du.zip
    ...    ELSE    Log To Console    [ WARN ] No ecpri_xx.pcap file for ${profile_prefix}, only to be checked for UL_PROFILE_1 or DL_PROFILE_1.
    Extract snapshot archives and check iq log    ${TEST_LOG_DIR}/archive_du.zip    ${IQ_DATA_ANALYZER_FILE_NAME}[1]
    ...    ${TEST_LOG_DIR}    ${IQ_PCAP_MIN_SIZE}
    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_du.zip    target_startswith=RESP
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_du.zip   target_startswith=REQ
    ${resp_size}    Get File Size    ${path1}/${resp_txt}
    Run Keyword And Continue On Failure    Should Be True    ${resp_size} > 0    The file size should be greater than 0
    ${req_size}    Get File Size    ${path2}/${req_txt}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} >0    The file size should be greater than 0

    ${msg}    Run    cat ${path1}/${resp_txt} | grep UlData_PuschReceiveRespPs_t.subcells\\\\[0\\\\].grants.*.crc\\ =\\ 0x01\\ =\\ 1

    Run Keyword And Continue On Failure    Should Not Be Empty    ${msg}

    ${pusch_bundled_summary.csv}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_du.zip    target_startswith=pusch_bundled_summary.csv
    Check_UL_5Gmax    resp_file=${path1}/${resp_txt}    bundled_summary_file=${path4}/${pusch_bundled_summary.csv}

Check RU IQ
    [Arguments]    ${snapshot}    ${isUploaded}=${False}    ${profile_prefix}=UL_PROFILE_1
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive_ru.zip    target_board=rfsrm7-thor
    ...    event_trigger_only=True    is_72e_ul=True    is_72e_dl=False    iq_data_analyzer_branch=master
    ...    branch_5gmax=master
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=True | is_72e_dl=False |.

    Run Keyword If    '${profile_prefix.upper()}' in ('UL_PROFILE_1', 'DL_PROFILE_1')    Check ecpri.pcap file    ${TEST_LOG_DIR}/archive_ru.zip
    ...    ELSE    Log To Console    [ WARN ] No ecpri_xx.pcap file for ${profile_prefix}, only to be checked for UL_PROFILE_1 or DL_PROFILE_1.
    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_ru.zip    target_startswith=RESP_RU
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_ru.zip   target_startswith=REQ_RU
    ${msg1}    Run    cat ${path1}/${resp_txt} | grep UlDataFH_PuschReceiveRespCellPs
    Should Not Be Empty    ${msg1}    [ERROR] ${msg1} is NOT found in <resp_txt>
    ${msg2}    Run    cat ${path2}/${req_txt} | grep UlDataFH_PuschReceiveReq_t
    Should Not Be Empty    ${msg2}    [ERROR] ${msg2} is NOT found in <req_txt>

    ${pusch_bundled_summary.csv}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_ru.zip    target_startswith=pusch_bundled_summary.csv
    Check_UL_5Gmax    resp_file=${path1}/${resp_txt}    bundled_summary_file=${path4}/${pusch_bundled_summary.csv}


Check SrsNonDtx DU IQ
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
    #snr is not alignment between resp and 5gmax prase, need import user_defined_file
    #${snr_diff}=    Evaluate    abs(${snr_resp_value} - ${NrRxSrsMeasSinrDb_value})
    #Should Be True    ${snr_diff} <= 0.1


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
    ...    compress_file=${archive_zip}    target_startswith=ecpri.*.pcap
    ${file_size}=    Get File Size    ${path0}/${ecpri_bin_pcap}
    Log    File size is: ${file_size}
    Run Keyword And Continue On Failure    Should Be True    ${file_size} > 0
    ...    [ ERROR ] ${ecpri_bin_pcap} size [file_size] should be greater than 0

Restore swconfig
    &{swconfig_flags}    Create Dictionary    0x580357=0    0x58035c=0    0x580358=0
    modify swconfig file    ${swconfig_flags}

SMAwave L3 call with rdAbnormalEventRlfEnabled event IQ capture
    [Arguments]    ${dl_tput}    ${ul_tput}    ${rat}    ${band}
    ...    ${specific_UE_index}=UE_1    ${duration}=600    ${protocol}=udp
    ${bts_id}    Convert To String    ${bts_id}
    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}

    ${dl_subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 1][7-2e]NRCELL-0: Subcell 0
    ${random_antenna_group}      Evaluate    random.choice(['Group17', 'Group18'])    random
    ${antenna_list_group}    Create Dictionary    Antenna list=${random_antenna_group}
    Configure IQ capture via webUI    ul_subcell_index_list=${None}    dl_subcell_index_list=${dl_subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU and RU
    ...    profile_prefix=DL_PROFILE_1    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${antenna_list_group}

    &{L2PS_sub_dict_1}    Create Dictionary    name=rdAbnormalEventTriggerOnlineEnable    value=2
    &{L2PS_sub_dict_2}    Create Dictionary    name=rdAbnormalEventRlfEnabled    value=1
    &{L2PS_sub_dict_3}    Create Dictionary    name=rdAbnormalEventTriggerNumber    value=1
    @{L2PS_list}    Create List    ${L2PS_sub_dict_1}    ${L2PS_sub_dict_2}    ${L2PS_sub_dict_3}
    ADMIN Set Multiple RAD debug parameters    L2PS    ${L2PS_list}

    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][target_value]

    Sleep    40s
    ${snapshot}    Save Snapshot Via WebUI
    ${isUploaded}    Upload snapshot to ROTTA    ${snapshot}
    Run Keyword And Continue On Failure    Extract snapshot archives and check iq log    ${snapshot}
    ...    ${TC25_IQ_FILE_IN_SNAPSHOT}    ${TEST_LOG_DIR}    ${MIN_SIZE}
    Run Keyword And Continue On Failure    Extract snapshot archives and check iq log    ${snapshot}
    ...    ${DLUL_FD_POSTBF_IQ}    ${TEST_LOG_DIR}    20
    Run Keyword And Continue On Failure    Check DU CP0 IQ    ${snapshot}    ${isUploaded}
    Run Keyword And Continue On Failure    Check RU CP4 IQ    ${snapshot}    ${isUploaded}
    [Teardown]    Run keywords    SMAwave Stop Data And Detach
    ...    AND    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]

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
    Should Be True    ${file_size} > ${MIN_SIZE}    [ ERROR ] ${TARGET_FILE_NAMES} size [ ${file_size} ] should be greater than ${MIN_SIZE} KB
    Run    rm -rf ${TARGET_FILE}

Extract snapshot archives and check iq log
    [Arguments]    ${snapshot}    ${target_files}    ${output_dir}    ${min_size}
    ${is_list}=    Evaluate    isinstance($target_files, list)
    ${pattern_list}=    Run Keyword If    ${is_list}    Set Variable    ${target_files}
    ...    ELSE    Create List    ${target_files}
    ${output}=    search_and_extract_files_from_archive    ${snapshot}    ${pattern_list}    ${output_dir}
    FOR    ${pattern}    IN    @{pattern_list}
        ${file_dict}=    Get From Dictionary    ${output}    ${pattern}
        FOR    ${file_name}    IN    @{file_dict.keys()}
            ${file_info}=    Get From Dictionary    ${file_dict}    ${file_name}
            ${file_size}=    Get From Dictionary    ${file_info}    size
            ${output_path}=    Get From Dictionary    ${file_info}    output_path
            Run Keyword And Continue On Failure    Should Be True    ${file_size} > ${min_size}
            ...    [ ERROR ] ${file_name} size [ ${file_size} ] at [ ${output_path} ] should be greater than ${min_size} KB.
        END
    END

Check RU CP4 IQ
    [Arguments]    ${snapshot}    ${isUploaded}=${False}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive_ru.zip    target_board=rfsrm7-thor
    ...    event_trigger_only=False    is_72e_ul=False    is_72e_dl=True    iq_data_analyzer_branch=master
    ...    branch_5gmax=master
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=False | is_72e_ul=False | is_72e_dl=True |.
    Extract snapshot archives and check iq log    ${TEST_LOG_DIR}/archive_ru.zip    ${IQ_DATA_ANALYZER_FILE_NAME}[0]
    ...    ${TEST_LOG_DIR}    ${MIN_SIZE}
    ${REQ_dl}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_ru.zip   target_startswith=REQ
    ${msg1}    Run    cat ${path2}/${REQ_dl} | grep DlDataFH_PdschSendReq
    Should Not Be Empty    ${msg1}    [ERROR] ${msg1} is NOT found in <REQ_dl>
    ${msg2}    Run    cat ${path2}/${REQ_dl} | grep DlDataFH_PdcchSendReq
    Should Not Be Empty    ${msg2}    [ERROR] ${msg2} is NOT found in <REQ_dl>
    # check 5gmax for DL
    ${pdsch_summary.csv}    ${path3}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_ru.zip    target_startswith=PDSCH_summary.csv
    Check_Dl_5Gmax    bundled_summary_file=${path3}/${pdsch_summary.csv}

Check DU CP0 IQ
    [Arguments]    ${snapshot}    ${isUploaded}=${False}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive_du.zip    target_board=DU    event_trigger_only=False
    ...    is_72e_ul=False    is_72e_dl=True
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=False | is_72e_ul=False | is_72e_dl=True |.
    ${REQ_dl}    ${path1}    Extract Target file From Compressed File    compress_file=${TEST_LOG_DIR}/archive_du.zip    target_startswith=REQ
    ${msg1}    Run    cat ${path1}/${REQ_dl} | grep DlData_PdschSendReq
    Should Not Be Empty    ${msg1}    [ERROR] ${msg1} is NOT found in <REQ_dl>
    # check 5gmax for DL
    ${pdsch_summary.csv}    ${path3}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_du.zip    target_startswith=PDSCH_summary.csv
    Check_Dl_5Gmax    bundled_summary_file=${path3}/${pdsch_summary.csv}

SMAwave L3 call with 5G blind IQ capture
    [Arguments]    ${dl_tput}    ${ul_tput}    ${rat}    ${band}    ${profile_prefix}=UL_PROFILE_1
    ...    ${specific_UE_index}=UE_1    ${duration}=600    ${protocol}=udp
    ${bts_id}    Convert To String    ${bts_id}
    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]
    SMAwave UE attach    rat=${rat}    cell_id=None    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    common_resource_bts.ADMIN Set Multiple RAD debug parameters    NrUlPhy    [{'name':'enableRespCapture', 'value': '34'}]
    IQ blind capture configuration    profile_prefix=${profile_prefix}

    SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    10%    5G
    ${L1IQ}    Save IQ capture data via webUI
    ${blind_iq_file_name}    Set Variable If    '${profile_prefix.upper()}' in ('UL_PROFILE_1','UL_PROFILE_2')    ${UL_BLIND_IQ_FILE_NAMES}
    ...    ${DL_BLIND_IQ_FILE_NAMES}
    Check fcpTriggeredCapture logs for blind mode IQ    ${L1IQ}    ${blind_iq_file_name}
    Extract L1_IQ_Capture and check size    ${L1IQ}    @{IQ_FILE_NAME}
    ${isUploaded}    Run Keyword And Return Status    jenkins_upload_file_to_ROTTA    ${L1IQ}    ${ROTTA_PATH}
    Run Keyword If    '${profile_prefix.upper()}' in ('UL_PROFILE_1','UL_PROFILE_2')
    ...    Run Keyword And Continue On Failure    Check Blind UL DU IQ    ${L1IQ}    ${isUploaded}
    ...    ELSE    Run Keyword And Continue On Failure    Check Blind DL DU IQ    ${L1IQ}    ${isUploaded}
    [Teardown]    Run Keywords    SMAwave Stop Data And Detach
    ...    AND    Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]    ${bts_PA_dict}[${bts_id}][init_value]

Check Blind UL DU IQ
    [Arguments]    ${L1IQ}    ${isUploaded}=${False}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${L1IQ_name}    Split String From Right    ${L1IQ}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${L1IQ_name}    local_file=${TEST_LOG_DIR}/archive_du.zip    target_board=DU    event_trigger_only=False
    ...    is_72e_ul=True    is_72e_dl=False
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=False | is_72e_ul=True | is_72e_dl=False |.

    ${node_id}    Get Node Id    ABIP    thor_1
    ${ul.pcap}    ${path5}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_du.zip    target_startswith=UL_${node_id.strip('0x')}D_IqSamples_ecpri
    ${ul.pcap_size}=    Get File Size    ${path5}/${ul.pcap}
    Run Keyword And Continue On Failure    Should Be True    ${ul.pcap_size} > 0    [ ERROR ] ${ul.pcap} size [ ${ul.pcap_size} ] should be > 0.

    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_du.zip    target_startswith=RESP
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_du.zip   target_startswith=REQ
    ${resp_size}    Get File Size    ${path1}/${resp_txt}
    Run Keyword And Continue On Failure    Should Be True    ${resp_size} > 0    The file size should be greater than 0
    ${req_size}    Get File Size    ${path2}/${req_txt}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} >0    The file size should be greater than 0
    ${pusch_bundled_summary.csv}    ${path4}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_du.zip    target_startswith=pusch_bundled_summary.csv
    Check_UL_5Gmax    resp_file=${path1}/${resp_txt}    bundled_summary_file=${path4}/${pusch_bundled_summary.csv}
    Run    mv ${TEST_LOG_DIR}/archive_du.zip ${TEST_LOG_DIR}/archived_du.zip

Check Blind DL DU IQ
    [Arguments]    ${L1IQ}    ${isUploaded}=${False}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${L1IQ_name}    Split String From Right    ${L1IQ}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${L1IQ_name}    local_file=${TEST_LOG_DIR}/archive_du.zip    target_board=DU    event_trigger_only=False
    ...    is_72e_ul=False    is_72e_dl=True    iq_data_analyzer_branch=master    branch_5gmax=master    slots_to_decode=10
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=False | is_72e_ul=False | is_72e_dl=True |.

    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${TEST_LOG_DIR}/archive_du.zip   target_startswith=REQ
    ${req_size}    Get File Size    ${path2}/${req_txt}
    Run Keyword And Continue On Failure    Should Be True    ${req_size} >0    The file size should be greater than 0
    ${pdsch_summary.csv}    ${path3}    Extract Target file From Compressed File
    ...    compress_file=${TEST_LOG_DIR}/archive_du.zip    target_startswith=PDSCH_summary.csv
    Check_Dl_5Gmax    bundled_summary_file=${path3}/${pdsch_summary.csv}
    Run    mv ${TEST_LOG_DIR}/archive_du.zip ${TEST_LOG_DIR}/archived_du.zip

Extract L1_IQ_Capture and check size
    [Arguments]    ${file_path}    ${IQ_FILE_NAME}
    ${target_patterns}     Create List    l1radio_fcpTriggeredCapture_thor\.tar\.gz\.a*
    Create Directory    ${TEST_LOG_DIR}/output
    ${result}    search_and_extract_files_from_archive    ${file_path}    ${target_patterns}     ${TEST_LOG_DIR}/output
    ${merged}    Run    cat ${TEST_LOG_DIR}/output/* > ${TEST_LOG_DIR}/output/test.tar.gz
    ${result}    search_and_extract_files_from_archive    ${TEST_LOG_DIR}/output/test.tar.gz    ${IQ_FILE_NAME}     ${TEST_LOG_DIR}/output
    log to console    ${result}
    FOR    ${pattern}    ${target}    IN    &{result}
        log to console    ${pattern}
        FOR    ${fname}    ${info}    IN    &{target}
            log to console    ${fname}
            should be true    ${info}[size]>10000    [ ERROR ] ${fname} size [ ${info}[size] ] is less than 20000 KB.
            log to console    ${info}[output_path]
        END
    END
    Remove Directory    ${TEST_LOG_DIR}/output    True

Check fcpTriggeredCapture logs for blind mode IQ
    [Arguments]    ${blind_iq_log}    ${BLIND_IQ_NAMES}

    ${output_path}    Set Variable    ${TEST_LOG_DIR}/output
    ${merged_achived_iq}    Set Variable    ${TEST_LOG_DIR}/output/blind_iq.tar.gz

    Create Directory    ${output_path}
    ${result}    search_and_extract_files_from_archive    ${blind_iq_log}    ${BLIND_IQ_NAMES}     ${output_path}

    FOR    ${pattern}    ${target}    IN    &{result}
        FOR    ${fname}    ${info}    IN    &{target}
            log to console    ${fname}
            log to console    ${info}
            Should Be True    ${info}[size]>1000    [ ERROR ] ${fname} size [ ${info}[size] ] is less than 1000 KB.
        END
    END
    Remove Directory    ${TEST_LOG_DIR}/output    True

IQ blind capture configuration
    [Arguments]    ${profile_prefix}
    ${subcell_index_list}=    Create List    [BBMOD_R-1(ABIP)] [PCI: 1][7-2e]NRCELL-0: Subcell 0
    ${random_antenna_group}      Evaluate    random.choice(['Group17', 'Group18'])    random
    ${list_group}    Create Dictionary    Antenna list=${random_antenna_group}
    ${antenna_list_group}    Set Variable If    '${profile_prefix.upper()}' in ('UL_PROFILE_1','UL_PROFILE_2')    ${None}    ${list_group}
    ${ul_subcell_index_list}    Set Variable If    '${profile_prefix.upper()}' in ('UL_PROFILE_1','UL_PROFILE_2')    ${subcell_index_list}    ${None}
    ${dl_subcell_index_list}    Set Variable If    '${profile_prefix.upper()}' in ('UL_PROFILE_1','UL_PROFILE_2')    ${None}    ${subcell_index_list}
    Configure IQ capture via webUI    ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${dl_subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Blind    capture_from=BBU and RU
    ...    profile_prefix=${profile_prefix}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${antenna_list_group}

Decode All l1trace Files
    [Arguments]    ${target_file}    ${test_log_dir}
    ${list_length}=    Get Length    ${target_file}
    Should Be True    ${list_length} > 0    No l1trace .dat files found in snapshot
    ${decoded_results}=    Create List
    FOR    ${index}    IN RANGE    ${list_length}
        ${dat_file}=    Get From List    ${target_file}    ${index}
        ${result}=    Decode Target File    ${TEST_LOG_DIR}/${dat_file}
        Append To List    ${decoded_results}    ${result}
        Log    Completed decoding file ${index + 1}: ${result}
        ${txt_file}=    Replace String    ${result}    .dat    .txt
        Run Keyword If    ${index} != 0    Check File Size Greater Than 10K    ${txt_file}
    END
    [Return]    ${decoded_results}
    [Teardown]    Run Keyword And Ignore Error    Remove Files    ${TEST_LOG_DIR}/../*_thor.tar.gz
    ...    ${TEST_LOG_DIR}/../BTS_part*.zip

Set RU RAD Debug Parameters With L1 Domain
    [Arguments]    ${target_ru}    @{param_dicts}
    ${domain}=    Create Dictionary    domainName=L1    parameters=@{param_dicts}
    ${domains}=    Create List    ${domain}
    ${result}=    Set RU RAD Debug Parameters    ${target_ru}    ${domains}
    [Return]    ${result}

Get All l1_runtime Log Paths From Snapshot
    [Arguments]    ${snapshot}    ${TEST_LOG_DIR}
    ${target_log_list}    ${root_path}    Get Target Logs From Snapshot    ${snapshot}    l1-runtime.tar.gz
    ${isCompressedIn_BTS_Part_X}    Set Variable If    'BTS_part' in '${target_log_list[0]}'    True    False
    ${target_zip}    ${first_path}    Extract Target file From Compressed File    ${snapshot}    ${target_log_list}[0]
    ${senond_file}    ${second_path}    Run Keyword If    ${isCompressedIn_BTS_Part_X}
    ...    Extract Target file From Compressed File    ${first_path}/${target_zip}    l1-runtime.tar.gz
    ...    ELSE    Set Variable    ${target_zip}    ${first_path}
    ${result}    ${original_paths}=    search_and_extract_files_with_original_paths    ${second_path}/${senond_file}
    ...    l1_runtime.log    ${TEST_LOG_DIR}
    Log To Console    Found original files: ${original_paths}
    ${file_dict}=    Get From Dictionary    ${result}    l1_runtime.log
    ${paths}=    Create List
    FOR    ${fname}    IN    @{file_dict.keys()}
        Log    Checking file name: '${fname}'
        ${pattern}=    Set Variable    ^l1_runtime\\.log(\\.\\d+)?$
        ${is_match}=    Run Keyword And Return Status    Should Match Regexp    ${fname.strip()}    ${pattern}
        IF    ${is_match}
            ${file_info}=    Get From Dictionary    ${file_dict}    ${fname}
            ${output_path}=    Get From Dictionary    ${file_info}    output_path
            Append To List    ${paths}    ${output_path}
        END
    END
    [Return]    ${paths}
    [Teardown]    Run Keyword And Ignore Error    Remove Files    ${first_path}/${target_zip}
    ...    ${second_path}/${senond_file}

Get l1_runtime.log Path From Snapshot
    [Arguments]    ${snapshot}
    ${output}=    search_and_extract_files_from_archive    ${snapshot}    l1_runtime.log    ${TEST_LOG_DIR}
    ${file_dict}=    Get From Dictionary    ${output}    l1_runtime.log
    ${file_info}=    Get From Dictionary    ${file_dict}    l1_runtime.log
    ${log_path}=    Get From Dictionary    ${file_info}    output_path
    [Return]    ${log_path}

Grep debug paramters In l1_runtime File
    [Arguments]    ${file_path}    ${parameter}
    ${result}=    Run    grep ${parameter} ${file_path}
    [Return]    ${result}

Get All l1trace Dat Paths From Snapshot
    [Arguments]    ${snapshot}    ${TEST_LOG_DIR}
    ${target_log_list}    ${root_path}=    Get Target Logs From Snapshot    ${snapshot}    l1radio_rt_l1trace
    ${all_dat_paths}=    Create List
    FOR    ${tar_file}    IN    @{target_log_list}
        ${isCompressedIn_BTS_Part_X}    Set Variable If    'BTS_part' in '${tar_file}'    True    False
        ${target_zip}    ${first_path}=    Extract Target file From Compressed File    ${snapshot}    ${tar_file}
        IF    ${isCompressedIn_BTS_Part_X}
            ${second_file_var}    ${second_path}=    Extract Target file From Compressed File
            ...    ${first_path}/${target_zip}    l1radio_rt_l1trace    ${EMPTY}    all
        ELSE
            ${second_file_var}    ${second_path}=    Set Variable    ${target_zip}    ${first_path}
        END

        ${second_file_var}=    Set Variable    ${second_file_var}
        FOR    ${sfile}    IN    @{second_file_var}
            ${result}    ${original_paths}=    search_and_extract_files_with_original_paths
            ...    ${second_path}/${sfile}    l1trace.*\\.dat    ${TEST_LOG_DIR}
            FOR    ${path}    IN    @{original_paths}
                    Append To List    ${all_dat_paths}    ${path}
            END
        END
    END
    [Return]    ${all_dat_paths}

Check File Size Greater Than 10K
    [Arguments]    ${file_path}
    ${file_size}=    Get File Size    ${file_path}
    Should Be True    ${file_size} > 10240    File size of ${file_path} is less than 10K!
