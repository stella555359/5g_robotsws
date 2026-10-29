*** Settings ***
Resource    ./XPATH.robot
Library    ../../../lib/string_list.py
Library     taf.analyzer.pcap    WITH NAME    pcap
Library     Collections
Library     BuiltIn
Resource    ./Check_VoNR_via_tcpdump_log.robot

Documentation
...   Author: Ding Binmei
...   squad group: MMW_SG1
...   Common checkpoint for CA verification from pcap log

*** Variables ***
${FILTER_RRC_RECONFIG}    nr-rrc.rrcReconfiguration_element
${A1_Configured_RRC_FILTER}       (nr-rrc.rrcReconfiguration_element&&nr-rrc.eventA1_element)
${A2_Configured_RRC_FILTER}       (nr-rrc.rrcReconfiguration_element&&nr-rrc.eventA2_element)

*** Keywords ***
Get CA info from rrc reconfiguration msg
    [Documentation]  Author: Ding Binmei
    ...    Get CA info from RRC reconfiguration msg, and return as a dict. Can extend content if needed.
    ...    ${log_file_path}: pcap log file path
    ...    Return value for maxMIMO_layers if equals -1, means no value found
    ...    Example output: {    'pcell_info': {'pcell_pci': '937', 'pcell_maxMIMO_layers_ul': '1', 'pcell_maxMIMO_layers_dl': '2'},
    ...                         'scell_addition_info': {'ul_ca_scell_pci': ['936'], 'dl_ca_scell_pci': ['938', '940', '936']}
    ...                         'scell_info': {'938': {'scell_maxMIMO_layers_ul': '-1', 'scell_maxMIMO_layers_dl': '2'},
    ...                                        '940': {'scell_maxMIMO_layers_ul': '-1', 'scell_maxMIMO_layers_dl': '4'},
    ...                                        '936': {'scell_maxMIMO_layers_ul': '1', 'scell_maxMIMO_layers_dl': '4'}
    ...                                        }
    ...                     }
    [Arguments]    ${log_file_path}    ${display_filter}=${FILTER_RRC_RECONFIG}
    pcap.setup    infile=${log_file_path}    display_filter=${display_filter}    alias=test0
#    Get pcell info
    @{pcell_pci}    pcap.get_field_value_by_xpath    xpath=${XPATH_PCELL_PCI}    pcap_parser=test0
    &{dict_pcell_info}    Run keyword if    ${pcell_pci}    _Get pcell info from rrc reconfiguration msg    alias=test0
    ...    ELSE    Create Dictionary
#   Get scell addition info
    @{scell_addition_dl_ca_scell_pci}    pcap.get_field_value_by_xpath    xpath=${XPATH_SCELL_ADD_DL_CA_SCELL_PCI}    pcap_parser=test0
    @{scell_addition_ul_ca_scell_pci}    pcap.get_field_value_by_xpath    xpath=${XPATH_SCELL_ADD_UL_CA_SCELL_PCI}    pcap_parser=test0
    ${scell_addition_dl_ca_scell_pci}    Evaluate    list(set(${scell_addition_dl_ca_scell_pci}))
    ${scell_addition_ul_ca_scell_pci}    Evaluate    list(set(${scell_addition_ul_ca_scell_pci}))
    &{dict_scell_addition_info}    Create Dictionary    ul_ca_scell_pci=${scell_addition_ul_ca_scell_pci}
    ...    dl_ca_scell_pci=${scell_addition_dl_ca_scell_pci}
#    Get scell info
    ${all_scells_pci}    Evaluate    list(set(${scell_addition_dl_ca_scell_pci}+${scell_addition_ul_ca_scell_pci}))
    ${scell_info}    Create Dictionary
    FOR    ${scell_pci}    IN    @{all_scells_pci}
        ${xpath_scell_maxMIMO_layers_ul}    ${xpath_scell_maxMIMO_layers_dl}    Get xpath for filter scell maxMIMO layers in RRC message
        ...    scell_pci=${scell_pci}
        ${scell_maxMIMO_layers_ul}    pcap.get_field_value_by_xpath    xpath=${xpath_scell_maxMIMO_layers_ul}    pcap_parser=test0
        ${scell_maxMIMO_layers_ul}    Set variable if    ${scell_maxMIMO_layers_ul}    ${scell_maxMIMO_layers_ul[-1]}    -1
        ${scell_maxMIMO_layers_dl}    pcap.get_field_value_by_xpath    xpath=${xpath_scell_maxMIMO_layers_dl}    pcap_parser=test0
        ${scell_maxMIMO_layers_dl}    Set variable if    ${scell_maxMIMO_layers_dl}    ${scell_maxMIMO_layers_dl[-1]}    -1
        &{dict_scell_info}    Create Dictionary    scell_maxMIMO_layers_ul=${scell_maxMIMO_layers_ul}
        ...    scell_maxMIMO_layers_dl=${scell_maxMIMO_layers_dl}
        Set to dictionary    ${scell_info}    ${scell_pci}=${dict_scell_info}
    END
    &{dict_ca_info_rrc}    Create Dictionary
    Set To Dictionary    ${dict_ca_info_rrc}    pcell_info=${dict_pcell_info}
    Set to dictionary    ${dict_ca_info_rrc}    scell_addition_info=${dict_scell_addition_info}
    Set To Dictionary    ${dict_ca_info_rrc}    scell_info=${scell_info}
    Log to console    ${dict_ca_info_rrc}
    [Return]    ${dict_ca_info_rrc}

_Get pcell info from rrc reconfiguration msg
    [Documentation]  Author: Ding Binmei
    ...    Get pcell info from rrc reconfiguration msg, and return as a dict. Can extend content if needed.
    ...    ${alias}: connection for pcap parser
    ...    Example output: {'pcell_pci': '937', 'pcell_maxMIMO_layers_ul': '1', 'pcell_maxMIMO_layers_dl': '4'}
    [Arguments]    ${alias}=test0
    @{pcell_pci}    pcap.get_field_value_by_xpath    xpath=${XPATH_PCELL_PCI}    pcap_parser=${alias}
    ${pcell_pci}    Set variable    ${pcell_pci[0]}
    ${xpath_pcell_maxMIMO_layers_ul}    ${xpath_pcell_maxMIMO_layers_dl}    Get xpath for filter pcell maxMIMO layers in RRC message
    ...    pcell_pci=${pcell_pci}
    @{pcell_maxMIMO_layers_ul_initial}    pcap.get_field_value_by_xpath    xpath=${xpath_pcell_maxMIMO_layers_ul}    pcap_parser=${alias}
    ${pcell_maxMIMO_layers_ul_initial}    set variable if    ${pcell_maxMIMO_layers_ul_initial}    ${pcell_maxMIMO_layers_ul_initial[-1]}    -1
    @{pcell_maxMIMO_layers_dl_initial}    pcap.get_field_value_by_xpath    xpath=${xpath_pcell_maxMIMO_layers_dl}    pcap_parser=${alias}
    ${pcell_maxMIMO_layers_dl_initial}    Set variable if    ${pcell_maxMIMO_layers_dl_initial}    ${pcell_maxMIMO_layers_dl_initial[-1]}    -1

    @{pcell_maxRank_update_ul_reconfig}    pcap.get_field_value_by_xpath    xpath=${XPATH_PCELL_MAXRANK_CHANGE_UL}    pcap_parser=${alias}
    ${pcell_maxMIMO_layers_ul}    Set variable if    ${pcell_maxRank_update_ul_reconfig}    ${pcell_maxRank_update_ul_reconfig[-1]}
    ...    ${pcell_maxMIMO_layers_ul_initial}
    Run keyword if    '${pcell_maxMIMO_layers_ul}'!='${pcell_maxMIMO_layers_ul_initial}'
    ...    Log to console    pcell_maxMIMO_layers_ul changed from ${pcell_maxMIMO_layers_ul_initial} to ${pcell_maxMIMO_layers_ul} after RRC reconfig
    @{pcell_maxRank_update_dl_reconfig}    pcap.get_field_value_by_xpath    xpath=${XPATH_PCELL_MAXRANK_CHANGE_DL}    pcap_parser=${alias}
    ${pcell_maxMIMO_layers_dl}    Set variable if    ${pcell_maxRank_update_dl_reconfig}    ${pcell_maxRank_update_dl_reconfig[-1]}
    ...    ${pcell_maxMIMO_layers_dl_initial}
    Run keyword if    '${pcell_maxMIMO_layers_dl}'!='${pcell_maxMIMO_layers_dl_initial}'
    ...    Log to console    pcell_maxMIMO_layers_dl changed from ${pcell_maxMIMO_layers_dl_initial} to ${pcell_maxMIMO_layers_dl} after RRC reconfig
    &{dict_pcell_info}    Create Dictionary    pcell_pci=${pcell_pci}    pcell_maxMIMO_layers_ul=${pcell_maxMIMO_layers_ul}
    ...    pcell_maxMIMO_layers_dl=${pcell_maxMIMO_layers_dl}
    [Return]    ${dict_pcell_info}

Get transformPrecoder from rrc reconfiguration msg for pcell
    [Documentation]  Author: Ding Binmei
    ...    Get transformPrecoder value from rrc reconfiguration message for pcell
    ...    Note: Since TP will ping-pong when adjust pcell signal, this is normal behavior as pcell(AHLOA) and scell(AHLOA) have interference
    ...    --  https://jiradc.ext.net.nokia.com/browse/REX-15610, so will ignore this TP pingpong issue in code and will check the
    ...    --  Final status in F1ap.
    ...    Return value with string format. enabled, disabled, invalid
    ...    transformPrecoder='0': Means enabled
    ...    transformPrecoder='1': Means disabled
    ...    others:  Means invalid. then need to check f1ap log manually
    [Arguments]    ${log_file_path}
    pcap.setup    infile=${log_file_path}    display_filter=${FILTER_RRC_RECONFIG}    alias=test0
    ${XPATH_transformPrecoder}    Catenate    SEPARATOR=    //nr-rrc.spCellConfig_element/nr-rrc.spCellConfigDedicated_element//*//
    ...    nr-rrc.pusch_Config/nr-rrc.setup_element/nr-rrc.transformPrecoder
    @{list_transformPrecoder}    pcap.get_field_value_by_xpath    xpath=${XPATH_transformPrecoder}    pcap_parser=test0
    ${transformPrecoder}    Set variable if    '${list_transformPrecoder[-1]}'=='0'    enabled
    ...    '${list_transformPrecoder[-1]}'=='1'    disabled
    ...    invalid
    [Return]    ${transformPrecoder}

Get dlDmrsType from rrc reconfiguration msg for pecll
    [Documentation]  Author: Ding Binmei
    ...    Get dlDmrsType value from rrc reconfiguration message for pcell
    ...    Return value with string format. type1, type2, invalid
    ...    if IE dlDmrsType not exist: Means type1
    ...    if dlDmrsType='2': Means type2
    ...    others:  Means invalid. then need to check f1ap log manually
    [Arguments]    ${log_file_path}
    pcap.setup    infile=${log_file_path}    display_filter=${FILTER_RRC_RECONFIG}    alias=test0
    ${XPATH_dlDmrsType}    Catenate    SEPARATOR=    //nr-rrc.spCellConfig_element/nr-rrc.spCellConfigDedicated_element//*//
    ...    nr-rrc.pdsch_Config//*//nr-rrc.dmrs_Type
    ${pdsch_config_msg}    pcap.get_field_value_by_xpath
    ...    xpath=//nr-rrc.spCellConfig_element/nr-rrc.spCellConfigDedicated_element//*//nr-rrc.pdsch_Config    pcap_parser=test0
    Should Not Be Empty    ${pdsch_config_msg}
    ...    msg=Failed due to not able to get Parent node for dlDmrsType with pdsch config for pcell
    @{list_dlDmrsType}    pcap.get_field_value_by_xpath    xpath=${XPATH_dlDmrsType}    pcap_parser=test0
    ${len_list_dlDmrsType}    Get Length    ${list_dlDmrsType}
    ${dlDmrsType}    Set variable if    ${len_list_dlDmrsType}==${0}    type1
    ...    '${list_dlDmrsType[-1]}'=='0'    type2
    ...    invalid
    [Return]    ${dlDmrsType}

Verify scell addition from f1ap log
    [Documentation]  Author: Ding Binmei
    ...    ${log_file_path}: pcap log file path
    ...    ${scell_index_ul}: scell index for UL CA. Example value: 1,2    ${None} means no ul CA.
    ...    ${scell_index_dl}: scell index for DL CA. Example value: 1,2    ${None} means no dl CA.
    [Arguments]  ${log_file_path}    ${scell_index_ul}=${None}    ${scell_index_dl}=${None}    ${nr_cell_mapping}=${NR_CELL_ID_MAPPING}
    ...    ${display_filter}=${FILTER_RRC_RECONFIG}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${display_filter}     Run Keyword If    '${has_cbts}'=='${True}'
    ...       Set Variable      f1ap.DUtoCURRCInformation_element
    ...     ELSE       Set Variable     ${display_filter}
    ${ca_info_rrc}    Get CA info from rrc reconfiguration msg    log_file_path=${log_file_path}    display_filter=${display_filter}

    ${ul_ca_scell_pci_act}    Set variable    ${ca_info_rrc['scell_addition_info']['ul_ca_scell_pci']}
    ${dl_ca_scell_pci_act}    Set variable    ${ca_info_rrc['scell_addition_info']['dl_ca_scell_pci']}
    ${scell_index_ul}    Run keyword if  ${scell_index_ul}!=${None}    string2list    input_str=${scell_index_ul}
    ...    ELSE    Set variable    ${None}
    ${scell_index_dl}    Run keyword if  ${scell_index_dl}!=${None}    string2list    input_str=${scell_index_dl}
    ...    ELSE    Set variable    ${None}
    ${scell_pci_ul}    Convert cell id to physical cell id    list_cell_index=${scell_index_ul}    nr_cell_mapping=${nr_cell_mapping}
    ${scell_pci_dl}    Convert cell id to physical cell id    list_cell_index=${scell_index_dl}    nr_cell_mapping=${nr_cell_mapping}
    ${scell_index_ul_ca_gap}    Run keyword if  ${scell_pci_ul}!=${None}    Evaluate    list(set(${ul_ca_scell_pci_act})^set(${scell_pci_ul}))
    Run keyword and continue on failure    Run keyword if  ${scell_pci_ul}!=${None}    Should be empty    ${scell_index_ul_ca_gap}
    ...    msg=Expect UL CA on ${scell_pci_ul}, actually UL CA on ${ul_ca_scell_pci_act}
    ...    ELSE    Should be Empty    ${ul_ca_scell_pci_act}
    ...        msg=Should be no UL CA, but actually UL ca exists for bellow cells: ${ul_ca_scell_pci_act}
    ${scell_index_dl_ca_gap}    Run keyword if  ${scell_pci_dl}!=${None}    Evaluate    list(set(${dl_ca_scell_pci_act})^set(${scell_pci_dl}))
    Run keyword and continue on failure    Run keyword if  ${scell_pci_dl}!=${None}    Should be empty    ${scell_index_dl_ca_gap}
    ...    msg=Expect DL CA on ${scell_pci_dl}, actually DL CA on ${dl_ca_scell_pci_act}
    ...    ELSE    Should be Empty    ${dl_ca_scell_pci_act}
    ...        msg=Should be no DL CA, but actually DL ca exists for bellow cells: ${dl_ca_scell_pci_act}

Convert cell id to physical cell id
    [Documentation]  Author: Ding Binmei
    ...    Return with ${None} or list format
    [Arguments]    ${list_cell_index}   ${nr_cell_mapping}
    ${pci}    Run keyword if    ${list_cell_index}!=${None}    _Convert list cell id to physical cell id    list_cell_index=${list_cell_index}
    ...    nr_cell_mapping=${nr_cell_mapping}
    ...    ELSE    Set variable    ${None}
    [Return]  ${pci}

_Convert list cell id to physical cell id
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${list_cell_index}   ${nr_cell_mapping}
    @{list_pci}    Create List
    FOR    ${cell_index}  IN    @{list_cell_index}
        ${cell_index}    Evaluate    int(${cell_index})
        ${pci}    Evaluate    str(${nr_cell_mapping[${cell_index}]['physicalCellId']})
        Append to list    ${list_pci}    ${pci}
    END
    [Return]  ${list_pci}

Verify no scell addition from f1ap log
    [Documentation]    Private    Author: Dandan Fang
    ...    When scell addition method as covBasedA1, A1 info should be configured with first rrc-reconfig.
    ...    ${log_file_path}: pcap log file path
    [Arguments]    ${log_path_pcap}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${display_filter}     Run Keyword If    '${has_cbts}'=='${True}'
    ...           Set Variable      f1ap.DUtoCURRCInformation_element
    ...    ELSE   Set Variable     ${FILTER_RRC_RECONFIG}

    pcap.setup    infile=${log_path_pcap}    display_filter=${display_filter}

    ${ScellIndex}  pcap.get_field_value_by_xpath
    ...      xpath=.//nr-rrc.sCellToAddModList
    ...      attribute_name=showname

    Should be Empty     ${ScellIndex}

Verify Scell Released from F1AP log
    [Documentation]    Private    Author: Dandan Fang
    ...    When scell addition method as covBasedA1, A1 info should be configured with first rrc-reconfig.
    ...    ${log_file_path}: pcap log file path
    ...    ${scell_index}: scell id, can be 1 or 1,2
    [Arguments]    ${log_path_pcap}   ${scell_index}=${1}
    ${scell_index}    string2list    ${scell_index}

    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${display_filter}     Run Keyword If    '${has_cbts}'=='${True}'
    ...       Set Variable      f1ap.DUtoCURRCInformation_element
    ...       ELSE   Set Variable   ${FILTER_RRC_RECONFIG}
    pcap.setup    infile=${log_path_pcap}    display_filter=${display_filter}

    ${release_scell_index}  pcap.get_field_value_by_xpath
    ...      xpath=.//nr-rrc.sCellToReleaseList//nr-rrc.SCellIndex
    ...      attribute_name=show
    sort list    ${release_scell_index}
    should be equal    ${release_scell_index}    ${scell_index}

################ Measurement Event Check ####################################
Verify A1 event configed in F1AP log
    [Documentation]    Private    Author: Dandan Fang
    ...    When scell addition method as covBasedA1, A1 info should be configured with first rrc-reconfig.
    ...    ${log_file_path}: pcap log file path
    ...    Note: cloud NR-RRC is securited , no able to get eventA1_element from nr-rrc and f1ap message, so not check A1 event for Cloud.
    [Arguments]    ${log_path_pcap}   ${display_filter}= ${A1_Configured_RRC_FILTER}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}

    run keyword if   '${has_cbts}'=='${True}'    Run Keywords
    ...   Log To Console     Skip A1 Event for Cloud TL due to nr-rrc message is securited.
    ...   AND     Return from keyword    ${True}

    pcap.setup    infile=${log_path_pcap}    display_filter=${display_filter}

    ${a1Meas_type}  pcap.get_field_value_by_xpath
    ...      xpath=.//nr-rrc.eventA1_element/nr-rrc.a1_Threshold
    ...      attribute_name=showname

    should be equal as strings    rsrp    ${a1Meas_type[0].split()[1]}

Verify A1 measurement report in F1AP log
    [Documentation]    author: Dandan Fang
    ...    ${log_file_path}: pcap log file path
    ...    ${a1_rsrp_thres}: A1 rsrp threshold , same with NIDD used.
    ...    ${cell_id}: cell ID of which A1 event reported.
    ...    ${meas_id}: meas id of A1 event, which is same with reportId.
    [Arguments]    ${a1_rsrp_thres}=${A1_THRES_HO_SSB_RSRP_SA}    ${cell_id}=${PCELL_ID}       ${meas_id}=${A1_MEAS_ID}
    ...            ${log_path_pcap}=${CPIF_LOG}
    ${a1_rsrp}    _Get RSRP in measurment report for special cell and measId    meas_id=${meas_id}
    ...    log_path_pcap=${log_path_pcap}     cell_id=${cell_id}

    should be true    ${a1_rsrp} >= ${a1_rsrp_thres}

Verify A2 event configed in F1AP log
    [Documentation]    Private    Author: Dandan Fang
    ...    When scell addition method as covBasedA1, A2 info should be configured with first rrc-reconfig when received
    ...    A1 event.
    ...    ${log_file_path}: pcap log file path
    [Arguments]    ${log_path_pcap}
    pcap.setup    infile=${log_path_pcap}    display_filter=${A2_Configured_RRC_FILTER}

    ${a2Meas_type}  pcap.get_field_value_by_xpath
    ...      xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
    ...      attribute_name=showname

    should be equal as strings    rsrp    ${a2Meas_type[0].split()[1]}

Verify A2 measurement report for special cell in F1AP log
    [Documentation]    author: Dandan Fang
    ...    ${a2_rsrp_thres}: A2 rsrp threshold , same with NIDD used.
    ...    ${cell_id}: cell ID of which A2 event reported.
    ...    ${meas_id}: meas id of A2 event, which is same with reportId.
    [Arguments]    ${a2_rsrp_thres}=${A2_THRES_HO_SSB_RSRP_SA}    ${meas_id}=${A2_MEAS_ID}     ${cell_id}=${0}
    ...            ${log_path_pcap}=${CPIF_LOG}
    ${a2_rsrp}    _Get RSRP in measurment report for special cell and measId    meas_id=${meas_id}
    ...    log_path_pcap=${log_path_pcap}     cell_id=${cell_id}

    should be true    ${a2_rsrp} <= ${a2_rsrp_thres}

Verify measurement report for multiple cells in F1AP log
    [Documentation]    author: Cui Lingxue
    ...    Verify the existence for measurement report for multiple cells.
    ...    ${cell_id}: nrCellId, can be 1 or 1,2
    [Arguments]    ${log_path_pcap}    ${cell_id}
    ${cell_id_list}    string2list    ${cell_id}
    ${filter_measurement_report}    set variable    nr-rrc.measurementReport_element && nr-rrc.measId
    pcap.setup     infile=${log_path_pcap}    display_filter=${filter_measurement_report}

    FOR    ${cell_id}    IN    @{cell_id_list}
        ${physicalCellId}   set variable    ${NR_CELL_ID_MAPPING[${cell_id}]['physicalCellId']}
        ${xpath_rsrp}    catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
        ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp
        ${rsrp}    pcap.get_field_value_by_xpath       xpath=${xpath_rsrp}      attribute_name=show
        should not be empty    ${rsrp}
    END

Get reportConfigId for special measEvent in F1AP log
    [Documentation]    author: Dandan Fang
    ...    try to find each eventId's reportId, which measId is equal.
    ...    Maybe just suitable for "each event just have 1 reportConfig", for example 1 A1 event for 1 cell
    ...    Or 1 A1 event, 1 A3 event.
    [Arguments]     ${log_path_pcap}=${CPIF_LOG}   ${measEvent}=None
    pcap.setup    infile=${log_path_pcap}    display_filter=(nr-rrc.rrcReconfiguration_element&&nr-rrc.${measEvent}_element)

    ${reportId_xpath}  catenate    SEPARATOR=${EMPTY}     .//*/nr-rrc.${measEvent}_element/ancestor::nr-rrc.reportConfig/
    ...                preceding-sibling::nr-rrc.reportConfigId

    ${report_Id}    pcap.get_field_value_by_xpath
    ...       xpath=${reportId_xpath}      attribute_name=show
    [Return]    ${report_Id[${0}]}

_Get RSRP in measurment report for special cell and measId
    [Documentation]    author: Dandan Fang
    [Arguments]    ${log_path_pcap}   ${meas_id}=${1}     ${cell_id}=${PCELL_ID}
    ${MeasurementReport_filter}    set variable
    ...                         nr-rrc.measurementReport_element && (nr-rrc.measId == ${meas_id})
    pcap.setup     infile=${log_path_pcap}    display_filter=${MeasurementReport_filter}

    ${physicalCellId}   set variable    ${NR_CELL_ID_MAPPING[${cell_id}]['physicalCellId']}
    ${xpath_rsrp}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
    ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp

    ${rsrp}    pcap.get_field_value_by_xpath       xpath=${xpath_rsrp}      attribute_name=show

    [Return]    ${rsrp[0]}

Verify pcell lock unlock happen from tcpdump log when fail to check status from webUI after nrrel delete
    [Documentation]    Author: Ding Binmei
    ...    Verify PDUSessionResourceReleaseCommand in tcpdump.
    ...    pdu_release_cause:0 means normal release
    ...    Sometimes PDUSessionResourceReleaseCommand won't be captured from F1AP log, then we'll check if NGResetAcknowledge exists.
    ...    If still not checked, then will fail the check point
    [Arguments]    ${tcpdump_log}
    pcap.setup    infile=${tcpdump_log}    display_filter=f1ap||nr-rrc||ngap||s1ap
    @{pdu_release_cause}    pcap.get_field_value_by_xpath    xpath=${XPATH_PDU_SESSION_RELEASE_CAUSE}
    ${is_pdu_session_release_exist}    Run keyword and return status    should be equal as strings    ${pdu_release_cause[0]}   0
    ${reset_element}    pcap.get_field_value    field_name=ngap.NGResetAcknowledge_element   fmt=showname
    ${is_reset_element_exist}    Run keyword and return status    should not be empty    ${reset_element}
    ${final_result}    Evaluate    ${is_pdu_session_release_exist} or ${is_reset_element_exist}
    Should be true    ${final_result}    msg=Check cell lock unlock from tcpdump log failed, please check manually

Verify Intra-gNB handover successfully
    [Documentation]    Author: Wu Rong
    [Arguments]    ${tcpdump_log}    ${expect_Ho_target_cell}
    pcap.setup    infile=${tcpdump_log}    display_filter=f1ap
    ${handover_msg}  pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.HandoverPreparationInformation_element
    ...    attribute_name=showname
    ${target_cell}  pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.spCellConfig_element/nr-rrc.reconfigurationWithSync_element/nr-rrc.spCellConfigCommon_element/nr-rrc.physCellId

    run keyword and continue on failure    should not be empty    ${handover_msg}    msg=Check intra-gNB handover failed, please check manually
    should be true    ${expect_Ho_target_cell} == ${target_cell}[-1]
