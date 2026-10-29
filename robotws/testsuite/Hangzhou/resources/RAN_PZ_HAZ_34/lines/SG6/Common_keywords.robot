*** Settings ***
Documentation    This is for all SG6 related common keywords.
...              Please do not modify the file without notification to author
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    ./Common_setup_and_teardown.robot



*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${CP_Runtime_file}    /home/ute/SCF/cp_runtime.ini


*** Keywords ***
Modify Attenuation Channel Vaules
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Modify attenuation values for every ru cell.
    ...               :param  if is matrix, the max-value is 63, if is PA, the max-value is 127
    [Arguments]    ${value}=63    ${vendor}=HBTE    ${ru_id}=0    ${gnb_id}=0
    ${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator    ip_addr=${tl.attenuator.ip_addr}
    ...                            port=${tl.attenuator.port}
    ...                            attenuation_port_numbers=${channels}
    ...                            vendor=${vendor}
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}

Get Managed Objects Via Rest API
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               :param ${class_name} like as NRREL_A
    ...               _R MO    - Runtime view object defined by external parties: NIDD, ADMIN, SYSADAPTER.
    ...               _M MO    - Runtime view object defined by a manager. Used for internal OAM communication.
    ...               _L MO    - Objects created by services. Often referred to as HW objects.
    ...               _A MO    - Objects from network plan. Defined in NIDD without “_A” suffix.
    ...               _NOTIF    - Object created by service, used to notify manager or indicator about a needed action.
    [Arguments]    ${class_name}=NRREL_A    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=${60}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${managed_objects}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}    timeout=${timeout}
    [Return]    ${managed_objects}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Get The Nrrel Index
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Only support one nrrel under one cell
    [Arguments]    ${class_name}=NRREL_A    ${cell_index}=1    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=${60}
    ${managed_objects}    Get Managed Objects Via Rest API    class_name=${class_name}
    ...                                          connection=${connection}
    ...                                          gnb_index=${gnb_index}
    ...                                          timeout=${timeout}
    FOR    ${managed_objects}    IN    @{managed_objects}
        ${distName}    Get From Dictionary    ${managed_objects}    key=distName
        ${status}    Run Keyword And Return Status    Should Contain    ${distName}    NRCELL_A-${cell_index}
        ${nrrel_index}    Run Keyword If    '${status}'=='True'    Fetch From Right    ${distName}    -
        Exit For Loop If    '${status}'=='True'
    END
    [Return]    ${nrrel_index}

Update Params Via RestApi
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...               param:${params_need_to_modify}, List
    [Arguments]    ${params_need_to_modify}    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ...    ${skip_parameter_relation_errors}=False    ${check_on_air}=${True}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_need_to_modify}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Run Keyword If    ${check_on_air}    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Update Params Via RestApi For ASOG
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...               param:${params_need_to_modify}, List
    [Arguments]    ${params_need_to_modify}    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ...    ${skip_parameter_relation_errors}=False
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_need_to_modify}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    Wait Gnb Ready And Cell On Air For ASOG    gnb_id=${gnb_index}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Get UE IP Address
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               get pdu ip addr in message <InitialContextSetupRequest,DL NAS transport,pdu session establishment accept>
    ...               message filter: ngap.procedureCode == 14 && nas_5gs.sm.pdu_addr_inf_ipv4
    ...               If MultiPdu is configured, second pdu ip addr can be get from message <PDUSessionResourceSetupRequest>
    ...               message filter: ngap.procedureCode == 29 &&  nas_5gs.sm.pdu_addr_inf_ipv4
    [Arguments]    ${cpif_log_path}    ${is_multi_pdu}=${False}    ${pdu_index}=0    ${mode}=SA
    ${ue_ip_list}    Create List
    ${first_pdu_ip}    Run Keyword If    '${mode}'=='SA'
    ...            Check Target Item Value on CPIF Tcpdump
    ...                file_path=${cpif_log_path}
    ...                filter_expression=ngap.procedureCode == 14 && nas_5gs.sm.pdu_addr_inf_ipv4
    ...                xpath=.//nas_5gs.sm.pdu_addr_inf_ipv4
    ...                filter=f1ap||nr-rrc||ngap
    ...    ELSE    Check Target Item Value on CPIF Tcpdump
    ...                file_path=${cpif_log_path}
    ...                filter_expression=s1ap.procedureCode == 9 && nas_eps.esm.pdn_ipv4
    ...                xpath=.//nas_eps.esm.pdn_ipv4
    ...                filter=f1ap||nr-rrc||s1ap
    Append To List    ${ue_ip_list}    ${first_pdu_ip}[0]
    ${second_pdu_ip}    Run Keyword If    ${is_multi_pdu} and '${mode}'=='SA'
    ...             Check Target Item Value on CPIF Tcpdump
    ...                 file_path=${cpif_log_path}
    ...                 filter_expression=ngap.procedureCode == 29 && nas_5gs.sm.pdu_addr_inf_ipv4
    ...                 xpath=.//nas_5gs.sm.pdu_addr_inf_ipv4
    ...                 filter=f1ap||nr-rrc||ngap
    ...    ELSE IF    ${is_multi_pdu} and '${mode}'=='NSA'
    ...             Check Target Item Value on CPIF Tcpdump
    ...                 file_path=${cpif_log_path}
    ...                 filter_expression=s1ap.procedureCode == 19 && nas_eps.esm.pdn_ipv4
    ...                 xpath=.//nas_eps.esm.pdn_ipv4
    ...                 filter=f1ap||nr-rrc||s1ap
    Run Keyword If    ${is_multi_pdu}    Append To List    ${ue_ip_list}    ${second_pdu_ip}[0]
    ${ue_ip}    Set Variable    ${ue_ip_list}[${pdu_index}]
    Should Not Be Empty    ${ue_ip}    msg=get ue ip failed from attach log.
    [Return]    ${ue_ip}

Get NR Cell Identity
    [Documentation]    Author:stella.lin@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
    ${nrCellIdentity_list}    Create List
    FOR    ${item}    IN     @{cell_id_list}
        ${nrCellIdentity}    Evaluate    int(${cell_mapping[${item}]['nrCellIdentity']})
        Append To List    ${nrCellIdentity_list}    ${nrCellIdentity}
    END
    [Return]    ${nrCellIdentity_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get NR Cell And Cell Identity Mapping
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
    ${nrCellIdentity_dic}    Create Dictionary
    FOR    ${item}    IN     @{cell_id_list}
        ${nrCellIdentity}    Evaluate    int(${cell_mapping[${item}]['nrCellIdentity']})
        Set To Dictionary    ${nrCellIdentity_dic}    ${item}    ${nrCellIdentity}
    END
    [Return]    ${nrCellIdentity_dic}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get Cell Physical ID
    [Documentation]    Author:stella.lin@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_cell_info    connection_alias=${connection}
    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
    ${physical_id_list}    Create List
    FOR    ${item}    IN     @{cell_id_list}
        ${physical_id}    Evaluate    int(${cell_mapping[${item}]['physicalCellId']})
        Append To List    ${physical_id_list}    ${physical_id}
    END
    [Return]    ${physical_id_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get Chbw Info
    [Documentation]    Author:stella.lin@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
    ${chbw_list}    Create List
    FOR    ${item}    IN     @{cell_id_list}
      ${chbw}    coam_parameter.get_single_value_from_scf_file    parameter=chBw    dist_name=NRBTS-${NRBTS_ID}/NRCELL-${item}
      ...                                                         connection=${connection}
      ${chbw}    Set Variable    ${chbw.split('M')[0]}
      Append To List    ${chbw_list}    ${chbw}
    END
    [Return]    ${chbw_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get Nrarfcn Info
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_cell_info    connection_alias=${connection}
    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
    ${nrarfcn_id_list}    Create List
    FOR    ${item}    IN     @{cell_id_list}
        ${nrarfcn_id}    Evaluate    int(${cell_mapping[${item}]['nrarfcn']})
        Append To List    ${nrarfcn_id_list}    ${nrarfcn_id}
    END
    [Return]    ${nrarfcn_id_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get ssbFrequency Value From SCF
    [Documentation]   Auther:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM     ${gnb_index}=0
    ${ssbFrequency_list}    Create List
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
    FOR    ${cell_index}    IN     @{cell_id_list}
        ${ssbFrequency}    coam_parameter.get_single_value_from_scf_file
        ...                              parameter=ssbFrequency
        ...                              dist_name=NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRHOIF-1
        ...                              connection=${connection}
        Append To List    ${ssbFrequency_list}    ${ssbFrequency}
    END
    [Return]    ${ssbFrequency_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Create Cplane Runtime File On Cluster
    [Documentation]   Auther:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${connection}=ASIK Master
    ${status}    Run Keyword And Return Status     OperatingSystem.File Should Exist    ${CP_Runtime_file}
    Run Keyword If    ${status}    Run Keyword    Upload Cplane Runtime File    connection=${connection}
    ...        ELSE   Run Keywords    Connect to Common Unit Master
    ...        AND       ssh.send_command    command=echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini    connection=${connection}
    ...        AND       ssh.send_command      command=crasign /ffs/run/cp_runtime.ini    connection=${connection}
    [Teardown]     Run Keyword And Ignore Error    ssh.disconnect    connection=${connection}

Upload Cplane Runtime File
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${connection}=ASIK Master
    Connect to Common Unit Master
    ssh.upload_file    local_path=/home/ute/SCF/cp_runtime.ini    remote_path=/ffs/run/cp_runtime.ini    connection=${connection}
    ssh.send_command    command=ls -al /ffs/run/    connection=${connection}
    ${file_list}    ssh.read_output    connection=${connection}
    Should Contain    ${file_list}    cp_runtime.ini
    ssh.send_command      command=crasign /ffs/run/cp_runtime.ini    connection=${connection}
    [Teardown]     Run Keyword And Ignore Error    ssh.disconnect    connection=${connection}

Get Multi BTS Counters Information
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${counter_info_dict_list}    ${gnb_id}=0    ${timeout}=60
    COAM Navigate to login page via webUI    timeout=${timeout}    gnb_index=${gnb_id}
    ${counters_result_dict}    Create Dictionary
    FOR    ${item}    IN    @{counter_info_dict_list}
        ${counter_id_and_full_path}    Get Dictionary Items    ${item}
        ${counter_result}    selenium_coam.get_bts_counters_info    counter_id=${counter_id_and_full_path}[0]
        ...                                                         full_path=${counter_id_and_full_path}[1]
        ...                                                         timeout_for_loading_available_counters=${timeout}
        Set To Dictionary    ${counters_result_dict}    ${counter_id_and_full_path}[0]=${counter_result}
    END
    [Return]    ${counters_result_dict}
    [Teardown]    selenium_coam.logout

Check IE Values On Measurement Report Message
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               Checkpoint:Measurement Report Message should contain configured source and neighbor cell id
    ...               Comment: wireshark is captured in source cell, should be captured after attach before handover.
    ...                        use condition nr-rrc.servCellId == 0 to filter Measurement Report Message.
    [Arguments]    ${wireshark_log}    ${connection}=GNB_OAM    ${gnb_id}=0    ${source_cell_id}=${PCELL_ID}    ${scell_id}=${SCELL_ID}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    ${source_cell_id_on_scf}     coam_parameter.get_single_value_from_scf_file    parameter=physCellId
    ...                                                                           dist_name=NRBTS-${NRBTS_ID}/NRCELL-${source_cell_id}
    ...                                                                           connection=${connection}
    ${scell_id_on_scf}     coam_parameter.get_single_value_from_scf_file    parameter=physCellId
    ...                                                                     dist_name=NRBTS-${NRBTS_ID}/NRCELL-${scell_id}
    ...                                                                     connection=${connection}
    Convert CPIF Pcap To Pdml    file_path=${wireshark_log}    filter=nr-rrc
    ${source_cell_id_on_wireshark}    Get Field Value From Pdml
    ...                                              filter_expression=nr-rrc.MeasResultServMO_element
    ...                                              xpath=.//nr-rrc.measResultServingCell_element/nr-rrc.physCellId
    ...                                              attribute_name=show
    ${neighbor_cell_id_on_wiresahrk}    Get Field Value From Pdml
    ...                                              filter_expression=nr-rrc.measResultNeighCells
    ...                                              xpath=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId
    ...                                              attribute_name=show
    Should Be Equal    ${source_cell_id_on_scf}    ${source_cell_id_on_wireshark}[0]
    ...                msg=source physical cell id is not include in measurement report
    ${status}    Evaluate    '${neighbor_cell_id_on_wiresahrk}[0]'!='${scell_id_on_scf}[0]'
    Should Be True    ${status}    msg=neighbor physical cell id is not include in measurement report
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Online Cell AdministrativeState Modification
    [Documentation]    author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_index}=${PCELL_ID}    ${cell_administrativeState}=Locked
    ${cell_administrativeState_parameter}    Catenate
    ...    {'abbr': 'administrativeState', 'dist_name': 'NRCELL-${cell_index}',
    ...     'filter_param': 'Administrative state','new_value': '${cell_administrativeState}'}
    ${update_param_list}    Evaluate    [${cell_administrativeState_parameter}]
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${update_param_list}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${True}

Remove Value Of Matched Strings From List
    [Documentation]    author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${list}    ${matched_strings}
    FOR    ${item}    IN    @{list}
        ${index}    Get Index From List    ${list}    ${item}
        ${status}    Run Keyword And Return Status    Should Contain    ${item}    ${matched_strings}
        Run Keyword If    '${status}'=='${True}'    Remove From List      ${list}    ${index}
    END
    [Return]    ${list}

COAM Delete Several Object Via Rest Api
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...              Description: this keyword is to delete several object via rest api.
    ...    ${parameters_to_update_via_api} should be given in special format, as the following:
    ...    ${parameters_to_update_via_api}=[{'dist_name': 'NRBTS-1/NRCELL-1'}, {'dist_name': 'NRBTS-1/NRCELL-1'}]
    ...    ${update_via_api_status} will be returned, if the parameter requires the reset of bts in order to take effect,
    ...    additional check will be required.
    ...     Note: if use this keyword to modify p_name involving in list_name, then all other p_name which exist in this list_name
    ...          should be given thoroughly as well.
    [Arguments]    ${parameters_to_update_via_api}    ${timeout}=${60}    ${connection}=GNB_OAM    ${should_activate}=${True}
    ${para_file}    coam_parameter.create_delete_objects_delta
    ...    parameters=${parameters_to_update_via_api}
    ...    connection=${connection}
    ${update_via_api_status}    coam_parameter.perform_scf_delta_commission
    ...    delta_file=${para_file['updated']}
    ...    timeout=${timeout}
    ...    connection=${connection}
    ...    should_activate=${should_activate}
    ${msg_for_parameter_activation_not_executed}    Catenate    Parameter update activation for ${parameters_to_update_via_api} is not executed,
    ...    due to flag should_activate is set to ${should_activate}
    Run keyword if    '${should_activate}'=='${True}'
    ...    Should contain    ${update_via_api_status}    PASS    msg=parameters do not update successfully.    ignore_case=${True}
    ...    ELSE    Log to console     ${msg_for_parameter_activation_not_executed}
    [Return]   ${update_via_api_status}

Get ALL PDU IP Address From Wireshark
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               get pdu ip addr in message <InitialContextSetupRequest,DL NAS transport,pdu session establishment accept>
    ...               message filter: ngap.procedureCode == 14 && nas_5gs.sm.pdu_addr_inf_ipv4
    ...               If MultiPdu is configured, second pdu ip addr can be get from message <PDUSessionResourceSetupRequest>
    ...               message filter: ngap.procedureCode == 29 &&  nas_5gs.sm.pdu_addr_inf_ipv4
    ...               return dict：{ims:xx,data:xx}
    [Arguments]    ${cpif_log_path}    ${is_multi_pdu}=${False}    ${alias}=parser    ${mode}=SA    ${ip_type}=4
    log    ${is_multi_pdu}
    ${version}    OperatingSystem.Run    wireshark -version
    ${wireshark_version}   Get Regexp Matches    ${version}    Wireshark (...)    1
#    ${5gs_filter}    Set Variable If    '${wireshark_version[0]}'=='4.2'    nas-5gs    nas_5gs
#    ${eps_filter}    Set Variable If    '${wireshark_version[0]}'=='4.2'    nas-eps    nas_eps
    ${5gs_filter}    Set Variable    nas-5gs
    ${eps_filter}    Set Variable    nas-eps
    ${first_pdu_ip_message_filter}    Set Variable If     '${mode}'=='SA'    ngap.procedureCode == 14 && ${5gs_filter}.sm.pdu_addr_inf_ipv${ip_type}
    ...                                                                      s1ap.procedureCode == 9 && ${eps_filter}.esm.pdn_ipv${ip_type}
    ${second_pdu_ip_message_filter}    Set Variable If     '${mode}'=='SA'    ngap.procedureCode == 29 && ${5gs_filter}.sm.pdu_addr_inf_ipv${ip_type}
    ...                                                                       s1ap.procedureCode == 19 && ${eps_filter}.esm.pdn_ipv${ip_type}
    ${pdu_ip_xpath}    Set Variable If     '${mode}'=='SA'    .//${5gs_filter}.sm.pdu_addr_inf_ipv${ip_type}    .//${eps_filter}.esm.pdn_ipv${ip_type}
    ${dnn_xpath}    Set Variable If     '${mode}'=='SA'    .//${5gs_filter}.cmn.dnn    .//${eps_filter}.esm.qci
    ${cmd}    Set Variable    /usr/bin/tshark -r {pcap_file} -o nas-5gs.null_decipher:TRUE -Y \"${first_pdu_ip_message_filter}\" -T pdml
    pcap.load_pcap_file    pcap_file=${cpif_log_path}    command_template=${cmd}    alias=${alias}
#    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${first_pdu_ip_message_filter}    alias=${alias}
    ${first_pdu_ip}     pcap.get_field_value_by_xpath    xpath=${pdu_ip_xpath}     pcap_parser=${alias}
    ${first_dnn_value}    pcap.get_field_value_by_xpath    xpath=${dnn_xpath}     pcap_parser=${alias}
    ${first_pdu_ip_dnn_pair}    Evaluate    list(zip(${first_pdu_ip},${first_dnn_value}))
    ${pdu_ip_dnn_dict}    Create Dictionary
    FOR  ${item}  IN  @{first_pdu_ip_dnn_pair}
      ${ip_types}    Set Variable If    '${item[-1]}'=='ims' or '${item[-1]}'=='5'    ims    data
      Set To Dictionary    ${pdu_ip_dnn_dict}     ${ip_types}    ${item[0]}
    END
    ${cmd2}    Set Variable    /usr/bin/tshark -r {pcap_file} -o nas-5gs.null_decipher:TRUE -Y \"${second_pdu_ip_message_filter}\" -T pdml
    pcap.load_pcap_file    pcap_file=${cpif_log_path}    command_template=${cmd2}    alias=${alias}
#    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}
#    ...                          filter=${second_pdu_ip_message_filter}
#    ...                          alias=${alias}
    ${second_pdu_ip}     pcap.get_field_value_by_xpath    xpath=${pdu_ip_xpath}     pcap_parser=${alias}
    ${second_dnn_value}    pcap.get_field_value_by_xpath    xpath=${dnn_xpath}     pcap_parser=${alias}
    ${second_pdu_ip_dnn_pair}    Evaluate    list(zip(${second_pdu_ip},${second_dnn_value}))
    FOR  ${item}  IN  @{second_pdu_ip_dnn_pair}
      ${ip_types}    Set Variable If    '${item[-1]}'=='ims' or '${item[-1]}'=='5'    ims    data
      Set To Dictionary    ${pdu_ip_dnn_dict}     ${ip_types}    ${item[0]}
    END
    Log to console    All pdu ip address are : ${pdu_ip_dnn_dict}
    run keyword if  not ${pdu_ip_dnn_dict}    Fail    msg=fail to get ue ip from wireshark。
    [Return]    ${pdu_ip_dnn_dict}

Collect Snapshot Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM    ${log_path}=${TS_CASE_LOG_PATH}     ${timeout}=${1200}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                             gnb_index=${gnb_index}
    ${snapshot_file_path}    COAM Save snapshot via rest api    connection=${connection}
    ...                                                         log_path=${log_path}
    ...                                                         timeout=${timeout}
    [Return]    ${snapshot_file_path}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Collect Snapshot Log Via WebUI
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Description: Snapshot logs will be stored under the indicate download_dir
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${log_timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            ${snapshot_timeout}=${1800}
    ...            ${coverage}=All log files
    ...            ${save_location}=Local
    ${temp_dir_for_save_snapshot}    Set Variable    /tmp/snapshot_ta
    Create Directory    ${temp_dir_for_save_snapshot}
    Wait Until Keyword Succeeds    2min    20sec    COAM Navigate to login page via webUI    download_dir=${temp_dir_for_save_snapshot}
    ...    timeout=${log_timeout}    gnb_index=${gnb_index}    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.snapshot_collection_settings    coverage=${coverage}    save_location=${save_location}
    ${temp_snapshot_file_path}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=${snapshot_timeout}

    Wait Until Keyword Succeeds    2min    2sec    File should not be empty    ${temp_snapshot_file_path}
    ${final_snapshot_file_path}    Wait Until Keyword Succeeds    3x    200ms    Copy file and verify file exists
    ...    source_file_path=${temp_snapshot_file_path}    dest_file_folder=${download_dir}
    [Return]    ${final_snapshot_file_path}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    COAM selenium logout    AND
    ...                           Run Keyword And Ignore Error    Empty Directory    path=${temp_dir_for_save_snapshot}

Collect Enb Snapshot Log
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${connection}=enblte_${enb_index}    ${log_path}=${TS_CASE_LOG_PATH}     ${timeout}=${1200}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
    ${snapshot_file_path}    COAM Save snapshot via rest api    connection=${connection}
    ...                                                         log_path=${log_path}
    ...                                                         timeout=${timeout}
    [Return]    ${snapshot_file_path}
    [Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Remove The Value With Special String From List
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${list}    ${str}
    FOR    ${i}    IN    @{list}
        ${index}    Get Index From List    ${list}    ${i}
        Run Keyword If    '${str}' in '${i}'    Remove From List    ${list}    ${index}
    END
    [Return]    ${list}


#--- Common keywords for Vonr/Emergency Call---#
Make Emergency Call
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               lock_ue_screen: adb -s {} shell 'input keyevent 3;input keyevent 26'
    ...               unlock_ue_screen: adb -s {} shell 'input keyevent 26;sleep 1;input keyevent 82'
    [Arguments]    ${ue_index}=${0}
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_POWER    connection=cpc_${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME    connection=cpc_${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell 'input keyevent 26;sleep 1;input keyevent 82'    connection=cpc_${ue_index}
    Sleep    3sec
    Run Keyword If  '${ue_type}'=='mtk'    csn.send_command
    ...      command=adb -s ${serial_number} shell am start -a android.intent.action.CALL -d tel:911    connection=cpc_${ue_index}
    ...      ELSE    csn.send_command
    ...      command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL -d tel:911    connection=cpc_${ue_index}
    Sleep    3sec
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_ENTER    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Hang Up Emergency Call
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${sleep_time}=5sec
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_POWER    connection=cpc_${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap 540 1992    connection=cpc_${ue_index}
    Sleep    3sec
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_HOME    connection=cpc_${ue_index}
    Sleep    ${sleep_time}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Make Vonr Call
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...            ${phone_number}=+6688
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Hang Up Vonr Call
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...            ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${sleep_time}=5sec
    ...            ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...            ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...            ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=adb -s ${serial_number} shell input keyevent KEYCODE_ENDCALL    connection=cpc_${ue_index}
    Sleep    ${sleep_time}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Answer Vonr Call
    [Arguments]    ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    sleep   1s
    ####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=${connection}
    sleep   1s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=${connection}
    sleep   1s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 5    connection=${connection}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Make Vonr Call in cycles
    [Documentation]   Auther:xiangsheng.chu@nokia-sbell.com
    ...               Make Vonr Call with loop
    [Arguments]    ${count_times}
    FOR    ${i}    IN  RANG  ${count_times}
    	Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
        ...                                    tcpdump_collector_name=vonr_call
    	...                                    asik_connection_alias=ASIK Master
    	...                                    gnb_index=${0}
    	Make Vonr Call
    	sleep	2s
    	${vonr_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection    tcpdump_collector_name=vonr_call
    	sleep	3s
    	Check VoNR Call Success    log_path=${vonr_wireshark}
    	Hang Up Vonr Call
    END

Check VoNR Call Success
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               Check vonr call success via wireshark log
    [Arguments]    ${log_path}    ${alias}=parser
    ${cmd}    Set Variable    /usr/bin/tshark -r {pcap_file} -o nas-5gs.null_decipher:TRUE -T pdml
    pcap.load_pcap_file    pcap_file=${log_path}    command_template=${cmd}    alias=${alias}
#    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    # Check PDUSessionResourceModifyRequest
    ${PDUSessionResourceModifyRequest}    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and nas_5gs.sm.5qi==1
    Log To Console    Check PDUSessionResourceModifyRequest
    ${PDUSessionResourceModifyRequest_status}    Run Keyword And Return Status
    ...    pcap.get_packets    filter=${PDUSessionResourceModifyRequest}    pcap_parser=${alias}
    Should Be Equal    ${PDUSessionResourceModifyRequest_status}    ${True}

    pcap.load_pcap_file    pcap_file=${log_path}    command_template=${cmd}    alias=${alias}
    # BearerContextModificationRequest
    ${BearerContextModification}    Catenate    e1ap.E1AP_PDU == 2
    Log To Console    Check BearerContextModificationRequest whether failure
    ${BearerContextModification_status}    Run Keyword And Return Status
    ...    pcap.get_packets    filter=${BearerContextModification}    pcap_parser=${alias}
    Should Be Equal    ${BearerContextModification_status}    ${False}

    pcap.load_pcap_file    pcap_file=${log_path}    command_template=${cmd}    alias=${alias}
#    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    # Check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer}    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    Check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status}    Run Keyword And Return Status
    ...    pcap.get_packets    filter=${DLRRCMessageTransfer}    pcap_parser=${alias}
    Should Be Equal    ${DLRRCMessageTransfer_status}    ${True}

    pcap.load_pcap_file    pcap_file=${log_path}    command_template=${cmd}    alias=${alias}
#    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    # Check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse}    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    Check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status}   Run Keyword And Return Status
    ...    pcap.get_packets    filter=${PDUSessionResourceModifyResponse}    pcap_parser=${alias}
    Should Be Equal    ${PDUSessionResourceModifyResponse_status}    ${True}

    pcap.load_pcap_file    pcap_file=${log_path}    command_template=${cmd}    alias=${alias}
#    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    # Check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer}    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    Check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status}    Run Keyword And Return Status
    ...    pcap.get_packets    filter=${ULRRCMessageTransfer}    pcap_parser=${alias}
    Should Be Equal    ${ULRRCMessageTransfer_status}    ${True}

    pcap.load_pcap_file    pcap_file=${log_path}    command_template=${cmd}    alias=${alias}
#    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    # Check release value on PDUSessionResourceModifyRequest message
    Log To Console    Check release value on PDUSessionResourceModifyRequest message
    ${Vonr_release_message}    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.nas==0
    ${Vonr_release_message_status}    Run Keyword And Return Status
    ...    pcap.get_packets    filter=${Vonr_release_message}    pcap_parser=${alias}
    Should Be Equal    ${Vonr_release_message_status}    ${True}

Check Emergency Call Success
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               Check 911 call success via wireshark log
    [Arguments]    ${log_path}    ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap    ${alias}=parser    ${req_type}=3
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    ${req_type_value}    Get Field Value From Pdml    filter_expression=ngap.procedureCode == 46 &&nas_5gs.mm.req_type
    ...                                               xpath=.//nas_5gs.mm.req_type
    ...                                               attribute_name=show
    Should Be Equal    ${req_type_value}[0]    ${req_type}    msg=Emergency call is not successful for req_type:${req_type_value}

Check VoLTE Call Success
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               Check vonr call success via wireshark log
    [Arguments]    ${log_path}    ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap    ${alias}=parser
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    # Check BearerContextReleaseComplete after make volte call
    ${BearerContextReleaseComplete}    Get Field Value From Pdml    filter_expression=e1ap.procedureCode == 11
    ...                                                             xpath=.//e1ap.BearerContextReleaseComplete_element
    ...                                                             attribute_name=showname
    Should Be Equal    ${BearerContextReleaseComplete}[0]    BearerContextReleaseComplete

    # Check sgNBAdditionRequest after hand up volte call
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    ${sgNBAdditionRequest}    Run Keyword And Return Status    pcap.get_packets    filter=x2ap.procedureCode == 27    pcap_parser=${alias}
    Should Be Equal    ${sgNBAdditionRequest}    ${True}

Get UE CRNTI From Wireshark
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               filter message UEContextSetUpResponse:
    ...               ngap||f1ap||nr-rrc && f1ap.procedureCode == 5&&f1ap.C_RNTI
    [Arguments]    ${cpif_log_path}    ${alias}=parser
    ${message_filter}    Set Variable    f1ap.procedureCode == 5 && f1ap.C_RNTI
    Convert CPIF Pcap To Pdml    file_path=${cpif_log_path}    filter=${message_filter}    alias=${alias}
    ${crnti}     pcap.get_field_value_by_xpath    xpath=.//f1ap.C_RNTI     pcap_parser=${alias}
    [Return]    ${crnti[0]}

Check CGI For ANR From Wireshark
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    ...               Check cgi whether in the reconfiguration message
    ...               Check cgi whether in the MR message
    [Arguments]    ${log_path}    ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap||s1ap    ${alias}=parser
    ...            ${drxLongCycle_value}=320ms     ${drxOnDurationTimer_value}=10ms   ${ue_mode}=SA
    ...            ${whether_nr_to_lte}=${False}
    Log To Console     Check cgi whether in the reconfiguration message
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    ${cgi_procedureCode_filter}    Set Variable If     '${ue_mode}'=='SA'     12     30
    ${cgi_procedureCode_ue_mode_filter}    Set Variable If     '${ue_mode}'=='SA'     f1ap     x2ap
    ${cgi_in_reconfiguration_procedureCode_filter}    catenate
    ...    nr-rrc.reportType==2&&${cgi_procedureCode_ue_mode_filter}.procedureCode==${cgi_procedureCode_filter}
    ${cgi_in_reconfiguration}   Run Keyword And Return Status
    ...    pcap.get_packets    filter=${cgi_in_reconfiguration_procedureCode_filter}    pcap_parser=${alias}
    Should Be Equal    ${cgi_in_reconfiguration}    ${True}

    Log To Console     Check cgi whether in the MR message
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    ${cgi_procedureCode_for_plmn_filter}    Set Variable If     '${ue_mode}'=='SA'     13     35
    ${nr_ho_nr_filter}    catenate
    ...    ${cgi_procedureCode_ue_mode_filter}.procedureCode==${cgi_procedureCode_for_plmn_filter}&&nr-rrc.plmn_IdentityInfoList
    ${nr_ho_lte_filter}   Set Variable    nr-rrc.plmn_IdentityList_eutra_epc
    ${cgi_in_reconfiguration_procedureCode_filter}   Set Variable If    ${whether_nr_to_lte}    ${nr_ho_lte_filter}    ${nr_ho_nr_filter}
    ${cgi_in_mr}   Run Keyword And Return Status
    ...    pcap.get_packets    filter=${cgi_in_reconfiguration_procedureCode_filter}    pcap_parser=${alias}
    Should Be Equal    ${cgi_in_mr}    ${True}
    Convert CPIF Pcap To Pdml    file_path=${log_path}    filter=${filter}    alias=${alias}
    ${rx_LongCycleStartOffset}   Set Variable If     '${drxLongCycle_value}'=='320ms'     11
    ...                                              '${drxLongCycle_value}'=='640ms'     13
    ${drx_InactivityTimer}       Set Variable If     '${drxOnDurationTimer_value}'=='10ms'   7
    ...                                              '${drxOnDurationTimer_value}'=='20ms'   8
    ${drxLongCycle_filter_expression}    catenate
    ...    nr-rrc.reportType == 2&&nr-rrc.drx_LongCycleStartOffset == ${rx_LongCycleStartOffset}
    ${drxInactivityTimer_filter_expression}    catenate
    ...    nr-rrc.reportType == 2&&nr-rrc.milliSeconds == ${drx_InactivityTimer}
    ${rx_LongCycleStartOffset_in_mr}     Run Keyword And Return Status
    ...    pcap.get_packets    filter=${drxLongCycle_filter_expression}    pcap_parser=${alias}
    ${drxInactivityTimer_in_mr}     Run Keyword And Return Status
    ...    pcap.get_packets    filter=${drxInactivityTimer_filter_expression}    pcap_parser=${alias}
    Should Be Equal    ${rx_LongCycleStartOffset_in_mr}    ${True}
    Should Be Equal    ${drxInactivityTimer_in_mr}    ${True}

Get Subcell Ids
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ssh.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=GNB_${gnb_index}
    ${output}    ssh.execute    command=cat /ram/NrCellMappingInfo.txt    connection=GNB_${gnb_index}
    ${valid_lines_all}    Get Lines Matching Regexp    ${output}    \\d+\\s+\\S\\d\\s+0x    partial_match=true
    @{valid_lines}    Split To Lines    ${valid_lines_all}
    Log   ${valid_lines}
    ${DL_indices}    Evaluate    [index for (index, item) in enumerate(${valid_lines}) if 'DL' in item]
    ${UL_indices}    Evaluate    [index for (index, item) in enumerate(${valid_lines}) if 'UL' in item]
    Log to console       ${DL_indices}
    Log to console       ${UL_indices}
    ${subcell_ids_result}    Create Dictionary
    ${line_tag}    Set Variable    ${0}
    FOR    ${dl_line_index}    IN    @{DL_indices}
        ${ul_line_index}    Set Variable    ${UL_indices[${line_tag}]}
        ${line_context}    Set Variable    ${valid_lines[${dl_line_index}:${ul_line_index}]}
        ${line_length}     Get Length    ${line_context}
        ${subcell_elements}    Evaluate     list(map(lambda x:x.strip(), ${line_context}))
        ${subcell0_elements}    Get Regexp Matches    ${subcell_elements[0].strip()}    \\S+
        ${cell_index}     Set Variable    ${subcell0_elements[0]}
        ${subcell0_id}     Set Variable    ${subcell0_elements[7]}
        ${subcell1_id}     Run Keyword If     ${line_length}==${2}    Set Variable    ${subcell_elements[-1].strip()[0]}
        ${sub_dict}     Create Dictionary     subcell0_id=${subcell0_id}    subcell1_id=${subcell1_id}
        ${line_tag}    Evaluate    ${line_tag}+1
        set to dictionary    ${subcell_ids_result}    ${cell_index}     ${sub_dict}
    END
    [Return]    ${subcell_ids_result}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=GNB_${gnb_index}

Enable capture soap log
    [Documentation]    Author: Stella
    [Arguments]    ${is_right_blade}=${False}
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master0
    Run Keyword If    ${is_right_blade}    csn.connect to
    ...    hostname=fct-4a
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=ASIK Master1
    ...    proxy=ASIK Master0
    ${connection_alias}    Set Variable If    ${is_right_blade}    ASIK Master1    ASIK Master0
    Connect to RU With Allocated IP    ru_alias=RU_1    asik_alias=${connection_alias}
    Enable capture soap msg flag on RU    ru_alias=RU_1
    [Teardown]    Run keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=RU_1    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master1  AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master0

Download SOAP log
    [Documentation]    Author: Stella
    [Arguments]    ${is_right_blade}=${False}
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master0
    Run Keyword If    ${is_right_blade}    csn.connect to
    ...    hostname=fct-4a
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=ASIK Master1
    ...    proxy=ASIK Master0
    ${connection_alias}    Set Variable If    ${is_right_blade}    ASIK Master1    ASIK Master0
    Connect to RU With Allocated IP    ru_alias=RU_1    asik_alias=${connection_alias}
    ${SOAP_LOG_PATH}    Download soap msg from RU Reg   soap_log=UnitOAM_SOAP_Log*.xml    log_path=${TS_CASE_LOG_PATH}    ru_alias=RU_1
    Set Test Variable    ${SOAP_LOG_PATH}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    csn.Disconnect    connection=RU_1    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master1  AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master0

Do gNB Reset site and Wait Onair
    [Documentation]         Reset site
    [Arguments]    ${connection}=GNB_OAM     ${timeout}=30min
    Connect to gnb coam via ssl
    coam.reset_site         connection=${connection}
    sleep    30s
    Wait Gnb Ready And Cell On Air    timeout=${timeout}

ULMUMIMO.Check UE Paried Status Via TTITrace
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]     ${ttitrace_filt_path}
    ...             ${exp_staus}=paried
    ...             ${is_ulmustatus_need_to_check}=${True}
    ...             ${ulmustatus}=MUPAIRED_NO_TAPERING
    ...             ${percent_exp}=0.94
    ...             ${checked_pair_ue_rnti}=${None}
    ...             ${is_ulmugroup_status_need_to_check}=${False}
    ...             ${group_paird_percent_exp}=0.1
    check_ul_ue_paried_status_for_ues     file_path=${ttitrace_filt_path}
    ...                                   expect_pair_status=${exp_staus}
    ...                                   is_ulmustatus_need_to_check=${is_ulmustatus_need_to_check}
    ...                                   ulmustatus=${ulmustatus}
    ...                                   percent_exp=${percent_exp}
    ...                                   checked_pair_ue_rnti=${checked_pair_ue_rnti}
    ...                                   is_ulmugroup_status_need_to_check=${is_ulmugroup_status_need_to_check}
    ...                                   group_paird_percent_exp=${group_paird_percent_exp}

ULMUMIMO.Check Single UE Average Tput Via TTITrace
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${ttitrace_filt_path}=${None}
    ...            ${expect_tput_value}=${None}
    ...            ${unexpect_bler}=0.05
    ...            ${average_tput_percent}=0.9
    ${ue_tputs}    calculate_ubler_and_ultput_for_ues    file_path=${ttitrace_filt_path}
    ${ue_rnti_list}    Get Dictionary Keys    ${ue_tputs}
    ${expect_tput}=    Evaluate    float(${expect_tput_value} * ${average_tput_percent})
    ${unexpect_bler}=    Evaluate    float(${unexpect_bler})
    FOR    ${rnti}    IN    @{ue_rnti_list}
        ${average_tput}    Set Variable    ${ue_tputs['${rnti}']['tput']}
        ${average_bler}    Set Variable    ${ue_tputs['${rnti}']['bler']}
        Run Keyword If    ${expect_tput}>${average_tput}    Fail
        ...               avg ul tput of ue ${rnti} is ${average_tput}, expect result is ${expect_tput}
        Run Keyword If    ${average_bler}>${unexpect_bler}    Fail
        ...               avg ul bler of ue ${rnti} is ${average_bler}, too high!
    END

Check Single UE UL Average Tput Via TTiTrace
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ttitrace_filt_path}=${None}
    ...            ${expect_tput_value}=${None}
    ...            ${unexpect_bler}=0.05
    ...            ${average_tput_percent}=0.9
    ...            ${ue_number}=${4}
    ${ue_tputs}    calculate_ubler_and_ultput_for_ues    file_path=${ttitrace_filt_path}
    ${ue_rnti_list}    Get Dictionary Keys    ${ue_tputs}
    ${expect_tput}    Evaluate    float(${expect_tput_value} / ${ue_number} * ${average_tput_percent})
    ${unexpect_bler}    Evaluate    float(${unexpect_bler})
    FOR    ${rnti}    IN    @{ue_rnti_list}
        ${average_tput}    Set Variable    ${ue_tputs['${rnti}']['tput']}
        ${average_bler}    Set Variable    ${ue_tputs['${rnti}']['bler']}
        Run Keyword If    ${expect_tput}>${average_tput}    Fail
        ...               avg ul tput of ue ${rnti} is ${average_tput}, expect result is ${expect_tput}
        Run Keyword If    ${average_bler}>${unexpect_bler}    Fail
        ...               avg ul bler of ue ${rnti} is ${average_bler}, too high!
    END

Check Single UE DL Average Tput Via TTiTrace
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ttitrace_filt_path}=${None}
    ...            ${expect_tput_value}=${None}
    ...            ${unexpect_bler}=0.05
    ...            ${average_tput_percent}=0.9
    ...            ${ue_number}=${4}
    ${ue_tputs}    calculate_dlbler_and_dltput_for_ues    file_path=${ttitrace_filt_path}
    ${ue_rnti_list}    Get Dictionary Keys    ${ue_tputs}
    ${expect_tput}    Evaluate    float(${expect_tput_value} / ${ue_number} * ${average_tput_percent})
    ${unexpect_bler}    Evaluate    float(${unexpect_bler})
    FOR    ${rnti}    IN    @{ue_rnti_list}
        ${average_tput}    Set Variable    ${ue_tputs['${rnti}']['tput']}
        ${average_bler}    Set Variable    ${ue_tputs['${rnti}']['bler']}
        Run Keyword If    ${expect_tput}>${average_tput}    Fail
        ...               avg ul tput of ue ${rnti} is ${average_tput}, expect result is ${expect_tput}
        Run Keyword If    ${average_bler}>${unexpect_bler}    Fail
        ...               avg ul bler of ue ${rnti} is ${average_bler}, too high!
    END

ULMUMIMO.Activate UL MUMIMO
    [Arguments]    ${cell_index}=1
    Log To Console    \n***start to activate UL MUMIMO***
    ${update_param_branch}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...    'parameter':'actUlMuMimo','value':'true'}
    ${update_param_branch}     evaluate    [${update_param_branch}]
    ${update_param_Trunk}    catenate
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actUlMuMimo','value':'true'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'actHighSpeedCell','value':'false'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}','parameter':'prachSequenceType','value':'Unrestricted'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...                 'parameter':'ulDMRSAdditionalPosition','value':'One additional DMRS'},
    ...               {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}',
    ...                 'parameter':'dlDMRSAdditionalPosition','value':'One additional DMRS'}
    ${update_param_Trunk}     evaluate    [${update_param_Trunk}]
    ${update_param}    Set Variable If    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'    ${update_param_Trunk}    ${update_param_branch}
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

ULMUMIMO.Modify UL MUMIMO Param ulSinrDiffThreshold
    [Arguments]    ${cell_index}=1    ${update_value}=-5
    Log To Console    \n***start to Modify UL MUMIMO Param ulSinrDiffThreshold***
    ${update_param}    catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRULMUMIMO-0',
    ...    'parameter':'ulSinrDiffThreshold','value':'${update_value}'}
    ${update_param}     evaluate    [${update_param}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param}    gnb_index=0

Wait For Onair And Check No Alarm
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0    ${allowed_faults}=${ALLOWED_FAULT}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}
    ...    connection=${connection}
    Run Keyword And Continue On Failure    Wait Gnb Ready And Cell On Air    gnb_id=${gnb_index}   connection=${connection}
    Run Keyword And Continue On Failure    should be true    ${alarm_status}    msg=unexpect alarm exist

Do ADB Reboot
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot   connection=cpc_${ue_index}
    Sleep    10s
    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}
    ...                                                                   serial_number=${tl.ues[${ue_index}].serial_number}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

Get Mapping Between Cell Index And NrCellIdentity Via WebEM
    [Arguments]  ${cell_id}    ${technology}=NR
    Selenium Login And Disable Screen Lock
    ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_id}    technology=${technology}
    ${cell_index}    Convert To Integer    ${cell_info}[Global cell ID]
    @{split_cell_group}    string.split string    ${cell_info}[Cell group]    separator=-
    ${cell_group_index}    Convert To Integer    ${split_cell_group}[-1]
    ${nr_cell_identity}    Convert To Integer    ${cell_info}[NR cell ID]
    ${cell_id_mapping_info}    Create Dictionary    cell_group_id=${cell_group_index}    nrCellIdentity=${nr_cell_identity}
    ${cell_mapping_info}    Create Dictionary    ${cell_index}=${cell_id_mapping_info}
    [Return]    ${cell_mapping_info}
    [Teardown]    Selenium Logout And Close Browser

Get Bts Name For Gnb
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${timeout}=${900}   ${gnb_id}=${0}    ${connection}=GNB_OAM${gnb_id}
    Connect to gnb coam via ssl    gnb_index=${gnb_id}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}
    ${gnb_info}    coam.get_bts_info    connection=${connection}    timeout=${timeout}
    ${bts_Name}    Set Variable    ${gnb_info['name']}
    [Return]    ${bts_Name}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get BTS Counters Value Via WebUI
    [Arguments]    ${counter_info_dict_list}    ${timeout}=360
    ${counters_result_dict}    Get Multi BTS Counters Information    counter_info_dict_list=${counter_info_dict_list}    timeout=${timeout}
    [Return]    ${counters_result_dict}    ${counter_info_dict_list}

Get PM Counter Values Information
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${counter_generatd_time}    ${counter_info_dict_list}    ${timeout}=360
    ${counters_result_dict}    ${counter_info_dict_list}    Get BTS Counters Value Via WebUI
    ...    counter_info_dict_list=${counter_info_dict_list}    timeout=${timeout}
    ${counter_id_mapping_values}    Create Dictionary
    ${counter_items}    Get Dictionary Items    ${counter_info_dict_list}[0]
    ${timestamps}    Set Variable    ${counters_result_dict['${counter_items}[0]']}
    ${started_counter_timestamps}    Get Dictionary Keys    ${timestamps}
    FOR    ${started_counter_timestamp}   IN    @{started_counter_timestamps}
         ${ended_conuter_timestamp}    robot.libraries.DateTime.Add Time To Date    ${started_counter_timestamp}    00:05:00
         ${ended_time}    robot.libraries.DateTime.Convert Date    ${ended_conuter_timestamp}    Epoch
         ${started_time}    robot.libraries.DateTime.Convert Date    ${started_counter_timestamp}    Epoch
         ${status}    Run Keyword And Return Status    Should Be True
         ...          '${started_time}' <= '${counter_generatd_time}' <= '${ended_time}'
         ${counter_belonged_to_timestamp}    Set Variable    ${started_counter_timestamp}
         Exit For Loop If    '${status}'=='True'
    END
    FOR    ${counter_item}    IN    @{counter_info_dict_list}
        ${counter_id}    Get Dictionary Keys    ${counter_item}
        ${counter_timestamps}     Set Variable    ${counters_result_dict['${counter_id}[0]']}
        ${counter_value}    Set Variable    ${counter_timestamps['${counter_belonged_to_timestamp}']}
        ${next_conuter_timestamp}    robot.libraries.DateTime.Add Time To Date    ${counter_belonged_to_timestamp}    00:05:00
        ${next_counter_value}    Set Variable    ${counter_timestamps['${next_conuter_timestamp.split('.')[0]}']}
        ${value}    Evaluate    ${counter_value} + ${next_counter_value}
        Set To Dictionary    ${counter_id_mapping_values}    ${counter_id[0]}    ${value}
    END
    [Return]    ${counter_id_mapping_values}

Netboot Uboot Setting
    [Arguments]    ${ASIK_MASTER_ALIAS}=ASIK Master
    Cloud DU connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    Run Keyword And Continue On Failure    csn.execute    command=uboot_env set netboot=netboot_first
    ...                                                        connection=${ASIK_MASTER_ALIAS}
    Sleep   10sec
    [Teardown]    csn.disconnect    connection=${ASIK_MASTER_ALIAS}

Check ERR Syslog Existed
    ${software_info}     get_build_version_from_robot_variables
    ${Case_NAME}     Remove String    ${TEST NAME}    ${SPACE}
    ${err_base_dir}    Join Path    /home/ute/ERR_WRN_logs/${testline_name}    ${Case_NAME}/${software_info}
    ${file}    ${folder}    get_latest_err_file    folder_path=${err_base_dir}
    ${err_file_path}    Join Path    ${err_base_dir}   ${file}
    ${snapshot_zip_path}    Run Keyword And Continue On Failure    get_snapshot_zip_file_path    err_file_path=${err_file_path}
    ${snapshot_unzip_file_path}    Run Keyword And Continue On Failure
    ...    Run Keyword If    '${snapshot_zip_path}'!='${None}'    ERR_WRN_Check.decompress_snapshot
    ...    log_path=${snapshot_zip_path}
    ${rf_check_err_status}    ${bts_check_err_status}    ${rf_err_print}    ${bts_err_print}
    ...    filter_result_without_warn    err_file_path=${err_file_path}
    ${len_rf_err}     Get Length    ${rf_err_print}
    ${len_bts_err}     Get Length    ${bts_err_print}
    ${rf_err_print_info}     print_err     err_info_list=${rf_err_print}
    ${bts_err_print_info}    print_err     err_info_list=${bts_err_print}
    Run Keyword And Continue On Failure    Run Keyword If    '${rf_check_err_status}'=='False'    Fail
    ...    msg=RF ERR SUM ${len_rf_err}:${rf_err_print_info}
    Run Keyword And Continue On Failure    Run Keyword If    '${bts_check_err_status}'=='False'    Fail
    ...    msg=SYSLOG ERR SUM ${len_bts_err}:${bts_err_print_info}
    [Teardown]    Run Keyword And Ignore Error    run    sudo rm -rf ${snapshot_unzip_file_path}