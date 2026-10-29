*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Ganesha
...              :contact: ganesha.u@nokia.com

#Resource     ../resources/5G_SW_WRO_Keywords.robot
#Library      ../resources/Python/webem_alarms.py
#Library      ../CB007262/CB007262_A/CB007262_keywords.py
#Library      ../CB007813/CB007813-B_keywords.py
Resource         ../../resources/robot/PM_Counters.robot
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core
Library      BuiltIn
Library      Collections
Library      ta_pcmd
Library      ta_pcmd.tshark_plugin_configurator
Variables    ta5g_global_var
Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Library      ta5g_tshark
Library      ta5g_commissioning
Library      ta5g_enb
Library      ta5g_file_system
Library      ta5g_cell_operations
Library      ta5g_iphy
Library      ta5g_testline_management
Library      ta5g_setups_and_teardowns
Library      ta5g_egate
Library      ta5g_ue_mobility
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library   taf.sbts.oam.coam.admin
Library    taf.sw.scout    WITH NAME     scout
Resource        ../../resources/robot/configuration_id.robot



*** Keywords ***
Wait For Another PCMD Records
    Sleep    100s

Verify PCMD Trace Records for RI
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
     ...   pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
    log to console  ${relation_symbol}
Verify PCMD Trace Records for RIM-RS
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
     ...   pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
    log to console  ${relation_symbol}
Verify If PCMD Records For RI Are Not Sent
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${alias}=third_tcp_pcap
    Verify Tshark For No Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    log to console  ${pcap_file_path}
Verify IF PCMD Records For RIMRS Are Not Sent
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${alias}=third_tcp_pcap
    Verify Tshark For No Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    log to console  ${pcap_file_path}
Verify PCMD Trace Records for RIM-RS After Cell Reconfiguration
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=second_tcp_pcap    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
     ...   pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
    log to console  ${relation_symbol}
Perform Cell Reconfiguration By Delta Commissioning To Stop Sending PCMD Records
     Find Scfc and Send Delta Commissioning    scfc_filename=actPCMDreport_disabled.json
     Sleep    30s

Verify If PCMD Content Related to actPCMDReporting Flag Is Not Sent To TCE
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${alias}=tcp_pcap
    Verify Tshark For No Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    log to console  ${pcap_file_path}
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
    [Arguments]   ${luashark_path}=/opt/luashark/generated_luashark/luashark.lua
    ...    ${input_file}=${OUTPUT_DIR}/*.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -T pdml > ${OUTPUT_DIR}/PCMD_report.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    5s
    log to console  ${luashark_path}
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
    ...    ELSE    BuiltIn.Log    File '~/.config/wireshark/preferences' contains the required flags for PCMD

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
    ...     \ propagation_delay=16 rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25 factorRsSequence=1 offsetRsSequence=1
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

Verify Counters
    sleep    600s
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}    expected_value=${EXPECTED_PCELL_VALUE1}
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}    expected_value=${EXPECTED_PCELL_VALUE2}
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}    expected_value=${EXPECTED_PCELL_VALUE3}
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=${EXPECTED_SCELL_VALUE1}
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER2}    expected_value=${EXPECTED_SCELL_VALUE2}

Validate PM Counters
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Validate PM Counters bigger than
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Validate PM Counters equal or bigger than
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal or bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Validate PM Counters equal to float number
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value equal to float number    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Validate PM Counters bigger than float number
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than float number   expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

Outdated Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Outdated Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}
    log to console  ${node_id}
Outdated Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}

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


