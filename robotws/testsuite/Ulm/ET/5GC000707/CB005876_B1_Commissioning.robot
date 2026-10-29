*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for CB005876_B1 commissioning

Library     taf.config.scf        WITH NAME    scf
Library     taf.gnb.oam.commissioning    WITH NAME    commission

Resource          ../resources/SQD65/sqd65_keywords.robot
Resource    ../resources/SQD65/sqd65_commissioning.robot

*** Variables ***
&{drxProfile1}=
...                              drxOnDurationTimer=10ms
...                              drxInactivityTimer=40ms
...                              drxRetransTimerDl=16slot
...                              drxRetransTimerUl=16slot
...                              drxLongCycle=40ms
...                              drxHarqRttTimerDl=0symbols
...                              drxHarqRttTimerUl=0symbols

${NIDD_VERSION}                  NRBTSCL5G21B_2104_100

*** Keywords ***

Activate CB005876 B1
    ${SW_BRANCH}=    testline.Get gNB SW Branch
    Set Suite Variable  ${SW_BRANCH}
    ${config_dir}=    Get test suite config directory
    scf.load_scf    ${P_ORIG_SCF}
    Add NRDRB15 to SCF
    Add NRDRB16 to SCF
    Add NRDRB5QI6 to SCF
    Add NRDRB5QI7 to SCF
    Add NRDRBRMAC3 to SCF
    Add NRDRBRMAC4 to SCF
    Add NRDRBPDCP3 to SCF
    Add NRDRBPDCP4 to SCF
    Add NRDRBRLCUM1 to SCF
    Add NRDRBRLCUM2 to SCF
    Add NRHOIR to SCF
    Update Params in NRCELL
    Add NRADJECELL to SCF
    Add NRRELE to SCF
    Update Params in NRBTS
    # setting discardTimer to max value for QoS 1 so that PDCP SDUs are discarded due to bearer release
    scf.modify_scf_element        dist_name=NRBTS-1/NRDRB-15     p_name=discardTimer    value=1500ms
    #Additional mandatory NIDD Parameters added
    scf.modify_scf_element        dist_name=NRBTS-1/NRDRB-10     p_name=resType    value=nonGBR
    scf.modify_scf_element        dist_name=MRBTS-1/NRBTS-1/NRDRB_MAC-4     p_name=lcgid    value=1
    Disable GBRService            ## GMC change: d938d36b4bccc407c537912db29a1ac12b2f257d

    scf.save_scf                  ${config_dir}/scf_5876.xml
    ${scf_params}=                Existing Parameter List to be updated
    commission.modify_scf         input_scf=${config_dir}/scf_5876.xml    output_scf=${config_dir}/scf_5876.xml    parameters_lists=${scf_params}
    Execute full commissioning    ${config_dir}/scf_5876.xml


Add NRDRB15 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB-15
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}                          ${value}      IN
    ...   actDddsReduction                   false
    ...   discardTimer                       1500ms
    ...   dlFlowControlAlg                   none
    ...   dscp                               46
    ...   maxDddsPeriodCpuOvld               40
    ...   nrDrbMacDN                         MRBTS-1/NRBTS-1/NRDRB_MAC-3
    ...   nrDrbPdcpDN                        MRBTS-1/NRBTS-1/NRDRB_PDCP-3
    ...   nrDrbRlcUmDN                       MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...   numSduDiscard                      1
    ...   queuingDelaySduDiscardThreshold    200
    ...   queuingDelayDiscarding             Disabled
    ...   queuingDelayDiscardStart           5
    ...   resType                            GBR
    ...   rlcMode                            RLC_UM
    ...   schedulWeight                      1
    ...   sduDiscardIntervalTmr              100
    ...   durationThresDiscard               50
    ...   volThresDiscard                    100
    ...   actLostPduFastRetx                 false
    ...   maxRlcQueueingDelayGbr             20
    ...   maxTransferDelayGbr                20
    ...   endMarkerTimer                     2000
    ...   dlAllowMinDelayLinkX2Calib         false
    ...   caPduReSendingDelayMargin          2
    ...   rlcPduDelayThCa                    30
          scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=cellAggrLevel
    ${param_list}=    create list    Not FR1 CA eligible
    scf.add_elements_to_list    dist_name=${dist_name}    list_name=cellAggrLevel    elements=${param_list}

    IF  '${SW_BRANCH}' > 'SBTS25R2' or '${SW_BRANCH}' == 'SBTS00'
        Set Element               dist_name=${dist_name}   p_name=srsStaticUeDoublePeriodicity      value=false
    END

Add NRDRB16 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB-16
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}                             ${value}      IN
    ...   discardTimer                          infinity
    ...   actDddsReduction                      false
    ...   dlFlowControlAlgo                     none
    ...   dscp                                  46
    ...   maxDddsPeriodCpuOvld                  40
    ...   nrDrbMacDN                            MRBTS-1/NRBTS-1/NRDRB_MAC-4
    ...   nrDrbPdcpDN                           MRBTS-1/NRBTS-1/NRDRB_PDCP-4
    ...   nrDrbRlcUmDN                          MRBTS-1/NRBTS-1/NRDRB_RLC_UM-2
    ...   numSduDiscard                         1
    ...   queuingDelaySduDiscardThreshold       200
    ...   queuingDelayDiscarding                Disabled
    ...   queuingDelayDiscardStart              5
    ...   resType                               nonGBR
    ...   rlcMode                               RLC_UM
    ...   schedulWeight                         1
    ...   sduDiscardIntervalTmr                 100
    ...   actLostPduFastRetx                    false
    ...   maxRlcQueueingDelayGbr                20
    ...   maxTransferDelayGbr                   20
    ...   endMarkerTimer                        2000
    ...   dlAllowMinDelayLinkXxCalib            false
    ...   actDlTxResumeOnPdcpStatRep            false
    ...   durationThresDiscardDl                40
    ...   durationThresDiscardUl                20
    ...   volThresDiscardDl                     8000
    ...   volThresDiscardUl                     800
    ...   caPduReSendingDelayMargin             2
    ...   rlcPduDelayThCa                       30
    ...   durationThresDiscardDlMacSdu          40
    ...   durationThresDiscardDlPdcpPdu5GLeg    40
    ...   durationThresDiscardDlPdcpPduLteLeg   40
    ...   volThresDiscardDlMacSdu               8000
    ...   volThresDiscardDlPdcpPdu5GLeg         8000
    ...   volThresDiscardDlPdcpPduLteLeg        8000
    ...   actOptDataFlowRateEst                 false
    ...   maxForwardTimeLimitX2                 50
    ...   minForwardTputX2                      100
    ...   nrDrxDN                               MRBTS-1/NRBTS-1/NRDRX-1
          scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=cellAggrLevel
    ${param_list}=    create list    Not FR1 CA eligible
    scf.add_elements_to_list    dist_name=${dist_name}  list_name=cellAggrLevel  elements=${param_list}

    IF   '${SW_BRANCH}' != 'SBTS24R3'
        Set Element               dist_name=${dist_name}   p_name=allowedPdcchPowerBoostALDueCce    value=none
        Set Element               dist_name=${dist_name}   p_name=allowedPdcchPowerBoostALDueCfg    value=None
    END
    IF  '${SW_BRANCH}' > 'SBTS25R2' or '${SW_BRANCH}' == 'SBTS00'
        Set Element               dist_name=${dist_name}   p_name=srsStaticUeDoublePeriodicity      value=false
    END

Add NRDRB5QI1 to SCF
    ${dist_name}=             Set Variable              NRBTS-1/NRDRB_5QI-1
    Set Object                NRDRB_5QI                 ${dist_name}

    ${param_list}=            Create List  5
    Set New List              ${dist_name}              fiveqiValueList
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=fiveqiValueList   elements=${param_list}
    Set Element               dist_name=${dist_name}    p_name=nrDrbDN              value=MRBTS-1/NRBTS-1/NRDRB-10
    Set Element               dist_name=${dist_name}    p_name=dataForwarding       value=IRATDataFwd

Add NRDRB5QI2 to SCF
    ${dist_name}=             Set Variable              NRBTS-1/NRDRB_5QI-2
    Set Object                NRDRB_5QI                 ${dist_name}

    ${param_list}=            Create List  6
    Set New List              dist_name=${dist_name}    list_name=fiveqiValueList
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=fiveqiValueList   elements=${param_list}
    Set Element               dist_name=${dist_name}    p_name=nrDrbDN              value=MRBTS-1/NRBTS-1/NRDRB-11
    Set Element               dist_name=${dist_name}    p_name=dataForwarding       value=IRATDataFwd

Add NRDRB5QI6 to SCF
    ${dist_name}=             Set Variable              NRBTS-1/NRDRB_5QI-6
    Set Object                NRDRB_5QI                 ${dist_name}

    ${param_list}=            Create List  1
    Set New List              dist_name=${dist_name}    list_name=fiveqiValueList
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=fiveqiValueList   elements=${param_list}
    Set Element               dist_name=${dist_name}    p_name=nrDrbDN              value=MRBTS-1/NRBTS-1/NRDRB-15

    # CB013289: USCB013289-A#B2: Successful Inter-Rat handover with indirect data forwarding (AS#1)
    Set Element               dist_name=${dist_name}    p_name=dataForwarding       value=noIRATDataFwd
    IF   'SBTS24R3' == '${sw_branch}'
    ...                       Set Element               dist_name=${dist_name}      p_name=dataForwarding    value=IRATDataFwd

Add NRDRB5QI7 to SCF
    ${dist_name}=             Set Variable              NRBTS-1/NRDRB_5QI-7
    Set Object                NRDRB_5QI                 ${dist_name}

    ${param_list}=            Create List  128
    Set New List              dist_name=${dist_name}    list_name=fiveqiValueList
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=fiveqiValueList   elements=${param_list}
    Set Element               dist_name=${dist_name}    p_name=nrDrbDN              value=MRBTS-1/NRBTS-1/NRDRB-16

    # CB013289: USCB013289-A#B2: Successful Inter-Rat handover with indirect data forwarding (AS#1)
    Set Element               dist_name=${dist_name}    p_name=dataForwarding       value=noIRATDataFwd
    IF   'SBTS24R3' == '${sw_branch}'
    ...                       Set Element               dist_name=${dist_name}      p_name=dataForwarding    value=IRATDataFwd

Add NRDRBRMAC3 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_MAC-3
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB_MAC    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}              ${value}      IN
    ...   lcgid                  4
    ...   schedulPrio            4
    ...   prioritisedBitRate     16kBps
          scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add NRDRBRMAC4 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_MAC-4
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB_MAC    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}              ${value}      IN
    ...   lcgid                  1
    ...   schedulPrio            5
    ...   prioritisedBitRate     16kBps
              scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add NRDRBPDCP3 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_PDCP-3
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB_PDCP    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}                  ${value}      IN
    ...   cuFlowControlProfId        1
    ...   pdcpBufDiscardEnabled      false
    ...   pdcpBufDiscardThreshold    20000
    ...   tReorderingDl              ms300
    ...   tReorderingUl              ms300
    ...   pdcpDelayThreshRetxMode    disabled
          scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add NRDRBPDCP4 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_PDCP-4
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB_PDCP    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}                  ${value}      IN
    ...   cuFlowControlProfId        1
    ...   pdcpBufDiscardEnabled      false
    ...   pdcpBufDiscardThreshold    20000
    ...   tReorderingDl              ms300
    ...   tReorderingUl              ms300
    ...   pdcpDelayThreshRetxMode    disabled
          scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add NRDRBRLCUM1 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_RLC_UM-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB_RLC_UM    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}              ${value}      IN
    ...   dlTReassemblyUm        ms20
    ...   rlcUMDrbSNLength       rlcUm12bitSN
    ...   ulTReassemblyUm        ms20
          scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add NRDRBRLCUM2 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_RLC_UM-2
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB_RLC_UM    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}              ${value}      IN
    ...   dlTReassemblyUm        ms20
    ...   rlcUMDrbSNLength       rlcUm12bitSN
    ...   ulTReassemblyUm        ms20
          scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add NRHOIR to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRHOIR-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRHOIR    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}                  ${value}      IN
    ...   allowedMeasBandwidth       mbw50
    ...   b2MeashoEnabled            rsrq
    ...   b2Threshold1hoRsrp         35
    ...   b2Threshold1hoRsrpVoNr     35
    ...   b2Threshold1hoRsrq         50
    ...   b2Threshold1hoRsrqVoNr     50
    ...   b1MeasRedirectEnabled      none
    ...   earfcnValue                1
    ...   eutraFreqQOffsetRange      0dB
    ...   presenceAntennaPort1       false
    ...   reportAmount               r8
    ...   reportInterval             ms240
    ...   widebandRsrqMeas           false
          scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf    dist_name=${dist_name}    list_name=eutraB2MeashoRsrp
    ${b2MeasRsrp_dict}   Create dictionary  b2HysteresishoRsrp  0  b2HysteresishoRsrpVoNr  0  b2Threshold2hoRsrp  18
    ...   b2Threshold2hoRsrpVoNr  18  b2TimeToTriggerhoRsrp  ms480  b2TimeToTriggerhoRsrpVoNr  ms480
    scf.add_item_to_list   dist_name=${dist_name}   list_name=eutraB2MeashoRsrp   elements=${b2MeasRsrp_dict}
    scf.add_list_to_scf    dist_name=${dist_name}    list_name=eutraB2MeashoRsrq
    ${b2MeasRsrq_dict}   Create dictionary  b2HysteresishoRsrq  0  b2HysteresishoRsrqVoNr  0  b2Threshold2hoRsrq  2
    ...   b2Threshold2hoRsrqVoNr  2  b2TimeToTriggerhoRsrq  ms480  b2TimeToTriggerhoRsrqVoNr  ms480
    scf.add_item_to_list   dist_name=${dist_name}   list_name=eutraB2MeashoRsrq   elements=${b2MeasRsrq_dict}


Update Params in NRCELL
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-1
    Set Element    dist_name=${dist_name}    p_name=absThreshSsbRsrpConsolidation   value=0
    Set Element    dist_name=${dist_name}    p_name=measGapSelectionSA              value=favourUeThroughput
    Set Element    dist_name=${dist_name}    p_name=sMeasConfigSsbRsrp              value=0
    Set New List              dist_name=${dist_name}    list_name=drxProfile1
    scf.add_item_to_list   dist_name=${dist_name}   list_name=drxProfile1   elements=${drxProfile1}
    Set New List              dist_name=${dist_name}    list_name=a1MeashoSsbRsrpSA
    ${a1Meas_dict}   Create dictionary  a1HysteresishoSsbRsrpSA  0  a1ThresholdhoSsbRsrpSA  39  a1TimeToTriggerhoSsbRsrpSA  ms480
    scf.add_item_to_list   dist_name=${dist_name}   list_name=a1MeashoSsbRsrpSA   elements=${a1Meas_dict}
    Set New List              dist_name=${dist_name}    list_name=a2MeashoSsbRsrpSA
    ${a2Meas_dict}   Create dictionary  a2HysteresishoSsbRsrpSA  0  a2HysteresisHoSsbRsrpVoNr  0  a2ThresholdhoSsbRsrpSA  36
    ...   a2ThresholdHoSsbRsrpVoNr  36  a2TimeToTriggerhoSsbRsrpSA  ms480  a2TimeToTriggerHoSsbRsrpVoNr  ms480
    scf.add_item_to_list   dist_name=${dist_name}   list_name=a2MeashoSsbRsrpSA   elements=${a2Meas_dict}
    Set New List              dist_name=${dist_name}    list_name=a3MeasSsbRsrp
    ${a3Meas_dict}   Create dictionary  a3HysteresisSsbRsrp  0  a3OffsetSsbRsrp  30  a3TimeToTriggerSsbRsrp  ms480
    scf.add_item_to_list   dist_name=${dist_name}   list_name=a3MeasSsbRsrp   elements=${a3Meas_dict}
    Set New List              dist_name=${dist_name}    list_name=nrhoirDNList
    ${param_list}=    Create List  MRBTS-1/NRBTS-1/NRHOIR-1
    scf.add_elements_to_list  dist_name=${dist_name}  list_name=nrhoirDNList   elements=${param_list}


Add NRADJECELL to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRADJECELL-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRADJECELL    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}              ${value}      IN
    ...   eNodeBId               18
    ...   ePSTrackingAreaCode    222
    ...   earfcnValue            1
    ...   lcrId                  1
    ...   physCellId             11
    ...   iRatDataForwardingMethod  indirectDataFwd
          scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf    dist_name=${dist_name}    list_name=eUtraMultibandInfoList
    scf.add_elements_to_list  dist_name=${dist_name}  list_name=eUtraMultibandInfoList   elements=1
    scf.add_list_to_scf    dist_name=${dist_name}    list_name=ecgiPlmn
    ${ecgiPlmn_dict}   Create dictionary  mcc  311  mnc  489  mncLength  3
    scf.add_item_to_list   dist_name=${dist_name}   list_name=ecgiPlmn   elements=${ecgiPlmn_dict}
    scf.add_list_to_scf    dist_name=${dist_name}    list_name=enbPlmn
    ${enbPlmn_dict}   Create dictionary  mcc  311  mnc  489  mncLength  3
    scf.add_item_to_list   dist_name=${dist_name}   list_name=enbPlmn   elements=${enbPlmn_dict}


Add NRRELE to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-1/NRRELE-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRRELE    dist_name=${dist_name}    version=NRBTSCL5G21B_2104_100
    FOR   ${p_name}               ${value}      IN
    ...   cellIndividualOffset    0dB
    ...   eNodeBId                18
    ...   removeNotAllowed        false
    ...   eutranCellExcluded      false
    ...   lcrId                   1
          scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.add_list_to_scf    dist_name=${dist_name}    list_name=ecgiPlmn
    ${ecgiPlmn_dict}   Create dictionary  mcc  311  mnc  489  mncLength  3
    scf.add_item_to_list   dist_name=${dist_name}   list_name=ecgiPlmn   elements=${ecgiPlmn_dict}


Update Params in NRBTS
    ${dist_name}=    Set Variable    NRBTS-1
    FOR   ${p_name}                     ${value}      IN
    ...   excludedEutranCellPeriod      10
    ...   excludedEutranCellThreshold   5
    ...   excludedEutranCellTimeWindow  10
        Set Element     dist_name=${dist_name}  p_name=${p_name}    value=${value}
    END

Existing Parameter List to be updated
    ${param2}=  create dictionary  value=true  dist_name=NRBTS-1  p_name=actInterRatHoSA
    ${param3}=  create dictionary  value=true  dist_name=NRBTS-1  p_name=actMFBIEutra
    ${param4}=  create dictionary  value=600  dist_name=NRBTS-1  p_name=srbInactivityTimerSA
    ${param5}=  create dictionary  value=5   dist_name=NRBTS-1/NRCELL-1  p_name=arpPrioEmergencyCall
    ${param6}=  create dictionary  value=rsrp   dist_name=NRBTS-1/NRCELL-1  p_name=a1MeashoEnabledSA
    ${param7}=  create dictionary  value=rsrp   dist_name=NRBTS-1/NRCELL-1  p_name=a2MeashoEnabledSA
    ${param8}=  create dictionary  value=rsrp   dist_name=NRBTS-1/NRCELL-1  p_name=a3MeasEnabled
    ${param9}=  create dictionary  value=Automatic   dist_name=NRBTS-1/NRCELL-1  p_name=openLoopScheme
    ${param10}=  create dictionary  value=40  dist_name=NRBTS-1/NRDRB-10  p_name=dscp
    ${param11}=  create dictionary  value=50   dist_name=NRBTS-1/NRDRB-10  p_name=queuingDelaySduDiscardThreshold
    ${param12}=  create dictionary  value=100   dist_name=NRBTS-1/NRDRB-10  p_name=sduDiscardIntervalTmr
    ${param13}=  create dictionary  value=ms0   dist_name=NRBTS-1/NRDRB_RLC_AM-2  p_name=ulTReassembly
    ${param14}=  create dictionary  value=200  dist_name=NRBTS-1/TRACKINGAREA-200  p_name=fiveGsTac
    # below parameters are CB005876 B1 specific
    ${param15}=  create dictionary  value=true  dist_name=NRBTS-1  p_name=actInterRatHoSADlDataForward
    ${param16}=  create dictionary  value=5000  dist_name=NRBTS-1  p_name=tNgRelocOverall
    ${param17}=  create dictionary  value=5min  dist_name=NRBTS-1/NRPMRNL-1  p_name=miNrNRPFW
    ${param18}=  create dictionary  value=true   dist_name=NRBTS-1/NRCELL-1  p_name=actVoNR
    ${param_list}=  Create list  ${param2}  ${param3}  ${param4}  ${param5}  ${param6}  ${param7}  ${param8}  ${param9}  ${param10}
    ...   ${param11}  ${param12}  ${param13}   ${param14}  ${param15}  ${param16}  ${param17}  ${param18}
    RETURN    ${param_list}

Disable GBRService
    Set Element     dist_name=NRBTS-1/NRCELL-1  p_name=actGBRAdmissionControl    value=off
    Set Element     dist_name=NRBTS-1/NRCELL-1  p_name=actLowGbrNumHandlingEnh   value=false
    Set Element     dist_name=NRBTS-1/NRCELL-1  p_name=actNonVoNRGbrService      value=false
