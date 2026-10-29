*** Settings ***
Documentation
...    copyright: Nokia

Library      taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library      taf.collectors.core    WITH NAME    core
Library      ta_pcmd
Library      ta_pcmd.tshark_plugin_configurator
Library      ta5g_pm_counters
Library      ta5g_tshark
Library      BuiltIn
Library      Collections

*** Variables ***
${NOISE_POWER_FOR_RI_1116}=     SEPARATOR=
...                             -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                             -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

*** Keywords ***
Commmon Test Setup
    [Arguments]    ${iphy_config_file_name}   ${scf_file_name}   ${lua_config_file_name}
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${iphy_config_file_name}
    Configure PCMD in Wireshark
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scf_file_name}
    Check Radios Availability
    Reach Onair    lua_cfg=${lua_config_file_name}

Verify If RS1 Is Properly Transmitted
    ${slot_rimrssendreq}    ${nsc_id_rimrssendreq}    get_rimrs_slot_and_nsc_id    pdml_path=${OUTPUT_DIR}/BIP_log_1.pdml
    Should Be True    ${slot_rimrssendreq} == [3]
    Should Be True    ${nsc_id_rimrssendreq} == [1]

Verify If RS2 Is Properly Transmitted
    ${slot_rimrssendreq}    ${nsc_id_rimrssendreq}    get_rimrs_slot_and_nsc_id    pdml_path=${OUTPUT_DIR}/BIP_log_2.pdml
    Should Be True    ${slot_rimrssendreq} == [3]
    Should Be True    ${nsc_id_rimrssendreq} == [3]

Verify If RS1 And RS2 Are Properly Transmitted
    ${slot_rimrssendreq}    ${nsc_ids_for_rimrssendreq}    get_slot_and_nsc_id_for_rs1_and_rs2    pdml_path=${OUTPUT_DIR}/BIP_log_1.pdml
    Should Be True    ${slot_rimrssendreq} == [3, 3]
    Should Be True    ${nsc_ids_for_rimrssendreq} == [1, 1]

Verify If RS1 And RS2 Are Not Transmitted
    verify_if_rimrssendreq_does_not_occur    pdml_file=${OUTPUT_DIR}/BIP_log_2.pdml

Change RIM-RS Transmission From Constantly Trigger To RI Trigger
    Find Scfc and Send Delta Commissioning    scfc_filename=RS_trans_trigger_to_RI.json
    Sleep    30s

Verify If RS1 Is Properly Transmitted for FS1208
    ${slot_rimrssendreq}    ${nsc_id_rimrssendreq}    get_rimrs_slot_and_nsc_id    pdml_path=${OUTPUT_DIR}/BIP_logRS1.pdml
    Should Be True    ${slot_rimrssendreq} == [3]
    Should Be True    ${nsc_id_rimrssendreq} == [1]

Verify If RS2 Is Properly Transmitted for FS1208
    ${slot_rimrssendreq}    ${nsc_id_rimrssendreq}    get_rimrs_slot_and_nsc_id    pdml_path=${OUTPUT_DIR}/BIP_logRS2.pdml
    Should Be True    ${slot_rimrssendreq} == [3]
    Should Be True    ${nsc_id_rimrssendreq} == [9]

Check If RimRsSendReq Is Not Longer Generated
    verify_if_rimrssendreq_does_not_occur    pdml_file=${OUTPUT_DIR}/BIP_log_RIM_disabled.pdml

Wait 100s After Delta Recommisioning
    Sleep    100s

Deactivate RIM-RS transmission by Sending Delta Commisioning
     Find Scfc and Send Delta Commissioning    scfc_filename=RI_Tigger.json
     Sleep    100s

Wait For Next Pm Interval
    Sleep    300s

Verify PM Counters For RIMRS
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00001
    ...    value=12
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00002
    ...    value=300
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00009
    ...    value=${-74}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00010
    ...    value=${-74}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00011
    ...    value=${-74}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00012
    ...    value=${-74}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00013
    ...    value=${-74}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}

Verify If Pm Counters Are Not Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00001
    ...    value=0
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55194C00002
    ...    value=0
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${PM_COUNTERS_FILE}

Start Data Traffic In DL and UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}      ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl}

Setup X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment

Generate RI For 1116 FS
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_FOR_RI_1116}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Stop Generate RI
     Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=deactivate

Generate RIMRS
    ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=5 config_mode=standalone victim_cell=1 aggressor_cell=1 rsSetId=12345 rimRsType=rsType1
    ...     \ propagation_delay=16 rsType1NScId=1,2 rsType2NScId=3,4 rsPattern1Period=50
    ...     \ repetitionRsType1=1 repetitionRsType2=1 rim_framework=framework_1 factorRsSequence=1 factorRsSequenceRS2=1 offsetRsSequence=1
    ...     \ offsetRsSequenceRS2=1 startRbForRs=20,70 numRsType1SetId=131072 numRsType2SetId=131072
    Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=5 action=activate

Start Gathering BIP Logs And Wait 200s
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
     Sleep    200

Convert pcap file to pdml
    [Arguments]   ${input_file}
    ...           ${filter}
    ...           ${dir_path}
    Log to console    Converting pcap to pdml
    ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y ${filter}
    ...    -T pdml > ${dir_path}
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    150s

Stop gnbMirroring And Gather L1L2 Bip Logs
     [Arguments]    ${alias}  ${input_file}
     Create directory  path=${OUTPUT_DIR}/${alias}
     Create directory  path=/tmp/${alias}
     core.stop_collectors    names=tcpdump
     core.collect_collectors    names=tcpdump    target_dir=${OUTPUT_DIR}
     core.teardown_collectors    names=tcpdump
     ${rc}=    Run And Return Rc  mergecap -a ${OUTPUT_DIR}/tcpdump/*mirroring_L2L1*.pcap* -w /tmp/${alias}/tcpdump.pcap
     Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
     OperatingSystem.Copy File    /tmp/${alias}/tcpdump.pcap    ${input_file}
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True
     Sleep    10s

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

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start Data Traffic In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
