*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Library    taf.transport.ssh         WITH NAME    ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core       WITH NAME    core
Library      ta_pcmd
Library      ta_pcmd.tshark_plugin_configurator

*** Keywords ***
Verify RIM-RS Slot With 4 Repetitions
    ${slot_rimrssendreq}    Get Rimrs Slot    pdml_path=${OUTPUT_DIR}/BIP_L1L2.pdml
    Should Be True    ${slot_rimrssendreq} == [3,8,12,17]

Verify RIM-RS Is Detected In First UL Slot
    ${slot}    ${symbol_index}     Get Slot And Symbol Index    pdml_path=${OUTPUT_DIR}/BIP_L1L2.pdml
    Should Be Equal    ${slot}    ${4}
    Should Contain     ${symbol_index}    ${12}

Wait For Updated Fault 7527 Without Dl Mittigation
    Wait For Fault To Be Up     fault_id=7527   timeout=1200

Convert pcap file to pdml
    [Arguments]   ${input_file}=${OUTPUT_DIR}/BIP_L1L2.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y '(dldata_rimrssendreq) || (3gpp.slot == 4 && UlData_detectionResUnitsResp_t.symbolIndex == 12)'
    ...    -T pdml > ${OUTPUT_DIR}/BIP_L1L2.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    5s

Start Gathering BIP Logs
    [Arguments]    ${target_file_name}=tcpdump
     ${webservice}=  Create Dictionary
     ...  host=192.168.255.129
     ...  user=Nemuadmin
     ...  password=nemuuser
     ...  port=443

     create_interface_mirroring_l1l2bip_collector
     ...  name=tcpdump
     ...  webservice=${webservice}
     ...  target_file_name=tcpdump
     ...  timeout=1300
     ...  remove_zip_file=False
     core.setup_collectors    names=tcpdump
     core.start_collectors    names=tcpdump
     core.Set Suite Alias     ${target_file_name}
     Sleep    310

Stop gnbMirroring And Gather L1L2 Bip Logs
     [Arguments]
     ...     ${alias}=L1L2_BIP_Logs
     ...     ${dir_path}=${OUTPUT_DIR}
     ...     ${delay}=0
     Sleep  ${delay}
     Create directory  path=${dir_path}/${alias}
     Create directory  path=/tmp/${alias}
     core.stop_collectors    names=tcpdump
     core.collect_collectors    names=tcpdump    target_dir=${OUTPUT_DIR}
     core.teardown_collectors    names=tcpdump
     ${rc}=    Run And Return Rc  mergecap -a ${dir_path}/tcpdump/*mirroring_L2L1*.pcap* -w /tmp/${alias}/tcpdump.pcap
     Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
     OperatingSystem.Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2.pcap
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True
     Sleep    10s

Start Data Traffic In DL and UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}      ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl}

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Generate RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate
Generate RIMRS
    ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=3 config_mode=standalone aggressor_cell=1 victim_cell=3 rsSetId=22222
    ...     \ propagation_delay=17 rsNearFarConfig=1
    ...     \ rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25 factorRsSequence=0 offsetRsSequence=0
    ...     \ startRbForRs=1,50,100,150 rimRsTxPower=-330 repetitionRsType1=4 rsPattern2Period=25
    Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=activate

Setup X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

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
