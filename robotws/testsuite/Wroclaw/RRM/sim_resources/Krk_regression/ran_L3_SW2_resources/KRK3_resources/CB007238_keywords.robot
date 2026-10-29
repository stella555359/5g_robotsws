# Copyright (c) 2021 Nokia. All rights reserved.

*** Settings ***
Library         OperatingSystem
Library         String

Resource        ../../resources/external/Ulm/snapshot.robot
Resource        ../../resources/external/Ulm/ttitrace.robot
Resource        ../../resources/external/Ulm/btslog.robot
Resource        ../../resources/external/Ulm/core.robot
Resource        ../../resources/external/Ulm/gnb.robot
Resource        ../../resources/external/Ulm/reporting.robot
Resource        ../../resources/external/Ulm/testline.robot
Resource        ../../resources/external/Ulm/tcpdump.robot
Resource        ../../resources/external/Ulm/ute_workarounds.robot
Resource        ../../resources/external/Ulm/wts_ue.robot

*** Variables ***
${TL_STATE_COMMISSIONED}=            ${FALSE}
${TL_STATE_CONFIGURED}=              ${FALSE}
${TL_STATE_ON_AIR}=                  ${FALSE}
${TL_STATE_DUALCONNECTIVITY}=        ${FALSE}
${stopwatch_starttime}               stopped

${GLOBAL_RESET_TIMEOUT}=             900s

*** Keywords ***
Start Test Environment
    ${EXPECTED_TPUT_DL}=    Evaluate    ${TRF_MBPS}*1e6*${TRF_TOLERANCE}
    ${EXPECTED_TPUT_UL}=    Evaluate    ${TRF_MBPS}*1e6*${TRF_TOLERANCE}
    Set Suite Variable    ${EXPECTED_TPUT_DL}
    Set Suite Variable    ${EXPECTED_TPUT_UL}

    testline.Create Test Suite Log Folders
    ${TESTSUITE_LOG_DIR}=    testline.Get test suite log directory
    Set Suite Variable       ${TESTSUITE_LOG_DIR}

    ute_workarounds.UTE Cloud Workaround
    wts_ue.Kill WTS services

    ${NUMBER_OF_UES}=    Get Length     ${TESTUE_IDS}
    Set Suite Variable    ${NUMBER_OF_UES}

    Run keyword if    ${COLLECT_SYSLOG}    btslog.Start Btslog

    Verify Commissioning State
    ${status}    Run Keyword And Return Status    Verify if BTS Site is Ready

    Stop Watch Start
    Run Keyword If    ${status} != True or ${FORCE_REBOOT}    ute_workarounds.Bring Airphone TL to F1 up status    timeout=15min
    ${delta_time}    Stop Watch End
    Log to console    ----- Bring Airphone TL to F1 up status took ${delta_time} seconds -----

    Run keyword if    ${COLLECT_SYSLOG}    btslog.Stop Btslog    target_dir=${TESTSUITE_LOG_DIR}/startup/

End Test Environment
    Run keyword and Ignore error    wts_ue.Reset Wts Cfg
    Run keyword and Ignore error    snapshot.Collect snapshot from gNB    target_dir=${TESTSUITE_LOG_DIR}
    Run keyword and Ignore error    wts_ue.Collect sos report logs    target_dir=${TESTSUITE_LOG_DIR}

    Run keyword and Ignore error    wts_ue.Teardown Egate Connection for Airphone
    Run keyword and Ignore error    wts_ue.Teardown Edaemon Connection for Airphone

Start Testcase Environment
    ${testcase_dir}=     testline.Get test case log directory
    Set test variable    ${testcase_dir}

End Testcase Environment
    run keyword and ignore error    wts_ue.Save Current Egate Console Log

Start Logging
    Run keyword if    ${COLLECT_SYSLOG}    btslog.Start Btslog
    Run keyword if    ${COLLECT_SCTP}      tcpdump.Start TCPdump on gNB OAM VM    interface=any sctp

Stop Logging
    [Arguments]    ${label}
    Run keyword if    ${COLLECT_SCTP}        Run Keyword and Ignore Error    tcpdump.Stop TCPdump on gNB OAM VM
    ...                                                                    interface=any sctp     target_dir=${testcase_dir}/${label}
    Run keyword if    ${COLLECT_SYSLOG}      Run Keyword and Ignore Error    btslog.Stop Btslog    target_dir=${testcase_dir}/${label}

Stop Watch Start
    ${stopwatch_starttime}=     Get Current Date
    Set Suite Variable          ${stopwatch_starttime}

Stop Watch End
    Should Not Be Equal As Strings      ${stopwatch_starttime}    stopped    msg=Stop Watch Start keyword should be executed first
    ${stopwatch_stoptime}=              Get Current Date
    ${delta_time}=                      Subtract Date From Date     ${stopwatch_stoptime}   ${stopwatch_starttime}
    Set Suite Variable                  ${stopwatch_starttime}    stopped
    [Return]    ${delta_time}

Verify if BTS Site is Ready
    Should be true                ${TL_STATE_COMMISSIONED}    msg=gNB is not Commissioned
    ${oam_alias}=    connect.Setup OAM session
    gnb.Verify Single BTS is Configured     connection=${oam_alias}
    gnb.Verify Single Radio is Online       connection=${oam_alias}    ru_id=0
    gnb.Verify Single Cell is Configured    connection=${oam_alias}    cell_id=0
    Set Suite Variable            ${TL_STATE_CONFIGURED}            ${TRUE}
    [Teardown]    connect.Teardown OAM session    connection=${oam_alias}

Verify Commissioning State
    Set Suite Variable            ${TL_STATE_COMMISSIONED}            ${FALSE}
    admin.Connect To
    ${bts_status}                 admin.get_bts_statuses
    Should Contain Any            ${bts_status['proceduralState']}    OnAir    Commissioned    Configured    ignore_case=${TRUE}
    Set Suite Variable            ${TL_STATE_COMMISSIONED}            ${TRUE}
    [Teardown]    admin.Teardown

Verify On Air State
    Set Suite Variable            ${TL_STATE_ON_AIR}            ${FALSE}
    admin.Connect To
    ${bts_state}                  admin.Get Mrbts State
    BuiltIn.Log                   [INFO] BTS STATE : ${bts_state}    console=${P_console}
    Should Contain Any            ${bts_state}    OnAir    ignore_case=${TRUE}
    Set Suite Variable            ${TL_STATE_ON_AIR}            ${TRUE}
    [Teardown]    admin.Teardown

Start AP BIP Traces
    [Arguments]    ${collector}
    Run keyword IF    ${AP_L1BYPASS}    tcpdump.Start Airphone L1bypass BIP Traces    collector=${collector}
    ...               ELSE              tcpdump.Start Airphone BIP Traces    collector=${collector}

Stop AP BIP Traces
    [Arguments]    ${collector}
    Run keyword IF    ${AP_L1BYPASS}    tcpdump.Stop Airphone L1bypass BIP Traces    collector=${collector}
    ...               ELSE              tcpdump.Stop Airphone BIP Traces    collector=${collector}

Prepare and Verify Cell On Air
    Start Logging
    Run keyword if    ${COLLECT_GNB_BIP}    tcpdump.Start BIP Traces    collector=gnb-bip-tcpdump-cellsetup
    Run keyword if    ${COLLECT_AP_BIP}    Start AP BIP Traces    ap-bip-tcpdump-cellsetup
    Should be true                ${TL_STATE_CONFIGURED}    msg=gNB is not Configured
    ute_workarounds.Configure WTS for UTE Cloud Airphone TL    remove_logs=${True}
    ...                                                        cfg_file=${tl.core.cfg_filename}
    ...                                                        force_cu_type=${TEST_CU_TYPE}
    ute_workarounds.Verify Cell Setup

    wts_ue.Send Egate Command and verify output    cmd=sim_log_set flush
    ${core_alias}=    connect.Connect to Core
    FOR    ${idx}    IN RANGE    0    ${NUMBER_OF_UES}
        ${query}=         Catenate    Cell Setup completed for .CELL_ID:${TARGET_CELLS[${idx}]}.
        ${egate_log}=     ssh.execute    grep -i '${query}' ${tl.core.dir_path}/egate_console.log    connection=${core_alias}
        Should Contain    ${egate_log}    Cell Setup completed    ignore_case=True    msg=Cell ${TARGET_CELLS[${idx}]} Failed!
    END
    Verify On Air State
    [Teardown]    Run keywords    Run keyword if    ${COLLECT_GNB_BIP}    tcpdump.Stop BIP Traces    collector=gnb-bip-tcpdump-cellsetup
    ...           AND             Run keyword if    ${COLLECT_AP_BIP}    Stop AP BIP Traces    ap-bip-tcpdump-cellsetup
    ...           AND             Stop Logging    cellsetup

Perform 5G SA attach for all UEs
    [Arguments]    ${idx}=${0}    ${collect_log}=${TRUE}
    Run keyword if    ${collect_log}    Start Logging
    Run keyword if    ${COLLECT_GNB_BIP}    tcpdump.Start BIP Traces    collector=gnb-bip-tcpdump-sa-${idx}
    Run keyword if    ${COLLECT_AP_BIP}    Start AP BIP Traces    ap-bip-tcpdump-sa-${idx}
    Should be true                ${TL_STATE_ON_AIR}    msg=gNB is not On Air
    FOR    ${idy}    IN RANGE    0    ${NUMBER_OF_UES}
        wts_ue.Set traffic type                                ue_id=${TESTUESA_IDS[${idy}]}    pdu_id=1    trf_type=internal
        wts_ue.UE Register                                     ue_id=${TESTUESA_IDS[${idy}]}
        wts_ue.UE PDU Session Setup                            ue=${TESTUESA_IDS[${idy}]}    gw=1
    END
    Set Suite Variable            ${TL_STATE_DUALCONNECTIVITY}            ${TRUE}
    [Teardown]    Run keywords    Run keyword if    ${COLLECT_GNB_BIP}    tcpdump.Stop BIP Traces    collector=gnb-bip-tcpdump-sa-${idx}
    ...           AND             Run keyword if    ${COLLECT_AP_BIP}    Stop AP BIP Traces    ap-bip-tcpdump-sa-${idx}
    ...           AND             Run keyword if    ${collect_log}    Stop Logging    5G_attach_and_sa-${idx}

Perform SgNBAddition for all UEs
    [Arguments]    ${idx}=${0}    ${collect_log}=${TRUE}
    Run keyword if    ${collect_log}    Start Logging
    Run keyword if    ${COLLECT_GNB_BIP}    tcpdump.Start BIP Traces    collector=gnb-bip-tcpdump-sgnbaddition-${idx}
    Run keyword if    ${COLLECT_AP_BIP}    Start AP BIP Traces    ap-bip-tcpdump-sgnbaddition-${idx}
    Should be true                ${TL_STATE_ON_AIR}    msg=gNB is not On Air
    FOR    ${idy}    IN RANGE    0    ${NUMBER_OF_UES}
        wts_ue.Attach UE to LTE                                ${TESTUE_IDS[${idy}]}
        wts_ue.Trigger LTE-NR dual connectivity for bearers    ue_id=${TESTUE_IDS[${idy}]}    bearer_id=2    target_cells=${TARGET_CELLS[${idy}]}
    END
    Set Suite Variable            ${TL_STATE_DUALCONNECTIVITY}            ${TRUE}
    [Teardown]    Run keywords    Run keyword if    ${COLLECT_GNB_BIP}    tcpdump.Stop BIP Traces    collector=gnb-bip-tcpdump-sgnbaddition-${idx}
    ...           AND             Run keyword if    ${COLLECT_AP_BIP}    Stop AP BIP Traces    ap-bip-tcpdump-sgnbaddition-${idx}
    ...           AND             Run keyword if    ${collect_log}    Stop Logging    lte_attach_and_sgnb_addition-${idx}

Verify Random Access in Egate for all Ues
    Should be true                ${TL_STATE_DUALCONNECTIVITY}    msg=UE did not perform SgNBAddition
    wts_ue.Send Egate Command and verify output    cmd=sim_log_set flush
    ${core_alias}=    connect.Connect to Core
    FOR    ${idx}    IN RANGE    0    ${NUMBER_OF_UES}
        ${query}=    Catenate    UE${TESTUE_IDS[${idx}]}: Proxy .eNB 2 cell ${TARGET_CELLS[${idx}]}. reported successful RA
        ${egate_log}=     ssh.execute    grep -i '${query}' ${tl.core.dir_path}/egate_console.log    connection=${core_alias}
        Should Contain    ${egate_log}    reported successful RA    ignore_case=True    msg=RA on Cell ${TARGET_CELLS[${idx}]} Failed!
    END

Detach all UEs
    [Arguments]    ${idx}=${0}    ${collect_log}=${TRUE}
    Run keyword if    ${collect_log}    Start Logging
    Run keyword if    ${COLLECT_GNB_BIP}    tcpdump.Start BIP Traces        collector=gnb-bip-tcpdump-detach-${idx}
    Run keyword if    ${COLLECT_AP_BIP}    Start AP BIP Traces    ap-bip-tcpdump-detach-${idx}
    Should be true                ${TL_STATE_DUALCONNECTIVITY}    msg=UE is not Attached to gNB
    FOR    ${idy}    IN RANGE    0    ${NUMBER_OF_UES}
        wts_ue.Detach UE from 5G                               ue_id=${TESTUESA_IDS[${idy}]}    ue_detach_type=switch_off    device_type=ue
        wts_ue.Detach UE from LTE                              ${TESTUE_IDS[${idy}]}
    END
    Set Suite Variable            ${TL_STATE_DUALCONNECTIVITY}            ${FALSE}
    [Teardown]    Run keywords    Run keyword if    ${COLLECT_GNB_BIP}    tcpdump.Stop BIP Traces    collector=gnb-bip-tcpdump-detach-${idx}
    ...           AND             Run keyword if    ${COLLECT_AP_BIP}    Stop AP BIP Traces    ap-bip-tcpdump-detach-${idx}
    ...           AND             Run keyword if    ${collect_log}    Stop Logging    detach-${idx}

Verify UE Traffic
    [Arguments]    ${dl}=${False}    ${ul}=${False}    ${dl_mbps}=${TRF_MBPS}    ${ul_mbps}=${TRF_MBPS}    ${label}=${EMPTY}
    Start Logging
    Should be true                ${TL_STATE_DUALCONNECTIVITY}    msg=UE is not Attached to gNB
    ${bearer_id}          Set Variable    2    # in basic_setup.cfg: should match set_bearer id=2
    ${pdu_id}             Set Variable    1
    ${qfi}                Set Variable    1
    ${trf_id_dl_NSA}      Set Variable    4
    ${trf_id_ul_NSA}      Set Variable    3
    ${trf_id_dl_SA}       Set Variable    2
    ${trf_id_ul_SA}       Set Variable    1

    Run keyword if    ${COLLECT_GNB_BIP}           tcpdump.Start BIP Traces    collector=gnb-bip-tcpdump-${label}-traffic
    Run keyword if    ${COLLECT_AP_BIP}            Start AP BIP Traces    ap-bip-tcpdump-${label}-traffic
    Run keyword if    ${COLLECT_TTI_TRACE}         ttitrace.Start TTI Traces in Streaming mode
    Run keyword if    ${COLLECT_BH_PCAP}           tcpdump.Start Tcpdump on TestPc    eth3    collector=bh-eth3-tcpdump-${label}-traffic
    Run keyword if    ${COLLECT_WTS_PCAP}          tcpdump.Start Tcpdump on TestPc    eth4    collector=wts-eth4-tcpdump-${label}-traffic

    Start Traffic SA for All UEs     ${dl}    ${ul}    ${pdu_id}    ${qfi}    ${trf_id_dl_SA}    ${dl_mbps}    ${trf_id_ul_SA}    ${ul_mbps}
    Start Traffic NSA for All UEs    ${dl}    ${ul}    ${bearer_id}    ${trf_id_dl_NSA}    ${dl_mbps}    ${trf_id_ul_NSA}    ${ul_mbps}

    Sleep                        ${DURATION}s    reason=Traffic Duration
    Verify 5G did not drop
    Print All Traffic Result SA      ${dl}    ${ul}    ${pdu_id}    ${qfi}    ${trf_id_dl_SA}    ${trf_id_ul_SA}
    Print All Traffic Result NSA     ${dl}    ${ul}    ${bearer_id}    ${trf_id_dl_NSA}    ${trf_id_ul_NSA}

    Stop Traffic SA for All UEs    ${pdu_id}    ${qfi}    ${dl}    ${ul}    ${trf_id_dl_SA}    ${trf_id_ul_SA}

    [Teardown]    Run Keywords    Stop Traffic NSA for All UEs     ${dl}    ${ul}    ${bearer_id}    ${trf_id_dl_NSA}    ${trf_id_ul_NSA}
    ...           AND             Run keyword if    ${COLLECT_GNB_BIP}      tcpdump.Stop BIP Traces    collector=gnb-bip-tcpdump-${label}-traffic
    ...           AND             Run keyword if    ${COLLECT_AP_BIP}       Stop AP BIP Traces    ap-bip-tcpdump-${label}-traffic
    ...           AND             Run keyword if    ${COLLECT_TTI_TRACE}    ttitrace.Stop TTI Traces in Streaming mode
    ...                                                                     tti_trace_filename=tti_trace-${label}-traffic
    ...           AND             Run keyword if    ${COLLECT_BH_PCAP}      tcpdump.Stop Tcpdump on TestPc    eth3
    ...                                                                     collector=bh-eth3-tcpdump-${label}-traffic
    ...           AND             Run keyword if    ${COLLECT_WTS_PCAP}     tcpdump.Stop Tcpdump on TestPc    eth4
    ...                                                                     collector=wts-eth4-tcpdump-${label}-traffic
    ...           AND             Stop Logging    traffic-${label}

Start Traffic NSA for All UEs
    [Arguments]    ${dl}    ${ul}    ${bearer_id}    ${trf_id_dl_NSA}    ${dl_mbps}    ${trf_id_ul_NSA}    ${ul_mbps}
    Log to console    \n----- [Start Traffic NSA] DL:${dl} UL:${ul} ----
    Log to console      Expected Throughput. . . . . : ${TRF_MBPS} mbps
    Log to console      Passing Criteria . . . . . . : ${TRF_TOLERANCE}
    Log to console      Duration . . . . . . . . . . : ${DURATION}

    FOR    ${idx}    IN RANGE    0    ${NUMBER_OF_UES}
        Run keyword if    ${dl}   Start data traffic in egate    ${TESTUE_IDS[${idx}]}  dl  id=${bearer_id}
        ...                                                              trf_id=${trf_id_dl_NSA}  mbps=${dl_mbps}
        Run keyword if    ${ul}   Start data traffic in egate    ${TESTUE_IDS[${idx}]}  ul  id=${bearer_id}
        ...                                                              trf_id=${trf_id_ul_NSA}  mbps=${ul_mbps}
    END

Start Traffic SA for All UEs
    [Arguments]    ${dl}    ${ul}    ${pdu_id}    ${qfi}    ${trf_id_dl_SA}    ${dl_mbps}    ${trf_id_ul_SA}    ${ul_mbps}
    Log to console    \n----- [Start Traffic SA] DL:${dl} UL:${ul} ----
    Log to console      Expected Throughput. . . . . : ${TRF_MBPS} mbps
    Log to console      Passing Criteria . . . . . . : ${TRF_TOLERANCE}
    Log to console      Duration . . . . . . . . . . : ${DURATION}

    FOR    ${idx}    IN RANGE    0    ${NUMBER_OF_UES}
        Run keyword if    ${dl}   Start data traffic SA in egate    ${TESTUESA_IDS[${idx}]}  dl  pdu=${pdu_id}  qfi=${qfi}
        ...                                                                        trf_id=${trf_id_dl_SA}  mbps=${dl_mbps}
        Run keyword if    ${ul}   Start data traffic SA in egate    ${TESTUESA_IDS[${idx}]}  ul  pdu=${pdu_id}  qfi=${qfi}
        ...                                                                        trf_id=${trf_id_ul_SA}  mbps=${ul_mbps}
    END

Stop Traffic NSA for All UEs
    [Arguments]    ${dl}    ${ul}    ${bearer_id}    ${trf_id_dl_NSA}    ${trf_id_ul_NSA}
    FOR    ${idx}    IN RANGE    0    ${NUMBER_OF_UES}
        Run keyword if    ${dl}    Stop data traffic in egate    ${TESTUE_IDS[${idx}]}  dl  id=${bearer_id}  trf_id=${trf_id_dl_NSA}
        Run keyword if    ${ul}    Stop data traffic in egate    ${TESTUE_IDS[${idx}]}  ul  id=${bearer_id}  trf_id=${trf_id_ul_NSA}
    END
    Log to console    \n----- [Traffic NSA Stopped] ----\n

Stop Traffic SA for All UEs
    [Arguments]    ${dl}    ${ul}    ${pdu_id}    ${qfi}    ${trf_id_dl_SA}    ${trf_id_ul_SA}
    FOR    ${idx}    IN RANGE    0    ${NUMBER_OF_UES}
        Run keyword if    ${dl}    Stop data traffic SA in egate    ${TESTUESA_IDS[${idx}]}  dl  pdu=${pdu_id}  qfi=${qfi}
        ...                                                                                     trf_id=${trf_id_dl_SA}
        Run keyword if    ${ul}    Stop data traffic SA in egate    ${TESTUESA_IDS[${idx}]}  ul  pdu=${pdu_id}  qfi=${qfi}
        ...                                                                                     trf_id=${trf_id_ul_SA}
    END
    Log to console    ----- [Traffic SA Stopped] ----\n

Print All Traffic Result NSA
    Log to console    ----- [NSA TRAFFIC] ----\n
    [Arguments]    ${dl}    ${ul}    ${bearer_id}    ${trf_id_dl_NSA}    ${trf_id_ul_NSA}
    FOR    ${idx}    IN RANGE    0    ${NUMBER_OF_UES}
        Run keyword if    ${dl}    Print Average rate of packet loss from egate    ${TESTUE_IDS[${idx}]}  dir=dl
        ...                                                                        trf_id=${trf_id_dl_NSA}    id=${bearer_id}
        Run keyword if    ${dl}    Verify If Average Tput Is Correct  ${TESTUE_IDS[${idx}]}    dl    ${EXPECTED_TPUT_DL}    trf_id=${trf_id_dl_NSA}
        Run keyword if    ${ul}    Print Average rate of packet loss from egate    ${TESTUE_IDS[${idx}]}  dir=ul
        ...                                                                        trf_id=${trf_id_ul_NSA}    id=${bearer_id}
        Run keyword if    ${ul}    Verify If Average Tput Is Correct  ${TESTUE_IDS[${idx}]}    ul    ${EXPECTED_TPUT_UL}    trf_id=${trf_id_ul_NSA}
    END

Print All Traffic Result SA
    Log to console    ----- [SA TRAFFIC] ----\n
    [Arguments]    ${dl}    ${ul}    ${pdu_id}    ${qfi}    ${trf_id_dl_SA}    ${trf_id_ul_SA}
    FOR    ${idx}    IN RANGE    0    ${NUMBER_OF_UES}
        Run keyword if    ${dl}    Print Average rate of packet loss SA from egate    ${TESTUESA_IDS[${idx}]}  dir=dl
        ...                                                                        pdu=${pdu_id}  qfi=${qfi}  trf_id=${trf_id_dl_SA}
        Run keyword if    ${dl}    Verify If Average Tput SA Is Correct  ${TESTUESA_IDS[${idx}]}    dl    ${EXPECTED_TPUT_DL}
        ...                                                                     trf_id=${trf_id_dl_SA}
        Run keyword if    ${ul}    Print Average rate of packet loss SA from egate    ${TESTUESA_IDS[${idx}]}  dir=ul
        ...                                                                        pdu=${pdu_id}  qfi=${qfi}  trf_id=${trf_id_ul_SA}
        Run keyword if    ${ul}    Verify If Average Tput SA Is Correct  ${TESTUESA_IDS[${idx}]}    ul    ${EXPECTED_TPUT_UL}
        ...                                                                      trf_id=${trf_id_ul_SA}
    END

Print Average rate of packet loss from egate
    [Arguments]    ${ue_id}    ${dir}=bi    ${trf_id}=all    &{kwargs}
    ${packet_loss}=    Get Average rate of packet loss from egate    ${ue_id}    dir=${dir}    trf_id=${trf_id}    &{kwargs}
    ${packet_loss}=    Evaluate    ${packet_loss} * 100
    Log to console    Avg. rate of packet loss . . : [UE ${ue_id}] [${dir}] ${packet_loss} %

Print Average rate of packet loss SA from egate
    [Arguments]    ${ue_id}    ${dir}=bi    ${trf_id}=all    &{kwargs}
    ${packet_loss}=    Get Average rate of packet loss SA from egate    ${ue_id}    dir=${dir}    trf_id=${trf_id}    &{kwargs}
    ${packet_loss}=    Evaluate    ${packet_loss} * 100
    Log to console    Avg. rate of packet loss . . : [UE ${ue_id}] [${dir}] ${packet_loss} %

Get Average rate of packet loss from egate
    [Documentation]
    [Arguments]    ${ue_id}    ${dir}=bi    ${trf_id}=all    &{kwargs}
    ${dc_cell_group}=     Set Variable If    '${dir}' == 'dl'    scg    all
    ${output}=            wts_ue.Display bearer stats     ue_id=${ue_id}    direction=${dir}    trf_id=${trf_id}
    ...                                                   type=l3    dc_cell_group=${dc_cell_group}    &{kwargs}

    ${t_pkt_lost_raw}=    Get Lines Containing String    ${output}    Total packets lost
    ${t_pkt_rx_raw}=      Get Lines Containing String    ${output}    Total packets received

    ${t_pkt_lost_raw}=    Replace String    ${t_pkt_lost_raw}    Total packets lost        ${EMPTY}
    ${t_pkt_rx_raw}=      Replace String    ${t_pkt_rx_raw}    Total packets received    ${EMPTY}

    ${t_pkt_lost_raw}=    Strip String      ${t_pkt_lost_raw}
    ${t_pkt_rx_raw}=      Strip String      ${t_pkt_rx_raw}

    ${t_pkt_lost}=        Convert to Integer    ${t_pkt_lost_raw}
    ${t_pkt_rx}=          Convert to Integer    ${t_pkt_rx_raw}

    Should not be equal     ${t_pkt_rx}    0    msg=Total packet received is zero!
    ${packet_loss}=         Evaluate    ${t_pkt_lost} / ( ${t_pkt_rx} + ${t_pkt_lost} )

    [Return]    ${packet_loss}

Get Average rate of packet loss SA from egate
    [Documentation]
    [Arguments]    ${ue_id}    ${dir}=bi    ${trf_id}=all    &{kwargs}
    ${dc_cell_group}=     Set Variable If    '${dir}' == 'dl'    scg    all
    ${output}=            wts_ue.Display qfi stats     ue_id=${ue_id}    direction=${dir}    trf_id=${trf_id}
    ...                                                type=l3    dc_cell_group=${dc_cell_group}    &{kwargs}

    ${t_pkt_lost_raw}=    Get Regexp Matches    ${output}    Total packets dropped\\s+(\\d+)    1
    ${t_pkt_rx_raw}=      Get Regexp Matches    ${output}    Total packets received\\s+(\\d+)    1

    ${t_pkt_lost}=        Convert to Integer    ${t_pkt_lost_raw}[0]
    ${t_pkt_rx}=          Convert to Integer    ${t_pkt_rx_raw}[0]

    Should not be equal     ${t_pkt_rx}    0    msg=Total packet received is zero!
    ${packet_loss}=         Evaluate    ${t_pkt_lost} / ( ${t_pkt_rx} + ${t_pkt_lost} )

    [Return]    ${packet_loss}

Verify If Average Tput Is Correct
    [Arguments]  ${ue_id}
    ...          ${dir}
    ...          ${tp}
    ...          ${trf_id}
    ...          ${bearer_id}=2    &{kwargs}
    ${data_rate}=     wts_ue.Get Average Data Rate via Egate  ue_id=${ue_id}    id=${bearer_id}    dir=${dir}    trf_id=${trf_id}    &{kwargs}
    Log to console    Average data throughput. . . : [UE ${ue_id}] [${dir}] ${data_rate}
    Should Be True    ${data_rate} > ${tp}    msg=Throughput is incorrect!

Verify If Average Tput SA Is Correct
    [Arguments]  ${ue_id}    ${dir}    ${tp}    ${trf_id}    ${pdu_id}=1    ${qfi}=1    &{kwargs}
    ${data_rate}=     wts_ue.Get Average Data Rate SA via Egate  ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}
    ...                                                         dir=${dir}    trf_id=${trf_id}    &{kwargs}
    Log to console    Average data throughput. . . : [UE ${ue_id}] [${dir}] ${data_rate}
    Should Be True    ${data_rate} > ${tp}    msg=Throughput is incorrect!

Perform CU reset and Expect On Air
    Run keyword if    ${COLLECT_SYSLOG}    btslog.Start Btslog
    Verify On Air State

    ${bbmod_dist}=     Catenate    MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/CABINET-\\d+/BBMOD-1
    ${dist_names}=     gnb.Get distNames from gNB SCF    regex=${bbmod_dist}

    Stop Watch Start

    gnb.Perform gNB reset unit    dist_name=${dist_names[0]}    detailed_output=True    reset_type=Warm
    wts_ue.Reboot Airphone via Console

    gnb.Wait until all DUs up

    ${delta_time}=    Stop Watch End
    Log to Console    \n----- CU reset until all DUs up took: ${delta_time} seconds -----

    Wait until keyword succeeds     ${GLOBAL_RESET_TIMEOUT}    10s    Verify On Air State

    Should Be True    ${delta_time} < ${CU_RESET_KPI}    msg=CU Reset took longer than ${CU_RESET_KPI} seconds before getting ready!

    [Teardown]    Run keyword if    ${COLLECT_SYSLOG}    btslog.Stop Btslog    target_dir=${testcase_dir}/cu_reset/

Perform site reset and Expect On Air
    Run keyword if    ${COLLECT_SYSLOG}    btslog.Start Btslog
    Verify On Air State

    Stop Watch Start

    gnb.Perform gNB reboot
    Wait until keyword succeeds     ${GLOBAL_RESET_TIMEOUT}    10s    Verify On Air State

    ${delta_time}=    Stop Watch End
    Log to Console    \n----- Site reset until On Air took: ${delta_time} seconds -----
    Should Be True    ${delta_time} < ${SITE_RESET_KPI}    msg=Site Reset took longer than ${SITE_RESET_KPI} seconds to go on Air!

    [Teardown]    Run keyword if    ${COLLECT_SYSLOG}    btslog.Stop Btslog    target_dir=${testcase_dir}/site_reset/

Verify 5G did not drop
    ${status}    Run keyword and return status    Check Current Egate Console Status    Bearer-type change from SCG-split to MCG is successful
    Should Not Be True    ${status}    msg=Dual Connectivity Dropped!!!

Perform Attach then Detach for all UEs
    [Arguments]    ${idx}=${0}    ${collect_log}=${FALSE}
    Perform 5G SA attach for all UEs    idx=${idx}    collect_log=${collect_log}
    Perform SgNBAddition for all UEs    idx=${idx}    collect_log=${collect_log}
    Detach all UEs    idx=${idx}    collect_log=${collect_log}

Perform Call Setup KPI TC
    Verify On Air State
    Start Logging

    ${successful_callsetup_count}    Set Variable    ${0}
    FOR    ${idx}    IN RANGE    0    ${CALL_SETUP_TOTAL}
        ${status}    Run Keyword and return Status    Perform Attach then Detach for all UEs    idx=${idx}    collect_log=${FALSE}
        Sleep    20s    reason=Sometimes there is a slight delay in updating the UE status (after a De-register).
        ${successful_callsetup_count}    Run Keyword if    ${status}    Evaluate    ${successful_callsetup_count} + 1
        ...    ELSE                      Set Variable    ${successful_callsetup_count}
    END
    Log to console    Call Setup Success rate: ${successful_callsetup_count} of ${CALL_SETUP_TOTAL}\n
    Should be true    ${successful_callsetup_count} >= ${CALL_SETUP_KPI}    msg=KPI Fail: suucessful callsetup should be ${CALL_SETUP_KPI} or more

    [Teardown]    Stop Logging    callsetup_kpi
