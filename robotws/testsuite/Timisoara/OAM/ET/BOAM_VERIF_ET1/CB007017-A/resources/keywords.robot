*** Variables ***

${delta_file_enable_RTPM}=                    ${CURDIR}/../resources/enable_RTPM.json
${delta_file_disable_RTPM}=                   ${CURDIR}/../resources/disable_RTPM.json
${delta_file_change_RTPM_step2}=              ${CURDIR}/../resources/change_RTPM_step2.json
${delta_file_change_RTPM_step4}=              ${CURDIR}/../resources/change_RTPM_step4.json
${delta_file_change_RTPM_step7}=              ${CURDIR}/../resources/change_RTPM_step7.json
${delta_file_none_selected}=                  ${CURDIR}/../resources/nrRTPM_none_selected.json
${delta_file_one_selected}=                   ${CURDIR}/../resources/nrRTPM_one_selected.json
${delta_file_wrong_IP}=                       ${CURDIR}/../resources/wrong_IP_RTPM-CE.json
${delta_file_wrong_port}=                     ${CURDIR}/../resources/wrong_port_RTPM-CE.json
${delta_file_miNrEcpriUpFCp_disabled}=        ${CURDIR}/../resources/miNrEcpriUpFCp.json
${delta_file_miNrEcpriUpFCp_enabled}=          ${CURDIR}/../resources/miNrEcpriUpFCp_enabled.json

${gnb_path}    /user/toor4nsn
#${gnb_filter}   port 39001 and "tcp[tcpflags] & (tcp-ack) != 0"
${interface}    any

*** Keywords ***
EMSSIM RTPM Counters are available
    Log to console   Check counters for NRCELL object
    FOR  ${counter}  IN  @{rtpm_counters_list_nrcell}
        EMSSIM RTPM Counter exists      ${counter}   NRCELL-1
    END

    Log to console   Check counters for NRBTS object
    FOR  ${counter}  IN  @{rtpm_counters_list_nrbts}
        EMSSIM RTPM Counter exists      ${counter}   NRBTS-1
    END

    Log to console   Check counters for NRCUUP object
    FOR  ${counter}  IN  @{rtpm_counters_list_nrcuup}
        EMSSIM RTPM Counter exists      ${counter}   NRCUUP-1
    END

    Log to console   Check counters for NRDU object
    FOR  ${counter}  IN  @{rtpm_counters_list_nrdu}
        EMSSIM RTPM Counter exists      ${counter}   NRDU-1
    END

    Log to console   Check counters for MNLENT object
    EMSSIM RTPM Counter exists  ${rtpm_counters_list_mnlent}   MNLENT-1

Step 10 to step 13
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4203  timeout=180
    ADMIN CLI connection
    gNB Site Reset
    Wait Until Keyword Succeeds  500  20    ADMIN Check BTS onair

    Log to console   Step 11: Check that after site reset, FID 4203 is visible
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4203  timeout=180

    Log to console   Step 12: BTS continues to collect counters but they are not sent until the connection is established
    Check wireshark log   logname=TC2_step12.dcap
    ...                   message_filter=port 39001 and "tcp[tcpflags] & (tcp-fin) != 0"
    ...                   read_output=[F.]
    Run Keyword And Expect Error   RTPM files did not appear before timeout   EMSSIM RTPM counters are cleared

    Log to console   Step 13: Correct the RTPM-CE IP address
    Start Capture Wireshark Logs on gNB    rtpmlogname=TC2_step13.dcap    interface=${interface}
    ADMIN Perform Delta Recommissioning    delta_file=${delta_file_enable_RTPM}
    Log to console   FID 4203 is cleared and PM counters are being sent
    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=4203  timeout=120
    EMSSIM RTPM counters received
    Stop Capture Wireshark Logs on gNB    rtpmlogname=TC2_step13.dcap
    Log to console   Check that connection is established automatically
    Check wireshark log   logname=TC2_step13.dcap
    ...                   message_filter=port 39001 and "tcp[tcpflags] & (tcp-ack) != 0"
    ...                   read_output=[P.]


Wireshark capture on gNB
    [Arguments]       ${logname}    ${gnbfilter}   ${read_output}
    Start Capture Wireshark Logs on gNB    rtpmlogname=${logname}    interface=${interface}
    Sleep  60s
    Stop Capture Wireshark Logs on gNB    rtpmlogname=${logname}
    Check wireshark log   logname=${logname}   message_filter=${gnb_filter}   expected=${read_output}


Start Capture Wireshark Logs on gNB
    [Arguments]     ${rtpmlogname}    ${interface}
    Log To Console    Start Capture Wireshark Logs on gNB
    RUN KEYWORD AND IGNORE ERROR    gNB connections
    taf.transport.ssh.send command    command=tcpdump -i ${interface} -w ${gnb_path}/${rtpmlogname}
    ...                               connection=${SYSTEM_ALIAS_ASIL}

gNB connections
    [Arguments]    ${hostname}=${LMP_IP}
    ...            ${username}=${ROOT_USERNAME}
    ...            ${password}=${ROOT_PASSWORD}
    ...            ${alias}=${SYSTEM_ALIAS_ASIL}
    taf.transport.ssh.connect_to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${rtpmlogname}
    Log To Console    Stop Capture Wireshark Logs on gNB
    gNB connections
    sleep    5
    taf.transport.ssh.send command    command=killall tcpdump
    ...                               connection=${SYSTEM_ALIAS_ASIL}
    sleep    3
    taf.transport.ssh.download_file   remote_path=${gnb_path}/${rtpmlogname}
    ...                               local_path=${OUTPUT_DIR}/${TEST_NAME}/${rtpmlogname}
    ...                               connection=${SYSTEM_ALIAS_ASIL}
    sleep    3

Check wireshark log
    [Arguments]    ${logname}    ${message_filter}    ${read_output}
    ...            ${results_dir}=${OUTPUT_DIR}/${TEST_NAME}
    Log To Console    Check wireshark log
    ${cmd}=  catenate  SEPARATOR=   tcpdump -ttttnnr ${gnb_path}/${logname} -ni any ${message_filter}
    gNB connections
    ${output}     taf.transport.ssh.execute     command=${cmd}    connection=${SYSTEM_ALIAS_ASIL}
    should contain   ${output}   ${read_output}
    Log to console   ${output}

