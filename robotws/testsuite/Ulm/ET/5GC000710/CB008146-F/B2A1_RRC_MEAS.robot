*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB008146-F (test instance B2)

*** Keywords ***

B2A1_RRC_MEAS_REGEX
    [Arguments]              ${meascfg}   ${nrhoir}
    ${measIDs}=                           Set Variable   ${2}
    ${measObjectNR}=                      B2A1_RRC_MEAS.measObjectNR
    ${measObjectEUTRA}=                   B2A1_RRC_MEAS.measObjectEUTRA       ${nrhoir}   ${meascfg.earfcnValue}
    ${reportConfigNR}        ${measIDs}=  B2A1_RRC_MEAS.reportConfigNR        ${measIDs}  ${meascfg.a1MeashoEnabledSA}
    ${reportConfigInterRAT}  ${measIDs}=  B2A1_RRC_MEAS.reportConfigInterRAT  ${measIDs}  ${nrhoir}   ${meascfg.b2MeashoEnabled}
    ${measGapConfig}=                     B2A1_RRC_MEAS.measGapConfig
    ${measIdToAddModList}=                measIdToAddModList   ${measIDs}


    @{B2A1_RRC_MEAS_REGEX_LIST}=    Create List
    ...                             value DL-DCCH-Message
    ...                             message c1 : rrcReconfiguration
    ...                             measConfig
    ...                             measObjectToAddModList
    ...                             @{measObjectNR}
    ...                             @{measObjectEUTRA}
    ...                             reportConfigToRemoveList
    ...                             1
    ...                             reportConfigToAddModList
    ...                             @{reportConfigNR}
    ...                             @{reportConfigInterRAT}
    ...                             measIdToRemoveList
    ...                             1
    ...                             measIdToAddModList
    ...                             @{measIdToAddModList}
    ...                             @{measGapConfig}
    ...                             rrcReconfigurationComplete
    RETURN  ${B2A1_RRC_MEAS_REGEX_LIST}


measIdToAddModList
    [Arguments]   ${measIDs}
    @{measIdToAddMods}=  Create List
    ...                  measId \\d
    ...                  measObjectId \\d
    ...                  reportConfigId \\d

    @{measIdToAddModList}=  Create List
    FOR  ${i}  IN RANGE  ${measIDs}
        Append To List   ${measIdToAddModList}   @{measIdToAddMods}
    END
    RETURN  ${measIdToAddModList}

measObjectNR   #5G_CP_IF_RRC_3005
    ${khz}=              Get Regexp Matches    ${ssbScs}   (\\d+).*
    @{meas_object_nr}=   Create List
    ...                  measObjectId
    ...                  measObject measObjectNR
    ...                  ssbFrequency \\d+
    ...                  ssbSubcarrierSpacing kHz${khz[0][0]}
    ...                  smtc1
    ...                  periodicityAndOffset sf(1|2)0 : 0         #5G_CP_ARC_ALG_2433
    ...                  duration sf5
    ...                  referenceSignalConfig
    ...                  ssb-ConfigMobility
    ...                  deriveSSB-IndexFromCell TRUE              #hardcoded 5G_CP_IF_RRC_3047
    ...                  absThreshSS-BlocksConsolidation           #only applied to intra-frequency cell reselection
    ...                  quantityConfigIndex 1                     #hardcoded 5G_CP_IF_RRC_3033
    ...                  offsetMO
    ...                  freqBandIndicatorNR ${freqBandIndicatorNR}
    RETURN  ${meas_object_nr}


measObjectEUTRA
    [Arguments]    ${NRHOIR}  ${earfcnValue}
    @{meas_object_eutra}=  Create List
    ...    measObjectId
    ...    measObject measObjectEUTRA
    ...    carrierFreq ${earfcnValue}
    ...    allowedMeasBandwidth ${NRHOIR.allowedMeasBandwidth}
    ...    eutra-PresenceAntennaPort1 ${NRHOIR.presenceAntennaPort1}
    ...    widebandRSRQ-Meas (true|false)    # 5G_RAN_CP_33566: UE Capa
    RETURN  ${meas_object_eutra}


reportConfigInterRAT
    [Arguments]   ${measIDs}  ${NRHOIR}  ${b2MeashoEnabled}
    @{b2_report_cfg}=    Create List
    ...                  reportConfigId \\d
    ...                  reportConfig reportConfigInterRAT
    ...                  reportType eventTriggered
    ...                  eventId eventB2
    @{b2_report_quant}=  Create List
    ...                  rsType ssb
    ...                  reportInterval ${NRHOIR.b2reportInterval}
    ...                  reportAmount ${NRHOIR.b2reportAmount}
    ...                  reportQuantity
    ...                  rsrp TRUE
    ...                  rsrq TRUE
    ...                  sinr FALSE
    ...                  maxReportCells ${maxReportCells}
    @{b2_meas_cfg_rsrp_rrc}=   Create List
    ...                  @{b2_report_cfg}
    ...                  b2-Threshold1 rsrp : ${NRHOIR.b2Threshold1hoRsrp}
    ...                  b2-Threshold2EUTRA rsrp : ${NRHOIR.b2Threshold2hoRsrp}
    ...                  reportOnLeave ${reportOnLeave}
    ...                  hysteresis ${NRHOIR.b2HysteresishoRsrp}
    ...                  timeToTrigger ${NRHOIR.b2TimeToTriggerhoRsrp}
    ...                  @{b2_report_quant}
    @{b2_meas_cfg_rsrq_rrc}=   Create List
    ...                  @{b2_report_cfg}
    ...                  b2-Threshold1 rsrq : ${NRHOIR.b2Threshold1hoRsrq}
    ...                  b2-Threshold2EUTRA rsrq : ${NRHOIR.b2Threshold2hoRsrq}
    ...                  reportOnLeave ${reportOnLeave}
    ...                  hysteresis ${NRHOIR.b2HysteresishoRsrq}
    ...                  timeToTrigger ${NRHOIR.b2TimeToTriggerhoRsrq}
    ...                  @{b2_report_quant}
    @{b2_meas_cfg_rrc}=  IF  '${b2MeashoEnabled}' == 'rsrp' or '${b2MeashoEnabled}' == 'rsrpCombined'
    ...                                  Set Variable   ${b2_meas_cfg_rsrp_rrc}
    ...                              ELSE IF  '${b2MeashoEnabled}' == 'rsrq' or '${b2MeashoEnabled}' == 'rsrqCombined'
    ...                                  Set Variable   ${b2_meas_cfg_rsrq_rrc}
    ...                              ELSE IF  '${b2MeashoEnabled}' == 'rsrpAndRsrq'
    ...                                  Create List   @{b2_meas_cfg_rsrp_rrc}  @{b2_meas_cfg_rsrq_rrc}

    IF       '${b2MeashoEnabled}' == 'rsrpAndRsrq'
    ...                  Set Test Variable  ${measIDs}  ${measIDs+1}
    RETURN  ${b2_meas_cfg_rrc}  ${measIDs}


reportConfigNR
    [Arguments]   ${measIDs}  ${a1MeashoEnabledSA}
    @{a1_report_cfg}=    Create List
    ...                  reportConfigId \\d
    ...                  reportConfig reportConfigNR
    ...                  reportType eventTriggered
    ...                  eventId eventA1
    @{a1_report_quant}=  Create List
    ...                  rsType ssb
    ...                  reportInterval ${reportIntervalSA}
    ...                  reportAmount ${reportAmountSA}
    ...                  reportQuantityCell
    ...                  rsrp TRUE
    ...                  rsrq TRUE
    ...                  sinr TRUE
    ...                  maxReportCells ${maxReportCells}
    ...                  reportQuantityRS-Indexes
    ...                  rsrp TRUE
    ...                  rsrq TRUE
    ...                  sinr TRUE
    ...                  maxNrofRS-IndexesToReport ${maxNrofIndexesToReport}
    ...                  includeBeamMeasurements ${includeBeamMeasurements}
    @{a1_meas_cfg_rsrp_rrc}=   Create List
    ...                  @{a1_report_cfg}
    ...                  a1-Threshold rsrp : ${a1ThresholdhoSsbRsrpSA}
    ...                  reportOnLeave ${reportOnLeave}
    ...                  hysteresis ${a1HysteresishoSsbRsrpSA}
    ...                  timeToTrigger ${a1TimeToTriggerhoSsbRsrpSA}
    ...                  @{a1_report_quant}
    @{a1_meas_cfg_rsrq_rrc}=   Create List
    ...                  @{a1_report_cfg}
    ...                  a1-Threshold rsrq : ${a1ThresholdhoSsbRsrqSA}
    ...                  reportOnLeave ${reportOnLeave}
    ...                  hysteresis ${a1HysteresishoSsbRsrqSA}
    ...                  timeToTrigger ${a1TimeToTriggerhoSsbRsrqSA}
    ...                  @{a1_report_quant}
    @{a1_meas_cfg_rrc}=  IF  '${a1MeashoEnabledSA}' == 'rsrp' or '${a1MeashoEnabledSA}' == 'rsrpCombined'
    ...                                  Set Variable   ${a1_meas_cfg_rsrp_rrc}
    ...                              ELSE IF  '${a1MeashoEnabledSA}' == 'rsrq' or '${a1MeashoEnabledSA}' == 'rsrqCombined'
    ...                                  Set Variable   ${a1_meas_cfg_rsrq_rrc}
    ...                              ELSE IF  '${a1MeashoEnabledSA}' == 'rsrpAndRsrq'
    ...                                  Create List   @{a1_meas_cfg_rsrp_rrc}  @{a1_meas_cfg_rsrq_rrc}

    IF        '${a1MeashoEnabledSA}' == 'rsrpAndRsrq'
    ...                   Set Test Variable  ${measIDs}  ${measIDs+1}
    RETURN  ${a1_meas_cfg_rrc}  ${measIDs}


ssb-FilterConfig
    @{ssb_fc_rsrp}=  IF  '${filterCoeffSsbRsrp}' != 'fc4'
    ...                              Create List  filterCoefficientRSRP ${filterCoeffSsbRsrp}
    ...                          ELSE
    ...                              Create List
    @{ssb_fc_rsrq}=  IF  '${filterCoeffSsbRsrq}' != 'fc4'
    ...                              Create List  filterCoefficientRSRQ ${filterCoeffSsbRsrq}
    ...                          ELSE
    ...                              Create List

    @{ssb-FilterConfig}=  Create List
    ...                   @{ssb_fc_rsrp}
    ...                   @{ssb_fc_rsrq}
    RETURN  ${ssb-FilterConfig}


quantityConfig
    ${ssb-FilterConfig}=  ssb-FilterConfig

    @{quantityConfig}=    Create List
    ...                   quantityConfig
    ...                   quantityConfigNR-List
    ...                   quantityConfigCell
    ...                   ssb-FilterConfig
    ...                   @{ssb-FilterConfig}
    ...                   csi-RS-FilterConfig
    ...                   quantityConfigRS-Index
    ...                   ssb-FilterConfig
    ...                   @{ssb-FilterConfig}
    ...                   csi-RS-FilterConfig
    ...                   quantityConfigEUTRA
    RETURN  ${quantityConfig}


measGapConfig
    #mgl=ms6 (only) for supported gap pattern id 0,1 by AP capab. (5G_RAN_CP_35298)
    # 24R2: new def. val for actFlexGapOffset -> gapOffset calc changed (needs to be verified): 5G_CP_ARC_ALG_11666
    # WA: hard coded value applied
    ${mgrp}=  Set Variable If
    ...     '${measGapSelectionSA}' == 'favourUeThroughput'       ms80
    ...     '${measGapSelectionSA}' == 'favourFastMeasurements'   ms40
    ...     ${True}                                               ms40   #balancedChoice

    ${mgrp_val}=   Remove String   ${mgrp}  ms
#    ${gapOffset}=  Set Variable If
#    ...    ${gapOffset} < ${mgrp_val}   ${gapOffset}
#    ...    ${True}                      0

    @{measGapConfig}=  Create List
    ...                measGapConfig
    ...                gapUE setup
    ...                gapOffset \\d+
    ...                mgl ms6
    ...                mgrp ${mgrp}
    ...                mgta ${mgta}
    RETURN  ${measGapConfig}
