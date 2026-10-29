*** Settings ***
Documentation
...   All keywords are used in the test suite of 5G Performance and Capacity feature.
...   author: Sara Nowak Mateusz Potoniec
...   contact: sara.nowak@nokia.com mateusz.potoniec@nokia.com
...   maintainer: sara.nowak@nokia.com mateusz.potoniec@nokia.com

Library      Collections
Library      DateTime                                                          WITH NAME    dt
Library      OperatingSystem                                                   WITH NAME    os
Library      ute_ue                                                            WITH NAME    ue
Library      taf.transport.ssh                                                 WITH NAME    csn
Library      taf.collectors.l2stream3                                          WITH NAME    tcl
Library      taf.collectors.core                                               WITH NAME    tcc
Library      taf.collectors.tcpdump                                            WITH NAME    tct
Library      ta_attenuator                                                     WITH NAME    attenuator
Library      taf.rfrl.bts.operations                                           WITH NAME    bts_operations
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations         WITH NAME    gnb_cell
Library      taf.rfrl.bts.devices.du.logs_collecting.basic_logs.GnbLog         WITH NAME    gnb_log
Library      taf.rfrl.bts.devices.du.logs_collecting.basic_logs.EnbLog         WITH NAME    enb_log
Library      taf.rfrl.ue.ue_attach_verification.UeAttachVerification           WITH NAME    ue_attach_verification
Library      taf.rfrl.utilities.logger.custom_logger                           WITH NAME    logger
Library      ping.py                                                           WITH NAME    ping
Library      latency_analyzer.py                                               WITH NAME    latency_analyzer
Library      tti_trace_analyzer.py                                             WITH NAME    tti_trace_analyzer
Library      suite_specific_keywords.py                                        WITH NAME    suite_specific_keywords

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables    delta.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Keywords ***
Test Setup
    [Documentation]    Test setup, performing common preconditions and setting up attenuator and UE
    logger.Log Banner to Console    Test Setup
    logger.Log Info to Console    Perform Common Preconditions
    Common Preconditions
    Setup Attenuator
    Require UE
    logger.Log Banner to Console    Test Procedure

Test Setup eNB1
    [Documentation]    Test setup, setting up attenuator and UE
    Test Setup
    Perform Attenuation of ENB1 and ENB2    enb1_cell_1_value=0%      enb1_cell_2_value=100%
    ...                                     enb2_cell_1_value=100%    enb2_cell_2_value=100%

Test Teardown
    [Arguments]    ${logs_gnb1}=${True}    ${logs_gnb2}=${True}    ${logs_enb1}=${True}    ${logs_enb2}=${True}
    [Documentation]    Test teardown, performing common postconditions and getting logs from gNB and eNB
    ...                :param logs_gnb1:    Specifies whether to collect logs from gNB1
    ...                :param logs_gnb2:    Specifies whether to collect logs from gNB2
    ...                :param logs_enb1:    Specifies whether to collect logs from eNB1
    ...                :param logs_enb2:    Specifies whether to collect logs from eNB2

    logger.Log Banner to Console    Test Teardown
    Detach UE
    logger.Log Info to Console    Perform Common Postconditions
    Common Postconditions
    IF    ${logs_gnb1} == ${True}
        Get Configuration File and Snapshot from gNB    bts_id=0
    END
    IF    ${logs_gnb2} == ${True}
        Get Configuration File and Snapshot from gNB    bts_id=1
    END
    IF    ${logs_enb1} == ${True}
        Get Configuration File and Snapshot from eNB    bts_id=0
    END
    IF    ${logs_enb2} == ${True}
        Get Configuration File and Snapshot from eNB    bts_id=1
    END
    logger.Log Banner to Console    End Test

Get Configuration File and Snapshot from gNB
    [Arguments]    ${bts_id}=0    ${scf_log_dir}=${OUTPUT_DIR}/configs/    ${snapshot_log_dir}=${OUTPUT_DIR}/snapshots/
    [Documentation]    Get configuration file from gNB
    ...                :param bts_id:    ID of the gNB
    ...                :param scf_log_dir:    directory where config will be saved
    ...                :param snapshot_log_dir:    directory where logs will be saved

    logger.Log Info to Console    Get Configuration File from gNB${${bts_id}+1}
    bts_operations.Download BTS Configuration    log_dir=${scf_log_dir}    bts_type=GNB    bts_id=${bts_id}

    logger.Log Info to Console    Collect Snapshot from gNB${${bts_id}+1}
    gnb_log.Collect Snapshot    bts_id=${bts_id}    log_dir=${snapshot_log_dir}   timeout=900    du_id=0
    ...                         snapshot_coverage=Full    snapshot_name=REST_GNB${${bts_id}+1}_DU0_snapshot

Get Configuration File and Snapshot from eNB
    [Arguments]    ${bts_id}=0    ${scf_log_dir}=${OUTPUT_DIR}/configs/    ${snapshot_log_dir}=${OUTPUT_DIR}/snapshots/
    [Documentation]    Get configuration file from eNB
    ...                :param bts_id:    ID of the eNB
    ...                :param scf_log_dir:    directory where config will be saved
    ...                :param snapshot_log_dir:    directory where logs will be saved

    logger.Log Info to Console    Get Configuration File from eNB${${bts_id}+1}
    bts_operations.Download BTS Configuration    log_dir=${scf_log_dir}    bts_type=ENB    bts_id=${bts_id}

    logger.Log Info to Console    Collect Snapshot from eNB${${bts_id}+1}
    enb_log.Collect Snapshot    bts_id=${bts_id}    log_dir=${snapshot_log_dir}   timeout=900    du_id=0
    ...                         snapshot_coverage=Full    snapshot_name=REST_ENB${${bts_id}+1}_DU0_snapshot

Require UE
    [Documentation]    This keyword is used to require a specific UE with the given capabilities.
    logger.Log Info to Console    Require UE
    ue.Require UE    UE_1    capabilities=COMMERCIAL

Setup Attenuator
    [Documentation]    Setups attenuator
    logger.Log Info to Console    Setup Attenuator
    ${ABSTRACT_LIB_CONFIG}=    os.Get Environment Variable    name=ABSTRACT_LIB_CONFIG
    attenuator.Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    attenuator.Require attenuator setup of    ENB_1_CELL_1
    attenuator.Require attenuator setup of    ENB_1_CELL_2
    attenuator.Require attenuator setup of    ENB_2_CELL_1
    attenuator.Require attenuator setup of    ENB_2_CELL_2

Perform Attenuation of eNB1 and eNB2
    [Arguments]    ${enb1_cell_1_value}=0%    ${enb1_cell_2_value}=100%    ${enb2_cell_1_value}=100%    ${enb2_cell_2_value}=100%
    [Documentation]    Perform attenuation of eNB1 and eNB2
    ...                :param enb1_cell_1_value:    attenuation value for eNB1 cell1
    ...                :param enb1_cell_2_value:    attenuation value for eNB1 cell2
    ...                :param enb2_cell_1_value:    attenuation value for eNB2 cell1
    ...                :param enb2_cell_2_value:    attenuation value for eNB2 cell2

    logger.Log Info to Console    Perform attenuation of eNB1 and eNB2
    attenuator.Set Attenuation  ENB_1_CELL_1    ${enb1_cell_1_value}
    attenuator.Set Attenuation  ENB_1_CELL_2    ${enb1_cell_2_value}
    attenuator.Set Attenuation  ENB_2_CELL_1    ${enb2_cell_1_value}
    attenuator.Set Attenuation  ENB_2_CELL_2    ${enb2_cell_2_value}

Connect to BTS
    [Arguments]   ${hostname}=10.84.190.29     ${alias}=GNB
    [Documentation]    Connects to BTS via alias given by an argument.
    ...                :param hostname:    hostname of BTS
    ...                :param alias:    alias by which connection should be established.

    csn.connect_to     hostname=${hostname}
    ...                username=${tl.gnbs[1].cu.oam_ssh_connection_details.username}
    ...                password=${tl.gnbs[1].cu.oam_ssh_connection_details.password}
    ...                alias=${alias}
    [Return]           ${alias}

Start Tcpdump on CU
    [Arguments]   ${filename}=${test_name}.pcap   ${interface}=any    ${protocol}=sctp    ${sleep_after_start}=3
    ...           ${alias}=GNB
    [Documentation]    Starts tcpdump on CU
    ...                :param filename:              file where messages will be saved
    ...                :param interface:             interface to logs collection
    ...                :param protocol:              protocol to filter logs
    ...                :param sleep_after_start:     amout of time to sleep after logs collection start
    ...                :param alias:                 alias to connection

    csn.send_command    command=tcpdump ${protocol} -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    sleep   ${sleep_after_start} s

Stop Tcpdump on CU and Download Logs
    [Arguments]     ${filename}=${test_name}.pcap        ${alias}=GNB
    [Documentation]    Stops tcpdump on CU and dwonloads logs
    ...                :param filename:   file where messages will be saved
    ...                :param alias:      alias to connection

    sleep   3 s
    csn.execute          command=killall tcpdump
    ...                  connection=${alias}
    csn.execute          command=chmod 777 /tmp/${filename}
    ...                  connection=${alias}
    csn.download_file    /tmp/${filename}    ${OUTPUT_DIR}/${filename}
    ...                  connection=${alias}
    csn.execute          command=rm "/tmp/${filename}"
    ...                  connection=${alias}
    sleep   3 s

Attach UE With Pcap Check
    [Arguments]    ${5g_pci}    ${4g_pci}    ${time_sleep_before_stop_logs}=5s
    ...            ${pcap_name}=attach.pcap    ${protocol}=sctp -vv    ${forbidden_messages}=${False}
    [Documentation]    The keyword performs 5G NSA attach and checks if attach was performed to desired 4G and 5G cells of BTS.
    ...                It collects tcpdump logs on CU during attach and then checks if attach was performed correctly.
    ...                :param 5g_pci:    PCI of 5G cell
    ...                :param 4g_pci:    PCI of 4G cell
    ...                :param time_sleep_before_stop_logs:    time to sleep before logs collection stop
    ...                :param pcap_name:    name of pcap file
    ...                :param protocol:    protocol to filter logs
    ...                :param forbidden_messages:    check for forbidden messages

    logger.Log Info to Console    Attach UE
    Start tcpdump on CU     filename=${pcap_name}   protocol=${protocol}
    ue.Attach UE   UE_1
    logger.Log Info to Console    Wait ${time_sleep_before_stop_logs} before log collection stop
    Sleep  ${time_sleep_before_stop_logs}
    Stop tcpdump on CU and Download Logs    filename=${pcap_name}
    logger.Log Info to Console    Verify NSA attach
    ue_attach_verification.Verify_NSA_Attach    ue_alias=UE_1
    ...                                         pci_5g=${5g_pci}
    ...                                         pci_4g=${4g_pci}
    ...                                         pcap_file=${OUTPUT_DIR}/${pcap_name}
    ...                                         forbidden_messages_check=${forbidden_messages}
    [Return]    ${pcap_name}

Attach UE to gNB1 and Perform Inter MeNB HO With Pcap Check
    [Arguments]     ${pcap_name}=attach.pcap    ${forbidden_messages}=${False}
    [Documentation]    The keyword performs 5G NSA attach and then performs inter MeNB handover and checks
    ...                if attach was performed to desired 4G and 5G cells of BTS.
    ...                It collects tcpdump logs on CU during attach and checks if attach was performed to correct 4G cell.
    ...                Then it performs inter MeNB handover with checking if HO was performed to correct 4G cell.
    ...                It also check for desired 5G cell in collected pcap logs.
    ...                :param pcap_name:    name of pcap file
    ...                :param forbidden_messages:    check for forbidden messages

    Perform Attenuation of eNB1 and eNB2    enb1_cell_1_value=0%      enb1_cell_2_value=100%
    ...                                     enb2_cell_1_value=100%    enb2_cell_2_value=100%
    ${alias_for_tcpdump}=    Connect to BTS    ${GNB_1_ADDRESS}
    logger.Log Info to Console    Attach UE
    Start tcpdump on CU     filename=${pcap_name}   protocol=sctp -vv
    Sleep    5s
    ue.Attach UE   UE_1
    logger.Log Info to Console    Verify UE attach to eNB1
    ue_attach_verification.Verify_NSA_Attach    ue_alias=UE_1
    ...                                         pci_5g=${GNB_1_CELL_1_ID}
    ...                                         pci_4g=${ENB_1_CELL_1_ID}
    Perform Handover from eNB1 Cell1 to eNB2 Cell1
    Sleep    5s
    Stop tcpdump on CU and Download Logs    filename=${pcap_name}
    logger.Log Info to Console    Verify NSA flow
    ue_attach_verification.Verify_NSA_Attach    ue_alias=UE_1
    ...                                         pci_5g=${GNB_1_CELL_1_ID}
    ...                                         pci_4g=${ENB_2_CELL_1_ID}
    ...                                         pcap_file=${OUTPUT_DIR}/${pcap_name}
    ...                                         forbidden_messages_check=${forbidden_messages}
    [Return]    ${pcap_name}

Detach UE
    [Documentation]    The keyword performs UE detach.
    logger.Log Info to Console    Detach UE
    ue.Detach Ue    UE_1

Prepare Cells Before HO
    [Documentation]    The keyword prepares cells before handover.

    logger.Log Info to Console    Start preparing cell for HO
    Unlock All Cells         gnb_id=1
    logger.Log Info to Console    All source cells are unlocked
    Lock All Cells
    logger.Log Info to Console    All target cells are locked
    logger.Log Info to Console    All cells are prepared for HO

Perform Handover from eNB1 Cell1 to eNB2 Cell1
    [Documentation]    The keyword performs handover from eNB1 cell1 to eNB2 cell1.

    logger.Log Info to Console    Perform handover from eNB1 cell1 to eNB2 cell2
    Execute Fading Scenario    source_cell=ENB_1_CELL_1    target_cell=ENB_2_CELL_1    fading_step=3db
    ...    fading_interval=1s    fading_min=1dB    fading_max=40dB

Perform Inter gNB HO
    [Arguments]      ${iteration}
    [Documentation]    The keyword performs Inter gNB HO.
    ...                :param iteration:    iteration number

    ${alias_for_tcpdump}=    Connect to BTS    hostname=${ENB_1_ADDRESS}    alias=ENB1
    ${pcap_name}=    Set Variable    iter_${iteration}_inter_gnb_ho_logs.pcap
    Start Tcpdump on CU      filename=${pcap_name}    protocol=sctp -vv    alias=ENB1
    Sleep    5s
    logger.Log Info to Console    Perform Inter gNB HO by unlocking target cells
    Unlock All Cells
    logger.Log Info to Console    All target cells are unlocked
    Sleep    10s
    Stop Tcpdump on CU and Download Logs    filename=${pcap_name}    alias=ENB1
    ue.Detach Ue    UE_1
    [Return]   ${pcap_name}

Perform Inter gNB HO by Delta Commissioning
    [Documentation]    The keyword performs Inter gNB HO by delta commissioning.
    logger.Log Info to Console    Perform Inter gNB HO by delta commissioning
    Perform Delta Commissioning On gNB   ${DELTA_RESET}
    Wait Until Keyword Succeeds    7min    10s    gnb_cell.Verify All Cells are onAir    bts_id=0    du_id=${0}
    ...                                                                                  cell_type=nr
    Sleep    15s

Start UL and DL Data Transfer
    [Documentation]    Start UL and DL data transfer
    logger.Log Info to Console    Start UL and DL data transfer
    ue.Start Data Transfer    dt_name=DT_1_UL    ue_alias=UE_1    direction=ul    duration=forever    protocol=udp
    ...     throughput=10 Mbits/sec    packet=1400    buffer=4M    buffer_client=2M
    ue.Start Data Transfer    dt_name=DT_1_DL    ue_alias=UE_1    direction=dl    duration=forever    protocol=udp
    ...     throughput=10 Mbits/sec    packet=1400    buffer=4M    buffer_client=2M

Stop UL and DL Data Transfer
    [Documentation]    Stop UL and DL data transfer
    logger.Log Info to Console    Stop UL and DL data transfer
    ue.Stop Data Transfer    dt_name=DT_1_UL
    ue.Stop Data Transfer    dt_name=DT_1_DL

Start TTI Trace gNB1
    [Arguments]    ${collector_name}=l2stream31
    [Documentation]    Start TTI trace on gNB1
    ...                :param collector_name: name of the collector

    logger.Log Info to Console    Start ${collector_name} TTI trace on gNB1
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443

    ${l2_stream_config}=  Create Dictionary
    ...  nr_phy_cell_ids=50
    ...  profile_filter_list=Use RnD parameters
    ...  event_filter_list=ulTdSchedSubcellData,dlTdSchedSubcellData
    @{l2_stream_configuration}    Create List    ${l2_stream_config}

    tct.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth0 udp and dst 10.84.183.78 and dst port 5678
    ...  sudo_password=uteUTE!

    tcl.create sbts l2stream collector
    ...  name=${collector_name}
    ...  webservice=${webservice}
    ...  destination_ip_addr=10.84.183.78
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  tti_dec_path=/home/ute/tti_decoder

    tcl.Set suite alias
    ...  alias=${collector_name}
    tcc.Setup collectors
    ...  names=${collector_name}
    tcc.Start collectors
    ...  names=${collector_name}

Start TTI Trace gNB2
    [Arguments]    ${collector_name}=l2stream31
    [Documentation]    Start TTI trace on gNB2
    ...                :param collector_name: name of the collector

    logger.Log Info to Console    Start ${collector_name} TTI trace on gNB2
    ${webservice}=  Create Dictionary
    ...  host=10.84.190.29
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443

    ${l2_stream_config}=  Create Dictionary
    ...  nr_phy_cell_ids=61
    ...  profile_filter_list=Use RnD parameters
    ...  event_filter_list=ulTdSchedSubcellData,dlTdSchedSubcellData
    @{l2_stream_configuration}    Create List    ${l2_stream_config}

    tct.create tcpdump collector
    ...  name=tcpdump2
    ...  options=-i eth0 udp and dst 10.84.183.78 and dst port 5678
    ...  sudo_password=uteUTE!

    tcl.create sbts l2stream collector
    ...  name=${collector_name}
    ...  webservice=${webservice}
    ...  destination_ip_addr=10.84.183.78
    ...  collector=tcpdump2
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  tti_dec_path=/home/ute/tti_decoder

    tcl.Set suite alias
    ...  alias=${collector_name}
    tcc.Setup collectors
    ...  names=${collector_name}
    tcc.Start collectors
    ...  names=${collector_name}

Start TTI Trace
    [Arguments]    ${collector_name}=l2stream31
    [Documentation]    Starts TTI trace
    ...                :param collector_name: name of the collector

    logger.Log Info to Console    Start ${collector_name} TTI trace
    ${configurations}=  tcc.Load Configurations
    ...                 ${CURDIR}/ttitrace_collectors.yaml
    tcc.Create collectors
    ...  names=${collector_name}
    ...  configurations=${configurations['collectors']}
    tcl.Set suite alias
    ...  alias=${collector_name}
    tcc.Setup collectors
    ...  names=${collector_name}
    tcc.Start collectors
    ...  names=${collector_name}

Stop TTI Trace
    [Arguments]    ${collector_name}=l2stream31     ${split}=${True}    ${tcpdump_file}=tcpdump
    [Documentation]    Stops TTI trace, downloads logs to VM and splits pcap file to smaller ones if needed
    ...                :param collector_name: name of the collector
    ...                :param split:          split pcap file to smaller ones
    ...                :param tcpdump_file:   name of the tcpdump file

    logger.Log Info to Console    Stop ${collector_name} TTI trace
    tcc.Stop collectors
    ...  names=${collector_name}
    logger.Log Info to Console    Download TTI trace results
    tcc.Collect collectors
    ...  names=${collector_name}
    ...  target_dir=${OUTPUTDIR}/tti_pcap/
    tcc.Teardown collectors
    ...  names=${collector_name}
    ${list_of_splited_files}    Set Variable    ${None}
    IF    ${split}==${True}
        logger.Log Info to Console    Split ${collector_name} TTI trace pcap file to smaller ones
        ${list_of_splited_files}    suite_specific_keywords.Split Tcpdump File
        ...    ${OUTPUTDIR}/tti_pcap/${collector_name}/${tcpdump_file}/${tcpdump_file}.pcap
        ...    ${OUTPUTDIR}/tti_pcap/${collector_name}/${tcpdump_file}/splited/${tcpdump_file}_part.pcap
    END
    [Return]    ${list_of_splited_files}
