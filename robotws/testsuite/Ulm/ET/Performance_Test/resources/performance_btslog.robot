*** Settings ***
Documentation    Test keyword resource file for Performance_Test

Library    taf.transport.ssh                            WITH NAME   ssh
Library    String

Library     ../../../resources/Common/syslog_parser/syslog_parser.py
Library     python/perf_log_collection.py

Resource    ../../../resources/Common/connect.robot
Resource    ../../resources/SQD60/sqd60_tools.robot

*** Variables ***
${IGNOREFILENAME}       ${CURDIR}/syslog_parser/SYSLOG_EXCEPTION.TXT
${ERRORDEFFILE}         ${CURDIR}/syslog_parser/SYSLOG_ARRAY.TXT


*** Keywords ***
Syslog Check Post F1 Setup
    Check DlSharedData Creation for X UEs

Print SRS info from BTS log
    ${srs_count}       Get SRS enabled UE count in btslog
    ${no_srs_count}    Get SRS absent UE count in btslog
    Log to console    SRS Info:\n${SPACE}- UE SRS OK count: ${srs_count}\n${SPACE}- UE SRS NOK count: ${no_srs_count}

Get SRS enabled UE count in btslog
    ${output}               Btslog Return Regexp    .PSRS. add ue .rnti.*srs resource successfully!
    ${number_of_matches}    String.Get Line Count    ${output}
    RETURN    ${number_of_matches}

Get SRS absent UE count in btslog
    ${output}               Btslog Return Regexp    Rnti.* srsResourceForBeamManagement is absent. Skip PER_SRS scheduling addition
    ${number_of_matches}    String.Get Line Count    ${output}
    RETURN    ${number_of_matches}

Check DlSharedData Creation for X UEs
    [Documentation]    Debug Only
    ${output}    Btslog Return Regexp    DlSharedData Creation for [0-9]* UEs   bts_log_path=/tmp/btslog2/SYSLOG_*.LOG
    Run Keyword And Warn On Failure    Should Contain    ${output}    DlSharedData Creation    msg=DlSharedData Creation Not found in syslog

Print Btslog grep
    [Arguments]    ${pattern}    ${bts_log_path}=/tmp/btslog2/syslog_files.tgz    ${args}=-H -ae
    ${output}    Btslog Return Regexp    ${pattern}    bts_log_path=${bts_log_path}    args=${args}
    Log To Console    \n${bar_a}\ngrep: ${pattern} \n${bar_b}\n${output}\n\n${bar_a}\n\n

Btslog Return Regexp
    [Documentation]    bts_log_path can be /tmp/btslog2/SYSLOG_*.LOG for current Logs
    ...                args can have -A 2  to also get the next line
    [Arguments]    ${pattern}    ${bts_log_path}=/tmp/btslog2/syslog_files.tgz    ${args}=-H -ae
    ${core_alias}     connect.Connect to Core
    ${output}         ssh.Execute    command=zgrep ${args} "${pattern}" ${bts_log_path}    connection=${core_alias}
    RETURN    ${output}

Verify Using Syslog Parser
    [Arguments]    ${syslog_file}=${T_BTS_LOG_PATH}    ${ignorefname}=${IGNOREFILENAME}
    ...            ${errordeffname}=${ERRORDEFFILE}
    IF    "${syslog_file}"=="${None}"
        Log    ${SPACE} Verify Using Syslog Parser: no syslog file!    level=WARN
        RETURN    ${none}
    END

    OperatingSystem.File Should Exist    ${ignorefname}         msg=ignorefname missing

    ${outfile}         syslog_parser.Find Errors And Warnings In Logfile And Write Them Into Resultfile
    ...                     ${syslog_file}
    ...                     ignorefname=${ignorefname}
    ...                     errordeffname=${errordeffname}
    ${result}    ${msg}    Run Keyword And Ignore Error    OperatingSystem.File Should Be Empty    ${outfile}
    IF    "${result}"=="FAIL"
        Log    ${SPACE} - SYSLOG PARSER - FAIL - ${msg}    level=WARN
    END
    RETURN    ${outfile}
