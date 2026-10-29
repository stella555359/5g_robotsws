*** Settings ***
Documentation    Keywords for DCAP controller supported logging
...
...    Keywords for DCAP controller should not fail the test. All are escaped.
...
...    Use ``Setup Dcap`` for starting and connecting to DCAP controller.
...    Use ``Stop Dcap Controller`` to stop running DCAP controller.
...    Use ``Start Emil Trace`` to start tracing for BTS declared in BTS_INFO.
...    Traces are started if DCAP_RUNNING.
...    Use ``Stop Emil Trace And Get Results`` to stop and gather tracing results.
...    Traces are stopped and downloaded if EMIL_TRACE_ID was assigned.

Library    Collections
Library    OperatingSystem
Library    Process
Library    taf.sw.dcap.rd    WITH NAME    dcap


*** Variables ***
&{BTS_INFO}    host=10.0.1.2    port=443    username=Nemuadmin     password=nemuuser
${EMIL_TRACE_ID}    ${False}
${DCAP_RUNNING}    ${False}


*** Keywords ***
Setup Dcap
    [Documentation]    Start and connect to DCAP controller.
    ...    Additionally create BTS entry and fetch BTS and trace info.

    ${status}=    Start Dcap Controller
    IF    not $status    RETURN    ${False}
    ${vm_host_ip}=    Run    echo $(hostname -i)
    TRY
        dcap.Connect To
        ...    host=${vm_host_ip}
        ...    rd_version=dcapv3
        ...    port=9443
        ...    secure=${True}
        ...    timeout=${120}
        dcap.Create Bts    host=10.0.1.2
        dcap.Get All Bts Info
        dcap.Get All Trace Info
        Set Suite Variable    ${DCAP_RUNNING}    ${True}
    EXCEPT    AS    ${error}
        Log    Setting up DCAP failed with error: ${error}
    END

Start Dcap Controller
    [Documentation]    Start DCAP controller if not running.
    ...
    ...    DCAP controller is started with command:
    ...      - ``DCAP_Basic_controller    restart    --wait``
    ...    Option ``restart`` starts controller if not running and
    ...      restart if it runs incorrectly.
    ...    Option ``--wait`` ensure all processes are running.
    ...
    ...    DCAP controller status is verified with command:
    ...      - ``DCAP_Basic_controller status``
    ...    Command return codes:
    ...      - 16, DCAP controller not running
    ...      - 1, DCAP controller started but not running correctly
    ...      - 0, DCAP controller running correctly

    ${dcap_status}=    Process.Run Process    DCAP_Basic_controller    status
    IF    $dcap_status.rc!=${0}
        Log    DCAP controller is not running...\n${dcap_status.stdout}
        ${dcap_start}=    Process.Run Process    DCAP_Basic_controller    restart    --wait
        Log    Requested to re-start DCAP controller...\n${dcap_start.stdout}
        ${dcap_status}=    Process.Run Process    DCAP_Basic_controller    status
        IF    $dcap_status.rc==${0}    RETURN    ${True}
        Log    DCAP controller is not running...\n${dcap_status.stdout}
        RETURN    ${False}
    END
    RETURN    ${True}

Stop Dcap Controller
    [Documentation]    Stop DCAP controller if running.
    ...
    ...    DCAP controller is stoped with command:
    ...      - ``DCAP_Basic_controller    stop``
    ...
    ...    DCAP controller status is verified with command:
    ...      - ``DCAP_Basic_controller status``
    ...    Command return codes:
    ...      - 16, DCAP controller not running
    ...      - 1, DCAP controller started but not running correctly
    ...      - 0, DCAP controller running correctly

    ${dcap_status}=    Process.Run Process    DCAP_Basic_controller    status
    IF    $dcap_status.rc!=${16}
        Log    DCAP controller is running...\n${dcap_status.stdout}
        ${dcap_stop}=    Process.Run Process    DCAP_Basic_controller    stop
        Log    Requested to stop DCAP controller...\n${dcap_stop.stdout}
        ${dcap_status}=    Process.Run Process    DCAP_Basic_controller    status
        IF    $dcap_status.rc==${16}    RETURN    ${True}
        Log    DCAP controller is still running...\n${dcap_status.stdout}
        RETURN    ${False}
    END
    RETURN    ${True}

Start Emil Trace
    [Documentation]    Start EMIL trace for selected BTS.
    ...
    ...    EMIL tracing is started if DCAP was correctly set up.
    ...    EMIL tracing is started with custom profile by selecting cp_5g.
    ...    Tracing is started for BTS definied in BTS_INFO.

    IF    not $DCAP_RUNNING    RETURN    ${False}

    @{gnb_custom_profile}=    Create List    cp_5g
    TRY
        ${output}     dcap.Start Trace
        ...    bts=${BTS_INFO}
        ...    tag=start_emil_trace
        ...    timeout=${360}
        ...    force=${True}
        ...    gnb_custom_profile=${gnb_custom_profile}
        ...    wait_for_activation=${True}
        ...    allow_start_failures=${False}
        ${trace_id}=    Get From Dictionary    ${output}    tracer_id
        Set Suite Variable    ${EMIL_TRACE_ID}    ${trace_id}
    EXCEPT    AS    ${error}
        Log    Starting EMIL trace failed with error: ${error}
    END

Stop Emil Trace And Get Results
    [Documentation]    Stop EMIL trace and gather logs from current session.
    [Arguments]    ${logs_dir}=/home/ute/logs

    IF    not $EMIL_TRACE_ID    RETURN    ${False}

    TRY
        dcap.Stop Trace
        ...    trace_id=${EMIL_TRACE_ID}
        ...    timeout=${600}
        dcap.Get Results
        ...    result_id=${EMIL_TRACE_ID}
        ...    target_dir=${logs_dir}
        ...    timeout=${600}
    EXCEPT    AS    ${error}
        Log    Stopping EMIL trace failed with error: ${error}
    END
