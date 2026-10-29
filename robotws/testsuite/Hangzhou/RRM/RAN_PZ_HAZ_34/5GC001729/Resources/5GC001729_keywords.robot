*** Settings ***
Documentation    This is for feature 5GC001729 related common keywords.
...              Please do not modify the file without notification to author
Library    vars.py
Library    vars.TputInfoGeneration      WITH NAME     tput_info
Variables   vars.py
Resource    ./Common_resources.robot

*** Keywords ***
Check Scell Addition Success
    [Documentation]    author:Stella.lin@nokia-sbell.com
    ...                check scell addition success via three methods based on parameter ${log_type}:syslog,cpif
    [Arguments]    ${log_path}    ${scell_addition_method}=blind    ${log_type}=syslog
    ${log_type}    convert_to_lowercase    ${log_type}
    ${filter_output}    Run Keyword If    '${log_type}'=='syslog'    Check Scell Addition Success Via Syslog
    ...    log_path=${log_path}    scell_addition_method=${scell_addition_method}
    ...    ELSE IF    '${log_type}'=='cpif'    Check Target Item Value on CPIF Tcpdump
    ...    file_path=${log_path}
    ...    filter_expression=nr-rrc.rrcReconfiguration_element && nr-rrc.physCellId
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.SCellConfig_element/nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId
    ...    ELSE    Fail    msg=invaild log_type:${log_type} input.
    Should Not Be Empty    ${filter_output}    msg=scell addition failed.

Check Scell Addition Success Via Syslog
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${log_path}    ${scell_addition_method}=blind
    ${addition_method_indicate_on_syslog}    Set Variable If    '${scell_addition_method}' == 'blind'    Blind
    ...                                                         '${scell_addition_method}' == 'A1'    MeasBased
    @{syslog_filter_pattern_list}    Create List
    ...    (?i)scelladdition\\s+procedure\\s+completed\\s+with\\s+no\\s+scelladdition\\s+error
    ...    Indicate procedure done, procedure: scellAddition${addition_method_indicate_on_syslog}
    Check Log Existence On Syslog    log_path=${log_path}    syslog_filter_pattern_list=@{syslog_filter_pattern_list}

Check Scell Addition Success Via CPIF After HO
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                check scell addition success via CPIF log after HO complete
    [Arguments]    ${log_path}
    ${filter_output}    Check Target Item Value on CPIF Tcpdump    file_path=${log_path}
    ...         filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.physCellId)
    ...         xpath=.//nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId
     Should Not Be Empty    ${filter_output}    msg=scell addition failed after HO.

Check Scell Activation Success
    [Documentation]    author:Stella.lin@nokia-sbell.com
    ...                check scell addition success via syslog:btslog or aasyslog
    [Arguments]    ${log_path}    ${active_round}=1
    ${output}    Filter Element On Syslog    log_path=${log_path}    syslog_filter_pattern=(?i)handlemacce\\s+done
    Should Not Be Empty    ${output}    msg=scell activation failed
    ${active_time}    Get Regexp Matches   ${output}    <(\\d+-\\d+-\\d+)T(\\d+:\\d+:\\d+).*    1    2
    ${round}    Get Length    ${active_time}
    ${active_round}    Convert to number    ${active_round}
    Should Be Equal    ${round}    ${active_round}    msg=expect active round is ${active_round} times,actually is ${round} times.


Check No Scell Addition
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${log_path}    ${scell_addition_method}=blind     ${log_type}=syslog
    ${log_type}    convert_to_lowercase    ${log_type}
    ${status}    Run Keyword And Return Status    5GC001729_keywords.Check Scell Addition Success
    ...          log_path=${log_path}    scell_addition_method=${scell_addition_method}    log_type=${log_type}
    Should Not Be True    ${status}    msg=scell addition is still success.

Check No Scell Activation
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${log_path}
    ${status}    Run Keyword And Return Status    5GC001729_keywords.Check Scell Activation Success    log_path=${log_path}
    Should Not Be True    ${status}    msg=scell is still activate.

Check DRX Configure On CPIF Tcpdump
    [Documentation]    author:xiangyue.zhou@nokia-sbell.com
    [Arguments]        ${file_path}
    ${filter_output}    Check Target Item Value on CPIF Tcpdump
    ...                 file_path=${file_path}
    ...                 filter_expression=f1ap.procedureCode == 12 && nr-rrc.drx_Config
    ...                 xpath=.//nr-rrc.drx_Config
    ${list_length}    Get Length    ${filter_output}
    Should Not Be Empty    ${list_length}    msg=DRX is not activated in current env.

Generate CA Related NIDD Params
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               to do: 2.need to change framestructure param list. eg. 1208 have no param:tdLteUlDlConfig
    ...                      3.carrierAggregationSupportList is mulit-option param. if need to input a list???
    [Arguments]    ${pcell_chbw}=80
    ...            ${scell_chbw}=80
    ...            ${maxNumScellsDl}=1
    ...            ${pucchModeSelect}=longPucch
    ...            ${sCellAdditionMethod}=blind
    ...            ${sCellActivationMethod}=blind
    ...            ${actCDrx}=false
    ...            ${actFdmScheduling}=true
    ...            ${actBeamforming}=true
    ...            ${basicBeamSet}=beamSet_3_1
    ...            ${nrBtsBeamRefinementP2}=false
    ...            ${carrierAggregationSupportList}=none
    ...            ${sCellDeactivationBadRlqCount}=1
    ...            ${sCellChannelEstimationPeriod}=2000
    ...            ${sCellGoodChannelQualityThreshold}=8
    ...            ${sCellBadChannelQualityThreshold}=15
    ...            ${mcsDeactSCellDl}=10
    ...            ${actMeasBasedSCellAddition}=false
    ...            ${actMeasBasedSCellAdditionNsa}=false
    ...            ${sCellDeactivationTimerGNB}=infinity
    ...            ${srbInactivityTimerSA}=600
    ...            ${drbInactivityTimerSA}=600
    ...            ${numberOfTransmittedSsBlocks}=4
    ...            ${actVoNR}=false
    ...            ${actGrflShdn}=false
    ...            ${actCDrxVoNR}=false
    ...            ${miNrRSACU}=5min
    ...            ${actEnhancedVoNR}=false
    ${common_params}    Catenate    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'chBw', 'value': '${pcell_chbw}MHz'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'chBw', 'value': '${scell_chbw}MHz'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'maxNumScellsDl', 'value': '${maxNumScellsDl}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'pucchModeSelect', 'value': '${pucchModeSelect}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'pucchModeSelect', 'value': '${pucchModeSelect}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}/NRREL-${Pre_PCELL_NRREL_INDEX}','parameter':'sCellAdditionMethod',
    ...                  'value':'${sCellAdditionMethod}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}/NRREL-${Pre_SCELL_NRREL_INDEX}','parameter':'sCellAdditionMethod',
    ...                  'value':'${sCellAdditionMethod}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'sCellActivationMethod', 'value': '${sCellActivationMethod}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'maxNumScellsDl', 'value': '${maxNumScellsDl}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'actCDrx', 'value': '${actCDrx}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'actCDrx', 'value': '${actCDrx}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'actFdmScheduling', 'value': '${actFdmScheduling}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'actBeamforming', 'value': '${actBeamforming}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'actBeamforming', 'value': '${actBeamforming}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter':'beamSet',
    ...    'value':[{'basicBeamSet':'${basicBeamSet}','leftEdgeAngle':'60','nrBtsBeamRefinementP2':'${nrBtsBeamRefinementP2}',
    ...    'rightEdgeAngle':'60'}]},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter':'beamSet',
    ...    'value':[{'basicBeamSet':'${basicBeamSet}','leftEdgeAngle':'60','nrBtsBeamRefinementP2':'${nrBtsBeamRefinementP2}',
    ...    'rightEdgeAngle':'60'}]},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRDU-1', 'parameter':'carrierAggregationSupportList',
    ...    'value':['${carrierAggregationSupportList}']},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'sCellDeactivationBadRlqCount', 'value': '${sCellDeactivationBadRlqCount}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'sCellChannelEstimationPeriod',
    ...                                                          'value': '${sCellChannelEstimationPeriod}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'sCellChannelEstimationPeriod',
    ...                                                          'value': '${sCellChannelEstimationPeriod}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'sCellGoodChannelQualityThreshold',
    ...                                                          'value': '${sCellGoodChannelQualityThreshold}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'sCellGoodChannelQualityThreshold',
    ...                                                          'value': '${sCellGoodChannelQualityThreshold}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'sCellBadChannelQualityThreshold',
    ...                                                          'value': '${sCellBadChannelQualityThreshold}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'sCellBadChannelQualityThreshold',
    ...                                                          'value': '${sCellBadChannelQualityThreshold}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'mcsDeactSCellDl', 'value': '${mcsDeactSCellDl}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'actMeasBasedSCellAddition', 'value': '${actMeasBasedSCellAddition}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'actMeasBasedSCellAdditionNsa', 'value': '${actMeasBasedSCellAdditionNsa}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'sCellDeactivationTimerGNB',
    ...                                                          'value': '${sCellDeactivationTimerGNB}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'sCellDeactivationTimerGNB',
    ...                                                          'value': '${sCellDeactivationTimerGNB}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'drbInactivityTimerSA', 'value': '${drbInactivityTimerSA}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'srbInactivityTimerSA', 'value': '${srbInactivityTimerSA}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELLGRP-0', 'parameter': 'numberOfTransmittedSsBlocks',
    ...                                                          'value': '${numberOfTransmittedSsBlocks} beams'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELLGRP-1', 'parameter': 'numberOfTransmittedSsBlocks',
    ...                                                          'value': '${numberOfTransmittedSsBlocks} beams'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRSYSINFO_PROFILE-0/NRIAFIM-1', 'parameter': 'numberOfTransmittedSsBlocks',
    ...                                                          'value': '${numberOfTransmittedSsBlocks} beams'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRSYSINFO_PROFILE-0/NRIRFIM-1', 'parameter': 'numberOfTransmittedSsBlocks',
    ...                                                          'value': '${numberOfTransmittedSsBlocks} beams'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'actVoNR', 'value': '${actVoNR}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'actVoNR', 'value': '${actVoNR}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'actGrflShdn', 'value': '${actGrflShdn}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'actCDrxVoNR', 'value': '${actCDrxVoNR}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'actCDrxVoNR', 'value': '${actCDrxVoNR}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'actEnhancedVoNR', 'value': '${actEnhancedVoNR}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'actEnhancedVoNR', 'value': '${actEnhancedVoNR}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRPMRNL-1', 'parameter': 'miNrRSACU', 'value': '${miNrRSACU}'}
    ${scell_arfcn}    Set Variable    ${SCELL_ARFCN_TABLE['${pcell_chbw}_${scell_chbw}']}
    ${extra_param}    Catenate    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'nrarfcn', 'value': '${scell_arfcn}'}
    ${extra_param}    Evaluate    [${extra_param}]
    ${common_params}    Evaluate     [${common_params}]
    ${update_params}    Combine Lists    ${extra_param}    ${common_params}
    [Return]    ${update_params}

Parameters Need To Modify For Measurement
    [Documentation]   Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]   ${nrcell_id}=NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...           ${nrhoif_id}=NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRHOIF-1
#    ...           ${nrrel_id}=NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRREL-0
    ...           ${gapOffset}=0
    ...           ${ifhoSsbSmtcOffset}=0
    ...           ${mgta}=0
    ...           ${measGapSelectionSA}=favourUeThroughput
    ...           ${a1MeashoEnabledSA}=rsrp
    ...           ${a2MeashoEnabledSA}=rsrp
    ...           ${a1HysteresishoSsbRsrpSA}=0
    ...           ${a1ThresholdhoSsbRsrpSA}=95
    ...           ${a1TimeToTriggerhoSsbRsrpSA}=ms480
    ...           ${a2HysteresishoSsbRsrpSA}=0
    ...           ${a2ThresholdhoSsbRsrpSA}=70
    ...           ${a2TimeToTriggerhoSsbRsrpSA}=ms128
    ...           ${a3MeasEnabled}=rsrp
    ...           ${a5MeasEnabled}=rsrp
    ...           ${a3HysteresisSsbRsrp}=3
    ...           ${a3OffsetSsbRsrp}=5
    ...           ${a3TimeToTriggerSsbRsrp}=ms480
    ...           ${a5HysteresisSsbRsrp}=3
    ...           ${a5Threshold1SsbRsrp}=75
    ...           ${a5Threshold2SsbRsrp}=75
    ...           ${a5TimeToTriggerSsbRsrp}=ms480
    &{gapOffset}    Create Dictionary    dist_name=${nrcell_id}   parameter=gapOffset    value=${gapOffset}
    &{ifhoSsbSmtcOffset}    Create Dictionary    dist_name=${nrcell_id}   parameter=ifhoSsbSmtcOffset    value=${ifhoSsbSmtcOffset}
    &{mgta}    Create Dictionary    dist_name=${nrcell_id}   parameter=mgta    value=${mgta}
    &{measGapSelectionSA}    Create Dictionary    dist_name=${nrcell_id}   parameter=measGapSelectionSA    value=${measGapSelectionSA}
    &{a1MeashoEnabledSA}    Create Dictionary    dist_name=${nrcell_id}   parameter=a1MeashoEnabledSA    value=${a1MeashoEnabledSA}
    &{a2MeashoEnabledSA}    Create Dictionary    dist_name=${nrcell_id}   parameter=a2MeashoEnabledSA    value=${a2MeashoEnabledSA}
    &{a3MeasEnabled}    Create Dictionary    dist_name=${nrhoif_id}   parameter=a3MeasEnabled    value=${a3MeasEnabled}
    &{a5MeasEnabled}    Create Dictionary    dist_name=${nrhoif_id}   parameter=a5MeasEnabled    value=${a5MeasEnabled}
    &{a1_rsrp_params}    Create Dictionary    a1HysteresishoSsbRsrpSA=${a1HysteresishoSsbRsrpSA}
    ...                                       a1ThresholdhoSsbRsrpSA=${a1ThresholdhoSsbRsrpSA}
    ...                                       a1TimeToTriggerhoSsbRsrpSA=${a1TimeToTriggerhoSsbRsrpSA}
    &{a2_rsrp_params}    Create Dictionary    a2HysteresishoSsbRsrpSA=${a2HysteresishoSsbRsrpSA}
    ...                                       a2ThresholdhoSsbRsrpSA=${a2ThresholdhoSsbRsrpSA}
    ...                                       a2TimeToTriggerhoSsbRsrpSA=${a2TimeToTriggerhoSsbRsrpSA}
    &{a3_rsrp_params}    Create Dictionary    a3HysteresisSsbRsrp=${a3HysteresisSsbRsrp}
    ...                                       a3OffsetSsbRsrp=${a3OffsetSsbRsrp}
    ...                                       a3TimeToTriggerSsbRsrp=${a3TimeToTriggerSsbRsrp}
    &{a5_rsrp_params}    Create Dictionary    a5HysteresisSsbRsrp=${a5HysteresisSsbRsrp}
    ...                                       a5Threshold1SsbRsrp=${a5Threshold1SsbRsrp}
    ...                                       a5Threshold2SsbRsrp=${a5Threshold2SsbRsrp}
    ...                                       a5TimeToTriggerSsbRsrp=${a5TimeToTriggerSsbRsrp}
    &{a1MeasSsbRsrp}    Evaluate    {'dist_name': '${nrcell_id}', 'parameter': 'a1MeashoSsbRsrpSA','value':[&{a1_rsrp_params}]}
    &{a2MeasSsbRsrp}    Evaluate    {'dist_name': '${nrcell_id}', 'parameter': 'a2MeashoSsbRsrpSA','value':[&{a2_rsrp_params}]}
    &{a3MeasSsbRsrp}    Evaluate    {'dist_name': '${nrhoif_id}', 'parameter': 'a3MeasSsbRsrp','value':[&{a3_rsrp_params}]}
    &{a5MeasSsbRsrp}    Evaluate    {'dist_name': '${nrhoif_id}', 'parameter': 'a5MeasSsbRsrp','value':[&{a5_rsrp_params}]}
    @{params_need_to_modify}    Create List    ${gapOffset}
    ...                                        ${ifhoSsbSmtcOffset}
    ...                                        ${mgta}
    ...                                        ${measGapSelectionSA}
    ...                                        ${a1MeashoEnabledSA}
    ...                                        ${a2MeashoEnabledSA}
    ...                                        ${a3MeasEnabled}
    ...                                        ${a5MeasEnabled}
    ...                                        ${a1MeasSsbRsrp}
    ...                                        ${a2MeasSsbRsrp}
    ...                                        ${a3MeasSsbRsrp}
    ...                                        ${a5MeasSsbRsrp}
   [Return]    @{params_need_to_modify}

Modify Measurement Parameters Via rest Api
    [Documentation]   Auther:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${timeout}=${60}    ${connection}=GNB_OAM
    ${params_to_modify}    Create List
    COAM Navigate to login page via webUI
    ${cell_num}    selenium_coam.get_number_of_cells
    FOR    ${cell_index}    IN RANGE    ${cell_num}
           ${params_need_to_modify}    Parameters Need To Modify For Measurement
           ...                         nrcell_id=NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
           ...                         nrhoif_id=NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRHOIF-1
           ${params_to_modify}    Combine Lists    ${params_to_modify}    ${params_need_to_modify}
    END
    COAM Update several parameters via rest api     parameters_to_delete_via_api=${params_to_modify}
    ...                                    timeout=${timeout}
    ...                                    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    Run Keywords    COAM Teardown gnb connections    connection=${connection}
    ...           AND    COAM selenium logout

Update HO Related NIDD Params
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]        ${actInterFreqHoSA}=false
    ...                ${actIntraFreqHoSA}=true
    &{actInterFreqHoSA}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}    parameter=actInterFreqHoSA    value=${actInterFreqHoSA}
    &{actIntraFreqHoSA}    Create Dictionary    dist_name=NRBTS-${NRBTS_ID}    parameter=actIntraFreqHoSA    value=${actIntraFreqHoSA}
    @{params_for_ho}    Create List    ${actInterFreqHoSA}    ${actIntraFreqHoSA}
    Update Params Via RestApi       params_need_to_modify=${params_for_ho}

Check A1 Meaurement Report
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               get value nr-rrc.reportConfigId via filter (nr-rrc.eventId == 0 ) && (f1ap.procedureCode == 12)
    ...               nr-rrc.measId   filter message measurement report:(f1ap.procedureCode == 13) && (nr-rrc.physCellId == 811)
    [Arguments]    ${log_path}
    Convert CPIF Pcap To Pdml    file_path=${log_path}
    ${all_measId_on_rrc_reconfig}    Get Field Value From Pdml
    ...    filter_expression=nr-rrc.eventId == 0 && f1ap.procedureCode == 12
    ...    xpath=.//nr-rrc.ReportConfigToAddMod_element/nr-rrc.reportConfigId
    Should Not Be Empty    ${all_measId_on_rrc_reconfig}    msg=A1 event is not on message RRC Reconfiguration.
    ${event_id_on_rrc_reconfig}    Get Field Value From Pdml
    ...    filter_expression=nr-rrc.eventId == 0 && f1ap.procedureCode == 12
    ...    xpath=.//nr-rrc.eventTriggered_element/nr-rrc.eventId
    ${A1_measId_on_measurement_report}    Get Field Value From Pdml
    ...    filter_expression=f1ap.procedureCode == 13 && nr-rrc.physCellId == ${PCELL_PHYS_ID}
    ...    xpath=.//nr-rrc.measId
    ${A1_event_index_in_list}    Get Index From List    ${A1_measId_on_measurement_report}    0
    ${A1_measId_on_rrc_reconfig}    Get From List    ${all_measId_on_rrc_reconfig}    ${A1_event_index_in_list}
    Should Be Equal As Strings    ${A1_measId_on_rrc_reconfig}    ${A1_measId_on_measurement_report[0]}
    ...    msg=A1 measurement is not triggered.

Add Meaurement Configuration For Target Event Id
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...            check measurement Configuration via tcpdump log
    ...            return measId/reportConfigId for related A? event
    [Arguments]    ${log_path}    ${event_id_list}
#    ${a3_a5_event_value}    Create List    2    4
    Convert CPIF Pcap To Pdml    file_path=${log_path}
    ${event_id_in_ReportConfigToAddMod}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.ReportConfigToAddMod_element)
    ...    xpath=.//nr-rrc.eventId
    List Should Contain Sub List    ${event_id_in_ReportConfigToAddMod}   ${event_id_list}
    ...          msg= Related measurment trigger failure during attach
    ${reportConfigId_in_ReportConfigToAddMod}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.ReportConfigToAddMod_element)
    ...    xpath=.//nr-rrc.ReportConfigToAddMod_element//nr-rrc.reportConfigId
    ${reportConfigId_list}    Create List
    FOR  ${item}  IN  @{event_id_list}
       ${index}    Get Index From List     ${event_id_in_ReportConfigToAddMod}    ${item}
       ${reportConfigId}    Get From List    ${reportConfigId_in_ReportConfigToAddMod}    ${index}
       Append To List    ${reportConfigId_list}   ${reportConfigId}
    END
    ${reportConfigId_in_measIdToAddModList}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.measIdToAddModList)
    ...    xpath=.//nr-rrc.MeasIdToAddMod_element//nr-rrc.reportConfigId
    List Should Contain Sub List    ${reportConfigId_in_measIdToAddModList}    ${reportConfigId_list}
    ${measid_in_measIdToAddModList}    Get Field Value From Pdml
    ...    filter_expression=(f1ap.procedureCode == 12) && (nr-rrc.measIdToAddModList)
    ...    xpath=.//nr-rrc.MeasIdToAddMod_element//nr-rrc.measId
    ${measId_list}    Create List
    FOR  ${item}  IN  @{reportConfigId_list}
       ${index}    Get Index From List     ${reportConfigId_in_measIdToAddModList}    ${item}
       ${measId}    Get From List    ${measid_in_measIdToAddModList}    ${index}
       Append To List    ${measId_list}   ${measId}
    END
    Set Test Variable    ${measId_list}
    Set Test Variable    ${reportConfigId_list}

Delete Measurement Configuration Via RRC Reconfiguration
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${log_path}
    Convert CPIF Pcap To Pdml    file_path=${log_path}
    ${ReportConfigId_value}    Get Field Value From Pdml
    ...    filter_expression=f1ap.procedureCode == 12
    ...    xpath=.//nr-rrc.ReportConfigId
    Should Not Be Empty    ${ReportConfigId_value}    msg=no matched ReportConfigId found in RRC Reconfiguration
    ${MeasId_value}    Get Field Value From Pdml
    ...    filter_expression=f1ap.procedureCode == 12
    ...    xpath=.//nr-rrc.MeasId
    Should Not Be Empty    ${MeasId_value}    msg=no matched MeasId found in RRC Reconfiguration
    [Return]   ${ReportConfigId_value}    ${MeasId_value}

Gnb Response To Add A2 Event via RRC reconfiguration
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${log_path}
    ${ssbFrequency_list}    Get ssbFrequency Value From SCF
    ${ssbFrequency_value}    Check Target Item Value on CPIF Tcpdump    file_path=${log_path}
    ...                                        filter_expression=f1ap.procedureCode == 12
    ...                                        xpath=.//nr-rrc.ssbFrequency
    Should Be Equal    ${ssbFrequency_value[0]}    ${ssbFrequency_list[${SCELL_INDEX}]}
#    ${measObjectId_value}    Check Target Item Value on CPIF Tcpdump    file_path=${log_path}
#    ...                                        filter_expression=f1ap.procedureCode == 12
#    ...                                        xpath=.//nr-rrc.MeasObjectToAddMod_element/nr-rrc.measObjectId
#    Set Test variable    ${measObjectId_value}
#    [Return]    ${measObjectId_value}

Check Measurement Gap Configuration
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${log_path}
    ${filter_output}    Check Target Item Value on CPIF Tcpdump    file_path=${log_path}
    ...                 filter_expression=f1ap.procedureCode == 12 and nr-rrc.gapUE
    ...                 xpath=.//nr-rrc.gapUE
    ${gapUE_value}    Set Variable    ${filter_output}
    [Return]    ${gapUE_value}

Check RLQ Deactivate Success
    [Documentation]    author:Stella.lin@nokia-sbell.com
    ...                check RLQ deactivate success via sysl
    [Arguments]    ${log_path}
    ${syslog_filter_pattern}    Create List
    ...    (?i)rlqalgorithm\\s+prepare\\s+sending\\s+scellstatusind\\s+with\\s+permanent\\s+deactivation
    Check Log Existence On Syslog    log_path=${log_path}    syslog_filter_pattern_list=${syslog_filter_pattern}

Check CA Supported List
    [Documentation]    author:Stella.lin@nokia-sbell.com
    ...                check CA supported list via syslog(aasyslog or btslog supported
    [Arguments]    ${syslog_path}    ${connection}=GNB_0AM    ${gnb_index}=0
    ${MO_result}    Get Managed Objects Via Rest API    class_name=NRDU_A    connection=${connection}
    ${ca_supported_list}    Set Variable    ${MO_result[0]['parameters']['carrierAggregationSupportList']}
    FOR    ${ca_type}    IN    @{ca_supported_list}
      ${syslog_filter_pattern}    Create List    (?i)carrierAggregationSupportList\\s+contains\\s+${ca_type}:\\s+true
      Run Keyword And Continue On Failure    Check Log Existence On Syslog
      ...    log_path=${log_path}
      ...    syslog_filter_pattern_list=${syslog_filter_pattern}
    END

CA Common Variable Setting
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               common used varibles setting on suite setup.
    [Arguments]    ${connection}=GNB_OAM    ${gnb_id}=0
    ...            ${pre_pcell_index}=0    ${pre_scell_index}=1
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    Set Suite Variable    ${Pre_PCELL_ID}    ${ALL_CELL_ID}[${pre_pcell_index}]
    Set Suite Variable    ${Pre_SCELL_ID}    ${ALL_CELL_ID}[${pre_scell_index}]
    ${Pre_PCELL_NRREL_INDEX}    Get The Nrrel Index    cell_index=${Pre_PCELL_ID}    connection=${connection}    gnb_index=${gnb_id}
    ${Pre_SCELL_NRREL_INDEX}    Get The Nrrel Index    cell_index=${Pre_SCELL_ID}     connection=${connection}    gnb_index=${gnb_id}
    Set Suite Variable    ${Pre_PCELL_NRREL_INDEX}
    Set Suite Variable    ${Pre_SCELL_NRREL_INDEX}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}


Delete Parameter sCellAdditionMethod Via Rest API
    [Documentation]   author:jun.8.chen@nokia-sbell.com
    ...               Delete nidd parameter sCellAdditionMethod via restapi.
    [Arguments]    ${cell_index}=${PCELL_ID}    ${nrrel_index}=${PCELL_NRREL_INDEX}
    ...            ${gnb_id}=0    ${timeout}=${60}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    ${distname}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRREL-${nrrel_index}
    ${delte_sCellAdditionMethod}    Evaluate    [dict(dist_name='${distname}', parameter='sCellAdditionMethod')]
    COAM delete parameters via rest api    parameters_to_delete_via_api=${delte_sCellAdditionMethod}
    ...                                    timeout=${timeout}
    ...                                    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Add Parameter sCellAdditionMethod Via Rest API
    [Documentation]   author:jun.8.chen@nokia-sbell.com
    ...               Add nidd parameter sCellAdditionMethod via restapi.
    [Arguments]    ${cell_index}=${PCELL_ID}    ${nrrel_index}=${PCELL_NRREL_INDEX}
    ...            ${gnb_id}=0    ${timeout}=${60}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    ${distname}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}/NRREL-${nrrel_index}
    ${add_sCellAdditionMethod}    Evaluate    [dict(dist_name='${distname}', parameter='sCellAdditionMethod', value='blind')]
    COAM Update several parameters via rest api    parameters_to_update_via_api=${add_sCellAdditionMethod}
    ...                                    timeout=${timeout}
    ...                                    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify Multi DRB Function
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               Description:Get DRB Index List On RRC Reconfiguration Message
    ...                           filter: (f1ap.procedureCode == 12) && (nr-rrc.drb_ToAddModList)
    ...                           Get LCID Index List On Dldata_Pdschpayloadtbsendreqdl_sch
    ...                           filter:
    ...                           lcid index should equal to drb index
    [Arguments]    ${cpif_log_path}    ${bip_log_path}
    ${DRB_index_list}    Check Target Item Value on CPIF Tcpdump
    ...                  file_path=${cpif_log_path}
    ...                  filter_expression=f1ap.procedureCode == 12 && nr-rrc.drb_ToAddModList
    ...                  xpath=.//nr-rrc.drb_Identity
    ${LCID_index_list}    Create List
    Comment  STEP:TODO  how to check multi drb on bip with luashark, no MAC-NR message.
    Lists Should Be Equal    ${DRB_index_list}    ${LCID_index_list}     msg=multi DRB function is not normal.

Check Buffer Deactivate Success
    [Documentation]    author:Stella.lin@nokia-sbell.com
    ...                check ca deactivate success after stop traffic via syslog:btslog or aasyslog
    [Arguments]    ${log_path}    ${deactive_round}=1
    ${output}    Filter Element On Syslog    log_path=${log_path}    syslog_filter_pattern=Secondary L2Lo deactivated
    Should Not Be Empty    ${output}    msg=scell deactivation failed
    ${deactive_time}    Get Regexp Matches   ${output}    <(\\d+-\\d+-\\d+)T(\\d+:\\d+:\\d+).*    1    2
    ${round}    Get Length    ${deactive_time}
    Should Be Equal    ${round}    ${deactive_round}    msg=expect deactive round is ${deactive_round}times,actually is ${round}times.

Online SCell Addition Method Modification
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${scell_addition_method}=covBasedA1     ${act_meas_scell_addition_flag}=true    ${connection}=GNB_OAM    ${gnb_index}=0
    ${scell_addition_method_parameter}    Catenate
    ...    {'abbr': 'sCellAdditionMethod', 'dist_name': 'NRCELL-${Pre_PCELL_ID}/NRREL-${Pre_PCELL_NRREL_INDEX}',
    ...     'filter_param': 'Secondary cell addition method','new_value': '${scell_addition_method}'},
    ...    {'abbr': 'sCellAdditionMethod', 'dist_name': 'NRCELL-${Pre_SCELL_ID}/NRREL-${Pre_SCELL_NRREL_INDEX}',
    ...     'filter_param': 'Secondary cell addition method','new_value': '${scell_addition_method}'},
    ...    {'abbr': 'actMeasBasedSCellAddition', 'dist_name': 'NRBTS-${NRBTS_ID}',
    ...     'filter_param': 'Activate measurement based secondary cell addition','new_value': '${act_meas_scell_addition_flag}'},
    ...    {'abbr': 'actMeasBasedSCellAddition', 'dist_name': 'NRBTS-${NRBTS_ID}',
    ...     'filter_param': 'Activate measurement based secondary cell addition for NSA','new_value': '${act_meas_scell_addition_flag}'}
    ${update_param_list}    Evaluate    [${scell_addition_method_parameter}]
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${update_param_list}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${True}

PCELL And SCELL Related Params Setting
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    ...               Set Suite Variable: ${PCELL_INDEX},${SCELL_INDEX},${PCELL_PHYS_ID},${SCELL_PHYS_ID},${PCELL_CHBW},${SCELL_CHBW}
    ...               get pcell id in message <InitialUEContext>,message filter: ngap.procedureCode == 15
    ...               TO DO: Only support 2cc, and pcell scell index is 0 or 1
    [Arguments]    ${cpif_log_path}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${pcell_nr_identity_on_wireshark}    Check Target Item Value on CPIF Tcpdump
    ...                                  file_path=${cpif_log_path}
    ...                                  filter_expression=ngap.procedureCode == 15
    ...                                  xpath=.//ngap.NRCellIdentity
    ...                                  filter=f1ap||nr-rrc||ngap
    ...                                  attribute_name=value
    ${pcell_nr_identity_on_wireshark}    Get Substring     ${pcell_nr_identity_on_wireshark[0]}    0   9
    ${pcell_nr_identity_on_wireshark}    Convert To Binary    ${pcell_nr_identity_on_wireshark}    base=16
    ${pcell_nr_identity}    Convert To Integer    ${pcell_nr_identity_on_wireshark}    base=2
    ${nr_identity_list}    Get NR Cell Identity   connection=${connection}    gnb_index=${gnb_index}
    List Should Contain Value    ${nr_identity_list}    ${pcell_nr_identity}    msg=UE is not attached to correct cell.
    ${cell_count}    Get Length    ${nr_identity_list}
    ${pcell_idx}    Get Index From List    ${nr_identity_list}    ${pcell_nr_identity}
    ${scell_idx}    Set Variable If    '${pcell_idx}'=='0'    1    0
    Set Suite Variable    ${PCELL_INDEX}    ${pcell_idx}
    Set Suite Variable    ${SCELL_INDEX}    ${scell_idx}
    Set Suite Variable    ${PCELL_ID}    ${ALL_CELL_ID[${PCELL_INDEX}]}
    Set Suite Variable    ${SCELL_ID}    ${ALL_CELL_ID[${SCELL_INDEX}]}
    Set Suite Variable    ${PCELL_GROUP_ID}    ${CELL_MAPPING_INFO[${PCELL_ID}]['cell_group_id']}
    Set Suite Variable    ${SCELL_GROUP_ID}    ${CELL_MAPPING_INFO[${SCELL_ID}]['cell_group_id']}
    ${physical_id_list}    Get Cell Physical ID    connection=${connection}    gnb_index=${gnb_index}
    Set Suite Variable    ${PCELL_PHYS_ID}    ${physical_id_list[${pcell_idx}]}
    Set Suite Variable    ${SCELL_PHYS_ID}    ${physical_id_list[${scell_idx}]}
    ${chbw_list}    Get Chbw Info     connection=${connection}    gnb_index=${gnb_index}
    Set Suite Variable    ${PCELL_CHBW}    ${chbw_list[${pcell_idx}]}
    Set Suite Variable    ${SCELL_CHBW}    ${chbw_list[${scell_idx}]}

PCELL And SCELL Related Params Setting For CA HO
    [Documentation]    Author：xiangyue.zhou@nokia-sbell.com
    ...               get source physical cell id in message <Measurement Report>,message filter: f1ap.procedureCode==13&&nr-rrc.physCellId
    ...               can be used both before or after handover for CA env
    [Arguments]    ${cpif_log_path}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${physical_id_list}    ${chBw_id_list}    ${nrarfcn_id_list}
    ...                          Get Required Parameters List For CA HO    connection=${connection}    gnb_index=${gnb_index}
    ${pcell_physical_id}         Check Target Item Value on CPIF Tcpdump
    ...                                  file_path=${cpif_log_path}
    ...                                  filter_expression=(f1ap.procedureCode==13)&&(nr-rrc.physCellId)
    ...                                  xpath=.//nr-rrc.measResultServingCell_element//nr-rrc.physCellId
    ...                                  filter=f1ap||nr-rrc||ngap
    ...                                  attribute_name=value
    Should Not Be Empty    ${pcell_physical_id}
    ${ho_complete}    Set Variable    ${False}
    ${length}    Get Length    ${pcell_physical_id}
    ${ho_complete}  Set variable If    ${length}>1   ${True}   ${False}
    ${msg_before_ho}    Convert to String   Get pcell physical id failure before HO
    ${msg_after_ho}    Convert to String   Get pcell physical id failure after HO
    Run Keyword And Continue On Failure    Run Keyword If    '${ho_complete}'=='${False}'    Should Be True    ${length}==1    msg=${msg_before_ho}
    ...                                    ELSE     Should Be True    ${length}==2    msg=${msg_after_ho}
    ${PCELL_INDEX}   ${SCELL_INDEX}    Get Pcell And Scell Id For CA HO
    ...                                physical_id_list=${physical_id_list}
    ...                                pcell_physical_id=${pcell_physical_id}
    Set Suite Variable    ${PCELL_INDEX}
    Set Suite Variable    ${SCELL_INDEX}
    Set Suite Variable    ${PCELL_PHYS_ID}    ${physical_id_list[${PCELL_INDEX}]}
    Set Suite Variable    ${SCELL_PHYS_ID}    ${physical_id_list[${SCELL_INDEX}]}
    Set Suite Variable    ${PCELL_CHBW}    ${chBw_id_list[${PCELL_INDEX}]}
    Set Suite Variable    ${SCELL_CHBW}    ${chBw_id_list[${SCELL_INDEX}]}

Get Pcell And Scell Id For CA HO
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                get pcell/scell index before or after handover
    ...                [return] ${PCELL_INDEX}    ${SCELL_INDEX}
    [Arguments]    ${physical_id_list}    ${pcell_physical_id}
    ${ho_complete}    Set Variable    ${False}
    ${length}    Get Length    ${pcell_physical_id}
    ${ho_complete}  Set variable If    ${length}>1   ${True}   ${False}
    ${pcell_physical_id_index}   Set Variable If    '${ho_complete}'=='${False}'    0   -1
    ${pcell_physical_id}    Get Substring    ${pcell_physical_id[${pcell_physical_id_index}]}    2
    ${pcell_physical_id} 	Convert To Binary	${pcell_physical_id} 	base=16
    ${pcell_physical_id}    Convert To Integer    ${pcell_physical_id}    base=2
    List Should Contain Value    ${physical_id_list}    ${pcell_physical_id}    msg=UE is not attached to correct cell.
    ${pcell_idx}    Get Index From List    ${physical_id_list}    ${pcell_physical_id}
    ${scell_idx}    Run Keyword If    '${pcell_idx}'=='0'    Set Variable    1
    ...             ELSE IF           '${pcell_idx}'=='1'    Set Variable    0
    ...             ELSE IF           '${pcell_idx}'=='2'    Set Variable    3
    ...             ELSE IF           '${pcell_idx}'=='3'    Set Variable    2
    ${PCELL_INDEX}    Set Variable    ${pcell_idx}
    ${SCELL_INDEX}    Set Variable    ${scell_idx}
    [Return]    ${PCELL_INDEX}    ${SCELL_INDEX}

Get Required Parameters List For CA HO
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...    return ${physical_id_list}=[71,72,73,74]
    ...    ${chBw_id_list}=[100MHZ,100MHZ,100MHZ,100MHZ]
    ...    ${nrarfcn_id_list}=[525996,525996,525996,525996]
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
#    ${nrCellIdentity_id_list}    Get NR Cell Identity    connection=${connection}    gnb_index=${gnb_index}
    ${physical_id_list}    Get Cell Physical ID    connection=${connection}    gnb_index=${gnb_index}
    ${chBw_id_list}    Get Chbw Info    connection=${connection}    gnb_index=${gnb_index}
    ${nrarfcn_id_list}    Get Nrarfcn Info    connection=${connection}    gnb_index=${gnb_index}
    [Return]     ${physical_id_list}    ${chBw_id_list}    ${nrarfcn_id_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Generate CA Call Tput Info Based On Chbw
    [Documentation]   Auther:stella.lin@nokia-sbell.com
    [Arguments]    ${pcell_chbw}=${PCELL_CHBW}
    ...            ${scell_chbw}=${SCELL_CHBW}
    ...            ${pcell_idx}=${PCELL_INDEX}
    ...            ${scell_idx}=${SCELL_INDEX}
    ...            ${is_ca_peak}=${False}
    tput_info.set_pcell_index     value=${pcell_idx}
    tput_info.set_scell_index     value=${scell_idx}
    tput_info.set_pcell_chbw      value=${pcell_chbw}
    tput_info.set_scell_chbw      value=${scell_chbw}
    ${tput_info} =     tput_info.get_tput_data_for_CA_call
    ${tput_info_based_on_chbw}    Set Variable If    ${is_ca_peak}    ${tput_info['${pcell_chbw}_${scell_chbw}']}
    ...                                                               ${tput_info['CA_WITHOUT_PEAK']}
    [Return]    ${tput_info_based_on_chbw}

Adjust Attenuation To Trigger HO
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]       ${PA0_value}=30   ${PA1_value}=15    ${PA_vendor}=HBTE
    Modify Attenuation Channel Vaules    value=${PA1_value}    vendor=${PA_vendor}    ru_id=1
    Sleep  5sec
    Modify Attenuation Channel Vaules    value=${PA0_value}    vendor=${PA_vendor}    ru_id=0
    Sleep  5sec

Verify HO Complete Via Btslog
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                verify handover success via syslog:btslog
    [Arguments]    ${log_path}    ${syslog_filter_pattern}
    ${output}    Filter Element On Syslog    log_path=${log_path}    syslog_filter_pattern=${syslog_filter_pattern}
    Should Not Be Empty    ${output}    msg=gNB SA handover is not complete !!!
    ${HO_complete_time}    Get Regexp Matches   ${output}    <(\\d+-\\d+-\\d+)T(\\d+:\\d+:\\d+).*    1    2
    ${HO_complete_time}    Set Variable    ${ho_complete_time}[-1]
    ${HO_complete_time}    Set Variable    ${ho_complete_time}[0]${ho_complete_time}[1]
    ${HO_complete_time}    Add Time To Date    ${ho_complete_time}    08:00:00
    Set Test Variable    ${HO_complete_time}

Make Voice Call
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${vc_alias}=test_voice_call    ${sleep_time}=15 sec    ${phone_number}=004488
    start_voice_call    vc_alias=${vc_alias}    ue_alias=UE_${ue_index}    to=${phone_number}
    Sleep    ${sleep_time}
    stop_voice_call    vc_alias=${vc_alias}

Get CA Related PM Counters List
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               MRBTS-***/NRBTS-***/NRPMRNL-1  miNrRSACU  5min
    ...               counter id: M55138C01001 and M55138C01002 for Vonr call
    ...                           M55138C00003 and M55138C00005 for CA or normal data call
    [Arguments]    ${pcell_index}=${PCELL_ID}    ${scell_index}=${SCELL_ID}
    ${pcell_related_counters}    Catenate    {'M55138C01001': 'CELLS/NRCELL-${pcell_index}/RSACU/SA_GBR_DRB_REQ'},
    ...                                      {'M55138C01002': 'CELLS/NRCELL-${pcell_index}/RSACU/SA_GBR_DRB_SUCC'},
    ...                                      {'M55138C00003': 'CELLS/NRCELL-${pcell_index}/RSACU/SGNB_SA_NGBR_DRB_REQ'},
    ...                                      {'M55138C00005': 'CELLS/NRCELL-${pcell_index}/RSACU/SGNB_SA_NGBR_DRB_SUCC'}
    ${pcell_related_counters_list}    Evaluate    [${pcell_related_counters}]
    ${scell_related_counters}    Catenate    {'M55138C01001': 'CELLS/NRCELL-${scell_index}/RSACU/SA_GBR_DRB_REQ'},
    ...                                      {'M55138C01002': 'CELLS/NRCELL-${scell_index}/RSACU/SA_GBR_DRB_SUCC'},
    ...                                      {'M55138C00003': 'CELLS/NRCELL-${scell_index}/RSACU/SGNB_SA_NGBR_DRB_REQ'},
    ...                                      {'M55138C00005': 'CELLS/NRCELL-${scell_index}/RSACU/SGNB_SA_NGBR_DRB_SUCC'}
    ${scell_related_counters_list}    Evaluate    [${scell_related_counters}]
    [Return]    ${pcell_related_counters_list}    ${scell_related_counters_list}
