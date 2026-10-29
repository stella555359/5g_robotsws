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

Detach Ue
    [Arguments]    ${ue_type}
    [Documentation]    The keyword performs UE detach.
    Log Action To Console    Detach UE ${ue_type}
    ue.Detach Ue    ${ue_type}

Verify allowed faults on gNB
    [Arguments]    @{faults_names}
    [Documentation]    Keyword verifies if there are no any alarms despite of allowed alarms gNB.
    ...                :param faults_names:    list of allowed alarms
    Verify Allowed Alarms on gNB    allowed_alarms=${faults_names}    gnb_id=0    du_id=${0}

Verify L3 call TCP DL
    [Documentation]    Verifying L3 call for DL for 8CC configuration
    [Arguments]    ${ue_type_1}    ${ue_type_2}
    Log Action To Console                                       ---------Attach QC_SDX75---------
    ue.Attach UE                                                ${ue_type_1}
    Log Action To Console                                       ---------Attach S21---------
    ue.Attach UE                                                ${ue_type_2}
    Start and Verify TCP DL data transfer for UEs               ${ue_type_1}
    ...                                                         ${ue_type_2}
    ...                                                         dl_tput_1=4100 Mbits/sec
    ...                                                         dl_tput_2=4100 Mbits/sec
    Detach UE                                                   ${ue_type_1}
    Detach UE                                                   ${ue_type_2}

Verify L3 call TCP UL
    [Documentation]    Verifying L3 call for UL for 8CC configuration
    [Arguments]    ${ue_type_1}    ${ue_type_2}

    Log Action To Console                                       ---------Attach S21---------
    ue.Attach UE                                                ${ue_type_2}
    Detach UE                                                   ${ue_type_2}

    Log Action To Console                                       ---------Attach QC_SDX75---------
    ue.Attach UE                                                ${ue_type_1}
    Log Action To Console                                       ---------Attach S21---------
    ue.Attach UE                                                ${ue_type_2}
    Start and Verify TCP UL data transfer for UEs               ${ue_type_1}
    ...                                                         ${ue_type_2}
    ...                                                         ul_tput_1=550 Mbits/sec
    ...                                                         ul_tput_2=250 Mbits/sec
    Detach UE                                                   ${ue_type_1}
    Detach UE                                                   ${ue_type_2}

Start and Verify TCP DL data transfer for UEs
    [Arguments]     ${ue_type_1}
    ...             ${ue_type_2}
    ...             ${dl_tput_1}
    ...             ${dl_tput_2}
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
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name_1}    tput=${dl_tput_1}
    ...                                            deviation=${dl_deviation}
    Log Action To Console       ---------Verify Average Throughput DL With Deviation for S21---------
    ue.Start Data Transfer    dt_name=${dl_dt_name_2}    ue_alias=${ue_type_2}
    ...                       direction=dl    duration=${data_transfer_time}    protocol=tcp
    ...                       max_segment_size=1350C    parallel_streams=4
    ue.Await Data Transfer Finish    ${dl_dt_name_2}
    ue.Stop Data Transfer    dt_name=${dl_dt_name_2}
    ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name_2}    tput=${dl_tput_2}
    ...                                            deviation=${dl_deviation}

Start and Verify TCP UL data transfer for UEs
    [Arguments]     ${ue_type_1}
    ...             ${ue_type_2}
    ...             ${ul_tput_1}
    ...             ${ul_tput_2}
    ...             ${ul_deviation}=12%
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
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name_1}    tput=${ul_tput_1}
    ...                                            deviation=${ul_deviation}
    Log Action To Console       ---------Verify Average Throughput UL With Deviation for S21---------
    ue.Start Data Transfer    dt_name=${ul_dt_name_2}    ue_alias=${ue_type_2}
    ...                       direction=ul    duration=${data_transfer_time}    protocol=tcp
    ...                       max_segment_size=1350C    parallel_streams=4
    ue.Await Data Transfer Finish    ${ul_dt_name_2}
    ue.Stop Data Transfer    dt_name=${ul_dt_name_2}
    ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name_2}    tput=${ul_tput_2}
    ...                                            deviation=${ul_deviation}
