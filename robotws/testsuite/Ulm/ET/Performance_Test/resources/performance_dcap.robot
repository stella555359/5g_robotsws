*** Settings ***
Documentation  Keywords to collect DCAP Traces for performance Tests (used for EMIL CPlane Trace)

Resource    ../../../resources/Common/dcap.robot
Resource    performance_log_collection.robot

Library     python/perf_log_collection.py

Library     OperatingSystem

*** Variables ***

${docker_source}=  tts-docker-releases-local.artifactory-espoo2.int.net.nokia.com/bmi:FB2416.1-3282dfc228aa72a5a542ed710babd2c6a1aa71a5
${TC_dcap_started}=    ${false}

@{DCAP_PATHS}=    @{EMPTY}

*** Keywords ***

Start Container
    [Documentation]  Starts the DCAP container to get it ready for tracing. The 'docker_source' should be removed onece DCAP is fixed. (only WA)
    OperatingSystem.Run    utf_lab-hotfix install ${docker_source}
    Log    DCAP Container Starting!    console=${P_console}
    Start DCAP Container


Stop Container
    Stop DCAP Container


Start DCAP
    TRY
        Log    DCAP Collection Starting!    console=${P_console}
        Start DCAP Tracing  custom_profile=@{empty}    # emil traces if empty
        Set Test Variable    $TC_dcap_started    ${True}
    EXCEPT    .*status .failed. not in expected statuses .* for trace_id .* after .* seconds timeout    type=regexp
        Run Keyword And Continue On Failure    Fail    Failed to Start DCAP
    END


Stop And Collect DCAP
    [Arguments]    ${archive_name}=emil_traces    ${subfolder}=${empty}    ${sleep}=${TP.CFG_DCAP_SLEEP}
    IF    not ${TC_dcap_started}   RETURN
    Log    DCAP Collection Stopping!    console=${P_console}
    Stop DCAP Tracing
    Sleep    ${sleep}    reason=packaging
    ${log_path}=  Collect DCAP Traces  target_dir=${P_resultTestDir}/${subfolder}

    perf_log_collection.Queue Logs To Turandot    ${log_path}/*    archive_name=${archive_name}    subfolder=${subfolder}     tar=${True}

    Set Test Variable    $TC_dcap_started    ${false}
