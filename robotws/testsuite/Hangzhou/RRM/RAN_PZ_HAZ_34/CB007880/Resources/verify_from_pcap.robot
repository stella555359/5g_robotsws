*** Settings ***
Documentation    Author: Ding Binmei
...    Check points from pcap files.
Library     taf.analyzer.pcap    WITH NAME    pcap
Library    ./pcap_analyze.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_gnb_classical.py

*** Keywords ***
Verify positioning procedures
    [Documentation]    Author: Ding Binmei
    ...    Verify positioning procedures based on pcap file
    ...    ${log_file_path}: Path to the pcap file
    ...    ${cell_id_for_attach}: cell index where UE is attached
    ...    ${exp_TRP_num}: Expected number of TRPs reported in PositioningMeasurementReport
    ...    ${periodic_time_tolerance}: Allowed time gap tolerance in ms. Default to 100
    [Arguments]    ${log_file_path}    ${cell_id_for_attach}    ${exp_TRP_num}    ${exp_TRP_num_for_measurement_report}
    ...    ${periodic_time_tolerance}=100
    &{nr_cell_map}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ${pci_for_ru_access}    Set variable    ${nr_cell_map[${cell_id_for_attach}]['physicalCellId']}
    Run Keyword And Continue On Failure    Verify TRP information exchange procedure is successful between LMF and GNB
    ...    log_file_path=${log_file_path}    exp_TRP_num=${exp_TRP_num}
    Run Keyword And Continue On Failure    Verify SRS configuration procedure is successful between LMF and GNB
    ...    log_file_path=${log_file_path}    pci_for_ru_access=${pci_for_ru_access}
    Run Keyword And Continue On Failure    Verify there is no PositioningMeasurementFailure or MeasurementFailure procedures happen
    ...    log_file_path=${log_file_path}
    Run Keyword And Continue On Failure
    ...    Verify there is no PositioningMeasurementFailureIndication or MeasurementFailureIndication procedures happen
    ...    log_file_path=${log_file_path}
    Verify info in measurement report and check measurement report sent to LMF periodically
    ...    log_file_path=${log_file_path}    pci_for_ru_access=${pci_for_ru_access}    exp_TRP_num=${exp_TRP_num_for_measurement_report}
    ...    periodic_time_tolerance=${periodic_time_tolerance}

_Verify TRP Num are as expected from TRPInformationResponse
    [Documentation]    Author: Ding Binmei
    ...    Verify the number of TRPs reported in TRPInformationResponse is as expected
    ...    This keyword will extract the TRP IDs from the TRPInformationResponse and
    ...    compare the count with the expected number.
    ...    ${log_file_path}: Path to the pcap file
    ...    ${exp_TRP_num}: Expected number of TRPs reported in TRPInformationResponse
    [Arguments]    ${log_file_path}    ${exp_TRP_num}
    ${dict_field_xpath}    Create Dictionary    trp_id=.//f1ap.TRPInformationResponse_element//*/f1ap.tRPID
    ${list_fields_info_for_packets}    pcap_analyze.get_field_value_by_xpath_for_specific_packets    log_file_path=${log_file_path}
    ...    dict_field_xpath=${dict_field_xpath}    pcap_parser=test0    filter_for_package=f1ap.TRPInformationResponse_element
    FOR    ${field_info}    IN    @{list_fields_info_for_packets}
        ${act_TRP_num}    Get length    ${field_info['trp_id']}
        Should Be Equal As Integers    ${act_TRP_num}    ${exp_TRP_num}
    END

Verify TRP information exchange procedure is successful between LMF and GNB
    [Documentation]  Author: Ding Binmei
    ...    Verify TRP information exchange procedure:
    ...    --Verify message nrppa.TRPInformationRequest_element exists
    ...    --Verify message f1ap.TRPInformationRequest exists
    ...    --Verify message f1ap.TRPInformationResponse exists
    ...    --Verify message nrppa.TRPInformationResponse exists
    ...    --Verify TRP Num are as expected from TRPInformationResponse
    ...    ${log_file_path}: Path to the pcap file
    ...    ${exp_TRP_num}: Expected number of TRPs reported in TRPInformationResponse
    [Arguments]    ${log_file_path}    ${exp_TRP_num}
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=nrppa.TRPInformationRequest_element
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=f1ap.TRPInformationRequest_element
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=f1ap.TRPInformationResponse_element
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=nrppa.TRPInformationResponse_element
    _Verify TRP Num are as expected from TRPInformationResponse    log_file_path=${log_file_path}    exp_TRP_num=${exp_TRP_num}

Verify LMF measurement abort is successful between LMF and GNB
    [Documentation]  Author: Qi Xin
    ...    Verify LMF measurement abort procedure:
    ...    --Verify message nrppa.id-MeasurementAbort exists
    ...    --Verify message f1ap.PositioningMeasurementAbort exists
    ...    ${log_file_path}: Path to the pcap file
    [Arguments]    ${log_file_path}
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=nrppa.MeasurementAbort_element
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=f1ap.PositioningMeasurementAbort_element

Verify SRS configuration procedure is successful between LMF and GNB
    [Documentation]  Author: Ding Binmei
    ...    Verify SRS configuration procedure:
    ...    --Verify message nrppa.PositioningInformationRequest_element exists
    ...    --Verify message f1ap.PositioningInformationRequest exists
    ...    --Verify message f1ap.PositioningInformationResponse exists
    ...    --Verify message nrppa.PositioningInformationResponse exists
    ...    --Verify SRS configuration exist and PCI match the expected value
    ...    ${log_file_path}: Path to the pcap file
    ...    ${pci_for_ru_access}: Expected PCI for RU access(attached one)
    [Arguments]    ${log_file_path}    ${pci_for_ru_access}
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=nrppa.PositioningInformationRequest_element
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=f1ap.PositioningInformationRequest_element
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=f1ap.PositioningInformationResponse_element
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=nrppa.PositioningInformationResponse_element
    pcap.setup    infile=${log_file_path}    display_filter=f1ap.PositioningInformationResponse_element    alias=test0
    ${list_pci_for_srs_config}    pcap.get_field_value_by_xpath
    ...    xpath=.//f1ap.PositioningInformationResponse_element//*/f1ap.SRSConfiguration_element//*/f1ap.pci
    ...    pcap_parser=test0
    Should Be Equal As Numbers    ${list_pci_for_srs_config[0]}    ${pci_for_ru_access}

Verify there is no PositioningMeasurementFailure or MeasurementFailure procedures happen
    [Documentation]  Author: Ding Binmei
    ...    Check there is no F1AP:PositioningMeasurementFailure or NRPPa: MeasurementFailure
    [Arguments]    ${log_file_path}
    ${filter_measurement_failure}    Set variable    f1ap.PositioningMeasurementFailure_element||nrppa.MeasurementFailure_element
    Verify message should not exist    log_file_path=${log_file_path}    filter_for_package=${filter_measurement_failure}

Verify there is no PositioningMeasurementFailureIndication or MeasurementFailureIndication procedures happen
    [Documentation]  Author: Ding Binmeiz
    ...    Check there is no F1AP:PositioningMeasurementFailureIndication or NRPPa: MeasurementFailureIndication
    [Arguments]    ${log_file_path}
    ${filter_measurement_failure}  Set variable  f1ap.PositioningMeasurementFailureIndication_element or nrppa.MeasurementFailureIndication_element
    Verify message should not exist    log_file_path=${log_file_path}    filter_for_package=${filter_measurement_failure}


_Get measurement info from f1ap.PositioningMeasurementRequest based on pci for ru access
    [Documentation]  Author: Ding Binmei
    ...    Get measurement info from f1ap.PositioningMeasurementRequest based on pci for ru access.
    ...    Set ${MEASUREMENT_PERIOD_FROM_F1AP} as test variable for counter check usage.
    ...    ${log_file_path}: Path to the pcap file
    ...    ${pci_for_ru_access}: Expected PCI for RU access(attached one)
    ...    Returns a dictionary with keys:
    ...    - lmf_measurement_id: int(XXX)
    ...    - measurement_period: 1280(current value)
    [Arguments]    ${log_file_path}    ${pci_for_ru_access}
    pcap.setup    infile=${log_file_path}    display_filter=f1ap.PositioningMeasurementRequest_element    alias=test0
    ${xpath_root_for_srsConfig_with_pci}    Catenate    SEPARATOR=${EMPTY}   .//f1ap.SRSConfiguration_element//*/
    ...    f1ap.pci[@show='${pci_for_ru_access}']/ancestor::f1ap.PositioningMeasurementRequest_element
    ${xpath_lmf_measurement_id}    Set variable    ${xpath_root_for_srsConfig_with_pci}//*/f1ap.LMF_MeasurementID
    ${xpath_mesurement_period}    Set variable    ${xpath_root_for_srsConfig_with_pci}//*/f1ap.MeasurementPeriodicityExtended
    ${list_lmf_measurement_id}    pcap.get_field_value_by_xpath    xpath=${xpath_lmf_measurement_id}    pcap_parser=test0
    ${list_measurement_period}    pcap.get_field_value_by_xpath    xpath=${xpath_mesurement_period}    pcap_parser=test0    attribute_name=showname
    ${num_lmf_measurement_id}    Evaluate    len(set(${list_lmf_measurement_id}))
    ${num_measurement_period}    Evaluate    len(set(${list_measurement_period}))
    Should Be Equal As Integers    ${num_lmf_measurement_id}    1
    Should Be Equal As Integers    ${num_measurement_period}    1
    Should Contain    ${list_measurement_period[0]}    ms
    ${measurement_period}    Get Regexp Matches    ${list_measurement_period[0]}    MeasurementPeriodicityExtended: ms(\\d+)    1
    ${measurement_period}    Convert To Integer    ${measurement_period[0]}
    Set test variable    ${MEASUREMENT_PERIOD_FROM_F1AP}    ${measurement_period}
    ${lmf_measurement_id}    Convert To Integer    ${list_lmf_measurement_id[0]}
    ${dict_measurement_info}    Create Dictionary    lmf_measurement_id=${lmf_measurement_id}
    ...    measurement_period=${measurement_period}
    [Return]    ${dict_measurement_info}

Verify info in measurement report and check measurement report sent to LMF periodically
    [Documentation]  Author: Ding Binmei
    ...    Verify info in measurement report and check measurement report sent to LMF periodically
    ...    1. Verify message f1ap.PositioningMeasurementReport exists
    ...    2. Verify message nrppa.MeasurementReport exists
    ...    3. Verify ul_RTOA_k0, ul_srs_rsrp and trp_ids in PositioningMeasurementReport are not None
    ...    4. Verify the number of ul_RTOA_k0, ul_srs_rsrp and trp_ids in PositioningMeasurementReport
    ...       are as expected(exp_TRP_num)
    ...    5. Verify the time gap between two adjacent PositioningMeasurementReport messages
    ...       is close to the official measurement period defined in PositioningMeasurementRequest
    ...       (allowed time gap tolerance is periodic_time_tolerance)
    ...    ${log_file_path}: Path to the pcap file
    ...    ${pci_for_ru_access}: Expected PCI for RU access(attached one)
    ...    ${exp_TRP_num}: Expected number of TRPs reported in PositioningMeasurementReport
    ...    ${periodic_time_tolerance}: Allowed time gap tolerance in ms. Default to 100
    [Arguments]    ${log_file_path}    ${pci_for_ru_access}    ${exp_TRP_num}    ${periodic_time_tolerance}=100
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=f1ap.PositioningMeasurementReport_element
    Verify message exist    log_file_path=${log_file_path}    filter_for_package=nrppa.MeasurementReport_element
    ${dict_measurement_info}    _Get measurement info from f1ap.PositioningMeasurementRequest based on pci for ru access
    ...    log_file_path=${log_file_path}    pci_for_ru_access=${pci_for_ru_access}
    ${filter_for_packages}    Catenate    f1ap.PositioningMeasurementReport_element and
    ...    f1ap.LMF_MeasurementID == ${dict_measurement_info['lmf_measurement_id']}
    ${dict_field_xpath}    Create Dictionary    ul_RTOA_k0=.//f1ap.PosMeasurementResultList//*/f1ap.uL_RTOA_MeasurementItem/f1ap.k0
    ...    ul_srs_rsrp=.//f1ap.PosMeasurementResultList//*/f1ap.uL_SRS_RSRP
    ...    epoch_arrival_time=.//frame/frame.time_epoch
    ...    trp_ids=.//f1ap.PosMeasurementResultList//*/f1ap.tRPID
    ${list_fields_info_for_packets}    pcap_analyze.get_field_value_by_xpath_for_specific_packets    log_file_path=${log_file_path}
    ...    dict_field_xpath=${dict_field_xpath}
    ...    pcap_parser=test0    filter_for_package=${filter_for_packages}
    FOR   ${index}    ${dict_field_info}    IN ENUMERATE    @{list_fields_info_for_packets}
        Should Not Contain    ${dict_field_info['ul_RTOA_k0']}    ${None}    msg=ul_RTOA_k0 for each trp should not be None
        Should Not Contain    ${dict_field_info['ul_srs_rsrp']}    ${None}    msg=ul_srs_rsrp for each trp should not be None
        ${act_num_ul_RTOA_k0}    Get length    ${dict_field_info['ul_RTOA_k0']}
        Should Be Equal As Integers    ${act_num_ul_RTOA_k0}    ${exp_TRP_num}    msg=ul_RTOA_k0 number in measurement report is not as expected
        ${act_num_ul_srs_rsrp}    Get length    ${dict_field_info['ul_srs_rsrp']}
        Should Be Equal As Integers    ${act_num_ul_srs_rsrp}    ${exp_TRP_num}    msg=ul_srs_rsrp number in measurement report is not as expected
        ${act_trp_num}    Get length    ${dict_field_info['trp_ids']}
        Should Be Equal As Integers    ${act_trp_num}    ${exp_TRP_num}    msg=TRP number in measurement report is not as expected
        ${timestamp_current}    Set variable    ${dict_field_info['epoch_arrival_time'][0]}
        ${timestamp_previous}    Set variable if    ${index}>0    ${list_fields_info_for_packets[${index}-1]['epoch_arrival_time'][0]}
        ${act_time_gap_vs_official_period}    Run keyword if    ${index}>0    Evaluate
        ...    abs((float(${timestamp_current}) - float(${timestamp_previous}))*1000-${dict_measurement_info['measurement_period']})
        Run keyword if     ${index}>0    Should be true    ${act_time_gap_vs_official_period}<=${periodic_time_tolerance}
    END
    Should be true    ${index}>=1    msg=There should be at least 2 PositioningMeasurementReport messages

Verify message should not exist
    [Documentation]  Author: Ding Binmeiz
    ...    Check there is no specific packages exist in the pcap file
    ...    ${log_file_path}    Path to the pcap file
    ...    ${filter_for_package}    Filter for the package to check
    ...    E.G: f1ap.PositioningMeasurementFailure_element or nrppa.Measurement
    [Arguments]    ${log_file_path}    ${filter_for_package}
    pcap.setup    infile=${log_file_path}    display_filter=${filter_for_package}    alias=test0
    ${is_filtered_package_exists}    Run keyword and return status    pcap.get_packets    pcap_parser=test0
    Should Not Be True    ${is_filtered_package_exists}    msg=${filter_for_package} should not happen

Verify message exist
    [Documentation]    Author: Ding Binmei
    ...    Verify filter message exist in the pcap file
    [Arguments]    ${log_file_path}    ${filter_for_package}
    pcap.setup    infile=${log_file_path}    display_filter=${filter_for_package}    alias=test0
    ${is_filtered_package_exists}    Run keyword and return status    pcap.get_packets    pcap_parser=test0
    Should be True    ${is_filtered_package_exists}    msg=${filter_for_package} should exist
