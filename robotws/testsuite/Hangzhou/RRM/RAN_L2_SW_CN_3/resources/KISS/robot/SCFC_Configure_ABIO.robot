*** Settings ***
Library    ${CURDIR}/../python/local_xml.py

*** Variables ***
${version}    TL17
${qci1eVTTConfig}    <list name="qci1eVTTConfig"><item><p name="qci1DlTargetBler">50</p><p name="qci1HarqMaxTrDl">3</p>
...    <p name="qci1HarqMaxTrUl">3</p><p name="qci1ReconStopTimer">50</p><p name="qci1ThroughputFactorDl">40</p>
...    <p name="qci1ThroughputFactorUl">40</p><p name="qci1UlTargetBler">5</p></item></list>
${SPSConfig}    <list name="ulSpsConfig"><item><p name="amrVoiceBRThreshold">33</p><p name="maxNumSpsUeUl">6</p><p name="p0NomPuschSps">-100</p>
...    <p name="ulSpsInterval">20subframes</p><p name="ulSpsMaxNumPrb">20</p><p name="ulSpsMaxPrbPerUeNB">4</p><p name="ulSpsMaxPrbPerUeWB">8</p>
...    <p name="ulSpsMinVoicePktSize">25</p><p name="ulSpsNumEmptyTransmissions">e4</p><p name="ulSpsQci1ThroughputFactor">20</p>
...    <p name="ulSpsTwoIntervalConfig">true</p><p name="ulSpsVoicePktTbsNB">big</p><p name="ulSpsVoicePktTbsWB">big</p>
...    <p name="ulTargetBlerSps">10</p></item></list>
${CADPR}    <managedObject class="NOKLTE:CADPR" distName="MRBTS-1/LNBTS-1/CADPR-0" version="${version}" operation="create"><p name="a3Offset">10</p>
...    <p name="a3TimeToTrigger">ms320</p><p name="a3TriggerQuantity">RSRP</p><p name="a6Offset">6</p><p name="a6ReportInterval">640ms</p>
...    <p name="a6TimeToTrigger">320ms</p><p name="enableA3Event">true</p><p name="enableA6Event">true</p><p name="enableFreqPrioSwap">disabled</p>
...    <p name="hysA3Offset">10</p><p name="hysA6Offset">0</p><p name="maxNumMimoLayerTdd">10</p><p name="maxNumScellSwaps">0</p>
...    <p name="sFreqPrio">1</p><p name="scellMeasThreshRsrp">-100</p><p name="scellMeasThreshRsrq">-120</p>
...    <p name="scellPdcchOlLa">disabled</p></managedObject>
${CAGENB}    <managedObject class="NOKLTE:CAGENB" distName="MRBTS-1/LNBTS-1/CAGENB-0" version="${version}" operation="create">
...    <p name="actEnhCaBandCombSel">off</p><p name="caScellSchedWtFactMinCqi">6</p><p name="maxDlCaConfigForUlCa">max_3CC_DL_CA</p>
...    <p name="nlcvDeltaX2C2">2</p><p name="pcellUlPathlossOffset">10</p><p name="pcellUlPathlossThresh">125</p></managedObject>
${CAREL_1_2}    <managedObject class="NOKLTE:CAREL" distName="MRBTS-1/LNBTS-1/LNCEL-1/CAREL-2" operation="create" version="${version}">
...    <p name="lnBtsId">1</p><p name="lcrId">2</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${CAREL_1_3}    <managedObject class="NOKLTE:CAREL" distName="MRBTS-1/LNBTS-1/LNCEL-1/CAREL-3" operation="create" version="${version}">
...    <p name="lnBtsId">1</p><p name="lcrId">3</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${CAREL_2_1}    <managedObject class="NOKLTE:CAREL" distName="MRBTS-1/LNBTS-1/LNCEL-2/CAREL-1" operation="create" version="${version}">
...    <p name="lnBtsId">1</p><p name="lcrId">1</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${CAREL_2_3}    <managedObject class="NOKLTE:CAREL" distName="MRBTS-1/LNBTS-1/LNCEL-2/CAREL-3" operation="create" version="${version}">
...    <p name="lnBtsId">1</p><p name="lcrId">3</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${CAREL_3_1}    <managedObject class="NOKLTE:CAREL" distName="MRBTS-1/LNBTS-1/LNCEL-3/CAREL-1" operation="create" version="${version}">
...    <p name="lnBtsId">1</p><p name="lcrId">1</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${CAREL_3_2}    <managedObject class="NOKLTE:CAREL" distName="MRBTS-1/LNBTS-1/LNCEL-3/CAREL-2" operation="create" version="${version}">
...    <p name="lnBtsId">1</p><p name="lcrId">2</p><p name="maxNumOfSuppMimoLayer">2-layer</p><p name="pcellSwapAllowed">allowed</p>
...    <p name="scellPrio">1</p><p name="beamformingInScellAllowed">allowed</p></managedObject>
${redBwRbUlConfig}    <list name="redBwRbUlConfig"><item><p name="redBwMaxRbUl">25</p><p name="redBwMinRbUl">1</p></item></list>
${C_plan_overload}    <list name="cpovlha"><item><p name="enableInHoRed">OVL1andL2</p><p name="enableRrcConnRed">OVL1andL2</p></item></list>
${U_plan_overload}    <list name="upovlha"><item><p name="enableERabSetupRed">none</p><p name="enableInHoRed">none</p>
...    <p name="enableRrcConnRed">none</p><p name="enableSuspendSrs">none</p><p name="enableTxDivTransmission">none</p></item></list>
${interferenceAwareListUL_PC}    <list name="ulpcIAwConfig"><item><p name="p0NomPuschIAw">-100</p><p name="ulpcCEBalanceIAw">10</p>
...    <p name="ulpcMinQualIAw">10</p><p name="ulpcMinWaitForPc">25</p><p name="ulpcRefPwrIAw">-208</p></item></list>
${LNREL_1}    <managedObject class="NOKLTE:LNREL" distName="MRBTS-1/LNBTS-1/LNCEL-1/LNREL-1" operation="create" version="${version}">
...    <p name="amleAllowed">false</p><p name="cellIndOffNeigh">0dB</p><p name="handoverAllowed">allowed</p><p name="ecgiLcrId">3</p>
...    <p name="ecgiAdjEnbId">1</p><p name="nrControl">automatic</p><p name="removeAllowed">true</p><list name="ecgiPlmnId"><item>
...    <p name="mcc">262</p><p name="mnc">3</p><p name="mncLength">2</p></item></list></managedObject>
${LNREL_2}    <managedObject class="NOKLTE:LNREL" distName="MRBTS-1/LNBTS-1/LNCEL-2/LNREL-1" operation="create" version="${version}">
...    <p name="amleAllowed">false</p><p name="cellIndOffNeigh">0dB</p><p name="handoverAllowed">allowed</p><p name="ecgiLcrId">3</p>
...    <p name="ecgiAdjEnbId">1</p><p name="nrControl">automatic</p><p name="removeAllowed">true</p><list name="ecgiPlmnId"><item>
...    <p name="mcc">262</p><p name="mnc">3</p><p name="mncLength">2</p></item></list></managedObject>
${LNREL_3}    <managedObject class="NOKLTE:LNREL" distName="MRBTS-1/LNBTS-1/LNCEL-3/LNREL-1" operation="create" version="${version}">
...    <p name="amleAllowed">false</p><p name="cellIndOffNeigh">0dB</p><p name="handoverAllowed">allowed</p><p name="ecgiLcrId">3</p>
...    <p name="ecgiAdjEnbId">1</p><p name="nrControl">automatic</p><p name="removeAllowed">true</p><list name="ecgiPlmnId"><item>
...    <p name="mcc">262</p><p name="mnc">3</p><p name="mncLength">2</p></item></list></managedObject>
${LNHOIF_1}    <managedObject class="NOKLTE:LNHOIF" distName="MRBTS-1/LNBTS-1/LNCEL-1/LNHOIF-1" version="${version}" operation="create">
...    <p name="a3OffsetRsrpInterFreq">12</p><p name="a3OffsetRsrpInterFreqQci1">4</p><p name="a3ReportAmountRsrpInterFreq">infinity</p>
...    <p name="a3ReportAmountRsrqInterFreq">infinity</p><p name="a3ReportIntervalRsrpInterFreq">240ms</p>
...    <p name="a3TimeToTriggerRsrpInterFreq">320ms</p><p name="a5ReportAmountRsrpInterFreq">infinity</p>
...    <p name="a5ReportAmountRsrqInterFreq">infinity</p><p name="a5ReportIntervalInterFreq">480ms</p><p name="a5TimeToTriggerInterFreq">80ms</p>
...    <p name="eutraCarrierInfo">40740</p><p name="hysA3OffsetRsrpInterFreq">0</p><p name="hysThreshold3InterFreq">0</p>
...    <p name="interPresAntP">false</p><p name="measQuantInterFreq">rsrp</p><p name="measurementBandwidth">mbw100</p>
...    <p name="offsetFreqInter">0dB</p><p name="threshold3InterFreq">24</p><p name="threshold3InterFreqHpue">24</p>
...    <p name="threshold3InterFreqQci1">20</p><p name="threshold3aInterFreq">26</p><p name="threshold3aInterFreqHpue">24</p>
...    <p name="threshold3aInterFreqQci1">30</p><p name="thresholdRsrpIFLBFilter">-98</p><p name="thresholdRsrpIFSBFilter">-100</p>
...    <p name="thresholdRsrqIFLBFilter">-120</p><p name="thresholdRsrqIFSBFilter">-100</p></managedObject>
${LNHOIF_2}    <managedObject class="NOKLTE:LNHOIF" distName="MRBTS-1/LNBTS-1/LNCEL-2/LNHOIF-1" version="${version}" operation="create">
...    <p name="a3OffsetRsrpInterFreq">12</p><p name="a3OffsetRsrpInterFreqQci1">4</p><p name="a3ReportAmountRsrpInterFreq">infinity</p>
...    <p name="a3ReportAmountRsrqInterFreq">infinity</p><p name="a3ReportIntervalRsrpInterFreq">240ms</p>
...    <p name="a3TimeToTriggerRsrpInterFreq">320ms</p><p name="a5ReportAmountRsrpInterFreq">infinity</p>
...    <p name="a5ReportAmountRsrqInterFreq">infinity</p><p name="a5ReportIntervalInterFreq">480ms</p><p name="a5TimeToTriggerInterFreq">80ms</p>
...    <p name="eutraCarrierInfo">40740</p><p name="hysA3OffsetRsrpInterFreq">0</p><p name="hysThreshold3InterFreq">0</p>
...    <p name="interPresAntP">false</p><p name="measQuantInterFreq">rsrp</p><p name="measurementBandwidth">mbw100</p>
...    <p name="offsetFreqInter">0dB</p><p name="threshold3InterFreq">24</p><p name="threshold3InterFreqHpue">24</p>
...    <p name="threshold3InterFreqQci1">20</p><p name="threshold3aInterFreq">26</p><p name="threshold3aInterFreqHpue">24</p>
...    <p name="threshold3aInterFreqQci1">30</p><p name="thresholdRsrpIFLBFilter">-98</p><p name="thresholdRsrpIFSBFilter">-100</p>
...    <p name="thresholdRsrqIFLBFilter">-120</p><p name="thresholdRsrqIFSBFilter">-100</p></managedObject>
${LNHOIF_3}    <managedObject class="NOKLTE:LNHOIF" distName="MRBTS-1/LNBTS-1/LNCEL-3/LNHOIF-1" version="${version}" operation="create">
...    <p name="a3OffsetRsrpInterFreq">12</p><p name="a3OffsetRsrpInterFreqQci1">4</p><p name="a3ReportAmountRsrpInterFreq">infinity</p>
...    <p name="a3ReportAmountRsrqInterFreq">infinity</p><p name="a3ReportIntervalRsrpInterFreq">240ms</p>
...    <p name="a3TimeToTriggerRsrpInterFreq">320ms</p><p name="a5ReportAmountRsrpInterFreq">infinity</p>
...    <p name="a5ReportAmountRsrqInterFreq">infinity</p><p name="a5ReportIntervalInterFreq">480ms</p><p name="a5TimeToTriggerInterFreq">80ms</p>
...    <p name="eutraCarrierInfo">40740</p><p name="hysA3OffsetRsrpInterFreq">0</p><p name="hysThreshold3InterFreq">0</p>
...    <p name="interPresAntP">false</p><p name="measQuantInterFreq">rsrp</p><p name="measurementBandwidth">mbw100</p>
...    <p name="offsetFreqInter">0dB</p><p name="threshold3InterFreq">24</p><p name="threshold3InterFreqHpue">24</p>
...    <p name="threshold3InterFreqQci1">20</p><p name="threshold3aInterFreq">26</p><p name="threshold3aInterFreqHpue">24</p>
...    <p name="threshold3aInterFreqQci1">30</p><p name="thresholdRsrpIFLBFilter">-98</p><p name="thresholdRsrpIFSBFilter">-100</p>
...    <p name="thresholdRsrqIFLBFilter">-120</p><p name="thresholdRsrqIFSBFilter">-100</p></managedObject>
${LNADJ_1}    <managedObject class="NOKLTE:LNADJ" distName="MRBTS-1/LNBTS-1/LNADJ-1" operation="create" version="${version}">
...    <p name="cPlaneIpAddrCtrl">oamControlled</p><p name="rlfBasedRCRsupported">false</p><p name="adjEnbId">1</p>
...    <p name="cPlaneIpAddr">192.168.255.1</p><list name="plmnId"><item><p name="mcc">262</p><p name="mnc">3</p>
...    <p name="mncLength">2</p></item></list></managedObject>
${LNADJL_1}    <managedObject class="NOKLTE:LNADJL" distName="MRBTS-1/LNBTS-1/LNADJ-1/LNADJL-1" operation="create" version="${version}">
...    <p name="fDlEarfcn">40042</p><p name="ecgiLcrId">1</p><p name="phyCellId">50</p><p name="tac">666</p><list name="bcPlmnIdList"><item>
...    <p name="mcc">262</p><p name="mnc">3</p><p name="mncLength">2</p></item></list></managedObject>
${fastLoadBalanceConfig}    <list name="fastLoadBalanceConfig"><item><p name="fastLoadBalanceMcsThresh">0</p>
...    <p name="prbUsageRatioGapThresh">30</p><p name="prbUsageRatioHighThresh">80</p></item></list>
${csiRsConfigInfo}    <list name="csiRsConfigInfo"><item><p name="numOfCsiRsAntennaPorts">8</p><p name="csiRsPwrOffset">0</p>
...    <p name="csiRsResourceConf">rsc0</p><p name="csiRsSubfrConf">14</p></item></list>
${dlSectorBFWeightCusProf}    <list name="dlSectorBFWeightCusProf"><item><p name="antennaElementSpacing">1</p>
...    <p name="dlSectorBFWeightProfName">customized profile 1</p><p name="modulusOfWeighforAntGrp0">100</p>
...    <p name="modulusOfWeighforAntGrp1">100</p><p name="modulusOfWeighforAntGrp2">100</p><p name="modulusOfWeighforAntGrp3">100</p>
...    <p name="phaseOfWeighforAntGrp0">0</p><p name="phaseOfWeighforAntGrp1">180</p><p name="phaseOfWeighforAntGrp2">180</p>
...    <p name="phaseOfWeighforAntGrp3">180</p></item></list>
${beamforming}    <item><p name="beamformingType">beamforming</p><p name="srsBandwidth">3hbw</p><p name="srsUePeriodicity">5ms</p></item>
${APUCCH_TDD_1}    <managedObject class="NOKLTE:APUCCH_TDD" distName="MRBTS-1/LNBTS-1/LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0" version="${version}" 
...    operation="create"><p name="aPucchAddAUeRrHo">30</p><p name="aPucchAddAUeTcHo">45</p><p name="aPucchMinNumEmergencySessions">10</p>
...    <p name="aPucchMinNumRrc">10</p><p name="aPucchMinNumRrcNoDrb">5</p><p name="aPucchSrPeriodUpperLimit">20</p>
...    <p name="actLbPucchReg">false</p><p name="pucchF3Support2CC">false</p><p name="selectPrachRegion">None</p></managedObject>
${APUCCH_TDD_2}    <managedObject class="NOKLTE:APUCCH_TDD" distName="MRBTS-1/LNBTS-1/LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0" version="${version}" 
...    operation="create"><p name="aPucchAddAUeRrHo">30</p><p name="aPucchAddAUeTcHo">45</p><p name="aPucchMinNumEmergencySessions">10</p>
...    <p name="aPucchMinNumRrc">10</p><p name="aPucchMinNumRrcNoDrb">5</p><p name="aPucchSrPeriodUpperLimit">20</p>
...    <p name="actLbPucchReg">false</p><p name="pucchF3Support2CC">false</p><p name="selectPrachRegion">None</p></managedObject>
${APUCCH_TDD_3}    <managedObject class="NOKLTE:APUCCH_TDD" distName="MRBTS-1/LNBTS-1/LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0" version="${version}" 
...    operation="create"><p name="aPucchAddAUeRrHo">30</p><p name="aPucchAddAUeTcHo">45</p><p name="aPucchMinNumEmergencySessions">10</p>
...    <p name="aPucchMinNumRrc">10</p><p name="aPucchMinNumRrcNoDrb">5</p><p name="aPucchSrPeriodUpperLimit">20</p>
...    <p name="actLbPucchReg">false</p><p name="pucchF3Support2CC">false</p><p name="selectPrachRegion">None</p></managedObject>
${BBPOOLALLOC_1}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-1/LNBTS-1/LNCEL-1/BBPOOLALLOC-0" 
...    operation="create" version="${version}"><p name="bbPoolAllocMode">automatic</p></managedObject>
${BBPOOLALLOC_2}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-1/LNBTS-1/LNCEL-2/BBPOOLALLOC-0" 
...    operation="create" version="${version}"><p name="bbPoolAllocMode">automatic</p></managedObject>
${BBPOOLALLOC_3}    <managedObject class="NOKLTE:BBPOOLALLOC" distName="MRBTS-1/LNBTS-1/LNCEL-3/BBPOOLALLOC-0" 
...    operation="create" version="${version}"><p name="bbPoolAllocMode">automatic</p></managedObject>
${bbCardUsage}    <managedObject class="com.nokia.srbts.eqm:BBMOD" distName="MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1" 
...    operation="create" version="${version}"><p name="bbCardUsage">2</p><p name="useFullCapacity">true</p></managedObject>
${OTDOA_profile_list}    <list name="otdoaProfileList"><item><p name="otdoaPhaseErrorThreshold">1500</p>
...    <p name="otdoaSyncSourceType">GNSS</p></item></list>
${voipCovBoostConfig}    <list name="voipCovBoostConfig"><item><p name="ulsMinNumCoverageLimitationStateCheck">10</p>
...    <p name="ulsPhrQci1Hyst">5</p><p name="ulsPhrQci1Low">0</p></item></list>
#${CRGPR}    <managedObject class="NOKLTE:CRGPR" distName="MRBTS-1/LNBTS-1/CRGPR-0" operation="create" version="${version}">
...    <p name="crgSkipThreshold">0</p><p name="defaultGroupId">0</p><list name="plmnGroupList"><item><p name="mcc">262</p><p name="mnc">3</p>
...    <p name="mncLength">2</p><p name="groupId">0</p></item><item><p name="mcc">262</p><p name="mnc">4</p><p name="mncLength">2</p>
...    <p name="groupId">1</p></item></list><list name="groupShareList"><item><p name="groupId">0</p><p name="groupShare">70</p></item>
...    <item><p name="groupId">1</p><p name="groupShare">30</p></item></list></managedObject>
${CRGPR}    <managedObject class="NOKLTE:CRGPR" distName="MRBTS-1/LNBTS-1/CRGPR-0" version="xL20A_1909_001" operation="create">
...    <p name="crgSkipThreshold">0</p><p name="defaultGroupId">0</p><list name="groupShareList"><item><p name="groupId">0</p>
...    <p name="groupShare">70</p></item><item><p name="groupId">1</p><p name="groupShare">30</p></item></list><list name="plmnGroupList">
...    <item><p name="groupId">0</p><p name="mcc">666</p><p name="mnc">652</p><p name="mncLength">3</p></item><item><p name="groupId">1</p>
...    <p name="mcc">666</p><p name="mnc">653</p><p name="mncLength">3</p></item></list></managedObject>
${furtherPlmnIdL}    <list name="furtherPlmnIdL"><item><p name="autoRemovalAllowed">false</p><p name="cellReserve">Not Reserved</p>
...    <p name="mcc">666</p><p name="mnc">652</p><p name="mncLength">3</p></item><item><p name="autoRemovalAllowed">false</p>
...    <p name="cellReserve">Not Reserved</p><p name="mcc">666</p><p name="mnc">653</p><p name="mncLength">3</p></item></list>
${ULCOMP}    <managedObject class="NOKLTE:ULCOMP" distName="MRBTS-1/LNBTS-1/ULCOMP-1" operation="create" version="${version}">
...    <p name="ulCoMpSinrThreshold">10</p><p name="ulCoMpMode">SoftBit_Combining</p><list name="a3UlCoMpConfig">
...    <item><p name="a3OffsetCoMp">-30</p><p name="a3ReportIntervalCoMp">640ms</p><p name="a3TimeToTriggerCoMp">0ms</p>
...    <p name="hysA3OffsetCoMp">0</p></item></list><list name="ulCoMpCellList"><p>1</p><p>2</p></list></managedObject>
${ULCOMPBASICCONF}    <managedObject class="NOKLTE:ULCOMPBASICCONF" distName="MRBTS-1/LNBTS-1/ULCOMPBASICCONF-0" 
...    operation="create" version="${version}"><list name="cellList"><item><p name="lnCelId">1</p></item>
...    <item><p name="lnCelId">2</p></item></list><p name="sinrAlpha">90</p><p name="sinrThreshold">10</p> </managedObject>
${PMQAP}    <managedObject class="NOKLTE:PMQAP" distName="MRBTS-1/LNBTS-1/PMRNL-1/PMQAP-1" version="${version}" operation="create">
...    <p name="actCplaneCounters">false</p><p name="actL2Counters">false</p><p name="actPacketSchedulerCounters">false</p>
...    <p name="cfgARPRange">15</p><p name="cfgPRI">64</p><p name="cfgQCIRange">8</p></managedObject>
${tmSwitchThresholdDef256Qam}    <list name="tmSwitchThresholdDef256Qam"><item><p name="tm3to7CqiTh256Qam">50</p>
...    <p name="tm3to8CqiTh256Qam">100</p><p name="tm3to9CqiTh256Qam">110</p><p name="tm7to3CqiTh256Qam">90</p>
...    <p name="tm8to3CqiTh256Qam">140</p><p name="tm9to3CqiTh256Qam">140</p></item></list>
${tcpServiceDiffConfig}    <list name="tcpServiceDiffConfig"><item><p name="boostGuardTime">3000</p><p name="dlMaxBoostBytes">3000</p>
...    <p name="dlMinBoostBytes">875</p><p name="minTcpPacketSize">100</p><p name="timeBetweenTcpPackets">1000</p>
...    <p name="timeNextBoostingRound">5000</p><p name="ulMaxBoostBytes">3000</p><p name="ulMinBoostBytes">100</p></item></list>
${qci1BlerTgtConfig}    <list name="qci1BlerTgtConfig"><item><p name="qci1DlTargetBler">20</p><p name="qci1HarqMaxTxDl">5</p>
...    <p name="qci1HarqMaxTxUl">5</p><p name="qci1UlTargetBler">2</p></item></list>
${furtherPlmnIdL_5PLMN}    <list name="furtherPlmnIdL"><item><p name="autoRemovalAllowed">false</p><p name="cellReserve">Not Reserved</p>
...    <p name="mcc">666</p><p name="mnc">654</p><p name="mncLength">3</p></item><item><p name="autoRemovalAllowed">false</p>
...    <p name="cellReserve">Not Reserved</p><p name="mcc">666</p><p name="mnc">655</p><p name="mncLength">3</p></item>
...    <item><p name="autoRemovalAllowed">false</p><p name="cellReserve">Not Reserved</p><p name="mcc">666</p><p name="mnc">656</p>
...    <p name="mncLength">3</p></item>
...    <item> <p name="autoRemovalAllowed">false</p><p name="cellReserve">Not Reserved</p><p name="mcc">666</p><p name="mnc">657</p>
...    <p name="mncLength">3</p></item>
...    <item><p name="autoRemovalAllowed">false</p><p name="cellReserve">Not Reserved</p><p name="mcc">666</p><p name="mnc">658</p>
...    <p name="mncLength">3</p></item></list>

*** Keywords ***
Add evtt extend parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    @{lcelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        Add Element    ${lcell}    ${qci1eVTTConfig}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Modify SCFC into 2cc CA
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1"]    remove_tail=yes
    remove channel and igore error for cell'3'
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/LNCEL_TDD-0"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/SIB-0"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/IFGDPR-0"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/DRX-0"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/SDRX-0"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0"]
    ${lnbts}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${lnbts}    text=true    xpath=.//p[@name="actDLCAggr"]
    add_element    ${lnbts}    <p name="actFlexCaMgmt">false</p>    index=-1
    ${cmData}=    Get Element    ${xml}    xpath=.//cmData[1]
    Set element text    source=${lnbts}    text=2_carrierOperation    xpath=.//p[@name="actMultipleCarrier"]
    add_element    ${lnbts}    <p name="caSchedFairFact">10</p>    index=15
    add_element    ${cmData}    ${CADPR}    index=15
    add_element    ${cmData}    ${CAGENB}    index=16
    @{lcelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        Set element text    source=${lcell}    text=0    xpath=.//p[@name="addGbrTrafficRrHo"]
        Set element text    source=${lcell}    text=0    xpath=.//p[@name="addGbrTrafficTcHo"]
        Set element text    source=${lcell}    text=370    xpath=.//p[@name="pMax"]
        add_element    ${lcell}    <p name="caPoolId">1</p>    index=1
        add_element    ${lcell}    <p name="ulCaMinPcellSinr">0</p>    index=-1
        add_element    ${lcell}    <p name="ulCaMinPcellSinrQci1">0</p>    index=-1
        add_element    ${lcell}    <p name="dlCaMinPcellCqi">0</p>    index=-1
        add_element    ${lcell}    <p name="dlCaMinPcellCqiQci1">0</p>    index=-1
        add_element    ${lcell}    <p name="scellFastSchedulingSelect">fast</p>    index=-1
        add_element    ${lcell}    <p name="actCaArchEnh">false</p>    index=-1
        add_element    ${lcell}    <p name="actFlowCtrlEnh">false</p>    index=-1
        add_element    ${lcell}    <p name="actCaArchEnhImp">off</p>    index=-1
        add_element    ${lcell}    <p name="actScellConfigForHiDemand">false</p>    index=-1
        add_element    ${lcell}    <p name="eTputInitMcs">20</p>    index=-1
        add_element    ${lcell}    <p name="eTputFilterConfig">51</p>    index=-1
    END
    @{lcelltddlist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcelltdd}    IN    @{lcelltddlist}
        Set element text    source=${lcelltdd}    text=0    xpath=.//p[@name="addNumDrbRadioReasHo"]
        Set element text    source=${lcelltdd}    text=0    xpath=.//p[@name="addNumDrbTimeCriticalHo"]
        Set element text    source=${lcelltdd}    text=0    xpath=.//p[@name="addNumQci1DrbRadioReasHo"]
        Set element text    source=${lcelltdd}    text=0    xpath=.//p[@name="addNumQci1DrbTimeCriticalHo"]
        Set element text    source=${lcelltdd}    text=40    xpath=.//p[@name="maxNumActDrb"]
        Set element text    source=${lcelltdd}    text=20    xpath=.//p[@name="maxNumCaConfUe"]
        Set element text    source=${lcelltdd}    text=10    xpath=.//p[@name="maxNumCaConfUe3c"]
        Set element text    source=${lcelltdd}    text=10    xpath=.//p[@name="maxNumCaConfUeDc"]
        Set element text    source=${lcelltdd}    text=10    xpath=.//p[@name="maxNumQci1Drb"]
        Set element text    source=${lcelltdd}    text=20    xpath=.//p[@name="maxNumActUE"]
    END
    @{lcelltddmpucchlist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:MPUCCH_TDD"]
    FOR    ${lcelltddmpucch}    IN    @{lcelltddmpucchlist}
        Set element text    source=${lcelltddmpucch}
        Set element text    source=${lcelltddmpucch}    text=0    xpath=.//p[@name="addEmergencySessions"]
        Set element text    source=${lcelltddmpucch}    text=0    xpath=.//p[@name="addAUeRrHo"]
        Set element text    source=${lcelltddmpucch}    text=0    xpath=.//p[@name="addAUeTcHo"]
        Set element text    source=${lcelltddmpucch}    text=20    xpath=.//p[@name="maxNumRrc"]
        Set element text    source=${lcelltddmpucch}    text=20    xpath=.//p[@name="maxNumRrcEmergency"]
        Set element text    source=${lcelltddmpucch}    text=1    xpath=.//p[@name="nPucchF3Prbs"]
        Set element text    source=${lcelltddmpucch}    text=72    xpath=.//p[@name="n1PucchAn"]
    END
    @{lcell-1}=    Get Elements    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-1"]
    add_element    ${cmData}    ${CAREL_1_2}    index=17
    @{lcell-2}=    Get Elements    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2"]
    add_element    ${cmData}    ${CAREL_2_1}    index=19
    Save xml    source=${xml}    path=${SCFC}

Add SPS extend parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]    
    @{lcelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcell}    IN    @{lcelllist}
        Add Element    ${lcell}    ${SPSConfig}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Remove cell2 from SCFC
    [Arguments]    ${SCFC}    @{cell_id}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    Set element text    source=${xml}    text=false    xpath=.//p[@name="actMultipleCarrier"]
    @{cell_id}=    Split String    @{cell_id}    ,
    FOR    ${i}    IN    @{cell_id}
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-2/CHANNELGROUP-1"]
    ...    remove_tail=yes
        remove channel and igore error for cell'${i}'
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/LNCEL_TDD-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/SIB-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/IFGDPR-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/DRX-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/SDRX-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/LNCEL_TDD-0/MPUCCH_TDD-0"]    remove_tail=yes
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/SIB-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/IFGPR-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/IFGDPR-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/DRX-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/SDRX-0"]
    END
    Save xml    source=${xml}    path=${SCFC}

Remove cell3 from SCFC
    [Arguments]    ${SCFC}    @{cell_id}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    Set element text    source=${xml}    text=false    xpath=.//p[@name="actMultipleCarrier"]
    @{cell_id}=    Split String    @{cell_id}    ,
    FOR    ${i}    IN    @{cell_id}
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-3/CHANNELGROUP-1"]
    ...    remove_tail=yes
        remove channel and igore error for cell'${i}'
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/LNCEL_TDD-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/SIB-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/IFGDPR-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/DRX-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/SDRX-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/LNCEL_TDD-0/MPUCCH_TDD-0"]    remove_tail=yes
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/SIB-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/IFGPR-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/IFGDPR-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/DRX-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/SDRX-0"]
    END
    Save xml    source=${xml}    path=${SCFC}

Remove cell from SCFC
    [Arguments]    ${SCFC}    @{cell_id}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    Set element text    source=${xml}    text=false    xpath=.//p[@name="actMultipleCarrier"]
    @{cell_id}=    Split String    @{cell_id}    ,
    FOR    ${i}    IN    @{cell_id}
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${CELL${i}_INFO.ID}"]
    ...    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${CELL${i}_INFO.ID}/CHANNELGROUP-1"]
    ...    remove_tail=yes
        remove channel and igore error for cell'${i}'
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/LNCEL_TDD-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/SIB-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/IFGPR-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/IFGDPR-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/DRX-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/SDRX-0"]    remove_tail=yes
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/LNCEL_TDD-0/MPUCCH_TDD-0"]
    ...    remove_tail=yes
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/SIB-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/IFGPR-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/IFGDPR-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/DRX-0"]
        Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${CELL${i}_INFO.ID}/SDRX-0"]
    END
    Save xml    source=${xml}    path=${SCFC}

Modify SCFC into 3cc CA
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    ${lnbts}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    ${cmData}=    Get Element    ${xml}    xpath=.//cmData[1]
    Set element text    source=${lnbts}    text=true    xpath=.//p[@name="actDLCAggr"]
    add_element    ${lnbts}    <p name="actFlexCaMgmt">false</p>    index=-1
    add_element    ${lnbts}    <p name="actAmbrModCaTrigger">false</p>    index=-1
    add_element    ${lnbts}    <p name="caSchedFairFact">10</p>    index=15
    add_element    ${cmData}    ${CADPR}    index=16
    add_element    ${cmData}    ${CAGENB}    index=17
    @{lcelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        Set element text    source=${lcell}    text=0    xpath=.//p[@name="addGbrTrafficRrHo"]
        Set element text    source=${lcell}    text=0    xpath=.//p[@name="addGbrTrafficTcHo"]
        Set element text    source=${lcell}    text=2    xpath=.//p[@name="maxNumScells"]
        add_element    ${lcell}    <p name="caPoolId">0</p>    index=1
        add_element    ${lcell}    <p name="ulCaMinPcellSinr">0</p>    index=-1
        add_element    ${lcell}    <p name="ulCaMinPcellSinrQci1">0</p>    index=-1
        add_element    ${lcell}    <p name="dlCaMinPcellCqi">0</p>    index=-1
        add_element    ${lcell}    <p name="dlCaMinPcellCqiQci1">0</p>    index=-1
        add_element    ${lcell}    <p name="scellFastSchedulingSelect">fast</p>    index=-1
        add_element    ${lcell}    <p name="actCaArchEnh">false</p>    index=-1
    #    add_element    ${lcell}    <p name="actFlowCtrlEnh">false</p>    index=-1
        add_element    ${lcell}    <p name="actCaArchEnhImp">off</p>    index=-1
        add_element    ${lcell}    <p name="actScellConfigForHiDemand">false</p>    index=-1
        add_element    ${lcell}    <p name="eTputInitMcs">20</p>    index=-1
        add_element    ${lcell}    <p name="eTputFilterConfig">51</p>    index=-1
    END
    @{lcelltddlist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcelltdd}    IN    @{lcelltddlist}
        Set element text    source=${lcelltdd}    text=0    xpath=.//p[@name="addNumDrbRadioReasHo"]
        Set element text    source=${lcelltdd}    text=0    xpath=.//p[@name="addNumDrbTimeCriticalHo"]
        Set element text    source=${lcelltdd}    text=0    xpath=.//p[@name="addNumQci1DrbRadioReasHo"]
        Set element text    source=${lcelltdd}    text=0    xpath=.//p[@name="addNumQci1DrbTimeCriticalHo"]
        Set element text    source=${lcelltdd}    text=40    xpath=.//p[@name="maxNumActDrb"]
        Set element text    source=${lcelltdd}    text=20    xpath=.//p[@name="maxNumCaConfUe"]
        Set element text    source=${lcelltdd}    text=20    xpath=.//p[@name="maxNumCaConfUe3c"]
        Set element text    source=${lcelltdd}    text=20    xpath=.//p[@name="maxNumCaConfUeDc"]
        Set element text    source=${lcelltdd}    text=10    xpath=.//p[@name="maxNumQci1Drb"]
        Set element text    source=${lcelltdd}    text=20    xpath=.//p[@name="maxNumActUE"]
        add_element    ${lcelltdd}    <p name="uciOnlyMaxCodeRate">26</p>
    END
    @{lcelltddmpucchlist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:MPUCCH_TDD"]
    FOR    ${lcelltddmpucch}    IN    @{lcelltddmpucchlist}
        Set element text    source=${lcelltddmpucch}    text=0    xpath=.//p[@name="addEmergencySessions"]
        Set element text    source=${lcelltddmpucch}    text=0    xpath=.//p[@name="addAUeRrHo"]
        Set element text    source=${lcelltddmpucch}    text=0    xpath=.//p[@name="addAUeTcHo"]
        Set element text    source=${lcelltddmpucch}    text=20    xpath=.//p[@name="maxNumRrc"]
        Set element text    source=${lcelltddmpucch}    text=20    xpath=.//p[@name="maxNumRrcEmergency"]
        Set element text    source=${lcelltddmpucch}    text=1    xpath=.//p[@name="nPucchF3Prbs"]
        Set element text    source=${lcelltddmpucch}    text=72    xpath=.//p[@name="n1PucchAn"]
    END
    ${lcell-1}=    Get Element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-1/LNCEL_TDD-0"]
    Set element text    source=${lcell-1}    text=38952    xpath=.//p[@name="earfcn"]
    ${lcell-2}=    Get Element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-2/LNCEL_TDD-0"]
    Set element text    source=${lcell-2}    text=39150    xpath=.//p[@name="earfcn"]
    ${lcell-3}=    Get Element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-3/LNCEL_TDD-0"]
    Set element text    source=${lcell-3}    text=39348    xpath=.//p[@name="earfcn"]
    add_element    ${cmData}    ${CAREL_1_2}    index=18
    add_element    ${cmData}    ${CAREL_1_3}    index=19
    add_element    ${cmData}    ${CAREL_2_1}    index=21
    add_element    ${cmData}    ${CAREL_2_3}    index=22
    add_element    ${cmData}    ${CAREL_3_1}    index=24
    add_element    ${cmData}    ${CAREL_3_2}    index=25
    Save xml    source=${xml}    path=${SCFC}

Add DL 2CC CA extend parameter    
    [Arguments]    ${SCFC}    ${cellid1}    ${cellid2}
    ${id3}=    du1fv_exclude_cellid_list_element    ${cellid1}    ${cellid2}
    Modify SCFC into 3cc CA    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${cellid1}/CAREL-${id3}"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${cellid2}/CAREL-${id3}"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${id3}/CAREL-${cellid1}"]    remove_tail=yes
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${id3}/CAREL-${cellid2}"]    remove_tail=yes
    Save xml    source=${xml}    path=${SCFC}

Add parameter in all cell level
    [Arguments]    ${SCFC}    ${parameter}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    @{lcelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        add_element    ${lcell}    ${parameter}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Add parameter in all lncel_tdd level
    [Arguments]    ${SCFC}    ${parameter}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    @{lcelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcell}    IN    @{lcelllist}
        add_element    ${lcell}    ${parameter}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Add parameter in bts level
    [Arguments]    ${SCFC}    ${parameter}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    ${lnbts}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    add_element    ${lnbts}    ${parameter}    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add Restricted_PRB_assignment_in_uplink_configuration extend parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    @{lcelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        Add Element    ${lcell}    ${redBwRbUlConfig}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Add C_plan overload extend parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    ${lnbts}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    add_element    ${lnbts}    ${C_plan_overload}    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add U_plan overload extend parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    ${lnbts}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    add_element    ${lnbts}    ${U_plan_overload}    index=-1
    Save xml    source=${xml}    path=${SCFC}

Modify SCFC into 3cc CA only dl
    Modify SCFC into 3cc CA

Modify SCFC into 2cc CA only dl
    Modify SCFC into 2cc CA

replace btsname on scfc
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]

modify'${num2}'pipe number
    ${target_scfc}    Set Variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}=    Parse XML    source=${target_scfc}
    set_test_variable    ${xml}
    @{lceltddllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcelltdd}    IN    @{lceltddllist}
        remove_element    source=${lcelltdd}    xpath=.//p[@name="dlSectorBeamformingMode"]
    END
    ${lcelnum}=    Get Element Count    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${i}    IN RANGE    1    ${lcelnum}+1
        run keyword if    ${num2}!=6    delete RX to'${num2}'pipe for cell'${i}'transverse distribution
        run keyword if    ${num2}!=6    delete TX to'${num2}'pipe for cell'${i}'transverse distribution
        run keyword if    ${num2}==6    delete RX to 6 pipe for cell'${i}'longitudinal distribution
        run keyword if    ${num2}==6    delete TX to 6 pipe for cell'${i}'longitudinal distribution
    END
    Save xml    source=${xml}    path=${target_scfc}

delete RX to'${num2}'pipe for cell'${i}'transverse distribution
    FOR    ${k}    IN RANGE    8    ${num2}    -1
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1/CHANNEL-${k}"]
    ...    remove_tail=yes
    END

delete TX to'${num2}'pipe for cell'${i}'transverse distribution
    FOR    ${j}    IN RANGE    16    ${num2}+8    -1
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1/CHANNEL-${j}"]
    ...    remove_tail=yes
    END

delete RX to 6 pipe for cell'${i}'longitudinal distribution
    ${a}=    evaluate    ${i}*2-1
    ${b}=    evaluate    ${i}*2
    FOR    ${j}    IN    1    2    3    4    5    6    7    8
        run keyword if    ${j}==${a}    Continue For Loop
        run keyword if    ${j}==${b}    Continue For Loop
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1/CHANNEL-${j}"]
    ...    remove_tail=yes
    END
    
delete TX to 6 pipe for cell'${i}'longitudinal distribution
    ${a}=    evaluate    ${i}*2+7
    ${b}=    evaluate    ${i}*2+8
    FOR    ${k}    IN    9    10    11    12    13    14    15    16
        run keyword if    ${k}==${a}    Continue For Loop
        run keyword if    ${k}==${b}    Continue For Loop
        remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1/CHANNEL-${k}"]
    ...    remove_tail=yes
    END
    Set element text    source=${xml}    text=false    xpath=.//p[@name="actMultipleCarrier"]

remove channel and igore error for cell'${i}'
    FOR    ${j}    IN RANGE    1    17
        run_keyword_and_ignore_error    remove_element    ${xml}
    ...    xpath=.//managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${i}/CHANNELGROUP-1/CHANNEL-${j}"]    remove_tail=yes
    END

select scfc configure'${num1}'RRU and'${num2}'pipe
    run keyword if    ${num1}==1    copy file    ${source_scfc_1}    ${TEST LOG DIRECTORY()}
    run keyword if    ${num1}==3    copy file    ${source_scfc_2}    ${TEST LOG DIRECTORY()}
    run keyword if    ${num2}<8    modify'${num2}'pipe number
    run keyword if    ${num2}==4    modify TM type to closedmino

modify TM type to closedmino
    ${target_scfc}    Set Variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}=    Parse XML    source=${target_scfc}
    @{lceltddllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcelltdd}    IN    @{lceltddllist}
        Set element text    source=${lcelltdd}    text=Closed Loop MIMO (4x2)    xpath=.//p[@name="dlMimoMode"]
        Set element text    source=${lcelltdd}    text=true    xpath=.//p[@name="actFastMimoSwitch"]
        Add Element    ${lcelltdd}    <p name="activatedMimoTM">TM4</p>
    END
    Save xml    source=${xml}    path=${target_scfc}

Add interference aware UL-PC configuration extend parameter
    [Arguments]    ${SCFC}
    ${xml}    Parse XML    source=${SCFC}
    @{lcelllist}    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        Add Element    ${lcell}    ${interferenceAwareListUL_PC}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Add lnrel extend parameter on cell'${id}' ,and set parameter ecgiLcrId:'${parameter1}'ecgiAdjEnbId:'${parameter2}'
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}    Parse XML    source=${SCFC}
    ${a}    set_variable_if    ${id}==1    1    ${id}==2    2    ${id}==3    3
    ${cmData}    Get Element    ${xml}    xpath=.//cmData[1]
    Add Element    ${cmData}    ${LNREL_${id}}    index=-1
    ${lcelllist}    Get Element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${a}/LNREL-1"]
    Set Element Text    ${lcelllist}    ${parameter1}    xpath=.//p[@name="ecgiLcrId"]
    Set Element Text    ${lcelllist}    ${parameter2}    xpath=.//p[@name="ecgiAdjEnbId"]
    Save xml    source=${xml}    path=${SCFC}

Add lnhoif extend parameter on cell'${id}' ,and set parameter eutraCarrierInfo:'${parameter3}'
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}    Parse XML    source=${SCFC}
    ${a}    set_variable_if    ${id}==1    1    ${id}==2    2    ${id}==3    3
    ${cmData}    Get Element    ${xml}    xpath=.//cmData[1]
    Add Element    ${cmData}    ${LNHOIF_${id}}    index=1
    ${lcelllist}    Get Element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${a}/LNHOIF-1"]
    Set Element Text    ${lcelllist}    ${parameter3}    xpath=.//p[@name="eutraCarrierInfo"]
    Save xml    source=${xml}    path=${SCFC}

Add lnadj extend parameter ,and set adj parameter adjEnbId:'${parameter4}'cPlaneIpAddr:'${parameter5}'
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}    Parse XML    source=${SCFC}
    ${cmData}    Get Element    ${xml}    xpath=.//cmData[1]
    Add Element    ${cmData}    ${LNADJ_1}    index=1
    ${lnadj}    Get Element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNADJ-1"]
    Set Element Text    ${lnadj}    ${parameter4}    xpath=.//p[@name="adjEnbId"]
    Set Element Text    ${lnadj}    ${parameter5}    xpath=.//p[@name="cPlaneIpAddr"]
    Save xml    source=${xml}    path=${SCFC}

Add lnadjl extend parameter ,and set adj parameter fDlEarfcn:'${parameter6}'ecgiLcrId:'${parameter7}'phyCellId:'${parameter8}'tac:'${parameter9}'
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}    Parse XML    source=${SCFC}
    ${cmData}    Get Element    ${xml}    xpath=.//cmData[1]
    Add Element    ${cmData}    ${LNADJL_1}    index=-1
    ${lnadjl}    Get Element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNADJ-1/LNADJL-1"]
    Set Element Text    ${lnadjl}    ${parameter6}    xpath=.//p[@name="fDlEarfcn"]
    Set Element Text    ${lnadjl}    ${parameter7}    xpath=.//p[@name="ecgiLcrId"]
    Set Element Text    ${lnadjl}    ${parameter8}    xpath=.//p[@name="phyCellId"]
    Set Element Text    ${lnadjl}    ${parameter9}    xpath=.//p[@name="tac"]
    Save xml    source=${xml}    path=${SCFC}

Add fastLoadBalanceConfig extend parameter
    [Arguments]    ${SCFC}
    ${xml}    Parse XML    source=${SCFC}
    ${cagenb}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:CAGENB"]
    add_element    ${cagenb}    ${fastLoadBalanceConfig}    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add UL_CA_with_smartSched extend parameter
    [Arguments]    ${SCFC}
    #Add parameter in bts level    ${SCFC}    <p name="ulCaPathlossThr">100</p>
    Add parameter in bts level    ${SCFC}    <p name="caUlIntraBandAmpr">enabled</p>
    Add parameter in bts level    ${SCFC}    <p name="dlCaPreferred">DLandUL</p>
    Add parameter in bts level    ${SCFC}    <p name="actUlTraffDrivUlCa">false</p>
    Add fastLoadBalanceConfig extend parameter    ${SCFC}

Add csiRsConfigInfo extend parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    @{lcell_tddlist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcell_tdd}    IN    @{lcell_tddlist}
        Add Element    ${lcell_tdd}    ${csiRsConfigInfo}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Add PMQAP index'${id}' extend parameter and defualt cfgQCI'${QCI}'
    [Documentation]    default pmqap index is 1 ，so add pmqap index from 2...20
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}    Parse XML    source=${SCFC}
    ${cmData}    Get Element    ${xml}    xpath=.//cmData[1]
    Add Element    ${cmData}    <managedObject class="NOKLTE:PMQAP" distName="MRBTS-1/LNBTS-1/PMRNL-1/PMQAP-${id}" version="${version}"
    ...    operation="create"><p name="actCplaneCounters">false</p><p name="actL2Counters">false</p><p name="actPacketSchedulerCounters">false</p>
    ...    <p name="cfgARPRange">15</p><p name="cfgPRI">64</p><p name="cfgQCIRange">${QCI}</p></managedObject>    index=1
    Save xml    source=${xml}    path=${SCFC}

Add PMQAP index'${id}' extend parameter cfgARP'${arp}'
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}    Parse XML    source=${SCFC}
    ${PMQAP}=    Get Element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/PMRNL-1/PMQAP-${id}"]
    add_element    ${PMQAP}    <p name="cfgARPRange">${arp}</p>    index=1
    Save xml    source=${xml}    path=${SCFC}

Add PMQAP index'${id}' extend parameter cfgPRI'${pri}'
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}    Parse XML    source=${SCFC}
    ${PMQAP}=    Get Element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/PMRNL-1/PMQAP-${id}"]
    add_element    ${PMQAP}    <p name="cfgPRI">${pri}</p>    index=1
    Save xml    source=${xml}    path=${SCFC}

remove mo'${name}' in cell'${id}'
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}    Parse XML    source=${SCFC}
    ${a}    set_variable_if    ${id}==1    1    ${id}==2    2    ${id}==3    3
    remove_element    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${a}/${name}"]    remove_tail=yes
    Element Should Not Exist    ${xml}    xpath=.//managedObject[@distName="MRBTS-1/LNBTS-1/LNCEL-${a}/${name}"]
    Save xml    source=${xml}    path=${SCFC}

remove parameter'${parameter}' in all cell level
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    @{lcelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        remove_element    source=${lcell}    xpath=.//p[@name="${parameter}"]
    END
    Save xml    source=${xml}    path=${SCFC}

remove parameter'${parameter}' in bts level
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    ${lnbts}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    remove_element    source=${lnbts}    xpath=.//p[@name="${parameter}"]
    Save xml    source=${xml}    path=${SCFC}

Add dlSectorBFWeightCusProf extend parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    ${lnbts_tdd}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS_TDD"]
    add_element    ${lnbts_tdd}    ${dlSectorBFWeightCusProf}    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add beamforming parameter in cell
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    @{lcelltddlist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcelltdd}    IN    @{lcelltddlist}
        ${beamformingType}=    Get Element    ${lcelltdd}    xpath=.//list[@name="srsDlMimoModeDepConf"]
        add_element    ${beamformingType}    ${beamforming}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Add parameter in all cell_tdd level
    [Arguments]    ${SCFC}    ${parameter}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    @{lcelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcell}    IN    @{lcelllist}
        add_element    ${lcell}    ${parameter}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Add APUCCH_TDD extend parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    ${cmData}    Get Element    ${xml}    xpath=.//cmData[1]
    #@{lcelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    #: FOR    ${id}    IN    @{lcelllist}
    Add Element    ${cmData}    ${APUCCH_TDD_1}    index=-1
    Add Element    ${cmData}    ${APUCCH_TDD_2}    index=-1
    Add Element    ${cmData}    ${APUCCH_TDD_3}    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add APUCCH_TDD config in all cell_tdd level
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${cmData}=    Get Element    ${xml}    xpath=.//cmData[1]
    add_element    ${cmData}    ${APUCCH_TDD_1}    index=-1
    add_element    ${cmData}    ${APUCCH_TDD_2}    index=-1
    add_element    ${cmData}    ${APUCCH_TDD_3}    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add active eicic parameters
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1    xpath=.//p[@name="enbName"]
    @{lncelllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lncell}    IN    @{lncelllist}
        add_element    ${lncell}    <p name="eIcicAbsAdaptationBeta">10</p> 
        add_element    ${lncell}    <p name="eIcicMaxCre">10</p>
        add_element    ${lncell}    <p name="eIcicPartnerCacAbsTarget">10</p>
        add_element    ${lncell}    <p name="eIcicAbsAdaptationThreshold0To1">5</p>
        add_element    ${lncell}    <p name="eIcicAbsPatChangeDelayT">50</p>
        add_element    ${lncell}    <p name="eIcicPartnerCacTarget">20</p>
        add_element    ${lncell}    <p name="eIcicMp0DelayT">10</p>
        add_element    ${lncell}    <p name="multCioAdaptExecEicic">5</p>
        add_element    ${lncell}    <p name="eIcicCioAdaptAlgo">adaptive</p>
        add_element    ${lncell}    <p name="eIcicMaxMutePattern">mp2</p>
        add_element    ${lncell}    <p name="eIcicMaxNumPartners">3</p>
        add_element    ${lncell}    <p name="eIcicAbsDeltaAdjustment">6</p>
        add_element    ${lncell}    <p name="applyFeicicFunctionality">true</p>
        add_element    ${lncell}    <list name="loadSettings"><item><p name="cellCapClass">100</p><p name="targetLoadGbrDl">50</p>
    ...    <p name="targetLoadNonGbrDl">75</p><p name="mlbEicicOperMode">allUes</p><p name="nomNumPrbNonGbr">0.01</p><p name="targetLoadPdcch">90</p>
    ...    <p name="ulStaticCac">100</p><p name="ulCacIgnore">false</p><p name="ulCacSelection">ulReflectDlCac</p></item></list> 
    END
    Save xml    source=${xml}    path=${SCFC}

Add BBPOOLALLOC parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1    xpath=.//p[@name="enbName"]
    ${lnbts}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    ${cmData}    Get Element    ${xml}    xpath=.//cmData[1]
    Add Element    ${cmData}    ${BBPOOLALLOC_1}    index=-1
    Add Element    ${cmData}    ${BBPOOLALLOC_2}    index=-1
    Add Element    ${cmData}    ${BBPOOLALLOC_3}    index=-1
    Add Element    ${lnbts}    <p name="bbPoolEvalPeriod">50</p>    index=-1
    Add Element    ${lnbts}    <p name="bbPoolMinResource">5</p>    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add bbCardUsage parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=eNB1    xpath=.//p[@name="enbName"]
    ${BBMOD}=    Get Element    ${xml}    xpath=.//managedObject[@class="com.nokia.srbts.eqm:BBMOD"]
    ${cmData}    Get Element    ${xml}    xpath=.//cmData[1]
    Add Element    ${BBMOD}    <p name="bbCardUsage">2</p>    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add OTDOA profile list parameter
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${lnbts}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    add_element    ${lnbts}    ${OTDOA_profile_list}    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add voipCovBoostConfig LNCEL
    [Arguments]    ${SCFC}
    ${xml}    Parse XML    source=${SCFC}
    @{lcelllist}    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        Add Element    ${lcell}    ${voipCovBoostConfig}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

remove parameter'${parameter}' in all lncel_tdd level
    ${SCFC}    set_variable    ${TEST LOG DIRECTORY()}/scfc.xml
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    @{lceltddllist}=    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL_TDD"]
    FOR    ${lcell}    IN    @{lceltddllist}
        remove_element    source=${lcell}    xpath=.//p[@name="${parameter}"]
    END
    Save xml    source=${xml}    path=${SCFC}

Add CRGPR element in LNBTS
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${cmData}=    Get Element    ${xml}    xpath=.//cmData[1]
    add_element    ${cmData}    ${CRGPR}    index=48
    Save xml    source=${xml}    path=${SCFC}

Add furtherPlmnIdL config in LNCEL
    [Arguments]    ${SCFC}
    ${xml}    Parse XML    source=${SCFC}
    @{lcelllist}    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        Add Element    ${lcell}    ${furtherPlmnIdL}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Add ULCOMP element in LNBTS
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${cmData}=    Get Element    ${xml}    xpath=.//cmData[1]
    add_element    ${cmData}    ${ULCOMP}    index=48
    Save xml    source=${xml}    path=${SCFC}

Add ULCOMPBASICCONF element in LNBTS
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${cmData}=    Get Element    ${xml}    xpath=.//cmData[1]
    add_element    ${cmData}    ${ULCOMPBASICCONF}    index=48
    Save xml    source=${xml}    path=${SCFC}

Add parameter in CRGPR
    [Arguments]    ${SCFC}    ${parameter}
    ${xml}=    Parse XML    source=${SCFC}
    ${btsname}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNBTS"]
    Set element text    source=${btsname}    text=BTS1    xpath=.//p[@name="enbName"]
    ${CRGPR}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:CRGPR"]
    add_element    ${CRGPR}    ${parameter}    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add PMQAP element in LNBTS
    [Arguments]    ${SCFC}
    ${xml}=    Parse XML    source=${SCFC}
    ${cmData}=    Get Element    ${xml}    xpath=.//cmData[1]
    add_element    ${cmData}    ${PMQAP}    index=1
    Save xml    source=${xml}    path=${SCFC}

Add tmSwitchThresholdDef256Qam element in TMSWPR
    [Arguments]    ${SCFC}
    ${xml}    Parse XML    source=${SCFC}
    ${TMSWPR}=    Get Element    ${xml}    xpath=.//managedObject[@class="NOKLTE:TMSWPR"]
    add_element    ${TMSWPR}    ${tmSwitchThresholdDef256Qam}    index=-1
    Save xml    source=${xml}    path=${SCFC}

Add_TcpServiceDiffConfig_in_LNCELL
    [Arguments]    ${SCFC}
    ${xml}    Parse XML    source=${SCFC}
    @{lcelllist}    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        Add Element    ${lcell}    ${tcpServiceDiffConfig}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Add qci1BlerTgtConfig in LNCEL
    [Arguments]    ${SCFC}
    ${xml}    Parse XML    source=${SCFC}
    @{lcelllist}    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        Add Element    ${lcell}    ${qci1BlerTgtConfig}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}

Add furtherPlmnIdL_5PLMN config in LNCEL
    [Arguments]    ${SCFC}
    ${xml}    Parse XML    source=${SCFC}
    @{lcelllist}    Get Elements    ${xml}    xpath=.//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${lcell}    IN    @{lcelllist}
        Add Element    ${lcell}    ${furtherPlmnIdL_5PLMN}    index=-1
    END
    Save xml    source=${xml}    path=${SCFC}
