*** Settings ***
Documentation
...    The purpose of this test case is to verify if attach, Intra-DU Inter-Cell handover procedure was performed successfully
...    for multi UEs and DL, UL throughput reaches the expected level

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_WO_TTI    PY310    RF50

Variables    ${RESOURCES}/dist_names.py

Resource    ../../resources/main_resources.robot
# -- extra resources --
Variables    ${RESOURCES}/messages_definition.py

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/CNI67972_Multi_UE_Handover.resources

${LUA}    ${RESOURCES}/epcsim.cfg
${DELTA}    ${RESOURCES}/delta_2.json

${DATA_TRAFFIC_VOLUME_MBPS_DL}    ${50}
${EXPECTED_TPUT_MBPS_DL}    ${240}
${DATA_TRAFFIC_VOLUME_MBPS_UL}    ${25}
${EXPECTED_TPUT_MBPS_UL}    ${120}
${UES_AMOUNT}     ${5}
${DATA_TRAFFIC_TIME_MINUTES}    ${10}
${RMODS_NUMBER}    4

*** Test Cases ***
CNI67972_Multi_UE_Intra_DU_Inter_Cell_Handover
    [Documentation]
    ...    This test case is designed to verify CNI67972 Multi-UE Mobility Traffic Robustness, using handover functionality,
    ...    introduced in sub feature 5GC000704-B
    [Setup]    [PRE]CNI67972_Multi_UE_Intra_DU_Inter_Cell_Handover
    [Teardown]    [POST]CNI67972_Multi_UE_Intra_DU_Inter_Cell_Handover
    Attach and setup PDU for UEs
    Start DL and UL traffic for UEs
    Verify DL and UL throughput for UEs using PM counters
    Perform Intra-DU Inter-Cell handover for UEs
    Verify successful Intra-DU Inter-Cell handover for UEs using PM counter
    Verify DL and UL throughput for UEs using PM counters

*** Keywords ***
Test suite preconditions
    Commission eNB To SA Mode

[PRE]CNI67972_Multi_UE_Intra_DU_Inter_Cell_Handover
    Add flag to swconfig    0x340000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Add Flag To Swconfig    0x9D0000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Reboot BTS    rmods_number=${RMODS_NUMBER}
    Delta commissisoning    ${DELTA}
    Start WTS    ${LUA}    check_version=False
    Check if BTS is OnAir

[POST]CNI67972_Multi_UE_Intra_DU_Inter_Cell_Handover
    Report miscellaneous KPIs
    Detach all UEs
    Stop WTS

# -- test steps --
Attach and setup PDU for UEs
    [Tags]    DESIGNSTEP
    FOR    ${id}    IN RANGE    1    ${UES_AMOUNT}+1
        SA 5G Attach UE"${id}"
        SA Set Traffic Type For PDU"${id}" UE"${id}"
        SA Setup Primary PDU Session For PDU"${id}" UE"${id}" GW"${id}" NWSLICE"1"
    END

Start DL and UL traffic for UEs
    [Tags]    DESIGNSTEP
    FOR    ${id}    IN RANGE    1    ${UES_AMOUNT}+1
        SA Start Traffic In SA Mode    pdu=${id}    ue=${id}    qfi=1    dir=dl    mbps=${DATA_TRAFFIC_VOLUME_MBPS_DL}
        SA Verify If Throughput Is Started    ue=${id}    pdu=${id}    qfi=1    dir=dl
        SA Start Traffic In SA Mode    pdu=${id}    ue=${id}    qfi=1    dir=ul    mbps=${DATA_TRAFFIC_VOLUME_MBPS_UL}
        SA Verify If Throughput Is Started    ue=${id}    pdu=${id}    qfi=1    dir=ul
    END
    SLEEP    11 minutes    reason=Generating traffic

Verify DL and UL throughput for UEs using PM counters
    [Tags]    DESIGNSTEP
    ${now}=    GET CURRENT DATE    result_format=epoch    exclude_millis=${TRUE}
    ${last_time_verified}=    GET VARIABLE VALUE    ${last_time_verified}    ${now}
    ${samples_number}=    RUN KEYWORD IF    ${now}==${last_time_verified}
    ...    SET VARIABLE    ${DATA_TRAFFIC_TIME_MINUTES}
    ...    ELSE    EVALUATE    int((${now} - ${last_time_verified})/60)

    ${pm_values}=    Get PM Counter "${THROUGHPUT_DL_PM_COUNTER_PATH}" Measurements Untill Success
    ${avg_traffic_volume}=    pm_counter.get_avg_pm_counter_value    ${pm_values}    ${THROUGHPUT_DL_PM_COUNTER_PATH}   ${samples_number}
    ${avg_tput_mbps}=    EVALUATE    ${avg_traffic_volume} * 8 / 1000 / 60
    SHOULD BE TRUE    ${avg_tput_mbps} >= ${EXPECTED_TPUT_MBPS_DL}
    ...    msg=Throughput less than expected ${EXPECTED_TPUT_MBPS_DL} mbps: ${avg_tput_mbps} mbps

    ${pm_values}=    Get PM Counter "${THROUGHPUT_UL_PM_COUNTER_PATH}" Measurements Untill Success
    ${avg_traffic_volume}=    pm_counter.get_avg_pm_counter_value    ${pm_values}    ${THROUGHPUT_UL_PM_COUNTER_PATH}   ${samples_number}
    ${avg_tput_mbps}=    EVALUATE    ${avg_traffic_volume} * 8 / 1000 / 60
    SHOULD BE TRUE    ${avg_tput_mbps} >= ${EXPECTED_TPUT_MBPS_UL}
    ...    msg=Throughput less than expected ${EXPECTED_TPUT_MBPS_UL} mbps: ${avg_tput_mbps} mbps

    SET TEST VARIABLE    ${last_time_verified}    ${now}

Perform Intra-DU Inter-Cell handover for UEs
    [Arguments]    ${pci}=51
    [Tags]    DESIGNSTEP
    ${tshark_handover_directory}=    Prepare Logs Directory Path    tshark/handover   with_timestamp=${FALSE}
    SET TEST VARIABLE    ${tshark_handover_logs}    ${tshark_handover_directory}
    FOR    ${id}    IN RANGE    1    ${UES_AMOUNT}+1
        ${TCPDUMP_FILE_PATH_ON_GNB}=    SET VARIABLE    /tmp/ue_${id}.pcap
        Start Capturing E1-F1 Packets    destination=${TCPDUMP_FILE_PATH_ON_GNB}
        Perform Intra-DU Inter-Cell handover for UE    ue_id=${id}    pci=${pci}
        Stop Capturing E1-F1 Packets    ${TCPDUMP_FILE_PATH_ON_GNB}    ${tshark_handover_logs}
    END

Verify successful Intra-DU Inter-Cell handover for UEs using PM counter
    [Tags]    DESIGNSTEP
    SLEEP    120    reason=Wait for generating at least one PM counter
    ${pm_values}=    Get PM Counter "${PM_COUNTER_INTRA_DU_INTER_CELL}" Measurements Untill Success
    ${sum_of_pm_values}=    pm_counter.get_sum_pm_counter_value    ${pm_values}    ${PM_COUNTER_INTRA_DU_INTER_CELL}    ${DATA_TRAFFIC_TIME_MINUTES}
    SHOULD BE TRUE    ${sum_of_pm_values} == ${UES_AMOUNT}
    ...    msg=Successful Intra-DU Inter-Cell handover didn't meet expected amount. Was: "${sum_of_pm_values}", expected: "${UES_AMOUNT}".
    FOR    ${id}    IN RANGE    1    ${UES_AMOUNT}+1
        RUN KEYWORD AND CONTINUE ON FAILURE    Verify Intra gNB Inter Cell Handover E1AP and F1AP   ue_id=${id}
    END

# -- internals --
Perform Intra-DU Inter-Cell handover for UE
    [Arguments]   ${ue_id}    ${pci}
    ${operation}=    SET VARIABLE    ue_measurement_send_nr
    ${pass_regexp}=    SET VARIABLE    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ${egate_cmd}=    SET VARIABLE    ${operation} id=${ue_id} meas_id=1 event=A5 phycell_id=${pci} nrsrp_nr=101 srsrp_nr=19
    RUN KEYWORD AND CONTINUE ON FAILURE    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${egate_cmd}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}

Start Capturing E1-F1 Packets
    [Arguments]    ${destination}
    ${cmd}=    SET VARIABLE    ${__SSHPASS_TO_ENB_CMD__} "tcpdump -U -i any -w ${destination} sctp"
    Start Process    ${cmd}    shell=yes
    SLEEP    2    reason=Ensure all essential packets has been captured

Stop Capturing E1-F1 Packets
    [Arguments]   ${pcap_path_on_gnb}    ${destination}
    ${kill_tcpdump_proces}=    SET VARIABLE
    ...    ps -ef | grep ${pcap_path_on_gnb} | grep -v grep | awk '{print $2}' | xargs kill -s SIGTERM
    SLEEP    2    reason=Ensure all essential packets has been captured
    Run On Smod    ${kill_tcpdump_proces}
    SLEEP    5    reason=Ensure tcpdump finished working after sending SIGTERM
    Fetch From Smod    ${pcap_path_on_gnb}    ${destination}
    Run On Smod    rm ${pcap_path_on_gnb}

Verify Intra gNB Inter Cell Handover E1AP and F1AP
    [Arguments]   ${ue_id}
    ute_tshark.setup_tshark
    ...    interface=eth3
    ...    alias=ue_${ue_id}
    ...    log_dir=${tshark_handover_logs}
    ...    log_name=ue_${ue_id}.pcap
    FOR    ${message}    IN    @{INTRA_DU_INTER_CELL_HO}
        ${packets_count}=    ute_tshark.get_packets_count
        ...    packet_filter=${message['filter']}
        ...    alias=ue_${ue_id}
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${packets_count}>=${1}
        ...    msg=Packet ${message['name']} is missing.
    END

Detach all UEs
    FOR    ${id}    IN RANGE    1     ${UES_AMOUNT}+1
        SA 5G Detach UE"${id}"
    END
