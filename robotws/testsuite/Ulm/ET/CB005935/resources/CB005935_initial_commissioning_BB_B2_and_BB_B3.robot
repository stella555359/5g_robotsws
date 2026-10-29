*** Settings ***
Documentation    Scenario specific keywords for CB005935 of feature "Inter band FDD UL CA 2CCs"
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]
Enable some Functionality according to CFAM for BB_B2_and_BB_B3
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
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR  ${dist_name}  IN  @{distName_NRDU}
        Set Element    dist_name=${dist_name}    p_name=dlToUlContributionRatio            value=50
        Set Element    dist_name=${dist_name}    p_name=actConnectedModeMobilityCA         value=true
        Set Element    dist_name=${dist_name}    p_name=flexibleCAMode                     value=ConfigurationIndependent
        Set List      dist_name=${dist_name}  list_name=carrierAggregationSupportList
        ${param_list}=    create list  ca_Fdd_Fdd_Sa_WithUl  ca_Fdd_Fdd  ca_Fr1Tdd_Any_Sa  ca_Fr1Tdd_Sa  ca_Fr1Tdd_Fdd_Sa
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
Cfg CB005935 for FDD Cells for BB_B2_and_BB_B3
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
Cfg CB005935 for NRREL for PCell for BB_B2_and_BB_B3
    [Arguments]  ${sCellAdditionMethod}
    Adding NRREL    pcell_id=4    scell_id=5    dir=dlAndUl    nrrel_id=1     sCellAdditionMethod=${sCellAdditionMethod}
    Log    Cfg CB005935 for NRREL for PCell for BB_B2_and_BB_B3

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
