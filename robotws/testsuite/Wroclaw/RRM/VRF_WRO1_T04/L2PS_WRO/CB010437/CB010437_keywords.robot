*** Settings ***
Documentation
...    copyright: Nokia

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library      ../CB007813/CB007813-B_keywords.py
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core
Library      ta5g_tshark
Library      BuiltIn
Library      Collections
Library      ta_pcmd
Library      ta_pcmd.tshark_plugin_configurator

*** Keywords ***
Wait For Another PCMD Records
    Sleep    100s

Verify PCMD Trace Records for RI
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
     ...   pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify PCMD Trace Records for RIM-RS
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
     ...   pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify If PCMD Records For RI Are Not Sent
    [Arguments]    ${packet_filter}    ${alias}=third_tcp_pcap
    Verify Tshark For No Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}

Verify IF PCMD Records For RIMRS Are Not Sent
    [Arguments]    ${packet_filter}    ${alias}=third_tcp_pcap
    Verify Tshark For No Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}

Verify PCMD Trace Records for RIM-RS After Cell Reconfiguration
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=second_tcp_pcap    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
     ...   pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Perform Cell Reconfiguration By Delta Commissioning To Stop Sending PCMD Records
     Find Scfc and Send Delta Commissioning    scfc_filename=actPCMDreport_disabled.json
     Sleep    30s

Verify If PCMD Content Related to actPCMDReporting Flag Is Not Sent To TCE
    [Arguments]    ${packet_filter}    ${alias}=tcp_pcap
    Verify Tshark For No Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}

Start Second Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp_second.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}/tshark
    ...    alias=second_tcp_pcap

Start Third Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp_third.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}/tshark
    ...    alias=third_tcp_pcap

Stop Second Tcp Pcap
    [Arguments]    ${alias}=second_tcp_pcap
    Stop tshark    alias=${alias}

Stop Third Tcp Pcap
    [Arguments]    ${alias}=third_tcp_pcap
    Stop tshark    alias=${alias}

Verify If All PCMD Records For RI and RIMRS Exist
    verify_pcmd_records_presence_for_ri      pdml_file=${OUTPUT_DIR}/PCMD_report.pdml
    verify_pcmd_records_presence_for_rim_rs      pdml_file=${OUTPUT_DIR}/PCMD_report.pdml

Convert pcap file to pdml
    [Documentation]     Using luashark converting log from pcap to pdml.
    [Arguments]   ${input_file}=${OUTPUT_DIR}/*.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -T pdml > ${OUTPUT_DIR}/PCMD_report.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    5s

Start PCMD
    Configure PCMD    technology=5G    asn1per_decoding=${True}
    Start collecting PCMD reports

Start Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}/tshark
    ...    alias=tcp_pcap

Stop Tcp Pcap
    [Arguments]    ${alias}=tcp_pcap
    Stop tshark    alias=${alias}

Stop And Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD

Configure PCMD in Wireshark
    Add Preferences To Wireshark Config
    Start Server Interface

Add Nestapx Prototcol Plugin To Tshark
    Load Tshark Bin Plugin    technology=5G

Add Preferences To Wireshark Config
    ${preferences_exist}    Check If Preferences Exist
    ${command}=  catenate  SEPARATOR=
    ...    echo "ntrstr.port: 49151,49392" >> ~/.config/wireshark/preferences  &&
    ...    echo "ntrstr.defragment: TRUE" >> ~/.config/wireshark/preferences
    Run Keyword If    ${preferences_exist}==False
    ...    Run    ${command}
    ...    ELSE    Log    File '~/.config/wireshark/preferences' contains the required flags for PCMD

Check If Preferences Exist
    ${preferences_file}    Set Variable    ~/.config/wireshark/preferences
    ${file_exist}=    Run Keyword And Return Status
        ...    File Should Exist    ${preferences_file}
    Run Keyword If   ${file_exist}==False    Create File    ${preferences_file}
    ${file_content}=  OperatingSystem.Get File   ${preferences_file}
    ${preferences_exist}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${file_content}    ntrstr.port: 49151,49392
    [Return]    ${preferences_exist}

Start Server Interface
    [Documentation]    Starts interface between gNB and Trace Control Entity
    Start Vm Ethernet Interface    if_name=eth3:SERVER    ip_with_mask=10.0.1.1/24

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal

Start Data Traffic In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}

Activate RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Generate RI For 1116 FS
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_FOR_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Setup X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment

Activate RIMRS
    ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=3 config_mode=standalone aggressor_cell=1 victim_cell=3 rsSetId=12346
    ...     \ propagation_delay=16 rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25 factorRsSequence=0 offsetRsSequence=0
    ...     \ startRbForRs=1,50,100,150 rimRsTxPower=-330 repetitionRsType1=1 rsPattern2Period=25
    Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=activate

Generate RIMRS
    ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=3 config_mode=standalone aggressor_cell=1 rsSetId=12346 numRsSetId=1
    ...     \ enable_auto_propagation_delay=on rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=50 factorRsSequence=0 offsetRsSequence=0
    ...     \ startRbForRs=1,50,100,150 rimRsTxPower=-330 repetitionRsType1=1 rsPattern2Period=25 numRsType1SetId=524288
    Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=activate

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Change RIMRS profile
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=deactivate
    Sleep     100s
    ${rim_rs_profile7}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=7 config_mode=standalone aggressor_cell=1 victim_cell=3 rsSetId=12346
    ...     \ propagation_delay=16 rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25 factorRsSequence=0 offsetRsSequence=0
    ...     \ startRbForRs=1,50,100,150 rimRsTxPower=-330 repetitionRsType1=2 rsPattern2Period=25
    Execute Egate Command     cmd=${rim_rs_profile7}
    Sleep    5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=7 action=activate

Perform Cell Reconfiguration By Delta Commissioning
     Find Scfc and Send Delta Commissioning    scfc_filename=change_repetitionrstype.json
     Sleep    30s

Perform Delta Commisioning To Disable ActNRrim
     Find Scfc and Send Delta Commissioning    scfc_filename=actnrrim_disabled.json
     Sleep    30s

Start First Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}
    ...    alias=tcp_pcap

Start Netcat for tracing
    Log to console    Netcat started
    Run     sudo pkill -9 -f 'nc -l ${port_trace} -k'
    ${NC_PROC}=    Start Process  nc  -l  ${port_trace}  -k  stdout=/dev/null  stderr=/dev/null
    Sleep    5
    Run    ps -ef | grep nc
    Set Test Variable    ${NC_PROC}

Stop Netact for tracing
    Log to console    Netcat stopped
    Terminate Process  ${NC_PROC}
