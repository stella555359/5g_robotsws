# #*** Settings ***
# #Documentation
# #...   author: Shi Ming
# #...   contact: ming.shi@nokia-sbell.com
# #...   squad group: SG_03
# #...   feature : 5GC000749-W
# #
# #Force Tags    CA_5G_RRM
# #...    PY36
# #Suite Setup    Run Keywords
# #...            robot_common_operations.Common Suite Setup    AND
# #...            Run Keyword    Common Suite Setup for COAM
# #
# #Suite Teardown    Common Suite Teardown for COAM    gnb_list=${gnb_list}
# ##Suite Teardown    Run Keywords    remove object NRADJGNB and XNLINK for 2 gnbs
# #
# #Resource    ./Resources/5GC000749_common_keywords.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
# #Variables   ./Resources/5GC000749_variables.py
# ##Library     taf.selenium.sbts      WITH NAME       selenium_coam
# #
# #
# #*** Variables ***
# ###change the parameter actGnbInitRlf as below have been done at SCF importing
# #${nglogname1_1}    749W01_Mate20NG01.pcap
# #${nglogname1_2}    749W01_Mate20NG02.pcap
# #${nglogname1_3}    749W01_Mate20NG03.pcap
# #${nglogname1_4}    749W01_gNB2HO.pcap
# #${nglogname2}    749W02_Mate20NG01.pcap
# #${nglogname2_342}    749W02_342_Mate20NG01.pcap
# #${nglogname2_343}    749W02_343_Mate20NG01.pcap
# #
# #${enblogname1}    749W01_Mate20enb01.pcap
# #${enblogname2}    749W02_Mate20enb01.pcap
# #${enblogname2_342}    749W02_342_Mate20enb01.pcap
# #${enblogname2_343}    749W02_343_Mate20enb01.pcap
# #
# #${phone_number_TL343_1}    13032993580
# #${phone_number_TL343_2}    13032995967
# #
# #${a5Threshold1SsbRsrp}    50
# #${different_redirFreqEutra_value}    1900
# #@{diffTL_enb_ID}    36721    38221    911    5395    342
# #${epc_log_path}    /opt/workspace/CIT/Master/Case_Logs/
# #${TS_LOG_PATH_BASE}    /opt/workspace/CIT/Master/Case_Logs
# ##${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
# #${SCF_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
# #${SCF_file_name}    Configuration_scf_GNB1_CB008698.xml
# #${SCF_file_name_2}    Configuration_scf_GNB2_CB008698.xml
# #${SCF_file_name_342}    Configuration_scf_gnb342_749.xml
# #${enb_path}    /tmp
# #${ngap_filter}    ngap
# #${xnap_filter}    xnap
# #${s1ap_filter}    s1ap
# #${index0}    0
# #${index1}    1
# #${index2}    2
# #
# #${duration}    150
# #${ue_type}    huawei
# #${dl_throughput}    50M
# #
# #${5GRU0_ANT9}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #int
# #${5GRU0_ANT10}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #int
# #
# ###PA
# #@{PA_value}    ${35}    ${50}    ${30}    ${0}     ${63}     ${43}  #int list
# #${att_ipaddr}               ${tl.attenuator[0].ip_addr}
# #${att_api_port}             ${tl.attenuator[0].port}
# #@{att_connection_port}      ${5GRU0_ANT9}    ${5GRU0_ANT10}     #int list
# #${HBTE_max_value}           ${120}
# #${vendor}                    ${tl.attenuator[0].vendor}
# #${interface1}    any
# #
# ### filter command for coverting PDML
# #${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap or s1ap\"  -T pdml
# #
# #${att_port_1_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# #${att_port_2_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
# #${att_port_3_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
# #${att_port_4_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
# #${att_port_5_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
# #${att_port_6_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
# #${att_port_7_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
# #${att_port_8_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
# #
# #${att_ipaddr_HBTE}    ${tl.attenuator[0].ip_addr}
# ##${att_ipaddr_36721}    ${tl.attenuator[0].ip_addr}
# ##${att_ipaddr_911}      ${tl.attenuator[0].ip_addr}
# ##${att_ipaddr_38221}    ${tl.attenuator[0].ip_addr}
# ##${att_port_1_36721}     ${tl.attenuator[0].attenuator_ports[1]}
# ##${att_port_2_36721}     ${tl.attenuator[0].attenuator_ports[2]}
# ##${att_port_3_36721}     ${tl.attenuator[0].attenuator_ports[3]}
# ##${att_port_4_36721}     ${tl.attenuator[0].attenuator_ports[4]}
# ##${att_port_5_36721}     ${tl.attenuator[0].attenuator_ports[5]}
# ##${att_port_6_36721}     ${tl.attenuator[0].attenuator_ports[6]}
# ##${att_port_7_36721}     ${tl.attenuator[0].attenuator_ports[7]}
# ##${att_port_8_36721}     ${tl.attenuator[0].attenuator_ports[8]}
# #
# #
# #*** Test Cases ***
# #[1]5GC000749-W_001_Success_voice_call_fallback_LTE_with_redirect_from_5G_after_HO_via_Xn_interface_with_5GC_capability_check
# #    [Documentation]
# #    ...    This user scenario describes the success procedure of voice fallback to LTE with redirection
# #    ...    from 5G cell after Xn-based HO(5GC000704 feature).
# #    [Tags]     5GC000749-W    CIT_TRUNK    CRT_22R3    CIT_22R4
# #    [Timeout]    1 hour
# #    [Setup]    robot_common_operations.Common Case Setup
# #    Reset TopYong Attenuation
# #    setup for 749_W01
# #    temopary modify NIDD parameter
# #    lock gnb1 cell2
# #    lock gnb1 cell
# #    Setup for SA Env cell on-air on gnb2
# #    locked LTE cell
# #    Check UE device exist
# #    Prepare env with UE
# #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname1_1}    interface=${interface1}
# #    Check phone attach successfully on SA env    gnb_index=1
# #    sleep    5s
# #    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1_1}
# #    Analysis wireshark log for case 749W01_01
# #    unlock gnb1 cell
# #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname1_4}    interface=${interface1}
# #    Start Capture Wireshark Logs on gNB    nglogname=${nglogname1_2}    interface=${interface1}
# #    Adjust TopYong Attenuation for 749
# #    sleep    10s
# #    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1_2}
# #    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1_4}
# #    Analysis wireshark log for case 749W01_02    logname=${nglogname1_2}
# #    Start Capture Wireshark Logs on gNB    nglogname=${nglogname1_3}    interface=${interface1}
# #    Enb start capture wireshark log    filename=${enblogname1}
# #    unlocked LTE cell
# #    Start 749 data transfer    dl_throughput=${dl_throughput}
# #    sleep    10s
# #    Make a voice call on UE
# #    sleep    10s
# #    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1_3}
# #    Enb stop and Save classical Logs    filename=${enblogname1}
# #    Analysis wireshark log for case 749W01_03
# #    Analysis wireshark log on enb for case 749W01_01
# #    [Teardown]    Run Keywords
# #    ...    Common Case Teardown for COAM    gnb_list=${gnb_list}    AND
# #    ...    sleep    1m    AND    Huawei Mate X20 UE detach    AND
# #    ...    Run Keyword And Ignore Error    unlocked LTE cell   AND
# #    ...    unlock gnb1 cell2    AND
# #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1_1}    AND
# #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1_4}    AND
# #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1_2}    AND
# #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1_3}    AND
# #    ...    Enb stop and Save classical Logs    filename=${enblogname1}    AND
# #    ...    Recover TopYong Attenuation    AND
# #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# #
# #*** Keywords ***
# #Start To Capture gNB1 wireshark Logs and make sure success
# #    [Arguments]     ${nglogname}    ${connection}    ${interface}
# #    gNB connections
# ##    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${nglogname}   connection=${connection}
# #    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=${connection}
# #    sleep     3s
# #    csn.download_file   ${gnb_path}/${nglogname}   ${epc_log_path}${nglogname}   connection=${connection}
# #    ${logfile_zie}     Get File Size     ${epc_log_path}${nglogname}
# #    Log to console   \logfile_zie:${nglogname}:${logfile_zie}
# #    Run Keyword If	    '${logfile_zie}' < '50'     csn.send command    command=killall tcpdump     connection=${connection}
# #    Should be True     '${logfile_zie}' > '50'
# #
# #Start To Capture gNB2 wireshark Logs and make sure success
# #    [Arguments]     ${nglogname}    ${connection}    ${interface}
# #    gnb2 connection
# ##    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${nglogname}   connection=${connection}
# #    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=${connection}
# #    sleep     3s
# #    csn.download_file   ${gnb_path}/${nglogname}   ${epc_log_path}${nglogname}   connection=${connection}
# #    ${logfile_zie}     Get File Size     ${epc_log_path}${nglogname}
# #    Log to console   \logfile_zie:${nglogname}:${logfile_zie}
# #    Run Keyword If	    '${logfile_zie}' < '50'     csn.send command    command=killall tcpdump     connection=${connection}
# #    Should be True     '${logfile_zie}' > '50'
# #
# #lock gnb1 cell
# #    run keyword if    '${enb_instance}'=='36721'    Lock_gnb2_Cell    url=${WEBUI_COAM}    bts_host=${asik_addr}
# #    run keyword if    '${enb_instance}'=='38221'    Lock_gnb2_Cell    url=${WEBUI_COAM}    bts_host=${asik_addr}
# #    run keyword if    '${enb_instance}'=='911'      Lock_gnb2_Cell    url=${WEBUI_COAM}    bts_host=${asik_addr}
# #
# #unlock gnb1 cell
# #    run keyword if    '${enb_instance}'=='36721'    unLock_gnb2_Cell    url=${WEBUI_COAM}    bts_host=${asik_addr}
# #    run keyword if    '${enb_instance}'=='38221'    unLock_gnb2_Cell    url=${WEBUI_COAM}    bts_host=${asik_addr}
# #    run keyword if    '${enb_instance}'=='911'      unLock_gnb2_Cell    url=${WEBUI_COAM}    bts_host=${asik_addr}
# #
# #setup for 749_W01
# ##    set and check value of parameter administrativeState on MO SNSSAI    value=Locked    new_value=Locked
# ##    set and check value of parameter administrativeState of gnb2 on MO SNSSAI    value=Locked    new_value=Locked
# #    Prepare env with UE
# #    Setup for SA Env cell on-air
# #    checking type of system board on gnb1
# #    checking type of system board on gnb2
# #    get init value of parameter redirFreqEutra
# ##    Recover TopYong Attenuation
# #
# #setup for 749_W02
# #    TL342 and TL343 UE prepare
# #    TL342 and TL343 Setup for SA Env cell on-air
# #    check type of system board on TL342 and TL343
# #    lock TL342 and TL343 gnb2 cell
# #
# #setup for 749_W02_new
# #    set and check value of parameter administrativeState on MO SNSSAI    value=Locked    new_value=Locked
# #    set and check value of parameter administrativeState of gnb2 on MO SNSSAI    value=Locked    new_value=Locked
# #    Prepare env with UEs
# #    Set automatic rotation on UEs
# #    Setup for SA Env cell on-air
# #    checking type of system board on gnb1
# #    get init value of parameter redirFreqEutra
# #    Lock_gnb2_Cell
# #    lock gnb1 cell2
# #
# #pre-check paramater for 749W01
# #    check value of parameter actRedirect
# #    check value of parameter actNormVCfallback
# #    check value of parameter voiceFBmode
# #    check value of parameter redirRat
# #    check value of parameter redirFreqEutra
# #    check value of parameter a3MeasEnabled    value=rsrp
# #
# #Analysis wireshark log for case 749W01_01
# #    Check RedirectionVoiceFallback is possible    logname=${nglogname1_1}
# #
# #check HO successfully
# #    check UE attached
# #
# #Analysis wireshark log for case 749W01_02
# #    [Arguments]    ${logname}
# #    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
# #    ...    command_template=${command_template_with_Y}    alias=test6
# #    ${Code0_0} =    Catenate    xnap.XnAP_PDU == 0 and xnap.procedureCode == 0
# #    Log    check Handoverrequest
# #    ${Code0_0_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    filter_expression=${Code0_0}    pcap_parser=test6
# #    should be equal    ${Code0_0_status}    ${True}
# #
# #    ${Code1_0} =    Catenate    xnap.XnAP_PDU == 1 and xnap.procedureCode == 0
# #    Log    check Handovercomplete
# #    ${Code1_0_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    filter_expression=${Code1_0}    pcap_parser=test6
# #    should be equal    ${Code1_0_status}    ${True}
# #
# #Analysis wireshark log for case 749W01_03
# ##    Check RedirectionVoiceFallback is possible    logname=${nglogname1_3}
# #    Check support 5QI value and related message flow for call reject    logname=${nglogname1_3}
# #
# #Analysis wireshark log on enb for case 749W01_01
# #    Check voice falls back to lte to the end of sign    logname=${enblogname1}
# #
# #pre-check paramater for 749W02
# #    check value of parameter actRedirect
# #    check value of parameter actNormVCfallback
# #    check value of parameter voiceFBmode
# #    check value of parameter redirRat
# #    check value of parameter redirFreqEutra
# ##    set value of parameter administrativeState on gnb2 cell    new_value=Locked    despite_errors=True
# #    Lock_gnb2_Cell
# #
# #Analysis wireshark log for case 749W02_01
# #    Check RedirectionVoiceFallback is possible    logname=${nglogname2_342}
# #    Check support 5QI value and related message flow for call reject    logname=${nglogname2_342}
# #    Check RedirectionVoiceFallback is possible    logname=${nglogname2_343}
# #    Check support 5QI value and related message flow for call reject    logname=${nglogname2_343}
# #
# #Analysis wireshark log on enb for case 749W02_01
# #    Check voice falls back to lte to the end of sign    logname=${enblogname2_342}
# #    Check voice falls back to lte to the end of sign    logname=${enblogname2_343}
# #
# #Analysis wireshark log for case 749W02_01_new
# #    Check support 5QI value and related message flow for call reject between UE to UE    logname=${nglogname2}
# #
# #Check support 5QI value and related message flow for call reject between UE to UE
# #    [Arguments]    ${logname}
# #    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
# #
# #    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
# #    Log    check PDUSessionResourceModifyRequest
# #    ${Code26_0_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code26_0}
# #    should be equal    ${Code26_0_status}    ${True}
# #    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code26_0}
# #    ${ngap_fiveQI}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
# #    ...    xpath=.//ngap.fiveQI
# #    Should Be Equal    ${ngap_fiveQI[0]}    1
# #    Should Be Equal    ${ngap_fiveQI[1]}    1
# #
# #    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
# #    Log    check PDUSessionResourceModifyResponse
# #    ${Code26_1_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code26_1}
# #    should be equal    ${Code26_1_status}    ${True}
# #    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code26_1}
# #    ${ngap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
# #    ...    xpath=.//ngap.radioNetwork
# #    Should Be Equal    ${ngap_radioNetwork[0]}    36
# #    Should Be Equal    ${ngap_radioNetwork[1]}    36
# #
# #    ${Code42} =    Catenate    ngap.procedureCode == 42
# #    Log    check UEContextReleaseRequest
# #    ${Code42_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code42}
# #    should be equal    ${Code42_status}    ${True}
# #    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code42}
# #    ${ngap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
# #    ...    xpath=.//ngap.radioNetwork
# #    run keyword if    '${749A08_01_status}'=='False'    Should Contain    ${ngap_radioNetwork}    36
# #    run keyword if    '${749A08_01_status}'=='True'    Should Contain    ${ngap_radioNetwork}    36
# #
# #    ${Code41} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
# #    Log    check UEContextReleaseComplete
# #    ${Code41_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code41}
# #    should be equal    ${Code41_status}    ${True}
# #
# #Analysis wireshark log on enb for case 749W02_01_new
# #    Check voice falls back to lte to the end of sign_new    logname=${enblogname2}
# #
# #Check voice falls back to lte to the end of sign_new
# #    [Arguments]    ${logname}
# #    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
# #
# #    ${Code0_12} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 12
# #    Log    check InitialUEMessage
# #    ${Code0_12_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code0_12}
# #    should be equal    ${Code0_12_status}    ${True}
# #
# #    ${Code0_9} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 9
# #    Log    check InitialContextSetupRequest
# #    ${Code0_9_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code0_9}
# #    should be equal    ${Code0_9_status}    ${True}
# #
# #    ${Code0_5} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 5 and nas_eps.nas_msg_esm_type == 0xc5
# #    Log    check E_RABSetupRequest
# #    ${Code0_5_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code0_5}
# #    should be equal    ${Code0_5_status}    ${True}
# #    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code0_5}
# ##    ${s1ap_qCI} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
# ##    ...    xpath=.//s1ap.qCI
# ##    Should Be Equal    ${s1ap_qCI[0]}    1
# #
# #    ${Code0_13_c6} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xc6
# #    Log    check UplinkNASTransport
# #    ${Code0_13_c6_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code0_13_c6}
# #    should be equal    ${Code0_13_c6_status}    ${True}
# #
# #    ${Code0_7} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 7
# #    Log    check E_RABReleaseCommand
# #    ${Code0_7_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code0_7}
# #    should be equal    ${Code0_7_status}    ${True}
# #    ${filtered_packets}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code0_7}
# #    ${s1ap_nas} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
# #    ...    xpath=.//s1ap.nas
# #    Should Be Equal    ${s1ap_nas[0]}    0
# #    Should Be Equal    ${s1ap_nas[1]}    0
# #
# #    ${Code0_13_ce} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xce
# #    Log    check UplinkNASTransport
# #    ${Code0_13_ce_status} =    run_keyword_and_return_status
# #    ...    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Code0_13_ce}
# #    should be equal    ${Code0_13_ce_status}    ${True}
# #
# #remove object NRADJGNB and XNLINK for 2 gnbs
# #    remove object NRADJGNB and XNLINK
# #    remove object NRADJGNB and XNLINK    WEBUI_COAM=${WEBUI2_COAM}
# #
# #Start 749 data transfer
# #    [Arguments]    ${dl_throughput}    ${ue_index}=${0}
# #    log to console    \n *** Start DL transmission
# #    Start DL date transfer    dl_throughput=${dl_throughput}    ue_index=${ue_index}
# #
# #Start DL date transfer
# #    [Arguments]    ${dl_throughput}    ${ue_index}=${0}    ${iperf_port}=default
# #    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${dl_throughput}
# #    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}
# #
# #Reset TopYong Attenuation
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Recover HBTE Adjust gNB_eNB_RU Attenuation      #36721
# #    ...    gnb1_cell1_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Recover HBTE Adjust gNB_eNB_RU Attenuation      #38221
# #    ...    gnb1_cell1_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Recover HBTE Adjust gNB_eNB_RU Attenuation      #911
# #    ...    gnb1_cell1_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
# #
# #Recover TopYong Attenuation
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Recover HBTE Adjust gNB_eNB_RU Attenuation      #36721
# #    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Recover HBTE Adjust gNB_eNB_RU Attenuation      #38221
# #    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Recover HBTE Adjust gNB_eNB_RU Attenuation      #911
# #    ...    gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    gnb2_cell1_value=${0}    enb_cell1_value=${0}
# #
# #Adjust TopYong Attenuation for 749
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust gnb_enb the attenuation value for HBTE    #36721
# #    ...    gnb1_cell1_value=${0}    gnb2_cell1_value=${30}    enb_cell1_value=${0}
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust gnb_enb the attenuation value for HBTE    #38221
# #    ...    gnb1_cell1_value=${0}    gnb2_cell1_value=${35}    enb_cell1_value=${0}
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust gnb_enb the attenuation value for HBTE    #911
# #    ...    gnb1_cell1_value=${0}    gnb2_cell1_value=${45}    enb_cell1_value=${0}
# #
# #Adjust the attenuation value for HBTE
# #    [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}
# #    [Documentation]    Auther:cris.cai@nokia-sbell.com
# #    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
# #    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
# #    ...                if connect on local plz disconnect firstly
# #    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
# #    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
# #    att.set_attenuation     port=${5GRU0_ANT9}    value=${value_1}
# #    att.set_attenuation     port=${5GRU0_ANT10}    value=${value_1}
# #    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT9}
# #    should be equal    ${value_port1}    ${value_1}
# #    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT10}
# #    should be equal    ${value_port2}    ${value_1}
# #
# #Adjust gnb_enb the attenuation value for HBTE
# #    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
# ##    Run Keyword If     '${enb_instance}'=='@{diffTL_enb_ID}[0]'
# #    Adjust the tl HBTE attenuation value    #tl=@{diffTL_enb_ID}[0]
# #    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
# #    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
# ##    ...    ELSE    sleep    1s
# #
# #Recover HBTE Adjust gNB_eNB_RU Attenuation
# #    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
# ##    Run Keyword If     '${enb_instance}'=='@{diffTL_enb_ID}[0]'
# ##    Run Keyword If     '${enb_instance}'=='@{diffTL_enb_ID}[1]'    sleep    1s
# #    Adjust the tl HBTE attenuation value    #tl=@{diffTL_enb_ID}[0]
# #    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
# #    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
# ##    ...    ELSE    sleep    1s
# #
# ##Adjust the tl HBTE attenuation value
# ##    [Arguments]     ${tl}=${tl}    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
# ##    ...    ${enb_cell1_value}=${127}
# ##    ####create cell list#####
# ##    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_${tl}}     ${att_port_2_${tl}}
# ##    @{att_ports_gnb1_cell2}    Create List    ${att_port_3_${tl}}     ${att_port_4_${tl}}
# ##    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_${tl}}     ${att_port_6_${tl}}
# ##    @{att_ports_enb_cell1}     Create List    ${att_port_7_${tl}}     ${att_port_8_${tl}}
# ##
# ##    ###create value list####
# ##    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
# ##    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
# ##    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
# ##    @{values_enb_cell1}     Create List    ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}
# ##
# ##    ###Adjust the HBTE attenuation value###
# ##    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
# ##    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
# ##    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
# ##    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
# ##    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
# ##    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
# ##    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
# ##    ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
# #
# #Adjust the tl HBTE attenuation value
# #    [Arguments]     ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
# #    ####create cell list#####
# #    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_HBTE}     ${att_port_2_HBTE}
# #    @{att_ports_gnb1_cell2}    Create List    ${att_port_3_HBTE}     ${att_port_4_HBTE}
# #    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_HBTE}     ${att_port_6_HBTE}
# #    @{att_ports_enb_cell1}     Create List    ${att_port_7_HBTE}     ${att_port_8_HBTE}
# #
# #    ###create value list####
# #    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
# #    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
# #    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
# #    @{values_enb_cell1}     Create List    ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}
# #
# #    ###Adjust the HBTE attenuation value###
# #    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
# #    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
# #    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
# #    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
# #    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
# #    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
# #    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
# #    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
# #
# #temopary modify NIDD parameter
# #    Online delete parmeters     parameters_to_update=${PARAM_DELETE_Targetgnb1_W_001}     timeout=${120}
# #    Online modify parmeters     parameters_to_update=${PARAM_749_Targetgnb1_W_001}