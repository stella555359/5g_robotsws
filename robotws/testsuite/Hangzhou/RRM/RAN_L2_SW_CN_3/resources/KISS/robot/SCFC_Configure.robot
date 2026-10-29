*** Settings ***
Library           XML 

*** Variables ***
${version}        xL18A_1807_002
${qci1eVTTConfig}    <list name="qci1eVTTConfig"><item><p name="qci1DlTargetBler">50</p><p name="qci1HarqMaxTrDl">3</p>
...    <p name="qci1HarqMaxTrUl">3</p><p name="qci1ReconStopTimer">50</p><p name="qci1ThroughputFactorDl">40</p>
...    <p name="qci1ThroughputFactorUl">40</p><p name="qci1UlTargetBler">5</p></item></list>
${SPSConfig}      <list name="ulSpsConfig"><item><p name="amrVoiceBRThreshold">33</p><p name="maxNumSpsUeUl">6</p><p name="p0NomPuschSps">-80</p>
...    <p name="ulSpsInterval">20subframes</p><p name="ulSpsMaxNumPrb">20</p><p name="ulSpsMaxPrbPerUeNB">4</p><p name="ulSpsMaxPrbPerUeWB">8</p>
...    <p name="ulSpsMinVoicePktSize">25</p><p name="ulSpsNumEmptyTransmissions">e4</p><p name="ulSpsQci1ThroughputFactor">20</p>
...    <p name="ulSpsTwoIntervalConfig">true</p><p name="ulSpsVoicePktTbsNB">big</p><p name="ulSpsVoicePktTbsWB">big</p>
...    <p name="ulTargetBlerSps">10</p></item></list>
${CADPR}          <managedObject class="NOKLTE:CADPR" distName="MRBTS-2532/LNBTS-2532/CADPR-0" operation="create" version="${version}">
...    <p name="a3Offset">10</p><p name="a3TimeToTrigger">ms320</p><p name="a3TriggerQuantity">RSRP</p><p name="a6Offset">6</p>
...    <p name="a6ReportInterval">640ms</p><p name="a6TimeToTrigger">320ms</p><p name="enableA3Event">true</p><p name="enableA6Event">true</p>
...    <p name="enableFreqPrioSwap">disabled</p><p name="hysA3Offset">10</p><p name="hysA6Offset">0</p><p name="maxNumMimoLayerFdd">10</p>
...    <p name="maxNumMimoLayerTdd">12</p><p name="maxNumScellSwaps">0</p><p name="sFreqPrio">1</p><p name="scellMeasThreshRsrp">-100</p>
...    <p name="scellMeasThreshRsrq">-120</p><p name="scellPdcchOlLa">enabledScellBased</p></managedObject>
${CAGENB}         <managedObject class="NOKLTE:CAGENB" distName="MRBTS-2532/LNBTS-2532/CAGENB-0" operation="create" version="${version}">
...    <p name="actEnhCaBandCombSel">off</p><p name="caScellSchedWtFactMinCqi">6</p><p name="nlcvDeltaX2C2">2</p>
...    <p name="maxDlCaConfigForUlCa">max_3CC_DL_CA</p></managedObject>
${CAREL_1_2}      <managedObject class="NOKLTE:CAREL" distName="MRBTS-2532/LNBTS-2532/LNCEL-1/CAREL-2" operation="create" version="${version}">
...    <p name="lnBtsId">2532</p><p name="lcrId">2</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${CAREL_1_3}      <managedObject class="NOKLTE:CAREL" distName="MRBTS-2532/LNBTS-2532/LNCEL-1/CAREL-3" operation="create" version="${version}">
...    <p name="lnBtsId">2532</p><p name="lcrId">3</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${CAREL_2_1}      <managedObject class="NOKLTE:CAREL" distName="MRBTS-2532/LNBTS-2532/LNCEL-2/CAREL-1" operation="create" version="${version}">
...    <p name="lnBtsId">2532</p><p name="lcrId">1</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${CAREL_2_3}      <managedObject class="NOKLTE:CAREL" distName="MRBTS-2532/LNBTS-2532/LNCEL-2/CAREL-3" operation="create" version="${version}">
...    <p name="lnBtsId">2532</p><p name="lcrId">3</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${CAREL_3_1}      <managedObject class="NOKLTE:CAREL" distName="MRBTS-2532/LNBTS-2532/LNCEL-3/CAREL-1" operation="create" version="${version}">
...    <p name="lnBtsId">2532</p><p name="lcrId">1</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${CAREL_3_2}      <managedObject class="NOKLTE:CAREL" distName="MRBTS-2532/LNBTS-2532/LNCEL-3/CAREL-2" operation="create" version="${version}">
...    <p name="lnBtsId">2532</p><p name="lcrId">2</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${redBwRbUlConfig}    <list name="redBwRbUlConfig"><item><p name="redBwMaxRbUl">25</p><p name="redBwMinRbUl">1</p></item></list>
${C_plan_overload}    <list name="cpovlha"><item><p name="enableInHoRed">OVL1andL2</p><p name="enableRrcConnRed">OVL1andL2</p></item></list>
${U_plan_overload}    <list name="upovlha"><item><p name="enableERabSetupRed">none</p><p name="enableInHoRed">none</p>
...    <p name="enableRrcConnRed">none</p><p name="enableSuspendSrs">none</p><p name="enableTxDivTransmission">none</p></item></list>
${interferenceAwareListUL_PC}    <list name="ulpcIAwConfig"><item><p name="p0NomPuschIAw">-100</p><p name="ulpcCEBalanceIAw">10</p>
...    <p name="ulpcMinQualIAw">10</p><p name="ulpcMinWaitForPc">25</p><p name="ulpcRefPwrIAw">-208</p></item></list>
${LNREL_1}        <managedObject class="NOKLTE:LNREL" distName="MRBTS-2532/LNBTS-2532/LNCEL-1/LNREL-1" operation="create" version="${version}">
...    <p name="amleAllowed">false</p><p name="cellIndOffNeigh">0dB</p><p name="handoverAllowed">allowed</p><p name="ecgiLcrId">3</p>
...    <p name="ecgiAdjEnbId">1</p><p name="nrControl">automatic</p><p name="removeAllowed">true</p><list name="ecgiPlmnId"><item>
...    <p name="mcc">262</p><p name="mnc">3</p><p name="mncLength">2</p></item></list></managedObject>
${LNREL_2}        <managedObject class="NOKLTE:LNREL" distName="MRBTS-2532/LNBTS-2532/LNCEL-2/LNREL-1" operation="create" version="${version}">
...    <p name="amleAllowed">false</p><p name="cellIndOffNeigh">0dB</p><p name="handoverAllowed">allowed</p><p name="ecgiLcrId">3</p>
...    <p name="ecgiAdjEnbId">1</p><p name="nrControl">automatic</p><p name="removeAllowed">true</p><list name="ecgiPlmnId"><item>
...    <p name="mcc">262</p><p name="mnc">3</p><p name="mncLength">2</p></item></list></managedObject>
${LNREL_3}        <managedObject class="NOKLTE:LNREL" distName="MRBTS-2532/LNBTS-2532/LNCEL-3/LNREL-1" operation="create" version="${version}">
...    <p name="amleAllowed">false</p><p name="cellIndOffNeigh">0dB</p><p name="handoverAllowed">allowed</p><p name="ecgiLcrId">3</p>
...    <p name="ecgiAdjEnbId">1</p><p name="nrControl">automatic</p><p name="removeAllowed">true</p><list name="ecgiPlmnId"><item>
...    <p name="mcc">262</p><p name="mnc">3</p><p name="mncLength">2</p></item></list></managedObject>
${LNHOIF_1}       <managedObject class="NOKLTE:LNHOIF" distName="MRBTS-2532/LNBTS-2532/LNCEL-1/LNHOIF-1" operation="create" version="${version}">
...    <p name="a5ReportIntervalInterFreq">480ms</p><p name="a5TimeToTriggerInterFreq">80ms</p><p name="eutraCarrierInfo">40042</p>
...    <p name="offsetFreqInter">0dB</p><p name="measurementBandwidth">mbw100</p><p name="measQuantInterFreq">rsrp</p>
...    <p name="interPresAntP">false</p><p name="hysThreshold3InterFreq">0</p><p name="threshold3InterFreq">24</p>
...    <p name="threshold3aInterFreq">26</p><p name="useT312">false</p><p name="a3OffsetRsrpInterFreq">6</p><p name="a3OffsetRsrpInterFreqQci1">2</p>
...    <p name="a3ReportIntervalRsrpInterFreq">240ms</p><p name="a3TimeToTriggerRsrpInterFreq">320ms</p><p name="thresholdRsrpIFLBFilter">-98</p>
...    <p name="thresholdRsrqIFLBFilter">-120</p><p name="thresholdRsrpIFSBFilter">-100</p><p name="thresholdRsrqIFSBFilter">-100</p>
...    <p name="hysA3OffsetRsrpInterFreq">0</p><p name="threshold3InterFreqQci1">20</p><p name="threshold3aInterFreqQci1">30</p>
...    <p name="t312">1000ms</p></managedObject>
${LNHOIF_2}       <managedObject class="NOKLTE:LNHOIF" distName="MRBTS-2532/LNBTS-2532/LNCEL-2/LNHOIF-1" operation="create" version="${version}">
...    <p name="a5ReportIntervalInterFreq">480ms</p><p name="a5TimeToTriggerInterFreq">80ms</p><p name="eutraCarrierInfo">40042</p>
...    <p name="offsetFreqInter">0dB</p><p name="measurementBandwidth">mbw100</p><p name="measQuantInterFreq">rsrp</p>
...    <p name="interPresAntP">false</p><p name="hysThreshold3InterFreq">0</p><p name="threshold3InterFreq">24</p>
...    <p name="threshold3aInterFreq">26</p><p name="useT312">false</p><p name="a3OffsetRsrpInterFreq">6</p><p name="a3OffsetRsrpInterFreqQci1">2</p>
...    <p name="a3ReportIntervalRsrpInterFreq">240ms</p><p name="a3TimeToTriggerRsrpInterFreq">320ms</p><p name="thresholdRsrpIFLBFilter">-98</p>
...    <p name="thresholdRsrqIFLBFilter">-120</p><p name="thresholdRsrpIFSBFilter">-100</p><p name="thresholdRsrqIFSBFilter">-100</p>
...    <p name="hysA3OffsetRsrpInterFreq">0</p><p name="threshold3InterFreqQci1">20</p><p name="threshold3aInterFreqQci1">30</p>
...    <p name="t312">1000ms</p></managedObject>
${LNHOIF_3}       <managedObject class="NOKLTE:LNHOIF" distName="MRBTS-2532/LNBTS-2532/LNCEL-3/LNHOIF-1" operation="create" version="${version}">
...    <p name="a5ReportIntervalInterFreq">480ms</p><p name="a5TimeToTriggerInterFreq">80ms</p><p name="eutraCarrierInfo">40042</p>
...    <p name="offsetFreqInter">0dB</p><p name="measurementBandwidth">mbw100</p><p name="measQuantInterFreq">rsrp</p>
...    <p name="interPresAntP">false</p><p name="hysThreshold3InterFreq">0</p><p name="threshold3InterFreq">24</p>
...    <p name="threshold3aInterFreq">26</p><p name="useT312">false</p><p name="a3OffsetRsrpInterFreq">6</p><p name="a3OffsetRsrpInterFreqQci1">2</p>
...    <p name="a3ReportIntervalRsrpInterFreq">240ms</p><p name="a3TimeToTriggerRsrpInterFreq">320ms</p><p name="thresholdRsrpIFLBFilter">-98</p>
...    <p name="thresholdRsrqIFLBFilter">-120</p><p name="thresholdRsrpIFSBFilter">-100</p><p name="thresholdRsrqIFSBFilter">-100</p>
...    <p name="hysA3OffsetRsrpInterFreq">0</p><p name="threshold3InterFreqQci1">20</p><p name="threshold3aInterFreqQci1">30</p>
...    <p name="t312">1000ms</p></managedObject>
${LNADJ_1}        <managedObject class="NOKLTE:LNADJ" distName="MRBTS-2532/LNBTS-2532/LNADJ-1" operation="create" version="${version}">
...    <p name="cPlaneIpAddrCtrl">oamControlled</p><p name="rlfBasedRCRsupported">false</p><p name="adjEnbId">1</p>
...    <p name="cPlaneIpAddr">192.168.255.1</p><list name="plmnId"><item><p name="mcc">262</p><p name="mnc">3</p>
...    <p name="mncLength">2</p></item></list></managedObject>
${LNADJL_1}       <managedObject class="NOKLTE:LNADJL" distName="MRBTS-2532/LNBTS-2532/LNADJ-1/LNADJL-1" operation="create" version="${version}">
...    <p name="fDlEarfcn">40042</p><p name="ecgiLcrId">1</p><p name="phyCellId">50</p><p name="tac">666</p><list name="bcPlmnIdList"><item>
...    <p name="mcc">262</p><p name="mnc">3</p><p name="mncLength">2</p></item></list></managedObject>
${fastLoadBalanceConfig}    <list name="fastLoadBalanceConfig"><item><p name="fastLoadBalanceMcsThresh">0</p><p name="prbUsageRatioGapThresh">30</p>
...    <p name="prbUsageRatioHighThresh">80</p></item></list>
${csiRsConfigInfo}    <list name="csiRsConfigInfo"><item><p name="numOfCsiRsAntennaPorts">8</p><p name="csiRsPwrOffset">0</p>
...    <p name="csiRsResourceConf">rsc0</p><p name="csiRsSubfrConf">14</p></item></list>
${dlSectorBFWeightCusProf}    <list name="dlSectorBFWeightCusProf"><item><p name="antennaElementSpacing">1</p>
...    <p name="dlSectorBFWeightProfName">customized profile 1</p><p name="modulusOfWeighforAntGrp0">100</p>
...    <p name="modulusOfWeighforAntGrp1">100</p><p name="modulusOfWeighforAntGrp2">100</p><p name="modulusOfWeighforAntGrp3">100</p>
...    <p name="phaseOfWeighforAntGrp0">0</p><p name="phaseOfWeighforAntGrp1">180</p><p name="phaseOfWeighforAntGrp2">180</p>
...    <p name="phaseOfWeighforAntGrp3">180</p></item></list>
${beamforming}    <item><p name="beamformingType">beamforming</p><p name="srsBandwidth">3hbw</p><p name="srsUePeriodicity">5ms</p></item>
${APUCCH_TDD_1}    <managedObject class="NOKLTE:APUCCH_TDD" distName="MRBTS-2532/LNBTS-2532/LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0" operation="create" 
...    version="${version}"><p name="actLbPucchReg">true</p><p name="aPucchAddAUeRrHo">30</p><p name="aPucchAddAUeTcHo">45</p>
...    <p name="aPucchMinNumRrc">10</p><p name="aPucchMinNumRrcNoDrb">5</p><p name="aPucchSrPeriodUpperLimit">40</p>
...    <p name="pucchF3Support2CC">false</p><p name="selectPrachRegion">None</p><p name="aPucchMinNumEmergencySessions">10</p></managedObject>
${APUCCH_TDD_2}    <managedObject class="NOKLTE:APUCCH_TDD" distName="MRBTS-2532/LNBTS-2532/LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0" operation="create" 
...    version="${version}"><p name="actLbPucchReg">true</p><p name="aPucchAddAUeRrHo">30</p><p name="aPucchAddAUeTcHo">45</p>
...    <p name="aPucchMinNumRrc">10</p><p name="aPucchMinNumRrcNoDrb">5</p><p name="aPucchSrPeriodUpperLimit">40</p>
...    <p name="pucchF3Support2CC">false</p><p name="selectPrachRegion">None</p><p name="aPucchMinNumEmergencySessions">10</p></managedObject>
${APUCCH_TDD_3}    <managedObject class="NOKLTE:APUCCH_TDD" distName="MRBTS-2532/LNBTS-2532/LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0" operation="create" 
...    version="${version}"><p name="actLbPucchReg">true</p><p name="aPucchAddAUeRrHo">30</p><p name="aPucchAddAUeTcHo">45</p>
...    <p name="aPucchMinNumRrc">10</p><p name="aPucchMinNumRrcNoDrb">5</p><p name="aPucchSrPeriodUpperLimit">40</p>
...    <p name="pucchF3Support2CC">false</p><p name="selectPrachRegion">None</p><p name="aPucchMinNumEmergencySessions">10</p></managedObject>
${OTDOA_profile_list}     <list name="otdoaProfileList"><item><p name="otdoaPhaseErrorThreshold">1500</p>
...    <p name="otdoaSyncSourceType">GNSS</p></item></list>
${BBPOOLALLOC_1}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-2532/LNBTS-2532/LNCEL-1/BBPOOLALLOC-0" operation="create" 
...    version="${version}"><p name="bbPoolAllocMode">automatic</p></managedObject>
${BBPOOLALLOC_2}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-2532/LNBTS-2532/LNCEL-2/BBPOOLALLOC-0" operation="create" 
...    version="${version}"><p name="bbPoolAllocMode">automatic</p></managedObject>
${BBPOOLALLOC_3}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-2532/LNBTS-2532/LNCEL-3/BBPOOLALLOC-0" operation="create" 
...    version="${version}"><p name="bbPoolAllocMode">automatic</p></managedObject>
${BBPOOLALLOC_1_1}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-2532/LNBTS-2532/LNCEL-1/BBPOOLALLOC-0" operation="create" 
...    version="${version}"><p name="bbPoolAllocMode">manual</p><p name="bbPoolTargetId">1</p></managedObject>
${BBPOOLALLOC_2_1}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-2532/LNBTS-2532/LNCEL-2/BBPOOLALLOC-0" operation="create" 
...    version="${version}"><p name="bbPoolAllocMode">manual</p><p name="bbPoolTargetId">1</p></managedObject>
${BBPOOLALLOC_3_1}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-2532/LNBTS-2532/LNCEL-3/BBPOOLALLOC-0" operation="create" 
...    version="${version}"><p name="bbPoolAllocMode">manual</p><p name="bbPoolTargetId">2</p></managedObject>
${BBPOOLALLOC_1_bbPoolLogicalGroupId}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-2532/LNBTS-2532/LNCEL-1/BBPOOLALLOC-0" 
...    operation="create" version="${version}"><p name="bbPoolAllocMode">automatic</p><p name="bbPoolLogicalGroupId">1</p></managedObject>
${BBPOOLALLOC_2_bbPoolLogicalGroupId}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-2532/LNBTS-2532/LNCEL-2/BBPOOLALLOC-0" 
...    operation="create" version="${version}"><p name="bbPoolAllocMode">automatic</p><p name="bbPoolLogicalGroupId">1</p></managedObject>
${BBPOOLALLOC_3_bbPoolLogicalGroupId}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-2532/LNBTS-2532/LNCEL-3/BBPOOLALLOC-0" 
...    operation="create" version="${version}"><p name="bbPoolAllocMode">automatic</p><p name="bbPoolLogicalGroupId">1</p></managedObject>
${bbCardUsage}    <managedObject class="com.nokia.srbts.eqm:BBMOD" distName="MRBTS-2532/EQM-1/APEQM-1/CABINET-1/BBMOD-1" operation="create" 
...    version="${version}"><p name="bbCardUsage">2</p><p name="useFullCapacity">true</p></managedObject>
${CRGPR}          <managedObject class="NOKLTE:CRGPR" distName="MRBTS-2532/LNBTS-2532/CRGPR-0" operation="create" version="TL18SP_1803_04_1803_01">
...    <p name="crgSkipThreshold">0</p><p name="defaultPlmnGroupId">0</p><list name="plmnGroupList"><item><p name="mcc">262</p><p name="mnc">3</p>
...    <p name="mncLength">2</p><p name="plmnGroupId">0</p></item><item><p name="mcc">262</p><p name="mnc">4</p><p name="mncLength">2</p>
...    <p name="plmnGroupId">1</p></item></list><list name="plmnGroupShareList"><item><p name="plmnGroupId">0</p>
...    <p name="plmnGroupShare">70</p></item><item><p name="plmnGroupId">1</p><p name="plmnGroupShare">30</p></item></list></managedObject>
${furtherPlmnIdL}    <list name="furtherPlmnIdL"><item><p name="autoRemovalAllowed">false</p><p name="cellReserve">Not Reserved</p>
...    <p name="mcc">262</p><p name="mnc">3</p><p name="mncLength">2</p><p name="upperLayerIndR15">false</p><p name="defDcnGroupId"/>
...    <p name="acbFurtherPlmnProfileId"/></item><item><p name="autoRemovalAllowed">false</p><p name="cellReserve">Not Reserved</p>
...    <p name="mcc">262</p><p name="mnc">4</p><p name="mncLength">2</p><p name="upperLayerIndR15">false</p><p name="defDcnGroupId"/>
...    <p name="acbFurtherPlmnProfileId"/></item></list>
${ulMuMimoMCSOffset}      <list name="ulMuMimoMCSOffset"><p>-1</p><p>-1</p><p>-1</p><p>-1</p><p>-1</p><p>-1</p><p>-1</p><p>-1</p></list>
${ulMuMimoParaSet}        <list name="ulMuMimoParaSet"><item><p name="ulMuBfIcMethodH">30dB IC</p><p name="ulMuBfIcMethodV">30dB IC</p>
...    <p name="ulMuMimoOrthThreshold">4</p><p name="ulMuMimoSinrThreshold">5</p><p name="ulMuMimoPRBDiffThreshold">3</p></item></list>
${sectorBfWeightChgPrfTraffic}       <list name="sectorBfWeightChgPrfTraffic"><item><p name="dlPrbUsageThr">75</p>
...    <p name="dlUserTputDcrRateThr">20</p><p name="dlUserTputThr">1000</p><p name="numRrcConnUeIncRateThr">20</p><p name="startMonitorHour">14</p>
...    <p name="dlCellTputIncRateThr">20</p><p name="offsetThreshold1">10</p><p name="offsetThreshold2">10</p></item></list>
${sectorBfWeightChgProf}      <list name="sectorBfWeightChgProf"><item><p name="deltaElecDownTiltHighLoad">2</p>
...    <p name="deltaElecDownTiltLowLoad">0</p><p name="startSwitchHourHighLoad">20</p><p name="startSwitchHourLowLoad">2</p>
...    <p name="startSwitchMinuteHighLoad">0</p><p name="startSwitchMinuteLowLoad">0</p></item></list>
${dlQoeEnhanceParSet}     <list name="dlQoeEnhanceParSet"><item><p name="dlAggrTtiThd">3</p><p name="dlAvgNumUeWin">500</p>
...    <p name="dlLowLoadNumUeThd">10</p><p name="dlMaxDelayTtiSmallPkt">50</p><p name="dlMinUePerTti">5</p><p name="dlPasBurstNumMargin">2</p>
...    <p name="dlPasFactorPeakBurstNum">0</p><p name="dlPasMaxDelayTimer">300</p><p name="dlQoeCellTputBalance">0</p><p name="dlTtiNumPtp">100</p>
...    <p name="dlUePerTtiCoefficient">30</p><p name="dlWorkLoadFactor">1</p></item></list>
${pdcchMultiplexParaSet}    <list name="pdcchMultiplexParaSet"><item><p name="multiplexPriorToPdcchRes">true</p><p name="pdcchBfCqiThd">30</p>
...    <p name="pdcchBfGainThd">33</p></item></list>
#${pdcchBeamWeightProfName}    <list name="pdcchMultiplexParaSet"><item><p name="pdcchBeamWeightProfName">25dB IC</p>
${PMQAP}     <managedObject class="NOKLTE:PMQAP" distName="MRBTS-1/LNBTS-1/PMRNL-1/PMQAP-1" version="xL19B_1907_003" operation="create">
...    <p name="cfgPRI">20</p><p name="cfgQCIRange">7</p></managedObject>
${bbPoolAllocPrioList}    <list name="bbPoolAllocPrioList"><item><p name="allocCriterion">Logical group</p>
...    <p name="allocPriority">9</p></item><item><p name="allocCriterion">Frequency</p><p name="allocPriority">8</p></item></list>
${vlanId}     <managedObject class="com.nokia.srbts.tnl:VLANIF" distName="MRBTS-2532/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1" 
...    version="${version}" operation="create"><p name="vlanId">20</p></managedObject>


*** Keywords ***      Action            Action               Action        Action
Add evtt extend parameter
    [Arguments]         ${SCFC}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}     xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1        xpath=.//p[@name="enbName"]
    @{lcelllist}=       Get Elements         ${xml}     xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR               ${lcell}             IN         @{lcelllist}
                       Add Element          ${lcell}                     ${qci1eVTTConfig}           index=-0
    END
    Save xml            source=${xml}        path=${SCFC}

Modify SCFC into 2cc CA
    [Arguments]         ${SCFC}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}                   xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1    xpath=.//p[@name="enbName"]
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1"]    remove_tail=yes
    remove channel and igore error for cell       ${xml}               3
    remove_element      ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-3/LNCEL_TDD-0"]    remove_tail=yes
    remove_element      ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-3"]                remove_tail=yes
    remove_element      ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-3/SIB-0"]          remove_tail=yes
    remove_element      ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-3/IFGPR-0"]        remove_tail=yes
    remove_element      ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-3/IFGDPR-0"]       remove_tail=yes
    remove_element      ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-3/DRX-0"]          remove_tail=yes
    remove_element      ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-3/SDRX-0"]         remove_tail=yes
    remove_element      ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0"]
    ${lnbts}=           Get Element          ${xml}             xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${lnbts}      text=true          xpath=.//p[@name="actDLCAggr"]
    ${cmData}=          Get Element          ${xml}             xpath=.//cmData[1]
    Set element text    source=${lnbts}      text=2_carrierOperation              xpath=.//p[@name="actMultipleCarrier"]
    add_element         ${lnbts}             <p name="caSchedFairFact">10</p>     index=15
    add_element         ${cmData}            ${CADPR}           index=15
    #add_element         ${cmData}            ${CAGENB}          index=16
    @{lcelllist}=       Get Elements         ${xml}             xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR               ${lcell}             IN                 @{lcelllist}
                       Set element text     source=${lcell}    text=0     xpath=.//p[@name="addGbrTrafficRrHo"]
                       Set element text     source=${lcell}    text=0     xpath=.//p[@name="addGbrTrafficTcHo"]
                       Set element text     source=${lcell}    text=370                     xpath=.//p[@name="pMax"]
                       add_element          ${lcell}           <p name="caPoolId">1</p>     index=1
    END
    @{lcelltddlist}=    Get Elements         ${xml}             xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR               ${lcelltdd}          IN                 @{lcelltddlist}
                       Set element text     source=${lcelltdd}                   text=0          xpath=.//p[@name="addNumDrbRadioReasHo"]
                       Set element text     source=${lcelltdd}                   text=0          xpath=.//p[@name="addNumDrbTimeCriticalHo"]
                       Set element text     source=${lcelltdd}                   text=0          xpath=.//p[@name="addNumQci1DrbRadioReasHo"]
                       Set element text     source=${lcelltdd}                   text=0          xpath=.//p[@name="addNumQci1DrbTimeCriticalHo"]
                       Set element text     source=${lcelltdd}                   text=40         xpath=.//p[@name="maxNumActDrb"]
                       Set element text     source=${lcelltdd}                   text=20         xpath=.//p[@name="maxNumCaConfUe"]
                       Set element text     source=${lcelltdd}                   text=10         xpath=.//p[@name="maxNumCaConfUe3c"]
                       Set element text     source=${lcelltdd}                   text=10         xpath=.//p[@name="maxNumCaConfUeDc"]
                       Set element text     source=${lcelltdd}                   text=10         xpath=.//p[@name="maxNumQci1Drb"]
           Set element text    source=${lcelltdd}              text=20         xpath=.//p[@name="maxNumActUE"]
    END
    @{lcelltddmpucchlist}=    Get Elements        ${xml}        xpath=.//managedObject[@class="NOKLTE:MPUCCH_TDD"]
    FOR          ${lcelltddmpucch}         IN                 @{lcelltddmpucchlist}
                  Set element text    source=${lcelltddmpucch}    
                  Set element text    source=${lcelltddmpucch}             text=0                xpath=.//p[@name="addEmergencySessions"]
                  Set element text    source=${lcelltddmpucch}             text=0                xpath=.//p[@name="addAUeRrHo"]
                  Set element text    source=${lcelltddmpucch}             text=0                xpath=.//p[@name="addAUeTcHo"]
                  Set element text    source=${lcelltddmpucch}             text=20               xpath=.//p[@name="maxNumRrc"]
                  Set element text    source=${lcelltddmpucch}             text=20               xpath=.//p[@name="maxNumRrcEmergency"]
                  Set element text    source=${lcelltddmpucch}             text=1                xpath=.//p[@name="nPucchF3Prbs"]
                  Set element text    source=${lcelltddmpucch}             text=72                xpath=.//p[@name="n1PucchAn"]
    END
    @{lcell-1}=    Get Elements        ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-1"]
    add_element    ${cmData}           ${CAREL_1_2}                index=17
    @{lcell-2}=    Get Elements        ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-2"]
    add_element    ${cmData}           ${CAREL_2_1}                index=19
    Save xml       source=${xml}       path=${SCFC}                

Add SPS extend parameter
    [Arguments]         ${SCFC}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1                   xpath=.//p[@name="enbName"]
    @{lcelllist}=       Get Elements         ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR               ${lcell}             IN        @{lcelllist}
                       Add Element          ${lcell}                    ${SPSConfig}                  index=-0
    END
    Save xml            source=${xml}        path=${SCFC}

Remove cell from SCFC
    [Arguments]         ${SCFC}              @{cell_id}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}                    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1     xpath=.//p[@name="enbName"]
    Set element text    source=${xml}        text=false    xpath=.//p[@name="actMultipleCarrier"]
    @{cell_id}=         Split String         @{cell_id}    ,
    FOR               ${i}                 IN            @{cell_id}
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1"]
    ...    remove_tail=yes
        remove channel and igore error for cell    ${xml}    ${i}
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/LNCEL_TDD-0"]     remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}"]             remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/SIB-0"]       remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/IFGPR-0"]     remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/IFGDPR-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/DRX-0"]       remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/SDRX-0"]      remove_tail=yes
        run_keyword_and_ignore_error    remove_element    ${xml}
    ...    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/BBPOOLALLOC-0"]      remove_tail=yes
        run_keyword_and_ignore_error    remove_element    ${xml}
    ...    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/LNCEL_TDD-0/APUCCH_TDD-0"]      remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/LNCEL_TDD-0/MPUCCH_TDD-0"]    remove_tail=yes
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/SIB-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/IFGPR-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/IFGDPR-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/DRX-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${i}/SDRX-0"]
    END
    Save xml      source=${xml}     path=${SCFC}

Modify SCFC into 3cc CA
    [Arguments]         ${SCFC}
    ${xml}=             Parse XML           source=${SCFC}
    ${btsname}=         Get Element         ${xml}                        xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}   text=eNB1                     xpath=.//p[@name="enbName"]
    ${lnbts}=           Get Element         ${xml}                        xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    ${cmData}=          Get Element         ${xml}                        xpath=.//cmData[1]
    Set element text    source=${lnbts}     text=true                     xpath=.//p[@name="actDLCAggr"]
    add_element         ${lnbts}            <p name="caSchedFairFact">10</p>                index=15
    add_element         ${lnbts}            <p name="actFlexCaMgmt">false</p>               index=-0
    add_element         ${cmData}           ${CADPR}                      index=16
    add_element         ${cmData}           ${CAGENB}                     index=17
    @{lcelllist}=       Get Elements        ${xml}                        xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR               ${lcell}            IN          @{lcelllist}
                       Set element text    source=${lcell}       text=0                    xpath=.//p[@name="addGbrTrafficRrHo"]
                       Set element text    source=${lcell}       text=0                    xpath=.//p[@name="addGbrTrafficTcHo"]
                       Set element text    source=${lcell}       text=2                    xpath=.//p[@name="maxNumScells"]
                       add_element         ${lcell}              <p name="caPoolId">0</p>               index=1
                       add_element         ${lcell}              <p name="ulCaMinPcellSinr">0</p>       index=-0
                       add_element         ${lcell}              <p name="ulCaMinPcellSinrQci1">0</p>                     index=-0
                       add_element         ${lcell}              <p name="dlCaMinPcellCqi">0</p>        index=-0
                       add_element         ${lcell}              <p name="dlCaMinPcellCqiQci1">0</p>    index=-0
                       add_element         ${lcell}              <p name="scellFastSchedulingSelect">fast</p>             index=-0
                       add_element         ${lcell}              <p name="actFlowCtrlEnh">false</p>     index=-0
                       add_element         ${lcell}              <p name="actScellConfigForHiDemand">true</p>             index=-0
                       add_element         ${lcell}              <p name="dlScellConfigLevel">20</p>    index=-0
                       add_element         ${lcell}              <p name="actCaArchEnhImp">on_peak_data_rate_basic</p>    index=-0
                       add_element         ${lcell}              <p name="eTputFilterConfig">51</p>     index=-0
                       add_element         ${lcell}              <p name="eTputInitMcs">20</p>          index=-0
    END
    @{lcelltddlist}=    Get Elements        ${xml}                xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR               ${lcelltdd}         IN                    @{lcelltddlist}
                       Set element text    source=${lcelltdd}    text=0              xpath=.//p[@name="addNumDrbRadioReasHo"]
                       Set element text    source=${lcelltdd}    text=0              xpath=.//p[@name="addNumDrbTimeCriticalHo"]
                       Set element text    source=${lcelltdd}    text=0              xpath=.//p[@name="addNumQci1DrbRadioReasHo"]
                       Set element text    source=${lcelltdd}    text=0              xpath=.//p[@name="addNumQci1DrbTimeCriticalHo"]
                       Set element text    source=${lcelltdd}    text=300            xpath=.//p[@name="maxNumActDrb"]
                       Set element text    source=${lcelltdd}    text=100            xpath=.//p[@name="maxNumCaConfUe"]
                       Set element text    source=${lcelltdd}    text=50             xpath=.//p[@name="maxNumCaConfUe3c"]
                       Set element text    source=${lcelltdd}    text=100            xpath=.//p[@name="maxNumCaConfUeDc"]
                       Set element text    source=${lcelltdd}    text=40             xpath=.//p[@name="maxNumQci1Drb"]
           Set element text    source=${lcelltdd}                  text=300           xpath=.//p[@name="maxNumActUE"]
   END
    @{lcelltddmpucchlist}=    Get Elements        ${xml}            xpath=.//managedObject[@class="NOKLTE:MPUCCH_TDD"]
    FOR                     ${lcelltddmpucch}         IN          @{lcelltddmpucchlist}
           Set element text    source=${lcelltddmpucch}            text=0             xpath=.//p[@name="addEmergencySessions"]
           Set element text    source=${lcelltddmpucch}            text=0             xpath=.//p[@name="addAUeRrHo"]
           Set element text    source=${lcelltddmpucch}            text=0             xpath=.//p[@name="addAUeTcHo"]
           Set element text    source=${lcelltddmpucch}            text=300           xpath=.//p[@name="maxNumRrc"]
           Set element text    source=${lcelltddmpucch}            text=345           xpath=.//p[@name="maxNumRrcEmergency"]
           Set element text    source=${lcelltddmpucch}            text=1             xpath=.//p[@name="nPucchF3Prbs"]
           Set element text    source=${lcelltddmpucch}            text=108           xpath=.//p[@name="n1PucchAn"]
    END
    add_element               ${cmData}           ${CAREL_1_2}      index=18
    add_element               ${cmData}           ${CAREL_1_3}      index=19
    add_element               ${cmData}           ${CAREL_2_1}      index=21
    add_element               ${cmData}           ${CAREL_2_3}      index=22
    add_element               ${cmData}           ${CAREL_3_1}      index=24
    add_element               ${cmData}           ${CAREL_3_2}      index=25
    Save xml                  source=${xml}       path=${SCFC}

Add parameter in all cell level
    [Arguments]         ${SCFC}              ${parameter}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1               xpath=.//p[@name="enbName"]
    @{lcelllist}=       Get Elements         ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR               ${lcell}             IN                      @{lcelllist}
                       add_element          ${lcell}                ${parameter}       index=-0
    END
    Save xml            source=${xml}        path=${SCFC}

Add parameter in all lncel_tdd level
    [Arguments]         ${SCFC}              ${parameter}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1               xpath=.//p[@name="enbName"]
    @{lcelllist}=       Get Elements         ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR               ${lcell}             IN                      @{lcelllist}
                       add_element          ${lcell}                ${parameter}           index=-0
    END
    Save xml            source=${xml}        path=${SCFC}

Add parameter in bts level
    [Arguments]         ${SCFC}              ${parameter}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1               xpath=.//p[@name="enbName"]
    ${lnbts}=           Get Element          ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    add_element         ${lnbts}             ${parameter}            index=-0
    Save xml            source=${xml}        path=${SCFC}

Add Restricted_PRB_assignment_in_uplink_configuration extend parameter
    [Arguments]         ${SCFC}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1               xpath=.//p[@name="enbName"]
    @{lcelllist}=       Get Elements         ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR               ${lcell}             IN                      @{lcelllist}
                       Add Element          ${lcell}                ${redBwRbUlConfig}                   index=-0
    END
    Save xml            source=${xml}        path=${SCFC}

Add C_plan overload extend parameter
    [Arguments]         ${SCFC}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1               xpath=.//p[@name="enbName"]
    ${lnbts}=           Get Element          ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    add_element         ${lnbts}             ${C_plan_overload}      index=-0
    Save xml            source=${xml}        path=${SCFC}

Add U_plan overload extend parameter
    [Arguments]         ${SCFC}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1               xpath=.//p[@name="enbName"]
    ${lnbts}=           Get Element          ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    add_element         ${lnbts}             ${U_plan_overload}      index=-0
    Save xml            source=${xml}        path=${SCFC}

Modify SCFC into 3cc CA only dl
    Modify SCFC into 3cc CA

Modify SCFC into 2cc CA only dl
    Modify SCFC into 2cc CA

replace btsname on scfc
    [Arguments]         ${SCFC}
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}                  xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1               xpath=.//p[@name="enbName"]

modify'${num2}'pipe number
    ${target_scfc}       Set Variable              ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}=              Parse XML                 source=${target_scfc}
    set_test_variable    ${xml}
    @{lceltddllist}=     Get Elements      ${xml}                    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR                ${lcelltdd}       IN                        @{lceltddllist}
                        remove_element    source=${lcelltdd}        xpath=.//p[@name="dlSectorBeamformingMode"]
    END
    ${lcelnum}=          Get Element Count                ${xml}     xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR                ${i}           IN RANGE    1       ${lcelnum}+1
                        run keyword if    ${num2}!=6     delete RX to'${num2}'pipe for cell'${i}'transverse distribution
                        run keyword if    ${num2}!=6     delete TX to'${num2}'pipe for cell'${i}'transverse distribution
                        run keyword if    ${num2}==6     delete RX to 6 pipe for cell'${i}'longitudinal distribution
                        run keyword if    ${num2}==6     delete TX to 6 pipe for cell'${i}'longitudinal distribution
    END
    Save xml             source=${xml}           path=${target_scfc}

delete RX to'${num2}'pipe for cell'${i}'transverse distribution
    FOR                ${k}              IN RANGE       8        ${num2}       -1
        remove_element    ${xml}
    ...    xpath=.//managedObject[@distName="MRBTS-2532/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1/CHANNEL-${k}"]    remove_tail=yes
    END

delete TX to'${num2}'pipe for cell'${i}'transverse distribution
    FOR     ${j}      IN RANGE       16        ${num2}+8       -1
        remove_element    ${xml}
    ...    xpath=.//managedObject[@distName="MRBTS-2532/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1/CHANNEL-${j}"]    remove_tail=yes
    END

delete RX to 6 pipe for cell'${i}'longitudinal distribution    
    ${a}=            evaluate     ${i}*2-1
    ${b}=            evaluate     ${i}*2
    FOR                ${j}               IN      1     2     3     4    5    6    7    8
             run keyword if               ${j}==${a}         Continue For Loop
             run keyword if               ${j}==${b}         Continue For Loop
             remove_element               ${xml}
    ...    xpath=.//managedObject[@distName="MRBTS-2532/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1/CHANNEL-${j}"]    remove_tail=yes
    END

delete TX to 6 pipe for cell'${i}'longitudinal distribution
    ${a}=            evaluate     ${i}*2+7
    ${b}=            evaluate     ${i}*2+8
    FOR                ${k}               IN      9     10     11     12    13    14    15    16
             run keyword if               ${k}==${a}         Continue For Loop
             run keyword if               ${k}==${b}         Continue For Loop
             remove_element               ${xml}
    ...    xpath=.//managedObject[@distName="MRBTS-2532/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1/CHANNEL-${k}"]     remove_tail=yes
    END
    Set element text    source=${xml}    text=false    xpath=.//p[@name="actMultipleCarrier"]

remove channel and igore error for cell
    [Arguments]                 ${xml}            ${i}
    FOR                       ${j}      IN RANGE    1    129
             run_keyword_and_ignore_error      remove_element               ${xml}
    ...    xpath=.//managedObject[@distName="MRBTS-2532/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1/CHANNEL-${j}"]     remove_tail=yes
    END

select scfc configure'${num1}'RRU and'${num2}'pipe
    run keyword if    ${num1}==1           copy file     ${source_scfc_1}         ${SAVE LOG DIRECTORY}
    run keyword if    ${num1}==3           copy file     ${source_scfc_2}         ${SAVE LOG DIRECTORY}
    run keyword if    ${num1}==3           check_scfc_and_adaption_enb_positionInSubrack            ${SAVE LOG DIRECTORY}/SCFC_1.xml
    run keyword if    ${num2}<8            modify'${num2}'pipe number
    run keyword if    ${num2}==4           modify TM type to closedmino

modify TM type to closedmino
    ${target_scfc}      Set Variable        ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}=             Parse XML           source=${target_scfc}
    @{lceltddllist}=    Get Elements        ${xml}                xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR               ${lcelltdd}         IN                    @{lceltddllist}
                       Set element text    source=${lcelltdd}    text=Closed Loop MIMO (4x2)    xpath=.//p[@name="dlMimoMode"]
                       Set element text    source=${lcelltdd}    text=true    xpath=.//p[@name="actFastMimoSwitch"]
                       Add Element         ${lcelltdd}           <p name="activatedMimoTM">TM4</p>
    END
    Save xml            source=${xml}       path=${target_scfc}  

Add interference aware UL-PC configuration extend parameter
    [Arguments]     ${SCFC}
    ${xml}          Parse XML        source=${SCFC}
    @{lcelllist}    Get Elements     ${xml}     xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR           ${lcell}         IN         @{lcelllist}
                   Add Element      ${lcell}                     ${interferenceAwareListUL_PC}      index=-0
    END
    Save xml        source=${xml}    path=${SCFC}

Add lnrel extend parameter on cell'${id}' ,and set parameter ecgiLcrId:'${parameter1}'ecgiAdjEnbId:'${parameter2}'
    ${SCFC}             set_variable       ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}              Parse XML          source=${SCFC}
    ${a}                set_variable_if    ${id}==1    1          ${id}==2    2        ${id}==3    3
    ${cmData}           Get Element        ${xml}                 xpath=.//cmData[1]
    Add Element         ${cmData}          ${LNREL_${id}}         index=-0
    ${lcelllist}        Get Element        ${xml}                 xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${a}/LNREL-1"]
    Set Element Text    ${lcelllist}       ${parameter1}          xpath=.//p[@name="ecgiLcrId"]
    Set Element Text    ${lcelllist}       ${parameter2}          xpath=.//p[@name="ecgiAdjEnbId"]
    Save xml            source=${xml}      path=${SCFC}

Add lnhoif extend parameter on cell'${id}' ,and set parameter eutraCarrierInfo:'${parameter3}'
    ${SCFC}             set_variable       ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}              Parse XML          source=${SCFC}
    ${a}                set_variable_if    ${id}==1    1          ${id}==2    2        ${id}==3    3
    ${cmData}           Get Element        ${xml}                 xpath=.//cmData[1]
    Add Element         ${cmData}          ${LNHOIF_${id}}        index=-0
    ${lcelllist}        Get Element        ${xml}                 xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${a}/LNHOIF-1"]
    Set Element Text    ${lcelllist}       ${parameter3}          xpath=.//p[@name="eutraCarrierInfo"]
    Save xml            source=${xml}      path=${SCFC}

Add lnadj extend parameter ,and set adj parameter adjEnbId:'${parameter4}'cPlaneIpAddr:'${parameter5}'
    ${SCFC}             set_variable     ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}              Parse XML        source=${SCFC}
    ${cmData}           Get Element      ${xml}                   xpath=.//cmData[1]
    Add Element         ${cmData}        ${LNADJ_1}               index=-0
    ${lnadj}            Get Element      ${xml}                   xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNADJ-1"]
    Set Element Text    ${lnadj}         ${parameter4}            xpath=.//p[@name="adjEnbId"]
    Set Element Text    ${lnadj}         ${parameter5}            xpath=.//p[@name="cPlaneIpAddr"]
    Save xml            source=${xml}    path=${SCFC}

Add lnadjl extend parameter ,and set adj parameter fDlEarfcn:'${parameter6}'ecgiLcrId:'${parameter7}'phyCellId:'${parameter8}'tac:'${parameter9}'
    ${SCFC}             set_variable     ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}              Parse XML        source=${SCFC}
    ${cmData}           Get Element      ${xml}                   xpath=.//cmData[1]
    Add Element         ${cmData}        ${LNADJL_1}              index=-0
    ${lnadjl}           Get Element      ${xml}                   xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNADJ-1/LNADJL-1"]
    Set Element Text    ${lnadjl}        ${parameter6}            xpath=.//p[@name="fDlEarfcn"]
    Set Element Text    ${lnadjl}        ${parameter7}            xpath=.//p[@name="ecgiLcrId"]
    Set Element Text    ${lnadjl}        ${parameter8}            xpath=.//p[@name="phyCellId"]
    Set Element Text    ${lnadjl}        ${parameter9}            xpath=.//p[@name="tac"]
    Save xml            source=${xml}    path=${SCFC}

Add fastLoadBalanceConfig extend parameter
    [Arguments]    ${SCFC}
    ${xml}         Parse XML        source=${SCFC}
    ${cagenb}=     Get Element      ${xml}      xpath=.//managedObject[@class="NOKLTE:CAGENB"]
    add_element    ${cagenb}        ${fastLoadBalanceConfig}      index=-0
    Save xml       source=${xml}    path=${SCFC}

Add UL_CA_with_smartSched extend parameter
    [Arguments]                 ${SCFC}
    Add parameter in bts level                    ${SCFC}         <p name="ulCaPathlossThr">100</p>
    Add parameter in bts level                    ${SCFC}         <p name="caUlIntraBandAmpr">enabled</p>
    Add parameter in bts level                    ${SCFC}         <p name="dlCaPreferred">DLandUL</p>
    Add fastLoadBalanceConfig extend parameter    ${SCFC}

Add csiRsConfigInfo extend parameter
    [Arguments]          ${SCFC}
    ${xml}=              Parse XML            source=${SCFC}
    ${btsname}=          Get Element          ${xml}              xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text     source=${btsname}    text=eNB1           xpath=.//p[@name="enbName"]
    @{lcell_tddlist}=    Get Elements         ${xml}              xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR                ${lcell_tdd}         IN                  @{lcell_tddlist}
                        Add Element          ${lcell_tdd}        ${csiRsConfigInfo}     index=-0
    END
    Save xml             source=${xml}        path=${SCFC}

Add PMQAP index'${id}' extend parameter and defualt cfgQCI'${QCI}'
    [Documentation]    default pmqap index is 1 ，so add pmqap index from 2...20
    ${SCFC}            set_variable     ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}             Parse XML        source=${SCFC}
    ${cmData}          Get Element      ${xml}                         xpath=.//cmData[1]
    Add Element        ${cmData}        <managedObject class="PMQAP" distName="MRBTS-2532/LNBTS-2532/PMRNL-1/PMQAP-${id}" 
    ...    operation="create" version="${version}"><p name="cfgQCIRange">${QCI}</p></managedObject>    index=-0
    Save xml           source=${xml}    path=${SCFC}

Add PMQAP index'${id}' extend parameter cfgARP'${arp}'
    ${SCFC}        set_variable     ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}         Parse XML        source=${SCFC}
    ${PMQAP}=      Get Element      ${xml}    xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/PMRNL-1/PMQAP-${id}"]
    add_element    ${PMQAP}         <p name="cfgARPRange">${arp}</p>            index=-0
    Save xml       source=${xml}    path=${SCFC}

Add PMQAP index'${id}' extend parameter cfgPRI'${pri}'
    ${SCFC}        set_variable     ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}         Parse XML        source=${SCFC}
    ${PMQAP}=      Get Element      ${xml}         xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/PMRNL-1/PMQAP-${id}"]
    add_element    ${PMQAP}         <p name="cfgPRI">${pri}</p>     index=-0
    Save xml       source=${xml}    path=${SCFC}

remove mo'${name}' in cell'${id}'
    ${SCFC}                     set_variable       ${TEST_LOG_DIR}/SCFC_1.xml
    ${xml}    Parse XML          source=${SCFC}
    ${a}      set_variable_if    ${id}==1    1    ${id}==2    2    ${id}==3    3
    remove_element              ${xml}             xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${a}/${name}"]    remove_tail=yes
    Element Should Not Exist    ${xml}             xpath=.//managedObject[@distName="MRBTS-2532/LNBTS-2532/LNCEL-${a}/${name}"]
    Save xml                    source=${xml}      path=${SCFC}

remove parameter'${parameter}' in all cell level
    ${SCFC}             set_variable         ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}=             Parse XML            source=${SCFC}
    ${btsname}=         Get Element          ${xml}        xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1     xpath=.//p[@name="enbName"]
    @{lcelllist}=       Get Elements         ${xml}        xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR               ${lcell}             IN            @{lcelllist}
                       remove_element       source=${lcell}                 xpath=.//p[@name="${parameter}"]
    END
    Save xml            source=${xml}        path=${SCFC}

remove parameter'${parameter}' in bts level
    ${SCFC}                     set_variable            ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                                       xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                                    xpath=.//p[@name="enbName"]
    ${lnbts}=                   Get Element             ${xml}                                       xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    remove_element              source=${lnbts}         xpath=.//p[@name="${parameter}"]
    Save xml                    source=${xml}           path=${SCFC}

Add dlSectorBFWeightCusProf extend parameter
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                                       xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                                    xpath=.//p[@name="enbName"]
    ${lnbts_tdd}=               Get Element             ${xml}                                       xpath=.//managedObject[@class="NOKLTE:LNBTS_TDD"]
    add_element                 ${lnbts_tdd}            ${dlSectorBFWeightCusProf}                   index=-0
    Save xml                    source=${xml}           path=${SCFC}

Add beamforming parameter in cell
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}         xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1      xpath=.//p[@name="enbName"]
    @{lcelltddlist}=            Get Elements            ${xml}         xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR                       ${lcelltdd}             IN             @{lcelltddlist}
             ${beamformingType}=                       Get Element    ${lcelltdd}                    xpath=.//list[@name="srsDlMimoModeDepConf"]
             add_element             ${beamformingType}               ${beamforming}                 index=-0
    END
    Save xml                    source=${xml}           path=${SCFC}

Add parameter in all cell_tdd level
    [Arguments]                 ${SCFC}                 ${parameter}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}         xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1      xpath=.//p[@name="enbName"]
    @{lcelllist}=               Get Elements            ${xml}         xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR                       ${lcell}                IN             @{lcelllist}
        add_element            ${lcell}                ${parameter}                                index=-0
    END
    Save xml                    source=${xml}           path=${SCFC}

Add APUCCH_TDD extend parameter
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                                       xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                                    xpath=.//p[@name="enbName"]
    ${cmData}                   Get Element             ${xml}                                       xpath=.//cmData[1]
    #@{lcelllist}=               Get Elements            ${xml}                                       xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    #: FOR                       ${id}                IN                                           @{lcelllist}
    Add Element                 ${cmData}               ${APUCCH_TDD_1}           index=-0
    Add Element                 ${cmData}               ${APUCCH_TDD_2}           index=-0
    Add Element                 ${cmData}               ${APUCCH_TDD_3}           index=-0
    Save xml                    source=${xml}           path=${SCFC}

remove parameter in all lncel_tdd level    
    [Arguments]                 ${SCFC}                 ${parameter}
    ${xml}=                     Parse XML               source=${SCFC}
    set_test_variable           ${xml}    
    @{lceltddllist}=            Get Elements            ${xml}                    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR                       ${lcelltdd}             IN                        @{lceltddllist}
             remove_element          source=${lcelltdd}                          xpath=${parameter}
    END
    Save xml                    source=${xml}           path=${SCFC}         

Add APUCCH_TDD config in all cell_tdd level
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${cmData}=                  Get Element             ${xml}                                       xpath=.//cmData[1]
    add_element                 ${cmData}               ${APUCCH_TDD_1}                              index=-0
    add_element                 ${cmData}               ${APUCCH_TDD_2}                              index=-0
    add_element                 ${cmData}               ${APUCCH_TDD_3}                              index=-0
    Save xml                    source=${xml}           path=${SCFC}

Add active eicic parameters
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                                xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                             xpath=.//p[@name="enbName"]
    @{lncelllist}=              Get Elements            ${xml}                                xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR                       ${lncell}               IN                                    @{lncelllist}
             add_element            ${lncell}                                                <p name="eIcicAbsAdaptationBeta">10</p> 
             add_element            ${lncell}                                                <p name="eIcicMaxCre">10</p>
             add_element            ${lncell}                                                <p name="eIcicPartnerCacAbsTarget">10</p>
             add_element            ${lncell}                                                <p name="eIcicAbsAdaptationThreshold0To1">5</p>
             add_element            ${lncell}                                                <p name="eIcicAbsPatChangeDelayT">50</p>
             add_element            ${lncell}                                                <p name="eIcicPartnerCacTarget">20</p>
             add_element            ${lncell}                                                <p name="eIcicMp0DelayT">10</p>
             add_element            ${lncell}                                                <p name="multCioAdaptExecEicic">5</p>
             add_element            ${lncell}                                                <p name="eIcicCioAdaptAlgo">adaptive</p>
             add_element            ${lncell}                                                <p name="eIcicMaxMutePattern">mp2</p>
             add_element            ${lncell}                                                <p name="eIcicMaxNumPartners">3</p>
             add_element            ${lncell}                                                <p name="eIcicAbsDeltaAdjustment">6</p>
             add_element            ${lncell}                                                <p name="applyFeicicFunctionality">true</p>
             add_element            ${lncell}    <list name="loadSettings"><item><p name="cellCapClass">100</p>
    ...    <p name="targetLoadGbrDl">50</p><p name="targetLoadNonGbrDl">75</p><p name="mlbEicicOperMode">allUes</p>
    ...    <p name="nomNumPrbNonGbr">0.01</p><p name="targetLoadPdcch">90</p><p name="ulStaticCac">100</p><p name="ulCacIgnore">false</p>
    ...    <p name="ulCacSelection">ulReflectDlCac</p></item></list> 
    END
    Save xml                    source=${xml}           path=${SCFC}                   

Add TM7 parameter in all cell_tdd
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                                xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                             xpath=.//p[@name="enbName"]
    @{lcell_tddlist}=           Get Elements            ${xml}                                xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR                       ${lcell_tdd}                IN                                @{lcell_tddlist}
             Set element text        source=${lcelltdd}       text=Single Stream Beamforming      xpath=.//p[@name="dlMimoMode"]    
             Set element text        source=${lcelltdd}       text=customized profile 1           xpath=.//p[@name="dlSectorBFWeightProfName"]
    END
    Save xml                    source=${xml}           path=${SCFC}        

Add OTDOA profile list parameter
    [Arguments]              ${SCFC}
    ${xml}=                  Parse XML               source=${SCFC}
    ${lnbts}=                Get Element             ${xml}                                       xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    add_element              ${lnbts}                ${OTDOA_profile_list}                        index=-0
    Save xml                 source=${xml}           path=${SCFC}

Add BBPOOLALLOC parameter
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                                xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                             xpath=.//p[@name="enbName"]
    ${lnbts}=                   Get Element             ${xml}                                xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    ${cmData}                   Get Element             ${xml}                                xpath=.//cmData[1]
    Add Element                 ${cmData}               ${BBPOOLALLOC_1}                                        index=-0
    Add Element                 ${cmData}               ${BBPOOLALLOC_2}                                        index=-0
    Add Element                 ${cmData}               ${BBPOOLALLOC_3}                                        index=-0
    Add Element                 ${lnbts}                <p name="bbPoolEvalPeriod">50</p>                                         index=-0
    Add Element                 ${lnbts}                <p name="bbPoolMinResource">5</p>                                         index=-0
    Save xml                    source=${xml}           path=${SCFC}

Add bbPoolLogicalGroupId parameter
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                                xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                             xpath=.//p[@name="enbName"]
    ${lnbts}=                   Get Element             ${xml}                                xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    ${cmData}                   Get Element             ${xml}                                xpath=.//cmData[1]
    Add Element                 ${cmData}               ${BBPOOLALLOC_1_bbPoolLogicalGroupId}                                     index=-0
    Add Element                 ${cmData}               ${BBPOOLALLOC_2_bbPoolLogicalGroupId}                                     index=-0
    Add Element                 ${cmData}               ${BBPOOLALLOC_3_bbPoolLogicalGroupId}                                     index=-0
    Add Element                 ${lnbts}                <p name="bbPoolEvalPeriod">50</p>                                         index=-0
    Add Element                 ${lnbts}                <p name="bbPoolMinResource">5</p>                                         index=-0
    Save xml                    source=${xml}           path=${SCFC}

Add bbPoolAllocPrioList parameter
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                                       xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                                    xpath=.//p[@name="enbName"]
    ${lnbts}=                   Get Element             ${xml}                                       xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    add_element                 ${lnbts}                ${bbPoolAllocPrioList}                       index=-0
    Save xml                    source=${xml}           path=${SCFC}

Add BBPOOLALLOC parameter for manual
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                                xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                             xpath=.//p[@name="enbName"]
    ${lnbts}=                   Get Element             ${xml}                                xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    ${cmData}                   Get Element             ${xml}                                xpath=.//cmData[1]
    Add Element                 ${cmData}               ${BBPOOLALLOC_1_1}                                        index=-0
    Add Element                 ${cmData}               ${BBPOOLALLOC_2_1}                                        index=-0
    Add Element                 ${cmData}               ${BBPOOLALLOC_3_1}                                        index=-0
    Add Element                 ${lnbts}                <p name="bbPoolEvalPeriod">50</p>                         index=-0
    Add Element                 ${lnbts}                <p name="bbPoolMinResource">5</p>                         index=-0
    Save xml                    source=${xml}           path=${SCFC}

Add bbCardUsage parameter
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                         xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                      xpath=.//p[@name="enbName"]
    ${BBMOD}=                   Get Element             ${xml}                         xpath=.//managedObject[@class="com.nokia.srbts.eqm:BBMOD"]
    ${cmData}                   Get Element             ${xml}                         xpath=.//cmData[1]
    Add Element                 ${BBMOD}                <p name="bbCardUsage">2</p>    index=-0
    Save xml                    source=${xml}           path=${SCFC}

remove parameter'${parameter}' in all lncel_tdd level
    ${SCFC}                     set_variable            ${SAVE LOG DIRECTORY}/SCFC_1.xml
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                         xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                      xpath=.//p[@name="enbName"]
    @{lceltddllist}=            Get Elements            ${xml}                         xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR                       ${lcell}                IN                             @{lceltddllist}
             remove_element          source=${lcell}                                  xpath=.//p[@name="${parameter}"]
    END
    Save xml                    source=${xml}           path=${SCFC}

Add CRGPR element in LNBTS
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${cmData}=                  Get Element             ${xml}                         xpath=.//cmData[1]
    add_element                 ${cmData}               ${CRGPR}                       index=48
    Save xml                    source=${xml}           path=${SCFC}

Add furtherPlmnIdL config in LNCEL
    [Arguments]                 ${SCFC}
    ${xml}                      Parse XML               source=${SCFC}
    @{lcelllist}                Get Elements            ${xml}                         xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR                       ${lcell}                IN                             @{lcelllist}
             Add Element       ${lcell}                ${furtherPlmnIdL}              index=-0
    END
    Save xml                    source=${xml}           path=${SCFC}

Add UlMuMimo parameter in cell
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}                         xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=BTS1                      xpath=.//p[@name="enbName"]
    @{lcelltddlist}=            Get Elements            ${xml}                         xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR                       ${lcelltdd}             IN                             @{lcelltddlist}
        add_element            ${lcelltdd}             ${ulMuMimoMCSOffset}           index=-0
        add_element            ${lcelltdd}             ${ulMuMimoParaSet}             index=-0
    END
    Save xml                    source=${xml}           path=${SCFC}

Modify MMIMOCPR into left or right 32TRX
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML         source=${SCFC}
    ${MMIMOCPR}=                Get Element       ${xml}            xpath=.//managedObject[@class="NOKLTE:MMIMOCPR"]
    Set element text            source=${MMIMOCPR}                  text=60      xpath=.//p[@name="modulusOfAntGrp0H"]
    Set element text            source=${MMIMOCPR}                  text=50      xpath=.//p[@name="modulusOfAntGrp0V"]
    Set element text            source=${MMIMOCPR}                  text=100      xpath=.//p[@name="modulusOfAntGrp1H"]
    Set element text            source=${MMIMOCPR}                  text=100      xpath=.//p[@name="modulusOfAntGrp1V"]
    Set element text            source=${MMIMOCPR}                  text=100      xpath=.//p[@name="modulusOfAntGrp2H"]
    Set element text            source=${MMIMOCPR}                  text=100      xpath=.//p[@name="modulusOfAntGrp2V"]
    Set element text            source=${MMIMOCPR}                  text=80      xpath=.//p[@name="modulusOfAntGrp3H"]
    Set element text            source=${MMIMOCPR}                  text=50      xpath=.//p[@name="modulusOfAntGrp3V"]
    Set element text            source=${MMIMOCPR}                  text=25500      xpath=.//p[@name="modulusOfAntGrp4H"]
    Set element text            source=${MMIMOCPR}                  text=25500      xpath=.//p[@name="modulusOfAntGrp5H"]
    Set element text            source=${MMIMOCPR}                  text=25500      xpath=.//p[@name="modulusOfAntGrp6H"]
    Set element text            source=${MMIMOCPR}                  text=25500      xpath=.//p[@name="modulusOfAntGrp7H"]
    Set element text            source=${MMIMOCPR}                  text=-143      xpath=.//p[@name="phaseOfAntGrp0H"]
    Set element text            source=${MMIMOCPR}                  text=-97      xpath=.//p[@name="phaseOfAntGrp0V"]
    Set element text            source=${MMIMOCPR}                  text=103      xpath=.//p[@name="phaseOfAntGrp1H"]
    Set element text            source=${MMIMOCPR}                  text=0      xpath=.//p[@name="phaseOfAntGrp1V"]
    Set element text            source=${MMIMOCPR}                  text=100      xpath=.//p[@name="phaseOfAntGrp2H"]
    Set element text            source=${MMIMOCPR}                  text=0      xpath=.//p[@name="phaseOfAntGrp2V"]
    Set element text            source=${MMIMOCPR}                  text=-143      xpath=.//p[@name="phaseOfAntGrp3H"]
    Set element text            source=${MMIMOCPR}                  text=-97      xpath=.//p[@name="phaseOfAntGrp3V"]
    Set element text            source=${MMIMOCPR}                  text=255      xpath=.//p[@name="phaseOfAntGrp4H"]
    Set element text            source=${MMIMOCPR}                  text=255      xpath=.//p[@name="phaseOfAntGrp5H"]
    Set element text            source=${MMIMOCPR}                  text=255      xpath=.//p[@name="phaseOfAntGrp6H"]
    Set element text            source=${MMIMOCPR}                  text=255      xpath=.//p[@name="phaseOfAntGrp7H"]
    Save xml                    source=${xml}                       path=${SCFC}
    
Modify MMIMOCPR into top or bottom 32TRX
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML         source=${SCFC}
    ${MMIMOCPR}=                Get Element       ${xml}            xpath=.//managedObject[@class="NOKLTE:MMIMOCPR"]
    Set element text            source=${MMIMOCPR}                  text=40      xpath=.//p[@name="modulusOfAntGrp0H"]
    Set element text            source=${MMIMOCPR}                  text=100      xpath=.//p[@name="modulusOfAntGrp0V"]
    Set element text            source=${MMIMOCPR}                  text=50      xpath=.//p[@name="modulusOfAntGrp1H"]
    Set element text            source=${MMIMOCPR}                  text=100      xpath=.//p[@name="modulusOfAntGrp1V"]
    Set element text            source=${MMIMOCPR}                  text=80      xpath=.//p[@name="modulusOfAntGrp2H"]
    Set element text            source=${MMIMOCPR}                  text=25500      xpath=.//p[@name="modulusOfAntGrp2V"]
    Set element text            source=${MMIMOCPR}                  text=100      xpath=.//p[@name="modulusOfAntGrp3H"]
    Set element text            source=${MMIMOCPR}                  text=25500      xpath=.//p[@name="modulusOfAntGrp3V"]
    Set element text            source=${MMIMOCPR}                  text=100      xpath=.//p[@name="modulusOfAntGrp4H"]
    Set element text            source=${MMIMOCPR}                  text=90      xpath=.//p[@name="modulusOfAntGrp5H"]
    Set element text            source=${MMIMOCPR}                  text=100      xpath=.//p[@name="modulusOfAntGrp6H"]
    Set element text            source=${MMIMOCPR}                  text=80      xpath=.//p[@name="modulusOfAntGrp7H"]
    Set element text            source=${MMIMOCPR}                  text=-22      xpath=.//p[@name="phaseOfAntGrp0H"]
    Set element text            source=${MMIMOCPR}                  text=0      xpath=.//p[@name="phaseOfAntGrp0V"]
    Set element text            source=${MMIMOCPR}                  text=-50      xpath=.//p[@name="phaseOfAntGrp1H"]
    Set element text            source=${MMIMOCPR}                  text=0      xpath=.//p[@name="phaseOfAntGrp1V"]
    Set element text            source=${MMIMOCPR}                  text=-73      xpath=.//p[@name="phaseOfAntGrp2H"]
    Set element text            source=${MMIMOCPR}                  text=255      xpath=.//p[@name="phaseOfAntGrp2V"]
    Set element text            source=${MMIMOCPR}                  text=-88      xpath=.//p[@name="phaseOfAntGrp3H"]
    Set element text            source=${MMIMOCPR}                  text=255      xpath=.//p[@name="phaseOfAntGrp3V"]
    Set element text            source=${MMIMOCPR}                  text=-162    xpath=.//p[@name="phaseOfAntGrp4H"]
    Set element text            source=${MMIMOCPR}                  text=-20      xpath=.//p[@name="phaseOfAntGrp5H"]
    Set element text            source=${MMIMOCPR}                  text=9      xpath=.//p[@name="phaseOfAntGrp6H"]
    Set element text            source=${MMIMOCPR}                  text=144      xpath=.//p[@name="phaseOfAntGrp7H"]
    Save xml                    source=${xml}                       path=${SCFC}

Modify sector beam to eCPRI
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML         source=${SCFC}
    ${MMIMOCPR}=                Get Element       ${xml}            xpath=.//managedObject[@class="NOKLTE:MMIMOCPR"]
    Set element text            source=${MMIMOCPR}                  text=40      xpath=.//p[@name="modulusOfAntGrp0H"]
    Set element text            source=${MMIMOCPR}                  text=70      xpath=.//p[@name="modulusOfAntGrp0V"]
    Set element text            source=${MMIMOCPR}                  text=50      xpath=.//p[@name="modulusOfAntGrp1H"]
    Set element text            source=${MMIMOCPR}                  text=100     xpath=.//p[@name="modulusOfAntGrp1V"]
    Set element text            source=${MMIMOCPR}                  text=80      xpath=.//p[@name="modulusOfAntGrp2H"]
    Set element text            source=${MMIMOCPR}                  text=100     xpath=.//p[@name="modulusOfAntGrp2V"]
    Set element text            source=${MMIMOCPR}                  text=100     xpath=.//p[@name="modulusOfAntGrp3H"]
    Set element text            source=${MMIMOCPR}                  text=70      xpath=.//p[@name="modulusOfAntGrp3V"]
    Set element text            source=${MMIMOCPR}                  text=100     xpath=.//p[@name="modulusOfAntGrp4H"]
    Set element text            source=${MMIMOCPR}                  text=90      xpath=.//p[@name="modulusOfAntGrp5H"]
    Set element text            source=${MMIMOCPR}                  text=100     xpath=.//p[@name="modulusOfAntGrp6H"]
    Set element text            source=${MMIMOCPR}                  text=80      xpath=.//p[@name="modulusOfAntGrp7H"]
    Set element text            source=${MMIMOCPR}                  text=-22     xpath=.//p[@name="phaseOfAntGrp0H"]
    Set element text            source=${MMIMOCPR}                  text=0       xpath=.//p[@name="phaseOfAntGrp0V"]
    Set element text            source=${MMIMOCPR}                  text=-50     xpath=.//p[@name="phaseOfAntGrp1H"]
    Set element text            source=${MMIMOCPR}                  text=-144    xpath=.//p[@name="phaseOfAntGrp1V"]
    Set element text            source=${MMIMOCPR}                  text=-73     xpath=.//p[@name="phaseOfAntGrp2H"]
    Set element text            source=${MMIMOCPR}                  text=-144    xpath=.//p[@name="phaseOfAntGrp2V"]
    Set element text            source=${MMIMOCPR}                  text=-88     xpath=.//p[@name="phaseOfAntGrp3H"]
    Set element text            source=${MMIMOCPR}                  text=0       xpath=.//p[@name="phaseOfAntGrp3V"]
    Set element text            source=${MMIMOCPR}                  text=-162    xpath=.//p[@name="phaseOfAntGrp4H"]
    Set element text            source=${MMIMOCPR}                  text=-20     xpath=.//p[@name="phaseOfAntGrp5H"]
    Set element text            source=${MMIMOCPR}                  text=9       xpath=.//p[@name="phaseOfAntGrp6H"]
    Set element text            source=${MMIMOCPR}                  text=144     xpath=.//p[@name="phaseOfAntGrp7H"]
    Save xml                    source=${xml}                       path=${SCFC}

Add AdptSectorBfWeight parameter in cell
    [Arguments]                ${SCFC}
    ${xml}=                    Parse XML    source=${SCFC}
    ${btsname}=                Get Element                    ${xml}                 xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text           source=${btsname}              text=BTS1              xpath=.//p[@name="enbName"]
    @{lcelltddlist}=           Get Elements                   ${xml}                 xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcelltdd}       IN                             @{lcelltddlist}
            add_element       ${lcelltdd}                    ${sectorBfWeightChgPrfTraffic}          index=-0
            add_element       ${lcelltdd}                    ${sectorBfWeightChgProf}                index=-0
    END
    Save xml                   source=${xml}                  path=${SCFC}    

Add dlQoeEnhanceParSet parameter in cell
    [Arguments]                ${SCFC}
    ${xml}=                    Parse XML    source=${SCFC}
    ${btsname}=                Get Element                    ${xml}                 xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text           source=${btsname}              text=BTS1              xpath=.//p[@name="enbName"]
    @{lcelltddlist}=           Get Elements                   ${xml}                 xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcelltdd}       IN                             @{lcelltddlist}
            add_element       ${lcelltdd}                    ${dlQoeEnhanceParSet}              index=-0
    END
    Save xml                   source=${xml}                  path=${SCFC}    

Add pdcchMultiplexParaSet extend parameter
    [Arguments]                ${SCFC}
    ${xml}=                    Parse XML     source=${SCFC}
    ${btsname}=                Get Element                     ${xml}                xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text           source=${btsname}               text=eNB1             xpath=.//p[@name="enbName"]
    @{lcell_tddlist}=          Get Elements                    ${xml}                xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcell_tdd}      IN                              @{lcell_tddlist}
            Add Element       ${lcell_tdd}                    ${pdcchMultiplexParaSet}            index=-0
    END
    Save xml                   source=${xml}                   path=${SCFC}

Add PMQAP element in LNBTS
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${cmData}=                  Get Element             ${xml}                       xpath=.//cmData[1]
    add_element                 ${cmData}               ${PMQAP}                     index=-0
    Save xml                    source=${xml}           path=${SCFC}

Add vlanId parameter
    [Arguments]                 ${SCFC}
    ${xml}=                     Parse XML               source=${SCFC}
    ${btsname}=                 Get Element             ${xml}     xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text            source=${btsname}       text=eNB1                    xpath=.//p[@name="enbName"]
    ${VLANIF}=                  Get Element             ${xml}                       xpath=.//managedObject[@class="com.nokia.srbts.tnl:VLANIF"]
    add_element                 ${VLANIF}               ${vlanId}                    index=0
    Save xml                    source=${xml}           path=${SCFC}
