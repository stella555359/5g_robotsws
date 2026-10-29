*** Settings ***
Documentation    CB011117 case
Resource          ../../CUDU_L2/common_setup_teardown.robot


*** Keywords ***
A2 Triggered Pcell Change
    [Arguments]    ${UE_ID}    ${meas_id}    ${SCell2_rsrp}=90    ${SCell3_rsrp}=90
    Log To Console    start A2 Pcell Change ...
    ${command}    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A2 srsrp_nr=40 srsrq_nr=66 scell=1 scell_rsrp=90
    ...    scell_rsrq=115 scell=2 scell_rsrp=${SCell2_rsrp}
    ...    scell_rsrq=115 scell=3 scell_rsrp=${SCell3_rsrp} scell_rsrq=115 scell=4 scell_rsrp=90 scell_rsrq=115
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes

SA Multi UE Scell A1 Addition
    [Arguments]    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}    ${a1Threshold}    ${cc_num}
    FOR    ${ue_id}    ${pcell_id}    ${scell_physicalid}    IN ZIP    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}
        Trigger A1 Scell Addition    ${ue_id}    ${a1Threshold}    ${pcell_id}
        Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${scell_physicalid}    ${cc_num}
    END

StartAPBip
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${AP.ip} rm /ffs/run/tcpdumpL2L1_filtering_off*
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${SCRIPT_PATH}/BIP/bip_ASIL_2ABIO.sh ${AP.username}@${AP.ip}:/user/toor4nsn/
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${SCRIPT_PATH}/BIP/lfs-nw_switch-mirror-tool.sh ${AP.username}@${AP.ip}:/usr/bin
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${AP.ip} chmod 777 /user/toor4nsn/bip_ASIL_2ABIO.sh
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${AP.ip} chmod 777 /usr/bin/lfs-nw_switch-mirror-tool.sh
    SSH.Connect To    ${AP.ip}    ${AP.username}    ${AP.password}    alias=BIP_AP
    SSH.Send Command    command=sh /user/toor4nsn/bip_ASIL_2ABIO.sh 1>/dev/null 2>&1 &    connection=BIP_AP
    Set Suite Variable    ${BIP_CMD}           tcpdump -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    tcpdumpL2L1_filtering_off    ${BIP_CMD}    BIP_AP
    Log To Console    INFO:bip start success...
    Log To Console    INFO:to stop AP BIP log by "StopAPBip"

StopAPBip
    Log To Console    INFO:Stop AP BIP log...
    ${ret}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success
    ...    tcpdumpL2L1_filtering_off    ${BIP_CMD}    BIP_AP
    run keyword if    "${ret}"=="False"    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success
    ...    tcpdumpL2L1_filtering_off    ${BIP_CMD}    BIP_AP    kill_para=9
    Log To Console    INFO:to collect AP BIP log by "CollectAPBip"
CollectAPBip
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory    ${log_dir}
    Log To Console    copy bip files to ${log_dir}...
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/*.pcap* ${log_dir}
    ${count}    OperatingSystem.Count Items In Directory    ${log_dir}    pattern=*.pcap*
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${AP.ip} rm /ffs/run/tcpdumpL2L1_filtering_off*
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${AP.ip} ll /ffs/run/
    Run    sshpass -p ${AP.password} scp toor4nsn@192.168.200.1:/ffs/run/tcpdumpL2L1_filtering* ${log_dir}
    Run    ls -1 ${log_dir}
    Run    mergecap -a -w ${log_dir}/tcpdumpL2L1_filtering_off_AP.pcap ${log_dir}/tcpdumpL2L1_filtering_off*
    ${bip_file}=    Set Variable    ${log_dir}/tcpdumpL2L1_filtering_off_AP.pcap
    OperatingSystem.File Should Exist    ${bip_file}
    Log To Console    AP bip log:${bip_file}

Override Pcell RI To 4layer And Scells 2layer Per CC Num
    [Arguments]    ${ue_id}=1    ${cc_num}=5
    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3
    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=0
    FOR    ${scell_id}    IN RANGE    1    ${cc_num}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=2 scell=${scell_id}
    END

Override All UE RI For TDD Pcell 4Layer
    [Arguments]    ${ue_id_list}
    FOR    ${ue_id}    IN    @{ue_id_list}
    Override Pcell RI To 4layer And Scells 2layer Per CC Num    ${ue_id}
    END

Clear Egate
    Run Keyword And Ignore Error    Stop Edaemon Egate

Check Traffic On Pcell and Scell
    [Arguments]    ${UE_ID}=1    ${Scell_num}=1    ${dl_tp_threshold}=700
    Set Test Variable    ${scell_total_tp}    0
    Set Test Variable    ${total_dl_tp}    0
    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    FOR    ${index}    IN RANGE    1    ${Scell_num}+1
        ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=${index}
        ${scell_total_tp}    Evaluate    ${scell_total_tp}+${scell_dl_tp}
    END
    ${total_dl_tp}    Evaluate    ${scell_total_tp}+${pcell_dl_tp}
    Run Keyword And Continue On Failure    Should Be True    ${total_dl_tp}>=${dl_tp_threshold}
Check Traffic On Pcell and Scell mue
    [Arguments]    ${UE_ID}    ${Scell_num}=1    ${dl_tp_threshold}=130
    Set Test Variable    ${scell_total_tp}    0
    Set Test Variable    ${total_dl_tp}    0
    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    FOR    ${index}    IN RANGE    1    ${Scell_num}+1
        ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=${index}
        ${scell_total_tp}    Evaluate    ${scell_total_tp}+${scell_dl_tp}
    END
    ${total_dl_tp}    Evaluate    ${scell_total_tp}+${pcell_dl_tp}
    Run Keyword And Continue On Failure    Should Be True    ${total_dl_tp}>=${dl_tp_threshold}
Stop DL Traffic
    [Arguments]    ${UE_ID}    ${trf_id_num}
    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu=1 qfi=1 dir=dl trf_id\=${index}
    END

Stop UL Traffic
    [Arguments]    ${UE_ID}    ${trf_id_num}
    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${UE_ID} pdu=1 qfi=1 dir=ul trf_id\=${index}
    END

Start DL Traffic
    [Arguments]    ${UE_ID}    ${trf_id_num}
    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=175 dir=dl
    END
    Sleep   5s    reason=Wait scell activate successfully ...

Start UL Traffic
    [Arguments]    ${UE_ID}    ${trf_id_num}
    FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=50 dir=ul
    END
    Sleep   5s    reason=Start UL traffic ...

Wait Untill Scell Activated
    [Arguments]    ${Scell_num}=3    ${activate_times}=1
    Wait Until Keyword Succeeds    240s    5s    Check Scell Activated    ${Scell_num}    ${activate_times}

Wait Untill Scell Deactivated
    [Arguments]    ${Scell_num}=3    ${activate_times}=1
    Wait Until Keyword Succeeds    60s    5s    Check Scell Deactivated    ${Scell_num}    ${activate_times}

Check Scell Activated
    [Arguments]    ${Scell_num}=3    ${activate_times}=1
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellAct.log
    FOR    ${index}    IN RANGE    1    ${Scell_num}+1
        Check Egate Log With Message     ${egate_console_file}    SCellIndex ${index} activated successfully at airphone    ${activate_times}
    END

Check Scell Deactivated
    [Arguments]    ${Scell_num}    ${activate_times}
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    OperatingSystem.Run    mv ${TEST_LOG_DIRECTORY}/egate_console.log ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
    ${egate_console_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/egate_console-scellDeact.log
    FOR    ${index}    IN RANGE    1    ${Scell_num}+1
        Check Egate Log With Message     ${egate_console_file}    SCellIndex ${index} deactivated successfully at airphone    ${activate_times}
    END

Check Whether UE In CA Mode
    [Arguments]    ${UE_ID}=1    ${ca_num}=1
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=${UE_ID} type=pdsch scell=0-31    pass_regexp=EGATE
    Log    ${output}
    Should Contain X Times    ${output}    CellIndex-    ${ca_num}   msg=UE is not in ${ca_num} CC mode
CUDU_L2 Capture And Decode TTitrace For 2GNB
    [Arguments]    ${log_id}=1    ${duration}=5
    Start Ttitrace With Streaming Mode For 2GNB
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Start Ttitrace With Streaming Mode For 2GNB
    [Arguments]    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch all cells
    ...    Start Ttitrace With Streaming Mode
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    ${executor}=  Create Dictionary
    ...  host=10.0.1.2
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i eth3 udp and dst 10.0.1.1 and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
    ...  webservice=${executor}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
   ${executor2}=  Create Dictionary
    ...  host=10.0.1.3
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
    ...  webservice=${executor2}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...
Check UL And DL DTX From Ttitrace For 2GNB
    [Arguments]    ${log_id}    ${duration}
    CUDU_L2 Capture And Decode TTitrace For 2GNB   ${log_id}    ${duration}
    CUDU_L2 Check DTXNACK Rate    ${log_id}
    CUDU_L2 Check UL DTXCRC Rate    ${log_id}
