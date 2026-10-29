*** Settings ***
Documentation    Scenario specific keywords for CB005935 of feature "Inter band FDD UL CA 2CCs"
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]
Enable some Functionality according to CFAM for C001
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distName_NRDU}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDU-[0-9]+
    ${distName_NRDRB_RLC_AM}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDRB_RLC_AM-[0-9]+
    sort list    ${distName_NRBTS}
    sort list    ${distName_NRCELL}
    sort list    ${distName_NRDU}
    sort list    ${distName_NRDRB_RLC_AM}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR  ${dist_name}  IN  @{distName_NRBTS}
        Set Element    dist_name=${dist_name}    p_name=sCellActivationMethod              value=bufferBased
        Set Element    dist_name=${dist_name}    p_name=actMultipleDedicatedBWPs           value=false
        Set Element    dist_name=${dist_name}    p_name=actHighestEstNrTputBcSel           value=true
        Set Element    dist_name=${dist_name}    p_name=actLteNrDss                        value=false
        Set Element    dist_name=${dist_name}    p_name=actFdmScheduling                   value=true
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        Set Element    dist_name=${dist_name}    p_name=sCellDeactivationTimerGNB          value=ms1280
        Set Element    dist_name=${dist_name}    p_name=sCellActivationMinDataThreshold    value=6000
        Set Element    dist_name=${dist_name}    p_name=sCellActivationLevelUL             value=1TTI
        Set Element    dist_name=${dist_name}    p_name=sCellActivationLevel               value=1TTI
        Set Element    dist_name=${dist_name}    p_name=pucchModeSelect                    value=longPucch
        Set Element    dist_name=${dist_name}    p_name=actIncreasedFdmUsersPerSlot        value=true
        Set Element    dist_name=${dist_name}    p_name=actUlClosedLoopPwrCtrl             value=disabled
        Set Element    dist_name=${dist_name}    p_name=actEnhMultipleDedicatedBWPs        value=false
        Set Element    dist_name=${dist_name}    p_name=actPowerSavingBWP                  value=false
        Set Element    dist_name=${dist_name}    p_name=actPRBBlanking                     value=false
        Set Element    dist_name=${dist_name}    p_name=actK1Opt                           value=intra-gNB
        Set Element    dist_name=${dist_name}    p_name=maxNumScellsDlFr1                  value=4
        Set Element    dist_name=${dist_name}    p_name=actGBRAdmissionControl             value=GBRService
        Set Element    dist_name=${dist_name}    p_name=actNonVoNRGbrService               value=true
        Set Element    dist_name=${dist_name}    p_name=actGbrRacTdEnhResourcePriority     value=false
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR  ${dist_name}  IN  @{distName_NRDU}
        Set Element    dist_name=${dist_name}    p_name=dlToUlContributionRatio            value=50
        Set Element    dist_name=${dist_name}    p_name=actConnectedModeMobilityCA         value=true
        Set Element    dist_name=${dist_name}    p_name=flexibleCAMode                     value=ConfigurationIndependent
        Set List      dist_name=${dist_name}  list_name=carrierAggregationSupportList
        ${param_list}=    create list  ca_Fdd_Fdd_Sa_WithUl  ca_Fdd_Fdd  ca_Fr1Tdd_Any_Sa  ca_Fr1Tdd_Sa  ca_Fr1Tdd_Fdd_Sa
        ...                            ca_Fdd_Any_Sa  ca_Fdd_Fr1Tdd_Sa
        scf.add_elements_to_list    dist_name=${dist_name}    list_name=carrierAggregationSupportList   elements=${param_list}
    END
    FOR  ${dist_name}  IN  @{distName_NRDRB_RLC_AM}
        Set Element    dist_name=${dist_name}    p_name=ulTReassemblyIBCA                  value=40
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRULCLPC_PROFILE_1}=  set variable  ${distName_NRBTS[0]}/NRULCLPC_PROFILE-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRULCLPC_PROFILE
    ...           dist_name=${distName_NRULCLPC_PROFILE_1}
    ...           version=NRBTSCL23R2_2302_100
    Set List      dist_name=${distName_NRULCLPC_PROFILE_1}  list_name=clpcPucch
    ${clpcPucch_item}=  create dictionary
    ...    sinrAveMeasSamples           10
    ...    sinrThresholdIndex           triplet 1 (-2, 0, +1)
    ...    targetSinr                   8
    ...    tIntervalSinrUpd             100ms
    ...    tTpcPenalty                  50
    scf.add_item_to_list    dist_name=${distName_NRULCLPC_PROFILE_1}   list_name=clpcPucch   elements=${clpcPucch_item}


    Set Object    class_name=com.nokia.srbts.nrbts:NRULCLPC_PROFILE
    ...           dist_name=${distName_NRULCLPC_PROFILE_1}
    ...           version=NRBTSCL23R2_2302_100
    Set List      dist_name=${distName_NRULCLPC_PROFILE_1}  list_name=clpcPusch
    ${clpcPusch_item}=  create dictionary
    ...    interferAveMeasPeriod        0dot1s
    ...    maxTargSinr                  30
    ...    minTargSinr                  -10
    ...    refPathloss                  134
    ...    sinrAveMeasSamples           10
    ...    sinrThresholdIndex           triplet 1 (-2, 0, +1)
    ...    targetSinrOffset             0
    ...    tIntervalSinrUpd             100ms
    ...    tTpcPenalty                  50
    scf.add_item_to_list    dist_name=${distName_NRULCLPC_PROFILE_1}   list_name=clpcPusch   elements=${clpcPusch_item}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Cfg CB005935 for FDD Cells for C001
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    Remove Values From List    ${distName_NRCELL}    MRBTS-1/NRBTS-1/NRCELL-3    MRBTS-1/NRBTS-1/NRCELL-6
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        Set Element    dist_name=${dist_name}    p_name=cellDepType                        value=SA
        Set Element    dist_name=${dist_name}    p_name=actCDrx                            value=false
        Set Element    dist_name=${dist_name}    p_name=timingAdvanceOffset                value=n25600
        Set Element    dist_name=${dist_name}    p_name=increaseK1ULCA                     value=K1 not increased
    END

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Cfg CB005935 for NRREL for PCell for C001
    [Arguments]  ${sCellAdditionMethod}
    Adding NRREL    pcell_id=4    scell_id=5    dir=dlAndUl    nrrel_id=1     sCellAdditionMethod=${sCellAdditionMethod}
    Log    Cfg CB005935 for NRREL for PCell for BB_B2_and_BB_B3

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Configure new NRDRB-16
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB16}=  Set variable  ${distName_NRBTS[0]}/NRDRB-16
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB
    ...           dist_name=${distName_NRDRB16}
    ...           version=NRBTSCL23R3_2305_100
    FOR    ${p_name}    ${value}    IN
    ...    actDddsReduction                  false
    ...    actLostPduFastRetx                false
    ...    caPduReSendingDelayMargin         2
    ...    discardTimer                      100ms
    ...    discardTimerUl                    100ms
    ...    dlAllowMinDelayLinkXxCalib        false
    ...    dlFlowControlAlgo                 3gppFlowControl
    ...    dscp                              26
    ...    durationThresDiscardDlMacSdu      40
    ...    durationThresDiscardDlPdcpPdu5GLeg     40
    ...    durationThresDiscardDlPdcpPduLteLeg    40
    ...    endMarkerTimer                    2000
    ...    l2OHFactorDl                      16
    ...    l2OHFactorUl                      35
    ...    maxDataRateGbrDl                  30720
    ...    maxDataRateGbrUl                  30720
    ...    maxDddsPeriodCpuOvld              40
    ...    maxRlcQueueingDelayGbr            20
    ...    maxTransferDelayGbr               20
    ...    nrDrbMacDN                        MRBTS-1/NRBTS-1/NRDRB_MAC-5
    ...    nrDrbPdcpDN                       MRBTS-1/NRBTS-1/NRDRB_PDCP-2
    ...    nrDrbRlcUmDN                      MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...    numSduDiscard                     1
    ...    queuingDelayDiscarding            Disabled
    ...    queuingDelaySduDiscardThreshold   750
    ...    queuingDelayDiscardStart          5
    ...    resType                           GBR
    ...    rlcMode                           RLC_UM
    ...    rlcPduDelayThCa                   30
    ...    schedulWeight                     1
    ...    sduDiscardIntervalTmr             500
    ...    volThresDiscardDlMacSdu           8000
    ...    volThresDiscardDlPdcpPdu5GLeg     8000
    ...    volThresDiscardDlPdcpPduLteLeg    8000
    ...    actDlTxResumeOnPdcpStatRep        false
    ...    durationThresDiscardDl            40
    ...    durationThresDiscardUl            20
    ...    volThresDiscardDl                 8000
    ...    volThresDiscardUl                 800
    ...    actOptDataFlowRateEst             false
    ...    allowedPdcchPowerBoostALDueCce    none
    ...    allowedPdcchPowerBoostALDueCfg    None
    ...    nrDrxDN                           MRBTS-1/NRBTS-1/NRDRX-2
    ...    maxForwardTimeLimitXx             50
    ...    minForwardTputXx                  100
    ...    srsStaticUeDoublePeriodicity      false
        Set Element   dist_name=${distName_NRDRB16}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName_NRDRB16}  list_name=cellAggrLevel
    ${param_list}=    create list    Not FR1 CA eligible
    scf.add_elements_to_list    dist_name=${distName_NRDRB16}    list_name=cellAggrLevel    elements=${param_list}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Configure new 5QI-7 and set it to 2 and connect it to NRDRB-16
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
	${distName_NRDRB5QI7}=  Set variable  ${distName_NRBTS[0]}/NRDRB_5QI-7
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_5QI
    ...           dist_name=${distName_NRDRB5QI7}
    ...           version=NRBTSCL23R3_2305_100
    Set Element   dist_name=${distName_NRDRB5QI7}  p_name=nrDrbDN                           value=MRBTS-1/NRBTS-1/NRDRB-16
    Set List      dist_name=${distName_NRDRB5QI7}  list_name=fiveqiValueList
    ${param_list}=    create list  2
    scf.add_elements_to_list  dist_name=${distName_NRDRB5QI7}  list_name=fiveqiValueList   elements=${param_list}
    Set Element   dist_name=${distName_NRDRB5QI7}    p_name=dataForwarding    value=IRATDataFwd

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Configure new MAC-5
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
	${distName_NRDRBMAC5}=  Set variable  ${distName_NRBTS[0]}/NRDRB_MAC-5
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_MAC
    ...           dist_name=${distName_NRDRBMAC5}
    ...           version=NRBTSCL23R3_2305_100
    FOR    ${p_name}    ${value}    IN
    ...    delayTarget                       150
    ...    lcgid                             5
    ...    prioritisedBitRate                16kBps
    ...    schedulBSD                        100ms
    ...    schedulPrio                       7
        Set Element   dist_name=${distName_NRDRBMAC5}    p_name=${p_name}    value=${value}
    END

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
