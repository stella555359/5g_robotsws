*** Settings ***

Documentation
...    copyright: Nokia

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library      ../CB007813/CB007813-B_keywords.py
Library      taf.transport.ssh  WITH NAME  ssh
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library      taf.collectors.core    WITH NAME    core
Library      ta5g_tshark
Library      BuiltIn
Library      Collections
Library      ta_pcmd
Library      ta_pcmd.tshark_plugin_configurator


*** Keywords ***
Verify If RS1 Is Properly Transmitted
    ${slot_rimrssendreq}    ${nsc_id_rimrssendreq}    get_rimrs_slot_and_nsc_id    pdml_path=${OUTPUT_DIR}/BIP_log_1.pdml
    Should Be True    ${slot_rimrssendreq} == [7]
    Should Be True    ${nsc_id_rimrssendreq} == [1]

Verify If RS2 Is Properly Transmitted
    ${slot_rimrssendreq}    ${nsc_id_rimrssendreq}    get_rimrs_slot_and_nsc_id    pdml_path=${OUTPUT_DIR}/BIP_log_2.pdml
    Should Be True    ${slot_rimrssendreq} == [7]
    Should Be True    ${nsc_id_rimrssendreq} == [9]
Activate RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Deactive Ri
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=deactivate
Activate RIMRS
   ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=3 config_mode=standalone aggressor_cell=1 rsSetId=12345 numRsSetId=1 rimRsType=rsType1
    ...     \ propagation_delay=16 rsType1NScId=1,2 rsType2NScId=9,8 rsPattern1Period=50 rsPattern2Period=25
    ...     \ repetitionRsType1=1 repetitionRsType2=1 rim_framework=framework_1 factorRsSequence=1 factorRsSequenceRS2=0 offsetRsSequence=1
    ...     \ offsetRsSequenceRS2=0 startRbForRs=20 numRsType1SetId=65536 numRsType2SetId=65536
    Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=activate

Deactive RIMRS
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=deactivate

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
     Sleep    400

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
     Sleep    300
Stop gnbMirroring And Gather L1L2 Bip Logs2
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
     OperatingSystem.Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2_2.pcap
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True
     Sleep    10s
Convert pcap file to pdml
    [Arguments]
    ...    ${input_file}=${OUTPUT_DIR}/BIP_L1L2.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y "DlData_RimRsSendReq_t.nscID == 1"
    ...    -T pdml > ${OUTPUT_DIR}/BIP_log_1.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    300s

Convert Second pcap file to pdml
    [Arguments]
    ...    ${input_file}=${OUTPUT_DIR}/BIP_L1L2_2.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y "DlData_RimRsSendReq_t.nscID == 9"
    ...    -T pdml > ${OUTPUT_DIR}/BIP_log_2.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    300s
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

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
