*** Settings ***
Documentation
...  author:  Marcin Flis, Monika Mysliwiec
...  contact: marcin.1.flis@nokia.com, monika.banas@nokia.com
...  description: Test Cases for testline with ABIP and FR2

Library     DateTime                                                                    WITH NAME    dt
Library     OperatingSystem                                                             WITH NAME    os
Library     taf/rfrl/procedures/resources/python/sleeping_cell_detector.py              WITH NAME    scd
Library     taf.gnb.oam.coam.admin                                                      WITH NAME    admin
Library     taf.selenium.sbts                                                           WITH NAME    selenium_coam
Library     taf.rfrl.ue.ue_attach_verification.UeAttachVerification                     WITH NAME    ue_attach_verification
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                   WITH NAME    gnbcell
Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                       WITH NAME    gnb_du
Library     taf.rfrl.utilities.test_config.DefaultFileLocation                          WITH NAME    dfl
Library     taf.ue                                                                      WITH NAME    ue
Library     taf.rfrl.ue.ute_ue_config.UteUeConfig                                       WITH NAME    uteueconfig
Library     taf.transport.ssh                                                           WITH NAME    csn

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/enb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
${skip_commissioning}=     ${NONE}
${DIST_NAME_1}=            MRBTS-77059/LNBTS-77059/LNCEL-1
${DIST_NAME_2}=            MRBTS-77059/LNBTS-77059/LNCEL-2
${PARAM_NAME}=             defaultLnRelGnbCellId
${PARAM_VALUE}=            52

*** Keywords ***
Suite Setup
    [Documentation]    Test Setup, performs commissioning on gNB and ASIR
    Log Action To Console    Suite Setup ==========================================
    Log Action To Console    Download Current Config File from gNB
    Run Keyword And Ignore Error    Download gNB Configuration File    local_dir=${OUTPUT DIR}
    ...                                                                filename=gNB_SCF_before_test.xml    gnb_id=0
    ...                                                                du_id=0
    Run Keyword If    '${skip_commissioning}'!='true'    Perform Commissioning on BTS
    Run Keyword And Ignore Error    scd.Enable Sleeping Cell Detection Feature
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}
    Log Action To Console    End Suite Setup =======================================   new_line_after=True

Common Test Setup for different configs
    [Arguments]     ${scfc_file}
    [Documentation]    Test Setup, performs commissioning on gNB for different type of configs
    Log Action To Console    Common Preconditions
    gnb_scd.Enable Sleeping Cell Detection Feature For All Bts
    Perform Commissioning on gNB        scfc_file=${scfc_file}
    Common Preconditions

Require UE
    [Arguments]    ${ue_type}    ${capabilities}
    Log Action To Console    Require UE ${ue_type}
    ue.Require UE    ${ue_type}    capabilities=${capabilities}

Perform Commissioning on gNB
    [Arguments]     ${scfc_file}
    [Documentation]  Performs gNB commissioning with SCF file name given as argument
    ...              :scfc_file:    Name of scf file
    ${commissioning_files_directory}=    dfl.Get Commissioning Dir
    Log Action To Console    Perform Full Commissioning On Classical gNB with file ${scfc_file}
    Perform Full Commissioning On Classical Gnb    bts_id=0
    ...                                            scf_path=${commissioning_files_directory}/${scfc_file}
    ...                                            commissioning_timeout=1000
    Common Preconditions

Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs message to console
    ...                :param msg:     message logged
    ...                :datatime:    determines if include timestamp in log
    ...                :new_line_before:    determines if include new line before log
    ...                :new_line_after:    determines if include new line after log
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Fail And Log Error
    [Arguments]   ${msg}
    [Documentation]    The keyword performs failure and logs error message.
    ...                :param msg:     message logged
    Log    message=${msg}    level=ERROR
    Fail   msg=${msg}

Attach UE With Pcap Check
    [Arguments]    ${5g_pci}    ${4g_pci}     ${ue_type}
    ...            ${pcap_name}=attach.pcap    ${protocol}=sctp and port 36422 -U   ${forbidden_messages}=${False}
    ...            ${time_sleep_before_stop_logs}=5s
    [Documentation]    The keyword performs 5G NSA attach and checks if attach was performed to desired 4G and 5G cells of BTS.
    ...                It collects tcpdump logs on CU during attach and then checks if attach was performed correctly.
    ...                :param 5g_pci:    PCI of 5G cell
    ...                :param 4g_pci:    PCI of 4G cell
    ...                :param time_sleep_before_stop_logs:    time to sleep before logs collection stop
    ...                :param pcap_name:    name of pcap file
    ...                :param protocol:    protocol to filter logs
    ...                :param forbidden_messages:    check for forbidden messages
    ...                :param ue_type_1:    type of ue

    Log Action to Console    Connect to BTS
    Connect to BTS
    Log Action to Console    Attach UE
    Start tcpdump on CU     filename=${pcap_name}   protocol=${protocol}
    ue.Attach UE   ${ue_type}
    Log Action to Console    Wait ${time_sleep_before_stop_logs} before log collection stop
    Sleep  ${time_sleep_before_stop_logs}
    Stop tcpdump on CU and Download Logs    filename=${pcap_name}
    Log Action to Console    Verify NSA attach
    ue_attach_verification.Verify_NSA_Attach    ue_alias=${ue_type}
    ...                                         pci_5g=${5g_pci}
    ...                                         pci_4g=${4g_pci}
    ...                                         pcap_file=${OUTPUT_DIR}/${pcap_name}
    ...                                         forbidden_messages_check=${forbidden_messages}
    [Return]    ${pcap_name}

Detach Ue
    [Arguments]    ${ue_type}
    [Documentation]    The keyword performs UE detach.
    Log Action To Console    Detach UE ${ue_type}
    ue.Detach Ue    ${ue_type}

Connect to BTS
    [Arguments]   ${hostname}=10.84.190.59    ${alias}=GNB
    [Documentation]    Connects to BTS via alias given by an argument.
    ...                :param hostname:    hostname of BTS
    ...                :param alias:    alias by which connection should be established.

    csn.connect_to     hostname=${hostname}
    ...                username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
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

Start DL and UL data transmission
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ue_type}
    ...    ${ul_throughput_for_verify}    ${dl_throughput_for_verify}    ${max_allowed_data_loss}
    [Documentation]    The keyword starts and verifies DL/UL data transmission
    ...                :param ul_throughput:        value of ul_throughput
    ...                :param dl_throughput:        value of dl_throughput
    ...                :param ue_type:              type of ue
    ...                :param ul_throughput_for_verify:     value of ul_throughput to verify
    ...                :param dl_throughput_for_verify:     value of dl_throughput to verify
    ...                :max_allowed_data_loss:      value of max_allowed_data_loss
    Log Action To Console    Start UL and DL data transmission
    Start DL data transmission for specified time    dl_throughput=${dl_throughput}     data_transfer_time=60s    ue_type=${ue_type}
    Await DL data transmission finish
    Stop DL data transmission
    Verify DL data transmission loss    max_allowed_data_loss=${max_allowed_data_loss}    dl_throughput_for_verify=${dl_throughput_for_verify}
    Start UL data transmission for specified time    ul_throughput=${ul_throughput}     data_transfer_time=60s    ue_type=${ue_type}
    Await UL data transmission finish
    Stop UL data transmission
    Verify UL data transmission loss    max_allowed_data_loss=${max_allowed_data_loss}    ul_throughput_for_verify=${ul_throughput_for_verify}

Start UL data transmission for specified time
    [Arguments]    ${ul_throughput}    ${data_transfer_time}    ${ue_type}    ${ul_dt_name}=DT_1_UL
    [Documentation]    Keyword starts UDP UL traffic transmision for specified time.
    ...                Traffic is performed in uplink and downlink directions.
    ...                :param ul_throughput:    data trasmission's max tuput
    ...                :param data_transfer_time:    data trasmission's time
    ...                :param ul_dt_name:    data trasmission's name
    Log Action To Console    Start UL data transmission for ${data_transfer_time}
    ue.Start Data Transfer    dt_name=${ul_dt_name}    ue_alias=${ue_type}
    ...                       direction=ul    duration=${data_transfer_time}    protocol=udp    throughput=${ul_throughput}
    ...                       packet_size=1350B    buffer_client=4M

Start DL data transmission for specified time
    [Arguments]    ${dl_throughput}    ${data_transfer_time}    ${ue_type}    ${dl_dt_name}=DT_1_DL
    [Documentation]    Keyword starts UDP DL traffic transmision for specified time.
    ...                Traffic is performed in uplink and downlink directions.
    ...                :param dl_throughput:    value of dl max tuput to send
    ...                :param data_transfer_time:    data trasmission's time
    ...                :param dl_dt_name:    data trasmission's name
    Log Action To Console    Start DL data transmission for ${data_transfer_time}
    ue.Start Data Transfer    dt_name=${dl_dt_name}    ue_alias=${ue_type}
    ...                       direction=dl    duration=${data_transfer_time}    protocol=udp    throughput=${dl_throughput}
    ...                       iperf_len=1350B    packet=1350B   buffer_server=8M

Await UL data transmission finish
    [Arguments]    ${ul_dt_name}=DT_1_UL
    [Documentation]    Keyword awaits UDP UL traffic transmision.
    ...                :param ul_dt_name:    data trasmission's name
    Log Action To Console    Await UL data transmission finish
    ue.Await Data Transfer Finish    ${ul_dt_name}

Await DL data transmission finish
    [Arguments]    ${dl_dt_name}=DT_1_DL
    [Documentation]    Keyword awaits UDP DL traffic transmision.
    ...                :param dl_dt_name:    data trasmission's name
    Log Action To Console    Await DL data transmission finish
    ue.Await Data Transfer Finish    ${dl_dt_name}

Stop UL data transmission
    [Arguments]    ${ul_dt_name}=DT_1_UL
    [Documentation]    Keyword stops UDP UL traffic transmision.
    ...                :param ul_dt_name:    data trasmission's name
    Log Action To Console    Stop UL data transmission
    ue.Stop Data Transfer    dt_name=${ul_dt_name}

Stop DL data transmission
    [Arguments]    ${dl_dt_name}=DT_1_DL
    [Documentation]    Keyword stops UDP DL traffic transmision.
    ...                :param dl_dt_name:    data trasmission's name
    Log Action To Console    Stop DL data transmission
    ue.Stop Data Transfer    dt_name=${dl_dt_name}

Verify DL data transmission loss
    [Arguments]    ${max_allowed_data_loss}    ${dl_throughput_for_verify}    ${dl_dt_name}=DT_1_DL
    [Documentation]    Keyword checks if throughput datagram loss is below max_allowed_datagram_loss.
    ...                Checking is performed in downlink direction.
    ...                :param max_allowed_data_loss:   max allowed data loss value in percentage
    ...                :param dl_dt_name:    data trasmission's name
    Log Action To Console    Verify DL data transmission loss
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}
    ...                                            deviation=${max_allowed_data_loss}
    ...                                            tput=${dl_throughput_for_verify}

Verify UL data transmission loss
    [Arguments]    ${max_allowed_data_loss}    ${ul_throughput_for_verify}    ${dl_dt_name}=DT_1_UL
    [Documentation]    Keyword checks if throughput datagram loss is below max_allowed_datagram_loss.
    ...                Checking is performed in downlink direction.
    ...                :param max_allowed_data_loss:   max allowed data loss value in percentage
    ...                :param dl_dt_name:    data trasmission's name
    Log Action To Console    Verify UL data transmission loss
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}
    ...                                            deviation=${max_allowed_data_loss}
    ...                                            tput=${ul_throughput_for_verify}

Lock Unlock RF Units from GUI
    [Documentation]    Keyword locks and unlocks RF units from GUI
    Log Action To Console                                       ---------New iteration---------
    Log Action To Console                                       ---------RF module locking---------
    Lock All Radio Units on gNB from GUI
    Unlock All Radio Units on gNB from GUI
    Wait Until Keyword Succeeds                                 300 seconds  15 seconds  gnbru.Verify All Radio Units Are Online
    Wait Until Keyword Succeeds                                 300 seconds  15 seconds  gnbcell.Verify All Cells are OnAir

Reset BBMODs and check alarms
    [Documentation]    performs BBMOD reset and verify cells and RUs status
    [Arguments]     ${bb_mod_id_1}    ${bb_mod_id_2}
    Log Action To Console           ---------BBMODs reset---------
    gnb_du.reset bbmod              bbmod_id=${bb_mod_id_1}
    gnb_du.reset bbmod              bbmod_id=${bb_mod_id_2}
    Wait Until Keyword Succeeds     300 seconds  15 seconds  gnbru.Verify All Radio Units Are Online
    Wait Until Keyword Succeeds     300 seconds  15 seconds  gnbcell.Verify All Cells are OnAir

Wait until all cells are onair
    Log Action To Console          Wait until all cells are onair
    Wait Until Keyword Succeeds    8min    10s    Verify Cell Statuses   gnb_id=0    du_id=${0}    cell_type=nr
    ...                                           procedural_status=configured
    ...                                           administrative_state=unlocked
    ...                                           availability_status=online    operational_state=enabled

Lock Unlock All Cells
    [Documentation]    Lock and then unlock all cells one by one
    Log Action To Console                                       ---------New iteration ---------
    Log Action To Console                                       ---------Locking Cells----------
    Lock All Cells
    Log Action To Console                                       ---------Unlocking Cells--------
    Unlock All Cells
    Wait Until Keyword Succeeds                                 8 minute    10 seconds    gnbcell.Verify All Cells are OnAir

Manual SiSo SM BTS Site Reset
    [Documentation]    Reset gNB
    Log Action To Console                                       ---------Performing gnb reset---------
    Reset gNB via GUI
    Sleep                                                       20s
    Wait Until Keyword Succeeds                                 8 minute    10 seconds    gnbcell.Verify All Cells are OnAir

General SiSo Cell block and unblock
    [Documentation]    Keyword blocks and unblocks cells on gnb
    Log Action To Console                                   Block All Cells And Then Unblock One By One
    Block All Cells And Then Unblock One By One
    Log Action To Console                                   Block Unblock All Cells For Each Group
    Block Unblock All Cells For Each Group
    Verify All Cells Are Unblocked
    Wait Until Keyword Succeeds    8 minute    10 seconds    gnbcell.Verify All Cells are OnAir
    Wait For Site To Be Onair
    sleep    180s   Wait 3 minutes to verify if cells are still in online state

Verify L3 call
    [Arguments]    ${ue_type_1}    ${ue_type_2}
    ...            ${ul_throughput_1}    ${ul_throughput_2}    ${dl_throughput_1}    ${dl_throughput_2}    ${ul_throughput_for_verify_1}
    ...            ${ul_throughput_for_verify_2}    ${dl_throughput_for_verify_1}    ${dl_throughput_for_verify_2}
    ...            ${max_allowed_data_loss}
    [Documentation]    Verifying L3 call for DL and UL
    ...                :param ue_type_1:        type of ue_1
    ...                :param ue_type_2:        type of ue_2
    ...                :param ul_throughput_1:        value of ul_throughput_1
    ...                :param ul_throughput_2:        value of ul_throughput_2
    ...                :param dl_throughput_1:        value of dl_throughput_1
    ...                :param dl_throughput_2:        value of dl_throughput_2
    ...                :param ul_throughput_for_verify_1:     value of ul_throughput_1 to verify
    ...                :param ul_throughput_for_verify_2:     value of ul_throughput_2 to verify
    ...                :param dl_throughput_for_verify_1:     value of dl_throughput_1 to verify
    ...                :param dl_throughput_for_verify_2:     value of dl_throughput_2 to verify
    ...                :max_allowed_data_loss:      value of max_allowed_data_loss
    Log Action To Console                                       ---------Attach QC_SDX75---------
    ue.Attach UE                                                ${ue_type_1}
    Start DL and UL data transmission                           ${ul_throughput_1}
    ...                                                         ${dl_throughput_1}
    ...                                                         ${ue_type_1}
    ...                                                         ${ul_throughput_for_verify_1}
    ...                                                         ${dl_throughput_for_verify_1}
    ...                                                         ${max_allowed_data_loss}
    Detach UE                                                   ${ue_type_1}
    Log Action To Console                                       ---------Attach S21---------
    ue.Attach UE                                                ${ue_type_2}
    Start DL and UL data transmission                           ${ul_throughput_2}
    ...                                                         ${dl_throughput_2}
    ...                                                         ${ue_type_2}
    ...                                                         ${ul_throughput_for_verify_2}
    ...                                                         ${dl_throughput_for_verify_2}
    ...                                                         ${max_allowed_data_loss}
    Detach UE                                                   ${ue_type_2}

Try change parameter to wrong value
    [Arguments]    ${dist_name}    ${param_name}    ${param_value}    ${error_msg}
    [Documentation]    Keyword changes a parameter to a wrong value
    ...                :dist_name:      distanation name of a parameter
    ...                :param_name:     name of a parameter
    ...                :param_value:    value of a parameter
    ...                :error_msg:      msg of an error
    ${msg}=    Run Keyword And Expect Error    *    Perform configuration parameter recommissioning on gNB
    ...              ${dist_name}
    ...              ${param_name}
    ...              ${param_value}
    Should Contain    ${msg}    ${error_msg}

Verify L3 call TCP DL
    [Documentation]    Verifying L3 call for DL for 8CC configuration
    [Arguments]    ${ue_type_1}    ${dl_tput}
    Log Action To Console                                       ---------Attach QC_SDX75---------
    ue.Attach UE                                                ${ue_type_1}
    Start and Verify TCP DL data transfer for UEs               ${ue_type_1}
    ...                                                         ${dl_tput}
    Detach UE                                                   ${ue_type_1}

Verify L3 call TCP UL
    [Documentation]    Verifying L3 call for UL for 8CC configuration
    [Arguments]    ${ue_type_1}    ${ul_tput}
    Log Action To Console                                       ---------Attach QC_SDX75---------
    ue.Attach UE                                                ${ue_type_1}
    Start and Verify TCP UL data transfer for UEs               ${ue_type_1}
    ...                                                         ${ul_tput}
    Detach UE                                                   ${ue_type_1}

Start and Verify TCP DL data transfer for UEs
    [Arguments]     ${ue_type_1}
    ...             ${dl_tput}
    ...             ${dl_deviation}=5%
    [Documentation]    The keyword executes TC DL data transmission for a specific time and checks if throughput
    ...                was within allowed deviation
    ...    :param ue_type_1:        name of ue_1
    ...    :param ue_type_2:        name of ue_2
    ...    :param dl_tput_1:        DL_1 throughput value of data transfer
    ...    :param dl_tput_2:        DL_2 throughput value of data transfer
    ...    :dl_deviation:           value of deviation of DL throughput
    ${dl_dt_name_1}=            Set Variable    TCP_DL_DataTransfer_1
    ${dl_dt_name_2}=            Set Variable    TCP_DL_DataTransfer_2
    ${data_transfer_time}=      Set Variable    30s
    Log Action To Console       ---------Verify Average Throughput DL With Deviation for QC_SDX75---------
    ue.Start Data Transfer    dt_name=${dl_dt_name_1}    ue_alias=${ue_type_1}
    ...                       direction=dl    duration=${data_transfer_time}    protocol=tcp
    ...                       max_segment_size=1350B    parallel_streams=4
    ue.Await Data Transfer Finish    ${dl_dt_name_1}
    ue.Stop Data Transfer    dt_name=${dl_dt_name_1}
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name_1}    tput=${dl_tput}
    ...                                            deviation=${dl_deviation}

Start and Verify TCP UL data transfer for UEs
    [Arguments]     ${ue_type_1}
    ...             ${ul_tput}
    ...             ${ul_deviation}=10%
    [Documentation]    The keyword executes TC UL data transmission for a specific time and checks if throughput
    ...                was within allowed deviation
    ...    :param ue_type_1:        name of ue_1
    ...    :param ue_type_2:        name of ue_2
    ...    :param ul_tput_1:        UL_1 throughput value of data transfer
    ...    :param ul_tput_2:        UL_2 throughput value of data transfer
    ...    :dl_deviation:           value of deviation of UL throughput
    ${ul_dt_name_1}=            Set Variable    TCP_UL_DataTransfer_1
    ${ul_dt_name_2}=            Set Variable    TCP_UL_DataTransfer_2
    ${data_transfer_time}=      Set Variable    30s
    Log Action To Console       ---------Verify Average Throughput UL With Deviation for QC_SDX75---------
    ue.Start Data Transfer    dt_name=${ul_dt_name_1}    ue_alias=${ue_type_1}
    ...                       direction=ul    duration=${data_transfer_time}    protocol=tcp
    ...                       max_segment_size=1350B    parallel_streams=4
    ue.Await Data Transfer Finish    ${ul_dt_name_1}
    ue.Stop Data Transfer    dt_name=${ul_dt_name_1}
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name_1}    tput=${ul_tput}
    ...                                            deviation=${ul_deviation}
