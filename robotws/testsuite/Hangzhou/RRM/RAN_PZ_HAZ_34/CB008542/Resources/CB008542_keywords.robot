*** Settings ***
Resource     CB008542_variables.robot
Variables    commissionings/HGZ/${testline_name}/__init_8542__.py
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/TestData/PCell_selection_and_DistName.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_variables.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot


Documentation
...   This is for T+F CA feature CB008542 keywords.
...   author: Zhou Charlie
...   contact: charlie.zhou@nokia-sbell.com
...   squad group: MMW_SG1

*** Keywords ***
Import NIDD variables for 8542
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    connect to gnb coam via ssl
    ${is_tl_delta_file_exists}    Run keyword and return status    File should exist    ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    Run keyword if    ${is_tl_delta_file_exists}
    ...    Import variables  ${commissionings_path}/HGZ/${testline_name}/TLDelta.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_rest_api_8542.py

8542 Suite preparation
    [Arguments]    ${NSA_SA}=${NSA_SA}
    Import NIDD variables for 8542
    set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_DEFAULT}
    set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_DEFAULT}
    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT_20M_100M_1116_0}
    ${is_tl_enb_scf_file_exists}    Run keyword and return status    File should exist    ${ENB_SCF_DEFAULT_FILE_PATH}
    ${enb_default_scf_file}   set variable if     ${is_tl_enb_scf_file_exists}     ${ENB_SCF_DEFAULT_FILE_PATH}     ${None}
    CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${enb_default_scf_file}
    ...                     is_pdl_checking_needed=${True}


Get reportConfigId for A1 measEvent in cpif log NSA
    [Documentation]    Author: Zhou Charlie
    ...    try to find each eventId's reportId, which measId is equal.
    ...    Maybe just suitable for "each event just have 1 reportConfig", for example 1 A1 event for 1 cell
    ...    Or 1 A1 event, 1 A3 event.
    [Arguments]     ${measEvent}=None      ${log_path_pcap}=${CPIF_LOG}
    ${filter}    set variable     (x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 1) && (nr-rrc.ReportConfigToAddMod_element)
    ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}       filter=${filter}
    ${reportId_xpath}  catenate    SEPARATOR=${EMPTY}     .//*/nr-rrc.${measEvent}_element/ancestor::nr-rrc.reportConfig/
    ...                preceding-sibling::nr-rrc.reportConfigId
    ${report_Id}    pcap.get_field_value_by_xpath        xpath=${reportId_xpath}      attribute_name=show
    [Return]    ${report_Id[${0}]}


Get reportConfigId for A2 measEvent in cpif log NSA
    [Documentation]    Author: Zhou Charlie
    ...    try to find each eventId's reportId, which measId is equal.
    ...    Maybe just suitable for "each event just have 1 reportConfig", for example 1 A1 event for 1 cell
    ...    Or 1 A1 event, 1 A3 event.
    [Arguments]     ${measEvent}=None      ${log_path_pcap}=${CPIF_LOG}
    ${filter}    set variable     (x2ap.procedureCode == 30) && (x2ap.X2AP_PDU == 0) && (nr-rrc.ReportConfigToAddMod_element)
    ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}       filter=${filter}
    ${reportId_xpath}  catenate    SEPARATOR=${EMPTY}     .//*/nr-rrc.${measEvent}_element/ancestor::nr-rrc.reportConfig/
    ...                preceding-sibling::nr-rrc.reportConfigId
    ${report_Id}    pcap.get_field_value_by_xpath        xpath=${reportId_xpath}      attribute_name=show
    [Return]    ${report_Id[${0}]}


Get RSRP in measurment report in cpif log NSA
    [Documentation]    Author: Zhou Charlie
    [Arguments]    ${meas_id}    ${log_path_pcap}=${CPIF_LOG}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable
    ...    (x2ap.procedureCode == 35) && (x2ap.X2AP_PDU == 0) && (nr-rrc.measId == ${meas_id})
    ${pkt_measReport}    pcap.filter_packets_by_expression    filter_expression=${filter}
#    ${rsrp}    pcap.get_field_value_by_xpath
#    ...    xpath=.//nr-rrc.measResultServingMOList//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.rsrp
#    ...    attribute_name=show
    ${rsrp}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.measResultServingMOList//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp
    ...    attribute_name=show
    [Return]    ${rsrp[0]}

Verify A2 measurement report in cpif log NSA
    [Documentation]    Author: Zhou Charlie
    [Arguments]    ${a2_rsrp_thres}=${A2_THRES_HO_SSB_RSRP_SA}    ${log_path_pcap}=${CPIF_LOG}   ${meas_id}=${A2_MEAS_ID}
    ${a2_rsrp}    Get RSRP in measurment report in CPIF log NSA    meas_id=${meas_id}
    ...    log_path_pcap=${log_path_pcap}
    should be true    ${a2_rsrp} <= ${a2_rsrp_thres}

Verify A1 measurement report in cpif log NSA
    [Documentation]    Author: Zhou Charlie
    [Arguments]    ${a1_rsrp_thres}=${A1_THRES_HO_SSB_RSRP_SA}    ${log_path_pcap}=${CPIF_LOG}  ${meas_id}=${A1_MEAS_ID}
    ${a1_rsrp}    Get RSRP in measurment report in CPIF log NSA    meas_id=${meas_id}
    ...    log_path_pcap=${log_path_pcap}
    should be true    ${a1_rsrp} >= ${a1_rsrp_thres}


Verify A1 report and Scell addition but in inactivate when Pcell Signal From Bad To Good NSA
    [Documentation]    Author: Zhou Charlie
    ...      Note: It is just called when scell addition method as covBasedA1
    ...      a2_meas_for_scell_released control whether need to check A2 configured for Scell release, False no check
    ...                                         true need to check
    [Arguments]    ${tcpdump_log_name}=CA_A1_Report_When_Pcell_Good
    ...            ${exp_pa_value}=${40}       ${ru_index}=${PCELL_RU_INDEX}
    ...            ${a1_rsrp_thres}=${80}     ${meas_id}=${1}     ${a2_meas_for_scell_released}=${False}
    Prepare and start aasyslog
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    log to console    Tune PA to trigger UE A1 measurement report
    Initialize attenuator for specified RU     exp_pa_value=${exp_pa_value}    ru_index=${ru_index}
    sleep    5s    msg=Wait for UE send A1 measurement report.

    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and continue on failure  Verify A1 measurement report in cpif log NSA
    ...    log_path_pcap=${ute_log_path}   a1_rsrp_thres=${a1_rsrp_thres}     meas_id=${meas_id}

    run keyword if      ${a2_meas_for_scell_released}         Verify A2 measurement config for scell released in cpif log NSA
    ...     log_path_pcap=${ute_log_path}

    run keyword and continue on failure    Check Scell addition in tcpdump log    tcpdump_log=${ute_log_path}

    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation
    should not be true    ${is_scell_activated}
    [Return]    ${ute_log_path}
    [Teardown]    run keyword and ignore error    Run keywords    Stop Tcpdump via collector
    ...       tcpdump_collector_name=${tcpdump_log_name}    AND
    ...       Teardown the Aasyslog save progress


Verify A2 measurement config for scell released in cpif log NSA
    [Documentation]    Author: Zhou Charlie
    ...           nr-rrc.measCycleSCell is related with Scell
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}
    ${filter}       set variable     (x2ap.procedureCode == 30) && (x2ap.X2AP_PDU == 0) && (nr-rrc.measCycleSCell)
    ${rrcReconfig}    Load pcap file with filter    log_path_pcap=${log_path_pcap}       filter=${filter}

    ${a2MeasType}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
    ...    attribute_name=showname

    run keyword and continue on failure    should be equal as strings    rsrp    ${a2MeasType[0].split()[1]}


Verify A2 report for special cell in cpif log NSA
    [Documentation]    Author: Zhou Charlie
    ...        procedureCode: id-ULRRCMessageTransfer  13
    [Arguments]    ${a2_rsrp_thres}=${60}    ${log_path_pcap}=${CPIF_LOG}   ${meas_id}=${2}
    ...           ${cellId}=${PCELL_ID}
    ${filter}       set variable     (x2ap.procedureCode == 35) && (x2ap.X2AP_PDU == 0) && (nr-rrc.measId == ${meas_id})
    ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}       filter=${filter}

    ${physicalCellId}   set variable    ${NR_CELL_ID_MAPPING[${cellId}]['physicalCellId']}

#    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
#    ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.rsrp
    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
    ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp

    ${a2_rsrp}  pcap.get_field_value_by_xpath
    ...    xpath=${xpath}      attribute_name=show
    should be true    ${a2_rsrp[0]} <= ${a2_rsrp_thres}


A2 report and Scell released when Scell signal in bad NSA
    [Documentation]    Author: Zhou Charlie
    ...            Note:Pcell and Scell Signal need to be bad at the same time
    [Arguments]    ${tcpdump_log_name}=CA_A2_Report_When_Scell_Bad
    ...            ${exp_pa_value_pcell}=${40}         ${exp_pa_value_scell}=${40}
    ...            ${pcell_ru_index}=${PCELL_RU_INDEX}      ${scell_ru_index}=${SCELL_RU_INDEX}
    ...            ${a2_rsrp_thres}=${60}       ${meas_id}=${2}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    log to console    Tune PA to trigger UE A2 measurement report

    Initialize attenuator for specified RU     exp_pa_value=${exp_pa_value_pcell}    ru_index=${pcell_ru_index}
    Initialize attenuator for specified RU     exp_pa_value=${exp_pa_value_scell}    ru_index=${scell_ru_index}

    sleep    5s    msg=Wait for UE send A2 measurement report.
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and continue on failure     Verify A2 report for special cell in cpif log NSA
    ...    log_path_pcap=${ute_log_path}   a2_rsrp_thres=${a2_rsrp_thres}     meas_id=${meas_id}     cellId=${SCELL_ID}

    run keyword and continue on failure    Check Scell release in tcpdump log    tcpdump_log=${ute_log_path}
    [Teardown]    run keyword and ignore error    Run keywords    Stop Tcpdump via collector
    ...       tcpdump_collector_name=${tcpdump_log_name}    AND
    ...       Teardown the Aasyslog save progress


check Scell Addition Release Activation Deactivation Counter
    [Documentation]    Author: Zhou Charlie
    ...      Following counter will be counted under Pcell
    ...      M55114C00028: This counter provides the number of successful radio admissions for 1 S-Cell additions.
    ...      Updated to the PS-Cell whenever there is a successful radio admission for 1 S-Cell additions.
    ...      M55118C06504: This counter provides the number of successful RRC Reconfiguration procedures
    ...      in NSA 3x mode releasing 1 S-Cell in DL based on A2 measurement on S-Cell.
    ...      Following counter will be counted under both Scell
    ...      M55316C09000: This counter provides the number of S-Cell activations while pegged in the secondary cell.
    ...      When an S-Cell transition to "active" is triggered
    ...      M55316C09001: This counter provides the number of S-Cell deactivations due to Buffer Status while pegged
    ...      in secondary cell. When an S-Cell transition to "inactive" is triggered.
    [Arguments]       ${starting_log_timestamp}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list_pcell}    create list     ${PCELL_ID}
    ${cell_check_list_scell}    create list     ${SCELL_ID}
    ${list_measurement_ids_pcell}    create list    M55114C00028    M55118C06504
    ${list_measurement_ids_scell}    create list    M55316C09000    M55316C09001
    ${dict_measurements_value_pcell}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${cell_check_list_pcell}          list_measurement_ids=${list_measurement_ids_pcell}
    ${dict_measurements_value_scell}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${cell_check_list_scell}          list_measurement_ids=${list_measurement_ids_scell}

    ${pcell_M55114C00028}    set variable    ${dict_measurements_value_pcell['${pcell_id}']['M55114C00028']}
    ${pcell_M55118C06504}    set variable    ${dict_measurements_value_pcell['${pcell_id}']['M55118C06504']}
    ${scell_M55316C09000}    set variable    ${dict_measurements_value_scell['${scell_id}']['M55316C09000']}
    ${scell_M55316C09001}    set variable    ${dict_measurements_value_scell['${scell_id}']['M55316C09001']}
    run keyword and continue on failure   run keywords    Should be true      ${pcell_M55114C00028} >= ${1}
    ...                                        AND        Should be true      ${pcell_M55118C06504} >= ${1}
    ...                                        AND        Should be true      ${scell_M55316C09000} >= ${1}
    ...                                        AND        Should be true      ${scell_M55316C09001} >= ${1}
