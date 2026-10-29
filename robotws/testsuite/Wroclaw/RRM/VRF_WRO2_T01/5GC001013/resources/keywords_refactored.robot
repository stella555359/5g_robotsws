*** Settings ***
Documentation
...       Editor: Wiktor Jarosiński
...       Contact Person: Paweł Wiśniewski
...       Edit Reason: Robocop Clean
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library   taf.converters.pcaptopdml  WITH NAME  ptp

*** Keywords ***
Perform commissioning 1013 REF
    [Arguments]         ${srb3SupportEnabled}=false
    ...                 ${a3MeasEnabled}=rsrp
    ...                 ${a5MeasEnabled}=rsrp
    ...                 ${actIntraFreqIntraGnbMobilityNSA}=true
    ...                 ${csiReportPeriodicity}=slots160
    ...                 ${lteToNrTimeOffset}=0
    ...                 ${enDcSyncStatus}=synchronous
    ...                 ${actCDrx}=false
    ...                 ${option}=none
    ...                 ${scramblingIdStep}=3
    ...                 ${actTcpBoostPug}=allUes
    ...                 ${actNsaUeBasedAnrNr}=false

    Log to console      __Perform commissioning with given parameters.
    ${cell_ids}    Get cell ids
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    &{csiReportPeriodicity_dict}    Create dictionary    csiReportPeriodicity=${csiReportPeriodicity}
    ${is_higher}    check_release_is_higher_than    SBTS23R3

    run keyword if    ${is_higher} == ${True}    set to dictionary
    ...    ${csiReportPeriodicity_dict}    scramblingIdStep=${scramblingIdStep}

    Initialise delta store
    Add param to delta  ${object_path}      srb3SupportEnabled                value=${srb3SupportEnabled}

    Run keyword if    '${option}'=='B4'
    ...     Add param to delta  ${object_path}      actIntraFreqIntraGnbMobilityNSA   value=${actIntraFreqIntraGnbMobilityNSA}
    Run keyword if    ${is_higher} == ${True}
    ...     Add param to delta  ${object_path}      actNsaUeBasedAnrNr   value=${actNsaUeBasedAnrNr}
    Run keyword if  '${actCDrx}' == 'false'
    ...     set test variable  ${actTcpBoostPug}  disabled

    FOR    ${cell_id}    IN     @{cell_ids}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    enDcSyncStatus      value=${enDcSyncStatus}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    actCDrx             value=${actCDrx}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    lteToNrTimeOffset   value=${lteToNrTimeOffset}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    actTcpBoostPug      value=${actTcpBoostPug}
        Add list parameters to delta  ${object_path}/NRCELL-${cell_id}
        ...    periodicCsiAcquisition     &{csiReportPeriodicity_dict}
        Run keyword if    '${option}'=='B4'    Run keywords
        ...    Add param to delta  ${object_path}/NRCELL-${cell_id}    a3MeasEnabled    value=${a3MeasEnabled}    AND
        ...    Add param to delta  ${object_path}/NRCELL-${cell_id}    a5MeasEnabled    value=${a5MeasEnabled}
    END
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair

Perform commissioning 1013 REF __23r3
    [Arguments]         ${srb3SupportEnabled}=false
    ...                 ${a3MeasEnabled}=rsrp
    ...                 ${a5MeasEnabled}=rsrp
    ...                 ${actIntraFreqIntraGnbMobilityNSA}=true
    ...                 ${csiReportPeriodicity}=slots160
    ...                 ${scramblingIdStep}=3
    ...                 ${lteToNrTimeOffset}=0
    ...                 ${enDcSyncStatus}=synchronous
    ...                 ${actCDrx}=false
    ...                 ${option}=none
    Log to console      __Perform commissioning with given parameters.
    ${cell_ids}    Get cell ids
    ${object_path}      Set variable  MRBTS-${bts_id}/NRBTS-${bts_id}
    &{csiReportPeriodicity_dict}    Create dictionary
    ...    csiReportPeriodicity=${csiReportPeriodicity}
    ...    scramblingIdStep=${scramblingIdStep}
    Initialise delta store
    Add param to delta  ${object_path}      srb3SupportEnabled                value=${srb3SupportEnabled}
    Run keyword if    '${option}'=='B4'
    ...     Add param to delta  ${object_path}      actIntraFreqIntraGnbMobilityNSA   value=${actIntraFreqIntraGnbMobilityNSA}
    FOR    ${cell_id}    IN     @{cell_ids}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    enDcSyncStatus      value=${enDcSyncStatus}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    actCDrx             value=${actCDrx}
        Add param to delta  ${object_path}/NRCELL-${cell_id}    lteToNrTimeOffset   value=${lteToNrTimeOffset}
        Add list parameters to delta  ${object_path}/NRCELL-${cell_id}
        ...    periodicCsiAcquisition     &{csiReportPeriodicity_dict}
        Run keyword if    '${option}'=='B4'    Run keywords
        ...    Add param to delta  ${object_path}/NRCELL-${cell_id}    a3MeasEnabled    value=${a3MeasEnabled}    AND
        ...    Add param to delta  ${object_path}/NRCELL-${cell_id}    a5MeasEnabled    value=${a5MeasEnabled}
    END
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair

Slow attenuate cell
    [Arguments]  ${to_att}  ${max_value}
    log to console  Performing cell attenuation
    FOR  ${i}  IN RANGE  5  ${max_value}  7
        set attenuation and check   ${to_att}  value=${i}
        sleep  2s
    END

Slow attenuate cell to zero
    [Arguments]  ${to_att}  ${max_value}  ${step}
    FOR  ${i}  IN RANGE  0  ${max_value}  ${step}
        set attenuation and check   ${to_att}  value=${i}
        sleep  2s
    END

Parse and check cplane logs
    log to console   Parsing and checking cplane
    ptp.create pcap to pdml converter
    ...    name=converter
    ...    file_path_pattern=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pcap
    ptp.convert  converter
    ${out}  run  grep measGapConfig "${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pdml"
    ${res}  run keyword and ignore error  should contain  ${out}  measGapConfig
    run keyword if  '${res[0]}'=='FAIL'  Fail  msg=Missing measGapConfig in cplane logs.
    log to console  Test has passed

Parse and check cplane logs B
    log to console   Parsing and checking cplane B
    ptp.create pcap to pdml converter
    ...    name=converter
    ...    file_path_pattern=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pcap
    ptp.convert  converter

    ${out}  run  grep measGapConfig "${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pdml"
    ${res}  run keyword and ignore error  should contain  ${out}  measGapConfig
    run keyword if  '${res[0]}'=='FAIL'  Fail  msg=Missing measGapConfig in cplane logs.

    ${out}  run  grep UEContextModificationResponse "${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector.pdml"
    ${res}  run keyword and ignore error  should contain  ${out}  UEContextModificationResponse
    run keyword if  '${res[0]}'=='FAIL'  Fail  msg=Missing UEContextModificationResponse in cplane logs.

    log to console  Test has passed
