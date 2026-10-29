*** Settings ***
Documentation    Test variables and keyword resource file for Performance_Test

Library    OperatingSystem
Library    glob
Library    String

Library    taf.file.pack                                WITH NAME    file_pack
Library    taf.transport.ssh                            WITH NAME   ssh

Library    python/perf_timer.py
Library    python/perf_log_collection.py
Library    python/perf_resource_usage.py
Library    python/l2perf.py
Library    python/bash_helper.py
Library    python/perf_script.py
Library    python/lxc_top.py

Resource    ../../../resources/Common/btslog.robot
Resource    ../../../resources/Common/bip_trace.robot
Resource    ../../../resources/Common/bip_trace_ap.robot
Resource    ../../../resources/Common/pmcounters.robot
Resource    ../../../resources/Common/snapshot.robot
Resource    ../../../resources/Common/tcpdump.robot
Resource    ../../../resources/Common/wts_ue.robot
Resource    performance_btslog.robot
Resource    performance_ttitrace.robot
Resource    performance_turandot.robot
Resource    performance_snapshot.robot

*** Variables ***
${TS_BTS_COLLECTION_STARTED}=        ${FALSE}
${TS_BIP_COLLECTION_GNB_STARTED}=    ${FALSE}
${TS_BIP_COLLECTION_AP_STARTED}=     ${FALSE}
${TCPDUMP_RUNNING}=                  ${FALSE}
${L2PERF_GET_INFO_TIMEOUT}=          300
${T_BTS_LOG_PATH}=                   ${None}

*** Keywords ***
#--------------------------------------------------------- Log Collection -----------------------------------------------------------[150 characters]
Start SysLog Collection
    IF     "${TP.ENABLE_SYSLOG}"=="true" and not ${TS_BTS_COLLECTION_STARTED}
        Log    \nStart SysLog Collection    console=${P_console}
        ${core_alias}    connect.Connect To Core
        ssh.Execute    command=rm -f /tmp/btslog2/*    connection=${core_alias}
        TRY
            Start Btslog
            Set Test Variable    ${TS_BTS_COLLECTION_STARTED}    ${TRUE}
        EXCEPT    .*ExecutionError.*    type=regexp
            Log   Start SysLog Collection Failed    level=ERROR
        END
    ELSE
        Log    \nStart SysLog Collection: Failed, already started!    level=ERROR
    END

Stop SysLog Collection
    [Arguments]    ${subfolder}=${empty}
    IF    "${TP.ENABLE_SYSLOG}"=="true" and ${TS_BTS_COLLECTION_STARTED}
        Log    \nStop SysLog Collection ${subfolder}
        Set Test Variable    ${TS_BTS_COLLECTION_STARTED}    ${FALSE}
        TRY
            ${T_BTS_LOG_PATH}=    Stop Btslog    target_dir=${P_resultTestDir}/${subfolder}
            Set Test Variable    ${T_BTS_LOG_PATH}
            perf_log_collection.Queue Logs To Turandot    ${T_BTS_LOG_PATH}    archive_name=syslog    subfolder=${subfolder}
            ...    compress=${False}

            IF    "${TP.ENABLE_SYSLOG_PARSER}"=="true"
                ${_}    ${outfile}    Run Keyword And Warn On Failure    Verify Using Syslog Parser    syslog_file=${T_BTS_LOG_PATH}
                perf_log_collection.Queue Logs To Turandot    ${outfile}    archive_name=syslog_parser    subfolder=${subfolder}
                ...    tar=${True}
                OperatingSystem.Remove Directory    /home/ute/tmp_syslog    recursive=${True}
            END

        EXCEPT    .*ExecutionError.*        type=regexp
            Log    Syslog Collection Failed: ${subfolder}    level=ERROR
        END
    ELSE
         Log    Stop SysLog Collection ${subfolder}: Failed, not started!    level=ERROR
    END

Convert TTI traces
    [Timeout]    15mins
    IF    "${TP.ENABLE_TTI_TRACE_QUICK}"=="true"    Convert TTI Traces QUICK

Convert TTI Traces QUICK
    Log to console    Convert TTI Traces
    ${tti_st}    perf_timer.Start
    ${T_TTI_TRACE_PATH_QUICK_DF}     Convert TTI Trace To Dataframe    ${T_TTI_TRACE_PATH_QUICK}
    Set Test Variable        ${T_TTI_TRACE_PATH_QUICK_DF}
    perf_timer.Stop    msg=TTI Trace conversion:    start_time=${tti_st}

Convert TTI Traces Stream
    Log to console    Convert TTI Traces
    ${tti_st}    perf_timer.Start
    ${T_TTI_TRACE_PATH_DF}    Convert TTI Trace To Dataframe      ${T_TTI_TRACE_PATH}
    Set Test Variable        ${T_TTI_TRACE_PATH_DF}
    perf_timer.Stop    msg=TTI Trace conversion:    start_time=${tti_st}

Generate l2perf logs with py
    [Documentation]    lxc: 0x1730, asoe: 0x1518
    [Arguments]    ${logpath}=${P_resultTestDir}/l2perf    ${lxc}=${TP.CFG_L2PERF_LXC}    ${cpu}=${TP.CFG_L2PERF_CPU}
    ...            ${subfolder}=l2perf
    [Timeout]    20 mins
    Log To Console    Generate l2perf logs
    ${l2perf_base_path}    Set Variable    /home/ute/DEVELOPMENT/l2perf
    Run Keyword And Ignore Error    Remove File    ${l2perf_base_path}/l2perf.log
    ${lxc}    ${cpu}    l2perf.Resolve L2perf Defaults    ${lxc}    ${cpu}    ${TL_DATA['GNB_CAPU_TYPE']}    ${TL_DATA['GNB_CU_TYPE']}
    ${_}    ${logs}    Run Keyword And Warn On Failure    l2perf.Generate L2 Perf Logs Multi LXC
    ...                                                       ${lxc}    ${cpu}    logpath=${logpath}
    ...                                                       get_info_timeout=${L2PERF_GET_INFO_TIMEOUT}
    FOR    ${log}  IN    @{logs}
        perf_log_collection.Queue Logs To Turandot    ${log}   subfolder=${subfolder}
    END
    perf_log_collection.Queue Logs To Turandot    ${l2perf_base_path}/l2perf.log   subfolder=${subfolder}

Wait And Collect One Measurement Cycle
    [Arguments]    ${label}=default_traffic        ${subfolder}=${empty}    ${additional_time}=30
    IF    "${TP.ENABLE_PM_COUNTER}"=="false"
        Log    Skip PM Counter Collection: ${label}    console=${P_console}
        RETURN    ${None}
    END
    Log To Console    ${SPACE} - Wait and collect one measurement cycle: ${label}
    Wait For Next Measurement Period    ${label}    additional_time=${additional_time}
    ${pmfile}    Wait For Current Measurement        label=${label}    subfolder=${subfolder}    additional_time=${additional_time}
    RETURN    ${pmfile}

Wait For Next Measurement Period
    [Arguments]    ${label}=default_traffic    ${additional_time}=30

    ${variables}=  Get variables
    IF    "\${ENABLE_PM_COUNTER_${label}}" not in $variables
    ...               Set Test Variable    $ENABLE_PM_COUNTER_${label}    true

    IF    "${TP.ENABLE_PM_COUNTER}"=="false" or "${ENABLE_PM_COUNTER_${label}}"!="true"
        Log    Skip PM Counter Collection: ${label}    console=${P_console}
        RETURN    ${None}
    END

    ${variables}=  Get Variables
    Set Test Variable    $T_PM_FILES_LOCATION_${label}    ${None}

    Log To Console    ${SPACE} - Wait For Next Measurement Period: ${label}
    pmcounters.Wait Until The Next Measurement Period Starts    additional_time=${additional_time}

Wait for Current Measurement
    [Arguments]    ${label}=default_traffic    ${subfolder}=pmcounters   ${additional_time}=30
    ${variables}=  Get Variables
    IF    "\${ENABLE_PM_COUNTER_${label}}" not in $variables
    ...               Set Test Variable    $ENABLE_PM_COUNTER_${label}    false

    ${setting}    Catenate    \n - TP.ENABLE_PM_COUNTER:${TP.ENABLE_PM_COUNTER}\n - ENABLE_PM_COUNTER_${label}:${ENABLE_PM_COUNTER_${label}}
    IF    "${TP.ENABLE_PM_COUNTER}"=="false" or "${ENABLE_PM_COUNTER_${label}}"=="false"
        Log    Skip PM Counter Collection: ${label} ${setting}    console=${P_console}
        RETURN    ${None}
    END

    Log To Console    ${SPACE} - Wait for Current Measurement: ${subfolder} (${label})
    pmcounters.Wait Until The Current Measurement Period Stops    additional_time=${additional_time}
    ${pmfile}=    Collect PM Counter    target_dir=${P_resultTestDir}/${subfolder}    collector_alias=gnb_pm_counters_${label}
    Set Test Variable    $T_PM_FILES_LOCATION_${label}    ${pmfile}
    perf_log_collection.Queue Logs To Turandot    ${pmfile}/PM*    subfolder=${subfolder}    compress=${True}     is_dir=${False}
    ...                                           archive_name=pm_counters
    RETURN    ${T_PM_FILES_LOCATION_${label}}

Verify resource usage with suppress log
    [Arguments]    ${resources1}    ${resources2}    ${log_level}=ERROR    ${subfolder}=${EMPTY}    ${label}=default_traffix

    ${variables}    Get Variables    no_decoration=${True}
    FOR    ${counter}    IN RANGE    1    3    1
        IF    "resources_usage_${resources1}" not in $variables
            Log    undefined: resources_usage_${resources${counter}}    level=WARN
            RETURN    ${None}
        END
    END

    perf_resource_usage.generate_diff    ${resources1}    ${resources2}    subfolder=${subfolder}     label=${label}

    Set Log Level    ${log_level}
    IF    "${TP.ENABLE_RESOUCE_USAGE_VERIFY}"=="true"
            perf_resource_usage.Verify Resource Usage
            ...   ${resources_usage_${resources1}}
            ...   ${resources_usage_${resources2}}
            ...   label=${label}
            ...   subfolder=${subfolder}
    ELSE
          Run Keyword And Warn On Failure   perf_resource_usage.Verify Resource Usage
          ...   ${resources_usage_${resources1}}
          ...   ${resources_usage_${resources2}}
          ...   label=${label}
          ...   subfolder=${subfolder}
    END

    [Teardown]    Set Log Level    TRACE    # RF7 Reset Log Level


Start tcpdump traces
    [Documentation]  options: -i any sctp or icmp
    [Arguments]    ${collector}=default    ${options_testpc}=${EMPTY}    ${options_gnb}=${EMPTY}
    IF    "${TCPDUMP_RUNNING}"=="true"
        Log To Console    TCPDUMP already running, skipping (${collector})
        RETURN    ${None}
    END
    Log To Console    - Starting TCPDUMP traces: ${collector}
    tcpdump.Start Tcpdump on TestPc
    ...  options=${options_testpc}
    ...  collector=tcpdump_testpc_${collector}
    sleep     2s

    tcpdump.Start Tcpdump on gNB Common Unit
    ...  options=${options_gnb}
    ...  collector=tcpdump_gnb_${collector}
    # ...  gnb_id=0  du_id=0  comu_id=0
    sleep     2s

    Set Suite Variable      ${TCPDUMP_RUNNING}    ${collector}


Stop tcpdump traces
    [Arguments]    ${collector}=default    ${target_dir}=${P_resultTestDir}    ${subfolder}=${None}
    IF    "${TCPDUMP_RUNNING}"=="false"
        Log To Console    TCPDUMP not running, skipping (${collector})
        RETURN    ${None}
    ELSE IF   "${TCPDUMP_RUNNING}"!="${collector}"
        Log    TCPDUMP running with different collector (${TCPDUMP_RUNNING}), skipping stop for ${collector}   level=ERROR
        Log    Possible mismatch in start/stop collector names, stopping current collector (${TCPDUMP_RUNNING})     level=ERROR
        ${collector}    Set Variable    ${TCPDUMP_RUNNING}
    END
    Log To Console    - Stopping TCPDUMP traces: ${collector}
    ${tcpdump_testpc}=    tcpdump.Stop Tcpdump On TestPc    collector=tcpdump_testpc_${collector}    target_dir=${target_dir}
    ${tcpdump_gnb}=       tcpdump.Stop Tcpdump On GNB Common Unit    collector=tcpdump_gnb_${collector}    target_dir=${target_dir}

    perf_log_collection.Queue Logs To Turandot    ${tcpdump_testpc}
    ...                                          subfolder=${subfolder}

    perf_log_collection.Queue Logs To Turandot    ${tcpdump_gnb}
    ...                                          subfolder=${subfolder}

    Set Suite Variable      ${TCPDUMP_RUNNING}    false


Quick BIP Collection
    [Arguments]    ${gnb_id}=${0}
    ...            ${collector}=default
    ...            ${target_dir}=${P_resultTestDir}
    ...            ${duration}=${TP.CFG_LOG_QUICK_BIP_DURATION}
    ...            ${subfolder}=${EMPTY}
    Start BIP Collection    gnb_id=${gnb_id}    collector=bip_traces_${collector}

    Log To Console    Quick BIP Collection (${duration}): ${collector}
    Sleep    ${duration}    reason=BIP collection

    ${pcap_full_paths}    Stop BIP Traces and save to turandot    collector=bip_traces_${collector}
    ...                                                           target_dir=${target_dir}/${subfolder}
    ...                                                           subfolder=${subfolder}
    RETURN    ${pcap_full_paths}


Quick BIP Collection AP
    [Arguments]    ${ue_id}=0    ${comu_id}=0   ${option}=${EMPTY}    ${collector}=ue${ue_id}_bip_trace
    ...            ${target_dir}=${P_resultTestDir}
    ...            ${duration}=${TP.CFG_LOG_QUICK_BIP_AP_DURATION}
    ...            ${subfolder}=${EMPTY}
    Start BIP Collection AP    ue_id=${ue_id}    comu_id=${comu_id}   option=${option}    collector=${collector}

    Log To Console    Quick BIP Collection AP (${duration}): ${collector}
    Sleep    ${duration}    reason=BIP collection

    ${pcap_full_paths}    Stop BIP Traces AP And Save To Turandot    ue_id=${ue_id}    collector=${collector}
    ...                                                              target_dir=${target_dir}/${subfolder}
    ...                                                              subfolder=${subfolder}
    RETURN    ${pcap_full_paths}


Start BIP Collection
    [Arguments]    ${gnb_id}=${0}    ${collector}=default
    IF    not ${TS_BIP_COLLECTION_GNB_STARTED}
        bip_trace.Start BIP Traces With Taf Collector    collector=bip_traces_${collector}    gnb_id=${gnb_id}
        Set Test Variable    $TS_BIP_COLLECTION_GNB_STARTED    ${True}
    ELSE
        Log    BIP Trace Already started!    level=ERROR
    END


Stop BIP Traces And Save To Turandot
    [Arguments]    ${collector}=default
    ...            ${subfolder}=${EMPTY}
    ...            ${target_dir}=${P_resultTestDir}
    IF    ${TS_BIP_COLLECTION_GNB_STARTED}
        ${pcap_full_paths}    bip_trace.Stop BIP Traces With Taf Collector    collector=bip_traces_${collector}
        ...                                                                   target_dir=${target_dir}/${subfolder}
        Set Test Variable    $TS_BIP_COLLECTION_GNB_STARTED    ${False}

        FOR  ${pcap_full_path}  IN  @{pcap_full_paths}
            perf_log_collection.Queue Logs To Turandot    ${pcap_full_path}
            ...                                          subfolder=${subfolder}
        END
        RETURN    ${pcap_full_paths}
    ELSE
        Log    BIP Trace not started!    level=WARN
        RETURN    ${None}
    END


Start BIP Collection AP
    [Arguments]    &{kwargs}
    IF    not ${TS_BIP_COLLECTION_AP_STARTED}
        bip_trace_ap.Start Airphone BIP Traces    &{kwargs}
        Set Test Variable    $TS_BIP_COLLECTION_AP_STARTED    ${True}
    ELSE
        Log    BIP Trace AP Already started!    level=ERROR
    END


Stop BIP Traces AP And Save To Turandot
    [Arguments]    ${subfolder}=${EMPTY}    &{kwargs}
    IF    ${TS_BIP_COLLECTION_AP_STARTED}
        ${pcap_full_path}    bip_trace_ap.Stop Airphone BIP Traces    &{kwargs}
        Set Test Variable    $TS_BIP_COLLECTION_AP_STARTED    ${False}
        perf_log_collection.Queue Logs To Turandot    ${pcap_full_path}    subfolder=${subfolder}
        RETURN    ${pcap_full_path}
    ELSE
        Log    BIP Trace not started!    level=WARN
        RETURN    ${None}
    END



Start lxc top
    [Arguments]    ${containers}    ${hw}=gnb    ${target_dir}=${P_resultTestDir}    ${subfolder}=${empty}    ${csv}=${True}
    ...    ${filter}=cp_ue|cp_sb
    Log To Console    [LXC-1:0.${hw}] ${containers} Start Top
    ${core_alias}    Connect to Core
    lxc_top.start_lxc_top    ${containers}    ${target_dir}    subfolder=${subfolder}    hw=${hw}    filter=${filter}    csv=${csv}
    ...                      connection=${core_alias}    timeout=${None}

Stop lxc top and collect log
    [Arguments]    ${containers}    ${hw}=gnb    ${target_dir}=${P_resultTestDir}    ${subfolder}=${empty}
    Log To Console    [LXC-1:0.${hw}] ${containers} Stop Top
    ${core_alias}    Connect To Core
    lxc_top.stop_lxc_top    ${containers}    ${target_dir}    subfolder=${subfolder}    hw=${hw}
    ...                         connection=${core_alias}        timeout=${None}
    perf_log_collection.Queue Logs To Turandot    ${target_dir}/${subfolder}/top_threads*
    ...                                          subfolder=${subfolder}    archive_name=top_threads_output    tar=${True}

Start Perf Script
    [Arguments]    ${containers}    ${hw}=gnb
    Log To Console    [LXC-1:0.${hw}] ${containers} Start Perf Script
    ${core_alias}    connect.Connect to Core
    perf_script.start_perf_script    ${containers}    hw=${hw}
    ...                              pidof=cp_ue       connection=${core_alias}

Stop Perf Script
    [Arguments]    ${containers}    ${hw}=gnb    ${target_dir}=${P_resultTestDir}    ${subfolder}=${empty}
    Log To Console    [LXC-1:0.${hw}] ${containers} Stop Perf Script
    ${core_alias}    connect.Connect To Core
    perf_script.stop_perf_script    ${containers}    ${target_dir}    subfolder=${subfolder}    hw=${hw}
    ...                             connection=${core_alias}
    perf_log_collection.Queue Logs To Turandot    ${target_dir}/${subfolder}/perf_cpue_*
    ...                                          subfolder=${subfolder}    archive_name=perf_cpue    tar=${True}
