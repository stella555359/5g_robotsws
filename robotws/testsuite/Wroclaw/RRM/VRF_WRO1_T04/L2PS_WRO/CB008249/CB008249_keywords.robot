*** Settings ***
Documentation
...    copyright: Nokia

Library     taf.collectors.l2stream3     WITH NAME  tcl
Library     taf.collectors.core          WITH NAME  tcc
Library     taf.collectors.core          WITH NAME  core
Library     taf.converters.eventdecoder  WITH NAME  tce
Library     taf.transport.ssh            WITH NAME  ssh
Library     taf.collectors.l1l2bip       WITH NAME  l1l2bip
Library     taf.ul.gnb.bip.collection    WITH NAME  bip_collection
Library     ta_a2a
Library     ta5g_tshark
Library     Collections
Library     Process
Library     OperatingSystem
Library     ta_logcollector

*** Keywords ***
Commmon Test Setup
    [Arguments]    ${iphy_config_file_name}   ${scf_file_name}   ${lua_config_file_name}
    Start Default Logging
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${iphy_config_file_name}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scf_file_name}
    Check Radios Availability
    Reach Onair    lua_cfg=${lua_config_file_name}

Change Base threshold for NR remote interference detection
    Find Scfc and Send Delta Commissioning    scfc_filename=Delta_step_1.json
    Sleep    30s

Change Timer t300
    Find Scfc and Send Delta Commissioning    scfc_filename=Delta_step_2.json
    Sleep    30s

Wait 100s After Delta Recommisioning
    Sleep    100s

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=3 pdu=3 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=4 pdu=4 trf_type=internal

Set SRS Beam Config
    [Arguments]   ${ue_id_1}      ${ue_id_2}
    Execute Egate Command   cmd=ue_srs_beam_pos_nr profile_id=1 init_pos=0 srsMode=fixed
    Execute Egate Command   cmd=ue_testmode_set_nr id=${ue_id_1} testmode=ue_srs_beam_pos action=activate profile_id=1
    Execute Egate Command   cmd=ue_srs_beam_pos_nr profile_id=2 init_pos=2 srsMode=fixed
    Execute Egate Command   cmd=ue_testmode_set_nr id=${ue_id_2} testmode=ue_srs_beam_pos action=activate profile_id=2

Set Up X2 link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s

Attach SA UE And Verify msg2TPC
    [Arguments]   ${ue_id}      ${msg2TPC_value}
    Execute Egate Command    cmd=ue_register id=${ue_id}
    ...    pass_regexp=msg2TPC: ${msg2TPC_value}

Attach Ue To Enb And Start Gnb Addition And Verify TPC msg
    [Arguments]    ${ue_id}    ${target_cells}     ${msg2TPC_value}
    Attach Ue To Enb    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    pass_regexp=msg2TPC: ${msg2TPC_value}

Verify PowerRampingStep Configuration
    [Arguments]   ${filter}
    Verify Uu Messages    packet_filter=${filter}

Verify Uu Messages
    [Documentation]  Verification of messages captured on UU interface (between GnB and UE, WTS eth4).
    ...              By default keyword validates exact one occurrence of message.
    [Arguments]     ${packet_filter}
    Sleep   5s
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=default_uu  packet_filter=${packet_filter}    number_of_messages=1

Airphone override to rank2
    Execute Egate Command    cmd=csi_override_testmode_nr profile_id=1 cqi=15 ri=1
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1
    Execute Egate Command    cmd=ue_testmode_set_nr id=4 testmode=csi_override action=activate profile_id=1

Start Double Data Traffic In DL And Single In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}    ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu} Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=2
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu} Qfi:1 TrfId:2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${pdu} Qfi:1 TrfId:1
    Sleep    60s

Start Data Traffic In DL And In UL
    [Arguments]   ${ue_id}    ${tput_ul}    ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=dl mbps=${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=ul mbps=${tput_ul}
    Sleep    60s

Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Start Gathering BIP Logs And Wait 5s
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
     Sleep    5

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
    Sleep    10s

Check If UL SRS-based BF Is Enabled
    [Arguments]   ${file}=BIP_L1L2.pcap
    verify_if_SRS_is_enabled    pdml_path=${OUTPUT_DIR}/${file}

Check If UL SRS-based BF Is Disabled
    [Arguments]   ${file}=BIP_L1L2.pcap
    verify_if_SRS_is_disabled    pdml_path=${OUTPUT_DIR}/${file}

Generate RI
    [Arguments]   ${noise_power}
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=12 start_symbol_position=0 num_of_symbols=32 noise_power_values=${noise_power}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=12 action=activate

Cancel RI
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=12 action=deactivate

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=2 ue_deregister_type=switch_off
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=3 ue_deregister_type=switch_off
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=4 ue_deregister_type=switch_off

Stop All Data Transfers And Detach UE NSA
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=12
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=13
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=14

Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF
    [Arguments]  ${duration}    ${directory_name}   ${ini_path}
    Collect And Convert TTI Traces      duration=${duration}    directory_name=${directory_name}
    Check DL MU-MIMO And DL SRS-based BF in TTiTrace        directory_name=${directory_name}    ini_path=${ini_path}

Collect And Convert TTI Traces
    [Arguments]  ${duration}    ${directory_name}
    ${parent_directory}  Set variable  ${directory_name}
    Set Test Variable  ${parent_directory}
    Start TTI trace collection
    Log to console    Collecting duration is ${duration}
    Sleep  ${duration}
    Stop TTI trace collection
    Convert TTI trace from pcap  format=excelCsv  directory_name=${directory_name}

Start TTI trace collection
    ${configurations}=  tcc.Load Configurations    ${CURDIR}/config/tti_trace_collectors.yaml
    tcc.Create Collectors    names=l2stream3    configurations=${configurations['collectors']}
    tcl.Set Suite Alias     alias=l2stream3
    tcc.Setup Collectors    names=l2stream3
    tcc.Start Collectors    names=l2stream3
    Log to console    ${\n}TTI traces collecting started

Stop TTI trace collection
    Log to console    Stopping TTI traces collecting
    tcc.Stop Collectors    names=l2stream3
    tcc.Collect Collectors    names=l2stream3
    tcc.Teardown Collectors    names=l2stream3

Convert TTI trace from pcap
    [Arguments]  ${format}  ${directory_name}
    Log to console    Converting TTI traces to ${format}
    tce.Create eventDecoder Converter
    ...  name=ttitrace_converter
    ...  input_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/tcpdump/tcpdump.pcap
    ...  output_file_format=${format}
    ...  output_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/output
    tce.Convert
    ...  name=ttitrace_converter
    Move Directory	${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/  ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}/

Check DL MU-MIMO And DL SRS-based BF in TTiTrace
    [Arguments]  ${directory_name}      ${ini_path}
    check_log_with_au2anlysis    ini_path=${CURDIR}/config/${ini_path}    log_need_to_check=i
    ...    save_log_directory=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${directory_name}

Start gnbMirroring L2L1
    [Documentation]  Upload and start the gnbMirroring.sh script on ASIK. Needs to be stopped.
    ...  ${gnbMirroring_filtering} - on/off or tcpdump filter like: '!(ether[24:2] = 0x0122 || ether[24:2] = 0x0233)' -c 10000
    [Arguments]   ${gnbMirroring_filtering}=off   ${max_file_size_mbytes}=500   ${capturing_time_seconds}='infinite'
    ...           ${syscom_mirroring}=off
    ${filter}=   Assign specific filter to gnbMirroring   filtering=${gnbMirroring_filtering}
    Enable Mirroring In BB Slots    5
    Set global variable    ${gnbMirroring_filtering}   ${filter}
    Upload gnbMirroring Script To ASIL
    ${asik_alias}=    Connect to ASIK
    set test variable  ${p1}   --filtering=${gnbMirroring_filtering} --number_of_files=1 --file_size_mbytes=${max_file_size_mbytes}
    set test variable  ${p2}   --capturing_time_seconds=${capturing_time_seconds}
    set test variable  ${p3}   --syscom_mirroring=${syscom_mirroring}
    ssh.Send Command   command=nohup sh /ffs/run/config/scripts/gnbMirroring.sh ${p1} ${p2} ${p3}   connection=${asik_alias}
    ssh.Read Output Until    Filter    timeout=30    connection=${asik_alias}
    Log to console   Started gnbMirroring.sh!

Stop gnbMirroring And Gather L1L2 Bip Logs
    [Documentation]  Stops the gnbMirroring.sh script and downloads logs from ASIK to a chosen directory.
    [Arguments]   ${filename}=BIP_L1L2.pcap
    ${asik_alias}=           Connect to ASIK
    ssh.Execute         command=killall tcpdump   connection=${asik_alias}
    Sleep  5s
    Log to console      gnbMirroring.sh stopped!
    Wait until keyword succeeds   30s   3s
    ...                           ssh.Assert File Exists    /tmp/tcpdump_L2L1_bip_filtering_${gnbMirroring_filtering}.pcap
    ...                                                     connection=${asik_alias}
    ssh.Download File   local_path=${LOG_PATH}/${filename}
    ...                       remote_path=/tmp/tcpdump_L2L1_bip_filtering_${gnbMirroring_filtering}.pcap
    ...                       connection=${asik_alias}
    ssh.Execute   command=rm /tmp/tcpdump_L2L1*   connection=${asik_alias}
    Restore original gnbMirroring
    [Return]   ${LOG_PATH}/${filename}

Stop gnbMirroring And Gather L1L2 Bip Logs C
     [Arguments]
     ...     ${alias}
     ...     ${dir_path}
     ...     ${delay}
     ...     ${bip_file}
     Sleep  ${delay}
     Create directory  path=${dir_path}/${alias}
     Create directory  path=/tmp/${alias}
     core.stop_collectors    names=tcpdump
     core.collect_collectors    names=tcpdump    target_dir=${OUTPUT_DIR}
     core.teardown_collectors    names=tcpdump
     ${rc}=    Run And Return Rc  mergecap -a ${dir_path}/tcpdump/*mirroring_L2L1*.pcap* -w /tmp/${alias}/tcpdump.pcap
     Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
     Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/${bip_file}
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True
     Sleep    10s

Start gnbMirroring L2L1 ASIM
    [Documentation]     Collect L1L2 BIP Logs using taf.ul.gnb.bip.collection - scripting approach
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param bb_mods:   List of BB modules to start collection from them, default: [ABIO]
    [Arguments]
    ...     ${bb_mods}=[ABIO]

    bip_collection.Configure Bip Collection     l1_type=FS
    ...                                         gNB_common_unit=ASIM
    ...                                         gNB_capacity_units=${bb_mods}
    ...                                         use_script=True
    bip_collection.Start Bip Trace
    Log to console  BIP logs collecting started

Stop gnbMirroring And Gather L1L2 Bip Logs ASIM
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${dir_path}=${OUTPUT_DIR}
    ...     ${delay}=0
    ...     ${filename}=BIP_L1L2.pcap
    Sleep  ${delay}
    Create directory  path=${dir_path}/${alias}
    Create directory  path=/tmp/${alias}
    bip_collection.Stop Bip Trace   target_dir=/tmp/${alias}
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/tcpdump*.pcap* -w /tmp/${alias}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/${filename}
    Remove directory    /tmp/${alias}    recursive=True
    Log to console  BIP logs collecting finished

Upload gnbMirroring Script To ASIL
    [Documentation]   Uploads the gnbMirroring.sh script, which sets up and collects L1L2 logs.
    [Arguments]       ${script_folder}=${EXECDIR}/testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB006991/resources/gnbMirroring/ASIL
    ${asik_alias}=    Connect To ASIK
    ${remote_path}=   Set Variable    /ffs/run/config/scripts
    ssh.Execute       command=mkdir ${remote_path}   connection=${asik_alias}
    ssh.Upload File   local_path=${script_folder}/gnbMirroring.sh
    ...               remote_path=${remote_path}/gnbMirroring.sh
    ...               connection=${asik_alias}
    ssh.Upload File   local_path=${script_folder}/gnbMirroringConfig.sh
    ...               remote_path=${remote_path}/gnbMirroringConfig.sh
    ...               connection=${asik_alias}
    ssh.Execute       command=chmod +x ${remote_path}/gnbMirroring.sh         connection=${asik_alias}
    ssh.Execute       command=chmod +x ${remote_path}/gnbMirroringConfig.sh   connection=${asik_alias}
