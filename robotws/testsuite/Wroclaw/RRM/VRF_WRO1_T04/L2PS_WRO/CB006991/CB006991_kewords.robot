*** Settings ***
Documentation
...    copyright: Nokia

Library    Collections
Library    OperatingSystem
Library    Process
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.collectors.l1l2bip       WITH NAME    l1l2bip
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.l2stream3     WITH NAME    l2stream3
Library    taf.converters.eventdecoder  WITH NAME    eventdecoder
Library    ta_logcollector
Library    taf.ul.gnb.bip.collection    WITH NAME    bip_collection
Resource     testsuite/Wroclaw/RRM/resources/logs.robot

*** Keywords ***
Set Up X2 link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s

Start DL and UL Data Traffic For UE
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=dl mbps=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=ul mbps=1

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg

Check If RimRsSendReq is Present
    verify_rimrssendreq_is_visible    pdml_file=${OUTPUT_DIR}/BIP_log_RIM.pdml

Check If StartRBforRS When Rim-rs is Transmitting is Correctly Set
#    verify_if_starting_RB_for_RIMRS_is_correct    pdml_file=${OUTPUT_DIR}/BIP_log_RIM.pdml
    verify_rimrs_num_and_start_prbs    pdml_path=${OUTPUT_DIR}/BIP_log_RIM.pdml

Check If CSI-RS and RIM-RS are not send on the same slot
    verify_if_rimrs_are_not_on_the_same_slot_and_sfn_than_csirs    pdml_path=${OUTPUT_DIR}/BIP_log_RIM.pdml

Check If RimRsSendReq Is Not Longer Generated
    verify_that_rimrssendreq_does_not_occur    pdml_file=${OUTPUT_DIR}/BIP_log_RIM_disabled.pdml

Stop Data Traffic And Detach 1 UE
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11
    Sleep    5s

Activate RIM-RS transmission By Triggering RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=3 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_FOR_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=3 action=activate

Deactivate RIM-RS transmission
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=3 action=deactivate

Start DL and UL Data Traffic
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=dl kbps=100
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start id=2 ue=${ue_id} dir=ul kbps=100

#Start DL and UL Data Traffic For SA UE
#    [Arguments]    ${ue_id}    ${pdu}
#    Execute Egate Command And Wait For Data
#    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=1
#    Execute Egate Command And Wait For Data
#    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=1
Start Data Traffic In DL And In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}    ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu} Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${pdu} Qfi:1 TrfId:1

Start Low Data Traffic In DL And In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}    ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl kbps=${tput_dl} trf_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul kbps=${tput_ul}

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}
    Set Test Variable    ${tput_bf_RI}    ${avg_tput}

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Wait For 2 RI Monitoring Periods
    Sleep    10m      Wait For 2xRI Monitoring Period

Generate Remote Interference
    [Arguments]    ${ID}    ${RI_PWR}
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=${ID} start_symbol_position=0 num_of_symbols=32 noise_power_values=${RI_PWR}
    Sleep    2s
    Execute Egate Command    cmd=cell_testmode_set_nr gnb=2 cell_id=1 testmode=remote_interference profile_id=${ID} action=activate
    Sleep    10s

Create RI Profiles
    [Arguments]    ${RI_PWR}
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=${ID} start_symbol_position=0 num_of_symbols=32 noise_power_values=${RI_PWR}

Deactivate Remote Interference Testmode
    [Arguments]    ${ID}
    Execute Egate Command    cmd=cell_testmode_set_nr gnb=2 cell_id=1 testmode=remote_interference profile_id=${ID} action=deactivate
    Sleep    10s

Check If RI Alarm Is Not Present
    Verify If Admin Fault Is Down    fault_id=7525

Check If RI Alarm Is Present
    Verify If Admin Fault Is Up    fault_id=7525

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

Activate RIM-RS transmission By Sending Delta Commisioning
     Find Scfc and Send Delta Commissioning    scfc_filename=delta_activate_rimrs.json
     Sleep    30s

Deactivate RIM-RS transmission by Sending Delta Commisioning
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_deactivate_rimrs.json
    Sleep    30s

Stop All Data Transfers And Detach NSA UEs
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Execute Egate Command    cmd=trf_data_stop id=2 ue=12
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11
    Execute Egate Command    cmd=ue_detach id=12
    Sleep    5s

#Stop gnbMirroring And Gather L1L2 logs for Disabled RIMRS
#    [Documentation]  Stops the gnbMirroring.sh script and downloads logs from ASIK to a chosen directory.
#    [Arguments]   ${target_directory}=L1L2    ${filename}=BIP_L1L2_disabled.pcap
#    ${asik_alias}=           Connect to ASIK
#    ssh.Execute         command=killall tcpdump   connection=${asik_alias}
#    Sleep  5s
#    Log to console      gnbMirroring.sh stopped!
#    Wait until keyword succeeds   30s   3s
#    ...                           ssh.Assert File Exists    /tmp/tcpdump_L2L1_bip_filtering_${gnbMirroring_filtering}.pcap
#    ...                                                     connection=${asik_alias}
#    ssh.Download File   local_path=${LOG_PATH}/${filename}
#    ...                       remote_path=/tmp/tcpdump_L2L1_bip_filtering_${gnbMirroring_filtering}.pcap
#    ...                       connection=${asik_alias}
#    ssh.Execute   command=rm /tmp/tcpdump_L2L1*   connection=${asik_alias}
#    Restore original gnbMirroring
#    [Return]   ${LOG_PATH}/${filename}

#Convert pcap file to pdml Disabled RIMRS
#    [Documentation]     Using luashark converting BIP log from pcap to pdml.
#    [Arguments]   ${luashark_path}=/opt/luashark/generated_luashark/luashark.lua
#    ...    ${input_file}=${OUTPUT_DIR}/BIP_L1L2_disabled.pcap
#    Log to console    Converting pcap to pdml
#        ${tshark_cmd} =   Catenate    tshark
#    ...    -r ${input_file}
#    ...    -Y dldata_rimrssendreq
#    ...    -T pdml > ${OUTPUT_DIR}/BIP_log_RIM_disabled.pdml
#    Run    ${tshark_cmd}
#    Log to console    Pcap->Pdml conversion done...
#    Sleep    5s

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal

Stop Data Traffic And Detach 1 SA UE
    Execute Egate Command   cmd=trf_data_stop ue=1 pdu=1
    Execute Egate Command   cmd=ue_deregister id=1 ue_deregister_type=switch_off

Start Gathering BIP Logs When RIM-RS is Enabled ASIM
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
    Sleep  ${delay}
    Create directory  path=${dir_path}/${alias}
    Create directory  path=/tmp/${alias}
    bip_collection.Stop Bip Trace   target_dir=/tmp/${alias}
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/tcpdump*.pcap* -w /tmp/${alias}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2.pcap
    Remove directory    /tmp/${alias}    recursive=True
    Log to console  BIP logs collecting finished

Start Gathering BIP Logs When RIM-RS is Disabled ASIM
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


Stop gnbMirroring And Gather L1L2 logs for Disabled RIMRS ASIM
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${dir_path}=${OUTPUT_DIR}
    ...     ${delay}=0
    Sleep  ${delay}
    Create directory  path=${dir_path}/${alias}
    Create directory  path=/tmp/${alias}
    bip_collection.Stop Bip Trace   target_dir=/tmp/${alias}
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/tcpdump*.pcap* -w /tmp/${alias}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2_disabled.pcap
    Remove directory    /tmp/${alias}    recursive=True
    Log to console  BIP logs collecting finished


Start Gathering BIP Logs When RIM-RS is Enabled
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
     Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2.pcap
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True

Convert pcap file to pdml
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]   ${input_file}=${OUTPUT_DIR}/BIP_L1L2.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y "dldata_rimrssendreq||dldata_csirssendreql1sw"
    ...    -T pdml > ${OUTPUT_DIR}/BIP_log_RIM.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    5s

Start Gathering BIP Logs When RIM-RS is Disabled
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
     ...  timeout=300
     ...  remove_zip_file=False
     core.setup_collectors    names=tcpdump
     core.start_collectors    names=tcpdump
     core.Set Suite Alias     ${target_file_name}

Stop gnbMirroring And Gather L1L2 logs for Disabled RIMRS
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
     Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2_disabled.pcap

Convert pcap file to pdml Disabled RIMRS
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]   ${input_file}=${OUTPUT_DIR}/BIP_L1L2_disabled.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y dldata_rimrssendreq
    ...    -T pdml > ${OUTPUT_DIR}/BIP_log_RIM_disabled.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    5s
