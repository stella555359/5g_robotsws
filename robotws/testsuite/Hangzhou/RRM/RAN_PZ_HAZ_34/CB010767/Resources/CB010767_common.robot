*** Settings ***
Documentation    This is for feature CB009363 related common keywords.
...              Please do not modify the file without notification to author
...              Author:stella.lin@nokia-sbell.com
...              Squard: HZ SG6

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    CB010767_case_steps.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Modify actRedCapUeSupport Online
    [Arguments]    ${value}=true    ${cell_id}=1
    Log To Console    ---start to change actRedCapUeSupport to ${value}---
    ${actRedCapUeSupport}   catenate   {'abbr':'actRedCapUeSupport','dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}',
    ...    'filter_param':'Activate reduced capability UE support','new_value':'${value}'}
    ${actRedCapUeSupport_update}    Evaluate     [${actRedCapUeSupport}]
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${actRedCapUeSupport_update}
    ...    download_dir=${TS_CASE_LOG_PATH}
    Sleep    30s
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
	selenium_coam.enable_virtual_display
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate reduced capability UE support
    ...    abbr=actRedCapUeSupport
    ...    new_value=${value}
    ...    timeout=${120}
    log to console  start to validate and activate
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    Sleep   60 sec
    log to console  activate done!wait for gnb on air......
    Wait For Onair And Check No Alarm    allowed_faults=${ALLOWED_FAULTS_LIST}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM selenium logout    AND
    ...    Run Keyword And Ignore Error    selenium_coam.disable_message_box

Modify cellBarredRedCap Online
    [Arguments]    ${value}=no barring    ${cell_id}=1
    Log To Console    ---start to change cellBarredRedCap to ${value}---
    ${cellBarredRedCap}   catenate   {'abbr':'cellBarredRedCap','dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}',
    ...    'filter_param':'Cell barred reduced capability','new_value':'${value}'}
    ${cellBarredRedCap_update}    Evaluate     [${cellBarredRedCap}]
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${cellBarredRedCap_update}
    ...    download_dir=${TS_CASE_LOG_PATH}
    Sleep    30s
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
	selenium_coam.enable_virtual_display
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Cell barred reduced capability
    ...    abbr=cellBarredRedCap
    ...    new_value=${value}
    ...    timeout=${120}
    log to console  start to validate and activate
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    Sleep   60 sec
    log to console  activate done!wait for gnb on air......
    Wait For Onair And Check No Alarm    allowed_faults=${ALLOWED_FAULTS_LIST}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM selenium logout    AND
    ...    Run Keyword And Ignore Error    selenium_coam.disable_message_box

Modify ReaCap Params Online
    [Arguments]    ${redcap_support_value}=true    ${cell_barred_value}=no barring    ${cell_id}=1
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
	selenium_coam.enable_virtual_display
    Log To Console    ---Start to set actRedCapUeSupport to ${redcap_support_value}--
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate reduced capability UE support
    ...    abbr=actRedCapUeSupport
    ...    new_value=${redcap_support_value}
    ...    timeout=${120}
    Log To Console    ---Start to set cellBarredRedCap to ${cell_barred_value}--
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Cell barred reduced capability
    ...    abbr=cellBarredRedCap
    ...    new_value=${redcap_support_value}
    ...    timeout=${120}
    log to console  start to validate and activate
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    Sleep   60 sec
    log to console  activate done!wait for gnb on air......
    Wait For Onair And Check No Alarm    allowed_faults=${ALLOWED_FAULTS_LIST}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM selenium logout    AND
    ...    Run Keyword And Ignore Error    selenium_coam.disable_message_box

Update Related Parameters For AMF HO
    Log To Console    \n***start to Update Related Parameters For AMF HO***
    ${pdcpSNLengthRedCap1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-1',
    ...    'parameter':'pdcpSNLengthRedCap','value':'len18bits'}
    ${pdcpSNLengthRedCap2}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-2',
    ...    'parameter':'pdcpSNLengthRedCap','value':'len18bits'}
    ${pdcpSNLengthRedCap3}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-3',
    ...    'parameter':'pdcpSNLengthRedCap','value':'len18bits'}
    ${rlcAMDrbSNLengthRedCap1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_RLC_AM-1',
    ...    'parameter':'rlcAMDrbSNLengthRedCap','value':'rlcAm18bitSN'}
    ${rlcAMDrbSNLengthRedCap2}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_RLC_AM-2',
    ...    'parameter':'rlcAMDrbSNLengthRedCap','value':'rlcAm18bitSN'}
    ${handoverAllowedSA}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3/NRREL-256',
    ...    'parameter':'handoverAllowedSA','value':'XnHoNotAllowed'}
    ${TAC}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3/NRPLMNSET_SA-1',
    ...    'parameter':'trackingAreaDN','value':'TRACKINGAREA-20309'}
    ${AMF}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1',
    ...    'parameter':'administrativeState','value':'Locked'}
    ${update_param_list}     Catenate    ${pdcpSNLengthRedCap1},${pdcpSNLengthRedCap2},${pdcpSNLengthRedCap3},${rlcAMDrbSNLengthRedCap1},
    ...                                  ${rlcAMDrbSNLengthRedCap2},${handoverAllowedSA},${TAC},${AMF}
    ${update_param_list}     Evaluate    [${update_param_list}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param_list}    gnb_index=0

Recover Related Parameters For AMF HO
    Log To Console    \n***start to Update Related Parameters For AMF HO***
    ${pdcpSNLengthRedCap1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-1',
    ...    'parameter':'pdcpSNLengthRedCap','value':'len12bits'}
    ${pdcpSNLengthRedCap2}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-2',
    ...    'parameter':'pdcpSNLengthRedCap','value':'len12bits'}
    ${pdcpSNLengthRedCap3}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-3',
    ...    'parameter':'pdcpSNLengthRedCap','value':'len12bits'}
    ${rlcAMDrbSNLengthRedCap1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_RLC_AM-1',
    ...    'parameter':'rlcAMDrbSNLengthRedCap','value':'rlcAm12bitSN'}
    ${rlcAMDrbSNLengthRedCap2}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_RLC_AM-2',
    ...    'parameter':'rlcAMDrbSNLengthRedCap','value':'rlcAm12bitSN'}
    ${handoverAllowedSA}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3/NRREL-256',
    ...    'parameter':'handoverAllowedSA','value':'allowed'}
    ${TAC}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3/NRPLMNSET_SA-1',
    ...    'parameter':'trackingAreaDN','value':'TRACKINGAREA-20300'}
    ${AMF}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1',
    ...    'parameter':'administrativeState','value':'Unlocked'}
    ${update_param_list}     Catenate    ${pdcpSNLengthRedCap1},${pdcpSNLengthRedCap2},${pdcpSNLengthRedCap3},${rlcAMDrbSNLengthRedCap1},
    ...                                  ${rlcAMDrbSNLengthRedCap2},${handoverAllowedSA},${TAC},${AMF}
    ${update_param_list}     Evaluate    [${update_param_list}]
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${update_param_list}    gnb_index=0

Enable Required PA Port
    [Documentation]   stella.lin@nokia-sbell.com
    [Arguments]    ${attenuator_index}=${2}    ${pa_port_index}=${${1},${2},${3},${4}}    ${value}=10    ${ip_not_in_init}=${False}
    ${pa_port_index_type}    Evaluate    type(${pa_port_index}).__name__
    ${convert_pa_port_index_to_list}    Create List    ${pa_port_index}
    ${pa_port_index}    Set Variable If    'list' in '${pa_port_index_type}' or 'tuple' in '${pa_port_index_type}'
    ...      ${pa_port_index}     ${convert_pa_port_index_to_list}
    @{channels}    Set Variable    ${tl.attenuator[${attenuator_index}].attenuator_ports}
    ${ip_addr}    set variable if    ${ip_not_in_init}==${False}    ${tl.attenuator[${attenuator_index}].ip_addr}    ${None}
#    ${ip_addr}    set variable     ${tl.attenuator[${attenuator_index}].ip_addr}
    ${port}    set variable     ${tl.attenuator[${attenuator_index}].port}
    ${vendor}    set variable    ${tl.attenuator[${attenuator_index}].vendor}
    ${model}    set variable     ${tl.attenuator[${attenuator_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=${vendor}
    ...    model=${model}
    ${value}    Evaluate    float(${value})
    @{values}    Create List
    FOR    ${index}    IN    @{pa_port_index}
        Append To List    ${values}    ${value}
    END
    Wait Until Keyword Succeeds   5min   5sec   attenuator.set_ports_attenuation   ports=${pa_port_index}   values=${values}   confirm=True
    Log To Console    \n change attenuation to ${value}

Check Redcap RxType On wireshark With nsetapx
    [Arguments]    ${cpif_log_path}   ${RX_type}=0   ${Supported_redCap}=True
    ${filter_expression}    Catenate    nsetapx.nodeType == gnb-cu-Id && nsetapx.traceActivationType == mba &&
    ...    nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord
    pcap.setup    infile=${cpif_log_path}    display_filter=nsetapx.CuVendorExtensionRecordDataType == ueInfoRecord    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${redCapSupported}    pcap.get_field_value    field_name=nsetapx.redCapSupported
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${redCapRxType}    pcap.get_field_value    field_name=nsetapx.redCapRxType
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${redCapSupported_invalid}    Evaluate    [x[0] for x in ${redCapSupported} if x[0]!='${Supported_redCap}']
    ${redCapRxType_invalid}    Evaluate    [x[0] for x in ${redCapRxType} if x[0]!='${RX_type}']
    ${status_RX_type}    Set Variable If   '${RX_type}'=='0'    1RX
    ...                  '${RX_type}'=='1'    2RX
    ...                   others
    ${status_redCapSupported}    Set Variable If   '${Supported_redCap}'=='1'    support    not_support
    Run Keyword And Continue On Failure    Should Be Empty    ${redCapSupported_invalid}
    ...    msg=msg=cell for redCapSupported is not ${status_redCapSupported}
    Run Keyword And Continue On Failure    Should Be Empty    ${redCapRxType_invalid}
    ...    msg=msg=cell for redCapRxType is not ${status_RX_type}

Start BIP Capture
    [Arguments]    ${nr_phy_cell_ids}=771    ${capture_time}=15
    ...            ${target_file_name}=l1l2bip_log    ${gnb_index}=0    ${target_dir}=${TS_CASE_LOG_PATH}
    ${trace_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${target_file_name}    Set Variable    ${target_file_name}_${trace_timestamp}
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}
    ...                                          nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                          gnb_index=${gnb_index}
    sleep    ${capture_time}
    ${bip_log_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    ...                                                                 target_dir=${target_dir}
    [Return]    ${bip_log_path[0]}
    [Teardown]    Run Keyword And Ignore Error    Stop Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}

Check Barred Status On SIB
    [Arguments]    ${bip_log_path}    ${RedCap1Rx_status}=1    ${RedCap2Rx_status}=1
    Setup Pcap File   file_path=${bip_log_path}   filter=nr-rrc
    ${cellBarredRedCap1Rx}    Get Field Value From PCAP    field_name=nr-rrc.cellBarredRedCap1Rx_r17
    ...    filter_expression=nr-rrc.cellBarredRedCap1Rx_r17
    ${cellBarredRedCap2Rx}    Get Field Value From PCAP    field_name=nr-rrc.cellBarredRedCap2Rx_r17
    ...    filter_expression=nr-rrc.cellBarredRedCap1Rx_r17
    ${1RX_invalid}    Evaluate    [x[0] for x in ${cellBarredRedCap1Rx} if x[0]!='${RedCap1Rx_status}']
    ${2RX_invalid}    Evaluate    [x[0] for x in ${cellBarredRedCap2Rx} if x[0]!='${RedCap2Rx_status}']
    ${status_1RX}    Set Variable If   '${RedCap1Rx_status}'=='1'    notBarred    barred
    ${status_2RX}    Set Variable If   '${RedCap2Rx_status}'=='1'    notBarred    barred
    Run Keyword And Continue On Failure    Should Be Empty    ${1RX_invalid}
    ...    msg=msg=cell for RedCap1Rx_status is not ${status_1RX}
    Run Keyword And Continue On Failure    Should Be Empty    ${2RX_invalid}
    ...    msg=msg=cell for RedCap2Rx_status is not ${status_2RX}

Check A2 Measurement Report
    [Arguments]    ${cpif_log_path}   ${pci}=771
    ${filter_expression}    Catenate    ((nr-rrc.measQuantityResults.rsrp) && (!nr-rrc.measResultNeighCells == 0))
    ...   && (f1ap.procedureCode == 13)
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${actual_pci}    pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    Should Be Equal As Integers    ${actual_pci[0][0]}    ${pci}    msg=A2 MR is not triggered success.

Check A5A3 Measurement Report
    [Arguments]    ${cpif_log_path}   ${exp_source_pci}=771    ${exp_target_pci}=772
    ${filter_expression}    Catenate    nr-rrc.measResultNeighCells == 0
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${actual_pci}    pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${source_pci}    Set Variable   ${actual_pci[0][0]}
    ${target_pci}    Set Variable   ${actual_pci[-1][1]}
    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${source_pci}    ${exp_source_pci}
    ...   msg=A3/A5 MR is not triggered success
    Run Keyword And Continue On Failure     Should Be Equal As Integers    ${target_pci}    ${exp_target_pci}
    ...   msg=A3/A5 MR is not triggered success

Check RRC Reconfigure And RRC Reconfigure Complete
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}    ${ssbfrequency}=154570
    Log    ${ssbfrequency}
    ${filter_expression}    Catenate    f1ap.procedureCode == 12 && nr-rrc.gapUE == 0
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${rrc_transaction_identifier}    pcap.get_field_value    field_name=nr-rrc.rrc_TransactionIdentifier
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${complete_filter_expression}    Catenate    nr-rrc.rrcReconfigurationComplete_element &&
    ...                                          nr-rrc.rrc_TransactionIdentifier==${rrc_transaction_identifier[0][0]}
    pcap.setup    infile=${cpif_log_path}    display_filter=${complete_filter_expression}    alias=test0
    pcap.get_packets    filter=${complete_filter_expression}   pcap_parser=test0
    ${rrc_transaction_identifier_complete}    pcap.get_field_value    field_name=nr-rrc.rrc_TransactionIdentifier
    ...    filter=${complete_filter_expression}
    ...    pcap_parser=test0
    Should Not Be Empty    ${rrc_transaction_identifier}    msg=RRC Reconfiguration message not triggered success.
    Should Not Be Empty    ${rrc_transaction_identifier_complete}    msg=RRC Reconfiguration Complete message not triggered success.

Check RRC Reconfigure And RRC Reconfigure Complete For InterGNB
    [Documentation]    Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${source_ho_log_path}    ${target_ho_log_path}
    ${filter_expression}    Catenate    f1ap.procedureCode == 7 && nr-rrc.measObjectToAddModList && nr-rrc.csi_ReportConfigToAddModList
    pcap.setup    infile=${source_ho_log_path}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${rrc_transaction_identifier}    pcap.get_field_value    field_name=nr-rrc.rrc_TransactionIdentifier
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    ${complete_filter_expression}    Catenate    f1ap.procedureCode == 13 &&
    ...                                          nr-rrc.rrc_TransactionIdentifier==${rrc_transaction_identifier[0][0]}
    pcap.setup    infile=${target_ho_log_path}    display_filter=${complete_filter_expression}    alias=test1
    pcap.get_packets    filter=${complete_filter_expression}   pcap_parser=test1
    ${rrc_transaction_identifier_complete}    pcap.get_field_value    field_name=nr-rrc.rrc_TransactionIdentifier
    ...    filter=${complete_filter_expression}
    ...    pcap_parser=test1
    Should Not Be Empty    ${rrc_transaction_identifier}    msg=RRC Reconfiguration message not triggered success.
    Should Not Be Empty    ${rrc_transaction_identifier_complete}    msg=RRC Reconfiguration Complete message not triggered success.

Check RRC Reestablishment
    [Documentation]    Auther:Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}
    ${filter_expression}    Catenate    nr-rrc.rrcReestablishmentRequest_element
    pcap.setup    infile=${cpif_log_path}    display_filter=${filter_expression}    alias=test0
    ${status}    Run Keyword And Return Status    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${pci}    Run Keyword If    '${status}'=='${True}'     pcap.get_field_value    field_name=nr-rrc.physCellId
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
    Run Keyword If    '${status}'=='${True}'    Fail    msg=cell with pci ${pci} have RRC Reestablishment happend.

BTS Counters List For 9568
    [Documentation]    author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_id}=0
    ${bts_Name}    Get Bts Name For Gnb    gnb_id=${gnb_id}
    ${counters}    Catenate
    ...    {'M55140C00001': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/RSANB/PEAK_NUMBER_OF_SA_RRC_USERS_CU'},
    ...    {'M55140C00002': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/RSANB/PEAK_NBR_OF_SA_NGBR_USERS_CU'},
    ...    {'M55140C00101': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/RSANB/MAX_RRC_NR_SA_UES_CU'},
    ...    {'M55140C00102': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/RSANB/MAX_REDCAP_UES_CU'},
    ...    {'M55140C00501': '[${bts_Name}] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/RSANB/PEAK_NBR_OF_SA_GBR_USERS_CU'}
    ${counter_info_dict_list}    Evaluate    [${counters}]
    [Return]    ${counter_info_dict_list}

Verify PM Counter Values For 9568
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${counter_id_mapping_values}    ${handover_type}=intra
#    ${counter1_list}    Create List    M55140C00001    M55140C00002    M55140C00102=1/2#
#    ${counter2_list}    Create List    M55140C00101    M55140C00501
    ${M55140C00001_value}    convert to integer     ${counter_id_mapping_values['M55140C00001']}
    ${M55140C00002_value}    convert to integer     ${counter_id_mapping_values['M55140C00002']}
    ${M55140C00102_value}    convert to integer     ${counter_id_mapping_values['M55140C00102']}
    ${M55140C00101_value}    convert to integer     ${counter_id_mapping_values['M55140C00101']}
    ${M55140C00501_value}    convert to integer     ${counter_id_mapping_values['M55140C00501']}
    Run Keyword If    '${handover_type}'=='inter'
    ...               Run Keyword And Continue On Failure    Should Be True    ${M55140C00102_value}==int(${1})
    ...         ELSE IF    '${handover_type}'=='intra'
    ...                Run Keyword And Continue On Failure    Should Be True    int(${2})<=${M55140C00102_value}<=int(${3})
    Run Keyword And Continue On Failure    Should Be True    ${M55140C00001_value}==${M55140C00101_value}+${M55140C00102_value}
    Run Keyword And Continue On Failure    Should Be True    ${M55140C00102_value}<=${M55140C00002_value}<=${M55140C00001_value}
    Run Keyword And Continue On Failure    Should Be True    ${M55140C00501_value}==int(${0})
#
#    FOR    ${counter1}    IN    @{counter1_list}
#        ${value}     Set Variable    ${counter_id_mapping_values['${counter1}']}
#        IF    '${handover_type}'=='inter'
#            Run Keyword And Continue On Failure    Should Be True    int(${value}) == int(${1})
#        ELSE IF    '${handover_type}'=='intra'
#            Run Keyword And Continue On Failure    Should Be True    int(${1}) <= int(${value}) <= int(${2})
#        END
#    END
#    FOR    ${counter2}    IN    @{counter2_list}
#        ${value}     Set Variable    ${counter_id_mapping_values['${counter2}']}
#        Run Keyword And Continue On Failure    Should Be True    int(${value}) == int(${0})
#    END

Perform gNB Restart And Check on air via rest api
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                <<Keyword>> is to restart gnb one time and check gnb on air status.
    ...                Recommend to use this keywoed in TEST SETUP.
    [Arguments]    ${timeout}=600   ${connection}=GNB_OAM    ${is_x2_check_from_gnb_needed}=${True}
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${connection}
    COAM Wait for gnb ready and cell setup    timeout=20 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair