*** Settings ***
Documentation    Test variables and keyword resource file for Snapshot

Library    OperatingSystem
Library    glob

Library    taf.file.pack    WITH NAME    file_pack

Library    python/perf_timer.py
Library    python/perf_log_collection.py
Library    python/counters.py

Resource    ../../../resources/Common/snapshot.robot
Resource    performance_turandot.robot

*** Keywords ***
Collect Snapshot from gnb and save to turandot
    [Arguments]    ${archive_prefix}=${empty}    ${subfolder}=${empty}    ${delay}=${TP.CFG_DELAY_SNAPSHOT_CAPTURE}
    Log To Console    Collect Snapshot: ${subfolder} (${archive_prefix})
    IF    "${delay}"!="0"
        Log to console    ${SPACE} - Delay snapshot collection: ${delay}
        Sleep     ${delay}    msg=Delay snapshot collection
    END
    ${ss_st}    perf_timer.start

    ${_}    ${snapshot_path}    Run Keyword And Warn On Failure    Collect Snapshot From gNB    target_dir=${P_resultTestDir}/${subfolder}
    perf_log_collection.Queue Logs To Turandot    ${snapshot_path}    archive_name=${archive_prefix}snapshot    subfolder=${subfolder}
    ...                                           compress=${False}

    perf_timer.Stop    msg=snapshot:    start_time=${ss_st}

    RETURN    ${snapshot_path}


Post Process Snapshot
    [Arguments]    ${snapshot_path}    ${archive_prefix}=${empty}    ${subfolder}=${empty}
    IF    "${TP.ENABLE_TIMEMARKER}"=="true"
        Run Keyword And Warn On Failure    Generate Timemarker    snapshot_path=${snapshot_path}
        ...                                                              archive_prefix=${archive_prefix}
        ...                                                              subfolder=${subfolder}
    END
    IF    "${TP.ENABLE_SNAPSHOT_PCAP_EXTRACT}"=="true"          Run Keyword And Warn On Failure
    ...                                                             Extract Pcap From Snapshot          ${snapshot_path}    subfolder=${subfolder}
    IF    "${TP.ENABLE_SNAPSHOT_CRASH_EXTRACT}"=="true"         Run Keyword And Warn On Failure
    ...                                                             Extract Crash From Snapshot         ${snapshot_path}    subfolder=${subfolder}
    IF    "${TP.ENABLE_SNAPSHOT_L2TTITRACE_EXTRACT}"=="true"    Run Keyword And Warn On Failure
    ...                                                             Extract L2TtiTrace From Snapshot    ${snapshot_path}    subfolder=${subfolder}
    IF    "${TP.ENABLE_SNAPSHOT_L2TRACELO_EXTRACT}"=="true"     Run Keyword And Warn On Failure
    ...                                                             Extract L2TraceLo From Snapshot     ${snapshot_path}    subfolder=${subfolder}
    IF    "${TP.ENABLE_SNAPSHOT_RDCOUNTER_TO_CSV}"!="null"      Run Keyword And Warn On Failure
    ...                                                             Extract RDCounter From Snapshot To CSV    ${snapshot_path}
    ...                                                                 ${TP.ENABLE_SNAPSHOT_RDCOUNTER_TO_CSV}     subfolder=${subfolder}


Generate Timemarker
    [Arguments]    ${snapshot_path}=${P_resultTestDir}/gnb-0-classical-snapshot/snapshot.zip
    ...            ${tm2chrome_py_path}=/home/ute/DEVELOPMENT/performance/scripts/timemarker/tm2chrome.py
    ...            ${archive_prefix}=${empty}
    ...            ${subfolder}=${empty}
    [Timeout]    20 mins
    ${tm_st}    perf_timer.Start
    Log    Generate HTML Timemarker    console=${True}
    ${timemarker_script}    Catenate    ${CURDIR}/bash/generate_timemarker.sh ${snapshot_path} ${tm2chrome_py_path}
    ...                                 | tee -a ${WORKSPACE}/archive/robot_bash.log
    ${core_alias}    connect.Connect to Core
    ${ret}    ssh.execute    command=${timemarker_script}    connection=${core_alias}

    @{files}     List Files In Directory    /tmp/time_marker/    pattern=*.html    absolute=${true}

    FOR    ${file}  IN    @{files}
        ${path}    ${filename}          Split Path    ${file}
        ${filename_delta}    Catenate      ${TEST_NAME}_${filename}
        Copy File            ${file}       ${P_resultTestDir}/time_marker/${filename_delta}
        Log                  ${SPACE}- ../time_marker/${filename_delta}    console=${P_console}
        perf_log_collection.Queue Logs To Turandot    ${P_resultTestDir}/time_marker/${filename_delta}
        ...                                          archive_name=${archive_prefix}${filename_delta}
        ...                                          subfolder=${subfolder}
    END
    IF    'generate_timemarker.sh done!' not in """${ret}"""
    ...    Log    ${SPACE} - Generate Timemarker failed!    level=WARN   console=${False}
    perf_timer.Stop    msg=timemarker:    start_time=${tm_st}

Extract Pcap From Snapshot
    [Arguments]    ${snapshot_path}    ${subfolder}=${EMPTY}    ${turandot}=${true}    ${compress}=true
    ${subfolder}    Set Variable If    "${subfolder}"=="${EMPTY}"    snapshot_pcap    snapshot_pcap/${subfolder}
    ${selection}    Create Dictionary        .=*
    ...                                      *=*coldreset*
    ...                                      **/*=*startup*
    ...                                      **=*pcap

    ${output_dir}    Extract From Archive    ${snapshot_path}    *pcap    ${selection}
    ...                                      subfolder=${subfolder}    turandot=${turandot}
    ...                                      compress=${compress}

    RETURN    ${output_dir}

Extract Crash From Snapshot
    [Arguments]    ${snapshot_path}    ${subfolder}=${EMPTY}    ${turandot}=${true}    ${compress}=true
    ${subfolder}    Set Variable If    "${subfolder}"=="${EMPTY}"    snapshot_crash    ${subfolder}/snapshot_crash
    ${selection}    Create Dictionary        .=*
    ...                                      *=*crashdump*

    ${output_dir}    Extract From Archive    ${snapshot_path}    *crashdump*    ${selection}
    ...                                      subfolder=${subfolder}    turandot=${turandot}
    ...                                      compress=${compress}

    ${files}     List Files In Directory    ${output_dir}
    ${status}    Run Keyword And Return Status    Directory Should Be Empty    ${output_dir}    msg=gNB crash ${files}
    IF    not ${status}    Log    gNB crash: ${files}\n    level=WARN

    RETURN    ${output_dir}

Extract L2TtiTrace From Snapshot
    [Arguments]    ${snapshot_path}    ${subfolder}=${EMPTY}    ${turandot}=${true}    ${compress}=true
    ${subfolder}    Set Variable If    "${subfolder}"=="${EMPTY}"    snapshot_L2TtiTrace    ${subfolder}/snapshot_L2TtiTrace
    ${selection}    Create Dictionary        .=*
    ...                                      *=*L2TtiTrace*

    ${output_dir}    Extract From Archive    ${snapshot_path}    *L2TtiTrace*    ${selection}
    ...                                      subfolder=${subfolder}    turandot=${turandot}
    ...                                      compress=${compress}

    RETURN    ${output_dir}

Extract L2TraceLo From Snapshot
    [Arguments]    ${snapshot_path}    ${subfolder}=${EMPTY}    ${turandot}=${true}    ${compress}=true
    ${subfolder}    Set Variable If    "${subfolder}"=="${EMPTY}"    snapshot_L2TraceLo    ${subfolder}/snapshot_L2TraceLo
    ${selection}    Create Dictionary        .=*
    ...                                      *=*L2TraceLo*

    ${output_dir}    Extract From Archive    ${snapshot_path}    *L2TraceLo*    ${selection}
    ...                                      subfolder=${subfolder}    turandot=${turandot}
    ...                                      compress=${compress}

    RETURN    ${output_dir}

Extract crash from SosReport
    [Arguments]    ${subfolder}=${EMPTY}    ${turandot}=${true}    ${compress}=true
    ${subfolder}    Set Variable If    "${subfolder}"=="${EMPTY}"    SosReport_crash    ${subfolder}/SosReport_crash
    ${files}=    glob.Glob    ${P_resultTestDir}/SosReport*.tgz
    ${selection}    Create Dictionary        .=*
    ...                                      *=*crash*
    ${output_dir}    Extract From Archive    ${files[0]}    *crash*    ${selection}
    ...                                      subfolder=${subfolder}    turandot=${turandot}
    ...                                      compress=${compress}

    ${files}     List Files In Directory    ${output_dir}
    ${status}    Run Keyword And Return Status    Directory Should Be Empty    ${output_dir}    msg=ap crash ${files}
    IF    not ${status}    Log    ap crash: ${files}\n    level=WARN

    RETURN    ${output_dir}

Extract From Archive
    [Arguments]    ${path}
    ...            ${pattern}    ${selection}
    ...            ${subfolder}=${EMPTY}    ${turandot}=${false}    ${compress}=true
    ${extract_st}    perf_timer.Start
    ${subfolder}    Set Variable If    "${subfolder}"=="${EMPTY}"    extract_default    ${subfolder}
    ${output_dir}    Set Variable    ${P_resultTestDir}/${subfolder}
    ${output_tmp}    Set Variable    ${P_resultTestDir}/tmp/${subfolder}

    OperatingSystem.Create Directory    ${output_dir}
    OperatingSystem.Create Directory    ${output_tmp}

    file_pack.Extract
    ...  path=${path}
    ...  output_dir=${output_tmp}
    ...  &{selection}

    ${files}=    glob.Glob    ${output_tmp}/**/${pattern}    recursive=True
    FOR    ${file}  IN    @{files}
        OperatingSystem.Move File     ${file}     ${output_dir}/
    END

    IF    ${turandot}    perf_log_collection.Queue Logs To Turandot    ${output_dir}    compress=${compress}
    ...                                                                       subfolder=${subfolder}    is_dir=${True}

    perf_timer.Stop    msg=Extract ${subfolder}:    start_time=${extract_st}

    RETURN    ${output_dir}


Extract RDCounter From Snapshot To CSV
    [Arguments]    ${snapshot_path}    ${counters}    ${subfolder}=${EMPTY}    ${turandot}=${True}    ${compress}=false
    ${csv_file}    counters.Snapshot To CSV    ${snapshot_path}     ${P_resultTestDir}/${subfolder}/rdcountrs.csv     ${counters}

    IF    ${turandot}    perf_log_collection.Queue Logs To Turandot    ${csv_file}    compress=${compress}
    ...                                                                       subfolder=${subfolder}
