*** Settings ***
Documentation
...  author:  Kamil Bielecki
...  contact: kamil.bielecki@nokia.com
...  description: Robot Keywords for CB010636 NR CA counters FR2

Library     DateTime                                                                  WITH NAME    dt
Library     OperatingSystem                                                           WITH NAME    os
Library     String                                                                    WITH NAME    str
Library     SSHLibrary                                                                WITH NAME    ssh_lib

Library     ute_ue                                                                    WITH NAME    ue
Library     taf.hw.pdu                                                                WITH NAME    pdu
Library     taf.sbts.oam.coam.admin                                                   WITH NAME    admin

Library     taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                          WITH NAME    gnbcounter
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                 WITH NAME    gnbcell
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning                    WITH NAME    gnbscf
Library     taf.rfrl.bts.devices.du.commissioning.EnbCommissioning                    WITH NAME    enbscf
Library     taf.rfrl.ue.ute_ue_config.UteUeConfig                                     WITH NAME    uteueconfig
Library     taf/rfrl/procedures/resources/python/sleeping_cell_detector.py            WITH NAME    scd

Library     testsuite/Krakow/RRM/RAN_PZ/resources/pcap_verification/flow_verifier.py         WITH NAME    flow_verifier
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB010636/resources/tcp_runner.py
Library     testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB010636/resources/suite_specific_keywords.py

Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/resources/resources.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${CB010636_A_counters}=     SEPARATOR=
...                         M55310C20001,M55310C20000,M55310C02025,M55310C02026,M55310C02027,M55310C02028,
...                         M55310C02031,M55316C14001,M55316C14002,M55310C02033,M55310C02034,M55310C02035,M55310C02036
${abstract_lib_config}       ${NONE}
${CB010636_B_counters}=     SEPARATOR=
...                         M55309C00036,M55309C00037,M55309C00002,M55309C00003,M55373C00001,M55373C00002,
...                         M55349C03002,M55349C04002,M55353C00002,M55353C00003,
${CB010636_C_counters}=     SEPARATOR=
...                         M55309C00004,M55309C00005,M55309C00006,M55309C00007,M55309C00008,M55309C00009,
...                         M55309C00010,M55309C00011,M55309C00020,M55309C00021,M55309C00022,M55309C00023,
...                         M55309C00024,M55309C00025,M55309C00026,M55309C00027,M55309C00036,M55309C00037,
...                         M55309C00002,M55309C00003
${current_config}           ${NONE}
@{list_of_additional_allowed_alarms}    User Account has Default Password

*** Keywords ***
Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs given message with extra markers (e.g: timestamp, new lines...).
    ...                :param msg:    message logged
    ...                :param datatime:    switch on/off timestamp logging
    ...                :param new_line_before:    switch on/off adding extra line before log
    ...                :param msg:    switch on/off adding extra line after log
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   dt.Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Set cells IDs
    ${gnb1_cell1_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${260}    du_id=0
    Set Suite Variable    ${gnb1_cell1_id}      ${gnb1_cell1_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell1_nrid}    ${gnb1_cell1_parameters['nrCellIdentity']}
    ${gnb1_cell2_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${261}    du_id=0
    Set Suite Variable    ${gnb1_cell2_id}      ${gnb1_cell2_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell2_nrid}    ${gnb1_cell2_parameters['nrCellIdentity']}
    ${gnb1_cell3_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${262}    du_id=0
    Set Suite Variable    ${gnb1_cell3_id}      ${gnb1_cell3_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell3_nrid}    ${gnb1_cell3_parameters['nrCellIdentity']}
    ${gnb1_cell4_parameters}=  gnbcell.Get Cell Parameters    bts_id=0    cell_id=${263}    du_id=0
    Set Suite Variable    ${gnb1_cell4_id}      ${gnb1_cell4_parameters['physCellId']}
    Set Suite Variable    ${gnb1_cell4_nrid}    ${gnb1_cell4_parameters['nrCellIdentity']}

Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...     swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...     should_LTE_neighbour_be_changed=${False}
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}
    Set Suite Variable    ${current_config}

Wait until all cells are onair
    [Arguments]    ${waiting_time}=10min    ${checking_interval}=15s
    [Documentation]    The keyword waits until all cells will be in on air.
    ...                :param waiting_time:    time to wait
    ...                :param checking_interval: time between checking
    Log Action To Console    Wait until all cells are onair
    Wait Until Keyword Succeeds    ${waiting_time}    ${checking_interval}
    ...    Verify All Cells Are OnAir    bts_id=0    du_id=0

Check PM counters for CB010636-A
    Log Action To Console    Waiting for counters to update
    Sleep   60s
    Log Action To Console    Check CB010636-A counters
    ${counters}=    gnbcounter.Get Counter    ${CB010636_A_counters}
    ${is_incorrect}=    Check CB010636 A Counters    ${counters}
    Run Keyword If      ${is_incorrect} == True
    ...                 Fail    Counters value incorrect. Check logs for more info.

Check PM counters for CB010636-B-13
    Log Action To Console    Waiting for counters to update
    Sleep   60s
    Log Action To Console    Check CB010636-B-13 counters
    ${counters}=    gnbcounter.Get Counter    ${CB010636_B_counters}
    ${is_incorrect}=    Check CB010636 B 13 Counters    ${counters}
    Run Keyword If      ${is_incorrect} == True
    ...                 Fail    Counters value incorrect. Check logs for more info.

Check PM counters for CB010636-B-19
    Log Action To Console    Waiting for counters to update
    Sleep   60s
    Log Action To Console    Check CB010636-B-19 counters
    ${counters}=    gnbcounter.Get Counter    ${CB010636_B_counters}
    ${is_incorrect}=    Check CB010636 B 19 Counters    ${counters}
    Run Keyword If      ${is_incorrect} == True
    ...                 Fail    Counters value incorrect. Check logs for more info.

Check PM counters for CB010636-B-19 empty
    Log Action To Console    Waiting for counters to update
    Sleep   60s
    Log Action To Console    Check CB010636-B-19 counters are empty
    ${counters}=    gnbcounter.Get Counter    ${CB010636_B_counters}
    ${is_incorrect}=    Check CB010636 B 19 Counters Empty   ${counters}
    Run Keyword If      ${is_incorrect} == True
    ...                 Fail    Counters value incorrect. Check logs for more info.

Check PM counters for CB010636-C-10
    Log Action To Console    Waiting for counters to update
    Sleep   60s
    Log Action To Console    Check CB010636-C-10 counters
    ${counters}=    gnbcounter.Get Counter    ${CB010636_C_counters}
    ${is_incorrect}=    Check CB010636 C 10 Counters    ${counters}
    Run Keyword If      ${is_incorrect} == True
    ...                 Fail    Counters value incorrect. Check logs for more info.

Check PM counters for CB010636-C-11
    Log Action To Console    Waiting for counters to update
    Sleep   60s
    Log Action To Console    Check CB010636-C-11 counters
    ${counters}=    gnbcounter.Get Counter    ${CB010636_C_counters}
    ${is_incorrect}=    Check CB010636 C 11 Counters    ${counters}
    Run Keyword If      ${is_incorrect} == True
    ...                 Fail    Counters value incorrect. Check logs for more info.

Test Setup NSA
    Log Action To Console    Test Setup
    Common Preconditions With Commissioning        test_config=CB010636_NSA
    Set cells IDs
    Set Suite Variable       ${current_config}      CB010636_NSA
    ue.Require Ue    UE_1   capabilities=REAL_ANDROID_UE
    Run Keyword And Ignore Error    ue.Detach Ue    UE_1

Test Setup Benchmarking
    Log Action To Console    Test Setup
    Common Preconditions With Commissioning        test_config=CB010636_NSA_benchmarking
    Set cells IDs
    Set Suite Variable       ${current_config}      CB010636_NSA
    ue.Require Ue    UE_1   capabilities=REAL_ANDROID_UE
    Run Keyword And Ignore Error    ue.Detach Ue    UE_1

Restart UE PROXY Service
    Log Action To Console        Restart UE PROXY Service
    ${host}=    Set Variable  ${abstract_lib_config.UE_PC.ue_pc_ip}
    ${username}=    Set Variable  ${abstract_lib_config.UE_PC.ue_pc_login}
    ${password}=    Set Variable  ${abstract_lib_config.UE_PC.ue_pc_password}
    ssh_lib.Open Connection      host=${host}    timeout=60s
    ssh_lib.Login                username=${username}    password=${password}
    ssh_lib.Execute Command      net stop UE_PROXY_AT && net start UE_PROXY_AT
    Sleep                        10s
    [Teardown]   ssh_lib.Close Connection

Get NR Cell ID in hex
    [Arguments]    ${nr_cell_id}
    [Documentation]    This keyword converts  NR Cell Id from integer to hexadecimal value
    ...                :param nr_cell_id:    NR cell id in integerl
    ${hex_nr_cell_id} =    Evaluate    '{0:#0{1}x}'.format(int(${nr_cell_id}), 11)
    [Return]    ${hex_nr_cell_id}

Test Setup SA
    Log Action To Console    Test Setup
    Common Preconditions With Commissioning        test_config=CB010636_SA
    Set cells IDs
    Set Suite Variable       ${current_config}      CB010636_SA
    ${status}=    Run Keyword And Return Status    ue.Require Ue    UE_1    QC_2
    Run Keyword If    '${status}' == '${False}'    Run Keywords     Restart UE PROXY Service     AND    ue.Require Ue    UE_1    QC_2
    Run Keyword And Ignore Error    ue.Detach UE   UE_1

UE Teardown
    Common Postconditions
    Run Keyword And Ignore Error    Detach UE

Wait For Next PM measurements
    [Arguments]   ${interval}=5min    ${delay}=30
    [Documentation]  Wait for the next counter cycle, indicated by the interval
    ...              :param interval:    Interval of the counter
    ...              :param delay:    delay for checking PM counters after specified period
    Log Action To Console   Wait For Next PM measurements period
    gnbcounter.Wait For Next Pm Period    ${interval}    ${delay}

Set default NR cell for dual connectivity on eNB
    [Arguments]    ${lncell_id}    ${desired_5g_cell_pci}
    [Documentation]     Keyword sets a default NRCELL object on eNB (NSA mode) to which UE should attach.
    ...                 :param lncell_id:               Cell id of eNB anchor for NSA mode
    ...                 :param desired_5g_cell_pci:     pci of NRCELL which will be default for attach
    enbscf.perform_configuration_parameter_recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNCEL-${lncell_id}
    ...    parameter=defaultLnRelGnbCellId    value=${desired_5g_cell_pci}
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Fail And Log Error
    [Arguments]   ${msg}
    [Documentation]    This keyword logs given message and fails test case.
    ...                :param msg:    message to log
    Log Action To Console    message=${msg}    level=ERROR
    Fail    msg=${msg}

Verify NSA flow pcap
    [Arguments]   ${pcap_filename}   ${expected_nr_cell_id}
    [Documentation]    The keyword checks if attach was performed successfully. The keyword checks attach messages
    ...                in pcap file.
    ...                :param pcap_file:     name of pcap file with extension
    ...                :param 5g_pci:        Physical cell ID of expected 5G cell to be added as PSCell
    ${pcap_file} =   Set variable   ${LOG_PATH}/${pcap_filename}
    ${attach_expected_messages} =    Create List
    ...    SgNBAdditionRequest    SgNBAdditionRequestAcknowledge(contains(physCellId=${expected_nr_cell_id}))
    ...    SgNBReconfigurationComplete    SNStatusTransfer
    Expect Messages In Flow    awaited_messages=${attach_expected_messages}   pcap_file=${pcap_file}
    ${rach_fail} =    Check If Message Is In Flow
    ...    awaited_message=SgNBModificationRequest(contains(scgFailureInfo))  pcap_file=${pcap_file}
    Run Keyword If   ${rach_fail}       Fail And Log Error   msg=SCG Failure occured
    ${sgnb_release} =    Check If Message Is In Flow
    ...    awaited_message=SgNBReleaseRequest  pcap_file=${pcap_file}
    Run Keyword If   ${sgnb_release}    Fail And Log Error   msg=SgNB Release occured

Verify 5G SA Attach
    [Arguments]    ${pcap_filename}    ${expected_nr_cell_id}
    [Documentation]    This keyword checks ID of attached SA cell.
    ...                :param pcap_filename:    filename of pcap with caught messages
    ...                :param expected_nr_cell_id:    expected cell's nrcellid
    ${hex_expected_nr_cell_id}=    Get Nr Cell Id In Hex    ${expected_nr_cell_id}
    ${message_found}=    flow_verifier.Check If Message Is In Flow
    ...    awaited_message=UplinkNASTransport(contains(*nRCellIdentity=${hex_expected_nr_cell_id}))
    ...    pcap_file=${LOG_PATH}/${pcap_filename}
    Run Keyword If    ${message_found} == ${False}    Fail    msg=Ue did not attach to expected cell.

Attach 5G NSA UE
    [Arguments]    ${cell_id}
    [Documentation]    This keyword performs UE attach to 5G SA cell and check if attach was performed to desired cell
    ...                :param cell_id:    local id of cell for which UE should be attached
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_name}=  Set variable    UE_attach_${date}.pcap
    Start Tcpdump On CU    filename=${pcap_name}    interface=any    protocol=sctp
    ue.Attach UE   UE_1
    Sleep    3s
    Stop Tcpdump On CU And Download Logs    filename=${pcap_name}
    ${expected_nr_cell_id}=    Set Variable If     '${cell_id}'=='${gnb1_cell1_id}'    ${gnb1_cell1_id}
    ${expected_nr_cell_id}=    Set Variable If     '${cell_id}'=='${gnb1_cell2_id}'    ${gnb1_cell2_id}        ${expected_nr_cell_id}
    ${expected_nr_cell_id}=    Set Variable If     '${cell_id}'=='${gnb1_cell3_id}'    ${gnb1_cell3_id}        ${expected_nr_cell_id}
    ${expected_nr_cell_id}=    Set Variable If     '${cell_id}'=='${gnb1_cell4_id}'    ${gnb1_cell4_id}        ${expected_nr_cell_id}
    Verify NSA flow pcap    pcap_filename=${pcap_name}    expected_nr_cell_id=${expected_nr_cell_id}

Attach 5G SA UE
    [Documentation]    This keyword performs UE attach to 5G SA cell and check if attach was performed to first cell
    ${date}=    dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_name}=  Set variable    UE_attach_${date}.pcap
    Log Action To Console    Attach 5G SA UE to cell 1
    Start Tcpdump On CU    filename=${pcap_name}    interface=any    protocol=sctp
    ue.Attach UE   UE_1
    Sleep    5s
    Stop Tcpdump On CU And Download Logs    filename=${pcap_name}
    Verify 5G SA Attach    pcap_filename=${pcap_name}    expected_nr_cell_id=${gnb1_cell1_nrid}
    Sleep    10s

Attach 5G NSA UE to Cell A
    [Documentation]    This Kewyord perform UE attach to the chosen gNB cell A and check if attach is succesful
    Log Action To Console    Prepare cell and Attach 5G NSA UE to cell 1
    Set default NR cell for dual connectivity on eNB    lncell_id=2
    ...     desired_5g_cell_pci=0
    Attach 5G NSA UE    cell_id=${gnb1_cell1_id}

Attach 5G NSA UE to Cell B
    [Documentation]    This Kewyord perform UE attach to the chosen gNB cell B and check if attach is succesful
    Log Action To Console    Prepare cell and Attach 5G NSA UE to cell 2
    Set default NR cell for dual connectivity on eNB    lncell_id=2
    ...     desired_5g_cell_pci=1
    Attach 5G NSA UE    cell_id=${gnb1_cell2_id}

Attach 5G NSA UE to Cell C
    [Documentation]    This Kewyord perform UE attach to the chosen gNB cell C and check if attach is succesful
    Log Action To Console    Prepare cell and Attach 5G NSA UE to cell 3
    Set default NR cell for dual connectivity on eNB    lncell_id=2
    ...     desired_5g_cell_pci=2
    Attach 5G NSA UE    cell_id=${gnb1_cell3_id}

Attach 5G NSA UE to Cell D
    [Documentation]    This Kewyord perform UE attach to the chosen gNB cell D and check if attach is succesful
    Log Action To Console    Prepare cell and Attach 5G NSA UE to cell 4
    Set default NR cell for dual connectivity on eNB    lncell_id=2
    ...     desired_5g_cell_pci=3
    Attach 5G NSA UE    cell_id=${gnb1_cell4_id}

Start Uplink and Downlink TCP Data Transmission
    [Arguments]    ${duration}
    [Documentation]    The keyword starts data transfer on UE with set duration.
    ...                :param duration:            duration of data transfer
    ue.Start Data Transfer    dt_name=DT_1_DL    ue_alias=UE_1
    ...                direction=dl    duration=${duration}    protocol=tcp
    ...                parallel=4      max_segment_size=1400B     apn=5gkrk2
    ue.Start Data Transfer    dt_name=DT_1_UL    ue_alias=UE_1
    ...                direction=ul    duration=${duration}    protocol=tcp
    ...                parallel=2      max_segment_size=1400B     apn=5gkrk2

Stop Data Transmission
    [Arguments]    ${dt_name}
    [Documentation]    The keyword stops already started data transfer
    ...                :param dt_name:    name of data transfer
    ue.Stop Data Transfer    dt_name=${dt_name}

Stop Uplink and Downlink Data Transmission
    Log Action To Console    Stop TCP data transmission
    Stop Data Transmission    dt_name=DT_1_DL
    Stop Data Transmission    dt_name=DT_1_UL

Run Downlink FR2 SA TCP Data Transmission
    [Arguments]    ${duration}
    [Documentation]    The keyword starts data transfer on UE with set duration.
    ...                :param duration:            duration of data transfer
    tcp_runner.Start Data Transfer    dt_name=DL_UE_DT    ue_alias=UE_1
    ...    app_server_cmd=iperf3 -s -B <APP_SERVER_BIND_IP> -p <APP_SERVER_IPERF_PORT> -i 1
    ...    ue_cmd=/usr/bin/iperf3 -c <APP_SERVER_BIND_IP> -p <UE_IPERF_PORT> -t ${duration} -B <UE_IP> -i 1 -P 6 -R
    Sleep    ${duration}
    tcp_runner.Stop Data Transfer    dt_name=DL_UE_DT

Enable CB010636-B counters
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    param_name=actMacUserThpt
    ...    param_value=${True}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${180}
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    param_name=actPerCellMacUserThpt
    ...    param_value=${True}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${180}

Disable CB010636-B counters
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    param_name=actPerCCDLUserThpt
    ...    param_value=${False}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${180}
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    param_name=actMacUserThpt
    ...    param_value=${False}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${180}
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    param_name=actPerCellMacUserThpt
    ...    param_value=${False}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${180}

Detach UE
    Log Action To Console    Detach UE
    ue.Detach Ue    UE_1

Block all cells on the second gNB
    gnbcell.Block all cells    bts_id=1
    Wait Until Keyword Succeeds    1min    15s    gnbcell.Verify all cells are blocked      bts_id=1

Unblock all cells on the second gNB
    gnbcell.Unblock all cells    bts_id=1
    Wait Until Keyword Succeeds    1min    15s    gnbcell.Verify all cells are unblocked      bts_id=1