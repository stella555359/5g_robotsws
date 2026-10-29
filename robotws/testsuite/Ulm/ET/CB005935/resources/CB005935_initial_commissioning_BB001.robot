*** Settings ***
Documentation    Scenario specific keywords for CB005935 of feature "Inter band FDD UL CA 2CCs"
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]
Enable some Functionality according to CFAM for BB001
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
        Set Element    dist_name=${dist_name}    p_name=actHighestEstNrTputBcSel           value=false
        Set Element    dist_name=${dist_name}    p_name=actLteNrDss                        value=false
        Set Element    dist_name=${dist_name}    p_name=actFdmScheduling                   value=true
        Set List       dist_name=${dist_name}    list_name=actMeasBasedSCellAdditionSa
        ${actMeasBasedSCellAdditionSa_list}=  create list   A1-based
        scf.add_elements_to_list    dist_name=${dist_name}   list_name=actMeasBasedSCellAdditionSa   elements=${actMeasBasedSCellAdditionSa_list}
        Set Element    dist_name=${dist_name}    p_name=actBcsCheck                        value=disabled
        Set Element    dist_name=${dist_name}    p_name=actOverheatingAssistance           value=true
        Set Element    dist_name=${dist_name}    p_name=timerOverheatIndProhibit           value=2s
        Set Element    dist_name=${dist_name}    p_name=timerPostOverheating               value=0
        Set Element    dist_name=${dist_name}    p_name=rrcReestabTypeSA                   value=sameGNB
        Set Element    dist_name=${dist_name}    p_name=actHoOptimizationCa                value=true

        Set Element    dist_name=${dist_name}    p_name=actInterFreqHoSA                   value=true
        Set Element    dist_name=${dist_name}    p_name=actIntraFreqHoSA                   value=true
        Set Element    dist_name=${dist_name}    p_name=actIntraNrNgHo                     value=basicTargetOnly
        Set Element    dist_name=${dist_name}    p_name=suppCnPartialAdNgHo                value=false
        Set Element    dist_name=${dist_name}    p_name=tNgRelocExecDeltN                  value=3000
        Set Element    dist_name=${dist_name}    p_name=timerXnDataFwdGuard                value=250
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
        Set Element    dist_name=${dist_name}    p_name=weightForSCellSelection            value=50
        Set Element    dist_name=${dist_name}    p_name=a1MeashoEnabledSA                  value=rsrp
        Set Element    dist_name=${dist_name}    p_name=a2MeashoEnabledSA                  value=rsrp
        Set Element    dist_name=${dist_name}    p_name=measGapSelectionSA                 value=favourUeThroughput
    #-------Configure A1 measurement based addition for all cells------------------------------------------------------------------------------------
        Set Element    dist_name=${dist_name}    p_name=a1MeasSCellAddEnabled              value=rsrp
        Set List       dist_name=${dist_name}    list_name=a1MeasSCellAddSsbRsrp
        ${a1MeasSCellAddSsbRsrp_item}=  create dictionary
        ...    a1HysteresisSCellAddSsbRsrp        0
        ...    a1ThresholdSCellAddSsbRsrpFDD      30
        ...    a1ThresholdSCellAddSsbRsrpTDD      15
        ...    a1TimeToTriggerSCellAddSsbRsrp     320ms
        scf.add_item_to_list    dist_name=${dist_name}   list_name=a1MeasSCellAddSsbRsrp   elements=${a1MeasSCellAddSsbRsrp_item}
    #-------Configure A1 a1MeashoSsbRsrpSA ----------------------------------------------------------------------------------------------------------
        Set List       dist_name=${dist_name}    list_name=a1MeashoSsbRsrpSA
        ${a1MeashoSsbRsrpSA_item}=  create dictionary
        ...    a1HysteresishoSsbRsrpSA        0
        ...    a1ThresholdhoSsbRsrpSA         60
        ...    a1TimeToTriggerhoSsbRsrpSA     ms480
        scf.add_item_to_list    dist_name=${dist_name}   list_name=a1MeashoSsbRsrpSA   elements=${a1MeashoSsbRsrpSA_item}
    #-------Configure A2 a2MeashoSsbRsrpSA ----------------------------------------------------------------------------------------------------------
        Set List       dist_name=${dist_name}    list_name=a2MeashoSsbRsrpSA
        ${a2MeashoSsbRsrpSA_item}=  create dictionary
        ...    a2HysteresishoSsbRsrpSA        0
        ...    a2ThresholdhoSsbRsrpSA         34
        ...    a2TimeToTriggerhoSsbRsrpSA     ms480
        scf.add_item_to_list    dist_name=${dist_name}   list_name=a2MeashoSsbRsrpSA   elements=${a2MeashoSsbRsrpSA_item}
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
Cfg CB005935 for FDD Cells for BB001
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
Cfg CB005935 for NRREL for PCell for BB001
    [Arguments]  ${sCellAdditionMethod}
    Adding NRREL    pcell_id=2    scell_id=3    dir=dlOnly     nrrel_id=3     sCellAdditionMethod=${sCellAdditionMethod}
    Adding NRREL    pcell_id=2    scell_id=6    dir=dlOnly     nrrel_id=4     sCellAdditionMethod=${sCellAdditionMethod}
    Adding NRREL    pcell_id=2    scell_id=5    dir=dlAndUl    nrrel_id=1     sCellAdditionMethod=${sCellAdditionMethod}
    Adding NRREL    pcell_id=2    scell_id=4    dir=dlOnly     nrrel_id=2     sCellAdditionMethod=${sCellAdditionMethod}
    Adding NRREL    pcell_id=4    scell_id=5    dir=dlAndUl    nrrel_id=1     sCellAdditionMethod=blind

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Cfg CB005935 NRHOIF for BB001
    Adding NRHOIF    pcell_id=4    freqBandIndicatorNR=66    ssbFrequency=431070    nrhoif_id=1
    Adding NRREL    pcell_id=4    scell_id=2    dir=dlAndUl    nrrel_id=2     sCellAdditionMethod=blind
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
