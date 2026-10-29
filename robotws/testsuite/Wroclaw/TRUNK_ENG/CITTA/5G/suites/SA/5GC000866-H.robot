*** Settings ***
Documentation
...    The purpose of this test suite is to verify the Security compliant behaviour of gNB during
...    encrypted UL and DL transmission over a DRB, when the PDCP Layer detects that
...    the PDCP COUNT is about to wrap around, mechanism prevents the same security algorithm inputs to be reused
...    if PDCP COUNT were to roll over.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_WO_TTI    PY310    RF50


Resource    ../../resources/main_resources.robot
Variables    ${RESOURCES}/pm_counters_definitions.py
# -- extra resources --

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown  RUN KEYWORDS
...    Stop WTS    AND
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/5GC000866-H.resources

# -- test scenario variables --
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${DELTA_PATH}    ${RESOURCES}/delta_setup_ciphering.json
${RMODS_NUMBER}    4

*** Test Cases ***
5GC000866-H_-_Workaround_for_PDCP_COUNT_Roll-over_during_UL_Data_Transfer_over_DRB
    [Documentation]    This test verifies the Security compliant behaviour of gNB during encrypted UL transmission.
    [Setup]    [PRE]5GC000866-H_-_Workaround_for_PDCP_COUNT_Roll-over_during_UL_Data_Transfer_over_DRB
    [Teardown]    [POST]5GC000866-H_-_Workaround_for_PDCP_COUNT_Roll-over_during_UL_Data_Transfer_over_DRB
    SA 5G Attach UE"1"
    Estalbish two PDU sessions for UE1
    Start Traffic In SA Mode    ue=1    pdu=2    qfi=1    dir=ul    mbps=2
    Stop Collecting Tcpdump Logs    bearer_setup_UL
    Stop Tshark Capturing    UE_release_UL
    Check Bearer packet flow    bearer_setup_UL
    Check UE Release packet flow    UE_release_UL
    Verify Release of Bearer And PCPD Wraparound Counters

5GC000866-H_-_Workaround_for_PDCP_COUNT_Roll-over_during_DL_Data_Transfer_over_DRB
    [Documentation]    This test verifies the Security compliant behaviour of gNB during encrypted UL transmission.
    [Setup]    [PRE]5GC000866-H_-_Workaround_for_PDCP_COUNT_Roll-over_during_DL_Data_Transfer_over_DRB
    [Teardown]    [POST]5GC000866-H_-_Workaround_for_PDCP_COUNT_Roll-over_during_DL_Data_Transfer_over_DRB
    SA 5G Attach UE"2"
    Estalbish two PDU sessions for UE2
    Start Traffic In SA Mode    ue=2    pdu=4    qfi=1    dir=dl    mbps=2
    Stop Collecting Tcpdump Logs    bearer_setup_DL
    Stop Tshark Capturing    UE_release_DL
    Check Bearer packet flow    bearer_setup_DL
    Check UE Release packet flow    UE_release_DL
    Verify Release of Bearer And PCPD Wraparound Counters

*** Keywords ***
Test suite preconditions
    Add Flag To Swconfig    0x340000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Add Flag To Swconfig    0x9D0000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Reboot BTS    rmods_number=${RMODS_NUMBER}
    Commission eNB To SA Mode
    Delta Commissisoning    ${DELTA_PATH}
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[PRE]5GC000866-H_-_Workaround_for_PDCP_COUNT_Roll-over_during_UL_Data_Transfer_over_DRB
    Start Collecting Tcpdump    bearer_setup_UL
    Start Tshark packet capturing    UE_release_UL
    Get PM Counter Start Time

[POST]5GC000866-H_-_Workaround_for_PDCP_COUNT_Roll-over_during_UL_Data_Transfer_over_DRB
    SA 5G Detach UE"1"
    Report miscellaneous KPIs

[PRE]5GC000866-H_-_Workaround_for_PDCP_COUNT_Roll-over_during_DL_Data_Transfer_over_DRB
    Start Collecting Tcpdump    bearer_setup_DL
    Start Tshark packet capturing    UE_release_DL
    Get PM Counter Start Time

[POST]5GC000866-H_-_Workaround_for_PDCP_COUNT_Roll-over_during_DL_Data_Transfer_over_DRB
    SA 5G Detach UE"2"
    Report miscellaneous KPIs

# -- test steps --
Estalbish two PDU sessions for UE1
    Set Traffic Type For PDU"2" UE"1"
    SA Setup Primary PDU Session For PDU"1" UE"1" GW"1" NWSLICE"1"
    SA Setup Additional PDU Session For PDU"2" UE"1" GW"2" NWSLICE"1"

Estalbish two PDU sessions for UE2
    Set Traffic Type For PDU"4" UE"2"
    SA Setup Primary PDU Session For PDU"3" UE"2" GW"3" NWSLICE"1"
    SA Setup Additional PDU Session For PDU"4" UE"2" GW"4" NWSLICE"1"

Start Traffic In SA Mode
    [Arguments]    ${ue}    ${pdu}    ${qfi}    ${dir}    ${mbps}
    ${command}    SET VARIABLE    trf_data_start ue=${ue} pdu=${pdu} qfi=${qfi} dir=${dir} mbps=${mbps}
    ute_wtssim.execute_egate_command_and_wait_for_data    cmd=${command}    timeout=${__EGATE_COMMAND_TIMEOUT___}
    Sleep     60s

Check Bearer packet flow
    [Arguments]    ${alias}
    Setup Tshark Alias For Analyzing Pcap Logs    ${alias}
    ${E1AP_BEARER_MODIFICATION_REQUIRED}    ute_tshark.get_packets_count
    ...    packet_filter=e1ap.BearerContextModificationRequired_element && e1ap.radioNetwork == 5
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=${alias}
    ${E1AP_BEARER_MODIFICATION_CONFIRM}    ute_tshark.get_packets_count
    ...    packet_filter=e1ap.BearerContextModificationConfirm_element
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=${alias}
    ${F1AP_UE_CONTEXT_RELEASE_COMMAND}    ute_tshark.get_packets_count
    ...    packet_filter=f1ap.UEContextReleaseCommand_element
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=${alias}
    ${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    ute_tshark.get_packets_count
    ...    packet_filter=f1ap.UEContextReleaseComplete_element
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=${alias}
    ${E1AP_BEARER_RELEASE_COMMAND}    ute_tshark.get_packets_count
    ...    packet_filter=e1ap.BearerContextReleaseCommand_element
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=${alias}
    ${E1AP_BEARER_RELEASE_COMPLETE}    ute_tshark.get_packets_count
    ...    packet_filter=e1ap.BearerContextReleaseComplete_element
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=${alias}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${E1AP_BEARER_MODIFICATION_REQUIRED}==${1}
    ...    msg=Number of BEARER_MODIFICATION_REQUIRED packet are not as expected. Number of counted requests: ${E1AP_BEARER_MODIFICATION_REQUIRED}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${E1AP_BEARER_MODIFICATION_CONFIRM}==${1}
    ...    msg=Number of BEARER_MODIFICATION_CONFIRM packet are not as expected. Number of counted requests: ${E1AP_BEARER_MODIFICATION_CONFIRM}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${F1AP_UE_CONTEXT_RELEASE_COMMAND}==${1}
    ...    msg=Number of UE_CONTEXT_RELEASE_COMMAND packets are not as expected. Number of counted responses: ${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${F1AP_UE_CONTEXT_RELEASE_COMPLETE}==${1}
    ...    msg=Number of UE_CONTEXT_RELEASE_COMPLETE packets are not as expected. Number of counted responses: ${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${E1AP_BEARER_RELEASE_COMMAND}==${1}
    ...    msg=Number of BEARER_CONTEXT_RELEASE_COMMAND packets are not as expected. Number of counted responses: ${E1AP_BEARER_RELEASE_COMMAND}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${E1AP_BEARER_RELEASE_COMPLETE}==${1}
    ...    msg=Number of BEARER_CONTEXT_RELEASE_COMPLETE packets are not as expected. Number of counted responses: ${E1AP_BEARER_RELEASE_COMPLETE}
    [Teardown]    ute_tshark.teardown_tshark    alias=${alias}

Check UE Release packet flow
    [Arguments]    ${alias}
    ${NGAP_UE_RELEASE_REQUEST}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.UEContextReleaseRequest_element && ngap.radioNetwork == 38
    ...    alias=${alias}
    ${NGAP_UE_RELEASE_COMMAND}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.UEContextReleaseCommand_element
    ...    alias=${alias}
    ${NGAP_UE_RELEASE_COMPLETE}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.UEContextReleaseComplete_element
    ...    alias=${alias}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${NGAP_UE_RELEASE_REQUEST}==${1}
    ...    msg=Number of UE_RELEASE_COMMAND packet are not as expected. Number of counted requests: ${NGAP_UE_RELEASE_REQUEST}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${NGAP_UE_RELEASE_COMMAND}==${1}
    ...    msg=Number of UE_RELEASE_COMMAND packet are not as expected. Number of counted requests: ${NGAP_UE_RELEASE_COMMAND}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${NGAP_UE_RELEASE_COMPLETE}==${1}
    ...    msg=Number of UE_RELEASE_RELEASE packets are not as expected. Number of counted responses: ${NGAP_UE_RELEASE_COMPLETE}
    [Teardown]    ute_tshark.teardown_tshark    alias=${alias}

Verify Release of Bearer And PCPD Wraparound Counters
    Get PM Counter Collection Range Time
    Wait "120"s Untill PM Counters Are Available
    Verify Bearer and UE Counters

# -- internals --
Start Tshark packet capturing
    [Arguments]    ${alias}
    ${tshark_logs}    Prepare Logs Directory Path    tshark/${alias}    with_timestamp=${TRUE}
    ute_tshark.setup_tshark    interface=eth3    alias=${alias}    log_dir=${tshark_logs}    log_name=${alias}
    ute_tshark.start_capturing    capture_filter=sctp    alias=${alias}
    SLEEP    2    # << ensure all essential packets has been captured

Stop Tshark Capturing
    [Arguments]    ${alias}
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=${alias}

Start Collecting Tcpdump
    [Arguments]    ${tcpdump_file_name}
    SET SUITE VARIABLE    ${TCPDUMP_FILE_PATH_ON_GNB}    /tmp/${tcpdump_file_name}.pcap
    ${cmd}=    SET VARIABLE    ${__SSHPASS_TO_ENB_CMD__} "cd /tmp && tcpdump -i any -f sctp -U -w ${tcpdump_file_name}.pcap"
    Start Process    ${cmd}    shell=yes
    SLEEP    5    # << ensure all essential packets has been captured

Stop Collecting Tcpdump
    [Arguments]    ${tcpdump_file_name}
    ${kill_tcpdump_proces}=    SET VARIABLE
    ...    ps -ef | grep ${tcpdump_file_name}.pcap | grep -v grep | awk '{print $2}' | xargs kill -s SIGTERM
    Run On Smod    ${kill_tcpdump_proces}
    SLEEP    5    reason=Ensure tcpdump finished working after sending SIGTERM

Download Tcpdump File From GNB
    [Documentation]    Download tcpdump file from /tmp directory
    [Arguments]    ${tcpdump_file_name}
    ${TCPDUMP_logs}    Prepare Logs Directory Path    TCPDUMP_${tcpdump_file_name}
    SET SUITE VARIABLE    ${TCPDUMP_FILE}    ${TCPDUMP_logs}/${tcpdump_file_name}.pcap
    Fetch From Smod    ${TCPDUMP_FILE_PATH_ON_GNB}    ${TCPDUMP_FILE}
    Run On Smod    rm ${TCPDUMP_FILE_PATH_ON_GNB}

Stop Collecting Tcpdump Logs
    [Arguments]    ${tcpdump_file_name}
    SLEEP    5
    Stop Collecting Tcpdump    ${tcpdump_file_name}
    Download Tcpdump File From GNB    ${tcpdump_file_name}

Set Traffic Type For PDU"${pdu_number}" UE"${ue_id}"
    [Documentation]    Sets traffic type for given UEs and PDUSessionId
    ${command}    SET VARIABLE    set_pdu_param ue=${ue_id} pdu=${pdu_number} trf_type=internal
    ute_wtssim.execute_egate_command    cmd=${command}

Setup Tshark Alias For Analyzing Pcap Logs
    [Arguments]    ${alias}
    ute_tshark.setup_tshark
    ...    interface=eth3
    ...    alias=${alias}

Get PM Counter Start Time
    ${result}   pm_counter.get_current_pm_counter_time    round_direction=down
    SET TEST VARIABLE    ${START_NAME}    ${result}

Get PM Counter Collection Range Time
    ${stop}    pm_counter.get_current_pm_counter_time    round_direction=up
    @{range}    pm_counter.list_of_unix_minutes_between_dates    ${START_NAME}    ${stop}
    SET TEST VARIABLE    @{RANGE_TIME}    @{range}

Wait "${time}"s Untill PM Counters Are Available
    SLEEP    ${time}s

Verify Bearer and UE Counters
    FOR    ${counter}    IN    @{FEATURE_COUNTERS}
        ${pm_counter_path}    SET VARIABLE    ${counter['path']}/${counter['id']}
        ${pm_counters}    Get PM Counter "${pm_counter_path}" Measurements Untill Success
        ${result}    RUN KEYWORD AND CONTINUE ON FAILURE    pm_counter.get_sum_of_pm_counter_value_based_on_time
        ...    data=${pm_counters}
        ...    path=${pm_counter_path}
        ...    counter_time=${RANGE_TIME}
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    "${result}" == "${counter['amount']}"
        ...    msg=Amount of counter:${counter['id']} - ${counter['name']} (${result}) is not equal to ${counter['amount']}
    END
