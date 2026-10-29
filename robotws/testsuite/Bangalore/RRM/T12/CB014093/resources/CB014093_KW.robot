*** Settings ***
Library         BuiltIn
Library         Collections
Library         DateTime
Library         OperatingSystem
Library         String
Library         taf.collectors.l1l2bip
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         taf.sw.syslog       WITH NAME   slog
Library         ta5g_pm_counters
Library         taf.converters.eventdecoder  WITH NAME  EVENTDECODER
Library         taf.collectors.l2stream3   WITH NAME    L2STREAM3
Library         ue_stats.py
Resource        ${CURDIR}/../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../resources/Keywords/common_keywords.robot
Resource        ${CURDIR}/../../resources/Variables/common_variables.robot
Documentation       :copyright: Nokia
...                 :author   : Bhakti Patel
...                 :contact  : bhakti.ka_patel@nokia.com
...                 :Feature Related all common Keywords.


*** Variables ***
${TOPOLOGY}                CLOUD_5G_I_LOO_AP_LOOO
${DELTACONFIGDIR}          ${CURDIR}/../config/scf
${AP_CONFIG_BASIC}         ${CURDIR}/../config/wts
${Pdu_session_ID}          1
${timeout}      150


*** Keywords ***
Prepare For CB014093 C
    [Documentation]    Prepares environment for test case CB014093-C including commissioning, reboot and bring up.
    ${Log_Path}    Create Log Directory     CB014093C
    Link SCOUT SCF To Configuration ID For Reporting
    Update BSR Package For RJIO
    Set Test Variable    ${Log_Path}
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_C.json     timeout=500
    Sleep       120s
    GNB Reboot
    Sleep    360s
    Wait Coam Site To Be Ready
    Start UTE WTS     basic_setup.cfg
    NG Link Should Be UP
    Sleep   90s

Prepare For CB014093 B
    [Documentation]    Prepares environment for test case CB014093 B including commissioning, reboot and bring up.
    ${Log_Path}    Create Log Directory     CB014093B
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_B.json     timeout=500
    Sleep       120s
    GNB Reboot
    Sleep    360s
    Wait Coam Site To Be Ready
    Start UTE WTS     basic_setup14093.cfg
    Basic Bring Up

Prepare For CB014093 E
    [Documentation]    Prepares environment for test case CB014093 E including commissioning and bring up.
    ${Log_Path}    Create Log Directory     CB0140583_E
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
    Start UTE WTS     basic_setup14093.cfg
    Basic Bring Up
    Wait Coam Site To Be Ready
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_E.json
    Wait Coam Site To Be In Expected State
    Sleep    10s

Get GNB Alarms
    [Documentation]    Retrieves current list of active alarms from gNB.
    admin.Setup Admin
    ${alarms}      admin.Get Alarms
    [Return]       ${alarms}
    [Teardown]     admin.Teardown Admin

Get Alarm By Details
    [Documentation]    Extracts fault IDs from gNB alarm details.
    @{alarms}   Get GNB Alarms
    @{Alarm_Fault_Id}       Create List
    FOR  ${alarm}  IN  @{alarms}
        ${current_alarm_info}              Get From Dictionary  ${alarm}                      alarmInformation
        ${current_additional_info}         Get From Dictionary  ${current_alarm_info}         alarmAdditionalInfo
        ${current_additional_fault_id}     Get From Dictionary  ${current_additional_info}    additionalFaultID
        Append To List      ${Alarm_Fault_Id}       ${current_additional_fault_id}
    END
    [Return]    ${Alarm_Fault_Id}

Wait Coam Site To Be In Expected State
    [Documentation]    Waits until COAM site is connected, BTS is onAir, and cells are offline.
    [Arguments]    ${timeout}=${gNB_Check_Timeout}
    Wait Until Keyword Succeeds    ${timeout}    30sec    admin.Connect To    bts_host=${GNB_ASIK.Ip}
    Set Variable SUITE CFG DIR
    Wait Until Keyword Succeeds    ${timeout}    30sec    Verify Coam BTS Is OnAir
    Wait Until Keyword Succeeds    ${timeout}    10sec    Verify Coam Cell Is Offline
    [Teardown]    admin.Teardown

Verify Coam BTS Is OnAir
    [Documentation]    Verifies gNB BTS is in onAir state.
    ${bts_state}                  admin.Get Mrbts State
    Log To Console                [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}       onAir    ignore_case=${TRUE}

Verify Coam Cell Is Offline
    [Documentation]    Verifies COAM cells are offline.
    ${cells_info}    admin.Get Cells Info
    FOR    ${cell}    IN    @{cells_info}
        ${has_key}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${cell['status']}    availabilityStatus
        IF    ${has_key}
            ${status}=    Get From Dictionary    ${cell['status']}    availabilityStatus
            Log To Console    [INFO] CELL STATE : ${status}
            Should Contain Any    ${status}    off line    offline    ignore_case=${TRUE}
        END
    END

Change ActEnhancedPDSCHSchSplSlot Value Online
    [Documentation]    Changes actEnhancedPDSCHSchSplSlot parameter online for NIDD feature.
    [Arguments]    ${Dist}    ${val}
    Log To Console      \nChanging feature flag value
    admin.Setup Admin
    Online NIDD parameter change    paramName=actEnhancedPDSCHSchSplSlot    paramValue=${val}    paramDst=${Dist}
    Sleep               5s
    [Teardown]          admin.Teardown Admin

Change PrachRootSequenceIndex And ZeroCorrelationZoneConfig Value Online
    [Documentation]    Sets random prachRootSequenceIndex (1–837) and zeroCorrelationZoneConfig (1–15) online.
    [Arguments]    ${Dist}
    Log To Console    \nChanging prachRootSequenceIndex and zeroCorrelationZoneConfig value
    # Generate random numbers avoiding 0
    ${rawP}    Generate Random String    3    [NUMBERS]
    ${rawZ}    Generate Random String    2    [NUMBERS]
    ${valP}    Evaluate    (int("${rawP}") % 837) + 1
    ${valZ}    Evaluate    (int("${rawZ}") % 15) + 1
    Log To Console    \nSelected prachRootSequenceIndex: ${valP}
    Log To Console    \nSelected zeroCorrelationZoneConfig: ${valZ}
    admin.Setup Admin
    Online NIDD parameter change    paramName=prachRootSequenceIndex    paramValue=${valP}    paramDst=${Dist}
    ...    skip_parameter_relation_errors=false
    Online NIDD parameter change    paramName=zeroCorrelationZoneConfig    paramValue=${valZ}    paramDst=${Dist}
    ...    skip_parameter_relation_errors=false
    Sleep    5s
    [Teardown]    admin.Teardown Admin


Teardown For CB014093 E
    [Documentation]    Performs teardown for CB014093 E: stops syslog, collects logs, and reverses configuration.
    Stop Syslog    alias=sys1
    Snapshot Collection     ${Log_Path}     Snapshot_E.zip
    Collect Logs For The Test                   ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB014093_E.zip ${LOG_PATH}
    GNB Delta Commission       ${DELTACONFIGDIR}/Delta_Config_Reverse_E.json      timeout=500
    Sleep   10s
    RAT Block Unblock

Teardown For CB014093 B
    [Documentation]    Performs teardown for CB014093 B: stops syslog, collects logs, and reverses configuration.
    Stop Syslog    alias=sys1
    Snapshot Collection     ${Log_Path}     Snapshot_B.zip
    Collect Logs For The Test                   ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB014093_B.zip ${LOG_PATH}
    GNB Delta Commission       ${DELTACONFIGDIR}/Delta_B_rev.json      timeout=500
    Sleep   10s
    RAT Block Unblock

Teardown For CB014093 C
    [Documentation]    Performs teardown for CB014093 C: stops syslog, collects logs, and reverses configuration.
    Snapshot Collection     ${Log_Path}     Snapshot_C.zip
    Collect Logs For The Test                   ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB014093_C.zip ${LOG_PATH}
    RAT Block Unblock

DL Traffic Should Be Successful
    [Documentation]    Starts downlink traffic and verifies successful data transfer.
    [Arguments]    ${dl_rate}=30    ${UE_ID}=${UE_ID}       ${QFI}=1
    Log To Console    \nRunning DL Traffic
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=${QFI}    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log To Console    \n${output}

UL Traffic Should Be Successful
    [Documentation]    Starts uplink traffic and verifies successful data transfer.
    [Arguments]    ${ul_rate}=30    ${UE_ID}=${UE_ID}       ${QFI}=1
    Log To Console    \nRunning UL Traffic
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=${QFI}    dir=ul    mbps=${ul_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log To Console    \n${output}

Displays QFI Statistics
    [Documentation]    Displays DL and UL bearer statistics for given UE and QFI.
    [Arguments]    ${ue_id}    ${QFI1}    ${Pdu_session_ID}=${Pdu_session_ID}
    Log To Console     \nBearer stats for UE '${ue_id}' in DL direction
    bearer_stats    ue=${ue_id}   qfi=${QFI1}    pdu=${Pdu_session_ID}    dir=dl
    Run Keyword And Ignore Error    read_wtsemu_output_until       L3 stats for internal traffic     60
    Sleep    10s
    Log To Console     \nBearer stats for UE '${ue_id}' in UL direction
    bearer_stats    ue=${ue_id}    qfi=${QFI1}    dir=ul     pdu=${Pdu_session_ID}
    Run Keyword And Ignore Error    read_wtsemu_output_until       L3 stats for internal traffic     60
    Sleep    10s

Verify IRAT HO
    [Documentation]    Verifies inter-RAT handover events from WTS output.
    [Arguments]    ${IRAT_HO_PATTERN_CHECK}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${IRAT_HO_Pattern_Check}   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}     Handover   partial_match=${TRUE}
    Log To Console    \n${output} done

Verify A3 HO
    [Documentation]    Verifies A3 handover events from WTS output.
    [Arguments]    ${HO}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${HO}   timeout=40
    ${output}         Get Lines Matching Regexp    ${output}    ${HO}   partial_match=${TRUE}
    Log To Console    \n${output}

Verify Scell Addition
    [Documentation]    Verifies addition of secondary cells.
    [Arguments]    ${CELL}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${CELL}   timeout=20
    ${output}         Get Lines Matching Regexp    ${output}    sCellToAddModList   partial_match=${TRUE}
    Log To Console    \n${output}

Verify Scell Release
    [Documentation]    Verifies release of secondary cells.
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=sCellToReleaseList   timeout=20
    ${output}         Get Lines Matching Regexp    ${output}    sCellToReleaseList   partial_match=${TRUE}
    Log To Console    \n${output}

CB014093 B RRC Inactive State
    [Documentation]    Executes RRC inactive state test for CB014093 B.
    Log To Console    \nStarting Re-Establishment Case....
    amf_ue_ics_param     id=1     ue=1     trace_activation=on     trace_plmn=310:260    trace_ref_id=10
    ...    trace_rec_session_ref_id=20     trace_depth=medium     ifaces_to_trace=NG-C,Xn-C,Uu,F1-C,E1
    ...    tce_ip=10.0.1.1    core_network_assistance_info=on    ue_identity_index_value=1
    ...    ue_specific_drx=256    periodic_registration_update_timer=1:10min    plmn_id=310:260    tac_id=200
    UE Register Should Be Successful For SA    ${UE2}
    Log To Console    \nStarting Downlink and Uplink Traffic for UE ${UE2}
    DL Traffic Should Be Successful     ${DL_RT}    ${UE2}
    UL Traffic Should Be Successful     ${UL_RT}    ${UE2}
    Stop Traffic For SA     ${UE2}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${inactive}   timeout=40
    ${output}         Get Lines Matching Regexp    ${output}    ${inactive}   partial_match=${TRUE}
    Log To Console    \n${output}
    DL Traffic Should Be Successful     ${DL_RT}    ${UE2}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${RRCResume}   timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    ${RRCResume}   partial_match=${TRUE}
    Log To Console    \n${output}
    UL Traffic Should Be Successful     ${UL_RT}    ${UE2}
    UE Deregister Should Be Successful For SA       ${UE2}

CB01493 B RRC ReEstablishment
    [Documentation]    Executes RRC re-establishment test case for CB01493 B.
    Log To Console    \nStarting RRC re-establishment case....
    UE Register Should Be Successful For SA    ${UE72}
    Log To Console    \nStarting Downlink and Uplink Traffic for UE ${UE72}
    DL Traffic Should Be Successful     ${DL_RT}    ${UE72}
    UL Traffic Should Be Successful     ${UL_RT}    ${UE72}
    ue_rrc_reestablish    id=${UE72}    gnb=2  cell=2    cause=otherFailure
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${RRCreconfig}   timeout=40
    ${output}         Get Lines Matching Regexp    ${output}    ${RRCreconfig}   partial_match=${TRUE}
    Log To Console    \n${output}
    UE Register Should Be Successful For SA    ${UE4}
    Log To Console    \nStarting Downlink and Uplink Traffic for UE ${UE4}
    DL Traffic Should Be Successful     ${DL_RT}    ${UE4}
    UL Traffic Should Be Successful     ${UL_RT}    ${UE4}
    ue_rrc_reestablish    id=${UE4}    gnb=2  cell=10    cause=otherFailure
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${RRCreconfig}   timeout=40
    ${output}         Get Lines Matching Regexp    ${output}    ${RRCreconfig}   partial_match=${TRUE}
    Log To Console    \n${output}
    ue_disp     id=${UE4}
    ue_disp     id=${UE72}

CB01493 B Eutra Inact
    [Documentation]    Executes EUTRA inactivity case for CB01493 B.
    Log To Console    \nStarting eutra inact case
    LTE Attach Should Be Successful For NSA    ${UE101}
    enb_endc_param     id=${UE101}     serving_cell_index_range_scg=5:31
    UE Attach Should Be Successful For NSA    ${UE101}    1
    Start Traffic     ${UE101}
    Sleep    5s
    Stop Traffic    ${UE101}    1
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${Eutra}   timeout=90
    ${output}         Get Lines Matching Regexp    ${output}    ${Eutra}   partial_match=${TRUE}
    Log To Console    \n${output}
    UE Attach Should Be Successful For NSA    ${UE101}    1

Validate TCP Traffic
    [Arguments]    ${UE_ID}    ${qfi}    ${Pdu_session_ID}=${Pdu_session_ID}
    Log To Console    \nRunning DL + UL Traffic
    wtsrunner.trf_data_start    ue=${UE_ID}    pdu=${Pdu_session_ID}    qfi=${qfi}    dir=dl    protocol=tcp    seconds=6000
    ${output}=    wtsrunner.read_wtsemu_output_until_re    expected=TCP DL TRF    timeout=10
    ${output}=    Get Lines Matching Regexp    ${output}    TRF    partial_match=${TRUE}
    Log To Console    ${output}
    Sleep    5s
    wtsrunner.trf_data_start    ue=${UE_ID}    pdu=${Pdu_session_ID}    qfi=${qfi}    dir=ul    protocol=tcp    seconds=6000
    ${output}=    wtsrunner.read_wtsemu_output_until_re    expected=TCP UL TRF    timeout=10
    ${output}=    Get Lines Matching Regexp    ${output}    TRF    partial_match=${TRUE}
    Log To Console    ${output}
    Sleep    5s


Stop TCP Traffic
    [Arguments]    ${UE_ID}    ${qfi}
    Log To Console    \nStopping DL + UL Traffic
    wtsrunner.trf_data_stop    ue=${UE_ID}    pdu=1    qfi=${qfi}    dir=dl
    ${output}=    wtsrunner.read_wtsemu_output_until_re    expected=Stopped Downlink Internal traffic    timeout=10
    ${output}=    Get Lines Matching Regexp    ${output}    Stopped    partial_match=${TRUE}
    Log To Console    ${output}
    wtsrunner.trf_data_stop    ue=${UE_ID}    pdu=1    qfi=${qfi}    dir=ul
    ${output}=    wtsrunner.read_wtsemu_output_until_re    expected=Stopping Uplink Internal traffic    timeout=10
    ${output}=    Get Lines Matching Regexp    ${output}    uplink    partial_match=${TRUE}
    Log To Console    ${output}
    Sleep    5s


Modify PDU Session For UE To Add
    [Arguments]    ${ue_id}    ${Pdu_session_ID}=${Pdu_session_ID}    ${QFI}=${QFI2}    ${pattern}=${pdu_session_modify}
    ue_pdu_session_modify    ue=${ue_id}    pdu=${Pdu_session_ID}    qosflows_to_add=${QFI}    by=amf
    Sleep    10s
    read_wtsemu_output_until    ${pattern}    ${timeout}
    Sleep    5s


Validate Traffic With RTP
    [Arguments]    ${ue_id}    ${qfi}    ${Pdu_session_ID}=${Pdu_session_ID}
    trf_data_start    ue=${UE_ID}    pdu=${Pdu_session_ID}    qfi=${qfi}    dir=dl    rtp_codec=custom    seconds=3000
    ${output}=    wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink RTP Internal traffic over UDP    timeout=10
    ${output}=    Get Lines Matching Regexp    ${output}    TRF:    partial_match=${TRUE}
    Log To Console    \n${output}
    trf_data_start    ue=${UE_ID}    pdu=${Pdu_session_ID}    qfi=${qfi}    dir=ul    rtp_codec=custom    seconds=3000
    ${output}=    wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink RTP Internal traffic over UDP    timeout=10
    ${output}=    Get Lines Matching Regexp    ${output}    TRF:    partial_match=${TRUE}
    Log To Console    \n${output}
    Sleep    5s

Verify Throughput Reduces As Pathloss Increases
    [Arguments]    ${UE_ID}
    ${prev_avg}=    Set Variable    9999.0
    ${pathloss}=    Set Variable    ${PATHLOSS_START}

    WHILE    ${pathloss} <= ${PATHLOSS_END}

        Log To Console    \n===== Pathloss: ${pathloss} dB =====

        ul_sinr_testmode_nr    profile_id=${UE_ID}    pathloss=${pathloss}    pcmax=${PCMAX}
        ue_testmode_set_nr    id=${UE_ID}    testmode=ul_sinr    action=activate    profile_id=${UE_ID}
        ue_stats_nr           id=${UE_ID}    type=pdsch,pusch    scell=0-1

        ${output}=    Read WTS Output Until Pattern Matches    NR PUSCH Throughput    200
        ${avg}=       Check Avg Rate    ${output}

        Log To Console    Average Throughput : ${avg} Mbps

        # Skip check on first iteration
        Run Keyword If    ${pathloss} > ${PATHLOSS_START}
        ...    Should Be True    ${avg} < ${prev_avg}
        ...    msg=Throughput not reducing with higher pathloss

        ${prev_avg}=    Set Variable    ${avg}
        ${pathloss}=    Evaluate    ${pathloss} + ${STEP}

    END

Start TTI_TRACE custom
    [Arguments]    ${cell_id}=${50}
    Common Start Ttitrace With Streaming Mode_3 custom        pysical_cell_ids=${cell_id}

Common Start Ttitrace With Streaming Mode_3 custom
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ${nr_phy_cell_ids}    Create List    ${pysical_cell_ids}
    ${nr_phy_cell_ids}=    Evaluate  map(int, $nr_phy_cell_ids)
    Log Many    ${pysical_cell_ids}       ${nr_phy_cell_ids}
    ${localIpAddr}=    set variable    10.0.1.2
    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
   ...  destination_ip_addr=${dest_ip}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}

Common Get EIF Info Of Control PC
    ${ret}=    Run    ip addr
    ${eth0_ip}=    get_regexp_matches    ${ret}    inet (?P<eth0>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth0    eth0
    ${eth3_ip}=    get_regexp_matches    ${ret}    inet (?P<eth3>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth3    eth3
    ${eth0_ip}=    Set Variable    ${eth0_ip}[0]
    ${eth3_ip}=    Set Variable If    "${eth3_ip}"=="[]"    none    ${eth3_ip}[0]
    Log To Console    eth0_ip=${eth0_ip},eth3_ip=${eth3_ip}
    ${web_card}=    Set Variable If    "${eth3_ip}"=="none"    eth0    eth3
    ${dest_ip}=    Set Variable If    "${web_card}"=="eth0"    ${eth0_ip}    ${eth3_ip}
    Log To Console    web_card=${web_card},dest_ip=${dest_ip}
    [Return]    ${web_card}    ${dest_ip}

Stop ttitrace Collection
    [Arguments]    ${log_path}=${OUTPUT_DIR}        ${names}=l2stream3_ttitrace
    CORE.stop_collectors
    ...  names=${names}
    CORE.collect_collectors
    ...  names=${names}
    CORE.teardown_collectors
    ...  names=${names}
    ${pcap_file}=    Set Variable    ${OUTPUTDIR}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${pcap_file}" ${log_path}

Common Convert Ttitrace From Pcap To Excelcsv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${names}=l2stream3_ttitrace    ${filename}=tcpdump_ttitrace.pcap
    Builtin.Log   ${names}
    ${file_path}=    Set Variable    ${log_path}/${filename}
    EVENTDECODER.Create Eventdecoder Converter
    ...  name=converter
    ...  input_file_path=/home/ute/logs/tcpdump_ttitrace.pcap
    ...  output_file_format=excelCsv
    EVENTDECODER.Convert
    ...  name=converter
    OperatingSystem.Run    cp ${EXECDIR}/output_dl.csv ${log_path};cp ${EXECDIR}/output_ul.csv ${log_path}
