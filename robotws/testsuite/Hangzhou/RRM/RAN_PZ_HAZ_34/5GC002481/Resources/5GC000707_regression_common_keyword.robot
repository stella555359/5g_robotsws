*** Settings ***
Documentation     author: cindy.jin
...                 contact: cindy.1.jin@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000707

Library           OperatingSystem
Library           DateTime
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Library           taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.analyzer.pcap   WITH NAME    parser
#Library           Attenuation.Attenuation    WITH NAME    atten
Variables         5GC000707_regression_test_parameters.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py


*** Variables ***
${interface_any}    any
${interface_gnb}    fp0
${interface_enb}    br1
${counter_B2}    M55124C02001
${counter_A2}    M55124C02002
${path_A2B2}    BTS/CELLS/NRCELL-1/NRRCC
${path_NNGCC_IRATHO}    BTS/CELLS/NRCELL-1/NNGCC
${path_NREMO_IRATHO}    BTS/CELLS/NRCELL-1/MCC-${tl.core.mcc}_MNC-${tl.core.mnc}/ECI-1355265/NREMO
${tshark_path}    /usr/bin/tshark
${command_template_ngap}       {tshark_path} -r {pcap_file} -Y  \"ngap\"  -T pdml
${command_template_f1ap}       {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
${command_template_s1ap}       {tshark_path} -r {pcap_file} -Y  \"s1ap\"  -T pdml
${eNB_asik_addr}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${atten_ip_1}        ${tl.attenuator[1].ip_addr}
${atten_ip_2}        ${tl.attenuator[2].ip_addr}
${atten_ip_3}        ${tl.attenuator[3].ip_addr}
${atten_ip_0}        ${tl.attenuator[0].ip_addr}
${HBTE_port_1}    ${tl.attenuator[0].attenuator_ports[9]}
${HBTE_port_2}    ${tl.attenuator[0].attenuator_ports[10]}
${HBTE_port_3}    ${tl.attenuator[0].attenuator_ports[3]}
${HBTE_port_4}    ${tl.attenuator[0].attenuator_ports[4]}
${HBTE_port_5}    ${tl.attenuator[0].attenuator_ports[5]}
${HBTE_port_6}    ${tl.attenuator[0].attenuator_ports[6]}
${HBTE_port_7}    ${tl.attenuator[0].attenuator_ports[7]}
${HBTE_port_8}    ${tl.attenuator[0].attenuator_ports[8]}
${HBTE_port_9}    ${tl.attenuator[0].attenuator_ports[1]}
${HBTE_port_10}    ${tl.attenuator[0].attenuator_ports[2]}
${HBTE_port_11}    ${tl.attenuator[0].attenuator_ports[11]}
${HBTE_port_12}    ${tl.attenuator[0].attenuator_ports[12]}
${HBTE_port_13}    ${tl.attenuator[0].attenuator_ports[13]}
${HBTE_port_14}    ${tl.attenuator[0].attenuator_ports[14]}
${HBTE_port_15}    ${tl.attenuator[0].attenuator_ports[15]}
${HBTE_port_16}    ${tl.attenuator[0].attenuator_ports[16]}
${HBTE2_port_1}    ${tl.attenuator[2].attenuator_ports[1]}
${HBTE2_port_2}    ${tl.attenuator[2].attenuator_ports[2]}
${HBTE2_port_9}    ${tl.attenuator[2].attenuator_ports[9]}
${HBTE2_port_10}    ${tl.attenuator[2].attenuator_ports[10]}
${HBTE3_port_12}    ${tl.attenuator[3].attenuator_ports[12]}
${HBTE3_port_13}    ${tl.attenuator[3].attenuator_ports[13]}
${HBTE3_port_14}    ${tl.attenuator[3].attenuator_ports[14]}
${HBTE3_port_15}    ${tl.attenuator[3].attenuator_ports[15]}
${att_api_port}   ${tl.attenuator[0].port}
${ul_expect_throughput}    5
${dl_expect_throughput}    8

*** Keywords ***
Prepare the gNB cell onair status
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    ${cell_status}    run keyword and return status    Prepare the gNB cell onair    gnb_index=${gnb_index}
    ...                 tl_scf_file_name=${tl_scf_file_name}
    set suite variable    ${cell_status}

Prepare the gNB cell onair
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    login and load scf    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}
    ...                   tl_scf_file_name=${tl_scf_file_name}    pdl_checking=${True}
    Run Keyword if    '${release_info}' == '5G21A'    Precondition for enb    enb_scf_file_name=${enb_scf_file_name}
    ...    ELSE    sleep    1min
    wait until keyword succeeds    15 min    30 sec    Check cell status on air
    ...                   bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}
#    wait until keyword succeeds    10 min    20 sec    Check the enb cell onAir

Load scf file for gnb2
    [Arguments]    ${tl_scf_file_name}    ${gnb_index}=${0}
    login and load scf    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}
    ...                   tl_scf_file_name=${tl_scf_file_name}

Online modify parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${200}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Check X2 link status from GNB
    [Arguments]    ${gnb_index}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Check X2 link status from GNB
    sleep    1min
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Check RRC_Release with redirection
    [Arguments]    ${log_name}    ${asik_addr}=${asik_addr}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ...    tshark_path=${tshark_path}    command_template=${command_template_ngap}
    ${releasereq_filter}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 41
    ${releasereq_packets}=    parser.filter_packets_by_expression    filter_expression=${releasereq_filter}
    ${releasereq}=     parser.get_field_value_by_xpath    pdml_list=${releasereq_packets}    xpath=.//ngap.radioNetwork
    should be equal    ${releasereq[0]}    41
    ${releasecmd_filter}=     Catenate    ngap.procedureCode == 41 and ngap.radioNetwork == 41
    ${releasecmd_packets}=    parser.filter_packets_by_expression    filter_expression=${releasecmd_filter}
    ${releasecmd}=     parser.get_field_value_by_xpath    pdml_list=${releasecmd_packets}    xpath=.//ngap.radioNetwork
    should be equal    ${releasecmd[0]}    41
    ${releasecmp_filter}=     Catenate    ngap.procedureCode == 41 and ngap.NGAP_PDU == 1
    ${releasecmp_packets}=    parser.filter_packets_by_expression    filter_expression=${releasecmp_filter}
    ${releasecmp}=     parser.get_field_value_by_xpath    pdml_list=${releasecmp_packets}    xpath=.//ngap.procedureCode
    should be equal    ${releasecmp[0]}    41
Check PM counter Result
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}    ${counter_increase}=True
    ${counter_value}    Check PM counter from webui    counter_id=${counter_id}    full_path=${dic_path}    gnb_index=${gnb_index}
    ${counter_sum}    Sum the list value    ${counter_value}
    Run keyword if    "${counter_increase}" == "True"    should be true    ${counter_sum} >= ${1}
    ...    ELSE    should be true     ${counter_sum} == ${0}

Check PM counter from webui
    [Arguments]    ${counter_id}    ${full_path}    ${gnb_index}=${0}    ${date}=all
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${counter_value}
    [Teardown]    COAM Teardown gnb connections

Sum the list value
    [Arguments]    ${counter_result}
    ${length}    Get Length    ${counter_result}
    ${sum_result}    set variable    ${0}
    FOR    ${i}    IN RANGE    ${length}
        ${sum_result}    Evaluate    ${sum_result} + ${counter_result[${i}]}
    END
    [Return]      ${sum_result}

Get gnb release
    wait until keyword succeeds    1min    10s    Connect to Common Unit Master    alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml    connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Precondition for enb
    [Arguments]    ${enb_scf_file_name}    ${connection}=enb     ${enb_index}=${0}
    Connect to eNB via ssl    connection=${connection}     enb_index=${enb_index}
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${enb_scf_file_name}    timeout=800    is_pdl_checking_needed=${False}
    ...    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Lock and unlock LTE cell
    [Arguments]    ${value}    ${LTE_cell_id}=${0}    ${enb_index}=${0}
    Connect to eNB via ssl    enb_index=${enb_index}
    Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${LTE_cell_id}
    ...    parameter_name=administrativeState    value=${value}
    sleep    5s
    [Teardown]    enblte.teardown    connection=enblte

Start ul dl data transfer
    [Arguments]    ${throughput}=20M    ${duration}=600    ${ue_index}=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}   direction=ul    throughput=${throughput}    duration=${duration}    ue_index=${ue_index}
    ...    iperf_port=${ul_port}
    power_ue.Start traffic    ue_type=${ue_type}   direction=dl    throughput=${throughput}    duration=${duration}    ue_index=${ue_index}
    ...    iperf_port=${dl_port}    process_num=${1}

Stop ul dl data transfer
    [Arguments]    ${ue_index}=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}   direction=ul    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}   direction=dl    ue_index=${ue_index}

check throughput in gnb
    [Arguments]    ${cellid}=${1}    ${ultput}=${ul_expect_throughput}    ${dltput}=${dl_expect_throughput}    ${gnb_index}=${gnb_index}
    ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   5min    10s    power_ue.Check Throughput
    ...    ue_type=${ue_type}    direction=ul    throughput=${ultput}    cellid=${nrcellid}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   5min    10s    power_ue.Check Throughput
    ...    ue_type=${ue_type}    direction=dl    throughput=${dltput}    cellid=${nrcellid}    gnb_index=${gnb_index}

Check the throughput on enb UI
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${eNB_asik_addr}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    Check the bts counter M8012C71 from ${M8012C71_path} as 10000
    Check the bts counter M8012C76 from ${M8012C76_path} as 10000
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

Check the bts counter ${counter_id} from ${counter_path} as ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ...                 full_path=${counter_path}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}

Check A2 configuration in RRC message
    [Arguments]    ${log_name}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ...    tshark_path=${tshark_path}    command_template=${command_template_f1ap}
    ${A2_event_filter}=     Catenate    f1ap.procedureCode == 5 and nr-rrc.reportConfig == 0 and nr-rrc.eventId == 1
    ${A2_event_packets}=    parser.filter_packets_by_expression    filter_expression=${A2_event_filter}
    ${Event}=     parser.get_field_value_by_xpath    pdml_list=${A2_event_packets}    xpath=.//nr-rrc.eventId
    should be equal    ${Event[0]}    1
    ${Threshold}=     parser.get_field_value_by_xpath    pdml_list=${A2_event_packets}    xpath=.//nr-rrc.a2_Threshold
    should be equal    ${Threshold[0]}    0
    ${RSRP}=     parser.get_field_value_by_xpath    pdml_list=${A2_event_packets}    xpath=.//nr-rrc.rsrp
    should be equal    ${RSRP[0]}    ${A2Threshold}
    ${Hysteresis}=     parser.get_field_value_by_xpath    pdml_list=${A2_event_packets}    xpath=.//nr-rrc.hysteresis
    should be equal    ${Hysteresis[0]}    0
    ${TimeToTrigger}=     parser.get_field_value_by_xpath    pdml_list=${A2_event_packets}    xpath=.//nr-rrc.timeToTrigger
    should be equal    ${TimeToTrigger[0]}    15

Check removed A2 and configured A1/B2 in the RRC message
    [Arguments]    ${log_name}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ...    tshark_path=${tshark_path}    command_template=${command_template_f1ap}
    ${event_filter}=     Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.id == 9
    ${event_packets}=    parser.filter_packets_by_expression    filter_expression=${event_filter}
    ${A2_Event}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.measId
    should not contain    ${A2_Event}    1
    ${A1_Event}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.eventId
    should Contain    ${A1_Event}    0
    ${Threshold}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.a1_Threshold
    should be equal    ${Threshold[0]}    0
    ${RSRP}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.rsrp
    should Contain    ${RSRP}    ${A1Threshold}
    ${Hysteresis}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.hysteresis
    should be equal    ${Hysteresis[1]}    0
    ${TimeToTrigger}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.timeToTrigger
    should be equal    ${TimeToTrigger[1]}    9
    ${B2_Event}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.eventId
    should Contain    ${B2_Event}    1
    ${Threshold1}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.b2_Threshold1
    should be equal    ${Threshold1[0]}    0
    ${length} =    Get Length    ${Threshold1}
    should be equal as integers    ${length}    1
    ${B2_rsrp}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.rsrp
    should Contain    ${B2_rsrp}    ${B2Threshold1}
    ${Threshold2}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.b2_Threshold2EUTRA
    should Contain    ${Threshold2}    0
    ${B2_Threshold2_rsrp}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.rsrp
    should Contain    ${B2_Threshold2_rsrp}    ${B2Threshold2}
    ${B2_hysteresis}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.hysteresis
    should Contain    ${B2_hysteresis}    0
    ${B2_TimeToTigger}=     parser.get_field_value_by_xpath    pdml_list=${event_packets}    xpath=.//nr-rrc.timeToTrigger
    should Contain    ${B2_TimeToTigger}    9

Check measGapConfig Setup in RRC meassge
    [Arguments]    ${log_name}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ...    tshark_path=${tshark_path}    command_template=${command_template_f1ap}
    ${measGap_Setup_filter}=    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.gapUE == 1
    ${measGap_Setup_packets}=    parser.filter_packets_by_expression    filter_expression=${measGap_Setup_filter}
    ${measGap_Setup}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Setup_packets}    xpath=.//nr-rrc.gapUE
    should be equal    ${measGap_Setup[0]}    1
    ${measGap_gapoffset}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Setup_packets}    xpath=.//nr-rrc.gapOffset
    should be equal    ${measGap_gapoffset[0]}    0
    ${measGap_gapmgl}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Setup_packets}    xpath=.//nr-rrc.mgl
    should be equal    ${measGap_gapmgl[0]}    5
    ${measGap_gapmgrp}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Setup_packets}    xpath=.//nr-rrc.mgrp
    should be equal    ${measGap_gapmgrp[0]}    2
    ${measGap_gapmgta}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Setup_packets}    xpath=.//nr-rrc.mgta
    should be equal    ${measGap_gapmgta[0]}    2

Check measGapConfig Setup in RRC meassge in 20B
    [Arguments]    ${log_name}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ...    tshark_path=${tshark_path}    command_template=${command_template_f1ap}
    ${measGap_Setup_filter}=    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and nr-rrc.gapUE == 1
    ${measGap_Setup_packets}=    parser.filter_packets_by_expression    filter_expression=${measGap_Setup_filter}
    ${measGap_Setup}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Setup_packets}    xpath=.//nr-rrc.gapUE
    should be equal    ${measGap_Setup[0]}    1
    ${measGap_gapoffset}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Setup_packets}    xpath=.//nr-rrc.gapOffset
    should be equal    ${measGap_gapoffset[0]}    0
    ${measGap_gapmgl}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Setup_packets}    xpath=.//nr-rrc.mgl
    should be equal    ${measGap_gapmgl[0]}    5
    ${measGap_gapmgrp}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Setup_packets}    xpath=.//nr-rrc.mgrp
    should be equal    ${measGap_gapmgrp[0]}    2
    ${measGap_gapmgta}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Setup_packets}    xpath=.//nr-rrc.mgta
    should be equal    ${measGap_gapmgta[0]}    2

Check measGapConfig Release in RRC meassge
    [Arguments]    ${log_name}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ...    tshark_path=${tshark_path}    command_template=${command_template_f1ap}
    ${measGap_Release_filter}=    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7 and nr-rrc.gapUE == 0
    ${measGap_Release_packets}=    parser.filter_packets_by_expression    filter_expression=${measGap_Release_filter}
    ${measGap_Release}=     parser.get_field_value_by_xpath    pdml_list=${measGap_Release_packets}    xpath=.//nr-rrc.gapUE
    should be equal    ${measGap_Release[0]}    0

Check gnb trigger ho to lte
    [Arguments]     ${log_name}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ...    tshark_path=${tshark_path}    command_template=${command_template_ngap}
    ${ho_req_filter}=    Catenate    ngap.procedureCode == 12&&ngap.NGAP_PDU == 0
    ${ho_req_packets}=    parser.filter_packets_by_expression    filter_expression=${ho_req_filter}
    ${ho_req_cause}=     parser.get_field_value_by_xpath    pdml_list=${ho_req_packets}    xpath=.//ngap.radioNetwork
    should be equal    ${ho_req_cause[0]}    32
    ${ho_command_filter}=    Catenate    ngap.NGAP_PDU == 1&&ngap.procedureCode == 12
    ${ho_command_packets}=    parser.filter_packets_by_expression    filter_expression=${ho_command_filter}
    ${ho_command_cause}=     parser.get_field_value_by_xpath    pdml_list=${ho_command_packets}    xpath=.//ngap.HandoverType
    should be equal    ${ho_command_cause[0]}    1
    ${rel_success_filter}=    Catenate    ngap.NGAP_PDU == 1&&ngap.procedureCode == 41
    ${rel_success_packets}=    parser.filter_packets_by_expression    filter_expression=${rel_success_filter}
    ${rel_success}=     parser.get_field_value_by_xpath    pdml_list=${rel_success_packets}    xpath=.//ngap.procedureCode
    should be equal    ${rel_success[0]}    41
Check inter-rat successfully
    [Arguments]    ${log_name}=${s1logname}
    ${LTE_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
    ...    tshark_path=${tshark_path}    command_template=${command_template_s1ap}
    ${Ho_request_filter}=     Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 1
    ${Ho_request_packets}=    parser.filter_packets_by_expression    filter_expression=${Ho_request_filter}
    ${Ho_request}=     parser.get_field_value_by_xpath    pdml_list=${Ho_request_packets}    xpath=.//s1ap.radioNetwork
    should be equal    ${Ho_request[0]}    18
    ${Ho_Ack_LTE_filter}=     Catenate    s1ap.S1AP_PDU == 1 and s1ap.procedureCode == 1
    ${Ho_Ack_LTE_packets}=    parser.filter_packets_by_expression    filter_expression=${Ho_Ack_LTE_filter}
    ${Ho_Ack_LTE}=     parser.get_field_value_by_xpath    pdml_list=${Ho_Ack_LTE_packets}    xpath=.//s1ap.procedureCode
    should be equal    ${Ho_Ack_LTE[0]}    1
    ${Ho_notify_filter}=     Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 2
    ${Ho_notify_packets}=    parser.filter_packets_by_expression    filter_expression=${Ho_notify_filter}
    ${Ho_notify}=     parser.get_field_value_by_xpath    pdml_list=${Ho_notify_packets}    xpath=.//s1ap.procedureCode
    should be equal    ${Ho_notify[0]}    2
    ${UEContext_Release_fliter} =  Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 18
    ${UEContext_Release} =    parser.filter_packets_by_expression    filter_expression=${UEContext_Release_fliter}
    ${UEContext_Release_Value} =    parser.get_field_value_by_xpath    pdml_list=${UEContext_Release}    xpath=.//s1ap.procedureCode
    should be empty    ${UEContext_Release_Value}

Adjust the Attenuation Values
    [Arguments]    ${value}    ${port0}    ${port1}=${0}    ${port_num}=${1}    ${atten_ip}=${tl.attenuator[0].ip_addr}
    atten.connect to    ip=${atten_ip}
    ${i}    set variable    ${0}
    FOR    ${i}    IN RANGE    ${port_num}
      atten.get_value    channel=${port${i}}
      atten.set_value    channel=${port${i}}    value=${value}
    END
    atten.disconnect

adjust the HBTE attenuation value by step
    [Arguments]     ${start_value}    ${step}    ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}    ${atten_ip}=${atten_ip}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ${end_value} =    Evaluate    ${start_value} + ${step}
    FOR    ${value}    IN RANGE    ${start_value}    ${end_value}+2    2
      attenuator.set_attenuation     port=${att_port_1}    value=${value}
      attenuator.set_attenuation     port=${att_port_2}    value=${value}
      ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
      should be equal    ${value_port_1}    ${value}
      ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
      should be equal    ${value_port_2}    ${value}
      sleep    5s
    END

Test recovery
    run keyword and ignore error    Stop ul dl data transfer
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword and ignore error    coam.teardown    connection=gnb0
    run keyword and ignore error    coam.teardown    connection=gnb1

Suite recover
    run keyword and ignore error    Precondition for attn    value1=${${init_value}}
    run keyword and ignore error    Lock and unlock LTE cell    value=unlocked
    run keyword and ignore error    CI_interface.Common Case Teardown
