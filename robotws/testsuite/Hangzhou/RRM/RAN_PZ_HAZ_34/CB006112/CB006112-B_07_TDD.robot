# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation     author: yayun zhang
# # #...                 contact: yayun.zhang@nokia-sbell.com
# # #...                 squad group: SG_03
# # #...                 feature : CB006112
# # #
# # #Resource     ./../CB006112/Resources/CB006112_common_keywords.robot
# # #
# # #Suite Setup    Run Keywords
# # #...            Prepare env with UEs    AND
# # #...            Set automatic rotation on UEs    AND
# # #...            Setup for SA Env cell on-air    AND
# # #...            Setup for SA Env cell on-air on gnb2    AND
# # #...            Run Keyword And Ignore Error    Lock gnb1 cell2    AND
# # #...            Run Keyword And Ignore Error    locked LTE cell
# # #
# # #Suite Teardown    Run Keywords
# # #...               run keyword and ignore error    Unlock gnb1 cell2    AND
# # #...               run keyword and ignore error    unlocked LTE cell    #AND
# # ##...               run keyword and ignore error    Delete all NRADJGNB object
# # #
# # #*** Variables ***
# # #${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
# # #${SCF_file_name}         gNB1_6112_B_07.xml
# # #${SCF_file_name_2}       gNB2_6112_B_07.xml
# # #${epc_log_path}       /tmp/
# # #${interface1}    any
# # #${nglogname1}    6112_B_07_attach.pcap
# # #${nglogname2}    6112_B_07_VONR.pcap
# # #${nglogname3}    6112_B_07_VONR_HO.pcap
# # #${nglogname4}    6112_B_07_VONR_Release.pcap
# # ###get Attenuator parameter from TL
# # #${atten_ip}    ${tl.attenuator[0].ip_addr}
# # #${5GRU0_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# # #${5GRU0_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
# # ##${enb_instance}    ${tl.enbs[0].instance_id}
# # #@{gnb_filter1}      f1ap.procedureCode == 7 and nr-rrc.milliSeconds == 7
# # #             ...    f1ap.procedureCode == 7 and nr-rrc.drx_InactivityTimer == 14
# # #             ...    f1ap.procedureCode == 7 and f1ap.longDRXCycleLength == 9
# # #@{value}    7    14    9
# # #@{gnb_filter2}      #f1ap.procedureCode == 7 and nr-rrc.milliSeconds == 5
# # #             ...    f1ap.procedureCode == 7 and nr-rrc.drx_InactivityTimer == 4
# # #             ...    f1ap.procedureCode == 7 and f1ap.longDRXCycleLength == 3
# # ##@{value1}    5    4    3
# # #@{value1}     4    3
# # #@{gnb_filter3}      f1ap.procedureCode == 7 and nr-rrc.milliSeconds == 4
# # #             ...    f1ap.procedureCode == 7 and nr-rrc.drx_InactivityTimer == 5
# # #             ...    f1ap.procedureCode == 7 and f1ap.longDRXCycleLength == 3
# # #@{value2}    4    5    3
# # #@{gnb_filter4}      f1ap.procedureCode == 7 and nr-rrc.milliSeconds == 6
# # #             ...    f1ap.procedureCode == 7 and nr-rrc.drx_InactivityTimer == 7
# # #             ...    f1ap.procedureCode == 7 and f1ap.longDRXCycleLength == 3
# # #@{value3}    6    7    3
# # ##${gnb_filter4}
# # #${5GRU0_ANT9}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #int
# # #${5GRU0_ANT10}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #int
# # #
# # ###PA
# # #@{PA_value}    ${30}    ${57}    ${30}    ${0}    #int list
# # #${att_ipaddr}               ${tl.attenuator[0].ip_addr}
# # #${att_api_port}             ${tl.attenuator[0].port}
# # #@{att_connection_port}      ${5GRU0_ANT9}    ${5GRU0_ANT10}     #int list
# # #${HBTE_max_value}           ${120}
# # #${vendor}                    ${tl.attenuator[0].vendor}
# # #
# # ### filter command for coverting PDML
# # ##${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap\"  -T pdml > {output_file}
# # #${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap\"  -T pdml
# # #
# # #*** Test Cases ***
# # #[1]CB006112-B_07_Successful_INTER_gNB_HO_setup TDD _of_VoNR_call_with_enable_different_VoNR_DRX_profile
# # #    [Documentation]    Test case description the gNB behaviour for the successful setup of Voice over NR call with FDD by AMR-WB codec
# # #    [Tags]              CB0061112-B
# # #    [Setup]
# # #    run keyword and ignore error    lock gnb1 cell2
# # #    Check UE device exist
# # #    Prepare env with UE
# # #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname1}    interface=${interface1}
# # #    Check phone attach successfully on SA env    gnb_index=1
# # #    sleep    5s
# # #    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1}
# # #    sleep    2s
# # #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname2}    interface=${interface1}
# # #    Start Capture Wireshark Logs on gNB    nglogname=${nglogname3}    interface=${interface1}
# # #    Make a VoNR call(+6688)
# # ##    Capture and download TTITrace log    gnb_index=${1}
# # #    Change the PA value to trigger HO for B_07
# # ##    Capture and download TTITrace log    gnb_index=${0}
# # #    sleep    60s
# # #    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname2}
# # #    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname3}
# # #    Start Capture Wireshark Logs on gNB    nglogname=${nglogname4}    interface=${interface1}
# # #    hang up VoNR call
# # #    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname4}
# # #    sleep    10s
# # #    Check IE wireshark log for attach   logname=${nglogname1}    message_filter1=@{gnb_filter1}[0]    message_filter2=@{gnb_filter1}[1]
# # #    ...    message_filter3=@{gnb_filter1}[2]
# # #    ...    value1=@{value}[0]    value2=@{value}[1]    value3=@{value}[2]
# # #    Check intergNB HO process on source gNB    logname=${nglogname2}
# # #    Check intergNB HO process on target gNB    logname=${nglogname3}
# # #    Check IE wireshark log for VONR_Release CDRX config    logname=${nglogname4}    message_filter1=@{gnb_filter4}[0]
# # #    ...    message_filter2=@{gnb_filter4}[1]    message_filter3=@{gnb_filter4}[2]    value1=@{value3}[0]
# # #    ...    value2=@{value3}[1]    value3=@{value3}[2]
# # ##    Check IE wireshark log for VONR CDRX config    logname=${nglogname2}    message_filter1=@{gnb_filter2}[0]    mes
# ...sage_filter2=@{gnb_filter2}[1
# # ]
# # ##    ...    message_filter3=@{gnb_filter2}[2]
# # ##    ...    value1=@{value1}[0]    value2=@{value1}[1]    value3=@{value1}[2]
# # #    Check IE wireshark log for VONR CDRX config    logname=${nglogname2}    message_filter1=@{gnb_filter2}[0]    mess
# ...age_filter2=@{gnb_filter2}[1]
# # #    ...    value1=@{value1}[0]    value2=@{value1}[1]
# # #    Check IE wireshark log for VONR_Target_CDRX config    logname=${nglogname3}     message_filter1=@{gnb_filter3}[0]
# # #    ...    message_filter2=@{gnb_filter3}[1]    message_filter3=@{gnb_filter3}[2]    value1=@{value2}[0]
# # #    ...    value2=@{value2}[1]    value3=@{value2}[2]
# # #    [Teardown]     Run Keywords
# # #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1}      AND
# # #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname2}      AND
# # #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname3}       AND
# # #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname4}       AND
# # #    ...    run keyword and ignore error    Change the PA value for case    AND
# # #    ...    run keyword and ignore error    unlock gnb1 cell2    AND
# # #    ...    run keyword and ignore error    coam.teardown    connection=Local gnb1    AND
# # #    ...    run keyword and ignore error    coam.teardown    connection=Local gnb2    AND
# # #    ...    run keyword and ignore error    CI_interface.Common Case Teardown
# # #
# # #
# # #*** Keywords ***
# # #Set default PA value for B_07
# # #    ${release_info}    Get gnb release
# # #    Run Keyword If    '${release_info}' == '0000_000800'    Adjust RU0 Attenuation to 20
# # #    Run Keyword If    '${release_info}' == '0011_001800'    Adjust RU0 Attenuation to 0
# # #
# # #Check IE wireshark log for attach
# # #    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}
# # #             ...    ${value1}    ${value2}    ${value3}
# # #    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
# # #    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}    value=${value2}
# # #    Check IE wireshark log for longDRXCycleLength     logname=${logname}    message_filter=${message_filter3}    value=${value3}
# # #
# # ##Check IE wireshark log for VONR CDRX config
# # ##    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}
# # ##             ...    ${value1}    ${value2}    ${value3}
# # ##    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
# # ##    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}    value=${value2}
# # ##    Check IE wireshark log for longDRXCycleLength     logname=${logname}    message_filter=${message_filter3}    value=${value3}
# # #
# # #Check IE wireshark log for VONR CDRX config
# # #    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${value1}    ${value2}
# # #    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter1}    value=${value1}
# # #    Check IE wireshark log for longDRXCycleLength      logname=${logname}    message_filter=${message_filter2}    value=${value2}
# # #
# # #Check IE wireshark log for VONR_Target_CDRX config
# # #    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}
# # #             ...    ${value1}    ${value2}    ${value3}
# # #    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
# # #    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}    value=${value2}
# # #    Check IE wireshark log for longDRXCycleLength     logname=${logname}    message_filter=${message_filter3}    value=${value3}
# # #
# # #Check IE wireshark log for VONR_Release CDRX config
# # #    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}
# # #             ...    ${value1}    ${value2}    ${value3}
# # #    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
# # #    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}    value=${value2}
# # #    Check IE wireshark log for longDRXCycleLength      logname=${logname}    message_filter=${message_filter3}    value=${value3}
# # #
# # #Check IE wireshark log for drx_onDurationTimer
# # #    [Arguments]    ${logname}    ${message_filter}    ${value}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
# # #    ${filter_expression}=     Catenate    ${message_filter}
# # ##    ${filtered_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # ##    ${drx_onDurationTimer}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # ##    ...                                                xpath=.//nr-rrc.milliSeconds
# # #    ${drx_onDurationTimer}=     cap.get_field_value_by_xpath     xpath=.//nr-rrc.milliSeconds    pcap_parser=test6
# # #    should be equal    ${drx_onDurationTimer[0]}    ${value}
# # #
# # #Check IE wireshark log for drx_InactivityTimer
# # #    [Arguments]    ${logname}    ${message_filter}    ${value}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
# # #    ${filter_expression}=     Catenate    ${message_filter}
# # ##    ${filtered_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # ##    ${drx_InactivityTimer}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # ##    ...                                                xpath=.//nr-rrc.drx_InactivityTimer
# # #    ${drx_InactivityTimer}=     cap.get_field_value_by_xpath     xpath=.//nr-rrc.drx_InactivityTimer    pcap_parser=test6
# # #    should be equal    ${drx_InactivityTimer[0]}    ${value}
# # #
# # #Check IE wireshark log for longDRXCycleLength
# # #    [Arguments]    ${logname}    ${message_filter}    ${value}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
# # #    ${filter_expression}=     Catenate    ${message_filter}
# # ##    ${filtered_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
# # ##    ${f1ap_longDRXCycleLength}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # ##    ...                                                xpath=.//f1ap.longDRXCycleLength
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
# # #    ${f1ap_longDRXCycleLength}=     cap.get_field_value_by_xpath     xpath=.//f1ap.longDRXCycleLength    pcap_parser=test6
# # #    should be equal    ${f1ap_longDRXCycleLength[0]}    ${value}
# # #
# # #Check intergNB HO process on source gNB
# # #    [Arguments]    ${logname}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
# # #    ${5QI_1_filter}=     Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 1
# # ##    ${5QI_1_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${5QI_1_filter}
# # ##    ${PDU_session}=     cap.get_field_value_by_xpath    pdml_list=${5QI_1_packets}
# # ##    ...                                                xpath=.//ngap.fiveQI
# # #    ${5QI_1_packets}=    cap.filter_packets_by_expression    filter_expression=${5QI_1_filter}    pcap_parser=test6
# # #    ${PDU_session}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
# # #    should contain    ${PDU_session}    1
# # #    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik2_addr}
# # ##    ${HO_req_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${HO_req_filter}
# # ##    ${HO_req}=     cap.get_field_value_by_xpath    pdml_list=${HO_req_packets}
# # ##    ...                                                xpath=.//xnap.procedureCode
# # #    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
# # #    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
# # #    should contain    ${HO_req}    0
# # #    ${HO_res_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik_addr}
# # ##    ${HO_res_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${HO_res_filter}
# # ##    ${HO_res}=     cap.get_field_value_by_xpath    pdml_list=${HO_res_packets}
# # ##    ...                                                xpath=.//xnap.procedureCode
# # #    ${HO_res_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_res_filter}    pcap_parser=test6
# # #    ${HO_res}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode     pcap_parser=test6
# # #    should contain    ${HO_res}    0
# # #    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
# # ##    ${UE_rel_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${UE_rel_filter}
# # ##    ${UE_rel}=     cap.get_field_value_by_xpath    pdml_list=${UE_rel_packets}
# # ##    ...                                                xpath=.//xnap.procedureCode
# # #    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
# # #    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
# # #    should contain    ${UE_rel}    6
# # #
# # #Check intergNB HO process on target gNB
# # #    [Arguments]    ${logname}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
# # #    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
# # ##    ${HO_req_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${HO_req_filter}
# # ##    ${HO_req}=     cap.get_field_value_by_xpath    pdml_list=${HO_req_packets}
# # ##    ...                                                xpath=.//xnap.procedureCode
# # #    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
# # #    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
# # #    should contain    ${HO_req}    0
# # #    ${HO_res_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik_addr}
# # ##    ${HO_res_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${HO_res_filter}
# # ##    ${HO_res}=     cap.get_field_value_by_xpath    pdml_list=${HO_res_packets}
# # ##    ...                                                xpath=.//xnap.procedureCode
# # #    ${HO_res_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_res_filter}    pcap_parser=test6
# # #    ${HO_res}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
# # #    should contain    ${HO_res}    0
# # #    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${asik_addr}
# # ##    ${PathS_req_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}
# # ##    ...    filter_expression=${PathS_req_filter}
# # ##    ${PathS_req}=     cap.get_field_value_by_xpath    pdml_list=${PathS_req_packets}
# # ##    ...                                                xpath=.//ngap.procedureCode
# # #    ${PathS_req_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_req_filter}    pcap_parser=test6
# # #    ${PathS_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
# # #    should contain    ${PathS_req}    25
# # #    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${asik_addr}
# # ##    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}
# # ##    ...    filter_expression=${PathS_ACK_filter}
# # ##    ${PathS_ACK}=     cap.get_field_value_by_xpath    pdml_list=${PathS_ACK_packets}
# # ##    ...                                                xpath=.//ngap.procedureCode
# # #    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_ACK_filter}    pcap_parser=test6
# # #    ${PathS_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
# # #    should contain    ${PathS_ACK}    25
# # #    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
# # ##    ${UE_rel_packets}=    cap.filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${UE_rel_filter}
# # ##    ${UE_rel}=     cap.get_field_value_by_xpath    pdml_list=${UE_rel_packets}
# # ##    ...                                                xpath=.//xnap.procedureCode
# # #    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
# # #    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
# # #    should contain    ${UE_rel}    6
# # #    ${UE_contextreleasereq_filter}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 0
# # ##    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
# # ##    ...    filter_expression=${UE_contextreleasereq_filter}
# # ##    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    pdml_list=${UE_contextreleasereq_packets}
# # ##    ...                                                xpath=.//ngap.radioNetwork
# # #    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_contextreleasereq_
# ...filter}    pcap_parser=test6
# # #    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
# # #    should not contain    ${UE_contextreleasereq}    0
# # #
# # #Capture and download TTITrace log
# # #    [Arguments]    ${gnb_index}
# # #    ${release_info}    Get gnb release
# # #    Run Keyword If    '${release_info}' == 'SBTS22R1'    Capture TTITrace and download to test pc ASIB
# # #    ...    gnb_index=${1}    hw_slot=${1}
# # #    Run Keyword If    '${release_info}' == '5G21A'    Capture TTITrace and download to test pc ASIB
# # #    ...    gnb_index=${1}    hw_slot=${5}
# # #
# # #Change the PA value to trigger HO for B_07
# # #    ${release_info}    Get gnb release
# # #    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust the attenuation value for HBTE
# # #    ...    value_1=@{PA_value}[0]     value_2=@{PA_value}[0]
# # #    Run Keyword If    '${release_info}' == 'SBTS22R2_ENB_9999'    Adjust the attenuation value for HBTE
# # #    ...    value_1=@{PA_value}[0]     value_2=@{PA_value}[1]
# # #
# # ###PA##
# # #Adjust the attenuation value for HBTE
# # #    [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}
# # #    [Documentation]    Auther:cris.cai@nokia-sbell.com
# # #    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
# # #    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
# # #    ...                if connect on local plz disconnect firstly
# # #    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
# # #    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
# # #    att.set_attenuation     port=${5GRU0_ANT9}    value=${value_1}
# # #    att.set_attenuation     port=${5GRU0_ANT10}    value=${value_1}
# # #    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT9}
# # #    should be equal    ${value_port1}    ${value_1}
# # #    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT10}
# # #    should be equal    ${value_port2}    ${value_1}
# # #    sleep  3s
# # #    att.set_attenuation     port=${5GRU0_ANT9}    value=${value_2}
# # #    att.set_attenuation     port=${5GRU0_ANT10}    value=${value_2}
# # #    ${value_port3}    att.read_attenuation    port=${5GRU0_ANT9}
# # #    should be equal    ${value_port3}    ${value_2}
# # #    ${value_port4}    att.read_attenuation    port=${5GRU0_ANT10}
# # #    should be equal    ${value_port4}    ${value_2}
# # #
# # #Change the PA value for case
# # #    ${release_info}    Get gnb release
# # #    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Adjust the attenuation value for HBTE
# # #    ...    value_1=@{PA_value}[3]     value_2=@{PA_value}[3]
# # #    Run Keyword If    '${release_info}' == 'SBTS22R2_ENB_9999'    Adjust the attenuation value for HBTE
# # #    ...    value_1=@{PA_value}[2]     value_2=@{PA_value}[3]
