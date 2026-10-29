# -*- coding: utf-8 -*-

nr_rel = '<managedObject class="com.nokia.srbts.nrbts:NRREL" distName="MRBTS-1/NRBTS-2/NRCELL-1/NRREL-2" ' \
         'version="NRBTSCL22R1_2106_100" operation="create">' \
         '<p name="cellIndividualSsbRsrpOffset">0dB</p>' \
         '<p name="cellIndividualSsbRsrqOffset">0dB</p>' \
         '<p name="gNbId">2</p>' \
         '<p name="gNbIdLength">22</p>' \
         '<p name="handoverAllowedSA">allowed</p>' \
         '<p name="handoverAllowedSARedCap">forbidden</p>' \
         '<p name="isRplCellForPSCell">false</p>' \
         '<p name="lcrId">3</p>' \
         '<p name="nrDcAllowed">false</p>' \
         '<p name="removeNotAllowed">false</p>' \
         '<p name="sCellAdditionMethod">blind</p>' \
         '<list name="gnbPlmn">' \
         '<item>' \
         '<p name="mcc">311</p>' \
         '<p name="mnc">489</p>' \
         '<p name="mncLength">3</p>' \
         '</item>' \
         '</list>' \
         '</managedObject>'

a1meashossbrsrpsa_add = '<list name="a1MeashoSsbRsrpSA">' \
                        '<item>' \
                        '<p name="a1HysteresishoSsbRsrpSA">1</p>' \
                        '<p name="a1ThresholdhoSsbRsrpSA">56</p>' \
                        '<p name="a1TimeToTriggerhoSsbRsrpSA">ms320</p>' \
                        '</item>' \
                        '</list>'

a2meashossbrsrpsa_add = '<list name="a2MeashoSsbRsrpSA">' \
                        '<item>' \
                        '<p name="a2HysteresishoSsbRsrpSA">1</p>' \
                        '<p name="a2ThresholdhoSsbRsrpSA">48</p>' \
                        '<p name="a2TimeToTriggerhoSsbRsrpSA">ms320</p>' \
                        '</item>' \
                        '</list>'

a2measscellrelssbrsrp_add = '<list name="a2MeasSCellRelSsbRsrp"><item>' \
                            '<p name="a2HysteresisSCellRelSsbRsrp">0</p>' \
                            '<p name="a2ThresholdSCellRelSsbRsrp">34</p>' \
                            '<p name="a2TimeToTriggerSCellRelSsbRsrp">480ms</p>' \
                            '</item>' \
                            '</list>'

a3measssbrsrp_add = '<list name="a3MeasSsbRsrp">' \
                    '<item>' \
                    '<p name="a3HysteresisSsbRsrp">0</p>' \
                    '<p name="a3OffsetSsbRsrp">12</p>' \
                    '<p name="a3TimeToTriggerSsbRsrp">ms0</p>' \
                    '</item>' \
                    '</list>'

drx_profile = '<list name="drxProfile{profile_id}">' \
              '<item>' \
              '<p name="drxInactivityTimer">{drxInactivityTimer}</p>' \
              '<p name="drxLongCycle">{drxLongCycle}</p>' \
              '<p name="drxOnDurationTimer">{drxOnDurationTimer}</p>' \
              '<p name="drxRetransTimerDl">{drxRetransTimerDl}</p>' \
              '<p name="drxRetransTimerUl">{drxRetransTimerUl}</p>' \
              '<p name="drxHarqRttTimerDl">{drxHarqRttTimerDl}</p>' \
              '<p name="drxHarqRttTimerUl">{drxHarqRttTimerUl}</p>' \
              '</item>' \
              '</list>'

periodicCsi = '<list name="periodicCsiAcquisition">' \
              '<item>' \
              '<p name="csiReportPeriodicity">{csiReportPeriodicity}</p>' \
              '<p name="csirsNumberWithinReportPeriod_Set1">{csirsNumberWithinReportPeriod_Set1}</p>' \
              '<p name="csirsPower">{csirsPower}</p>' \
              '<p name="maxCsirsNumber">{maxCsirsNumber}</p>' \
              '<p name="scramblingIdStep">{scramblingIdStep}</p>' \
              '</item>' \
              '</list>'

tddFrameStructure = '<list name="tddFrameStructure">' \
                    '<item>' \
                    '<p name="frameStructureType">{frameStructureType}</p>' \
                    '<p name="guardPeriodLength">{guardPeriodLength}</p>' \
                    '<p name="tdLteUlDlConfig">{tdLteUlDlConfig}</p>' \
                    '<p name="ulDlDataSlotRatio">{ulDlDataSlotRatio}</p>' \
                    '</item>' \
                    '</list>'

csirsbeammgmt = '<list name="csirsBeamMgmt">' \
                '<item>' \
                '<p name="csirsBmMgmtDensity">{csirsBmMgmtDensity}</p>' \
                '<p name="csirsBmMgmtReIndex">{csirsBmMgmtReIndex}</p>' \
                '<p name="csirsBmMgmtSubband">{csirsBmMgmtSubband}</p>' \
                '</item>' \
                '</list>'

nr_hoif = '<managedObject class="com.nokia.srbts.nrbts:NRHOIF" distName="MRBTS-1/NRBTS-2/NRCELL-1/NRHOIF-1" ' \
          'version="NRBTSCL22R1_2106_100" operation="create">' \
          '<p name="a1BasedPCellSwitchEnabled">false</p>' \
          '<p name="a2BasedPCellSwitchEnabled">false</p>' \
          '<p name="a3MeasEnabled">rsrp</p>' \
          '<p name="a4MeasEnDcSteeringEnabled">none</p>' \
          '<p name="a4MeasHigherPrioFreqEnabled">none</p>' \
          '<p name="a4MeasNrDcEnabled">none</p>' \
          '<p name="a4MeasSCellAddEnabled">none</p>' \
          '<p name="a5MeasEnabled">none</p>' \
          '<p name="cellDepType">SA+NSA</p>' \
          '<p name="freqBandIndicatorNR">78</p>' \
          '<p name="ifhoSsbScs">30 KHz</p>' \
          '<p name="ifhoSsbSmtcDuration">sf3</p>' \
          '<p name="ifhoSsbSmtcPeriodicity">sf10</p>' \
          '<p name="numberOfTransmittedSsBlocks">1 beam</p>' \
          '<p name="ssBurstSetPeriod">20</p>' \
          '<p name="ssbFrequency">636700</p>' \
          '<list name="a3MeasSsbRsrp">' \
          '<item>' \
          '<p name="a3HysteresisSsbRsrp">2</p>' \
          '<p name="a3OffsetSsbRsrp">10</p>' \
          '<p name="a3TimeToTriggerSsbRsrp">ms0</p>' \
          '</item>' \
          '</list><list name="a5MeasSsbRsrp">' \
          '<item>' \
          '<p name="a5HysteresisSsbRsrp">0</p>' \
          '<p name="a5Threshold1SsbRsrp">11</p>' \
          '<p name="a5Threshold2SsbRsrp">15</p>' \
          '<p name="a5TimeToTriggerSsbRsrp">ms0</p>' \
          '</item>' \
          '</list>' \
          '</managedObject>'

nrdrb_15 = '<managedObject class="com.nokia.srbts.nrbts:NRDRB" distName="MRBTS-1/NRBTS-2/NRDRB-15" ' \
           'version="NRBTSCL23R2_2301_100" operation="create">' \
           '<p name="actDddsReduction">false</p>' \
           '<p name="actDlTxResumeOnPdcpStatRep">false</p>' \
           '<p name="actLostPduFastRetx">false</p>' \
           '<p name="actOptDataFlowRateEst">false</p>' \
           '<p name="caPduReSendingDelayMargin">2</p>' \
           '<p name="discardTimer">100ms</p>' \
           '<p name="dlAllowMinDelayLinkXxCalib">false</p>' \
           '<p name="dlFlowControlAlgo">none</p>' \
           '<p name="dscp">46</p>' \
           '<p name="durationThresDiscardDl">40</p>' \
           '<p name="durationThresDiscardDlMacSdu">40</p>' \
           '<p name="durationThresDiscardDlPdcpPdu5GLeg">40</p>' \
           '<p name="durationThresDiscardDlPdcpPduLteLeg">40</p>' \
           '<p name="durationThresDiscardUl">20</p>' \
           '<p name="endMarkerTimer">2000</p>' \
           '<p name="maxDataRateGbrDl">100</p>' \
           '<p name="maxDataRateGbrUl">100</p>' \
           '<p name="maxDddsPeriodCpuOvld">40</p>' \
           '<p name="maxRlcQueueingDelayGbr">20</p>' \
           '<p name="maxTransferDelayGbr">20</p>' \
           '<p name="nrDrbMacDN">MRBTS-1/NRBTS-2/NRDRB_MAC-3</p>' \
           '<p name="nrDrbPdcpDN">MRBTS-1/NRBTS-2/NRDRB_PDCP-3</p>' \
           '<p name="nrDrbRlcAmDN">MRBTS-1/NRBTS-2/NRDRB_RLC_AM-1</p>' \
           '<p name="nrDrbRlcUmDN">MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1</p>' \
           '<p name="numSduDiscard">1</p>' \
           '<p name="queuingDelayDiscardEnabled">false</p>' \
           '<p name="queuingDelaySduDiscardThreshold">750</p>' \
           '<p name="resType">GBR</p>' \
           '<p name="rlcMode">RLC_UM</p>' \
           '<p name="rlcPduDelayThCa">30</p>' \
           '<p name="schedulWeight">1</p>' \
           '<p name="sduDiscardIntervalTmr">500</p>' \
           '<p name="volThresDiscardDl">8000</p>' \
           '<p name="volThresDiscardDlMacSdu">8000</p>' \
           '<p name="volThresDiscardDlPdcpPdu5GLeg">8000</p>' \
           '<p name="volThresDiscardDlPdcpPduLteLeg">8000</p>' \
           '<p name="volThresDiscardUl">800</p>' \
           '<list name="cellAggrLevel">' \
           '<p>Not FR1 CA eligible</p>' \
           '</list>' \
           '</managedObject>'

nrdrb_5qi_6 = '<managedObject class="com.nokia.srbts.nrbts:NRDRB_5QI" distName="MRBTS-1/NRBTS-2/NRDRB_5QI-6" ' \
              'version="NRBTSCL22R1_2106_100" operation="create">' \
              '<list name="fiveqiValueList">' \
              '<p>1</p>' \
              '</list>' \
              '<p name="nrDrbDN">MRBTS-1/NRBTS-2/NRDRB-15</p>' \
              '</managedObject>'

nrdrb_mac = '<managedObject class="com.nokia.srbts.nrbts:NRDRB_MAC" distName="MRBTS-1/NRBTS-2/NRDRB_MAC-1" ' \
            'version="NRBTSCL22R1_2106_100" operation="create">' \
            '<p name="lcgid">4</p>' \
            '<p name="prioritisedBitRate">16kBps</p>' \
            '<p name="schedulPrio">5</p>' \
            '<p name="schedulBSD">100ms</p>' \
            '</managedObject>'

nrdrb_pdcp_3 = '<managedObject class="com.nokia.srbts.nrbts:NRDRB_PDCP" distName="MRBTS-1/NRBTS-2/NRDRB_PDCP-3" ' \
               'version="NRBTSCL22R1_2106_100" operation="create">' \
               '<p name="cuFlowControlProfId">1</p>' \
               '<p name="maxCidAllowed">4</p>' \
               '<p name="pdcpBufDiscardEnabled">false</p>' \
               '<p name="pdcpBufDiscardThreshold">20000</p>' \
               '<p name="pdcpDelayThreshRetxMode">disabled</p>' \
               '<p name="tReorderingDl">ms80</p>' \
               '<p name="tReorderingUl">ms80</p>' \
               '<p name="x2FlowControlProfIdForCu">1</p>' \
               '</managedObject>'

nrdrb_rlc_um_1 = '<managedObject class="com.nokia.srbts.nrbts:NRDRB_RLC_UM" ' \
                 'distName="MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1" ' \
                 'version="NRBTSCL22R1_2106_100" operation="create">' \
                 '<p name="dlTReassemblyUm">ms15</p>' \
                 '<p name="rlcUMDrbSNLength">rlcUm12bitSN</p>' \
                 '<p name="ulTReassemblyUm">ms15</p>' \
                 '</managedObject>'

nradjnrcell = '<managedObject class="com.nokia.srbts.nrbts:NRADJNRCELL" distName="MRBTS-1/NRBTS-2/NRADJNRCELL-1" ' \
              'version="NRBTSCL22R1_2106_100" operation="create">' \
              '<p name="cellDepType">SA+NSA</p>' \
              '<p name="cellReservedForOperatorUse">notReserved</p>' \
              '<p name="fiveGsTac">200</p>' \
              '<p name="gNbId">35</p>' \
              '<p name="gNbIdLength">22</p>' \
              '<p name="lcrId">1</p>' \
              '<p name="nrarfcn">638700</p>' \
              '<p name="physCellId">381</p>' \
              '<list name="gnbPlmn">' \
              '<item>' \
              '<p name="mcc">311</p>' \
              '<p name="mnc">489</p>' \
              '<p name="mncLength">3</p>' \
              '</item>' \
              '</list>' \
              '</managedObject>'

nradjgnb = '<managedObject class="com.nokia.srbts.nrbts:NRADJGNB" distName="MRBTS-1/NRBTS-2/NRADJGNB-1" ' \
           'version="NRBTSCL22R1_2106_100" operation="create">' \
           '<p name="administrativeState">Unlocked</p>' \
           '<p name="gNbIdLength">22</p>' \
           '<p name="gNodeBId">35</p>' \
           '<p name="gNodeBIdCtrl">oamControlled</p>' \
           '<p name="xnLinkRef">1</p>' \
           '<list name="gnbPlmn">' \
           '<item>' \
           '<p name="mcc">311</p>' \
           '<p name="mnc">489</p>' \
           '<p name="mncLength">3</p>' \
           '</item>' \
           '</list>' \
           '</managedObject>'

NRADJECELL = '<managedObject class="com.nokia.srbts.nrbts:NRADJECELL" distName="MRBTS-1/NRBTS-2/NRADJECELL-1" ' \
             'version="NRBTSCL22R1_2108_200" operation="create">' \
             '<p name="eNodeBId">1</p>' \
             '<p name="ePSTrackingAreaCode">222</p>' \
             '<p name="earfcnValue">1400</p>' \
             '<p name="lcrId">1</p>' \
             '<p name="physCellId">11</p>' \
             '<list name="ecgiPlmn">' \
             '<item>' \
             '<p name="mcc">311</p>' \
             '<p name="mnc">489</p>' \
             '<p name="mncLength">3</p>' \
             '</item>' \
             '</list>' \
             '<list name="enbPlmn">' \
             '<item>' \
             '<p name="mcc">311</p>' \
             '<p name="mnc">489</p>' \
             '<p name="mncLength">3</p>' \
             '</item>' \
             '</list>' \
             '</managedObject>'

NRRELE = '<managedObject class="com.nokia.srbts.nrbts:NRRELE" distName="MRBTS-1/NRBTS-2/NRCELL-4/NRRELE-1" ' \
         'version="NRBTSCL22R1_2108_200" operation="create">' \
         '<p name="cellIndividualOffset">0dB</p>' \
         '<p name="eNodeBId">1</p>' \
         '<p name="eutranCellBlacklisted">false</p>' \
         '<p name="lcrId">1</p>' \
         '<list name="ecgiPlmn">' \
         '<item>' \
         '<p name="mcc">311</p>' \
         '<p name="mnc">489</p>' \
         '<p name="mncLength">3</p>' \
         '</item>' \
         '</list>' \
         '</managedObject>'

NRHOIR = '<managedObject class="com.nokia.srbts.nrbts:NRHOIR" distName="MRBTS-1/NRBTS-2/NRHOIR-1" ' \
         'version="NRBTSCL22R1_2108_200" operation="create">' \
         '<p name="allowedMeasBandwidth">mbw100</p>' \
         '<p name="b2MeashoEnabled">rsrp</p>' \
         '<p name="b2Threshold1hoRsrp">40</p>' \
         '<p name="earfcnValue">1400</p>' \
         '<p name="eutraFreqQOffsetRange">0dB</p>' \
         '<p name="presenceAntennaPort1">false</p>' \
         '<p name="reportAmount">r8</p>' \
         '<p name="reportInterval">ms240</p>' \
         '<p name="widebandRsrqMeas">false</p>' \
         '<list name="eutraB2MeashoRsrp">' \
         '<item>' \
         '<p name="b2HysteresishoRsrp">0</p>' \
         '<p name="b2Threshold2hoRsrp">50</p>' \
         '<p name="b2TimeToTriggerhoRsrp">ms480</p>' \
         '</item>' \
         '</list>' \
         '</managedObject>'

nrhoirDNList_add = '<list name="nrhoirDNList">' \
                   '<p>MRBTS-1/NRBTS-2/NRHOIR-1</p>' \
                   '</list>'

raTypeList_add = '<list name="raTypeList">' \
                 '<p>nr</p>' \
                 '<p>eutra</p>' \
                 '</list>'

srsForBeamMgmt_add = '<list name="srsForBeamMgmt">' \
                     '<item>' \
                     '<p name="bSRS">{bSRS}</p>' \
                     '<p name="cSRS">{cSRS}</p>' \
                     '<p name="srsUePeriodicity">{srsUePeriodicity}</p>' \
                     '</item>' \
                     '</list>'

bwpdnlist_add = '<list name="cellBwpList">' \
                '<item>' \
                '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-6</p>' \
                '<p name="cellBwpId">0</p>' \
                '</item>' \
                '<item>' \
                '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-67</p>' \
                '<p name="cellBwpId">1</p>' \
                '</item>' \
                '<item>' \
                '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-63</p>' \
                '<p name="cellBwpId">2</p>' \
                '</item>' \
                '</list>'

bwpdnlist_add_dict = {"key_1": '<list name="cellBwpList">'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-6</p>'
                               '<p name="cellBwpId">0</p>'
                               '</item>'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-67</p>'
                               '<p name="cellBwpId">1</p>'
                               '</item>'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-63</p>'
                               '<p name="cellBwpId">2</p>'
                               '</item>'
                               '</list>',
                      "key_2": '<list name="cellBwpList">'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-8</p>'
                               '<p name="cellBwpId">0</p>'
                               '</item>'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-87</p>'
                               '<p name="cellBwpId">1</p>'
                               '</item>'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-85</p>'
                               '<p name="cellBwpId">2</p>'
                               '</item>'
                               '</list>',
                      "key_3": '<list name="cellBwpList">'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-1/BWP_PROFILE-8</p>'
                               '<p name="cellBwpId">0</p>'
                               '</item>'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-1/BWP_PROFILE-85</p>'
                               '<p name="cellBwpId">1</p>'
                               '</item>'
                               '</list>',
                      "key_4": '<list name="cellBwpList">'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-1/BWP_PROFILE-5</p>'
                               '<p name="cellBwpId">0</p>'
                               '</item>'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-1/BWP_PROFILE-52</p>'
                               '<p name="cellBwpId">1</p>'
                               '</item>'
                               '</list>',
                      "key_5": '<list name="cellBwpList">'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-6</p>'
                               '<p name="cellBwpId">0</p>'
                               '</item>'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-67</p>'
                               '<p name="cellBwpId">1</p>'
                               '</item>'
                               '<item>'
                               '<p name="bwpDN">MRBTS-1/NRBTS-2/BWP_PROFILE-65</p>'
                               '<p name="cellBwpId">2</p>'
                               '</item>'
                               '</list>'
                      }

eirpControlList_add = '<list name="eirpControl">' \
                      '<item>' \
                      '<p name="minGuaranteedBudgetRatio">{minGuaranteedBudgetRatio}</p>' \
                      '<p name="minGuaranteedBudgetRatioMode">{minGuaranteedBudgetRatioMode}</p>' \
                      '<p name="minSignificantNormalizedBeamGain">{minSignificantNormalizedBeamGain}</p>' \
                      '<p name="numOfSegmentAzimuthEdges">{numOfSegmentAzimuthEdges}</p>' \
                      '<p name="numOfSegmentElevationEdges">{numOfSegmentElevationEdges}</p>' \
                      '<p name="schedulWeightFactorEnabled">{schedulWeightFactorEnabled}</p>' \
                      '</item>' \
                      '</list>'

NRULCLPC_PROFILE = '<managedObject class="com.nokia.srbts.nrbts:NRULCLPC_PROFILE"  ' \
                   'distName="MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0" version="NRBTSCL23R4_2314_101" operation="create">' \
                   '<list name="clpcPucch">' \
                   '<item>' \
                   '<p name="sinrAveMeasSamples">10</p>' \
                   '<p name="sinrThresholdIndex">triplet 1 (-2, 0, +1)</p>' \
                   '<p name="targetSinr">8</p>' \
                   '<p name="tIntervalSinrUpd">100ms</p>' \
                   '<p name="tTpcPenalty">50</p>' \
                   '</item>' \
                   '</list>' \
                   '<list name="clpcPusch">' \
                   '<item>' \
                   '<p name="interferAveMeasPeriod">0dot1s</p>' \
                   '<p name="maxTargSinr">30</p>' \
                   '<p name="minTargSinr">-10</p>' \
                   '<p name="refPathloss">134</p>' \
                   '<p name="sinrAveMeasSamples">10</p>' \
                   '<p name="sinrThresholdIndex">triplet 1 (-2, 0, +1)</p>' \
                   '<p name="targetSinrOffset">0</p>' \
                   '<p name="tIntervalSinrUpd">100ms</p>' \
                   '<p name="tTpcPenalty">50</p>' \
                   '</item>' \
                   '</list>' \
                   '</managedObject>'

NRPGRP = '<managedObject class="com.nokia.srbts.nrbts:NRPGRP" ' \
         'distName="MRBTS-1/NRBTS-1/NRPGRP-0" version="NRBTSCL24R1_2318_101" operation="create">' \
         '<p name="lbpsCSONCtlEnabled">true</p>' \
         '<p name="lbpsLastCellMinLoad">0</p>' \
         '<p name="lbpsLastCellRTXMinLoad">0</p>' \
         '<p name="lbpsLastCellSOEnabled">true</p>' \
         '<p name="lbpsMaxLoad">60</p>' \
         '<p name="lbpsMinLoad">20</p>' \
         '<p name="lbpsMonWinForCellSOff">300</p>' \
         '<p name="lbpsMonWinForCellSOn">120</p>' \
         '<p name="lbpsPdcchLoadOffset">4</p>' \
         '<p name="lbpsRTXCellCapOffset">80</p>' \
         '<p name="lbpsRTXMaxLoad">60</p>' \
         '<p name="lbpsRTXMinLoad">20</p>' \
         '<p name="lbpsRTXSOffTime">30</p>' \
         '<p name="lbpsRTXSOnTime">30</p>' \
         '<p name="lbpsSOMethod">TX switch off</p>' \
         '<list name="lbpsCellList">' \
         '<item>' \
         '<p name="lbpsCellSOOrder">100</p>' \
         '<p name="lbpsUseExtConfig">false</p>' \
         '<p name="nrCellId">1</p>' \
         '</item>' \
         '</list>' \
         '<list name="lbpsPeriodList">' \
         '<item>' \
         '<p name="lbpsDayOfWeek">Wed</p>' \
         '<p name="lbpsDuration">1</p>' \
         '<p name="lbpsStartTimeHour">1</p>' \
         '<p name="lbpsStartTimeMinute">1</p>' \
         '<p name="lbpsSuspended">notSuspended</p>' \
         '</item>' \
         '</list>' \
         '</managedObject>'

LCSToGcsT_add = '<list name="lcsToGcsTranslate">' \
                '<item>' \
                '<p name="bearingAngle">0</p>' \
                '<p name="downtiltAngle">0</p>' \
                '<p name="slantAngle">0</p>' \
                '</item>' \
                '</list>'

subbandBm_add = '<list name="srsForSubbandBm">' \
                '<item>' \
                '<p name="actTasSrsForCriticalBandCombo">false</p>' \
                '<p name="bfSubbandSize">16 PRBs</p>' \
                '<p name="cbcTasConflictPolicy">CBC first</p>' \
                '<p name="dynamicSrsRmMode">mode0</p>' \
                '<p name="maxNumUeSrs">1</p>' \
                '<p name="srsPowerThreshold">-1150</p>' \
                '<p name="srsQualityThreshold">-1200</p>' \
                '<p name="srsSinrThreshold">-400</p>' \
                '<p name="srsUePeriodicityInput">slots80</p>' \
                '</item>' \
                '</list>'

wbSbSrsSwitch_add = '<list name="wbSbSrsSwitch">' \
                    '<item>' \
                    '<p name="channelStabilityHysteresis">10</p>' \
                    '<p name="channelStabilityThreshold">30</p>' \
                    '<p name="enableSbSrsVolatilityCheck">false</p>' \
                    '<p name="maxWbSbSwitch">10</p>' \
                    '<p name="numWbSrsConfigSample">10</p>' \
                    '<p name="numWbSrsReleaseSample">10</p>' \
                    '<p name="prbRatioHysteresis">15</p>' \
                    '<p name="prbRatioThreshold">20</p>' \
                    '<p name="prbSampleHighLowPercentage">60</p>' \
                    '<p name="rankHysteresis">1</p>' \
                    '<p name="rankThreshold">3</p>' \
                    '<p name="rlqBadPercentage">50</p>' \
                    '<p name="rlqGoodPercentage">20</p>' \
                    '<p name="seHysteresis">50</p>' \
                    '<p name="seThreshold">91</p>' \
                    '<p name="sortingMetric">DL Spectral Efficiency</p>' \
                    '<p name="wbSrsConfigProhibitTimer">100</p>' \
                    '<p name="wbSrsPowerHysteresis">50</p>' \
                    '<p name="wbSrsPowerThreshold">-1010</p>' \
                    '<p name="wbSrsReleaseProhibitTimer">1000</p>' \
                    '</item>' \
                    '</list>'
