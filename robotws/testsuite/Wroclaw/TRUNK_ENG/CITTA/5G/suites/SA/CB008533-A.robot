*** Settings ***
Documentation
...    CB008533-A - feature introduces inter-band DL only Carrier Aggregation between Component Carrier in FDD band
...    as PCell and up to 3 Component Carriers as SCells in FDD and TDD FR1 bands.
...    After successful UE attach, throughput is stated and A1 event triggered.
...    It is expected that 3 SCells where added and 4CC CA combination configured.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LPQ_AP_LOO
Metadata    variant    SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_WO_TTI    PY310    RF50

Variables    ${RESOURCES}/dist_names.py
Variables    ${RESOURCES}/message_definition.py

Resource    ../../resources/main_resources.robot
Resource    ../../../resources/iphy/iphy.resource

# -- Setup / Teardown
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/CB008533-A.resources
${LUA}    ${RESOURCES}/egate.cfg
${SCFC}    ${RESOURCES}/scf.xml
${IPHY}    ${RESOURCES}/iphy.xml
${UE_ID}    ${1}
${NUMBER_OF_RMODS}    ${4}
${timeout}    ${1800}
${counter_ids}    M55138C03001,M55138C03002,M55124C02003
${M55138C03001_VALUE}    ${1}
${M55138C03002_VALUE}    ${1}
${M55124C02003_VALUE}    ${1}
${NUMBER_OF_MEASUREMENTS}    ${5}
${START_TPUT_MBPS}       ${175}
${TPUT_INTERVAL_MINUTES}    ${3}

*** Test Cases ***
CB008533-A-B3_Single_UE_call_A1_PCell_measurement_based_SCell_addition
    [Documentation]
    ...    This test case verifies the successful SCells addition after A1 event
    [Setup]    [PRE]CB008533-A-B3_Single_UE_call_A1_PCell_measurement_based_SCell_addition
    [Teardown]    [POST]CB008533-A-B3_Single_UE_call_A1_PCell_measurement_based_SCell_addition

    Attach and setup PDU for UE
    Start downlink traffic
    Verify throughput level before A1 event
    Trigger A1 measurement based SCell addition
    Verify throughput level after A1 event
    Get PM counters
    Verify if SCells were added correctly
    Verify if A1 event was received by gNB
    Verify deconfiguration of A1 measurement
    Verify configuration of A2 measurement
    Verify beam refinement for TDD SCells on RRC
    Verify beam refinement for TDD SCells on F1AP

*** Keywords ***
[PRE]CB008533-A-B3_Single_UE_call_A1_PCell_measurement_based_SCell_addition
    Add Flag To Swconfig    0x340000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Add Flag To Swconfig    0x9D0000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Apply Iphy Configuration    ${IPHY}
    Perform Commissioning    scfc_path=${SCFC}
    Check if BTS is correctly configured    ${NUMBER_OF_RMODS}    ${timeout}
    Start WTS    ${LUA}    check_version=False
    Check if BTS is OnAir
    Wait for counters generation to be started

[POST]CB008533-A-B3_Single_UE_call_A1_PCell_measurement_based_SCell_addition
    Report miscellaneous KPIs
    SA 5G Detach UE"${UE_ID}"
    Stop WTS

# -- test steps --
Attach and setup PDU for UE
    [Tags]    DESIGNSTEP
    SA 5G Attach UE"${UE_ID}"
    SA Set Traffic Type For PDU"1" UE"${UE_ID}"
    SA Setup Primary PDU Session For PDU"1" UE"${UE_ID}" GW"1" NWSLICE"1"
    Sleep    5s

Start downlink traffic
    [Tags]    DESIGNSTEP
    SA Start Traffic In SA Mode    pdu=1    ue=${UE_ID}    qfi=1    dir=dl    mbps=${START_TPUT_MBPS}

Verify throughput level before A1 event
    [Tags]    DESIGNSTEP
    SLEEP    75    reason=Wait for generating at least one PM counter
    Comment    We expect throughput on cell 1 only.
    ${avg_tput}=    Get Average Downlink Throughput    cell_id=1    time_in_minutes=${TPUT_INTERVAL_MINUTES}
    Should Be True    ${avg_tput} > 100    msg=Expected throughput greater than 100 mbps, but got ${avg_tput} mbps instead.
    FOR    ${cell_id}    IN    2    3    6
        ${avg_tput}=    Get Average Downlink Throughput    cell_id=${cell_id}    time_in_minutes=${TPUT_INTERVAL_MINUTES}
        Should Be Equal As Numbers    ${avg_tput}    0    msg=Unexpected throughput on cell ${cell_id}: ${avg_tput} mbps.
    END

Verify throughput level after A1 event
    [Tags]    DESIGNSTEP
    SLEEP    120    reason=Wait for generating at least one PM counter
    Comment    We expect throughput on each cell.
    FOR    ${cell_id}    IN    1    2    3    6
        ${avg_tput}=    Get Average Downlink Throughput    cell_id=${cell_id}    time_in_minutes=${TPUT_INTERVAL_MINUTES}
        Run Keyword And Continue On Failure    Should Be True    ${avg_tput} > 0    msg=No throughput on cell ${cell_id}.
    END

Trigger A1 measurement based SCell addition
    [Tags]    DESIGNSTEP
    Start collecting tcpdump    tcpdump_file_name=beam_refinement    # for F1AP packets
    ${tshark_logs}    Prepare Logs Directory Path    tshark/    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth4
    ...    alias=A1_event
    ...    log_dir=${tshark_logs}
    ...    log_name=A1_event.pcap
    ute_tshark.start_capturing    alias=A1_event    capture_filter=sctp
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} event=A1 meas_id=3 srsrq_nr=110 srsrp_nr=127
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    Sleep    5s
    ute_tshark.stop_capturing    alias=A1_event
    [Teardown]    Stop collecting tcpdump    tcpdump_file_name=beam_refinement

Get PM counters
    [Tags]    DESIGNSTEP
    ${connection}=    Set Variable    get_pm_counters
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    ${counters_info}=    admin.get_pm_counters    counter_ids=${counter_ids}    connection=${connection}
    SET SUITE VARIABLE    ${COUNTERS_INFO}    ${counters_info}

Verify if SCells were added correctly
    [Tags]    DESIGNSTEP
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55138C03001 counter
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55138C03002 counter

Verify if A1 event was received by gNB
    [Tags]    DESIGNSTEP
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55124C02003 counter

Verify deconfiguration of A1 measurement
    [Tags]    DESIGNSTEP
    ${A1_deconfig_packet}    ute_tshark.get_packets_count
    ...    packet_filter=${A1_DECONFIGURATION}[A1_REPORT_CONFIG_TO_REMOVE_LIST]
    ...    alias=A1_event
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE     ${A1_deconfig_packet}==${1}
    ...    msg=Amount of message (${A1_deconfig_packet}) is not equal to expected (1)

Verify configuration of A2 measurement
    [Tags]    DESIGNSTEP
    ${A2_config_packet}    ute_tshark.get_packets_count
    ...    packet_filter=${A2_CONFIGURATION}[A2_REPORT_CONFIG_TO_ADD_LIST]
    ...    alias=A1_event
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${A2_config_packet}==${1}
    ...    msg=Amount of message (${A2_config_packet}) is not equal to expected (1)

Verify beam refinement for TDD SCells on RRC
    [Tags]    DESIGNSTEP
    ${csi_report_config}    ute_tshark.get_packets_count
    ...    packet_filter=${BEAM_REFINEMENT_RRC}[RRC_CSI_REPORTING_CONFIG_FOR_SCELLS]
    ...    alias=A1_event
    ${csi_beam_refinement}    ute_tshark.get_packets_count
    ...    packet_filter=${BEAM_REFINEMENT_RRC}[CSI_RS_BEAM_REFINEMENT]
    ...    alias=A1_event
    ${pucch_config}    ute_tshark.get_packets_count
    ...    packet_filter=${BEAM_REFINEMENT_RRC}[PUCCH_CONFIG]
    ...    alias=A1_event
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${csi_report_config}==${1}
    ...    msg=Amount of message (${csi_report_config}) is not equal to expected (1)
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${csi_beam_refinement}==${1}
    ...    msg=Amount of message (${csi_beam_refinement}) is not equal to expected (1)
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${pucch_config}==${1}
    ...    msg=Amount of message (${pucch_config}) is not equal to expected (1)

Verify beam refinement for TDD SCells on F1AP
    [Tags]    DESIGNSTEP
    ute_tshark.setup_tshark    interface=any    alias=A1_event_F1AP    # to read saved pcaps
    LOG TO CONSOLE    \n------- Verify Messages------
    ${bwp_uplink}    ute_tshark.get_packets_count
    ...    packet_filter=${BEAM_REFINEMENT_F1AP}[BWP_UPLINK_DEDICATED]
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=A1_event_F1AP
    ${serving_cell}    ute_tshark.get_packets_count
    ...    packet_filter=${BEAM_REFINEMENT_F1AP}[SERVING_CELL_CONFIG]
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=A1_event_F1AP
    ${scell_config}    ute_tshark.get_packets_count
    ...    packet_filter=${BEAM_REFINEMENT_F1AP}[F1AP_SCELL_CONFIG_DEDICATED]
    ...    pcap_file_path=${TCPDUMP_FILE}
    ...    alias=A1_event_F1AP
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${bwp_uplink}==${1}
    ...    msg=Amount of message (${bwp_uplink}) is not equal to expected (1)
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${serving_cell}==${1}
    ...    msg=Amount of message (${serving_cell}) is not equal to expected (1)
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${scell_config}>=${1}
    ...    msg=Amount of message (${scell_config}) is not equal to expected (>=1)
    ute_tshark.teardown_tshark    alias=A1_event_F1AP

# -- internals --
Get Average Downlink Throughput
    [Documentation]    Returns average throughput (in mbsp) for given `cell_id` over `time_in_minutes`.
    ...    Calculation is based on M55309C12001 counter value, with assumption that PM counters are collected every minute.
    [Arguments]    ${cell_id}    ${time_in_minutes}
    ${avg_tput_bytes}    Get Average Value Of PM Counter    ${M55309C12001_CELL_${cell_id}}    ${time_in_minutes}
    ${avg_tput_mbps}    Evaluate    ${avg_tput_bytes} * 8 / 1000000
    [Return]    ${avg_tput_mbps}

Wait for counters generation to be started
    comment    Waiting for distName creation for the counter (BTS/CELLS/NRCELL-1/RSACU/M55138C03001)
    Wait Until Keyword Succeeds    20x    15s    Get PM Counter "${M55138C03001_PATH}" Measurements

Verify M55138C03001 counter
    ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}    ${M55138C03001_PATH}   ${NUMBER_OF_MEASUREMENTS}
    ${error_msg}=    Catenate
    ...    The number of PCell UEs with 1 activated SCell in DL didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "${M55138C03001_VALUE}".
    SHOULD BE TRUE    ${actual_value} == ${M55138C03001_VALUE}
    ...    msg=${error_msg}

Verify M55138C03002 counter
    ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}   ${M55138C03002_PATH}    ${NUMBER_OF_MEASUREMENTS}
    ${error_msg}=    Catenate
    ...    The number of SCell activations didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "${M55138C03002_VALUE}".
    SHOULD BE TRUE    ${actual_value} == ${M55138C03002_VALUE}
    ...    msg=${error_msg}

Verify M55124C02003 counter
    ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}    ${M55124C02003_PATH}   ${NUMBER_OF_MEASUREMENTS}
    ${error_msg}=    Catenate
    ...    The number of RRC measurement report messages received with A1 measurement report didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "${M55124C02003_VALUE}".
    SHOULD BE TRUE    ${actual_value} == ${M55124C02003_VALUE}
    ...    msg=${error_msg}

Start collecting tcpdump
    [Arguments]    ${tcpdump_file_name}
    SET SUITE VARIABLE    ${TCPDUMP_FILE_PATH_ON_GNB}    /tmp/${tcpdump_file_name}.pcap
    ${cmd}=    SET VARIABLE    ${__SSHPASS_TO_ENB_CMD__} "cd /tmp && tcpdump -i any -f sctp -U -w ${tcpdump_file_name}.pcap"
    Start Process    ${cmd}    shell=yes
    SLEEP    5    # << ensure all essential packets has been captured

Stop collecting tcpdump
    [Arguments]    ${tcpdump_file_name}
    SLEEP    5
    Stop Tcpdump    ${tcpdump_file_name}
    Download Tcpdump File From GNB    ${tcpdump_file_name}

Stop Tcpdump
    [Arguments]    ${tcpdump_file_name}
    ${kill_tcpdump_proces}=    SET VARIABLE
    ...    ps -ef | grep ${tcpdump_file_name}.pcap | grep -v grep | awk '{print $2}' | xargs kill -s SIGTERM
    SLEEP    3
    Run On Smod    ${kill_tcpdump_proces}

Download Tcpdump File From GNB
    [Documentation]    Download tcpdump file from /tmp directory
    [Arguments]    ${tcpdump_file_name}
    ${TCPDUMP_logs}    Prepare Logs Directory Path    TCPDUMP_${tcpdump_file_name}
    SET SUITE VARIABLE    ${TCPDUMP_FILE}    ${TCPDUMP_logs}/${tcpdump_file_name}.pcap
    Fetch From Smod    ${TCPDUMP_FILE_PATH_ON_GNB}    ${TCPDUMP_FILE}
    Run On Smod    rm ${TCPDUMP_FILE_PATH_ON_GNB}
