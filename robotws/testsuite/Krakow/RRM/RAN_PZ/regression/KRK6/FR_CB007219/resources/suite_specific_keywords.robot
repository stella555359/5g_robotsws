*** Settings ***
Documentation
...   author: Jakub Bak
...   contact: jakub.1.bak@nokia.com
...   maintainer: jakub.1.bak@nokia.com

Library   DateTime                                                                    WITH NAME    dt
Library   XML                                                                         use_lxml=true
Library   SSHLibrary
Library   ute_ue                                                                      WITH NAME    ue
Library   OperatingSystem                                                             WITH NAME    os
Library   ute_tshark
Library   taf.rfrl.ue.ute_ue_config.UteUeConfig
Library   taf.collectors.tcpdump                                                      WITH NAME    tcpdump
Library   taf.collectors.core                                                         WITH NAME    core
Library   ./smart_attenuator.py                                                       WITH NAME    attenuator
Library   testsuite/Krakow/RRM/RAN_PZ/resources/pcap_verification/flow_verifier.py    WITH NAME    flow_verifier
Library   testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/suite_specific_keywords.py
Library   testsuite/Krakow/RRM/RAN_PZ/regression/KRK6/FR_CB007219/resources/qc_ids.py

Resource  taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource  testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${header_to_repo}    'X-JFrog-Art-Api: AKCp8oiHU5YVmxybvkJef917wNemeaeHb5LMqX8272B2AU1dcGx4fHim1ifQ8JVJcZR6kZYMj'
${directory_plugins}    /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/

${pcell_id_message}      .//field[@name='nr-rrc.spCellConfig_element']//field[@name='nr-rrc.physCellId']
${scell_id_message}      .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.physCellId']
${pcell_band_message}    .//field[@name='nr-rrc.spCellConfig_element']//field[@name='nr-rrc.FreqBandIndicatorNR']
${scell_band_message}    .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.reqBandIndicatorNR']
${data_transfer_duration}    30

*** Keywords ***

Suite Setup
    [Documentation]    CB007219 suite setup with contains common suite setup and prepare tshark to read pcap files.
    Log Action To Console    Suite Setup
    &{abstract_lib_config}=    Get ute UE Configuration Dict
    Set Suite Variable    ${abstract_lib_config}
    Set Suite Variable    $ue_pc     ${abstract_lib_config.UE_PC}
    ute_tshark.setup tshark    eth1
    ${setup_sw_gnb}=    Get SW From BTS
    ${release}=     Get Release From SW    ${setup_sw_gnb}
    ${cb_b5_ca_qc_tag}=    Get QC TAG From Release    test_name=CB007219-CB_B5_CA_configuration
    ...                                               release=${release}
    ${cb_b3.2_ca_qc_tag}=    Get QC TAG From Release    test_name=CB007219-CB_B3.2_CA_configuration
    ...                                                 release=${release}
    ${cb_b1_ca_qc_tag}=    Get QC TAG From Release    test_name=CB007219-CB_B1_de-activation_of_FR2_CA
    ...                                                 release=${release}
    Set Global Variable    ${CB_B5_CA_QC_TAG}      ${cb_b5_ca_qc_tag}
    Set Global Variable    ${CB_B3.2_CA_QC_TAG}    ${cb_b3.2_ca_qc_tag}
    Set Global Variable    ${CB_B1_CA_QC_TAG}      ${cb_b1_ca_qc_tag}
    Setup Attenuator
    suite_specific_keywords.Set cell attenuation to 0dB

Setup Attenuator
    [Documentation]    Initializes attenuator.
    Log Action to Console    Setup Attenuator
    attenuator.setup_attenuator    attenuator=${tl.attenuators[0]}    alias=RADIO_RACK
    Set Suite Variable    @{GNB_1_2_ALL_CELLS_RF_PORTS}    ${1}    ${18}    ${69}    ${86}
    ...    ${137}    ${154}    ${205}    ${222}

Attenuate all ports
    [Documentation]    Initializes attenuator and turn on attenuation for all cells.
    Log Action to Console    Attenuate all ports
    ${ports}=    Evaluate    list(range(1, 257))
    ${values}=    Evaluate    ["64dB"] * 256
    attenuator.Set Ports Attenuation    RADIO_RACK    ${ports}    ${values}

Set cell attenuation to 0dB
    [Documentation]    Turn off attenuation from Cell.
    [Arguments]     ${RF_ports}=${GNB_1_2_ALL_CELLS_RF_PORTS}
    Log Action to Console    Set cell attenuation to 0dB
    Set cell attenuation    att_value=0dB    RF_ports=${RF_ports}

Set cell attenuation
    [Documentation]    Set attenuation from Cell.
    [Arguments]     ${att_value}=0dB   ${RF_ports}=${GNB_1_2_ALL_CELLS_RF_PORTS}
    Log Action to Console    ======= Set cell attenuation to ${att_value} ========\n
    ${values}=    Create List     ${att_value}    ${att_value}    ${att_value}    ${att_value}    ${att_value}
    ...    ${att_value}    ${att_value}    ${att_value}
    attenuator.Set Ports Attenuation    RADIO_RACK    ${RF_ports}    ${values}

Download Wireshark Plugins
    [Documentation]    Download wireshark plugins to read f1ap and xnap messages into wireshark plugin folder
    Log Action To Console     Downloading plugins for wireshark...\n
    ${url_xn_plugin}=    Get Latest Plugin Url    plugin=Nokia_Xn_AP
    OperatingSystem.Run     sudo wget --header=${header_to_repo} -P ${directory_plugins} ${url_xn_plugin}
    ${url_f1_plugin}=    Get Latest Plugin Url    plugin=Nokia_F1_AP
    OperatingSystem.Run     sudo wget --header=${header_to_repo} -P ${directory_plugins} ${url_f1_plugin}

Attach UE
    [Documentation]    The keyword perform attach
    Log Action To Console    Attach UE
    ue.Attach UE   SDX_75
    Sleep  5s

Detach UE
    [Documentation]    This keyword perform detach
    Log Action To Console    Detach UE
    ue.Detach Ue    SDX_75
    Sleep  3s

Start tcpdump on gNB
    [Arguments]    ${pcap_filename}
    [Documentation]   The keyword starts collecting pcap log file on gNB with tcpdump command.
    ...          :pcap_filename:     name of collected log file
    Log Action to Console    Start collecting pcap file
    Start tcpdump on CU     filename=${pcap_filename}    interface=any

Stop tcpdump on gNB
    [Arguments]    ${pcap_filename}
    [Documentation]   The keyword starts collecting pcap log file on gNB with tcpdump command.
    ...          :pcap_filename:     name of collected log file
    Log Action to Console    Stop collecting pcap file and download it from gNB
    Stop tcpdump on CU and Download Logs    filename=${pcap_filename}

Verify Cell Addition
    [Arguments]    ${pcap_filename}    ${expected_cell_id}    ${expected_cell_band}   ${cell_type}
    [Documentation]   This keyword verify frequency band and ID of selected type of cell, based on pcap message
    ...               :pcap_filename:          name of collected log file
    ...               :expected_scell_ids:     expected ID of pcells
    ...               :expected_scell_bands:   expected band freq of pcells
    ...               :cell_type:              type of veryfied cell, values: scell/pcell
    Run Keyword If    '${cell_type}'=='pcell'    Run Keywords
    ...     Set Test Variable   ${cell_id_message}    ${pcell_id_message}     AND
    ...     Set Test Variable   ${cell_band_message}     ${pcell_band_message}
    Run Keyword If    '${cell_type}'=='scell'    Run Keywords
    ...     Set Test Variable   ${cell_id_message}    ${scell_id_message}     AND
    ...     Set Test Variable   ${cell_band_message}     ${scell_band_message}
    ${output}    ute_tshark.read pcap    packet_filter=f1ap.procedureCode ==7   output_type=pdml  pcap_file_path=${pcap_filename}
    ${cell_id_elements}    Get elements   ${output}    ${cell_id_message}
    ${cell_band_elements}    Get elements    ${output}    ${cell_band_message}
    FOR  ${x}  IN  @{cell_id_elements}
        ${cell_id}=  Get element attribute   ${x}  showname
        @{cell_id_list} =  Split String    ${cell_id}
        ${cell_id_nr}=    Get From List    ${cell_id_list}    1
            Should Contain Any  ${expected_cell_id}  ${cell_id_nr}    msg=Wrong ${cell_type} IDs
    END
    FOR  ${x}  IN  @{cell_band_elements}
        ${cell_band}=  Get element attribute   ${x}  show
            Should Contain Any    ${expected_cell_band}  ${cell_band}    msg=Wrong ${cell_type} Bands
    END

Check CA with MFBI
    [Arguments]    ${pcell_id}    ${scell_ids}    ${scell_freqBands}    ${pcell_freqBand}
    [Documentation]    This keyword tests MFBI (Multi Frequency Band Indicator)
    Log Action to Console    Checking if MFBI CA feature works
    ${date}=  dt.Get Current Date    result_format=%d_%m_%Y_%H_%M
    ${pcap_filename}=  Set variable   MFBI_${date}.pcap
    Start tcpdump on gNB    pcap_filename=${pcap_filename}
    Attach UE
    Sleep  30s
    Detach UE
    Create Directory  ${LOG_PATH}
    Stop tcpdump on gNB    pcap_filename=${pcap_filename}
    Log Action To Console  Verify Pcell Addition
    Verify Cell Addition
    ...    pcap_filename=${LOG_PATH}/${pcap_filename}
    ...    expected_cell_id=${pcell_id}
    ...    expected_cell_band=${pcell_freqBand}
    ...    cell_type=pcell
    Log Action To Console  Verify Scell Addition
    Verify Cell Addition
    ...    pcap_filename=${LOG_PATH}/${pcap_filename}
    ...    expected_cell_id=${scell_ids}
    ...    expected_cell_band=${scell_freqBands}
    ...    cell_type=scell

Start DL and UL data transmission for specified time
    [Arguments]    ${tput_dl_min}    ${tput_ul_min}    ${data_transfer_time}=${data_transfer_duration}
    [Documentation]    This keyword starts UDP traffic transmision in both directions for specified time.
    ...                :param data_transfer_time:    data trasmission's time in seconds
    ...                :param tput_ul_min:    level of minimum required throughput in uplink direction
    ...                :param tput_dl_min:    level of minimum required throughput in downlink direction
    ...                :param data_transfer_time:    duration of data transmission
    Log Action to Console    Verify SCell activation and throughput
    Attach UE
    Log Action To Console    Start TCP DL and UL data transmission for ${data_transfer_time} seconds
    ue.Start Data Transfer    dt_name=DT_1_UL    ue_alias=SDX_75
    ...                       direction=ul       protocol=tcp
    ...                       parallel=4         max_segment_size=1350B
    Sleep    2s
    ue.Start Data Transfer    dt_name=DT_1_DL    ue_alias=SDX_75
    ...                       direction=dl       protocol=tcp
    ...                       parallel=4         max_segment_size=1350B
    Sleep    ${data_transfer_time}
    Log Action To Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=DT_1_UL
    ue.Stop Data Transfer    dt_name=DT_1_DL
    Log Action To Console    Verify DL and UL avg tput
    ue.Verify Average Throughput      DT_1_UL     tput_min=${tput_ul_min}    tput_max=800 Mbits/sec
    ue.Verify Average Throughput      DT_1_DL     tput_min=${tput_dl_min}    tput_max=7000 Mbits/sec
    Detach UE

Verify TCP UL and DL Data Transmission
    [Arguments]    ${tput_dl_min}    ${tput_ul_min}    ${tput_dl_max}    ${tput_ul_max}    ${data_transfer_time}=20
    [Documentation]    This keyword starts TCP traffic transmision in both directions for specified time.
    ...                :param data_transfer_time:    data trasmission's time in seconds
    ...                :param tput_dl_min:    level of minimum required throughput in downlink direction
    ...                :param tput_ul_min:    level of minimum required throughput in uplink direction
    ...                :param tput_dl_max:    level of maximum required throughput in downlink direction
    ...                :param tput_ul_max:    level of maximum required throughput in uplink direction
    ...                :param data_transfer_time:    duration of data transmission
    Log Action To Console    Start TCP DL and UL data transmission for ${data_transfer_time} seconds
    ue.Start Data Transfer    dt_name=DT_1_UL    ue_alias=SDX_75
    ...                       direction=ul       protocol=tcp
    ...                       parallel=4         max_segment_size=1350B
    Sleep    2s
    ue.Start Data Transfer    dt_name=DT_1_DL    ue_alias=SDX_75
    ...                       direction=dl       protocol=tcp
    ...                       parallel=4         max_segment_size=1350B
    Sleep    ${data_transfer_time}
    Log Action To Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=DT_1_UL
    ue.Stop Data Transfer    dt_name=DT_1_DL
    Log Action To Console    Verify DL and UL avg tput
    ue.Verify Average Throughput      DT_1_UL     tput_min=${tput_ul_min}    tput_max=${tput_ul_max}
    ue.Verify Average Throughput      DT_1_DL     tput_min=${tput_dl_min}    tput_max=${tput_dl_max}

Set qrxLevMin for 5G cell
    [Arguments]    ${nrcell_id}    ${qrxlevmin_value}
    [Documentation]    Keyword sets default NR cell for EN-DC.
    ...    :param nrcell_id: id of NR cell for which qrxLevMin to be set
    ...    :param qrxlevmin_value: value of qRXLevMin to be set
    Log Action to Console    Set qrxlevmin to ${qrxlevmin_value} on cell ${nrcell_id}
    gnbscf.Perform Configuration Parameter Recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${nrcell_id}
    ...    parameter=qRxLevMin    value=${qrxlevmin_value}
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Toggle actExtN77Support flag
    [Arguments]    ${isActive}=false
    [Documentation]     Keywords to activate or deactivate actExtn77Support feature flag for n77 USA band
    ...    :param isActive: value of actExtn77support feature flag. Either false or true.
    Log Action to Console    Set actExtn77Support flag to ${isActive} on primary gNB
    gnbscf.Perform Configuration Parameter Recommissioning   operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    parameter=actExtN77Support    value=${isActive}
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${180}
    Wait until all cells are onair

Toggle actExt2N77Support flag
    [Arguments]    ${isActive}=false
    [Documentation]     Keywords to activate or deactivate actExt2N77Support feature flag for n77 Canadian band
    ...    :param isActive: value of actExt2N77Support feature flag. Either false or true.
    Log Action to Console    Set actExt2n77Support flag to ${isActive} on Primary gNB
    gnbscf.Perform Configuration Parameter Recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    parameter=actExt2N77Support    value=${isActive}
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${180}
    Wait until all cells are onair

Toggle actMfbiNrCaSupportFr1 flag
    [Arguments]    ${isActive}=false
    [Documentation]     Keywords to activate or deactivate actMfbiNrCaSupportFr1 feature flag for MFBI FR1 CA
    ...    :param isActive: value of actMfbiNrCaSupportFr1 feature flag. Either false or true.
    Log Action to Console    Set actMfbiNrCaSupportFr1 flag to ${isActive} on primary gNB
    gnbscf.Perform Configuration Parameter Recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ...    parameter=actMfbiNrCaSupportFr1    value=${isActive}
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${60}

Change PCell
    [Arguments]    ${old_pcell_id}    ${new_pcell_id}
    [Documentation]    Keyword changes qrxlevmin of two cells in way that one cell has qrxlevmin value on level
    ...    unable to attach by UE. The other cell qrxlevel is set to value that allows UE to attach to it.
    ...    :param old_pcell_id: id of nrcell that has a larger qrxlevmin level and is assumed as PCell.
    ...    :param new_pcell_id: id of nrcell that has a lower qrxlevmin level and should be a PCell.
    Log Action to Console    Change PCell on primary gNB
    Set qrxLevMin for 5G cell    ${old_pcell_id}    -25
    Set qrxLevMin for 5G cell    ${new_pcell_id}    -45

Common Test Teardown
    [Documentation]    This keyword clears environment after each test case.
    Log Action to Console    End test
    Run Keyword And Ignore Error    ue.Detach UE    SDX_75
    Log Action To Console    Stop DL and UL data transmission
    Run Keyword And Ignore Error    ue.Stop Data Transfer    dt_name=DT_1_UL
    Run Keyword And Ignore Error    ue.Stop Data Transfer    dt_name=DT_1_DL
    Attenuate all ports
    Common Postconditions With Watching Alarms

Log Action to Console
    [Arguments]    ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]    Logs message to console
    ...                :param msg:     message logged
    ...                :datatime:    determines if include timestamp in log
    ...                :new_line_before:    determines if include new line before log
    ...                :new_line_after:    determines if include new line after log
    Run keyword if    '${new_line_before}'=='${True}'    Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'    dt.Get Current Date
    Run keyword if    '${datatime}'=='${True}'    Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'    Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'    Log To Console    \n    no_newline=${True}

Wait until all cells are onair
    [Arguments]    ${waiting_time}=10min    ${checking_interval}=10s
    [Documentation]    The keyword waits until all cells will be in on air.
    ...                :param waiting_time:    time to wait
    ...                :param checking_interval: time between checking
    Log Action To Console    Wait until all cells are onair
    Wait Until Keyword Succeeds    ${waiting_time}    ${checking_interval}
    ...    gnbcell.Verify All Cells Are On Air

Open Connection And Log In
    [Arguments]    ${host}    ${username}    ${password}
    [Documentation]   Open a ssh connection to given host.
    ...    :param host:  Host to connect with.
    ...    :param username:  Host user login
    ...    :param password:   Host user password
    Log Action To Console    Open ssh connection to ${host} UE PC
    SSHLibrary.Open Connection         host=${host}
    SSHLibrary.Login               username=${username}        password=${password}
