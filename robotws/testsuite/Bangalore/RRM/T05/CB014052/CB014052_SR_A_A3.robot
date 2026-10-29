*** Settings ***
Documentation     *CB014052-SR-A-A3*
...               [Author] "Punya"

Force Tags        CLOUD_R4BANO_CUS   CRT     SBTS00   RAN_4G_TDD     RAN_4G

Library           OperatingSystem
Library           ute_wtssim
Library           ta_uexgate
Library           ta5g_pm_counters
Library           taf.sw.syslog
Library           taf.ul.ue.sim.env_setup
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.ttitrace_4g    WITH NAME    ttitrace
Library           taf.converters.ttitracer    WITH NAME    converter
Library           ute_fsmaccess
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.collectors.tcpdump   WITH NAME   tcpdump
Library           taf.sbts.oam.coam.admin
Library           taf.sbts.oam.coam.admin  WITH NAME    coam
Library           String
Library           ta_messaging
Library           taf.sw.dcap.rd    WITH NAME    rd
Library             Collections
Library             taf.ccs.aashell      WITH NAME      cli
Library             taf.sw.dcap.rd       WITH NAME     dcap
Library             taf.sbts.oam.coam.admin    WITH NAME     admin
Library             taf.collectors.dcap
Library             taf.collectors.tshark
Library             ta5g_tshark
Library             ute_tshark
Resource            ${CURDIR}/Resource/tsharkPcapVerifyKeywords.robot
Library     		ta_emss
Library     		taf.ul.alarms_watchdog
Resource    		./Resource/CB014052_keywords.robot
Resource            ../resources/Keywords/configuration_id.robot

*** Variables ***
${cus_yaml_TC1}                  ${CURDIR}/config/coco.yaml
${scfc_TC1}                     ${CURDIR}/config/FEATURE_en.xml
${cus_yaml_TC2}                  ${CURDIR}/config/Bsplit.yaml
${scfc_TC2}                     ${CURDIR}/config/Bsplit.xml
${cus_yaml_TC3}                  ${CURDIR}/config/YAML/cus_BANO.yaml
${scfc_TC3}                     ${CURDIR}/config/SCFC/Configuration_scf_MRBTS-1_IAV-WRO-CLOUD281_20260102-1551.xml
#${scfc_TC3_D}, ${cus_yaml_TC3_D} & ${A4_LB_HO} Added For D
${scfc_TC3_D}                   ${CURDIR}/config/SCFC/Configuration_scf_MRBTS-1_IAV-WRO-CLOUD281_20251119-1730.xml
${cus_yaml_TC3_D}               ${CURDIR}/config/YAML/cus_BANO_3.yaml
${A4_LB_HO}    (lte-rrc.carrierFreq == 40334) && (lte-rrc.reportConfigId == 4)
${dcaphost}=    10.42.189.42
${COLLECT_TRAFFIC_TIMER}    15
${CELL_ID_1}      1
${UE_EUTRA_CAPABILITIES}    CA1FF41032C10381DF834620000A0068100039400030
${UE_INDEX_1}     1
${UE_INDEX_2}     2
${CA_CAPABLE_UE}    1
${tl.gnbs[0].cu.oam_http_connection_details.username}=      Nemuadmin
${tl.gnbs[0].cu.oam_http_connection_details.password}=      nemuuser
${Log_Path}=         /home/ute/logs
${pcap_file_path}    /home/ute/logs
${msg_names}    lte-rrc.eventId == 4
${UL_HO_eA5_meas_act}    lte-rrc.measId == 3    &&    lte-rrc.measObjectId == 2    &&    lte-rrc.reportConfigId == 4
${UL_HO_eA5_meas_deact}    lte-rrc.MeasId == 3
${A3_HO}        lte-rrc.targetPhysCellId == 7    &&    lte-rrc.targetPhysCellId == 7
${eA5_UL_HO}    x2ap.radioNetwork == 2
${stepwise_increase}           stepwise_increase
${stepwise_decrease}           stepwise_decrease
${UL_eA5_measurements}            UL_eA5_measurements
${UL_eA5_HO}            UL_eA5_HO
${ULHO_measurements}           ULHO_measurements
${path}   ${OUTPUTDIR}
@{swconfig_flags_list}=    0x10041=5    0x10040=1   0x1003F=1   0x130020=1  0x130021=1  0x13001e=1  0x13001f=1  0x120004=1  0x120005=1  0x120006=1

*** Test Cases ***
CB014052_SR_A_IWK1_Interaction_with_A2_event_for_coverage_based_mobility
     Suite Setup   ${cus_yaml_TC3}   ${scfc_TC3}
     Sleep  30s
     configuration_id.Link SCOUT SCF to Configuration ID for Reporting
     Start Syslog_Sub_Case_1
#     Start DCAP Basic Controller
#     Collect C-plane Traces
     Start pcap collection in eth4      name=UL_eA5_measurements
     Log to Console    \n Detach all UEs
     Run Uex Command   ue_detach   all
     Log to Console    \n Attach UE to CB014052 enabled TDD cell
     Run UEx Command   ue_attach  id=57   cell=2
     Run Uex Command   get_ue_meas_config id=57
     Log to Console    \n Trigger UL non-GBR data on TDD source cell \n
     Run UEx Command   trf_data_start   ue=57  dir=ul   protocol=udp   Mbps=150    duration=40    duration_unit=seconds
     Run Uex Command   ue_measurement_send    id=57    event=A2    srsrp=20    srsrq=10
     Run Uex Command   ue_measurement_send    id=57    event=A3    phycell_id=7    nrsrp=97    nrsrq=34
     Sleep    10s
     Run Uex Command   ue_detach   all
     Sleep    10s
     ${pcap_file_path}     Stop pcap collection in eNB 14052   ${UL_eA5_measurements}    ${Log_Path}
     Msg Should Be Present In PCAP    ${pcap_file_path}    ${UL_HO_eA5_meas_act}     RRCConnectionReconfiguration
     Log to Console    \n eA5 measurements activated due to UL buffer overflow
     Msg Should Be Present In PCAP    ${pcap_file_path}    ${UL_HO_eA5_meas_deact}     RRCConnectionReconfiguration
     Log to Console    \n ea5 measurements dectivated due to A2 measurement report during ongoing eA5
#     Collect Snapshot    ${path}    Snapshot_1
#     Start Syslog_Sub_Case_2
#     Start DCAP Basic Controller
#     Collect C-plane Traces
     Start pcap collection in eth4      name=UL_eA5_measurements
     Start pcap collection in eth3      name=UL_eA5_HO
     Log to Console    \n Detach all UEs
     Run Uex Command   ue_detach   all
     Log to Console    \n Attach UE to CB014052 enabled TDD cell
     Run UEx Command   ue_attach  id=57   cell=2
     Run Uex Command   get_ue_meas_config id=57
     Log to Console    \n Trigger UL non-GBR data on TDD source cell \n
     Run UEx Command   trf_data_start   ue=57  dir=ul   protocol=udp   Mbps=150    duration=40    duration_unit=seconds
     Sleep    1s
     Log to Console    \n Send eA5 measurement report of preferred FDD cell \n
     Run Uex Command   ue_measurement_send    id=57    event=A5    phycell_id=7    nrsrp=97    nrsrq=34
     Log to Console    \n A2 event reported during UL HO handover preparation \n
     Run Uex Command   ue_measurement_send    id=57    event=A2    srsrp=20    srsrq=10
#     Sleep    10s
     Wait For Next Full Pm Interval
     ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
     Verify Last Counters In File
     ...     M8021C65   1     IEF_UL_VOL_HO_PREP
     ...     M8021C66   1     IEF_UL_VOL_HO_EXE_ATT
     ...     M8021C67   1     IEF_UL_VOL_HO_EXE_SUCC
     ...     M8021C68   0     IEF_UL_VOL_HO_F_TMR
     ...     local_moid=PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-2
     ...     file_path=${pm_counter_file}
     Run Uex Command   ue_detach   all
     Sleep    10s
     ${pcap_file_path}     Stop pcap collection in eNB 14052   ${UL_eA5_measurements}    ${Log_Path}
     Sleep    10s
     ${pcap_file_path}     Stop pcap collection in eNB 14052   ${UL_eA5_HO}    ${Log_Path}
     Msg Should Be Present In PCAP    ${pcap_file_path}    ${UL_HO_eA5_meas_act}     RRCConnectionReconfiguration
     Log to Console    \n eA5 measurements activated due to UL buffer overflow
     Msg Should Be Present In PCAP    ${pcap_file_path}    ${eA5_UL_HO}     HandoverRequest
     Log to Console    \n Resource optimization Handover triggered \n
     Msg Should Be Present In PCAP    ${pcap_file_path}    ${UL_HO_eA5_meas_deact}     RRCConnectionReconfiguration
     Log to Console    \n eA5 measurements dectivated after HO to Target FDD cell
     Collect Snapshot    ${path}    Snapshot_IWK1
    [Teardown]  taf.sw.syslog.Collect Syslog Results    destination=${OUTPUT_DIR}${/}Sub_Case_1.log    unzip=True    alias=Sub_Case_1

CB014052_SR_D_IWK1_Filters_the_targets_of_lower_priority_HOs_with_common_target_freq_during_blockLowPrioHoAtHo_running
     Suite Setup   ${cus_yaml_TC3_D}   ${scfc_TC3_D}
     Sleep  30s
     configuration_id.Link SCOUT SCF to Configuration ID for Reporting
     Start Syslog_Sub_Case_3
     Start pcap collection in eth4      name=UL_eA5_measurements
#     Start pcap collection in eth3      name=UL_eA5_HO
     Log to Console    \n Detach all UEs
     Run Uex Command   ue_detach   all
     Log to Console    \n Attach UE to CB014052 enabled TDD cell
     run_esim_command    ue_mme_param    id=57    spid=1
     run_esim_command    ue_mme_param    id=58    spid=1
     Run Uex Command    ue_attach id=57-58    cell=2
     Run Uex Command    trf_data_start trf_id=1 dir=ul Mbps=150 ue=57-58 protocol=udp duration=60 duration_unit=seconds
     sleep  3s
     Run Uex Command    ue_measurement_send  id=57-58 event=A5 phycell_id=16 nrsrp=97 nrsrq=34
     Run Uex Command    ue_attach id=1-20    cell=3
     Run Uex Command    trf_data_start trf_id=1 dir=dl Mbps=150 ue=1-20 protocol=udp
     sleep    30s
     Run Uex Command    trf_data_start trf_id=1 dir=dl Mbps=150 ue=57-58 protocol=udp
     sleep    8s
#     run keyword and continue on failure    Run Uex Command    ue_measurement_send  id=57-58 event=A4 phycell_id=14 nrsrp=97 nrsrq=34
#     sleep    3s
     run keyword and continue on failure    Run Uex Command    ue_measurement_send  id=57-58 event=A4 phycell_id=14 nrsrp=97 nrsrq=34
#     sleep    3s
#     run keyword and continue on failure    Run Uex Command    ue_measurement_send  id=57-58 event=A4 phycell_id=14 nrsrp=97 nrsrq=34
     Sleep    10s
     Run Uex Command   ue_detach   all
     Sleep    10s
     ${pcap_file_path}     Stop pcap collection in eNB 14052   ${UL_eA5_measurements}    ${Log_Path}
     Sleep  10s
#     ${pcap_file_path}     Stop pcap collection in eNB 14052   ${UL_eA5_HO}    ${Log_Path}
     Msg Should Be Present In PCAP    ${pcap_file_path}    ${UL_HO_eA5_meas_act}     RRCConnectionReconfiguration
     Log to Console    \n eA5 measurements activated due to UL buffer overflow
     Msg Should Be Present In PCAP    ${pcap_file_path}    ${A4_LB_HO}     RRCConnectionReconfiguration
     Log to Console    \n Low Priority Handover triggered \n
     Collect Snapshot    ${path}    Snapshot_IWK1
    [Teardown]  taf.sw.syslog.Collect Syslog Results    destination=${OUTPUT_DIR}${/}Sub_Case_3.log    unzip=True    alias=Sub_Case_3


*** Keywords ***

Start DCAP Basic Controller
    Execute Terminal Command    DCAP_Basic_controller start

Start pcap collection in eth4
    [Documentation]    Start Pcap collection In GNB CU
    [Arguments]    ${name}=gnbTcpdump    ${options}=-i eth4
    tcpdump.Create Tcpdump Collector
    ...     name=${name}
    ...     options=${options}
    core.Setup Collectors    names=${name}
    core.Start Collectors    names=${name}
    tcpdump.Set test Alias    ${name}
    Log to Console    \n Wireshark started for eth4

Start pcap collection in eth3
    [Documentation]    Start Pcap collection In GNB CU
    [Arguments]    ${name}=gnbTcpdump    ${options}=-i eth3
    tcpdump.Create Tcpdump Collector
    ...     name=${name}
    ...     options=${options}
    core.Setup Collectors    names=${name}
    core.Start Collectors    names=${name}
    tcpdump.Set test Alias    ${name}
    Log to Console    \n Wireshark started for eth3

Stop pcap collection in eNB 14052
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}
    ${pcap_file_path}=   set variable    ${Log_Path}/${name}/${name}.pcap
    [Return]     ${pcap_file_path}
    Log to Console    \n Wireshark stopped

Suite Setup
    [Arguments]     ${cus_yaml}   ${scfc}
    Add Simulator   sim_type=cus    config=${cus_yaml}
    Add Enb Configuration           scfc=${scfc}    rad_params=@{swconfig_flags_list}
    Configure environment
    sleep   2s

Start Default Logging For CUS
    [Arguments]     ${output_dir}=${OUTPUT_DIR}
    start_syslog_for_enb    logs_dirpath=${output_dir}/enb  log_filename_prefix=default_syslog_enb    alias=default_enb
    start_infomodel

Stop Default Logging For CUS And Compress Test Logs
    [Arguments]     ${output_dir}=${OUTPUT_DIR}
    stop infomodel    log_filepath=${output_dir}/enb
    print_current_active_faults_from_fsm
    stop_syslog_with_specified_alias    alias=default_enb
    teardown_all_aliases_for_tshark
    compress_test_logs


Test Case Setup
    [Arguments]    ${test_name}
    Set Test Variable    ${tc_folder}    ${OUTPUT_DIR}${/}${test_name}
    Create Directory    ${tc_folder}

Keep Traffic Sending Lasting Time
    Sleep    ${COLLECT_TRAFFIC_TIMER}

Teardown And Collect All Logs
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    Collect Additional Debug Files For Failed Testcase Or Testsuite

Attach And Start Both Direction Traffic For List Ues
    [Arguments]    @{ue_list}
    FOR    ${ue_id}    IN    @{ue_list}
        Run Uex Command    ue_param   id=1   rohc=16   sec_key=0102030405060708090A0B0C0D0E1001   category=9   release=11
        Run Uex Command    ue_param   id=1   ue_eutra_capabilities=C99FF41032C10381DF834620000A0068100039400030
        Run Uex Command    ue_attach   id=1   cell=11
        Run UEx Command    trf_data_start     ue=1   dir=dl     protocol=udp    Mbps=${dl_traffic}     bearer=5    stats=true
        Run UEx Command    trf_data_start     ue=1   dir=ul     protocol=udp    Mbps=${ul_traffic}     bearer=5    stats=true
    END

Attach And Start Traffic CUS
    Run Uex Command    ue_param   id=1   rohc=16   sec_key=0102030405060708090A0B0C0D0E1001   category=9   release=11
    Run Uex Command    ue_param   id=1   ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES}
    Run Uex Command    ue_attach   id=1   cell=11
    Run UEx Command    trf_data_start     ue=1   dir=dl     protocol=udp    Mbps=1     bearer=5    stats=true


Compare Pm Counter
    [Arguments]    ${pm_counter_value}= 0    ${value}= 0    ${error}= 0.5
    ${delta}=    Evaluate    (abs(${pm_counter_value}-${value}) *1.0 /${pm_counter_value})
    Should Be True    ${delta} < ${error}


Clear Pm Counter
    [Arguments]    ${file_type}    ${sleep_time}=${WAIT_PLTF_DURATION}
    Run Keyword If    ${file_type}=='Raw'    Get Next Unpacked Raw Pm Counters File
              ...    ELSE IF    ${file_type}=='Full'    Get Next Unpacked Full Pm Counters File
    Sleep    ${sleep_time}

Get Pm Counter Value From Next Pm Data File Real Rf
    ${pm_counters_filepath}=    Get Next Unpacked Full Pm Counters File
    ${M8010C94}=    Get Latest Pm Counter Value
    ...    counter_id=M8010C94
    ...    local_moid=${LOCAL_CELL_ID_1}
    ...    filepath=${pm_counters_filepath}
    Log To Console    PM counter M8010C94 (OFDM_SYM_MICRO_DTX_R_RFM) value is ${M8010C94}
    Set Test Variable    ${M8010C94}

Start Syslog_${id}
	[Documentation]	Start Syslog keyword
     taf.sw.syslog.Start Syslog    log_dir=/home/ute/logs/${id}    log_name=${id}    alias=${id}
    ...    ip=192.168.255.126    ports=51000   add_line_number=True
    Log to Console    \n Start Syslog for Sub_Case_2

Start TTI Traces
    [Arguments]     ${cell_number}
    Log to console    \n Starting TTI Trace
    ttitrace.create ttitrace server 4g
    ...    name=ttiserver
    ...    enb_ip=192.168.255.129
    ttitrace.create ttitrace 4g collector
    ...    name=ttitrace
    ...    tool=ttiserver
    ...    global_cell_id=${cell_number}
    core.setup_collectors      names=ttitrace
    core.start_collectors      names=ttitrace
    core.set_suite_alias      alias=ttitrace

Stop TTI Traces
    [Arguments]     ${ttitrace_directory}
    Log to console    \n Stopping TTI Traces
    core.stop_collectors      names=ttitrace
    core.collect_collectors
    ...    names=ttitrace
    ...    target_dir=${ttitrace_directory}
    core.teardown_collectors      names=ttitrace
    taf.sbts.oam.coam.admin.Setup Admin
    ${sw_version}=    taf.sbts.oam.coam.admin.get_sw_version
    ${release_name}=    taf.sbts.oam.coam.admin.get_sw_release_name
    taf.sbts.oam.coam.admin.Teardown admin
    ${sw_version}    Replace String Using Regexp    ${sw_version}    ${release_name}   SBTS00
    install_ttitracer    version=${sw_version}    force=true
    Log to console    \n Converting tti trace dat file to txt file
    converter.create_ttitracer_converter
    ...          name=converter_1
    ...          file_path_pattern=${ttitrace_directory}/ttitrace/*.dat
    ...          duplex=tdd
    converter.setup     converter_1
    converter.convert   converter_1
    converter.teardown  converter_1

Collect Snapshot
    [Arguments]    ${path}    ${snapshot_file_name}
    ${snapshot_file_path}    set variable    ${path}/${snapshot_file_name}.zip
#    CoamAdmin.collect_snapshot
    taf.sbts.oam.coam.admin.Setup Admin
    coam.Collect Snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    detailed_output=True
    ...    timeout=300
    taf.sbts.oam.coam.admin.Teardown admin
    Log To Console    Snapshot collected and saved on path ${snapshot_file_path}

Start observing for MeNB addition message
    Log To Console  Start observing for MeNB addition message
    Expect Message Flow
    ...                  MeNB:DL-DCCH-Message (eventId eventA5 is present)
#    ...                 MeNB:X2AP_SgNBAdditionRequestAcknowledge (CG-Config is present)
#    ...                 MeNB:X2AP_SgNBReconfigurationComplete (RRCReconfigurationComplete is present)
    ...                 alias=SgNB_Addition    overall_timeout=30

Collect C-plane Traces

    &{bts}=  Create Dictionary
    ...  host=10.0.1.2
    ...  port=443
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}

    @{enb_custom_profile}=  Create List  cp_4g

    &{trace}=  Create Dictionary
    ...  bts=${bts}
    ...  enb_custom_profile=${enb_custom_profile}

    Create DCAP Trace Collector
    ...  name=dcap
    ...  trace=${trace}

    btslog.Setup Collectors   names=dcap
    core.Start Collectors   names=dcap
    sleep    120s
    core.Stop_collectors     names=dcap
    ttitrace.Collect Collectors  names=dcap
#    [teardown]  Teardown Collectors  names=dcap

Configure UE
	[Arguments]    ${ue_id}=1
	Run UEx command		ue_param	id=${ue_id}	ue_eutra_capabilities=C500004000CA2294244F87F13E1FC4F87F13E1FC4F87EBC3FE3880C200C040184000
	run_esim_command		ue_mme_param	id=${ue_id}	spid=1

Reconfigure UE and verify SPID A5 configured
	[Arguments]    ${ue_id}=1	${cell}=1
	Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishment (${ReestablishmentRequest})
    ...    alias=ReestablishmentRequest    overall_timeout=10
	Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${SPID_A5_query})
    ...    alias=SPID_A5    overall_timeout=10
    Run UEx command		ue_rrc_reestablish 	id=${ue_id}	cell=${cell}
	Flow Occurred As Expected    alias=ReestablishmentRequest
	Flow Occurred As Expected    alias=SPID_A5
	log to console		UE${ue_id} Reconfiguration successful

Start low UL data transfer and verify no UL A5 configured
	[Arguments]    ${ue_id}=1	${dir}=ul
	Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${UL_A5_query})
    ...    alias=UL_A5    overall_timeout=10
	Start data transfer	1	${dir}	1
	Flow Not Occurred For message    alias=UL_A5

Start high UL data transfer and verify UL A5 configured
	[Arguments]    ${ue_id}=1	${dir}=ul
	Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${UL_A5_query})
    ...    alias=UL_A5    overall_timeout=10
	Start data transfer	1	${dir}	250
	Flow Occurred As Expected    alias=UL_A5

Send A5 measurement and verify HO
	[Arguments]    ${ue_id}=1	${target_cell}=1
	Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${HO})
    ...    alias=HO    overall_timeout=10
	Run UEx command   ue_measurement_send	id=${ue_id}	event=A5	phycell_id=${target_cell}	nrsrp=97 nrsrq=34
	log to console		A5 measurement sent for UE ${ue_id}
	Flow Occurred As Expected    alias=HO

Stop data transfer and wait for UE IDLE
	[Arguments]    ${ue_id}=1	${dir}=ul
	Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (${UE_IDLE})
    ...    alias=IDLE    overall_timeout=60
	Stop data transfer	${ue_id}	${dir}
	Flow Occurred As Expected    alias=IDLE

Start data transfer
    [Arguments]    ${ue_id}=1    ${dir}=ul   ${data}=1000     ${qci}=6    ${duration}=60    ${trf_id}=1		${protocol}=tcp
    ${cmd}    catenate
    ...    trf_data_start trf_id=${trf_id} dir=${dir}
    ...    ue=${ue_id} protocol=${protocol} qci=${qci} duration=${duration} duration_unit=seconds rate=${data} size=130000
	Log to console			Starting ${dir} ${protocol} data transfer in UE${ue_id} for duration ${duration}
    Run UEx command    ${cmd}

Stop data transfer
	[Arguments]    ${ue_id}=1	${dir}=ul
	Run UEx command   trf_data_stop  ue=${ue_id}  dir=${dir}
	log to console		Stopped ${dir} data on UE ${ue_id}

Verify Counters
    Log to Console    \nChecking for counters
    Wait For Next Raw Pm Interval
	Verify Last Counters In File
    ...     M8023C12    1    AVG_ACT_UE_PROFILE_1
    ...     local_moid=MRBTS-1/LNCEL-1/LNCEL-1
    ...     file_path=${pm_counter_file}
