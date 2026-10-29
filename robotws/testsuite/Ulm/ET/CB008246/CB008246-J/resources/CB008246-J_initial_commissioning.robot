*** Settings ***
Documentation       Scenario specific keywords for subfeature CB008246-J of "LA for HR DRBs"
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***
#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Change Reporting Interval for CB008246
    [Arguments]    ${interval_duration}
    @{distName_NRPMRNL}=    Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=    create list
    ...    miNrCellAvailability
    ...    miNrCellUtilization
    ...    miNrTimingAdvance
    ...    miNrUlSignalQuality
    ...    miNrDlHarq
    ...    miNrUlHarq
    ...    miNrDlHarqLowSEMCS
    ...    miNrUlHarqLowSEMCS
    ...    miNrSignalQualityLowSEMCS
    ...    miNrPdcch
    ...    miNrResourceUtilizationPerCell
    # for later usage: miNrPdcch2
    FOR    ${pname}    IN    @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}    dist_name=${distName_NRPMRNL[0]}    p_name=${pname}
    END
    @{distName_PMCADM}=    Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element
    ...    value=${interval_duration}
    ...    dist_name=${distName_PMCADM[0]}
    ...    p_name=reportingIntervalPm

Enable and disable some Functionality according to CFAM
    @{distName_NRCELL}=    Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRCELL[0]}    actDl256Qam    true
    ...    ${distName_NRCELL[0]}    actUl256Qam    true
    ...    ${distName_NRCELL[0]}    actDlMuMimo    false

    ...    ${distName_NRCELL[2]}    actDl256Qam    true
    ...    ${distName_NRCELL[2]}    actUl256Qam    true
    ...    ${distName_NRCELL[2]}    actDlMuMimo    false

        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END


    #    NRBTS.actGeneralConnectivityBronze    = true -> SCF from UTE has already value set to "none"
    #    NRBTS/NRDU/carrierAggregationSupportList    = none -> SCF from UTE has already value set to "none"
    #    MRBTS/NRBTS/NRCELL/ulPowerControlCommon    all set to default values -> already set to default values

Activate CB008246
    @{distName_NRBTS}=    Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    @{distName_NRCELL}=    Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN


    ...    ${distName_NRBTS[0]}    actMultiDrbNSA    true
    ...    ${distName_NRCELL[0]}    actLAForHiReliab    true
    ...    ${distName_NRCELL[0]}    actCceSplit    false
    ...    ${distName_NRCELL[0]}    scalingStepdownHREnabled    true
    ...    ${distName_NRCELL[0]}    dlMcsDowngradeForHr    disabled
    ...    ${distName_NRCELL[0]}    ulMcsDowngradeForHr    disabled
    ...    ${distName_NRCELL[0]}    actUlPtrs    true
    ...    ${distName_NRCELL[0]}    actDlMuMimo    false
    ...    ${distName_NRCELL[0]}    ulTransPrecodePi2Bpsk    true


    ...    ${distName_NRCELL[2]}    actLAForHiReliab    true
    ...    ${distName_NRCELL[2]}    actCceSplit    false
    ...    ${distName_NRCELL[2]}    scalingStepdownHREnabled    true
    ...    ${distName_NRCELL[2]}    dlMcsDowngradeForHr    disabled
    ...    ${distName_NRCELL[2]}    ulMcsDowngradeForHr    disabled
    ...    ${distName_NRCELL[2]}    actUlPtrs  true
    ...    ${distName_NRCELL[2]}    actDlMuMimo  false
    ...    ${distName_NRCELL[2]}    ulTransPrecodePi2Bpsk  true

        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    ${cellBwpList_item1}=  create dictionary
    ...    actPdcchCceFragmentControl   false
    ...    actUpperThrAckNackFiltering  true
    ...    actUpperThrAckNackHrFiltering  true
    ...    bwpDN                        MRBTS-1/NRBTS-1/BWP_PROFILE-0
    ...    cellBwpId                    0
    ...    pdcchResourcePreference      peakRate

    ${cellBwpList_item2}=  create dictionary
    ...    actPdcchCceFragmentControl   false
    ...    actUpperThrAckNackFiltering  true
    ...    actUpperThrAckNackHrFiltering  true
    ...    bwpDN            MRBTS-1/NRBTS-1/BWP_PROFILE-44
    ...    cellBwpId        1
    ...    pdcchResourcePreference     peakRate

    Set List      dist_name=${distName_NRCELL[0]}  list_name=cellBwpList
    scf.add_item_to_list    dist_name=${distName_NRCELL[0]}   list_name=cellBwpList   elements=${cellBwpList_item1}
    scf.add_item_to_list    dist_name=${distName_NRCELL[0]}   list_name=cellBwpList   elements=${cellBwpList_item2}

    ${cellBwpList_item3}=  create dictionary
    ...    actPdcchCceFragmentControl   false
    ...    actUpperThrAckNackFiltering  true
    ...    actUpperThrAckNackHrFiltering  true
    ...    bwpDN                        MRBTS-1/NRBTS-1/BWP_PROFILE-4
    ...    cellBwpId                    0
    ...    pdcchResourcePreference      peakRate

    ${cellBwpList_item4}=  create dictionary
    ...    actPdcchCceFragmentControl   false
    ...    actUpperThrAckNackFiltering  true
    ...    actUpperThrAckNackHrFiltering  true
    ...    bwpDN            MRBTS-1/NRBTS-1/BWP_PROFILE-33
    ...    cellBwpId        1
    ...    pdcchResourcePreference     peakRate
    Set List      dist_name=${distName_NRCELL[2]}  list_name=cellBwpList
    scf.add_item_to_list    dist_name=${distName_NRCELL[2]}   list_name=cellBwpList   elements=${cellBwpList_item3}
    scf.add_item_to_list    dist_name=${distName_NRCELL[2]}   list_name=cellBwpList   elements=${cellBwpList_item4}

    # default values
    ${dlDataDmrsFdm_item}=  create dictionary
    ...    actDlDataDmrsFdm                 true
    ...    dlDataDmrsFdmThres256QamMcs      27
    ...    dlDataDmrsFdmThres64QamLowSEMcs  20
    ...    dlDataDmrsFdmThres64QamMcs       28
    ...    redCap1RxUesEnabled              false
    ...    thres256QamMcsRedCap1Rx          20

    ${ulDataDmrsFdm_item}=  create dictionary
    ...    actUlDataDmrsFdm                 true
    ...    ulDataDmrsFdmThres256QamMcs      27
    ...    ulDataDmrsFdmThres64QamLowSEMcs  20
    ...    ulDataDmrsFdmThres64QamMcs       28

    FOR    ${cell_id}    IN    0    2
        Set List      dist_name=${distName_NRCELL[${cell_id}]}  list_name=dlDataDmrsFdm
        Set List      dist_name=${distName_NRCELL[${cell_id}]}  list_name=ulDataDmrsFdm
        scf.add_item_to_list    dist_name=${distName_NRCELL[${cell_id}]}   list_name=dlDataDmrsFdm   elements=${dlDataDmrsFdm_item}
        scf.add_item_to_list    dist_name=${distName_NRCELL[${cell_id}]}   list_name=ulDataDmrsFdm   elements=${ulDataDmrsFdm_item}
    END

    Configure CB008246 on PDSCH
    Configure CB008246 on PUSCH
    Configure CB008246 on PDCCH

Configure CB008246 on PDSCH
    @{distName_NRBTS}=    Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    @{distName_NRCELL}=    Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRCELL[0]}    list_name=pdschHrLaConfig
    Set List    dist_name=${distName_NRCELL[2]}    list_name=pdschHrLaConfig

    #all with default values
    &{pdschHrLaConfig_item}=    create dictionary
    ...    dllaCqiOffsetHR                     0
    ...    dllaDeltaCqiMaxHR                 150
    ...    dllaDeltaCqiMinHR                -150
    ...    dllaDeltaCqiStepdownHR           2000
    ...    dllaIniDeltaCqiHR                 -30
    ...    dllaIniMcsHR                        3
    ...    dllaMcsMax64qamLowSERANK1HR        28
    ...    dllaMcsMax64qamLowSERANK2HR        28
    ...    dllaMcsMax64qamLowSERANK3HR        28
    ...    dllaMcsMax64qamLowSERANK4HR        28
    ...    dllaMcsMax64qamRANK1HR             28
    ...    dllaMcsMax64qamRANK2HR             28
    ...    dllaMcsMax64qamRANK3HR             28
    ...    dllaMcsMax64qamRANK4HR             28
    scf.add_item_to_list
    ...    dist_name=${distName_NRCELL[0]}
    ...    list_name=pdschHrLaConfig
    ...    elements=${pdschHrLaConfig_item}
    scf.add_item_to_list
    ...    dist_name=${distName_NRCELL[2]}
    ...    list_name=pdschHrLaConfig
    ...    elements=${pdschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRPDSCHHRLA_1}=    set variable    ${distName_NRBTS[0]}/NRPDSCHHRLA-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRPDSCHHRLA
    ...    dist_name=${distName_NRPDSCHHRLA_1}
    ...    version=NRBTSCL23R2_2302_100

    #all with default values
    FOR    ${p_name}    ${value}    IN
    ...    dlHRBlerOutageMcsThresh64qam                1
    ...    dlHRBlerOutageMcsThresh64qamLowSE           2
    ...    dlHRBlerOutagePercentage                   50
    ...    dlHRBlerOutagePeriod                       10    #not default
    ...    dlHRBlerRecoverMcsThresh64qam               5
    ...    dlHRBlerRecoverMcsThresh64qamLowSE         11
    ...    dlHRBlerRecoverPercentage                  60
    ...    dlHRBlerRecoverPeriod                      15    #not default
    ...    dllaBlerTargetHR    ${xlaBlerTarget_internal}
    ...    scalFactorForHRGbrDl                      110
        Set Element    dist_name=${distName_NRPDSCHHRLA_1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${dist_name}    ${value}    IN
    ...    ${distName_NRBTS[0]}/NRDRB-12    ${distName_NRBTS[0]}/NRPDSCHHRLA-1
        Set Element    dist_name=${dist_name}    p_name=nrPdschHRLaDN    value=${value}
    END

Configure CB008246 on PUSCH
    @{distName_NRBTS}=    Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    @{distName_NRCELL}=    Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRCELL[0]}    list_name=puschHrLaConfig
    Set List    dist_name=${distName_NRCELL[2]}    list_name=puschHrLaConfig

    #all with default values
    &{puschHrLaConfig_item}=    create dictionary
    ...    iniDeltaSinrHR                        -50
    ...    ullaDeltaSinrMaxHR                    150
    ...    ullaDeltaSinrMinHR                   -300
    ...    ullaDeltaSinrStepdownHR              2000
    ...    ullaIniMcsHR                            0
    ...    ullaMcsMax64qamLowSERANK1HR            28
    ...    ullaMcsMax64qamLowSERANK2HR            28
    ...    ullaMcsMax64qamRANK1HR                 28
    ...    ullaMcsMax64qamRANK2HR                 28
    ...    ullaSinrOffsetHR                       0

    scf.add_item_to_list
    ...    dist_name=${distName_NRCELL[0]}
    ...    list_name=puschHrLaConfig
    ...    elements=${puschHrLaConfig_item}
    scf.add_item_to_list
    ...    dist_name=${distName_NRCELL[2]}
    ...    list_name=puschHrLaConfig
    ...    elements=${puschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRPUSCHHRLA_1}=    set variable    ${distName_NRBTS[0]}/NRPUSCHHRLA-1
        Set Object    class_name=com.nokia.srbts.nrbts:NRPUSCHHRLA
    ...    dist_name=${distName_NRPUSCHHRLA_1}
    ...    version=NRBTSCL23R2_2302_100

    #all with default values
    FOR    ${p_name}    ${value}    IN
    ...    ulHRBlerOutagePercentage                    50
    ...    ulHRBlerOutagePeriod                        10    #not default
    ...    ulHRBlerOutageTbsThresh                   3000    #not default
    ...    ulHRBlerOutageTbsThresh64qam              3000    #not default
    ...    ulHRBlerRecoverPercentage                   60
    ...    ulHRBlerRecoverPeriod                       15    #not default
    ...    ulHRBlerRecoverTbsThresh                 15000    #not default
    ...    ulHRBlerRecoverTbsThresh64qam             7000
    ...    ullaBlerTargetHR     ${xlaBlerTarget_internal}
    ...    scalFactorForHRGbrUl                       110
        Set Element    dist_name=${distName_NRPUSCHHRLA_1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${dist_name}    ${value}    IN
    ...    ${distName_NRBTS[0]}/NRDRB-12    ${distName_NRBTS[0]}/NRPUSCHHRLA-1
        Set Element    dist_name=${dist_name}    p_name=nrPuschHRLaDN    value=${value}
    END

Configure CB008246 on PDCCH
    @{distName_NRBTS}=    Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    sort list    ${distName_NRBTS}
    ${distName_NRPDCCHHRLA_1}=    set variable    ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRPDCCHHRLA
    ...    dist_name=${distName_NRPDCCHHRLA_1}
    ...    version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    pdcchHRBlerOutagePercentage        50
    ...    pdcchHRBlerOutagePeriod            10    #not default
    ...    pdcchHRBlerRecoverPercentage       60
        Set Element    dist_name=${distName_NRPDCCHHRLA_1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${dist_name}    ${value}    IN
    ...    ${distName_NRBTS[0]}/NRDRB-12    ${distName_NRBTS[0]}/NRPDCCHHRLA-1
        Set Element    dist_name=${dist_name}    p_name=nrPdcchHRLaDN    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]


Configure SCF File for subfeature CB008246-B
    Configure BWP_PDCCH
    Configure BWP_PDCCH_CONFIG_DEDICATED FDD
    Configure BWP_PDCCH_CONFIG_DEDICATED TDD


Configure BWP_PDCCH
    @{distName_PDCCH_Init}=     gnb.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{1}/PDCCH-[0-9]+
    @{distName_PDCCH_Dedicated}=    gnb.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}/PDCCH-[0-9]+
    # Initial BWP_PROFILE with ID < 10
    FOR    ${dist_name}    IN    @{distName_PDCCH_Init}
        Set Element     dist_name=${dist_name}      p_name=dciDedicatedAggregationLevelHR      value=AL4
    END

    # Dedicated BWP_PROFILE with ID >= 10
    FOR    ${dist_name}    IN    @{distName_PDCCH_Dedicated}
        Set Element     dist_name=${dist_name}      p_name=alSelection      value=dynamic
        Set Element     dist_name=${dist_name}      p_name=dciDedicatedAggregationLevelHR      value=AL4

        Set List      dist_name=${dist_name}  list_name=dynamicAggregationLevelHRSet
        &{dynamicAggregationLevelHRSet_item}=  create dictionary
        ...    aggregationLevelListHR    AL1_AL2_AL4_AL8
        ...    cqiCorrectionUpHR         2
        ...    cqiDciCssAl1HR            106
        ...    cqiDciCssAl2HR            74
        ...    cqiDciCssAl4HR            45
        ...    cqiDciCssAl8HR            37
        ...    cqiDciCssAl16HR           0
        ...    highOlcCqiOffsetHR        50
        ...    lowOlcCqiOffsetHR         1100
        ...    pCqiErasureActTimerHR     160
        ...    pCqiErasureReductionHR    10
        ...    pdcchCqiOffsetHR          10
        scf.add_item_to_list
        ...    dist_name=${dist_name}   list_name=dynamicAggregationLevelHRSet   elements=${dynamicAggregationLevelHRSet_item}

        Set List      dist_name=${dist_name}  list_name=dynamicAggregationLevelSet
        &{dynamicAggregationLevelSet_item}=  create dictionary
        ...    aggregationLevelList    AL1_AL2
        ...    cqiCorrectionUp         8
        ...    cqiDciCssAl1            101
        ...    cqiDciCssAl2            69
        ...    cqiDciCssAl4            33
        ...    cqiDciCssAl8            10
        ...    cqiDciCssAl16           0
        ...    highOlcCqiOffset        100
        ...    lowOlcCqiOffset         1100
        ...    pCqiErasureActTimer     160
        ...    pCqiErasureReduction    10

        scf.add_item_to_list
        ...    dist_name=${dist_name}   list_name=dynamicAggregationLevelSet   elements=${dynamicAggregationLevelSet_item}
    END


Configure BWP_PDCCH_CONFIG_DEDICATED TDD
    @{distName_PDCCH_CONFIG_DEDICATED}=
    ...     gnb.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-44/PDCCH-[0-9]+/PDCCH_CONFIG_DEDICATED-[0-9]+

    Set List   dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}   list_name=searchSpaceDedicated

    &{searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_0_1
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n1
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n1
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl1
    ...      searchSpaceId                7
    ...      searchSpaceType              Type3
    ...      slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}

    &{searchSpaceDedicated_item2}=  create dictionary
    ...      coresetId                    1
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_0_1
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n1
    ...      numOfPdcchCandidatesInAL4    n3
    ...      numOfPdcchCandidatesInAL8    n1
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl1
    ...      searchSpaceId                8
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Configure BWP_PDCCH_CONFIG_DEDICATED FDD
    @{distName_PDCCH_CONFIG_DEDICATED}=
    ...     gnb.Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-33/PDCCH-[0-9]+/PDCCH_CONFIG_DEDICATED-[0-9]+

    Set List   dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}   list_name=coresetDedicated

    &{coresetDedicated_item}=  Create Dictionary
    ...      cceToRegMapping              interleaved
    ...      coresetId                    1
    ...      cRbStart                     0
    ...      duration                     1
    ...      interleaverSize              n3
    ...      regBundleSize                n2
    ...      size                         96
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=coresetDedicated  elements=${coresetDedicated_item}

    Set List   dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}   list_name=searchSpaceDedicated

    &{searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                    1
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_0
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n2
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n2
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl1
    ...      searchSpaceId                7
    ...      searchSpaceType              Type3
    ...      slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}

    &{searchSpaceDedicated_item2}=  create dictionary
    ...      coresetId                    1
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_0
    ...      numOfPdcchCandidatesInAL1    n2
    ...      numOfPdcchCandidatesInAL2    n2
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n2
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl1
    ...      searchSpaceId                8
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}

    &{searchSpaceDedicated_item3}=  create dictionary
    ...      coresetId                    1
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_1
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n1
    ...      numOfPdcchCandidatesInAL4    n1
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl1
    ...      searchSpaceId                9
    ...      searchSpaceType              Type3
    ...      slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item3}

    &{searchSpaceDedicated_item4}=  create dictionary
    ...      coresetId                    1
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_1
    ...      numOfPdcchCandidatesInAL1    n1
    ...      numOfPdcchCandidatesInAL2    n1
    ...      numOfPdcchCandidatesInAL4    n1
    ...      numOfPdcchCandidatesInAL8    n1
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl1
    ...      searchSpaceId                10
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item4}

    &{searchSpaceDedicated_item5}=  create dictionary
    ...      coresetId                    1
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     19
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n1
    ...      numOfPdcchCandidatesInAL4    n1
    ...      numOfPdcchCandidatesInAL8    n1
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl20
    ...      searchSpaceId                11
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   1
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item5}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
