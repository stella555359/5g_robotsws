*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB008146-F (test instance B1)

*** Keywords ***

A2_RRC_MEAS_REGEX
    [Arguments]              ${meascfg}  ${a2measconfig}
    ${measConfig}=           Set Variable   value DL-DCCH-Message.*rrcReconfiguration.*measConfig
    ${measObjectNR}=         B2A1_RRC_MEAS.measObjectNR
    ${reportConfigNR}=       A2_RRC_MEAS.reportConfigNR  ${meascfg.a2MeashoEnabledSA}  ${a2measconfig}
    ${quantityConfig}=       A2_RRC_MEAS.quantityConfig

    ${measObjectList}=      catenate  SEPARATOR=
    ...    measObjectToAddModList.*
    ...    ${measObjectNR}

    ${reportConfigList}=    catenate  SEPARATOR=
    ...    reportConfigToAddModList.*${reportConfigNR}

    ${measIdList}=   catenate  SEPARATOR=
    ...    measIdToAddModList.*measId \\d+.*measObjectId \\d+.*reportConfigId \\d+

    @{A2_RRC_MEAS_REGEX_LIST}=    Create List    ${measConfig}.*${measObjectList}.*rrcReconfigurationComplete
    ...                                          ${measConfig}.*${reportConfigNR}.*rrcReconfigurationComplete
    ...                                          ${measConfig}.*${reportConfigList}.*rrcReconfigurationComplete
    ...                                          ${measConfig}.*${measIdList}.*rrcReconfigurationComplete
    ...                                          ${measConfig}.*${quantityConfig}.*rrcReconfigurationComplete
    RETURN  ${A2_RRC_MEAS_REGEX_LIST}

reportConfigNR
    [Arguments]          ${a2MeashoEnabledSA}  ${a2measconfig}
    ${a2_report_cfg}=    Set Variable
    ...                  reportConfigId \\d+.*reportConfig reportConfigNR.*reportType eventTriggered.*eventId eventA2.*
    ${a2_report_quant}=  catenate  SEPARATOR=
    ...                  rsType ssb.*reportInterval ${reportIntervalSA}.*reportAmount ${reportAmountSA}.*
    ...                  reportQuantityCell.*rsrp TRUE.*rsrq TRUE.*sinr TRUE.*
    ...                  maxReportCells ${maxReportCells}.*
    ...                  reportQuantityRS-Indexes.*rsrp TRUE.*rsrq TRUE.*sinr TRUE.*
    ...                  maxNrofRS-IndexesToReport ${maxNrofIndexesToReport}.*
    ...                  includeBeamMeasurements ${includeBeamMeasurements}.*
    ${a2_meas_cfg_rsrp_rrc}=   catenate  SEPARATOR=
    ...                  ${a2_report_cfg}
    ...                  a2-Threshold rsrp : ${a2measconfig.a2ThresholdhoSsbRsrpSA}.*
    ...                  reportOnLeave ${reportOnLeave}.*
    ...                  hysteresis ${a2measconfig.a2HysteresishoSsbRsrpSA}.*
    ...                  timeToTrigger ${a2measconfig.a2TimeToTriggerhoSsbRsrpSA}.*
    ...                  ${a2_report_quant}
    ${a2_meas_cfg_rsrq_rrc}=   catenate  SEPARATOR=
    ...                  ${a2_report_cfg}
    ...                  a2-Threshold rsrq : ${a2measconfig.a2ThresholdhoSsbRsrqSA}.*
    ...                  reportOnLeave ${reportOnLeave}.*
    ...                  hysteresis ${a2measconfig.a2HysteresishoSsbRsrqSA}.*
    ...                  timeToTrigger ${a2measconfig.a2TimeToTriggerhoSsbRsrqSA}.*
    ...                  ${a2_report_quant}
    ${a2_meas_cfg_rrc}=  IF  '${a2MeashoEnabledSA}' == 'rsrp' or '${a2MeashoEnabledSA}' == 'rsrpCombined'
    ...                                  Set Variable   ${a2_meas_cfg_rsrp_rrc}
    ...                              ELSE IF  '${a2MeashoEnabledSA}' == 'rsrq' or '${a2MeashoEnabledSA}' == 'rsrqCombined'
    ...                                  Set Variable   ${a2_meas_cfg_rsrq_rrc}
    ...                              ELSE IF  '${a2MeashoEnabledSA}' == 'rsrpAndRsrq'
    ...                                  catenate   ${a2_meas_cfg_rsrp_rrc}  ${a2_meas_cfg_rsrq_rrc}
    RETURN  ${a2_meas_cfg_rrc}

quantityConfig
    ${ssb-FilterConfig}=  B2A1_RRC_MEAS.ssb-FilterConfig

    ${quantityConfig}=    catenate  SEPARATOR=
    ...    quantityConfig.*quantityConfigNR-List.*
    ...    quantityConfigCell.*${ssb-FilterConfig}.*
    ...    quantityConfigRS-Index.*${ssb-FilterConfig}.*
    RETURN  ${quantityConfig}

Verify A2 Addition
    [Arguments]  ${filename}  ${meascfg}=${MEAS_CFG_2}  ${a2measconfig}=${A2_MEAS_CFG}

    @{RRC_reconfig_prefix_seq}=       RRC_reconfig_prefix_seq
    @{measConfig_seq}=                Create List
    ...    measConfig
    @{measObjectToAddModList_seq}=    measObjectToAddModList_seq
    @{reportConfigToAddModList_seq}=  reportConfigToAddModList_seq  ${meascfg.a2MeashoEnabledSA}  ${a2measconfig}
    @{measIdToAddModList_seq}=        measIdToAddModList_seq
    @{quantityConfig_seq}=            quantityConfig_seq

    @{pattern_seq}=                   Create List
    ...    @{RRC_reconfig_prefix_seq}
    ...    @{measConfig_seq}
    ...    @{measObjectToAddModList_seq}
    ...    @{reportConfigToAddModList_seq}
    ...    @{measIdToAddModList_seq}
    ...    @{quantityConfig_seq}
    ...    message c1 : rrcReconfigurationComplete

    Verify sequence in Egate file  ${filename}  @{pattern_seq}

Verify B2 Removal
    [Arguments]  ${filename}

    @{RRC_reconfig_prefix_seq}=       RRC_reconfig_prefix_seq
    @{measConfig_seq}=                Create List
    ...    measConfig
    @{measObjectToRemoveList_seq}=    Create List
    ...    measObjectToRemoveList
    ...    \\d+
    @{measObjectToAddModList_seq}=    measObjectToAddModList_seq
    @{b2_ids}=  IF  '${MEAS_CFG_2.b2MeashoEnabled}' == 'rsrpAndRsrq'
    ...                         Create List  \\d+  \\d+
    ...                     ELSE IF  '${MEAS_CFG_2.b2MeashoEnabled}' == 'none'
    ...                         Create List
    ...                     ELSE
    ...                         Create List  \\d+
    @{a1_ids}=  IF  '${MEAS_CFG_2.a1MeashoEnabledSA}' == 'rsrpAndRsrq'
    ...                         Create List  \\d+  \\d+
    ...                     ELSE IF  '${MEAS_CFG_2.a1MeashoEnabledSA}' == 'none'
    ...                         Create List
    ...                     ELSE
    ...                         Create List  \\d+
    @{reportConfigToRemoveList_seq}=  Create List
    ...    reportConfigToRemoveList
    ...    @{b2_ids}
    ...    @{a1_ids}
    @{reportConfigToAddModList_seq}=  reportConfigToAddModList_seq  ${MEAS_CFG_2.a2MeashoEnabledSA}  ${A2_MEAS_CFG}
    @{measIdToRemoveList_seq}=        Create List
    ...    measIdToRemoveList
    ...    @{b2_ids}
    ...    @{a1_ids}
    @{measIdToAddModList_seq}=        measIdToAddModList_seq
    @{quantityConfig_seq}=            quantityConfig_seq
    @{measGapConfig_seq}=             Create List
    ...    measGapConfig
    ...    gapUE release : NULL

    @{pattern_seq}=                   Create List
    ...    @{RRC_reconfig_prefix_seq}
    ...    @{measConfig_seq}
    ...    @{measObjectToRemoveList_seq}
    ...    @{measObjectToAddModList_seq}
    ...    @{reportConfigToRemoveList_seq}
    ...    @{reportConfigToAddModList_seq}
    ...    @{measIdToRemoveList_seq}
    ...    @{measIdToAddModList_seq}
#    ...    @{quantityConfig_seq}   #  PR658130
    ...    @{measGapConfig_seq}
    ...    message c1 : rrcReconfigurationComplete

    Verify sequence in Egate file  ${filename}  @{pattern_seq}

RRC_reconfig_prefix_seq
    @{RRC_reconfig_prefix_seq}=  Create List
    ...    message c1 : rrcReconfiguration
    ...    rrc-TransactionIdentifier \\d+
    ...    criticalExtensions rrcReconfiguration
    RETURN  @{RRC_reconfig_prefix_seq}

measObjectToAddModList_seq
    @{measObjectNR_seq}=  measObjectNR_seq
    @{measObjectToAddModList_seq}=  Create List
    ...    measObjectToAddModList
    ...    @{measObjectNR_seq}
    RETURN  @{measObjectToAddModList_seq}

measObjectNR_seq
    ${khz}=              Get Regexp Matches    ${ssbScs}   (\\d+).*
    @{measObjectNR_seq}=  Create List
    ...    measObjectId \\d+
    ...    measObject measObjectNR
    ...    ssbFrequency \\d+
    ...    ssbSubcarrierSpacing kHz${khz[0][0]}
    ...    smtc1
    ...    periodicityAndOffset sf(1|2)0 : 0
    ...    duration sf5
    ...    referenceSignalConfig
    ...    ssb-ConfigMobility
#    ...    ssb-ToMeasure setup : mediumBitmap
    ...    deriveSSB-IndexFromCell TRUE
    ...    absThreshSS-BlocksConsolidation
    ...    quantityConfigIndex 1
    ...    offsetMO
    ...    freqBandIndicatorNR ${freqBandIndicatorNR}
    RETURN  @{measObjectNR_seq}

reportConfigToAddModList_seq
    [Arguments]  ${a2MeashoEnabledSA}  ${a2measconfig}
    @{reportConfigNR_seq}=  reportConfigNR_seq  ${a2MeashoEnabledSA}  ${a2measconfig}
    @{reportConfigToAddModList_seq}=  Create List
    ...    reportConfigToAddModList
    ...    @{reportConfigNR_seq}
    RETURN  @{reportConfigToAddModList_seq}

reportConfigNR_seq
    [Arguments]  ${a2MeashoEnabledSA}  ${a2measconfig}
    @{a2_report_cfg}=  Create List
    ...    reportConfigId \\d+
    ...    reportConfig reportConfigNR
    ...    reportType eventTriggered
    ...    eventId eventA2
    @{a2_report_quant}=  Create List
    ...    rsType ssb
    ...    reportInterval ${reportIntervalSA}
    ...    reportAmount ${reportAmountSA}
    ...    reportQuantityCell
    ...    rsrp TRUE
    ...    rsrq TRUE
    ...    sinr TRUE
    ...    maxReportCells ${maxReportCells}
    ...    reportQuantityRS-Indexes
    ...    rsrp TRUE
    ...    rsrq TRUE
    ...    sinr TRUE
    ...    maxNrofRS-IndexesToReport ${maxNrofIndexesToReport}
    ...    includeBeamMeasurements ${includeBeamMeasurements}
    @{a2_meas_cfg_rsrp_rrc}=  Create List
    ...    @{a2_report_cfg}
    ...    a2-Threshold rsrp : ${a2measconfig.a2ThresholdhoSsbRsrpSA}
    ...    reportOnLeave ${reportOnLeave}
    ...    hysteresis ${a2measconfig.a2HysteresishoSsbRsrpSA}
    ...    timeToTrigger ${a2measconfig.a2TimeToTriggerhoSsbRsrpSA}
    ...    @{a2_report_quant}
    @{a2_meas_cfg_rsrq_rrc}=  Create List
    ...    @{a2_report_cfg}
    ...    a2-Threshold rsrq : ${a2measconfig.a2ThresholdhoSsbRsrqSA}
    ...    reportOnLeave ${reportOnLeave}
    ...    hysteresis ${a2measconfig.a2HysteresishoSsbRsrqSA}
    ...    timeToTrigger ${a2measconfig.a2TimeToTriggerhoSsbRsrqSA}
    ...    @{a2_report_quant}
    @{a2_meas_cfg_rrc}=  IF  '${a2MeashoEnabledSA}' == 'rsrp' or '${a2MeashoEnabledSA}' == 'rsrpCombined'
    ...                                  Create List  @{a2_meas_cfg_rsrp_rrc}
    ...                              ELSE IF  '${a2MeashoEnabledSA}' == 'rsrq' or '${a2MeashoEnabledSA}' == 'rsrqCombined'
    ...                                  Create List  @{a2_meas_cfg_rsrq_rrc}
    ...                              ELSE IF  '${a2MeashoEnabledSA}' == 'rsrpAndRsrq'
    ...                                  Create List  @{a2_meas_cfg_rsrp_rrc}  @{a2_meas_cfg_rsrq_rrc}
    RETURN  @{a2_meas_cfg_rrc}

measIdToAddModList_seq
    @{measIdToAddModList_seq}=  Create List
    ...    measIdToAddModList
    ...    measId \\d+
    ...    measObjectId \\d+
    ...    reportConfigId \\d+
    RETURN  @{measIdToAddModList_seq}

quantityConfig_seq
    @{ssb-FilterConfig_seq}=  ssb-FilterConfig_seq
    @{quantityConfig_seq}=  Create List
    ...   quantityConfig
    ...   quantityConfigNR-List
    ...   quantityConfigCell
    ...   @{ssb-FilterConfig_seq}
    ...   quantityConfigRS-Index
    ...   @{ssb-FilterConfig_seq}
    RETURN  @{quantityConfig_seq}

ssb-FilterConfig_seq
    @{ssb_fc_rsrp}=  IF  '${filterCoeffSsbRsrp}' != 'fc4'
    ...                              Create List  filterCoefficientRSRP ${filterCoeffSsbRsrp}
    ...                          ELSE
    ...                              Create List

    @{ssb_fc_rsrq}=  IF  '${filterCoeffSsbRsrq}' != 'fc4'
    ...                              Create List  filterCoefficientRSRQ ${filterCoeffSsbRsrq}
    ...                          ELSE
    ...                              Create List

    @{ssb-FilterConfig_seq}=  Create List
    ...   ssb-FilterConfig
    ...   @{ssb_fc_rsrp}
    ...   @{ssb_fc_rsrq}
    ...   csi-RS-FilterConfig

    RETURN  @{ssb-FilterConfig_seq}
