*** Settings ***
Documentation
...   This is for  TA common keywords
...   squad group: MMW_SG1
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    ./5GC001911-CA-variable.robot
#Library     OperatingSystem
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ipsl.robot
Variables   ../testdata/5GC001911_CA_scf_modify.py
Library    taf.analyzer.pcap    WITH NAME    pcap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource    ../../5GC001581/Resources/5GC001581_keywords.robot
Resource    ../../5GC001911_AA/Resources/5GC001911_AA_keywords.robot
*** Keywords ***
Check QCI in X2log
    [Documentation]    author: Fang ludan
    ...     Description:check QCI in X2log
    [Arguments]    ${x2ap_log}
    ${request}      pcap.filter_packets_by_expression
    ...    filter_expression=(((x2ap.procedureCode == 29) ) && (x2ap.X2AP_PDU == 0)) && (x2ap.qCI == 8)
    ${RqCI8}        Get field value by xpath       packets=${request}    field_name=.//x2ap.full_E_RAB_Level_QoS_Parameters_element/x2ap.qCI
    ${E_RAB}        Get field value by xpath       packets=${request}    field_name=.//x2ap.E_RABs_ToBeAdded_SgNBModReq_Item_element/x2ap.e_RAB_ID
    ${Req_time}    pcap.get_field_value_by_name    field_name=frame.time_relative    attribute_name=show
    should be equal as integers    ${RqCI8[0]}      8
    ##check x2ap modfify request

    ${Ack}      pcap.filter_packets_by_expression
    ...    filter_expression=(((x2ap.procedureCode == 29) ) && (x2ap.id == 219)) && (x2ap.qCI == 8)
    ${AqCI8}        Get field value by xpath       packets=${Ack}   field_name=.//x2ap.mCG_E_RAB_Level_QoS_Parameters_element/x2ap.qCI
    ${Ack_time}      pcap.get_field_value_by_name    field_name=frame.time_relative    attribute_name=show
    should be equal as integers    ${AqCI8[0]}     8
    ##check ack

    ${complete}      pcap.filter_packets_by_expression
    ...    filter_expression=x2ap.procedureCode == 28
    ${Comp_time}    pcap.get_field_value_by_name    field_name=frame.time_relative    attribute_name=show
    ##check complete

    ${Transfer}      pcap.filter_packets_by_expression
    ...    filter_expression=(x2ap.X2AP_PDU == 0) && (x2ap.e_RAB_ID == ${E_RAB[0]})&&(x2ap.id == 19)
    ${Tran_time}    pcap.get_field_value_by_name    field_name=frame.time_relative    attribute_name=show
    ##check transfer

    ${Req_time_float}      evaluate     float(${Req_time[0]})
    ${Ack_time_float}      evaluate     float(${Ack_time[0]})
    ${Comp_time_float}     evaluate     float(${Comp_time[-1]})
    ${Tran_time_float}     evaluate     float(${Tran_time[0]})
    ##transform types

    should be true      ${Req_time_float}<${Ack_time_float}<${Comp_time_float}<${Tran_time_float}
    ##check time of log

check QCI in X2log additionRequest
    [Documentation]    author: Fang ludan
    ...     Description:check QCI in X2log
    [Arguments]    ${x2ap_log}
    ${request}   pcap.filter_packets_by_expression
    ...    filter_expression=(((x2ap.procedureCode == 27) ) && (x2ap.X2AP_PDU == 0))
    ${RqCI7_8_9}   Get field value by xpath     packets=${request}    field_name=.//${QCIXpath1}/${QCIXpath2}
    ${exp_QCI}  create list   8  7  9
    ${QCI_status}   run keyword and return status   should be equal   ${RqCI7_8_9}   ${exp_QCI}
    [Return]    ${QCI_status}

Get field value by xpath
    [Arguments]    ${packets}    ${field_name}    ${attribute_name}=show
    ${values}    pcap.get_field_value_by_xpath    pdml_list=${packets}    xpath=${field_name}    attribute_name=${attribute_name}
    [Return]    ${values}

modify parameter on ENB
    [Documentation]    Description: modify parameter on ENB.
    [Arguments]        ${parameters_to_update_via_api}=${MODIFY_ENB_ADMINISTRATIVESTATE_LOCK_VIA_API}
    Connect to eNB via ssl    connection=enblte
    ${update_status}    COAM Update several parameters via rest api    connection=enblte
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
    Should be true    '${update_status}'=='PASS'
    @{MOs}    enblte.get_managed_objects    class_name=LNADJGNB_A    connection=enblte
    [Teardown]    Enblte close down    connection=enblte



IPSL stop
    [Arguments]   ${ue_index}=${0}    ${ipsl_alias}=ipsl    ${ipsl_listen_port}=13868
    ...    ${ipsl_tool_dir}=${IPSL_TOOL_DIR}    ${ipsl_compiler_flags}=${IPSL_COMPILER_FLAGS}
    ...    ${ipsl_srv_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${ipsl_user}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${ipsl_pw}=${tl.ues[${ue_index}].ssh_connection_details.password}
    connect to IPSL server    ipsl_srv_ip=${ipsl_srv_ip}    ipsl_user=${ipsl_user}    ipsl_pw=${ipsl_pw}    ipsl_alias=${ipsl_alias}
    Stop IPSL server process    ipsl_alias=${ipsl_alias}




check UL&DL Tput
    [Arguments]     ${ue_tput_dict}
    should be true        ${ue_tput_dict['UE1_DL']['port${UE1_DL_PORT_QCI7}']}>=50
    should be true        ${ue_tput_dict['UE1_DL']['port${UE1_DL_PORT_QCI8}']}>=50
    should be true        ${ue_tput_dict['UE1_DL']['port${UE1_DL_PORT_QCI9}']}>=50
    should be true        ${ue_tput_dict['UE1_UL']['port${UE1_UL_PORT_QCI7}']}>=30
    should be true        ${ue_tput_dict['UE1_UL']['port${UE1_UL_PORT_QCI8}']}>=30
    should be true        ${ue_tput_dict['UE1_UL']['port${UE1_UL_PORT_QCI9}']}>=30
