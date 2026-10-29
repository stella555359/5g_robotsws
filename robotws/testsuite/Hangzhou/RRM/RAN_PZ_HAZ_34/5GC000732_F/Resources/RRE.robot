*** Settings ***
Documentation
...   This is template of automation testing
...   squad group: MMW_SG1
Resource    ./../../../../resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/mobility.robot



*** Keywords ***
Adjust attenuator to RRE
    [Documentation]    Author: Liu Zheng
    ...    RRE: RRC Reestablishment
    ...    ${PCELL_RRE_PA_VALUE_${MRBTS_ID}}, ${PCELL_INIT_PA_VALUE_${MRBTS_ID}}, ${PCELL_RRE_PA_INTERVAL} and ${PCELL_RU_INDEX}
    ...    are defined in CA_variables.robot
    [Arguments]    ${gnb_index}=${0}    ${ru_index}=${PCELL_RU_INDEX}
    ...    ${pa_begin_value}=${PCELL_INIT_PA_VALUE_${MRBTS_ID}}    ${pa_end_value}=${PCELL_RRE_PA_VALUE_${MRBTS_ID}}
    ...    ${pa_back_value}=${PCELL_INIT_PA_VALUE_${MRBTS_ID}}
    log to console    start to initialize Pcell PA......
    _set attenuator ports of specified RU to same value    exp_pa_value=${pa_begin_value}
    ...    gnb_index=${gnb_index}    ru_index=${ru_index}
    log to console    Start to trigger RRE......
    sleep    ${RRE_PA_INTERVAL_${MRBTS_ID}}
    _set attenuator ports of specified RU to same value    exp_pa_value=${pa_end_value}
    ...    gnb_index=${gnb_index}    ru_index=${ru_index}
    sleep    ${RRE_PA_INTERVAL_${MRBTS_ID}}
    _set attenuator ports of specified RU to same value    exp_pa_value=${pa_back_value}
    ...    gnb_index=${gnb_index}    ru_index=${ru_index}

Adjust pcell attenuator multi ports to trigger RRE
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${attenuator_index}=${0}        ${attenuator_device}=ATTEN_0
    ...    ${gnb_index}=${0}    ${ru_index}=${PCELL_RU_INDEX}
    ...    ${pa_begin_value}=${PCELL_INIT_PA_VALUE_${MRBTS_ID}}    ${pa_end_value}=${PCELL_RRE_PA_VALUE_${MRBTS_ID}}
    ...    ${pa_back_value}=${PCELL_INIT_PA_VALUE_${MRBTS_ID}}
    Connect to Attenuator    attenuator_index=${attenuator_index}    alias=${attenuator_device}
    ${atten_ports}    gnb_classical_hangzhou.Get Attenuation Channels For RU    gnb_id=${0}    RU_id=${PCELL_RU_INDEX}
    log to console    Start to trigger RRE......
    set PA value for multi ports    pa_value=${pa_begin_value}    atten_ports=${atten_ports}
    set PA value for multi ports    pa_value=${pa_end_value}    atten_ports=${atten_ports}
    set PA value for multi ports    pa_value=${pa_back_value}    atten_ports=${atten_ports}

set PA value for multi ports
    [Arguments]    ${pa_value}    ${atten_ports}    ${attenuator_device}=ATTEN_0
    ${interval_value}    create list    ${pa_value}    ${pa_value}
    set multi ports to same value on PA    atten_ports=${atten_ports}    pa_values=${interval_value}
    ...    attenuator_device=${attenuator_device}
    sleep    ${RRE_PA_INTERVAL_${MRBTS_ID}}

set multi ports to same value on PA
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${atten_ports}    ${pa_values}    ${attenuator_device}=ATTEN_0
    set_ports_attenuation    ports=${atten_ports}    values=${pa_values}    confirm=${False}
    ...    attenuator_device=${attenuator_device}
    read_ports_attenuation     ports=${atten_ports}    attenuator_device=${attenuator_device}

Adjust attenuator multi ports to same value
    [Documentation]    Author: Liu Zheng
    ...    currently only suport 2 ports and 4 ports
    [Arguments]    ${attenuator_index}=${0}        ${attenuator_device}=ATTEN_0
    ...    ${gnb_index}=${0}    ${ru_index}=${SCELL_RU_INDEX}
    ...    ${pa_value}=${SCELL_INIT_PA_VALUE_${MRBTS_ID}}
    ...    ${pa_port_num}=${4}
    Connect to Attenuator    attenuator_index=${0}    alias=${attenuator_device}
    ${atten_ports}    gnb_classical_hangzhou.Get Attenuation Channels For RU    gnb_id=${gnb_index}
    ...    RU_id=${ru_index}
    ${pa_values_2}    create list    ${pa_value}    ${pa_value}
    ${pa_values_4}    create list    ${pa_value}    ${pa_value}    ${pa_value}    ${pa_value}
    ${pa_values}    set variable if    ${pa_port_num}==${4}    ${pa_values_4}    ${pa_values_2}
    set_ports_attenuation    ports=${atten_ports}    values=${pa_values}    confirm=${False}
    ...    attenuator_device=${attenuator_device}
    read_ports_attenuation     ports=${atten_ports}    attenuator_device=${attenuator_device}

Verify a1 scell addition measurement config in cpif log
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${log_path_pcap}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable
    ...    (f1ap.procedureCode == 12) && (f1ap.F1AP_PDU == 0) && (nr-rrc.eventId == 0)
    ${RrcReconf}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${a1MeasType}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.a1_Threshold
    ...    attribute_name=showname
#    ${rsrp}    pcap.get_field_value_by_xpath
#    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.a1_Threshold/nr-rrc.rsrp
#    ...    attribute_name=show

    ${rsrp}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.a1_Threshold/nr-rrc.measTriggerQuantity.rsrp
    ...    attribute_name=show

    ${hysteresis}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.hysteresis
    ...    attribute_name=show
    ${timeToTrigger}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.timeToTrigger
    ...    attribute_name=showname

    run keyword and continue on failure    should be equal as strings    rsrp    ${a1MeasType[0].split()[1]}
    run keyword and continue on failure    should be equal as strings    ${A1_THRES_SCELL_ADD_SSB_RSRP_TDD}    ${rsrp[0]}
    run keyword and continue on failure    should be equal as strings    ${A1_HYS_SCELL_ADD_SSB_RSRP}    ${hysteresis[0]}
    should be equal as strings    ${A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP}    ${timeToTrigger[0].split()[1]}

Verify RRE messages in config in f1ap log
    [Documentation]    Author: Liu Zheng
    ...    This KW will use the method in taf.analyzer.pcap to analylize the pcap_logs.
    [Arguments]    ${log_path_pcap}    ${check_only_rrcReestablishmentRequest}=${False}
    ${filter}    catenate     ((f1ap.procedureCode == 11) && (nr-rrc.c1 == 2))
    ...    || ((f1ap.procedureCode == 12)&&(nr-rrc.c1 == 3)) || (( f1ap.procedureCode==13) && (nr-rrc.c1 == 3))
    cap.setup      infile=${log_path_pcap}    display_filter=${filter}    alias=test_rre
    pcap.get_packets    filter=${filter}    pcap_parser=test_rre
    ${rre}    run keyword and continue on failure    pcap.get_field_value    field_name=nr-rrc.c1   fmt=showname    pcap_parser=test_rre
    ${length}    Get Length    ${rre}
    ${remainder}    evaluate    ${length}%3
    run keyword and continue on failure    should be true    ${remainder}==${0}
    run keyword and continue on failure    should be true    ${length}>=${3}
    run keyword and continue on failure    should contain    ${rre[0]}    c1: rrcReestablishmentRequest (2)    case_insensitive=${True}
    ...    whitespace_insensitive=${True}
    run keyword if     ${check_only_rrcReestablishmentRequest}==${False}   run keyword and continue on failure
    ...    should contain    ${rre[1]}    c1: rrcReestablishment (3)    case_insensitive=${True}
    ...    whitespace_insensitive=${True}
    run keyword if     ${check_only_rrcReestablishmentRequest}==${False}   run keyword and continue on failure
    ...    should contain    ${rre[2]}    c1: rrcReestablishmentComplete (3)    case_insensitive=${True}
    ...    whitespace_insensitive=${True}

Verify RRCReconfiguration messages should be correct after RRE in f1ap log
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${log_path_pcap}
#    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    catenate      ((f1ap.procedureCode == 12) && (nr-rrc.c1 == 0)) ||  ((f1ap.procedureCode == 13) && (nr-rrc.c1 == 1))
#    ${RrcReconf}    pcap.filter_packets_by_expression
#    ...    filter_expression=${filter}
#    ${rrc_reconfiguration}    run keyword and continue on failure    pcap.get_field_value_by_name    field_name=nr-rrc.c1   attribute_name=showname
    cap.setup      infile=${log_path_pcap}    display_filter=${filter}    alias=test_rrc_reconfig
    pcap.get_packets    filter=${filter}    pcap_parser=test_rrc_reconfig
    ${rrc_reconfiguration}    run keyword and continue on failure    pcap.get_field_value
    ...    field_name=nr-rrc.c1   fmt=showname    pcap_parser=test_rrc_reconfig

    ${length}    Get Length    ${rrc_reconfiguration}
    ${remainder}    evaluate    ${length}%2
    run keyword and continue on failure    should be true    ${remainder}==${0}
    run keyword and continue on failure    should be true    ${length}>=${4}
    run keyword and continue on failure    should contain    ${rrc_reconfiguration[0]}    c1: rrcReconfiguration (0)    case_insensitive=${True}
    ...    whitespace_insensitive=${True}
    run keyword and continue on failure    should contain    ${rrc_reconfiguration[1]}    c1: rrcReconfigurationComplete (1)
    ...    case_insensitive=${True}    whitespace_insensitive=${True}
