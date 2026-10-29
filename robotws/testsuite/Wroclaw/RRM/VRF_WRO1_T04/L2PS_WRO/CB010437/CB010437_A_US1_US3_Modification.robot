*** Settings ***
Documentation    :copyright: Nokia

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Library      ta_pcmd
Library      ta_pcmd.tshark_plugin_configurator
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/configuration_id.robot

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CRT    SBTS00    RAN_5G    RAN_5G_TDD

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/CB006991_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB010437.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/RIMRS_from_gNB_basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${port_trace}               49151
${ip_trace}                 10.0.1.10

@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x580582 = 3
...                         0x58057b = 8

${folder_path}=     /home/ute/test_logs/

${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
${RIMRS_SLOPE_MEASUREMENTS}   SEPARATOR=
...      (((nsetapx.rimRsMonitoringRecord == 1) && (nsetapx.rimRsSetId == 12346)) &&
...      (nsetapx.propagationDelayInSymbol == 15)) && (nsetapx.repetitionIndex == 1)

${RI_SLOPE_MEASUREMENTS}   SEPARATOR=
...      ((((nsetapx.riSlopeMeasRecord == 0) && (nsetapx.recordCollectionDuration == 60000)) &&
...      (nsetapx.slotNumber == 7)) && (nsetapx.symbolNumber == 12) && (nsetapx.numOfDropHeightSamples))

${NO_CONTENT_FOR_PCMDREPORTING}=      (nsetapx.dlRbRlcMeasRecord  == 0) && (nsetapx.ulRbRlcMeasRecord == 0)

*** Test Cases ***
CB010437-A_US1_US3_Activation_PCMD_trace_content_and_deactivation_via_actPCMDReport_flag_RI_slope_and_RIM-RS_records_actNrRim_Modyfication_NSA
    [Tags]    AP_REG
    [Setup]    Run Keywords   Start Netcat for tracing
    ...    AND     Setup X2 Link
    ...    AND     Start Tcp Pcap
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Start DL and UL Data Traffic    ue_id=11
    Activate RI
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Activate RIM RS
    Wait For Fault To Be Up     fault_id=7527   timeout=900
    Verify PCMD Trace Records for RI     ${RI_SLOPE_MEASUREMENTS}
    Verify PCMD Trace Records for RIMRS      ${RIMRS_SLOPE_MEASUREMENTS}
    Verify If PCMD Content Related to actPCMDReporting Flag Is Not Sent To TCE      packet_filter=${NO_CONTENT_FOR_PCMDREPORTING}
    Stop Tcp Pcap
    Stop Netcat for tracing
    Recofniguration RI by Sending Delta Commissioning to Detection and Mitigation state
    Start Tcp Pcap for RI Detection
    Start PCMD
    Wait For PCMD Records
    Verify PCMD Trace Records for RI Detection      ${RI_SLOPE_MEASUREMENTS}
    Verify If PCMD Content Related to actPCMDReporting Flag Is Not Sent To TCE for RI      packet_filter=${NO_CONTENT_FOR_PCMDREPORTING}
    Stop Tcp Pcap for RI Detection
    Stop And Teardown PCMD
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE
    ...    AND    Send Configuration ID To Scout


*** Keywords ***
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

Stop Netcat for tracing
    Log to console    Netcat stopped
    Terminate Process  ${NC_PROC}

Wait For PCMD Records
    Sleep    100s

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

Start Tcp Pcap for RI Detection
    Start tshark
    ...    log_filename=eth3_second_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}/tshark
    ...    alias=second_tcp_pcap

Stop Tcp Pcap
    [Arguments]    ${alias}=tcp_pcap
    Stop tshark    alias=${alias}

Stop Tcp Pcap for RI Detection
    [Arguments]    ${alias}=second_tcp_pcap
    Stop tshark    alias=${alias}

Stop And Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD

Configure PCMD in Wireshark
#    Add Nestapx Prototcol Plugin To Tshark
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
Verify PCMD Trace Records for RI
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap   ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify PCMD Trace Records for RIMRS
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap   ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify PCMD Trace Records for RI Detection
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=second_tcp_pcap   ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify If PCMD Content Related to actPCMDReporting Flag Is Not Sent To TCE
    [Arguments]    ${packet_filter}    ${alias}=tcp_pcap
    Verify Tshark For No Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}

Verify If PCMD Content Related to actPCMDReporting Flag Is Not Sent To TCE for RI
    [Arguments]    ${packet_filter}    ${alias}=second_tcp_pcap
    Verify Tshark For No Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal

Start Data Traffic In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul kbps=${tput_ul}

Activate RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Activate RIM RS
    ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=7 config_mode=standalone aggressor_cell=1 victim_cell=3 rsSetId=12346
    ...     \ propagation_delay=16 rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25 factorRsSequence=0 offsetRsSequence=0
    ...     \ startRbForRs=1,50,100,150 rimRsTxPower=-330 repetitionRsType1=1 rsPattern2Period=25
    Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=7 action=activate

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Recofniguration RI by Sending Delta Commissioning to Detection and Mitigation state
     Find Scfc and Send Delta Commissioning    scfc_filename=actNrRim_DetectionMitigation.json
     Sleep    30s
Disable PCMD Trace Record by Sending Delta Commissioning
     Find Scfc and Send Delta Commissioning    scfc_filename=disable_actPCMDreport.json
     Sleep    30s

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
Start DL and UL Data Traffic
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=dl kbps=10
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=ul kbps=10
