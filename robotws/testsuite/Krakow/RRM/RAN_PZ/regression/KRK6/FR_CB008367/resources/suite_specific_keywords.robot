*** Settings ***

Documentation
...  author:  Piotr Brzezicki, Marcin Wachacki
...  contact: piotr.brzezicki@nokia.com, marcin.wachacki@nokia.com

Library   taf.rfrl.utilities.test_config
Library   OperatingSystem                                                             WITH NAME    os
Library   ArchiveLibrary                                                              WITH NAME    arch
Library   DateTime                                                                    WITH NAME    dt
Library   taf.ue                                                                      WITH NAME    ue
Library   taf.collectors.l2stream3
Library   ute_fsmaccess
Library   ta5g_pm_counters                                                            WITH NAME    pmcount
Library   taf.rfrl.bts.commissioning                                                  WITH NAME    commissioning
Library   taf.rfrl.bts.devices.du.du_operations.GenericDuOperations  bts_type=GNB     WITH NAME    du_oper
Library   taf.rfrl.utilities.test_config.DefaultFileLocation                          WITH NAME    dfl
Library   testsuite/Krakow/RRM/RAN_PZ/resources/pcap_verification/flow_verifier.py    WITH NAME    flow_verifier
Library   ./suite_specific_keywords.py                                                WITH NAME    sskpy
Library   ./cce_split_verifier.py                                                     WITH NAME    cce_split
Library   ./smart_attenuator.py                                                       WITH NAME    attenuator

Resource  taf/rfrl/bts/robot/gnb.robot
Resource  taf/rfrl/common_resources/common_step/interface.robot
Resource  testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot
Resource  taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
@{GNB_1_CELL_1_RF_PORTS}    ${5}    ${6}
@{OTHER_GNB_RF_PORTS}       ${7}    ${8}
${SYSLOG_GATHER_TIME}       20s
${DATA_TRANSFER_MAX_LOSS}   20%


*** Keywords ***
CB008367 Suite Setup
    [Documentation]    Suite setup of CB008367 feature.
    Log Action To Console   Suite Setup
    Set cell IDs
    ${HOSTNAME}=    taf.rfrl.utilities.tl_config.Get Testline Name
    ${RELEASE}=     dfl.Get Commissioning Branch
    Set Suite Variable    ${RELEASE}
    Set Suite Variable    ${CB008367_C101_SCF}    commissionings/Krakow/${HOSTNAME}/${RELEASE}/CB008367_C101_GNB0_SCF_gps.xml
    Set Suite Variable    ${CB008367_C201_SCF}     commissionings/Krakow/${HOSTNAME}/${RELEASE}/CB008367_C201_GNB0_SCF_gps.xml
    Run Keyword And Ignore Error     gnb_cell.Lock All Cells    gnb_id=1    administrative_state=${True}
    sskpy.Remove unused gNB from tl robot variable
    du_oper.Upload swconfig    commissionings/Krakow/${HOSTNAME}/${RELEASE}/CB008367_swconfig.txt
    Common Suite Setup    check_truck_roll=${True}

CB008367 Test Setup
    [Arguments]   ${scf_path}
    [Documentation]    Common setup for CB008367 test cases.
    ...                :param scf_path:     path to SCF
    Log Action To Console    Test Setup
    taf.rfrl.utilities.test_config.Set Test Case Log Path
    taf.rfrl.utilities.test_config.Get Log Path
    Set test variable    ${SYSLOG_DIRECTORY}     ${LOG_PATH}/syslog
    Set test variable    ${COUNTER_DIRECTORY}    ${LOG_PATH}/counters
    Set test variable    ${COUNTER_LOCALMOID}
    ...                  PLMN-PLMN/MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${gnb1_cell1_nrcellid}
    Commission And Wait For onAir   scf_path=${scf_path}
    Setup Attenuation
    Setup UEs
    Wait For Next Full Pm Counter Interval
    Setup Syslog Collector    ${SYSLOG_DIRECTORY}

CB008367-C101 Test Teardown
    Log Action To Console    Test Teardown
    Run Keyword And Ignore Error    Stop Data Transfers for 2 UEs
    Run Keyword And Ignore Error    Deregister 2 UEs
    Common Postconditions

Commission and wait for onAir
    [Arguments]   ${scf_path}
    [Documentation]    Performs commissioning and wait for testline onAir state.
    ...                :param scf_path:     path to SCF
    Log Action To Console    Commission and wait for onAir
    commissioning.Perform Full Commissioning On Classical Gnb    bts_id=0   scf_path=${scf_path}
    Wait Until Keyword Succeeds    600    20    gnbcell.Verify All Cells Are Onair    bts_id=0

Set cell IDs
    [Documentation]    Collects ID of cells from main gNB and sets as global variables.
    ${gnb1_cell1_parameters}=    gnbcell.Get Cell Parameters    bts_id=0    cell_id=${1}    du_id=0
    Set Suite Variable    ${gnb1_cell1_pci}      ${gnb1_cell1_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell1_nrcellidentity}         ${gnb1_cell1_parameters['nrCellIdentity']}
    Set Suite Variable    ${gnb1_cell1_nrcellid}         1

Setup UEs
    ue.Require Ue    UE_1  capabilities=REAL_ANDROID_UE
    ue.Require Ue    UE_2  capabilities=REAL_ANDROID_UE_S22

Setup Attenuation
    [Documentation]    Initializes attenuator and turn off attenuation for cell 1.
    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=RADIO_RACK_01
    ${ports}=     Combine Lists   ${GNB_1_CELL_1_RF_PORTS}   ${OTHER_GNB_RF_PORTS}
    ${values}=    Create List     0dB    0dB    110dB    110dB
    attenuator.Set Ports Attenuation    RADIO_RACK_01    ${ports}    ${values}

Register 2 UEs in SA cell
    Log Action To Console    Register UE1 UE2
    Attach Ue    UE_1    ${gnb1_cell1_nrcellidentity}
    Attach Ue    UE_2    ${gnb1_cell1_nrcellidentity}

Deregister 2 UEs
    Log Action To Console    Deregister UE1 UE2
    ue.Detach Ue    UE_1
    ue.Detach Ue    UE_2

Start data transfer for UEs that UE1 is in Large BWP and UE2 in PS BWP
    Log Action To Console    Starting data transfer on UE1 and UE2
    Start Data Transfer    dt_name=UL_UE_1_DT   ue_alias=UE_1    direction=ul
    ...                    protocol=udp    throughput=50Mbits/sec   packet_size=1350B
    Start Data Transfer    dt_name=DL_UE_1_DT    ue_alias=UE_1    direction=dl
    ...                    protocol=udp    throughput=100Mbits/sec    iperf_len=1350B    packet=1350B
    Start Data Transfer    dt_name=UL_UE_2_DT   ue_alias=UE_2    direction=ul
    ...                    protocol=udp    throughput=4kbits/sec   packet_size=120B
    Start Data Transfer    dt_name=DL_UE_2_DT    ue_alias=UE_2    direction=dl
    ...                    protocol=udp    throughput=10kbits/sec    iperf_len=120B    packet=120B

Collect syslog for short time and verify that CCE split is not enabled in 2 dedicated BWPs
    Start collecting syslog
    Wait    ${SYSLOG_GATHER_TIME}
    Stop collecting syslog    ${SYSLOG_DIRECTORY}/feature_disabled
    ${absolute_syslog_direcotry_path}=    Get absolute syslog direcotry path    log_dir=${SYSLOG_DIRECTORY}/feature_disabled
    Verify syslog DynamicPdcchLogger reports    syslog_dir=${absolute_syslog_direcotry_path}    change_ratio=0    bwp_idx=1
    Verify syslog DynamicPdcchLogger reports    syslog_dir=${absolute_syslog_direcotry_path}    change_ratio=0    bwp_idx=2

Wait until PM Counter interval and check that M55335C02016/M55335C02011 is 0
    Wait For Next Full Pm Counter Interval
    ${absolute_counter_file_path}=    Collect PM Counters    ${COUNTER_DIRECTORY}/feature_disabled
    ${counter_id}=    Set Variable If    '${RELEASE}'=='TRUNK'    M55335C02019    M55335C02019
    Verify PM Counter value is equal to given    counter_id=${counter_id}    expected_value=0
    ...                                          counter_localmoid=${COUNTER_LOCALMOID}     log_file=${absolute_counter_file_path}

Collect syslog for short time and verify that CCE split is enabled in Large BWP
    Start collecting syslog
    Wait    ${SYSLOG_GATHER_TIME}
    Stop collecting syslog    ${SYSLOG_DIRECTORY}/feature_enabled
    ${absolute_syslog_direcotry_path}=    Get absolute syslog direcotry path    log_dir=${SYSLOG_DIRECTORY}/feature_enabled
    Verify syslog DynamicPdcchLogger reports    syslog_dir=${absolute_syslog_direcotry_path}    change_ratio=60    bwp_idx=1

Stop and verify data transfers for 2 UEs
    Stop Data Transfers for 2 UEs
    Log Action To Console    Verifing data transfer for UE1 UE2
    Verify DL and UL data transmission loss    dt_name=UE_1_DT    ul_max_allowed_data_loss=${DATA_TRANSFER_MAX_LOSS}
    ...                                                           dl_max_allowed_data_loss=${DATA_TRANSFER_MAX_LOSS}
    Verify DL and UL data transmission loss    dt_name=UE_2_DT    ul_max_allowed_data_loss=${DATA_TRANSFER_MAX_LOSS}
    ...                                                           dl_max_allowed_data_loss=${DATA_TRANSFER_MAX_LOSS}

Stop Data Transfers for 2 UEs
    Log Action To Console    Stoping data transfer for UE1 UE2
    Stop DL and UL data transmission    dt_name=UE_1_DT
    Stop DL and UL data transmission    dt_name=UE_2_DT

Wait until PM Counter interval and check that M55335C02016/M55335C02011 larger than 0
    Wait For Next Full Pm Counter Interval
    ${absolute_counter_file_path}=    Collect PM Counters    ${COUNTER_DIRECTORY}/feature_enabled
    ${counter_id}=    Set Variable If    '${RELEASE}'=='TRUNK'    M55335C02019    M55335C02019
    Verify PM Counter value is greater than given    counter_id=${counter_id}    value=0
    ...                                             counter_localmoid=${COUNTER_LOCALMOID}     log_file=${absolute_counter_file_path}

Setup Syslog Collector
    [Arguments]    ${log_dir}
    [Documentation]    Initializes syslog collector.
    os.Remove Directory    ${log_dir}    recursive=${True}
    btslogcollector.Setup Btslog Collector

Start collecting syslog
    [Documentation]    Starts collecting syslog from main gNB.
    Log Action To Console    Start collecting syslog
    Start Collecting gNB Btslog    gnb_id=0

Stop collecting syslog
    [Arguments]    ${log_dir}
    [Documentation]    Stops collecting syslog from main gNB.
    ...                :param log_dir: path to directory where logs will be kept
    Log Action To Console    Stop collecting syslog
    Stop Collecting gNB Btslog    log_dir=${log_dir}    gnb_id=0

Get absolute syslog direcotry path
    [Arguments]    ${log_dir}
    [Documentation]    Unpack syslog archive and returns path to directory with ordered syslog files.
    ...                :param log_dir: path to directory where logs are kept
    ...                :return: path to directory with ordered syslog files
    Log Action To Console    Checking syslog
    ${syslog_dir}=    Set Variable    ${log_dir}/btslog_REST_GNB0_DU0_79118_79118/syslog_files
    arch.Extract Tar File    tar_file=${log_dir}/btslog_REST_GNB0_DU0_79118_79118/syslog_files.tgz    dest=${syslog_dir}
    [Return]    ${syslog_dir}

Wait
    [Arguments]    ${time}
    [Documentation]    Wait given time with extra info about waiting.
    Log Action To Console    Wait ${time}
    Sleep    ${time}

Is Feature Enabled
    [Arguments]    ${nr_cell_id}
    [Documentation]    Check if CB008367 feature is enabled in cell configuration.
    ...                :param nr_cell_id:    nr cell id
    Log Action To Console    Check If Feature Is Enabled
    &{cell_parameters}=    Get Cell Parameters    cell_id=${nr_cell_id}
    ${status}=    Set Variable If	'${cell_parameters['actDynPdcchTdMode']}' == 'perBWP'    ${True}    ${False}
    [Return]    ${status}

Disable Feature If Enabled
    ${is_feature_enabled}=    Is Feature Enabled    nr_cell_id=${gnb1_cell1_nrcellid}
    Run Keyword If    '${is_feature_enabled}' == '${True}'    Disable Feature    nr_cell_id=${gnb1_cell1_nrcellid}

Enable CB008367 feature
    [Arguments]    ${nr_cell_id}=${gnb1_cell1_nrcellid}
    [Documentation]    Switches on CB008367 feature by cell settings reconfiguration.
    ...                :param nr_cell_id:    nr cell id
    Log Action To Console    Enable CB008367 Feature
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${nr_cell_id}
    ...    param_name=actDynPdcchTdMode
    ...    param_value=perBWP
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${180}
    Sleep   30s

Disable Feature
    [Arguments]    ${nr_cell_id}
    [Documentation]    Switches off CB008367 feature by cell settings reconfiguration.
    ...                :param nr_cell_id:    nr cell id
    Log Action To Console    Disable Feature
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${nr_cell_id}
    ...    param_name=actDynPdcchTdMode
    ...    param_value=disabled
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${180}

Verify syslog DynamicPdcchLogger reports
    [Arguments]    ${syslog_dir}    ${change_ratio}    ${bwp_idx}
    [Documentation]    Verifies DynamicPdcchLogger reports in syslog.
    ...                :param syslog_dir:    directory with syslog files
    ...                :param change_ratio: required change ratio of frames in syslog
    ...                :param bwp_idx: id of bwp cell for which to check ratio
    Log Action To Console    Verify If CCE Split Was Enabled For Bwp ${bwp_idx}
    Verify If CCE Split Was Enabled For Bwp    syslogs_dir=${syslog_dir}    bwp_idx=${bwp_idx}    change_ratio=${change_ratio}

Collect PM Counters
    [Arguments]    ${log_dir}
    [Documentation]    Collects file with PM counters from main gNB.
    ...                :param log_dir:    directory where to store PM counters files
    Log Action To Console    Collecting PM Counters...${SPACE}
    ${absolute_log_file}=    pmcount.Get Latest Unpacked Full Pm Counters File    output_dirpath=${log_dir}
    [Return]    ${absolute_log_file}

Wait For Next Full Pm Counter Interval
    Log Action To Console    Waiting For Next Full Pm Interval...${SPACE}
    pmcount.Wait For Next Full Pm Interval

Verify PM Counter value is equal to given
    [Arguments]    ${counter_id}    ${expected_value}    ${counter_localmoid}    ${log_file}
    [Documentation]    Verifies if value of given PM Counter from passed log file is equal to expected value.
    ...                :param counter_id:    id of PM counter
    ...                :param expected_value:    value to compare
    ...                :param counter_localmoid:    localmoid, e.g: PLMN-PLMN/MRBTS-79118/NRBTS-79118/NRCELL-1
    ...                :param log_file:    file with PM Counters values
    Log Action To Console    Verifing if counter ${counter_id} value equals to ${expected_value}
    pmcount.verify_if_latest_pm_counter_has_exact_value    ${counter_id}    ${expected_value}    ${counter_localmoid}    ${log_file}

Verify PM Counter value is greater than given
    [Arguments]    ${counter_id}    ${value}    ${counter_localmoid}    ${log_file}
    [Documentation]    Verifies if value of given PM Counter from passed log file is greater than expected value.
    ...                :param counter_id:    id of PM counter
    ...                :param expected_value:    value to compare
    ...                :param counter_localmoid:    localmoid, e.g: PLMN-PLMN/MRBTS-79118/NRBTS-79118/NRCELL-1
    ...                :param log_file:    file with PM Counters values
    Log Action To Console    Verifing if counter ${counter_id} value equals to ${value}
    pmcount.verify_if_latest_pm_counter_is_bigger_than_the_given_value    ${counter_id}    ${value}    ${counter_localmoid}    ${log_file}

Attach Ue
    [Arguments]    ${ue_alias}    ${expected_nr_cell_id}
    [Documentation]    Performes attach of given UE.
    ...                :param ue_alias: alias of UE
    ...                :param expected_nr_cell_id: nrcellid to verify attach procedure
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_filename}=  Set variable    ${ue_alias}_attach_${date}.pcap
    Start Tcpdump On CU    filename=${pcap_filename}    interface=any    protocol=sctp
    Sleep    3s
    ue.Attach Ue    ${ue_alias}
    Sleep    3s
    Stop Tcpdump On CU And Download Logs    filename=${pcap_filename}
    Verify Attach Cell Id    pcap_filename=${pcap_filename}    expected_nr_cell_id=${expected_nr_cell_id}

Verify Attach Cell Id
    [Arguments]    ${pcap_filename}    ${expected_nr_cell_id}
    [Documentation]    Checks ID of attached cell.
    ...                :param pcap_filename:    filename of pcap with caught messages
    ...                :param expected_nr_cell_id:    expected cell's nrcellid
    ${expected_nr_cell_id_in_hex}=    Evaluate    "{0:#0{1}x}".format(int(${expected_nr_cell_id}), 11)
    ${message_found}=    flow_verifier.Check If Message Is In Flow
    ...                       awaited_message=UplinkNASTransport(contains(*nRCellIdentity=${expected_nr_cell_id_in_hex}))
    ...                       pcap_file=${LOG_PATH}/${pcap_filename}
    Run Keyword If    ${message_found} == ${False}    Fail    msg=Ue did not attach to expected cell.

Await DL and UL data transmission finish
    [Arguments]    ${dt_name}
    [Documentation]    Await until UL and DL data transmission streams will be finish.
    ...                :param dt_name:    data transmission alias (same for UL and DL streams)
    Await Data Transfer Finish    UL_${dt_name}
    Await Data Transfer Finish    DL_${dt_name}

Stop DL and UL data transmission
    [Arguments]    ${dt_name}
    [Documentation]    Stop UL and DL data transmission streams.
    ...                :param dt_name:    data transmission alias (same for UL and DL streams)
    Stop Data Transfer    dt_name=UL_${dt_name}
    Stop Data Transfer    dt_name=DL_${dt_name}
    Sleep    1s

Verify DL and UL data transmission loss
    [Arguments]    ${dt_name}    ${ul_max_allowed_data_loss}    ${dl_max_allowed_data_loss}
    [Documentation]    Checks if datagram loss is below expected for UL and DL directions.
    ...                :param dt_name:    data transmission alias (same for UL and DL streams)
    ...                :param ul_max_allowed_data_loss:    max allowed datagram loss for UL direction
    ...                :param dl_max_allowed_data_loss:    max allowed datagram loss for DL direction
    Verify Throughput With Datagram Loss    UL_${dt_name}    max_allowed_datagram_loss=${ul_max_allowed_data_loss}
    Verify Throughput With Datagram Loss    DL_${dt_name}    max_allowed_datagram_loss=${dl_max_allowed_data_loss}

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs given message with extra markers (e.g: timestamp, new lines...).
    ...                :param msg:    message logged
    ...                :param datatime:    switch on/off timestamp logging
    ...                :param new_line_before:    switch on/off adding extra line before log
    ...                :param msg:    switch on/off adding extra line after log
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}
