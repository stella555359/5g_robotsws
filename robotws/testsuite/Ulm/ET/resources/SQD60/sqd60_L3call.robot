# Copyright (c) 2021 Nokia. All rights reserved.

*** Settings ***
Documentation
...    Team: 'MN RAN RD VRF ULM 6'
...    Email: 'ou_mn_ran_rd_vrf_ulm_6_53244963@internal.nsn.com'
...    Description: Basic L3 Call tools

Library         String
Library         Collections
Library         DateTime

Library         taf.sbts.oam.coam.admin                      WITH NAME    admin
Library         taf.transport.ssh                            WITH NAME    ssh

Resource        ../../../resources/Common/btslog.robot
Resource        ../../../resources/Common/coam_ulm.robot
Resource        ../../../resources/Common/gnb.robot
Resource        ../../../resources/Common/reporting.robot
Resource        ../../../resources/Common/snapshot.robot
Resource        ../../../resources/Common/testline.robot
Resource        ../../../resources/Common/tcpdump.robot
Resource        ../../../resources/Common/bip_trace.robot
Resource        ../../../resources/Common/bip_trace_ap.robot
Resource        ../../../resources/Common/ttitrace.robot
Resource        ../../../resources/Common/ute_workarounds.robot
Resource        ../../../resources/Common/wts_ue.robot

Resource        sqd60_tools.robot


*** Variables ***
# &{TESTSUITE_PARAMETERS}
&{TSP}                    COLLECT_GNB_BIP=false          # [ FALSE, TRUE ]        Collect gNB BIP Trace
...                       COLLECT_AP_BIP=false           # [ FALSE, TRUE ]        Collect AP BIP Trace
...                       COLLECT_SCTP=false             # [ FALSE, TRUE ]        Collect sctp trace
...                       COLLECT_SYSLOG=true            # [ FALSE, TRUE ]        Collect btslog2 syslog
...                       COLLECT_TTI_TRACE=false        # [ FALSE, TRUE ]        Collect TTI Trace for traffic
...                       COLLECT_BH_PCAP=false          # [ FALSE, TRUE ]        Collect BH pcap (eth3)
...                       COLLECT_WTS_PCAP=false         # [ FALSE, TRUE ]        Collect WTS pcap (eth4)
...                       COLLECT_SNAPSHOT=true          # [ FALSE, TRUE ]        Collect Snapshot
...                       COLLECT_SOS_REPORT=false       # [ FALSE, TRUE ]        Collect SOS Report
...                       FORCE_REBOOT=false             # [ FALSE, TRUE ]        Reboot testline every start of test
...                       ENFORCE_RESOURCE_USAGE=true    # [false, true] enables resource usage assertion (for testing)
...                       TEST_CU_TYPE=SA+NSA            # [ SA, NSA, SA+NSA ]
...                       ENABLE_ONLINE_REPORTING=false  # [ FALSE, TRUE ]
...                       QC_PATH=${EMPTY}
...                       RESTORE_TESTLINE_CONFIG=false  # [ FALSE, TRUE ]        Restores default config

${TIMER_START_REFERENCE}             stopped
@{exclude_in_resource_check}         //nbOfFreeCRNTI    //cellGroupResources

*** Keywords ***
Start Test Environment
    Initialize Dictionary Parameters

    ${EXPECTED_TPUT_DL_EGATE}=    Evaluate    ${TRF_MBPS}*1000000*${TRF_TOLERANCE}
    ${EXPECTED_TPUT_UL_EGATE}=    Evaluate    ${TRF_MBPS}*1000000*${TRF_TOLERANCE}
    Set Suite Variable    ${EXPECTED_TPUT_DL_EGATE}
    Set Suite Variable    ${EXPECTED_TPUT_UL_EGATE}

    testline.Create Test Suite Log Folders
    ${TESTSUITE_LOG_DIR}=    testline.Get Test Suite Log Directory
    Set Suite Variable       ${TESTSUITE_LOG_DIR}

    ute_workarounds.UTE Cloud Workaround

    Store Current SCF From GNB                                        # Suite Variable Name ${P_ORIG_SCF}
    gnb.Store Current Swconfig From GNB                               # Suite Variable Name ${P_ORIG_GNB_SWCONFIG}
    wts_ue.Store Current Swconfig From Airphone                       # Suite Variable Name ${P_ORIG_AP_SWCONFIG}
    wts_ue.Store Current WTS Config                                   # Suite Variable Name ${P_ORIG_WTS_CONFIG}

    ute_workarounds.Log TL Info As Metadata For UTE AP TL
    wts_ue.Kill WTS Services

    IF    "${TSP.COLLECT_SYSLOG}"=="true"    btslog.Start Btslog

    Verify Commissioning State
    ${status}    Run Keyword And Return Status    gnb.Wait For Minimum Required State For Cell Setup

    Start Timer
    IF    ${status} != True or "${TSP.FORCE_REBOOT}"=="true"
    ...               ute_workarounds.Bring Airphone TL To F1 Up Status    timeout=15min
    ${delta_time}    Stop Timer
    Log To Console    ----- Bring Airphone TL to F1 up status took ${delta_time} seconds -----

    IF    "${TSP.COLLECT_SYSLOG}"=="true"    btslog.Stop Btslog    target_dir=${TESTSUITE_LOG_DIR}/startup/

End Test Environment
    IF    "${TSP.RESTORE_TESTLINE_CONFIG}"=="true"    Run Keyword And Warn On Failure    Run Keywords    Revert Iphy
    ...               AND    Restore Scf   AND    Reload Stored Swconfig To GNB    AND    Reload Stored Swconfig To Airphone
    ...               AND    Reload Stored WTS Config

    Run Keyword And Ignore Error       wts_ue.Reset Wts Cfg
    Run Keyword And Ignore Error       wts_ue.Teardown Egate Connection For Airphone
    Run Keyword And Ignore Error       wts_ue.Teardown Edaemon Connection For Airphone
    Run Keyword And Ignore Error       connect.Teardown OAM Http Session


Start Testcase Environment
    ${testcase_dir}=     testline.Get Testcase Log Directory
    Set Test Variable    ${testcase_dir}

    Start Log Collection

End Testcase Environment
    Run Keyword And Ignore Error    wts_ue.Save Current Egate Console Log

    Stop Log Collection
    IF    "${TSP.ENABLE_ONLINE_REPORTING}"=="true"    Start Online Reporting

Start Online Reporting
    IF          '${TEST STATUS}'!='PASS'   RETURN
    Set Tags    SKIP_REPORT

    reporting.Online Reporting To ReP    tcName=${TEST NAME}
    ...                                  qcFilePath=${QC_PATH}    isForDebugging=no
    Log To Console    \nReported to QC: ${QC_PATH}

Start Timer
    ${TIMER_START_REFERENCE}=     DateTime.Get Current Date
    Set Suite Variable          ${TIMER_START_REFERENCE}

Stop Timer
    Should Not Be Equal As Strings      ${TIMER_START_REFERENCE}    stopped    msg=Start Timer keyword should be executed first
    ${stopwatch_stoptime}=              DateTime.Get Current Date
    ${delta_time}=                      DateTime.Subtract Date From Date     ${stopwatch_stoptime}   ${TIMER_START_REFERENCE}
    Set Suite Variable                  ${TIMER_START_REFERENCE}    stopped
    RETURN    ${delta_time}

Verify Commissioning State
    ${oam_alias}=    connect.Setup OAM Http Session
    ${bts_status}                 admin.Get Bts Statuses    connection=${oam_alias}
    coam_ulm.Nidd Value Should Be One Of    ${bts_status['proceduralState']}    OnAir, Commissioned, Configured

Verify On Air State
    ${oam_alias}=    connect.Setup OAM Http Session
    ${bts_state}                  admin.Get Mrbts State    connection=${oam_alias}
    Log                   [INFO] BTS STATE : ${bts_state}    console=${P_console}
    coam_ulm.Nidd Value Should Be Equal    ${bts_state}    OnAir

Start AP BIP Traces
    [Arguments]    ${collector}
    Log To Console    Start AP BIP Traces: ${collector}
    bip_trace_ap.Start Airphone BIP Traces    collector=${collector}

Stop AP BIP Traces
    [Arguments]    ${collector}
    Log To Console    Start AP BIP Traces: ${collector}
    bip_trace_ap.Stop Airphone BIP Traces    collector=${collector}

Prepare And Verify Cell On Air
    [Arguments]    ${target_cells}=${TARGET_CELLS_NSA}    ${cu_type}=${TSP.TEST_CU_TYPE}    ${cfg_file}=${tl.core.cfg_filename}
    ute_workarounds.Configure WTS For UTE Cloud Airphone TL    remove_logs=${True}
    ...                                                        cfg_file=${cfg_file}
    ...                                                        force_cu_type=${cu_type}
    ute_workarounds.Verify Cell Setup

    wts_ue.Send Egate Command And Verify Output    cmd=sim_log_set flush
    ${core_alias}=    connect.Connect To Core
    FOR    ${target_cell}    IN    @{target_cells}
        ${query}=         Catenate    Cell Setup completed for .CELL_ID:${target_cell}.
        ${egate_log}=     ssh.Execute    grep -i '${query}' ${tl.core.dir_path}/egate_console.log    connection=${core_alias}
        Should Contain    ${egate_log}    Cell Setup completed    ignore_case=True    msg=Cell ${target_cell} Failed!
    END
    Verify On Air State

Start Log Collection
    [Arguments]    ${tag}=default
    IF    "${TSP.COLLECT_GNB_BIP}"=="true"      bip_trace.Start BIP Traces                collector=gnb-bip-tcpdump-${tag}
    IF    "${TSP.COLLECT_AP_BIP}"=="true"       Start AP BIP Traces                       ap-bip-tcpdump-${tag}
    IF    "${TSP.COLLECT_SCTP}"=="true"         tcpdump.Start TCPdump On GNB Common Unit  collector=gnb-sctp   options=-i any sctp
    IF    "${TSP.COLLECT_SYSLOG}"=="true"       btslog.Start Btslog

    IF    "${TSP.COLLECT_TTI_TRACE}"=="true"    ttitrace.Start TTI Traces In Streaming Mode
    IF    "${TSP.COLLECT_BH_PCAP}"=="true"      tcpdump.Start Tcpdump On TestPc   options=-i eth3    collector=bh-eth3-tcpdump-${tag}
    IF    "${TSP.COLLECT_WTS_PCAP}"=="true"     tcpdump.Start Tcpdump On TestPc   options=-i eth4    collector=wts-eth4-tcpdump-${tag}

Stop Log Collection
    [Arguments]    ${tag}=default
    IF    "${TSP.COLLECT_GNB_BIP}"=="true"      Run Keyword And Ignore Error    bip_trace.Stop BIP Traces
    ...                                                                                        collector=gnb-bip-tcpdump-${tag}
    IF    "${TSP.COLLECT_AP_BIP}"=="true"       Run Keyword And Ignore Error    Stop AP BIP Traces    ap-bip-tcpdump-${tag}
    IF    "${TSP.COLLECT_SCTP}"=="true"         Run Keyword And Ignore Error    tcpdump.Stop TCPdump On GNB Common Unit
    ...                                                                                        collector=gnb-sctp
    ...                                                                                        target_dir=${testcase_dir}/gnb-sctp-tcpdump-${tag}
    IF    "${TSP.COLLECT_SYSLOG}"=="true"       Run Keyword And Ignore Error    btslog.Stop Btslog
    ...                                                                                        target_dir=${testcase_dir}/syslog-${tag}

    IF    "${TSP.COLLECT_TTI_TRACE}"=="true"    Run Keyword And Ignore Error    ttitrace.Stop TTI Traces In Streaming Mode
    ...                                                                                        tti_trace_filename=tti_trace-${tag}
    IF    "${TSP.COLLECT_BH_PCAP}"=="true"      Run Keyword And Ignore Error    tcpdump.Stop Tcpdump On TestPc
    ...                                                                                        collector=bh-eth3-tcpdump-${tag}
    IF    "${TSP.COLLECT_WTS_PCAP}"=="true"     Run Keyword And Ignore Error    tcpdump.Stop Tcpdump On TestPc
    ...                                                                                        collector=wts-eth4-tcpdump-${tag}

    IF    "${TSP.COLLECT_SNAPSHOT}"=="true"     Run Keyword And Ignore Error    snapshot.Collect Snapshot From GNB
    ...                                                                                        target_dir=${TESTSUITE_LOG_DIR}
    IF    "${TSP.COLLECT_SOS_REPORT}"=="true"     Run Keyword And Ignore Error  wts_ue.Collect Sos Report Logs
    ...                                                                                        target_dir=${TESTSUITE_LOG_DIR}

List Length Should Be Equal And Return Length
    [Arguments]    ${list1}    ${list2}    ${msg}=list is not equal
    ${list1_length}=    Get Length     ${list1}
    ${list2_length}=    Get Length     ${list2}
    Should Be Equal As Numbers    ${list1_length}    ${list2_length}
    ...                           msg=${msg}
    RETURN    ${list1_length}

Restore SCF
    Log To Console    Restore SCF
    Wait For RU
    ${oam_alias}=    connect.Setup OAM Http Session
    admin.Perform Commissioning  scf_file=${P_ORIG_SCF}  connection=${oam_alias}
    ...  skip_parameter_relation_errors=True  timeout=600
    Run Keyword And Warn On Failure    Wait For Minimum Required State For Cell Setup    timeout=10min

Wait For RU
    [Arguments]    ${timeout}=5min
    ${oam_alias}                  connect.Setup OAM Http Session
    BuiltIn.Log                   \nWaiting for RU    console=${P_console}
    Wait Until Keyword Succeeds   ${timeout}   20s    Verify All Radios Are Online    connection=${oam_alias}

Revert Iphy
    BuiltIn.Log To Console        Revert iphy.xml
    ${ACU_alias}                  Connect To Airphone Common Unit
    ssh.Execute                   cp /ffs/run/simmode/new_iphy_orig.xml /ffs/run/simmode/new_iphy.xml    connection=${ACU_alias}

####################
# NSA Keywords
####################

Perform SgNBAddition For All UEs
    [Arguments]     ${ue_ids}=${TESTUE_IDS_NSA}    ${target_cells}=${TARGET_CELLS_NSA}
    ${total_ues}=    List Length Should Be Equal And Return Length    ${ue_ids}    ${target_cells}    msg=ue_ids should match target_cells count

    FOR    ${ueid_cell_map_idx}    IN RANGE    0    ${total_ues}
        wts_ue.Attach UE To LTE                                ${ue_ids[${ueid_cell_map_idx}]}
        wts_ue.Trigger LTE-NR Dual Connectivity For Bearers    ue_id=${ue_ids[${ueid_cell_map_idx}]}    bearer_id=2
        ...                                                    target_cells=${target_cells[${ueid_cell_map_idx}]}
    END

Verify Random Access In Egate For All Ues
    [Arguments]     ${ue_ids}=${TESTUE_IDS_NSA}    ${target_cells}=${TARGET_CELLS_NSA}
    ${total_ues}=    List Length Should Be Equal And Return Length    ${ue_ids}    ${target_cells}    msg=ue_ids should match target_cells count

    wts_ue.Send Egate Command And Verify Output    cmd=sim_log_set flush
    ${core_alias}=    connect.Connect To Core
    FOR    ${ueid_cell_map_idx}    IN RANGE    0    ${total_ues}
        ${query}=    Catenate    UE${ue_ids[${ueid_cell_map_idx}]}: Proxy.*
        ...                      cell ${target_cells[${ueid_cell_map_idx}]}. reported successful RA
        ${egate_log}=     ssh.Execute    grep -i '${query}' ${tl.core.dir_path}/egate_console.log    connection=${core_alias}
        Should Contain    ${egate_log}    reported successful RA    ignore_case=True    msg=RA on Cell ${target_cells[${ueid_cell_map_idx}]} Failed!
    END

Detach All UEs
    [Arguments]     ${ue_ids}=${TESTUE_IDS_NSA}
    Log To Console    Detach all UEs: ${ue_ids}
    FOR    ${ue_id}    IN    @{ue_ids}
        wts_ue.Detach UE From LTE    ${ue_id}
    END

Start Internal Traffic For All UEs
    [Arguments]    ${dl}=0    ${ul}=0    ${trf_id_dl}=2    ${trf_id_ul}=1
    ...            ${cu_type}=NSA    ${ue_ids}=${TESTUE_IDS_NSA}
    Log To Console                                      \n----- [Start Internal Traffic] ----
    IF    "${dl}"!="0"    Log To Console      Expected DL Throughput . . . : ${dl} mbps
    IF    "${ul}"!="0"    Log To Console      Expected UL Throughput . . . : ${ul} mbps
    Log To Console                                        Passing Criteria . . . . . . : ${TRF_TOLERANCE}
    Log To Console                                        Duration . . . . . . . . . . : ${TRF_DURATION} \n

    &{traffic_param}=    IF    '${cu_type}' == 'NSA'    Create Dictionary    id=2
    ...    ELSE    Create Dictionary    pdu=1    qfi=1

    FOR    ${ue_id}    IN    @{ue_ids}
        IF    '${dl}'!='0'   Start Data Traffic In Egate    ${ue_id}  dl  trf_id=${trf_id_dl}  mbps=${dl}  &{traffic_param}
        IF    '${ul}'!='0'   Start Data Traffic In Egate    ${ue_id}  ul  trf_id=${trf_id_ul}  mbps=${ul}  &{traffic_param}
    END

Print And Verify All Traffic Result
    [Arguments]    ${dl}=0    ${ul}=0    ${trf_id_dl}=2    ${trf_id_ul}=1
    ...            ${cu_type}=NSA    ${ue_ids}=${TESTUE_IDS_NSA}
    &{traffic_param}=    IF    '${cu_type}' == 'NSA'    Create Dictionary    id=2
    ...    ELSE    Create Dictionary    pdu=1    qfi=1
    Run Keyword And Continue On Failure    Verify 5G Did Not Drop

    FOR    ${ue_id}    IN    @{ue_ids}
        IF    "${dl}"!="0"    Print Average Rate Of Packet Loss From Egate    ${ue_id}  dir=dl    trf_id=${trf_id_dl}    &{traffic_param}
        IF    "${dl}"!="0"    Verify If Average Tput Is Correct  ${ue_id}    dl    ${dl}    trf_id=${trf_id_dl}      &{traffic_param}

        IF    "${ul}"!="0"    Print Average Rate Of Packet Loss From Egate    ${ue_id}  dir=ul    trf_id=${trf_id_ul}    &{traffic_param}
        IF    "${ul}"!="0"    Verify If Average Tput Is Correct  ${ue_id}    ul    ${ul}    trf_id=${trf_id_ul}      &{traffic_param}
    END

    [Teardown]    Stop Traffic For All UEs    dl=${dl}    ul=${ul}   cu_type=${cu_type}    ue_ids=${ue_ids}

Stop Traffic For All UEs
    [Arguments]    ${dl}=${true}    ${ul}=${true}    ${trf_id_dl}=2    ${trf_id_ul}=1
    ...            ${cu_type}=NSA   ${ue_ids}=${TESTUE_IDS_NSA}

    &{traffic_param}=    IF    '${cu_type}' == 'NSA'    Create Dictionary    id=2
    ...    ELSE    Create Dictionary    pdu=1

    FOR    ${ue_id}    IN    @{ue_ids}
        IF    ${dl}    Stop Data Traffic In Egate    ${ue_id}  dl  trf_id=${trf_id_dl}  &{traffic_param}
        IF    ${ul}    Stop Data Traffic In Egate    ${ue_id}  ul  trf_id=${trf_id_ul}  &{traffic_param}
    END
    Log To Console    ----- [ Traffic Stopped] ----\n

Print Average Rate Of Packet Loss From Egate
    [Arguments]    ${ue_id}    ${dir}=bi    ${trf_id}=all    &{kwargs}
    ${packet_loss}=    Get Average Rate Of Packet Loss From Egate    ${ue_id}    dir=${dir}    trf_id=${trf_id}    &{kwargs}
    ${packet_loss}=    Evaluate    ${packet_loss} * 100
    Log To Console    Avg. rate of packet loss . . : [UE ${ue_id}] [${dir}] ${packet_loss} %

Get Average Rate Of Packet Loss From Egate
    [Documentation]
    [Arguments]    ${ue_id}    ${dir}=bi    ${trf_id}=all    &{kwargs}
    ${dc_cell_group}=     Set Variable If    '${dir}' == 'dl'    scg    all
    ${output}=            wts_ue.Display Bearer Stats     ue_id=${ue_id}    direction=${dir}    trf_id=${trf_id}
    ...                                                   type=l3    dc_cell_group=${dc_cell_group}    &{kwargs}

    ${t_pkt_lost_raw}=    String.Get Lines Containing String    ${output}    Total packets lost
    ${t_pkt_rx_raw}=      String.Get Lines Containing String    ${output}    Total packets received

    ${t_pkt_lost_raw}=    String.Replace String    ${t_pkt_lost_raw}    Total packets lost        ${EMPTY}
    ${t_pkt_rx_raw}=      String.Replace String    ${t_pkt_rx_raw}    Total packets received    ${EMPTY}

    ${t_pkt_lost_raw}=    String.Strip String      ${t_pkt_lost_raw}
    ${t_pkt_rx_raw}=      String.Strip String      ${t_pkt_rx_raw}

    ${t_pkt_lost}=        Convert To Integer    ${t_pkt_lost_raw}
    ${t_pkt_rx}=          Convert To Integer    ${t_pkt_rx_raw}

    Run Keyword And Continue On Failure    Should Not Be Equal    ${t_pkt_rx}    ${0}    msg=Total packet received is zero!
    IF    ${t_pkt_rx}==${0}    RETURN   ${1}
    ${packet_loss}=         Evaluate    ${t_pkt_lost} / ( ${t_pkt_rx} + ${t_pkt_lost} )

    RETURN    ${packet_loss}

Verify If Average Tput Is Correct
    [Arguments]  ${ue_id}
    ...          ${dir}
    ...          ${tp}
    ...          ${trf_id}
    ...          &{kwargs}
    ${data_rate}=     wts_ue.Get Average Data Rate Via Egate  ue_id=${ue_id}    dir=${dir}    trf_id=${trf_id}    &{kwargs}
    Log To Console    Average data throughput. . . : [UE ${ue_id}] [${dir}] ${data_rate}
    Run Keyword And Continue On Failure    Should Be True    ${data_rate} > ${tp}    msg=Throughput is incorrect!

Verify 5G Did Not Drop
    ${status}    Run Keyword And Return Status   wts_ue.Check Current Egate Console Status   Bearer-type change from SCG-split to MCG is successful
    Should Not Be True    ${status}    msg=Dual Connectivity Dropped!!!

Perform Attach Then Detach For All UEs
    Perform SgNBAddition For All UEs
    Detach All UEs

####################
# SA Keywords
####################

Trigger UE Register In Egate For All Ues
    [Arguments]    ${ue_ids}=${TESTUE_IDS_SA}
    Log To Console    Trigger UE Register in Egate for all Ues: ${ue_ids}
    FOR    ${ue_id}    IN    @{ue_ids}
        wts_ue.UE Register    ue_id=${ue_id}
    END

Trigger UE PDU Session Setup In Egate For All Ues
    [Arguments]    ${ue_ids}=${TESTUE_IDS_SA}
    ${PDU_SESSIONS}=    Create List
    FOR    ${ue_id}    IN    @{ue_ids}
        wts_ue.Set Traffic Type    ue_id=${ue_id}    pdu_id=1    trf_type=internal    log_traffic_stats=off
        ${ue_pdu_session}    ${_}=    wts_ue.UE PDU Session Setup    ue_id=${ue_id}    pdu=1    gw=${ue_id}
        Collections.Append To List    ${PDU_SESSIONS}    ${ue_pdu_session}
    END
    Set Suite Variable    ${PDU_SESSIONS}

UE PDU Session Release All UEs
    [Arguments]    ${ue_ids}=${TESTUE_IDS_SA}
    FOR    ${ue_id}    IN     @{ue_ids}
        wts_ue.UE PDU Session Release    ue_id=${ue_id}
    END
    ${PDU_SESSIONS}=      Create List    #  empty the PDU sessions
    Set Suite Variable    ${PDU_SESSIONS}

Deregister All UEs
    [Arguments]    ${ue_ids}=${TESTUE_IDS_SA}
    Log To Console    Deregister all UEs: ${ue_ids}
    FOR    ${ue_id}    IN     @{ue_ids}
        wts_ue.UE Deregister    ue_id=${ue_id}
    END

Perform Register Then Deregister For All UEs
    Trigger UE Register In Egate For All Ues
    Deregister All UEs
