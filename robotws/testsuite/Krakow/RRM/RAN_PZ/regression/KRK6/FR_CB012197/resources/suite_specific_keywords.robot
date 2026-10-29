*** Settings ***
Documentation
...    author: Mikolaj Borkowski
...    contact: mikolaj.borkowski@nokia.com

Library    taf/rfrl/procedures/resources/python/OAM_KPI/oam_kpi_runner.py
Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Library    DateTime                                                                  WITH NAME    dt
Library    OperatingSystem                                                           WITH NAME    os
Library    taf.ue
Library    taf.sbts.oam.coam.admin                                                   WITH NAME    coam
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                 WITH NAME    gnbcell
Library    taf.rfrl.bts.devices.du.du_operations.GnbDuOperations                     WITH NAME    gnb_du
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning                    WITH NAME    gnbscf
Library    taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations                     WITH NAME    gnbru
Library    testsuite.Krakow.RRM.RAN_PZ.resources.small_cells.sc_keywords.SmallCellsKeywords
Library    taf.sw.reporting_portal
Library    taf.rfrl.common_resources.oam_kpi.report_oam_kpi
Library    taf.rfrl.ue.ute_ue_config.UteUeConfig                                     WITH NAME    uteueconfig
Library     testsuite/Krakow/RRM/RAN_PZ/resources/pcap_verification/flow_verifier.py    WITH NAME    flow_verifier

Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/procedures/resources/robot/StatusCheck.robot
Resource   testsuite/Krakow/RRM/RAN_PZ/resources/resources.robot
Resource   taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource   taf/rfrl/bts/robot/common/gnb_scf.robot
Resource   taf/rfrl/bts/robot/common/gnb_alarm.robot
#Resource   taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Resource   taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot

Variables  taf/rfrl/procedures/resources/python/common_allowed_alarms.py



*** Variables ***
${reset_times}                10
${APN}                        ${None}
${UE_ALIAS}                   S22
${TPUT_TIME}                  12s
${UE_ATTACH_CELL_ID}          20518924
${UE_ATTACH_5G_CELL_ID_40}    40
${UE_ATTACH_5G_CELL_ID_50}    50

*** Keywords ***
Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${True}
    [Documentation]  :param msg:     message logged
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   dt.Get Current Date    exclude_millis=yes
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console   [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

CB012197 Test Teardown with UE
    [Documentation]    Common postcondidtion teardown with UE detach
    Log Action to Console    End test
    Run Keyword and Ignore Error    ute_ue.Detach Ue    ${UE_ALIAS}
    Common Postconditions

CB012197 Test Teardown with waiting for all cells to be on air and UE detach
    [Documentation]    Common postcondidtion teardown with waiting for all cells to be on air
    Log Action to Console    End test
    Run Keyword and Ignore Error    ute_ue.Detach Ue    ${UE_ALIAS}
    Wait Until Keyword Succeeds    8 minute    10 seconds    gnbcell.verify_all_cells_statuses
    ...            cell_type=all
    ...            blocking_state=unblocked    availability_status=online    operational_state=enabled
    ...            procedural_status=configured    administrative_state=unlocked    usage_state=${None}
    ...            barring_status=unbarred
    Common Postconditions

CB012197 General_SiSo_BB_sub-unit_reset_with_L3_call Test Teardown
    [Documentation]    Common postcondidtion teardown with UE detach and Unlocking RUs blocked during test
    Log Action to Console    End test
    Run Keyword and Ignore Error    ute_ue.Detach Ue    ${UE_ALIAS}
    Unblock RU    bts_id=0    radio_unit_id=4
    Unblock RU    bts_id=0    radio_unit_id=6
    Common Postconditions

Attach Ue
    [Arguments]    ${ue_type}    ${desired_5g_cell_pci}
    [Documentation]    The keyword perform attach EN-DC and checks if attach was performed to desired cell 4G and 5G.
    ...                :param desired_5g_cell_pci:    Physical cell ID of expected 5G cell to be added as PSCell
    ...                :param ue_type: Typ uzywanego UE
    Log Action To Console    Attach UE
    ${date}=    dt.Get Current Date   exclude_millis=True    result_format=%d.%m.%Y.%H.%M
    ${pcap_name}=  Set Variable    UE_attach-${date}.pcap
    Set Suite Variable     ${pcap_name}
    Start Tcpdump     filename=${pcap_name}
    ute_ue.Attach UE   ${ue_type}
    Stop Tcpdump On CU And Download Logs    filename=${pcap_name}
    Verify NSA Flow Pcap   ${pcap_name}   ${desired_5g_cell_pci}
    ${4G_CELL_ID}=    ute_ue.Get Ue Info    ${ue_type}   CELL_ID
    Should Be Equal    ${UE_ATTACH_CELL_ID}     ${4G_CELL_ID}

Detach UE
    [Arguments]    ${ue_type}
    [Documentation]    The keyword performs UE detach.
    Log Action To Console    Detach UE ${ue_type}
    ute_ue.Detach Ue    ${ue_type}

Stop Tcpdump
    [Documentation]    Stop Tcpdump
    Sleep   3 s    reason=Wait a while before stopping the logs
    ${alias}=        Connect To gNB
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.execute
    ...              command=killall tcpdump
    ...              connection=${alias}
    ...              ELSE
    ...              ssh.execute
    ...              command=sudo killall tcpdump
    ...              connection=${alias}

Start Tcpdump
    [Arguments]   ${filename}=${test_name}.pcap   ${interface}=any   ${sleep_after_start_s}=3
    [Documentation]    Start Tcpdump to collect pcap
    ...                :param filename: Name of a collected pcap
    ...                :param interface: Interface that is used in tcpdum
    ...                :param sleep_after_start_s: Amount of time to wait after the log starts
    ${alias}=    Connect To gNB
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.send_command    command=tcpdump -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    ...              ELSE
    ...              ssh.send_command    command=sudo tcpdump -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    Sleep   ${sleep_after_start_s} s   reason=Wait a while after the log starts

Verify NSA Flow Pcap
    [Arguments]   ${pcap_file}   ${5g_pci}
    [Documentation]    The keyword checks if attach was performed successfully. The keyword checks attach messages
    ...                in pcap file.
    ...                :param pcap_file:     name of pcap file with extension
    ...                :param 5g_pci:        Physical cell ID of expected 5G cell to be added as PSCell
    ${pcap_file} =   Set Variable   ${LOG_PATH}/${pcap_file}
    ${attach_expected_messages} =    Create List
    ...    SgNBAdditionRequest    SgNBAdditionRequestAcknowledge(contains(physCellId=${5g_pci}))
    ...    SgNBReconfigurationComplete    SNStatusTransfer
    flow_verifier.Expect Messages In Flow    awaited_messages=${attach_expected_messages}   pcap_file=${pcap_file}
    ${rach_fail} =    flow_verifier.Check If Message Is In Flow
    ...    awaited_message=SgNBModificationRequest(contains(scgFailureInfo))  pcap_file=${pcap_file}
    Run Keyword If    ${rach_fail}       Fail   msg=SCG Failure occured
    ${sgnb_release} =    flow_verifier.Check If Message Is In Flow
    ...    awaited_message=SgNBReleaseRequest  pcap_file=${pcap_file}
    Run Keyword If    ${sgnb_release}    Fail  msg=SgNB Release occured

Verify allowed faults on gNB
    [Arguments]     @{allowed_alarms}
    [Documentation]    Keyword verifies if there are no any alarms despite of allowed alarms gNB.
    ...                :param faults_names:    List of allowed alarms.
    Log Action to Console    Verify Allowed Alarms on gNB
    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}    gnb_id=0    du_id=${0}

Wait until cell is blocked
    [Arguments]    ${cell_id}
    [Documentation]    The keyword waits until cell will be in operational state equals disabled value
    ...                cell's availability status will be offline and cell's administrative state will be unlocked.
    ...                :param cell_id:    global cell id
    Log Action to Console   Wait until cell is blocked
    Wait Until Keyword Succeeds    5min    10s    Verify Cell Statuses    gnb_id=0    cell_id=${cell_id}    du_id=0
    ...    operational_state=Disabled    procedural_status=configured
    ...    availability_status=Offline    administrative_state=Unlocked

Verify gNB Cell Is Unblocked
    [Arguments]    ${cell_id}
    [Documentation]    Verify if cell is unblocked.
    ...                :param cell_id:    global cell id
    Log Action to Console   Verify Cell Is Unblocked
    gnbcell.Verify Cell Is Unblocked    cell_id=${cell_id}

Verify Attach and Detach Procedure
    [Arguments]    ${ue_type}    ${desired_5g_cell_pci}
    [Documentation]    Verifying attach to a correct cells and detach
    ...                :param ue_type: Type of a used UE
    ...                :param desired_5g_cell_pci: 5G cell PCI that we want to attach to
    Attach Ue          ue_type=${ue_type}
    ...                desired_5g_cell_pci=${desired_5g_cell_pci}


    Sleep    10s
    Detach UE    ${ue_type}

Check BTS and RATs states
    [Documentation]  Check if gNB is onAir
    Log Action to Console    Verify BTS and RATs states
    Verify all RATs states
    Verify Procedural and Blocking State

NR RAT Reset
    [Documentation]    Perform NR RAT reset
    Log Action to Console    NR RAT reset
    coam.Setup admin    bts_host=192.168.255.129
    ...            bts_port=443
    ...            use_ssl=True
    coam.rat reset    rat_type=NR    reset_type=Soft    timeout=600
    Log Action to Console    Check if LTE RAT not impacted
    gnbru.verify_statuses_on_ru                   ru_id=2
    ...                                           operational_state=enabled     procedural_status=configured
    ...                                           availability_status=online    administrative_state=unlocked
    ...                                           usage_state=active
    Log Action to Console    Check if NR RAT impacted
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Cell Statuses    cell_id=40
        ...                             operational_state=disabled     administrative_state=unlocked
        ...                             availability_status=failed     procedural_status=not initialized

General SiSo Cell block and unblock
    [Documentation]    Block all cells, first one by one and then all cells for each group
    Block All Cells And Then Unblock One By One
    Verify All Cells Are Unblocked
    Wait Until Keyword Succeeds    8 minute    10 seconds    gnbcell.verify_all_cells_statuses
    ...            cell_type=all
    ...            blocking_state=unblocked    availability_status=online    operational_state=enabled
    ...            procedural_status=configured    administrative_state=unlocked    usage_state=${None}
    ...            barring_status=unbarred
    Block Unblock All Cells For Each Group
    Verify All Cells Are Unblocked
    Wait Until Keyword Succeeds    8 minute    10 seconds    gnbcell.verify_all_cells_statuses
    ...            cell_type=all
    ...            blocking_state=unblocked    availability_status=online    operational_state=enabled
    ...            procedural_status=configured    administrative_state=unlocked    usage_state=${None}
    ...            barring_status=unbarred
    Wait For Site To Be Onair
    Wait Until Keyword Succeeds    8 minute    10 seconds    gnbcell.verify_all_cells_statuses
    ...            cell_type=all
    ...            blocking_state=unblocked    availability_status=online    operational_state=enabled
    ...            procedural_status=configured    administrative_state=unlocked    usage_state=${None}
    ...            barring_status=unbarred

Verify L3 call for 1x8CC
    [Arguments]    ${ue_type}    ${desired_5g_cell_pci}
    [Documentation]    Verifying L3 call for DL and UL
    ...                :param ue_type: Type of a used UE
    ...                :param desired_5g_cell_pci: 5G cell PCI that we want to attach to
    Attach Ue                                                  ue_type=${ue_type}
    ...                                                        desired_5g_cell_pci=${desired_5g_cell_pci}
    Sleep     60s   reason=Wait for ENDC setup
    Start DL data transmission for 1x8CC                 ue_type=${ue_type}
    Sleep     60s   reason=Wait until UE cools down
    Start UL data transmission for 1x8CC                 ue_type=${ue_type}
    Detach UE                                                   ${ue_type}

Verify L3 call for 1x4CC
    [Arguments]    ${ue_type}    ${desired_5g_cell_pci}
    [Documentation]    Verifying L3 call for DL and UL
    ...                :param ue_type: Type of a used UE
    ...                :param desired_5g_cell_pci: 5G cell PCI that we want to attach to
    Attach Ue                                                  ue_type=${ue_type}
    ...                                                        desired_5g_cell_pci=${desired_5g_cell_pci}
    Sleep     60s   reason=Wait for ENDC setup
    Start DL data transmission for 1x4CC                 ue_type=${ue_type}
    Sleep     60s   reason=Wait until UE cools down
    Start UL data transmission for 1x4CC                 ue_type=${ue_type}
    Detach UE                                                   ${ue_type}

Reset BBMOD and check alarms
    [Arguments]     ${bb_mod_id}
    [Documentation]    performs BBMOD reset and verify cells and RUs status
    ...                :param bb_mod_id: Id of a RU that will be reset
    Wait Until Keyword Succeeds    8 minute    10 seconds    gnbcell.verify_all_cells_statuses
    ...            cell_type=all
    ...            blocking_state=unblocked    availability_status=online    operational_state=enabled
    ...            procedural_status=configured    administrative_state=unlocked    usage_state=${None}
    ...            barring_status=unbarred
    Log Action To Console    ================================ BBMOD ${bb_mod_id} reset ================================
    gnb_du.reset bbmod              bbmod_id=${bb_mod_id}
    Wait Until Keyword Succeeds     360 seconds  15 seconds  gnbru.verify_all_radio_units_statuses
    ...            bts_id=0    du_id=0    radio_type=all    skip_ru_if_not_configured=False
    ...            availability_status=${None}    operational_state=enabled    administrative_state=unlocked
    ...            procedural_status=configured        usage_state=${None}
    ...            power_state=${None}

    Wait Until Keyword Succeeds    360 seconds   15 seconds    gnbcell.verify_all_cells_statuses
    ...            cell_type=all
    ...            blocking_state=unblocked    availability_status=online    operational_state=enabled
    ...            procedural_status=configured    administrative_state=unlocked    usage_state=${None}
    ...            barring_status=unbarred

Start DL data transmission for 1x4CC
    [Arguments]    ${ue_type}=S20
    [Documentation]    Performs DL data transmission and verify the results for 4CC
    ...                :param ue_type: Type of a used UE
    Log Action To Console    Start DL data transmission
    Start And Verify DL Data Transmission    dl_throughput=1.05 Gbits/sec    data_transfer_time=${TPUT_TIME}
    ...    ue_type=${ue_type}    apn=${APN}    max_allowed_data_loss=15%    dl_throughput_for_verify=1.90 Gbits/sec

Start UL data transmission for 1x4CC
    [Arguments]    ${ue_type}=S20
    [Documentation]    Performs UL data transmission and verify the results for 4CC
    ...                :param ue_type: Type of a used UE
    Log Action To Console    Start UL data transmission
    Start And Verify UL Data Transmission    ul_throughput=500 Mbits/sec     data_transfer_time=${TPUT_TIME}
    ...     ue_type=${ue_type}    apn=${APN}    max_allowed_data_loss=15%    ul_throughput_for_verify=500 Mbits/sec

Start DL data transmission for 1x8CC
    [Arguments]    ${ue_type}=S20
    [Documentation]    Performs DL data transmission and verify the results for 8CC
    ...                :param ue_type: Type of a used UE
    Log Action To Console    Start DL data transmission
    Start And Verify DL Data Transmission    dl_throughput=1.80 Gbits/sec    data_transfer_time=${TPUT_TIME}
    ...     ue_type=${ue_type}    apn=${APN}    max_allowed_data_loss=15%    dl_throughput_for_verify=3.60 Gbits/sec

Start UL data transmission for 1x8CC
    [Arguments]    ${ue_type}=S20
    [Documentation]    Performs UL data transmission and verify the results for 8CC
    ...                :param ue_type: Type of a used UE
    Log Action To Console    Start UL data transmission
    Start And Verify UL Data Transmission     ul_throughput=500 Mbits/sec     data_transfer_time=${TPUT_TIME}
    ...    ue_type=${ue_type}    apn=${APN}    max_allowed_data_loss=15%    ul_throughput_for_verify=500 Mbits/sec

Start And Verify DL Data Transmission
    [Arguments]    ${dl_throughput}    ${data_transfer_time}    ${ue_type}   ${max_allowed_data_loss}
    ...    ${dl_throughput_for_verify}    ${dl_dt_name}=DT_1_DL    ${apn}=${None}
    [Documentation]    Start, await, stop and verify average throughput for DL
    ...                :param dl_throughput: Value of the DL throughput
    ...                :param data_transfer_time: Time of a data transfer
    ...                :param ue_type: Type of the UE
    ...                :param max_allowed_data_loss: Maximal allowed data loss
    ...                :param dl_throughput_for_verify: Minimal value of the DL throughput to pass a test case
    ...                :param dl_dt_name: Iperf param to start DL tput
    ...                :param apn: APN
    Log Action To Console    Start DL data transmission
    ute_ue.Start Data Transfer    dt_name=${dl_dt_name}    ue_alias=${ue_type}    apn=${apn}
    ...                       direction=dl    duration=${data_transfer_time}    protocol=udp
    ...                       throughput=${dl_throughput}
    ...                       iperf_len=1350B    packet=1350B    buffer_server=4M    parallel_streams=2
    ute_ue.Await Data Transfer Finish    ${dl_dt_name}
    ute_ue.Stop Data Transfer    dt_name=${dl_dt_name}
    ute_ue.Verify Average Throughput With Deviation    dt_name=${dl_dt_name}
    ...                                                deviation=${max_allowed_data_loss}
    ...                                                tput=${dl_throughput_for_verify}
    ...                                                omit=2

Start And Verify UL Data Transmission
    [Arguments]    ${ul_throughput}    ${data_transfer_time}    ${ue_type}   ${max_allowed_data_loss}
    ...    ${ul_throughput_for_verify}    ${ul_dt_name}=DT_1_UL    ${apn}=${None}
    [Documentation]    Start, await, stop and verify average throughput for UL
    ...                :param ul_throughput: Value of the UL throughput
    ...                :param data_transfer_time: Time of a data transfer
    ...                :param ue_type: Type of the UE
    ...                :param max_allowed_data_loss: Maximal allowed data loss
    ...                :param ul_throughput_for_verify: Minimal value of the UL throughput to pass a test case
    ...                :param ul_dt_name: Iperf param to start UL tput
    ...                :param apn: APN
    Log Action To Console    Start UL data transmission
    ute_ue.Start Data Transfer    dt_name=${ul_dt_name}    ue_alias=${ue_type}    apn=${apn}
    ...                       direction=ul    duration=${data_transfer_time}    protocol=udp
    ...                       throughput=${ul_throughput}
    ...                       packet_size=1350    buffer_client=4M
    ute_ue.Await Data Transfer Finish    ${ul_dt_name}
    ute_ue.Stop Data Transfer    dt_name=${ul_dt_name}
    ute_ue.Verify Average Throughput With Deviation    dt_name=${ul_dt_name}
    ...                                                deviation=${max_allowed_data_loss}
    ...                                                tput=${ul_throughput_for_verify}
    ...                                                omit=2
Lock Radio Unit via WebUI
    [Arguments]    ${radio_unit_id}=0
    [Documentation]    Lock radio unit with specified id via WebUI.
    ...                :param radio_unit_id:    position of radio unit in rus table from Test Line configuration
    Log Action to Console    Lock Radio Unit via WebUI
    Lock Radio Unit on gNB from GUI   gnb_id=0    radio_unit_id=${radio_unit_id}    du_id=0
    Sleep    3s

Block RU
    [Arguments]    ${bts_id}    ${radio_unit_id}
    [Documentation]    Blocks RUs for neighbor eNB nad gNB at the beggining of suite tests run
    Log Action To Console                Lock RU with ID ${radio_unit_id}
    gnbru.lock_radio_unit                bts_id=${bts_id}    radio_unit_id=${radio_unit_id}
    Log Action To Console                Verify RU with ID ${radio_unit_id} is locked
    Wait Until Keyword Succeeds          90s    15s
    ...                                  gnbru.verify_radio_unit_is_locked
    ...                                  bts_id=${bts_id}   radio_unit_id=${radio_unit_id}    radio_type=rmod


Unblock RU
    [Arguments]    ${bts_id}    ${radio_unit_id}
    [Documentation]    Unblocks RUs for neighbor eNB nad gNB at the end of Test suite run
    Log Action To Console                Unlock RU with ID ${radio_unit_id}
    gnbru.unlock_radio_unit              bts_id=${bts_id}   radio_unit_id=${radio_unit_id}
    Log Action To Console                Verify RU with ID ${radio_unit_id} is unlocked
    Wait Until Keyword Succeeds          1min    15s
    ...                                  gnbru.verify_radio_unit_is_unlocked
    ...                                  bts_id=${bts_id}    radio_unit_id=${radio_unit_id}    radio_type=rmod
