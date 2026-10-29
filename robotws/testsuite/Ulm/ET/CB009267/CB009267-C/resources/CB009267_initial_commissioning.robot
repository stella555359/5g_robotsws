*** Settings ***
Documentation    Commissioning keywords for CB009267: common changes
...
...    "2TDD+2FDD Setup" == CLOUD_5G_I_LO_AP_LO + VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
...    ---------------------------------------------------------------------------------------------
...    cell_1 | n78 | TDD | 100MHz | 7880 | 636666        | NSA or SA | ---+
...    cell_2 | n78 | TDD | 100MHz | 7880 | 636666        | NSA or SA |   \|/  --F+T
...    cell_3 | n71 | FDD |  20MHz | 1582 | 126380/135760 | NSA or SA | --T+F    /|\
...    cell_4 | n71 | FDD |  20MHz | 1582 | 126380/135760 | NSA or SA |        ---+
...
...    "4TDD in FR2 Setup" == CLOUD_5G_I_LO_AP_LO + VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD
...    -----------------------------------------------------------------------------
...    cell_1 | n257 | TDD | 100MHz | 22446 | 2071675 | NSA or SA | ---+ PCell
...    cell_2 | n257 | TDD | 100MHz | 22426 | 2065705 | NSA or SA | ---+ SCell
...    cell_3 | n257 | TDD | 100MHz | 22458 | 2075003 | NSA or SA | ---+ SCell
...    cell_4 | n257 | TDD | 100MHz | 22464 | 2076667 | NSA or SA | ---+ SCell



*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Modify SCF for 4TDD for SA FR2 Setup
    Activate CA in NRBTS in FR2 for SA


Modify SCF for 4TDD for NSA FR2 Setup
    Activate CA in NRBTS in FR2 for NSA
    Activate CA in NRCELL in FR2 for NSA             pcell_id=3
    Activate CA in NRCELL in FR2 for NSA on SCell    scell_id=4
    Add NRREL    pcell_id=1    scell_id=2    dir=dlAndUl    nrrel_id=1
    Add NRREL    pcell_id=3    scell_id=4    dir=dlAndUl    nrrel_id=1


Modify SCF for 2TDD+2FDD for ${ue_type} FR1 Setup
    log to console    Modify SCF for 2TDD+2FDD for ${ue_type} FR1 Setup: started
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${increasePUSCHPrepTimeULCA} =    set variable if    '${ue_type}' == 'SA'    true       false
    ${sCellOperationalMode} =         set variable if    '${ue_type}' == 'SA'    dlAndUl    dlOnly
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 actCarAgPmCount                      true
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRBTS[0]}                 actCarrierAggregation                true
    ...    ${distName_NRBTS[0]}                 caConfigurationSupport               2CCDL_2CCUL
    ...    ${distName_NRBTS[0]}                 sCellActivationMethod                bufferAndRLQualityBased
    ...    ${distName_NRBTS[0]}                 actOverheatingAssistance             true
    ...    ${distName_NRBTS[0]}                 timerOverheatIndProhibit             1s
    ...    ${distName_NRBTS[0]}                 timerPostOverheating                 0
    ...    ${distName_NRBTS[0]}                 caBackoffTimerUeOh                   60
    ...    ${distName_NRBTS[0]}                 mcsDeactSCellDl                      3
    ...    ${distName_NRBTS[0]}                 mcsDeactSCellUl                      3
    ...    ${distName_NRBTS[0]}                 pathlossDeltaActSCellDl              3
    ...    ${distName_NRBTS[0]}                 pathlossDeltaActSCellUl              3
    ...    ${distName_NRBTS[0]}                 maxNumScellsDl                       1
    ...    ${distName_NRBTS[0]}                 maxNumScellsUl                       1
    ...    ${distName_NRBTS[0]}                 actLteNrDss                          false
    ...    ${distName_NRBTS[0]}                 actFdmScheduling                     true
    ...    ${distName_NRBTS[0]}                 actMultipleDedicatedBWPs             false
    ...    ${distName_NRBTS[0]}                 actTddPrePooling                     false
    ...    ${distName_NRBTS[0]}                 actHighestEstNrTputBcSel             true
    ...    ${distName_NRBTS[0]}                 actSlowPrbPooling                    true
    ...    ${distName_NRBTS[0]}                 actConnRrcPooling                    true
    ...    ${distName_NRBTS[0]}                 actScheUePooling                     true
    ...    ${distName_NRCELL[1]}                increasePUSCHPrepTimeULCA            ${increasePUSCHPrepTimeULCA}

        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${NRCELL}    IN    @{distName_NRCELL}
        Configure each Cell for CA in FR1     ${NRCELL}
    END
    Add NRREL    pcell_id=1    scell_id=3    dir=${sCellOperationalMode}    nrrel_id=1
    Add NRREL    pcell_id=4    scell_id=2    dir=${sCellOperationalMode}    nrrel_id=1
    IF    '${ue_type}' == 'SA'     Activate CA In NRDU For SA FR1
    ...    ELSE IF    '${ue_type}' == 'NSA'    Activate CA in NRDU for NSA FR1
    Activate CA in NRDRB_RLC_AM
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    log to console    Modify SCF for 2TDD+2FDD for ${ue_type} FR1 Setup: finished


Modify SCF for PUSCH Slot Aggregation
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 actCarAgPmCount                      true
    ...    ${distName_NRCELL[0]}                actVoNR                              true
    ...    ${distName_NRCELL[1]}                actVoNR                              true
    ...    ${distName_NRCELL[2]}                actVoNR                              true
    ...    ${distName_NRCELL[3]}                actVoNR                              true
    ...    ${distName_NRCELL[3]}                actDrxSleepOff                       Enabled_VoNr_SAg
    ...    ${distName_NRCELL[3]}                actEnhancedVoNR                      true
    ...    ${distName_NRCELL[3]}                actUlDftSOfdm                        true
    ...    ${distName_NRCELL[3]}                actUlSlotAgg                         Enabled_VoNr
    ...    ${distName_NRCELL[3]}                maxHarqBundlesUlSlotAgg              10
    ...    ${distName_NRCELL[3]}                minTbsUlSlotAgg                      384
    ...    ${distName_NRCELL[3]}                sCellDeactInPoorRf                   Deact_Scells_VoNr_SAg
    ...    ${distName_NRBTS[0]}                 actSaUeBasedAnrEutra                 false
    ...    ${distName_NRBTS[0]}                 actSaUeBasedAnrNr                    false
    ...    ${distName_NRCELL[0]}                actDlLaDynBlerTarget                 false
    ...    ${distName_NRCELL[1]}                actDlLaDynBlerTarget                 false
    ...    ${distName_NRCELL[2]}                actDlLaDynBlerTarget                 false
    ...    ${distName_NRCELL[3]}                actDlLaDynBlerTarget                 false
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRCELL[3]}  list_name=ulTransPrecodeCtl
    ${ulTransPrecodeCtl_item}=  create dictionary
    ...    ulSlotAggOffTotPwrThresh             15
    ...    ulSlotAggOnTotPwrThresh              12
    ...    ulTransPrecodeOffSinrThresh          35
    ...    ulTransPrecodeOffSinrThrRedCap       35
    ...    ulTransPrecodeOnSinrThresh           15
    ...    ulTransPrecodeOnSinrThrRedCap        15
    ...    ulTransPrecodePi2Bpsk                true
    ...    ulTransPrePi2BpskPwrBoost            false
    scf.add_item_to_list    dist_name=${distName_NRCELL[3]}   list_name=ulTransPrecodeCtl   elements=${ulTransPrecodeCtl_item}


Configure each Cell for CA in FR1
    [Arguments]  ${distName}
    FOR    ${p_name}                    ${value}         IN
    ...    actK1Opt                     intra-gNB
    ...    sCellDeactivationTimerGNB    infinity
    ...    pMaxNROwnCell                20
    ...    pucchModeSelect              longPucch
    ...    lteNrDssMode                 none
    ...    actCDrx                      true
    ...    actUlClosedLoopPwrCtrl       disabled
    ...    actEnhMultipleDedicatedBWPs  false
    ...    actPowerSavingBWP            false
    ...    timingAdvanceOffset          n25600
        Set Element    dist_name=${distName}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName}  list_name=allowUnsuppBcOrBcs
    ${param_list}=    create list  accept unknown band combinations
    scf.add_elements_to_list  dist_name=${distName}  list_name=allowUnsuppBcOrBcs   elements=${param_list}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate CA in NRBTS in FR2 for SA
    ${distName_NRBTS}=     Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                    ${value}         IN
    ...    sCellActivationMethod        bufferAndRLQualityBased
    ...    mcsDeactSCellDl              3
    ...    mcsDeactSCellUl              3
    ...    pathlossDeltaActSCellDl      3
    ...    pathlossDeltaActSCellUl      3
        Set Element    dist_name=${distName_NRBTS[0]}    p_name=${p_name}    value=${value}
    END


Activate CA in NRBTS in FR2 for NSA
    ${distName_NRBTS}=     Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                    ${value}         IN
    ...    sCellActivationMethod        bufferAndRLQualityBased
    ...    mcsDeactSCellDl              3
    ...    mcsDeactSCellUl              3
    ...    pathlossDeltaActSCellDl      3
    ...    pathlossDeltaActSCellUl      3
    ...    maxNumScellsDl               2
    ...    maxNumScellsUl               1
        Set Element    dist_name=${distName_NRBTS[0]}    p_name=${p_name}    value=${value}
    END


Activate CA in NRCELL in FR2 for SA
    [Arguments]  ${pcell_id}
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                    ${value}         IN
    ...    maxNumOf2CCUsersFr2SA        10
    ...    maxNumOf3To4CCUsersFr2SA     10
    ...    maxNumOf5To8CCUsersFr2Sa     10
    ...    actK1Opt                     intra-gNB
    ...    sCellDeactivationTimerGNB    infinity
    ...    pMaxNROwnCell                20
    ...    pucchModeSelect              longPucch
    ...    lteNrDssMode                 none
    ...    actCDrx                      false
    ...    actUlClosedLoopPwrCtrl       disabled
    ...    actEnhMultipleDedicatedBWPs  false
    ...    actPowerSavingBWP            false
    ...    timingAdvanceOffset          n13792
        Set Element    dist_name=${distName_NRCELL[${pcell_id}-1]}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRCELL[${pcell_id}-1]}  list_name=dtxOptimizedScheduler
    ${dtxOptimizedScheduler_item}=  create dictionary
    ...    caSupportEnabled                true
    ...    drbDifferentiationEnabled       false
    ...    drxSupportEnabled               false
    ...    dtxDelaySinceLastScheduling     0
    ...    dtxMaxRetentionDelay            50
    ...    dtxPrbThreshold                 100
    ...    multiCellSyncEnabled            false
    ...    rlcStatusPduSupportEnabled      false
    scf.add_item_to_list    dist_name=${distName_NRCELL[${pcell_id}-1]}   list_name=dtxOptimizedScheduler   elements=${dtxOptimizedScheduler_item}


Activate CA in NRCELL in FR2 for NSA
    [Arguments]  ${pcell_id}
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                    ${value}         IN
    ...    sCellDeactivationTimerGNB    infinity
    ...    timingAdvanceOffset          n13792
    ...    actCDrx                      false
        Set Element    dist_name=${distName_NRCELL[${pcell_id}-1]}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRCELL[${pcell_id}-1]}  list_name=dtxOptimizedScheduler
    ${dtxOptimizedScheduler_item}=  create dictionary
    ...    caSupportEnabled                true
    ...    drbDifferentiationEnabled       false
    ...    drxSupportEnabled               false
    ...    dtxDelaySinceLastScheduling     0
    ...    dtxMaxRetentionDelay            50
    ...    dtxPrbThreshold                 100
    ...    multiCellSyncEnabled            false
    ...    rlcStatusPduSupportEnabled      false
    scf.add_item_to_list    dist_name=${distName_NRCELL[${pcell_id}-1]}   list_name=dtxOptimizedScheduler   elements=${dtxOptimizedScheduler_item}


Activate CA in NRCELL in FR2 for NSA on SCell
    [Arguments]  ${scell_id}
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                    ${value}         IN
    ...    sCellDeactivationTimerGNB    infinity
    ...    timingAdvanceOffset          n13792
    ...    actCDrx                      false
        Set Element    dist_name=${distName_NRCELL[${scell_id}-1]}    p_name=${p_name}    value=${value}
    END


Add NRREL
    [Arguments]  ${pcell_id}  ${scell_id}  ${dir}  ${nrrel_id}
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRREL}=  Set variable  ${distName_NRCELL[${pcell_id}-1]}/NRREL-${nrrel_id}
    Set Object    class_name=com.nokia.srbts.nrbts:NRREL
    ...           dist_name=${distName_NRREL}
    ...           version=NRBTSCL23R4_2312_101
    FOR    ${p_name}                                         ${value}    IN
    ...    cellIndividualSsbRsrpOffset                       0dB
    ...    cellIndividualSsbRsrqOffset                       0dB
    ...    gNbId                                             1
    ...    gNbIdLength                                       22
    ...    handoverAllowedSA                                 allowed
    ...    handoverAllowedSARedCap                           forbidden
    ...    isRplCellForPSCell                                false
    ...    lcrId                                             ${scell_id}
    ...    nrDcAllowed                                       false
    ...    removeNotAllowed                                  false
    ...    sCellAdditionMethod                               blind
    ...    sCellOperationalMode                              ${dir}
        Set Element    dist_name=${distName_NRREL}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRREL}  list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              311
    ...    mnc              489
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${distName_NRREL}   list_name=gnbPlmn   elements=${gnbPlmn_item}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate CA in NRDU for SA FR1
    ${distName_NRDU}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDU-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=${distName_NRDU[0]}    p_name=fr1UlCaPreferred                    value=ulCaPreferred
    Set Element    dist_name=${distName_NRDU[0]}    p_name=flexibleCAMode                      value=NumberCellAmount
    Set Element    dist_name=${distName_NRDU[0]}    p_name=dlToUlContributionRatio             value=50
    Set Element    dist_name=${distName_NRDU[0]}    p_name=actInterNumerologyCa                value=true
    Set Element    dist_name=${distName_NRDU[0]}    p_name=actConnectedModeMobilityCA          value=true
    Set List      dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList
    ${param_list}=    create list
    ...    ca_Fdd_Fr1Tdd_Sa_WithUl   ca_Fdd_Fr1Tdd_Sa
    ...    ca_Fr1Tdd_Fdd_Sa_WithUl   ca_Fr1Tdd_Fdd_Sa
    scf.add_elements_to_list    dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList   elements=${param_list}


Activate CA in NRDU for NSA FR1
    ${distName_NRDU}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDU-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=${distName_NRDU[0]}    p_name=flexibleCAMode                      value=NumberCellAmount
    Set Element    dist_name=${distName_NRDU[0]}    p_name=dlToUlContributionRatio             value=50
    Set Element    dist_name=${distName_NRDU[0]}    p_name=actInterNumerologyCa                value=true
    Set Element    dist_name=${distName_NRDU[0]}    p_name=actConnectedModeMobilityCA          value=true
    Set List      dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList
    ${param_list}=    create list    ca_Fdd_Fr1Tdd_Nsa  ca_Fr1Tdd_Nsa  ca_Fr1Tdd_Fdd_Nsa
    scf.add_elements_to_list    dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList   elements=${param_list}


Activate CA in NRDRB_RLC_AM
    ${distName_RLC_AM}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDRB_RLC_AM-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=${distName_RLC_AM[0]}    p_name=ulTReassemblyIBCA     value=40
    Set Element    dist_name=${distName_RLC_AM[1]}    p_name=ulTReassemblyIBCA     value=40
    Set Element    dist_name=${distName_RLC_AM[0]}    p_name=dlTReassemblyIBCA     value=40
    Set Element    dist_name=${distName_RLC_AM[1]}    p_name=dlTReassemblyIBCA     value=40


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
