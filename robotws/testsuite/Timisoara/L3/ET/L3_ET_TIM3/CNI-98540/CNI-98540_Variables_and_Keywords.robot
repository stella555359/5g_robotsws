*** Keywords ***

Syslog should not contain SPDLOG messages
    [Arguments]      ${SPDLOG_regex}
    log to console     Verifying SPDLOG messages not in syslog
    ${status} =   run    command=sudo cat ${OUTPUT_DIR}/suite_setup_logs/enb/default_syslog_enbNone.log | grep "${SPDLOG_regex}"
    Should Be Empty   ${status}
