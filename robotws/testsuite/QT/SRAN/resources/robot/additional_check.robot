*** Settings ***
Documentation     This file is for logs check in QT test
Library     BuiltIn
Library     OperatingSystem
Library     Collections
Library     String
Library     ${CURDIR}/../python/str.py
Library     ${CURDIR}/../python/additional_check.py

*** Variables ***
@{snapshot_check_KW}    Error Handler exception report    ERR/CCS/AaError    ERR/CCS/AaPro   etc-ssl-certs.mount: Failed with result
...   Failed to verify signer certificate    EFaultId_BBBus_SyncError.*EFaultCause_Internal    ERR/Hlapi.*FAILED
...   ERR/Syscon/Mon    ERR/LTX/UOM_SWDL    ECpriSoapSender.*<status>fail    hwr-swdl.service: Watchdog timeout    ProbingTimeout
...   EFaultId_FrResetRequestedAl   EFaultId_NoFeedBackSignal   EFaultId_FrRfBbBusSynchError
...   ddal.*Input/output error    ERR/LTX/MED_Startup    ERR/Cprt
...   [[]err[]] kernel.*rcu_preempt    [[]err[]] trs-vpp    ERR/TRSW/TRSWSyslog.*trs-fastpath
...   ERR/LFS/LinuxSyslog.*CCSRTDaemonExe    ccs-rt.service.*ERR
...   [[]err[]] HWRSwDlSExe    ERR/swman    ERR/EXTLOG/DDAL.*No such file or directory    ERR/RTHWAPI/Daemon
...   terminate called after throwing an instance of.*Exception     WRN/BM/CLIC.*fan_detector
...   reporting non-critical fault    WRN/swman/swman_service    [[]warning[]] update_marvellfw.sh
...   BMU last reset reason.*timeout    ddal_reset_baseband_perform_k2_recovery    ERR/Draco/Wisdom
...   err.*ERR.*PMStat    ERR/LTX/UOAM_ECpriArrayRadio     Kernel panic    ERR/HWA/SUPERVISOR
...   Received reset request from.*because of.*failure
...   AAERROR_DIAGN_LOG_DETECTED_IND_MSG    <startupProblem>    BlackBoxLoggingService, Last reset
...   performing radio reset    createStaticResetInfoMO    ERR/MwCertMan.*throws exception    WRN/MwCertMan.*throws exception
...   WRN/l1_application_rt    L2Tupu.*ERR    ERR/LTX/MED_VirtConn    WRN/LTX/MED_VirtConn.*addResetInfoToMri
...   libreset reboot function has been disabled
@{skip_snapshot_check_KW}    AaProGetCommForEuId    AaProcDump    Failed to set timeout to    Failed to resolve unit specifiers in
...   ddal_sfp_read_file..*read failed    multimaster_recvmsg: read() error    Address was not found in MA Table
...   Timed out waiting for device sys-devices-virtual-net-rlan0   Failed to find module .nf.*    ERR/parseLine()
...   qat_asym does not support asymmetric crypto    cannot get flash info capability FSTYPE    cannot get mountpoint for partition
...   cfgExt.restore failed    handleTxFbPowerMeasurementRequest.*ReadyTimeout    validateBiasesAndPickCorrectValues
...   ddal_fpga_get_stored_version    dev-ddal-clock-board_00    bufferUnderflowCallback IRQ_BUFFER_UNDERFLOW_ALARM
...   We have ISSI flash    setup default values    1247 activated    check_sysref_detection NOK    Ubi container not available
...   WRN/swman/swman_service.*Unexpected msg    remount: failed for /ffs    remount: failed for /ffs    message repeated 2 times
...   Job nfs-trace.service/stop deleted to break ordering cycle starting with sysinit.target/stop
...   Failed unmounting run-netns-monitoring.mount    remount: failed     Carrier .* frequency is out of range
...   HandleTransactionPrepareResp    transaction failed    ddal_ssd_get_static_wear_leveling_status
...   AaProSystemRawReaderThread    Job generate-icom-hosts.service/stop deleted    ECpriArrayRadioManager.*execute failed
...   Current active slot is not aligned with active in system    ddal_security_is_secure_env    Register to AaTrbl failed
...   failed to request auth flag, mwcertman service address unknown    IRQ_BUFFER_UNDERFLOW_ALARM raised
...   /dev/ddal/subrack/product_code    ddal_subrack_get_string    ddal_utils_read_from_fd_no_intr    board_pwr_support
...   interface_version returned error   pthread_timedjoin_np failed    convert_ffs_role_to_id
...   GNSSReceiver.*GetInfo.*read error    HandlePollTimeout    MonitorTimer: Sync lost detected
...   No active subscribers for message UNIT_READY_IND_MSG    craverify.*Failed to verify signer certificate
...   <startupProblem>none    swman_service.*Filesystem type read failed    swman_service.*ubi    swman_service.*Ubi
...   swman_service.*Filesystem.*failed
@{L3Call_num_KW}    ERR/.uplane    WRN/.uplane/L2-PS    pkt discarded cause    ULPHY detect wrong preamble or HO sent too later
...    WRN/L2HiCu    PuschReceiveRespHarq
&{L3Call_last_line_check}
...   cp_ue/SgnbAdditionUeContextSetupActions=SgnbAdditionRequestAcknowledge|updateRrcReconfSCellAttCounter
@{L3call_check_in_syslog}     WRN/cp_ue/InitialContext    WRN/L2HI    dataSendPaused    BearerErrorIndScenario
...    UEC_CONNECTIVITY_TRSW.*FAILURE
@{cloud_check_KW_in_syslog}     ERROR cm::dataformatter        WARNING PlanOperationManager
...    ERR/CCS/AaError    CreateCarriersAsync finished with FAIL
...    ERR/Tas    onSoapTimeout()    WRN/Tas/Tas    WRN/E1SetupGuard
...    status.*faultId: 4019    recoveryType: SiteReset
...    crecoveryType: PodRecovery    is not OK    WRN/L2HiDU    added mcplane to kernel with File exists
...    ERR/cp_sctp    WRN/cp_rt/L1Setup    ERR/ctrl    ERR/cp_nb    WRN/cp_nb/CellConfigUpdateConfiguration
...    ERR/syscomd    ERR/LGC/RPMAG    ERROR [[]activation[]]    WRN/cp_rt/PoolStoreUtils
...    SPoolConfigurationResp.*NOTOK    Couldn.t map nodeId   ERR/TRS_SW
...    ERR/CCSRT-ERR    ERROR [[]startup[]]
...    AAERROR_DIAGN_LOG_DETECTED_IND_MSG    ERR/.uplane/L2-PS
...    CcsProxyListener ERR/CCS/CCSDaemon    ERR/dhcp4server
...    WRN/cp_rt/NiddConfig    WRN/cp_rt/PoolStoreUtils    ERR/CCS/AaFile, AaFileTarExtract
...    ERR/HWRSyncEthSExe    ERR/trs-vpp    ERR/FM/Common, [[]fm::AlarmStorage[]]
...    triggerReboot Reboot triggered    ip-traffic-capture/start request
...    ERR/./common/platform/    ERR/L2-PS/src    WRN/CMSERVICE/OAM
...    ERR/BM/TIME    CpCm::ENgStatus.*NOTOK    cp_rt WRN/cp_rt    EResult_Failed
...    ERR/CCS/AaRTOS    DCS.*Failure    ERR/LGC/APW    ERR/CCS/EM    L2Tupu.*ERR
...    consume CoredumpEvent: coreId.*RAISE    registration request timeout
@{classical_KW_in_TC_syslog}    swInvalid found for    ERR/LFS/LinuxSyslog, systemd
...    SW_FAILURE    ERR/LGC    AAERROR_DIAGN_LOG_DETECTED_IND_MSG
...    ERR/Has    CATEGORY: TIMEOUT    NgApErrorHandler    ERR/DCS/BBConf
...    NOTOK    Autonomous reset triggered by unknown    WRN/SysAdapter
...    WRN/cp_nb/CellConfigUpdateConfiguration    Not sending NiddConfigurationReq
...    sending ecpri link monitoring fault report to OAM for port
...    CATEGORY: UNKNOWN.*RESET_COUNTER.*SCOPE: RFM
...    oam-async-worke ERR/CCS/AaNet    oam-async-worke ERR/CCS/AaNet
...    WRN/cp_rt/NiddConfig    WRN/cp_rt/PoolStoreUtils    SPoolConfigurationResp.*NOTOK
...    is_power_down: FATAL    csf_ready failed
...    NgReset    RPRAM reset type data: exists YES, type 0, info \"\"
...    WRN/Has/BB_CAPACITY    WRN/cp_nb/LoggerImpl   ERR/cp_sctp_X2
...    srioServiceHandleSrioConnectionTimeout    ERR/L2-PS/src
...    handleEthernetMonitorFaultSvc:    ERR/Wts/Core    ethlsc ERR    Timeout while waiting
...    DCS.*INVALID    DCS.*Failed to    DCS.*ValidationReasoning
...    ERR/RCP    ERR.*databaseintegrator    ERR/CCS/AaFile    WRN/HWA/SUPERVISOR
...    stopping deployment application    report30Fault    Incorrect.*Parameter Setting
&{classical_KW_on_site}
...  /tmp/startup_BM.log=ERR/BM
...  /tmp/startup_HWAPI.log=ERR/HWA/HWATIME
...  /tmp/startup_HWAPI.log=SW_FAILURE
...  /tmp/startup_HWAPI.log=Watchdog reset
...  /tmp/startup_LFS.log=error while loading shared libraries
...  /tmp/startup_LFS.log=Failed to start
&{RLF_check_KW}
...  rlfReason=RlfType:[\\w\\S\\s]+
...  RadioLinkFailure handling with failureType=[\\s\\w]+RadioLinkFailure handling with failureType[\\s\\w]+
...  ueRlStatus=ueRlStatus:[A-Za-z_]+
...  randomAccessTimerForNsaInitialAccess Timeout=randomAccessTimerForNsaInitialAccess Timeout
@{classical_KW_in_syslog}    CCSRT ERR    ERR/LFS/LinuxSyslog, ERR    SW_FAILURE  ERR/LTE L2    ERR/DCS
...    ERR/I-PHY/NokiaRp1VsbLinkMessageTransfer    ERR/I-PHY/CpriLinkCtrl    ERR/TRSW/TRSWSyslog, trs-ipqos-d
...    Nonexistent file    Check fail for    normal update activation failed for reason   ERR/LTS/LTS
...    ERR/Ne3sAdapter   ddal_file_lock_release    DDAL_STRERROR
...    ERR/MCtrl    No BBPool ID    bpfForRadioAvailabilityState is unknown    ERR/CCSSysComGwExe
...    handleCoreDumpStarted    Failed execute command    ERR/HWA/SUM    ERR/l1_application
...    ERR/CellManager    _core.sh
&{class_gnb_startup_fail_num}
...  Timeout for CpCm_ConfigurationReq=15
...  MRI not yet sent, because NTP is not active=100
@{cloud_gnb_startup_check_failure_num_KW}    Failed:POST /api/bb/v1/ran-nic/cells-to-l1-mapping    f1setupfailure
&{cloud_last_line_check}
...  Update syncStatus success=Locked
...  getInterfaceConfig ec=Success
...  NetworkPlanFileInternalUpdate=status= available
...  deploymentStatus:=complete
...  All NG-C preconditions met=All NG-C preconditions met?: Yes
...  FHCONFIG/Swm=local previous and new build versions are equal to|SWM_POST_REGISTER_RU_COMPLETED|OfflineUpgradeRu overal status Idle
...  BaseBandStreamConfigInL1Async create 1 finished=SUCCESS
...  getLoglinkFromMeshLinks=loglink is selected
...  T0x0000, [[]Activation[]]=result:SUCCESS|CMActivationRespAck
...  [[]Validation[]] Received CMValidationResp=SUCCESS|CMValidationRespAck
...  get plan activation operationState from CM=success
...  checkCurrentPlanStatus=ACTIVATED
...  SctpEndpoint.*[]]SCTP association=SCTP association established
...  health status is=\[SERVING\]
...  CELL_MAPPING_TASK=Succeeded|EOperationType::Delete:
...  collectNgRanUpdateResp=Status:ok
...  CommissioningCheck.*Current Plan=Current Plan active in OAM CM
...  Cell availability status for.*evaluated as current status=Offline|Online
...  CellStateHandler=activateRadioForCell
...  uplaneCarrierDN.*availabilityStatus=Online
...  The new F1IpConnParamsList is=portNumber
&{classical_last_line_check}
...  nDnrBuildData=nDnrBuildData=1
...  EFallbackCause_=EFallbackCause_None
...  CheckL1Synch=HFNSYNC: 1
...  assignPeerBtsParamsToRmod=It is local rf info
@{classical_hidden_logs_check}
...   AlarmingObjectMapper    RestartFaultHandler    report() Done for faultId    Resetting radio.*ResetCause.*
@{skip_regex}   .*SW_FAILURE.*INFO: LinkId.*    .*AlarmFaultSignature::setFaultSignature SW_FAILURE\\b    .*ForRuemLog HISTORY.*
...   .*sshd executing as.*    .*temp_user_plan_file_plan.*    .*Failed to set timeout to 10min: Invalid argument.*
...   .*source has not been found on sources stabilities statuses list.*    .*clock_source_selector.*
...   .*Response for POST on /update/stream/ from BB Config is not OK.*    .*parse json file failed from string.*
...   .*Timeout for message: ExpectedMessageParameters.*    .*Invalid cell to delete, cell is not Enable.*
...   .*Failed to resolve unit specifiers.*    .*Received result under unsupported object.*    .*PlanValidationService.*
...   .*Timed out waiting for device sys-.*    .*ccs_em_dispatcher_custom_wait_thread_dispatchers_exit.*
...   .*ccs_em_config_tag_read.*    .*em_get_counters_from_shm.*    .*ConfigureNetworkLayerTaskCloud.*
...   .*ConfigureFhSshTask.*    .*ETempMeasError_NoResponse.*    .*NE3SSOAP.*    .*COMAXML_read_str.*
...   .*MainComponent.*     .*Indication for Subscription id.*    .*Could not open alarm history file for reading.*
...   .*Timeout on retrieving service distname for: HWASYNCETH.*
...   .*Connector initialization failed.*    .*ERR/BM/CLOCK, distname_query: Response timeout.*
...   .*deserializeFS.*CATEGORY.*    .*notification_queue_manager_info is NULL.*    .*parent distname.*does not exist
...   .*Precondition CELL_M check failed.*    .*NftmgmtNodeId is not set for L3RtPool in case of VDU BTS.*
...   .*InternalCellDeleteTask.*    .*Open TRSW firewall with transactionId.*
...   .*Reading full size of the NV index.*    subscribers for message UNIT_READY_IND_MSG received from.*Message was dropped
...   Timeout while waiting for API_SFP_GET_ALL_AVAILABLE_SFP_INFO_RESP_MSG from slave    Failed to remove ims2FileChars
...   core.sh.*New LWP    hwr_reconfig_reset    CCS/AaFile.*failed to remove directory    SWDLreport    bbox/Diagnostic
...   API_SFP_GET_ALL_AVAILABLE_QSFP_INFO_RESP_MSG    SFP.*Blackbox    AaFile.*run/logs    AaFile.*/ffs/stb/config/
...   /ffs/fs1.*Device or resource busy
${INVALID_SSD}    ${{ [{'VENDOR_ID': '1588', 'PRODUCT_ID': '4720'}, {'VENDOR_ID': '4976', 'PRODUCT_ID': '1024'}] }}

*** Keywords ***
RLF check in Logs
    [Arguments]    ${file_path}    ${str_pattern}    ${regex_pattern}
    ${rlfReason}=    Run    grep "${str_pattern}" ${file_path}
    ${rlfReason_result}    Run Keyword and Return Status    Should be empty    ${rlfReason}
    Run Keyword If    ${rlfReason_result}!=${True}
    ...    Compare timestamp of L3call failure log and print rlf reason to console
    ...    rlf_input=${rlfReason}
    ...    regex_pattern=${regex_pattern}

Compare timestamp of L3call failure log and print rlf reason to console
    [Arguments]    ${rlf_input}    ${regex_pattern}
    @{rlfReason}=    Split To Lines    ${rlf_input}
    FOR    ${rlfReason_details}    IN    @{rlfReason}
        ${rlfReason_extract}=    Get Regexp Matches    ${rlfReason_details}    ${regex_pattern}
	    Compare timestamp of L3call failure log
        ...    msg=${rlfReason_details}    console_print=UE dropped due to ${rlfReason_extract}[0]
        ...    log_print=L3call rlf reason
    END

Print rlf reason to console
    [Arguments]    ${rlf_input}    ${regex_pattern}
    @{rlfReason}=    Split To Lines    ${rlf_input}
    ${rlfReason_regex}=    Get Regexp Matches    ${rlfReason}[0]    ${regex_pattern}
    log    UE dropped due to ${rlfReason_regex}, pls check!    WARN

Check failure numbers in syslog
    [Documentation]  this keyword now supports L3call or gnb_startup failure numbers in log
    ...   author: Yin Jie
    [Arguments]    ${issueType}    ${file_path}    ${pattern}    ${threshold}=0    ${fatal}=False
    ${failures_cnt}=    Run    grep -c "${pattern}" ${file_path}
    ${failures_cnt}     Strip String    ${failures_cnt}
    ${failures_cnt}=    Convert To Integer    ${failures_cnt}
    Run Keyword If    '${issueType}'=='warnings' or '${issueType}'=='l2lo'
    ...               Set Global Variable    ${failures_cnt_${issueType}}    ${failures_cnt}
    ${threshold}=    Convert To Integer    ${threshold}
    Run keyword if   ${failures_cnt}>${threshold}    Run Keywords
    ...    Run    echo ">>>>>>Below logs are about ${pattern}:<<<<<\n" >> ${LOG_PATH}/${issueType}_failure.log
    ...    AND    Run    more ${file_path} | grep '${pattern}' >> ${LOG_PATH}/${issueType}_failure.log
    ...    AND    Run    echo "\n\n" >> ${LOG_PATH}/${issueType}_failure.log
    Run keyword if   ${failures_cnt}>${threshold} and ${fatal}==${False}
    ...   log
    ...   There are ${failures_cnt} lines of warning/errors regarding ${pattern}, pls check logs! Details refer to ${issueType}_failure.log
    ...   WARN
    ${fatal_err_msg}=    set variable if    ${failures_cnt}>${threshold}
    ...   There are ${failures_cnt} lines of warning/errors regarding ${pattern}, pls check logs! Details refer to ${issueType}_failure.log
    ...   None
    Run Keyword if    ${failures_cnt}>${threshold} and '${fatal}'=='True'    Run Keywords
    ...    append to list    ${fatal_err_list}    True
    ...    AND    append to list    ${fatal_err_msg_list}    ${fatal_err_msg}

Check NAS release in logs
    [Arguments]    ${file_path}
    ${nas_release}=    Run    grep "CauseNas" ${file_path}
    ${nas_release}=    Replace String    ${nas_release}    \(    \\(
    ${nas_release}=    Replace String    ${nas_release}    \)    \\)
    ${nas_release_result}    Run Keyword and Return Status    Should be empty    ${nas_release}
    Run Keyword If    ${nas_release_result}!=${True}    Compare timestamp of L3call failure log
    ...    msg=${nas_release}
    ...    console_print=UE is released by AMF
    ...    log_print=UE released by AMF

Compare timestamp of L3call failure log
    [Documentation]   This keyword is used to compare timestamp L3call failure log with traffic end time
    ...               author: Yin Jie
    [Arguments]    ${msg}     ${console_print}    ${log_print}
    ${isCloud}    Evaluate    ${vCU_build_flag} or ${vDU_build_flag}
    ${traffic_end_timestamp}=    Get variable value    ${traffic_end_timestamp}    00.00 00:00:00
    ${result_timestamp}    compare_l3call_timestamp
    ...   l3call_failure_msg=${msg}
    ...   traffic_end_timestamp_str=${traffic_end_timestamp}
    ...   is_cloud=${isCloud}
    IF    ${result_timestamp[0]}
        Log    ${console_print} at ${result_timestamp[1]}, pls check logs! Details can be found in L3call_failure.log    WARN
        Run    echo ">>>>>>Below logs are about ${log_print}:<<<<<\n" >> ${LOG_PATH}/L3call_failure.log
        Run    echo "${msg.replace('"', '')}\n\n" >> ${LOG_PATH}/L3call_failure.log
    END

Check error message in syslog
    [Documentation]    print warning from syslog
    ...                author: Yin Jie
    [Arguments]        ${isCloud}=False    ${pattern}=None    ${file_path}=/tmp/btslog2    ${log_to_console}=True    ${grep_command}=-r
    ...     ${msg_hidden}=False    ${log_file_name}=gnb_startup_failure.log    ${alarm7313_check}=False
    ${skip_regex_str}=    Evaluate    "|".join(${skip_regex})
    ${SW_FAILURE_CHECK}=     Get Variable Value    ${SW_FAILURE_CHECK}    ${False}
    ${res_limit}    ${res}    handle_error_message_in_syslog
    ...    isCloud=${isCloud}
    ...    pattern=${pattern}
    ...    file_path=${file_path}
    ...    grep_command=${grep_command}
    ...    skip_regex_str=${skip_regex_str}
    ${log_to_console_check}    Evaluate    ('${pattern}'=='SW_FAILURE' and '${SW_FAILURE_CHECK}'=='False') or '${pattern}'!='SW_FAILURE'
    ${result}=    Run Keyword And Return Status    Should Be String    ${res_limit}
    IF    ${result} and ${log_to_console} and ${log_to_console_check} and '${msg_hidden}'=='False' and not ${alarm7313_check}
        Log    There are warnings about ${pattern}:\n${res_limit}     WARN
    ELSE IF    ${result} and ${log_to_console_check} and '${msg_hidden}'=='False' and not ${alarm7313_check}
        Log    There are warnings/errors about ${pattern}, pls check logs! Details can be found in ${log_file_name}    WARN
    ELSE IF    ${log_to_console} and ${result} and ${alarm7313_check}
        Log
        ...    There is SA UE attached during cell deletion procedure and this will trigger expected alarm FID7313, Pls check!\n${res_limit}
        ...    WARN
    END
    IF    ${result} and ${log_to_console_check}
        Append To File
        ...    path=${LOG_PATH}/${log_file_name}
        ...    content=>>>>>>Below logs are about gnb startup warnings/errors related with ${pattern}:<<<<<\n
        Append To File    path=${LOG_PATH}/${log_file_name}    content=${res}\n\n
    END
    Run Keyword If    ${result} and '${pattern}'=='SW_FAILURE'
    ...    Set Suite Variable    ${SW_FAILURE_CHECK}    ${True}

Check error message in site
    [Documentation]    print warning from log on site
    ...                author: Yin Jie
    [Arguments]        ${pattern}    ${file_path}   ${log_to_console}=True    ${log_to_file}=True
    ${skip_regex_str}=    Evaluate    "|".join(${skip_regex})
    ${err_limit}    ${err}    handle_error_message_in_site
    ...    pattern=${pattern}
    ...    file_path=${file_path}
    ...    skip_regex_str=${skip_regex_str}
    ...    alias=gnb
    ${result}=    Run Keyword And Return Status    Should Be String    ${err_limit}
    Run Keyword if    ${log_to_console} and ${result}
    ...    Log     There is warning/error about ${pattern} in ${file_path}:${err_limit}    WARN
    IF    ${log_to_file} and ${result}
        Run
        ...    echo ">>>>>>Below logs are about gnb startup warnings/errors related with ${pattern}:<<<<<\n" >> ${LOG_PATH}/gnb_startup_failure.log
        Append To File    path=${LOG_PATH}/gnb_startup_failure.log    content=${err}\n\n
    END

Check L1 error message in site
    [Documentation]    print warning from log on site
    ...                author: Yin Jie
    [Arguments]        ${pattern}    ${file_path}
    ${smod_type}    Get Variable Value    ${smod_type}    NOT_SET
    ${l1_cmd}=    Set Variable    grep '${pattern}' ${file_path}
    IF    'ASO' in '${smod_type}'
        ${res}=    ssh.execute     command=${l1_cmd}    connection=gnb    timeout=60s
    ELSE
        ${ipaddr}=    ssh.execute     command=backplane-ip -c 0 FSP1    connection=gnb    timeout=60s
        ${fsp_ping}=    ssh.execute     command=ping -c 4 ${ipaddr.strip()}    connection=gnb    timeout=60s
        ${fsp_reachable}=    Run Keyword And Return Status    Should Contain    ${fsp_ping}    received, 0% packet loss
        IF    ${fsp_reachable}
            ssh.connect_to      hostname=${ipaddr.strip()}
            ...                 username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
            ...                 password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
            ...                 proxy=gnb
            ...                 alias=fspcon
            ${res}=    ssh.execute     command=${l1_cmd}    connection=fspcon    timeout=60s
        ELSE
            ${fsp_cmd}=    Set Variable    ip netns exec boot_over_ethernet ssh -F /etc/bsoc/bsoc_ssh_config toor4nsn@${ipaddr.strip()} "${l1_cmd}"
            ${res}=    ssh.execute     command=${fsp_cmd}    connection=gnb    timeout=60s
        END
    END
    ${err_result}=    Run Keyword and Return Status    Should not be empty    ${res}
    ${file_exists}=    Run Keyword If    ${err_result}    Run Keyword And Return Status
    ...    Should Not Contain Any   ${res}
    ...    No such file or directory    Connection refused
    ...    l1soc-dataflash-update
    ...    ELSE    Set Variable    ${False}
    ${err_limit}=    Run Keyword if    ${file_exists} and ${err_result}
    ...   Run    head -n 10 ${res}
    IF    ${err_result} and ${file_exists}
        Log     There is warning/error about ${pattern} in ${file_path}:${err_limit}    WARN
        Run
        ...    echo ">>>>>>Below logs are about gnb startup warnings/errors related with ${pattern}:<<<<<\n" >> ${LOG_PATH}/gnb_startup_failure.log
        Append To File    path=${LOG_PATH}/gnb_startup_failure.log    content=${res}\n\n
    END

Check crashs in ocp log
    [Documentation]  this keyword is used to check kw in log for PR633151
    [Arguments]    ${file_path}
    ${res}=   Run   cat ${file_path} | grep "need to recover" | grep -v "no need to recover"
    IF    ${{len($res)}}>0
        Log    Crashs detected in syslog: \n --> \n ${res}    WARN
        Run
        ...    echo "\n\n>>>>>>Below logs are about cloud crash logs:<<<<<\n" >> ${LOG_PATH}/gnb_startup_failure.log
        Append To File    path=${LOG_PATH}/gnb_startup_failure.log    content=${res}\n\n
    END

Check SCF validation errors in log
    [Documentation]  this keyword is used to check if validation error visible
    ...    author: Yin Jie
    [Arguments]    ${file_path}
    ${res}    Run    grep "Plan validation failed" ${file_path}
    IF    ${{len($res)}}>0
        Log    Plan validation failed, pls check!    WARN
        Run
        ...    echo ">>>>>>Below logs are about Plan validation failed:<<<<<\n" >> ${LOG_PATH}/gnb_startup_failure.log
        Append To File    path=${LOG_PATH}/gnb_startup_failure.log    content=${res}\n\n
        Run Keyword and ignore error    Log SCF validation error details from log
        ...    file_path=${file_path}   pattern=parameterDefinitionErrors
        Run Keyword and ignore error    Log SCF validation error details from log
        ...    file_path=${file_path}   pattern=hardwareRelationErrors
    END

Additional check in TC
    [Documentation]    perform additional check in classical testcase level
    ...                author: Yin Jie
    ${btslog_exist}=   Run Keyword And Return Status    Directory Should Exist    /tmp/btslog2
    IF    ${btslog_exist}
        Check error message in syslog    pattern=Lifecycle of SA UE finished.*Status: Unknown
        ...    alarm7313_check=True
        Check error message in syslog
        ...    pattern=SanityCheckMsgReceiver][\\s][a-zA-Z]+[\\s]:[\\s\\S]+    grep_command=-P -r
        FOR    ${pattern}    IN    @{classical_KW_in_TC_syslog}
            Check error message in syslog    pattern=${pattern}
        END
    END
    ${connection}    Run Keyword and Return Status    ssh.connect_to
    ...                 hostname=192.168.255.129
    ...                 username=toor4nsn
    ...                 password=oZPS0POrRieRtu
    ...                 alias=gnb
    IF    ${connection}
        ${smod_type}    Get Variable Value    ${smod_type}    NOT_SET
        FOR    ${file_path}    ${kw}    IN   &{classical_KW_on_site}
            IF   'l1' not in '${file_path}'
                Check error message in site    pattern=${kw}    file_path=${file_path}
            ELSE IF    'l1' in '${file_path}' and '${smod_type}'!='ASIA'
                Check L1 error message in site    pattern=${kw}    file_path=${file_path}
            END
        END
    END

Common L3Call Check
    [Arguments]    ${file_path}    ${isCloud}
    FOR    ${kw}    IN    @{L3Call_num_KW}
        Check failure numbers in syslog    issueType=L3call    file_path=${file_path}    pattern=${kw}
    END
    Check failure numbers in syslog
    ...    issueType=L3call    file_path=${file_path}    pattern=WRN/L2Lo    threshold=800    fatal=True
    FOR    ${kw}    ${regex}    IN   &{RLF_check_KW}
        RLF check in Logs    file_path=${file_path}    str_pattern=${kw}    regex_pattern=${regex}
    END
    FOR    ${kw}    ${checkpoint}    IN    &{L3Call_last_line_check}
        Last line check in logs
        ...    file_path=${file_path}    kw=${kw}    checkpoint=${checkpoint}    issueType=L3call
    END
    Check NAS release in logs    file_path=${file_path}
    FOR    ${pattern}    IN    @{L3call_check_in_syslog}
        Check error message in syslog    isCloud=${isCloud}    file_path=${file_path}    pattern=${pattern}
        ...    log_file_name=L3call_failure.log
    END
    Check error message in syslog    isCloud=${isCloud}    file_path=${file_path}    pattern=ERR/L2HiDu    grep_command=-r -A 1
    Check error message in syslog    isCloud=${isCloud}   file_path=${file_path}    pattern=Lifecycle of   log_to_console=False
    ...    msg_hidden=True    log_file_name=L3call_failure.log

Last line check in logs
    [Documentation]   check if last matched line from logs is faulty, checkpoint should be the correct one
    [Arguments]    ${file_path}    ${kw}    ${checkpoint}   ${issueType}=gnb_startup
    ${res}    ${resful}    handle_last_line_check    file_path=${file_path}    kw_regex=${kw}    checkpoint_regex=${checkpoint}
    ${result}    Run Keyword and return status    Should Not Be String     ${res}
    IF    not ${result}
        Log     Last line of ${kw} is not correct, correct status should be ${checkpoint}:\n${res}     WARN
        Run
        ...    echo ">>>>>>Below logs are about status of ${kw}:<<<<<\n" >> ${LOG_PATH}/${issueType}_failure.log
        Append To File    path=${LOG_PATH}/${issueType}_failure.log    content=${resful}\n\n
    END

Check populatePodsInfo
    [Documentation]  this keyword is to check lastline of populatePodsInfo on all pods
    ...   author: Yin Jie
    [Arguments]    ${file_path}
    ${res}=    Run    grep 'populatePodsInfo: \\[' ${file_path}
    ${status}    Run Keyword and return status    Should Not Be Empty    ${res}
    ${populatePodsList}=     Run Keyword If    ${status}    Get Regexp Matches    ${res}    populatePodsInfo: \\[po\\S+
    ${populatePodsList}=     Run Keyword If    ${status}    Remove Duplicates     ${populatePodsList}
    ...    ELSE     Create List    empty_list
    FOR    ${populatePod}    IN    @{populatePodsList}
        ${populatePod}=    Replace String    ${populatePod}    [    \\[
        ${populatePod}=    Replace String    ${populatePod}    ]    \\]
        Last line check in logs    file_path=${file_path}    kw=${populatePod}     checkpoint=empty
    END

Additonal Check in Logs
    [Documentation]   Add additonal checkpoints in logs
    [Arguments]    ${file_path}    ${L3call_check}=${True}
    Log To Console    \n\t\t- - - Start additional check in logs [...] - - -
    ${file_exists}    Run Keyword and return status    File should exist    ${file_path}
    ${fatal_err_msg_list}    create list
    ${fatal_err_list}    create list
    set suite variable    ${fatal_err_list}
    set suite variable    ${fatal_err_msg_list}
    IF    ${file_exists}
        IF    ${L3call_check}
            Common L3Call Check    file_path=${file_path}    isCloud=False
        END
        Fault signature check in classical syslog    file_path=${file_path}
        Log To Console    \t\t- - - Start additional check in syslogs [DONE]- - -
    ELSE
        Log To Console    \t\t- - - Skip additional check in syslog due to log dosen't exist!
    END

Fault signature check in classical syslog
    [Documentation]  this keyword is for additional check in classical syslog
    ...   author: Yin Jie
    [Arguments]    ${file_path}
    ${classical_hidden_logs_check_str}=    Evaluate    "|".join(${classical_hidden_logs_check})
    Check error message in syslog
    ...    pattern=${classical_hidden_logs_check_str}    log_to_console=False    msg_hidden=True    grep_command=-E -r
    FOR    ${pattern}    IN    @{classical_KW_in_syslog}
           Check error message in syslog    file_path=${file_path}    pattern=${pattern}
    END
    FOR    ${pattern}    ${threshold}    IN    &{class_gnb_startup_fail_num}
        Check failure numbers in syslog
        ...    issueType=gnb_startup    file_path=${file_path}    pattern=${pattern}    threshold=${threshold}
    END
    Check error message in syslog
    ...    pattern=CC&S AaPro exception report    file_path=${file_path}    log_to_console=True    grep_command=-r -A 10
    FOR   ${kw}    ${checkpoint}   IN    &{classical_last_line_check}
        Last line check in logs    file_path=${file_path}    kw=${kw}    checkpoint=${checkpoint}
    END
    Check Number Of Warnings    ${file_path}

Check Number Of Warnings
    [Documentation]  this keyword is for calculating the percentage of warnings in syslog
    [Arguments]    ${file_path}
    ${syslog_lines}    Run    wc -l < ${file_path}
    IF    '${syslog_lines}'=='0'
        Log    Skip warnings number check
    ELSE
        Check failure numbers in syslog    issueType=warnings    file_path=${file_path}    pattern=WRN/        threshold=${syslog_lines}
        Check failure numbers in syslog    issueType=l2lo        file_path=${file_path}    pattern=WRN/L2Lo    threshold=${syslog_lines}
        ${warnings}       Evaluate     (${failures_cnt_warnings}/${syslog_lines})*100
        ${warnings}       Convert To Number    ${warnings}    3
        ${l2lo_warnings}       Evaluate     (${failures_cnt_l2lo}/${syslog_lines})*100
        ${l2lo_warnings}       Convert To Number    ${l2lo_warnings}    3
        ${syslog_warning_header}    Set Variable
        ...    --> INFO: The amount of warnings in syslog is: ${warnings}%
        ${l2lo_warnings_header}    Set variable
        ...    --> INFO: The amount of l2lo warnings in syslog is: ${l2lo_warnings}%
        Log to Console
        ...    ${syslog_warning_header} (syslog prints: ${syslog_lines}, warnings:${failures_cnt_warnings})
        Run Keyword If    '${l2lo_warnings}'=='0.0'    Log to Console    --> INFO: There is no WRN/L2Lo in syslog
        ...    ELSE    Log to Console
        ...    ${l2lo_warnings_header} (syslog prints: ${syslog_lines}, warnings:${failures_cnt_l2lo})
    END

Fault signature check in OCP log
    [Documentation]  this keyword is for additional check in syslog
    ...   author: Yin Jie
    [Arguments]    ${file_path}=/var/home/core/logservice/${${par_prefix}_tenant}/syslog.zip
    FOR    ${pattern}    IN    @{cloud_check_KW_in_syslog}
        Check error message in syslog    isCloud=True    file_path=${file_path}    pattern=${pattern}
    END
    Check error message in syslog    isCloud=True   file_path=${file_path}    pattern=(core dumped)    grep_command=-r -A 1
    Check error message in syslog    isCloud=True   file_path=${file_path}    pattern=an alarm    log_to_console=False    msg_hidden=True
    Check error message in syslog
    ...    isCloud=True   file_path=${file_path}    pattern=Last event from HC is    log_to_console=False    msg_hidden=True
    FOR    ${pattern}    IN    @{cloud_gnb_startup_check_failure_num_KW}
        Check failure numbers in syslog    issueType=gnb_startup    file_path=${file_path}    pattern=${pattern}
    END
    FOR   ${kw}    ${checkpoint}   IN    &{cloud_last_line_check}
        Last line check in logs    file_path=${file_path}    kw=${kw}    checkpoint=${checkpoint}
    END
    Check populatePodsInfo    file_path=${file_path}
    Check Number Of Warnings    ${file_path}

Additonal Check in OCP sys Logs
    [Documentation]  this keyword is for additional checkpoint in syslog
    [Arguments]    ${cloud_syslog_path}    ${file_path}=/var/home/core/logservice/${${par_prefix}_tenant}/syslog.zip
    Log To Console    --> Start additional check in logs [...]
    IF    $cloud_syslog_path is None
        Run     rm -rf /tmp/syslog*
        Get test timestamp
        ${result}    unzip_cloud_logs   file_path=${file_path}    timestamp=${timestamp}    connection=RM_alias
        IF    not ${result[0]}
            Log To Console    --> Skip additional check in logs due to log dosen't exist!
            RETURN
        END
        ${combined_file_path}    Set Variable    ${result[1]}
    ELSE
        ${combined_file_path}    Set Variable    ${cloud_syslog_path}
    END
    get_post_check_summary_if_deploy_failed    file_path=${combined_file_path}    save_to_file_path=${LOG_PATH}/gnb_startup_failure.log
    Check Cell OnAir Status in syslog    file_path=${combined_file_path}
    Check SCF validation errors in log    file_path=${combined_file_path}
    Fault signature check in OCP log   file_path=${combined_file_path}
    Common L3Call Check    file_path=${combined_file_path}    isCloud=True
    Log To Console    --> Start additional check in logs [DONE]

Check Cell OnAir Status in syslog
    [Documentation]  this keyword is for cell setup check in syslog
    ...   author: Yin Jie
    [Arguments]    ${file_path}
    ${cell_setup_test_result}=   get test case status by name    Verify gNB Cell setup
    Run Keyword If    '${cell_setup_test_result}'=='FAIL' and ${vCU_build_flag}    Check Cell OnAir Status in CU syslog    file_path=${file_path}
    ...    ELSE IF    '${cell_setup_test_result}'=='FAIL' and ${vDU_build_flag}    Check Cell OnAir Status in DU syslog    file_path=${file_path}

Check Cell OnAir Status in CU syslog
    [Documentation]  this keyword is for cell setup check in CU syslog
    ...   author: Yin Jie
    [Arguments]    ${file_path}
    ${res}=    Run    grep 'CellConfigurationProcedure finish' ${file_path}|tail -1
    ${status}    Run Keyword and return status    Should Not Be Empty    ${res}
    ${cell_active}=   Run Keyword If    ${status}    Get Regexp Matches    ${res}    cells succeeded: \\[\\d+\\]
    ${is_cell_active}=    Run Keyword If    ${status}     Run keyword And Return Status    Should Not Be Empty    ${cell_active}
    ...    ELSE    Set Variable    ${False}
    ${timestamp}=    Run Keyword If    ${is_cell_active}    Get Regexp Matches    ${res}    \\d{4}-\\d{2}-\\d{2}\\w\\d{2}:\\d{2}:\\d{2}
    Run Keyword If    ${is_cell_active}    Log    Cell is OnAir on CU at ${timestamp}[0], please check!    WARN

Check Cell OnAir Status in DU syslog
    [Documentation]  this keyword is for cell setup check in DU syslog
    ...   author: Yin Jie
    [Arguments]    ${file_path}
    ${res}=    Run    grep 'set onair' ${file_path}|tail -1
    ${status}    Run Keyword and return status    Should Not Be Empty    ${res}
    ${is_cell_active}=   Run Keyword If    ${status}    Run Keyword and return status    Should Contain     ${res}    with value 1
    ...    ELSE    Set Variable    ${False}
    ${timestamp}=    Run Keyword If    ${is_cell_active}    Get Regexp Matches    ${res}    \\d{4}-\\d{2}-\\d{2}\\w\\d{2}:\\d{2}:\\d{2}
    Run Keyword If    ${is_cell_active}    Log    Cell is OnAir on DU at ${timestamp}[0], please check!    WARN

Additional check in TC Common TS
    Additional check in TC
    TRY
        ${smod_type}    Get Variable Value    ${smod_type}    NOT_SET
        Run Keyword If         '${smod_type}'=='ASIA'    Check And Validate SSD Version
    EXCEPT    AS    ${error}
        Log    Unable to retrieve and validate the SSD version, manual checking may be required.    WARN
    END
    Set Suite Variable    ${are_logs_checked}    ${True}

Check Error in Snapshot
    [Documentation]  this keyword is used to check error in snapshot
    ...   author: Yin Jie
    [Arguments]    ${snapshot_path}
    [Timeout]    10 min
    Log To Console    \n\t\t- - - Start additional check in snapshot [...] - - -
    ${vCU_build_flag}    Get Variable Value    ${vCU_build_flag}    ${False}
    ${vDU_build_flag}    Get Variable Value    ${vDU_build_flag}    ${False}
    Run Keyword If    ${vCU_build_flag} or ${vDU_build_flag}
    ...    Remove Values From List    ${snapshot_check_KW}    ERR/CCS/AaPro
    ${file_exists}    Run Keyword and return status    File should exist    ${snapshot_path}
    ${snapshat_chek_kw_str}=    Evaluate    "\\|".join(${snapshot_check_KW})
    ${skip_snapshot_check_kw_str}=    Evaluate    "\\|".join(${skip_snapshot_check_KW})
    ${shapshot_check_script_path}    Set Variable    ${CURDIR}/../scripts
    ${shapshot_check_cmd}    Set Variable
    ...    ./snapshot_log_check.sh ${snapshot_path} "${snapshat_chek_kw_str}" "${skip_snapshot_check_kw_str}"
    Run    chmod +x ${shapshot_check_script_path}/snapshot_log_check.sh
    IF    ${file_exists}
        ${output}    Run
        ...    cd ${shapshot_check_script_path} && ${shapshot_check_cmd}
        IF    'Match found' in '''${output.replace("'", "")}'''
            Log     There is warnings/errors in snapshot    WARN
            ${console_logs}    remove_duplicate_lines    ${output}
            Log to Console     ${console_logs}
            Run
            ...  echo ">>>>>>Below logs are about gnb startup warnings/errors in snapshot:<<<<<\n" >> ${LOG_PATH}/gnb_startup_failure.log
            Append To File    path=${LOG_PATH}/gnb_startup_failure.log    content=${output}
        END
        Log To Console    \n\t\t- - - Start additional check in snapshot [DONE] - - -
    ELSE
        Log To Console    \t\t- - - Skip additional check in snapshot due to log dosen't exist!
    END

Check And Validate SSD Version
    [Documentation]    CExecute the command and validate VENDOR_ID and PRODUCT_ID using regex
    [Arguments]    ${host}=${LMP_IP}    ${username}=${asik_username}    ${password}=${asik_password}
    ${HW_Link} =    Set Variable    https://confluence.ext.net.nokia.com/display/GSMBTSTRS/Known+HW+Faults
    ssh.Connect to   hostname=${host}   username=${username}   password=${password}    alias=bbu_alias
    ${output}=    ssh.execute
    ...    command=/usr/libexec/ssd-collect-status-common
    ...    connection=bbu_alias
    ${vendor_id}=    Evaluate    re.search(r'VENDOR_ID=(\\d+)', '''${output.replace("'", "")}''').group(1)
    ${product_id}=    Evaluate    re.search(r'PRODUCT_ID=(\\d+)', '''${output.replace("'", "")}''').group(1)
    Log    Extracted VENDOR_ID=${vendor_id}, PRODUCT_ID=${product_id}
    FOR    ${combination}    IN    @{INVALID_SSD}
        ${invalid_vendor}=    Get From Dictionary    ${combination}    VENDOR_ID
        ${invalid_product}=    Get From Dictionary    ${combination}    PRODUCT_ID
        IF    '${vendor_id}' == '${invalid_vendor}' and '${product_id}' == '${invalid_product}'
            Log    \nInvalid SSD used: \n${output} \nPlease check if alarm is related to known HW issue. Reference link:\n${HW_Link}    WARN
        END
    END

Crash Info Check In Syslog
    [Documentation]  this keyword is used to check crash info in syslog
    [Arguments]    ${file_path}=/tmp/btslog2    ${crash_pattern}=exception report    ${is_cloud}=False
    ${skip_regex_str}=    Evaluate    "|".join(${skip_regex})
    ${skip_log_collection}    Get Variable Value    ${skip_log_collection}    ${False}
    IF    ${skip_log_collection}
        Log To Console    \nSkip crash info check in syslog due to skip_log_collection is set to True
        RETURN
    END
    ${crash_info}     get_crash_info_from_syslog
    ...    skip_regex_str=${skip_regex_str}
    ...    file_path=${file_path}
    ...    crash_pattern=${crash_pattern}
    ...    is_cloud=${is_cloud}
    IF    ${{len($crash_info)}}==0
        RETURN
    END
    Run
    ...    echo "\n>>>>>>Below logs are about crash info in syslog:<<<<<\n" >> ${LOG_PATH}/gnb_startup_failure.log
    Append To File    path=${LOG_PATH}/gnb_startup_failure.log    content=${crash_info}\n\n
    Fail    Crash info is found in syslog, please check gnb_startup_failure.log!

Crash Info Check In Cloud Syslog
    [Documentation]  this keyword is used to check crash info in cloud syslog
    ${skip_log_collection}    Get Variable Value    ${skip_log_collection}    ${False}
    IF    ${skip_log_collection}
        Log To Console    \nSkip crash info check in syslog due to skip_log_collection is set to True
        RETURN
    END
    Get ocp logservice    cloud_syslog_path=${None}
    Run     rm -rf /tmp/syslog*
    Get test timestamp
    ${result}    unzip_cloud_logs
    ...    file_path=/var/home/core/logservice/${${par_prefix}_tenant}/syslog.zip
    ...    file_path=/var/home/core/logservice/${${par_prefix}_tenant}/syslog.zip
    ...    timestamp=${timestamp}
    ...    connection=RM_alias
    IF    not ${result[0]}
        Log To Console    Skip crash info check in syslog due to log dosen't exist!
        RETURN
    END
    Set Suite Variable    ${cloud_syslog_path}    ${result[1]}
    Crash Info Check In Syslog
    ...    file_path=${result[1]}
    ...    is_cloud=True
