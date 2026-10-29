*** Settings ***
Documentation
...   All keywords are used in test cases for 5G BTS and UE testing.

...   author: Karolina Pacia Mateusz Potoniec
...   contact: karolina.pacia@nokia.com mateusz.potoniec@nokia.com
...   maintainer: karolina.pacia@nokia.com mateusz.potoniec@nokia.com

Library      DateTime                                                    WITH NAME    dt

Library      taf.sbts.oam.coam.admin                                     WITH NAME    admin
Library      ute_ue                                                      WITH NAME    ue

Library      taf.rfrl.bts.commissioning                                  WITH NAME    commission
Library      taf.rfrl.bts.devices.du.du_operations                       WITH NAME    du
Library      taf.rfrl.bts.devices.du.logs_collecting.basic_logs.GnbLog   WITH NAME    gnb_log
Library      taf.rfrl.ue.ue_attach_verification.UeAttachVerification     WITH NAME    ue_attach_verification
Library      taf.rfrl.ue.ute_ue_config.UteUeConfig                       WITH NAME    uteueconfig
Library      taf.rfrl.utilities.transfer_files                           WITH NAME    transfer_files

Library      ./suite_specific_keywords.py                                WITH NAME    suite_specific_keywords

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
${BTS_ID}=     ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs message to console
    ...                :param msg:     message logged
    ...                :datatime:    determines if include timestamp in log
    ...                :new_line_before:    determines if include new line before log
    ...                :new_line_after:    determines if include new line after log

    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   dt.Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Test Setup
    [Documentation]    Test setup, performing common preconditions
    Log Action to Console    Test Setup ==========================================
    Log Action to Console    Perform Common Preconditions
    Common Preconditions    verify_mandatory_scf_params=${False}
    ${time_before_test_start}=    Get Current Time
    Set Test Variable    ${TIME_BEFORE_TEST_START}    ${time_before_test_start}
    Log Action to Console    Test Procedure ======================================

Test Teardown
    [Documentation]    Test teardown, performing common postconditions

    ${snpshot_path}=    Get Snapshot from gNB
    Log Action To Console    Check Snapshot
    Check Snapshot    ${snpshot_path}    ${TIME_BEFORE_TEST_START}
    Log Action to Console    End Test Procedure ==================================
    Log Action to Console    Perform Common Postconditions
    Common Postconditions
    Log Action to Console    End Test ============================================   new_line_after=True

Test Setup UUF
    [Documentation]    Test setup, performing common preconditions and starting EGEN logs collector
    Test Setup
    Start Egen Logs Collector    timeout=36000
    Change actEcpriDelayMeasurement     True

Test Teardown UUF
    [Documentation]    Test teardown, performing common postconditions, stopping EGEN logs collector and checks it
    Change actEcpriDelayMeasurement    False
    ${egen_logs_path}=    Stop Egen Logs Collector and Download Logs
    Log Action To Console    Check Egen eCPRI Logs
    Check Egen eCPRI Logs    ${egen_logs_path}
    Test Teardown

Get Snapshot from gNB
    [Arguments]    ${bts_id}=0    ${snapshot_log_dir}=${OUTPUT_DIR}/
    [Documentation]    Get configuration file from gNB
    ...                :param bts_id:    ID of the gNB
    ...                :param scf_log_dir:    directory where config will be saved
    ...                :param snapshot_log_dir:    directory where logs will be saved

    ${snapshot_name}=    Set Variable    REST_GNB${bts_id}_DU0_snapshot.zip
    Log Action to Console    Collect Snapshot from gNB${bts_id}
    gnb_log.Collect Snapshot    bts_id=${bts_id}    log_dir=${snapshot_log_dir}   timeout=900    du_id=0
    ...                         snapshot_coverage=Full    snapshot_name=${snapshot_name}
    [return]    ${snapshot_log_dir}/${snapshot_name}

Start Egen Logs Collector
    [Arguments]    ${host}=SKA-ZH10-45-P08.p08.ska-lab.nsn-rdnet.net    ${file_name}=egen_logs.pcap
    ...            ${timeout}=600
    [Documentation]    The keyword starts EGEN logs collection.
    ...                :param host:    host name of EGEN logs collector
    ...                :param file_name:    name of EGEN logs collector
    ...                :param timeout:    timeout for EGEN logs collector, default: 600s

    Log Action To Console    Start Egen logs
    Start Egen Logs Collection
    ...    host=${host}
    ...    file_name=${file_name}
    ...    timeout=${timeout}

Stop Egen Logs Collector and Download Logs
    [Documentation]    The keyword stops EGEN logs collection.

    Log Action To Console    Stop Egen logs
    Stop Egen Logs Collection
    Log Action To Console    Collect Egen logs
    transfer_files.Download Files
    ...    local_dir=${OUTPUTDIR}
    ...    remote_file=egen_logs.pcap
    ...    device_name=EGEN
    ...    remote_dir=/home/egenuser

    [return]    ${OUTPUTDIR}/egen_logs.pcap

Require UE
    [Documentation]    The keyword performs UE commissioning and attach.
    Log Action To Console    Require UE
    ue.Require Ue    UE_1    capabilities=REAL_UE

Attach UE
    [Documentation]    The keyword performs attach and checks if attach was performed to desired cell of 5G BTS.
    Log Action To Console    Attach UE
    ue.Attach UE   UE_1     90
    Sleep  5s
    ${DESIRED_5G_CELL_ID}=   uteueconfig.Get 5G Starting Cell ID For  UE_1
    ue_attach_verification.Verify_SA_Attach    ue_alias=UE_1     pci_5g=${DESIRED_5G_CELL_ID}

Detach UE
    [Documentation]    The keyword performs UE detach.
    Log Action To Console    Detach UE
    ue.Detach Ue    UE_1    90

Start UDP DL and UL data transmission and verify results
    [Documentation]    The keyword starts UDP DL and UL data transmission and verifies results.

    Start UDP DL and UL data transmission for specified time  dl_throughput=200 Mbits/sec    ul_throughput=15 Mbits/sec
    ...      data_transfer_time=60s    dl_dt_name=DT_1_DL    ul_dt_name=DT_1_UL
    Await DL and UL data transmission finish                    dl_dt_name=DT_1_DL    ul_dt_name=DT_1_UL
    Stop DL and UL data transmission                            dl_dt_name=DT_1_DL   ul_dt_name=DT_1_UL
    Verify UDP DL and UL data transmission                      dl_throughput_for_verify=200 Mbits/sec
    ...                                                         ul_throughput_for_verify=15 Mbits/sec
    ...                                                         dl_deviation=10%
    ...                                                         ul_deviation=10%
    ...                                                         dl_dt_name=DT_1_DL    ul_dt_name=DT_1_UL

Start UDP DL and UL data transmission for specified time
    [Arguments]    ${dl_throughput}    ${ul_throughput}     ${data_transfer_time}
    ...            ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    Keyword starts UDP DL and UL traffic transmision for specified time.
    ...                Traffic is performed in downlink and uplink directions.
    ...                :dl_throughput:    throughput in downlink direction
    ...                :ul_throughput:    throughput in uplink direction
    ...                :param data_transfer_time:    data trasmission's time
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console     Start UDP DL and UL data transmission for ${data_transfer_time}
    ue.Start Data Transfer    dt_name=${dl_dt_name}    ue_alias=UE_1
    ...                       direction=dl    duration=${data_transfer_time}    protocol=udp
    ...                       throughput=${dl_throughput}    iperf_len=1320B    packet=1350B    buffer_server=16M
    ue.Start Data Transfer    dt_name=${ul_dt_name}    ue_alias=UE_1
    ...                       direction=ul    duration=${data_transfer_time}    protocol=udp
    ...                       throughput=${ul_throughput}    packet_size=1320    buffer_client=4M

Await DL and UL data transmission finish
    [Arguments]    ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    The keyword awaits DL and UL data transmission.
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console    Await DL and UL data transmission finish
    ue.Await Data Transfer Finish    ${dl_dt_name}
    ue.Await Data Transfer Finish    ${ul_dt_name}

Stop DL and UL data transmission
    [Arguments]    ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    The keyword stops DL and UL data transmission.
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=${dl_dt_name}
    ue.Stop Data Transfer    dt_name=${ul_dt_name}

Verify UDP DL and UL data transmission
    [Arguments]    ${dl_throughput_for_verify}    ${ul_throughput_for_verify}    ${dl_deviation}    ${ul_deviation}
    ...            ${dl_dt_name}=DT_1_DL    ${ul_dt_name}=DT_1_UL
    [Documentation]    Keyword checks if UDP throughput datagram loss is below max_allowed_datagram_loss.
    ...                Checking is performed in uplink and downlink directions.
    ...                :param dl_throughput_for_verify:    tuput in downlink direction for verify
    ...                :param ul_throughput_for_verify:    tuput in uplink direction for verify
    ...                :param dl_deviation:   deviation of tuput in downlink direction in percentage
    ...                :param ul_deviation:   deviation of tuput in uplink direction in percentage
    ...                :dl_dt_name:    name of throughput in downlink direction, default: DT_1_DL
    ...                :ul_dt_name:    name of throughput in downlink direction, default: DT_1_UL

    Log Action To Console    Verify UDP DL and UL data transmission
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}    tput=${dl_throughput_for_verify}
    ...                                            deviation=${dl_deviation}
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name}    tput=${ul_throughput_for_verify}
    ...                                            deviation=${ul_deviation}


Change actEcpriDelayMeasurement
    [Arguments]    ${value}
    [Documentation]    The keyword changes parameter MNL/MNLENT/FEATCADM.actEcpriDelayMeasurement to the specified value (True/False).
    ...                :param value:    value of parameter actEcpriDelayMeasurement, default: True

    Log Action To Console    Change actEcpriDelayMeasurement to ${value}
    ${boolean_value}=    Evaluate    bool(${value})
    gnbscf.perform_configuration_parameter_recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actEcpriDelayMeasurement    value=${boolean_value}
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${180}
    Sleep      15s
    Run Keyword If    ${boolean_value} == True    Wait until all cells are onair

Wait until all cells are onair
    [Arguments]    ${waiting_time}=60s   ${checking_interval}=15s
    [Documentation]    The keyword waits until all cells will be in on air.
    ...                :param waiting_time:    time to wait
    ...                :param checking_interval: time between checking

    Log Action To Console    Wait until all cells are onair
    Wait Until Keyword Succeeds    ${waiting_time}    ${checking_interval}
    ...    gnb_cells.Verify All Cells Statuses    du_id=0
    ...                                 operational_state=Enabled    procedural_status=configured
    ...                                 availability_status=Online    administrative_state=Unlocked

Set MRBTS ID
    [Documentation]    This keywords reads MRBTS ID and stores it in variable
    admin.Setup admin
    ${out_mrbts_id}=    admin.Get Bts Info
    Set Suite Variable    ${MRBTS_ID}    ${out_mrbts_id['mrbtsID']}
