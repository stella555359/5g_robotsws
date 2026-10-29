*** Settings ***
Documentation    Scenario specific keywords for subfeature CB008246-G of "LA for HR DRBs"

Library     Collections
Library     taf.config.scf
Library     ../../../L2/libraries/tools.py

Resource    ../../../../resources/Common/gnb.robot
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Change Reporting Interval for CB008246
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality
    ...                                 miNrDlHarq  miNrUlHarq
    ...                                 miNrDlHarqLowSEMCS  miNrUlHarqLowSEMCS  miNrSignalQualityLowSEMCS
    ...                                 miNrPdcch  miNrResourceUtilizationPerCell
    # for later usage: miNrPdcch2
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm


Setting Of XlDataDmrsFdm
    ${distName_NRCELL}=   gnb.Get DistNames From Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    Collections.Sort List    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    tools.Set List        dist_name=${distName_NRCELL[${NRCELL_ID}]}      list_name=ulDataDmrsFdm
    ${ulDataDmrsFdm}=  Create Dictionary
    ...    ulDataDmrsFdmThres64QamLowSEMcs      20
    scf.Add Item To List    dist_name=${distName_NRCELL[${NRCELL_ID}]}   list_name=ulDataDmrsFdm   elements=${ulDataDmrsFdm}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    tools.Set List        dist_name=${distName_NRCELL[${NRCELL_ID}]}      list_name=dlDataDmrsFdm
    ${dlDataDmrsFdm}=  Create Dictionary
    ...    dlDataDmrsFdmThres64QamLowSEMcs      20
    scf.Add Item To List    dist_name=${distName_NRCELL[${NRCELL_ID}]}   list_name=dlDataDmrsFdm   elements=${dlDataDmrsFdm}


Activate 5GC002271
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                            ${value}    IN
    ...    actAdaptiveSr                            true
    ...    adaptiveSrBlockingMinimization             20
    ...    adaptiveSrLoadThresholdDown                50
    ...    adaptiveSrLoadThresholdUp                  80
    ...    srPeriodicityMin                      slots40
    ...    vonrReservation                             0
        Set Element   dist_name=${distName_NRCELL[${NRCELL_ID}]}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                            ${value}    IN
    ...    actUlTxSkip                             false
    ...    payloadSizeProactiveTxSkip                 80
    ...    ulProGrantTimerTxSkip                    1200
    ...    ulSchedTimeIntervalTxSkip                 150
        Set Element   dist_name=${distName_NRCELL[${NRCELL_ID}]}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                            ${value}    IN
    ...    actProactUlScheduling                    true
    ...    payloadSizeProactiveDrx                    64
    ...    payloadSizeProactiveNonDrx                 16
        Set Element   dist_name=${distName_NRCELL[${NRCELL_ID}]}    p_name=${p_name}    value=${value}
    END


Activate CB008246
    [Arguments]    ${dllaBlerTargetHR_1}=5    ${dllaBlerTargetHR_2}=10    ${NRPDSCHHRLA_1_5QI6}="NRPDSCHHRLA-1"
    ...    ${NRPDSCHHRLA_2_5QI2}="NRPDSCHHRLA-1"    ${NRPDSCHHRLA_3_5QI3}="NRPDSCHHRLA-1"
    ...    ${NRPDSCHHRLA_4_5QI9}="NRPDSCHHRLA-2"    ${NRPDSCHHRLA_5_5QI7}="NRPDSCHHRLA-2"
    ...    ${NRPDSCHHRLA_6_5QI71}="NRPDSCHHRLA-2"
    ...    ${NRPDSCHHRLA_7_5QI80}="NRPDSCHHRLA-2"
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    Set Element    dist_name=${distName_NRBTS[0]}     p_name=actMultiDrbNSA              value=true
    Set Element    dist_name=${distName_NRCELL[${NRCELL_ID}]}    p_name=actLAForHiReliab            value=true
    Set Element    dist_name=${distName_NRCELL[${NRCELL_ID}]}    p_name=actCceSplit                 value=false
    Set Element    dist_name=${distName_NRCELL[${NRCELL_ID}]}    p_name=dlMcsDowngradeForHr         value=disabled
    Set Element    dist_name=${distName_NRCELL[${NRCELL_ID}]}    p_name=ulMcsDowngradeForHr         value=disabled
    Setting Of XlDataDmrsFdm
    Configure CB008246 on PDSCH   ${dllaBlerTargetHR_1}   ${dllaBlerTargetHR_2}   ${NRPDSCHHRLA_1_5QI6}
    ...   ${NRPDSCHHRLA_2_5QI2}   ${NRPDSCHHRLA_3_5QI3}
    ...   ${NRPDSCHHRLA_4_5QI9}   ${NRPDSCHHRLA_5_5QI7}   ${NRPDSCHHRLA_6_5QI71}   ${NRPDSCHHRLA_7_5QI80}
    Configure CB008246 On PUSCH
    Configure CB008246 on PDCCH


Configure CB008246 on PDSCH
    [Arguments]    ${dllaBlerTargetHR_1}    ${dllaBlerTargetHR_2}    ${NRPDSCHHRLA_1_5QI6}    ${NRPDSCHHRLA_2_5QI2}    ${NRPDSCHHRLA_3_5QI3}
    ...    ${NRPDSCHHRLA_4_5QI9}    ${NRPDSCHHRLA_5_5QI7}    ${NRPDSCHHRLA_6_5QI71}    ${NRPDSCHHRLA_7_5QI80}
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List      dist_name=${distName_NRCELL[${NRCELL_ID}]}  list_name=pdschHrLaConfig
    ${pdschHrLaConfig_item}=  create dictionary
    ...    dllaCqiOffsetHR                  0
    ...    dllaDeltaCqiMaxHR              150
    ...    dllaDeltaCqiMinHR             -150
    ...    dllaDeltaCqiStepdownHR         500
    ...    dllaIniDeltaCqiHR              -30
    ...    dllaIniMcsHR                     3
    ...    dllaMcsMax64qamLowSERANK1HR     25
    ...    dllaMcsMax64qamLowSERANK2HR     25
    ...    dllaMcsMax64qamLowSERANK3HR     20
    ...    dllaMcsMax64qamLowSERANK4HR     20
    ...    dllaMcsMax64qamRANK1HR          25
    ...    dllaMcsMax64qamRANK2HR          25
    ...    dllaMcsMax64qamRANK3HR          20
    ...    dllaMcsMax64qamRANK4HR          20
    scf.add_item_to_list    dist_name=${distName_NRCELL[${NRCELL_ID}]}   list_name=pdschHrLaConfig   elements=${pdschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${dist_name}                    ${value}   IN
    ...   ${distName_NRBTS[0]}/NRDRB-11   ${distName_NRBTS[0]}/${NRPDSCHHRLA_1_5QI6}
    ...   ${distName_NRBTS[0]}/NRDRB-16   ${distName_NRBTS[0]}/${NRPDSCHHRLA_2_5QI2}
    ...   ${distName_NRBTS[0]}/NRDRB-17   ${distName_NRBTS[0]}/${NRPDSCHHRLA_3_5QI3}
    ...   ${distName_NRBTS[0]}/NRDRB-14   ${distName_NRBTS[0]}/${NRPDSCHHRLA_4_5QI9}
    ...   ${distName_NRBTS[0]}/NRDRB-12   ${distName_NRBTS[0]}/${NRPDSCHHRLA_5_5QI7}
    ...   ${distName_NRBTS[0]}/NRDRB-18   ${distName_NRBTS[0]}/${NRPDSCHHRLA_6_5QI71}
    ...   ${distName_NRBTS[0]}/NRDRB-19   ${distName_NRBTS[0]}/${NRPDSCHHRLA_7_5QI80}
          Set Element   dist_name=${dist_name}   p_name=nrPdschHRLaDN   value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRPDSCHHRLA_1}=  set variable  ${distName_NRBTS[0]}/NRPDSCHHRLA-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRPDSCHHRLA
    ...           dist_name=${distName_NRPDSCHHRLA_1}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    dlHRBlerOutageMcsThresh64qamLowSE       2
    ...    dlHRBlerOutagePercentage                50
    ...    dlHRBlerOutagePeriod                    20
    ...    dlHRBlerRecoverMcsThresh64qamLowSE      11
    ...    dlHRBlerRecoverPercentage               60
    ...    dlHRBlerRecoverPeriod                   30
    ...    dllaBlerTargetHR                        ${dllaBlerTargetHR_1}
    ...    dlHRBlerOutageMcsThresh64qam            1
    ...    dlHRBlerRecoverMcsThresh64qam           5
    ...    scalFactorForHRGbrDl                    110
        Set Element   dist_name=${distName_NRPDSCHHRLA_1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRPDSCHHRLA_2}=  set variable  ${distName_NRBTS[0]}/NRPDSCHHRLA-2
    Set Object    class_name=com.nokia.srbts.nrbts:NRPDSCHHRLA
    ...           dist_name=${distName_NRPDSCHHRLA_2}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    dlHRBlerOutageMcsThresh64qamLowSE       2
    ...    dlHRBlerOutagePercentage                50
    ...    dlHRBlerOutagePeriod                    20
    ...    dlHRBlerRecoverMcsThresh64qamLowSE      11
    ...    dlHRBlerRecoverPercentage               60
    ...    dlHRBlerRecoverPeriod                   30
    ...    dllaBlerTargetHR                        ${dllaBlerTargetHR_2}
    ...    dlHRBlerOutageMcsThresh64qam            1
    ...    dlHRBlerRecoverMcsThresh64qam           5
    ...    scalFactorForHRGbrDl                    110
        Set Element   dist_name=${distName_NRPDSCHHRLA_2}    p_name=${p_name}    value=${value}
    END


Configure CB008246 On PUSCH
    ${distName_NRBTS}=    gnb.Get DistNames From Local SCF File  scf_path=${ORIGINAL_GNB_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   gnb.Get DistNames From Local SCF File  scf_path=${ORIGINAL_GNB_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    Collections.Sort List    ${distName_NRCELL}

    tools.Set List      dist_name=${distName_NRCELL[${NRCELL_ID}]}  list_name=puschHrLaConfig
    ${puschHrLaConfig_item}=  Create Dictionary
    ...    iniDeltaSinrHR                   -50
    ...    ullaDeltaSinrMaxHR               150
    ...    ullaDeltaSinrMinHR               -300
    ...    ullaDeltaSinrStepdownHR          2000
    ...    ullaIniMcsHR                     0
    ...    ullaMcsMax64qamLowSERANK1HR      28
    ...    ullaMcsMax64qamLowSERANK2HR      28
    ...    ullaMcsMax64qamRANK1HR           28
    ...    ullaMcsMax64qamRANK2HR           28
    ...    ullaSinrOffsetHR                 0
    scf.Add Item To List    dist_name=${distName_NRCELL[${NRCELL_ID}]}   list_name=puschHrLaConfig   elements=${puschHrLaConfig_item}

    FOR   ${dist_name}                    ${value}   IN
    ...   ${distName_NRBTS[0]}/NRDRB-11   ${distName_NRBTS[0]}/${NRPUSCHHRLA_1_5QI6}
    ...   ${distName_NRBTS[0]}/NRDRB-16   ${distName_NRBTS[0]}/${NRPUSCHHRLA_2_5QI2}
    ...   ${distName_NRBTS[0]}/NRDRB-17   ${distName_NRBTS[0]}/${NRPUSCHHRLA_3_5QI3}
    ...   ${distName_NRBTS[0]}/NRDRB-14   ${distName_NRBTS[0]}/${NRPUSCHHRLA_4_5QI9}
    ...   ${distName_NRBTS[0]}/NRDRB-12   ${distName_NRBTS[0]}/${NRPUSCHHRLA_5_5QI7}
    ...   ${distName_NRBTS[0]}/NRDRB-18   ${distName_NRBTS[0]}/${NRPUSCHHRLA_6_5QI71}
    ...   ${distName_NRBTS[0]}/NRDRB-19   ${distName_NRBTS[0]}/${NRPUSCHHRLA_7_5QI80}
          tools.Set Element   dist_name=${dist_name}   p_name=nrPuschHRLaDN   value=${value}
    END

    ${distName_NRPUSCHHRLA_1}=  Set Variable  ${distName_NRBTS[0]}/NRPUSCHHRLA-1
    tools.Set Object    class_name=com.nokia.srbts.nrbts:NRPUSCHHRLA
    ...           dist_name=${distName_NRPUSCHHRLA_1}
    ...           version=NRBTSCL23R2_2302_100

    ${distName_NRPUSCHHRLA_2}=  Set Variable  ${distName_NRBTS[0]}/NRPUSCHHRLA-2
    tools.Set Object    class_name=com.nokia.srbts.nrbts:NRPUSCHHRLA
    ...           dist_name=${distName_NRPUSCHHRLA_2}
    ...           version=NRBTSCL23R2_2302_100


Configure CB008246 on PDCCH
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRBTS}
    ${distName_NRPDCCHHRLA_1}=  set variable  ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRPDCCHHRLA
    ...           dist_name=${distName_NRPDCCHHRLA_1}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    pdcchHRBlerOutagePercentage             50
    ...    pdcchHRBlerOutagePeriod                 20
    ...    pdcchHRBlerRecoverPercentage            60
        Set Element   dist_name=${distName_NRPDCCHHRLA_1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${dist_name}                    ${value}   IN
    ...   ${distName_NRBTS[0]}/NRDRB-11   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-16   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-17   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-14   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-12   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-18   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-19   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
          Set Element   dist_name=${dist_name}   p_name=nrPdcchHRLaDN   value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]


Configure SCF File for dciDedicatedAggregationLevelHR
    ${distName_PDCCH}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...                                                    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]+/PDCCH-[0-9]+
    FOR  ${dist_name}  IN  @{distName_PDCCH}
        Set Element     dist_name=${dist_name}      p_name=dciDedicatedAggregationLevelHR      value=AL4
    END


Configure SCF File for subfeature CB008246-B
    Configure BWP_PDCCH
    Configure BWP_PDCCH_CONFIG_DEDICATED


Configure BWP_PDCCH
    ${distName_PDCCH}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...                                                    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]+/PDCCH-[0-9]+
    sort list   ${distName_PDCCH}
    # BWP_PROFILE-44:
    Set Element     dist_name=${distName_PDCCH[1]}      p_name=alSelection                         value=dynamic
    Set List        dist_name=${distName_PDCCH[1]}      list_name=dynamicAggregationLevelHRSet
    ${dynamicAggregationLevelHRSet_item}=  create dictionary
    ...    aggregationLevelListHR             AL2_AL4_AL8
    ...    cqiCorrectionUpHR                           20
    ...    cqiDciCssAl1HR                             106
    ...    cqiDciCssAl2HR                              74
    ...    cqiDciCssAl4HR                              45
    ...    cqiDciCssAl8HR                              37
    ...    cqiDciCssAl16HR                              0
    ...    highOlcCqiOffsetHR                          50
    ...    lowOlcCqiOffsetHR                         1100
    ...    pCqiErasureActTimerHR                      160
    ...    pCqiErasureReductionHR                      10
    ...    pdcchCqiOffsetHR                            10
    scf.add_item_to_list    dist_name=${distName_PDCCH[1]}   list_name=dynamicAggregationLevelHRSet   elements=${dynamicAggregationLevelHRSet_item}
    Set List      dist_name=${distName_PDCCH[1]}  list_name=dynamicAggregationLevelSet
    ${dynamicAggregationLevelSet_item}=  create dictionary
    ...    aggregationLevelList      AL1_AL2_AL4_AL8_AL16
    ...    cqiCorrectionUp                            100
    ...    cqiDciCssAl1                               130
    ...    cqiDciCssAl2                               100
    ...    cqiDciCssAl4                                70
    ...    cqiDciCssAl8                                40
    ...    cqiDciCssAl16                               20
    ...    highOlcCqiOffset                             1
    ...    lowOlcCqiOffset                              1
    ...    pCqiErasureActTimer                        160
    ...    pCqiErasureReduction                        50
    scf.add_item_to_list    dist_name=${distName_PDCCH[1]}   list_name=dynamicAggregationLevelSet   elements=${dynamicAggregationLevelSet_item}


Configure BWP_PDCCH_CONFIG_DEDICATED
    ${distName_PDCCH_CONFIG_DEDICATED}=  Get distNames from Local SCF File
    ...                                      scf_path=${original_gnb_scf}
    ...                                      regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]+/PDCCH-[0-9]+/PDCCH_CONFIG_DEDICATED-[0-9]+
    Set List   dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                                     0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                                      1
    ...      monitoringSymbolWithinSlot           symbol_0_1
    ...      numOfPdcchCandidatesInAL1                    n0
    ...      numOfPdcchCandidatesInAL2                    n1
    ...      numOfPdcchCandidatesInAL4                    n2
    ...      numOfPdcchCandidatesInAL8                    n0
    ...      numOfPdcchCandidatesInAL16                   n0
    ...      periodicity                                 sl1
    ...      searchSpaceId                                 7
    ...      searchSpaceType                           Type3
    ...      slotOffset                                    0
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}
    ${searchSpaceDedicated_item2}=  create dictionary
    ...      coresetId                                     1
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                                      1
    ...      monitoringSymbolWithinSlot           symbol_0_1
    ...      numOfPdcchCandidatesInAL1                    n5
    ...      numOfPdcchCandidatesInAL2                    n4
    ...      numOfPdcchCandidatesInAL4                    n3
    ...      numOfPdcchCandidatesInAL8                    n1
    ...      numOfPdcchCandidatesInAL16                   n1
    ...      periodicity                                 sl1
    ...      searchSpaceId                                 8
    ...      searchSpaceType                     UE-Specific
    ...      slotOffset                                    0
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}


Configure GBR for SA UEs in SCF File
    ${distName_NRCELL}=    Get distNames from Local SCF File   scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        Set Element    dist_name=${dist_name}    p_name=actGBRAdmissionControl            value=GBRService
        Set Element    dist_name=${dist_name}    p_name=actVoNR                           value=true
        Set Element    dist_name=${dist_name}    p_name=actNonVoNRGbrService              value=true
        Set Element    dist_name=${dist_name}    p_name=maxNumOfGBRBearersSA              value=30
        Set Element    dist_name=${dist_name}    p_name=actGbrRacTdEnhResourcePriority    value=false
    END


Configure new NRDRB-16
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB16}=  Set variable  ${distName_NRBTS[0]}/NRDRB-16
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB
    ...           dist_name=${distName_NRDRB16}
    ...           version=NRBTSCL25R3_2506_102
    FOR    ${p_name}    ${value}    IN
    ...    actDddsReduction                  false
    ...    actOptDataFlowRateEst             false
    ...    actLostPduFastRetx                false
    ...    allowedPdcchPowerBoostALDueCce    none
    ...    allowedPdcchPowerBoostALDueCfg    None
    ...    caPduReSendingDelayMargin         2
    ...    discardTimer                      100ms
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
    ...    nrDrbPdcpDN                       MRBTS-1/NRBTS-1/NRDRB_PDCP-3
    ...    nrDrbRlcUmDN                      MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...    nrDrxDN                           MRBTS-1/NRBTS-1/NRDRX-1
    ...    numSduDiscard                     1
    ...    queuingDelayDiscarding            Disabled
    ...    queuingDelaySduDiscardThreshold   750
    ...    queuingDelayDiscardStart          5
    ...    resType                           GBR
    ...    rlcMode                           RLC_UM
    ...    rlcPduDelayThCa                   30
    ...    schedulWeight                     1
    ...    sduDiscardIntervalTmr             500
    ...    srsStaticUeDoublePeriodicity      false
    ...    volThresDiscardDlMacSdu           8000
    ...    volThresDiscardDlPdcpPdu5GLeg     8000
    ...    volThresDiscardDlPdcpPduLteLeg    8000
    ...    actDlTxResumeOnPdcpStatRep        false
    ...    durationThresDiscardDl            40
    ...    durationThresDiscardUl            20
    ...    volThresDiscardDl                 8000
    ...    volThresDiscardUl                 800
    ...    maxForwardTimeLimitXx             50
    ...    minForwardTputXx                  100
        Set Element   dist_name=${distName_NRDRB16}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName_NRDRB16}  list_name=cellAggrLevel
    ${param_list}=    create list    Not FR1 CA eligible
    scf.add_elements_to_list    dist_name=${distName_NRDRB16}    list_name=cellAggrLevel    elements=${param_list}


Configure new NRDRB-17
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB17}=  Set variable  ${distName_NRBTS[0]}/NRDRB-17
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB
    ...           dist_name=${distName_NRDRB17}
    ...           version=NRBTSCL25R3_2506_102
    FOR    ${p_name}    ${value}    IN
    ...    actDddsReduction                  false
    ...    actOptDataFlowRateEst             false
    ...    actLostPduFastRetx                false
    ...    allowedPdcchPowerBoostALDueCce    none
    ...    allowedPdcchPowerBoostALDueCfg    None
    ...    caPduReSendingDelayMargin         2
    ...    discardTimer                      100ms
    ...    dlAllowMinDelayLinkXxCalib        false
    ...    dlFlowControlAlgo                 3gppFlowControl
    ...    dscp                              26
    ...    durationThresDiscardDlMacSdu      40
    ...    durationThresDiscardDlPdcpPdu5GLeg     40
    ...    durationThresDiscardDlPdcpPduLteLeg    40
    ...    endMarkerTimer                    2000
    ...    l2OHFactorDl                      50
    ...    l2OHFactorUl                      50
    ...    maxDataRateGbrDl                  30720
    ...    maxDataRateGbrUl                  30720
    ...    maxDddsPeriodCpuOvld              40
    ...    maxRlcQueueingDelayGbr            20
    ...    maxTransferDelayGbr               20
    ...    nrDrbMacDN                        MRBTS-1/NRBTS-1/NRDRB_MAC-5
    ...    nrDrbPdcpDN                       MRBTS-1/NRBTS-1/NRDRB_PDCP-3
    ...    nrDrbRlcUmDN                      MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...    nrDrxDN                           MRBTS-1/NRBTS-1/NRDRX-1
    ...    numSduDiscard                     1
    ...    queuingDelayDiscarding            Disabled
    ...    queuingDelaySduDiscardThreshold   750
    ...    queuingDelayDiscardStart          5
    ...    resType                           GBR
    ...    rlcMode                           RLC_UM
    ...    rlcPduDelayThCa                   30
    ...    schedulWeight                     1
    ...    sduDiscardIntervalTmr             500
    ...    srsStaticUeDoublePeriodicity      false
    ...    volThresDiscardDlMacSdu           8000
    ...    volThresDiscardDlPdcpPdu5GLeg     8000
    ...    volThresDiscardDlPdcpPduLteLeg    8000
    ...    actDlTxResumeOnPdcpStatRep        false
    ...    durationThresDiscardDl            40
    ...    durationThresDiscardUl            20
    ...    volThresDiscardDl                 8000
    ...    volThresDiscardUl                 800
    ...    maxForwardTimeLimitXx             50
    ...    minForwardTputXx                  100
        Set Element   dist_name=${distName_NRDRB17}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName_NRDRB17}  list_name=cellAggrLevel
    ${param_list}=    create list    Not FR1 CA eligible
    scf.add_elements_to_list    dist_name=${distName_NRDRB17}    list_name=cellAggrLevel    elements=${param_list}


Configure new NRDRB-18
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB18}=  Set variable  ${distName_NRBTS[0]}/NRDRB-18
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB
    ...           dist_name=${distName_NRDRB18}
    ...           version=NRBTSCL25R3_2506_102
    FOR    ${p_name}    ${value}    IN
    ...    actDddsReduction                  false
    ...    actOptDataFlowRateEst             false
    ...    actLostPduFastRetx                false
    ...    allowedPdcchPowerBoostALDueCce    none
    ...    allowedPdcchPowerBoostALDueCfg    None
    ...    caPduReSendingDelayMargin         2
    ...    discardTimer                      100ms
    ...    dlAllowMinDelayLinkXxCalib        false
    ...    dlFlowControlAlgo                 3gppFlowControl
    ...    dscp                              26
    ...    durationThresDiscardDlMacSdu      40
    ...    durationThresDiscardDlPdcpPdu5GLeg     40
    ...    durationThresDiscardDlPdcpPduLteLeg    40
    ...    endMarkerTimer                    2000
    ...    l2OHFactorDl                      50
    ...    l2OHFactorUl                      50
    ...    maxDataRateGbrDl                  30720
    ...    maxDataRateGbrUl                  30720
    ...    maxDddsPeriodCpuOvld              40
    ...    maxRlcQueueingDelayGbr            20
    ...    maxTransferDelayGbr               20
    ...    nrDrbMacDN                        MRBTS-1/NRBTS-1/NRDRB_MAC-5
    ...    nrDrbPdcpDN                       MRBTS-1/NRBTS-1/NRDRB_PDCP-3
    ...    nrDrbRlcUmDN                      MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...    nrDrxDN                           MRBTS-1/NRBTS-1/NRDRX-1
    ...    numSduDiscard                     1
    ...    queuingDelayDiscarding            Disabled
    ...    queuingDelaySduDiscardThreshold   750
    ...    queuingDelayDiscardStart          5
    ...    resType                           GBR
    ...    rlcMode                           RLC_UM
    ...    rlcPduDelayThCa                   30
    ...    schedulWeight                     1
    ...    sduDiscardIntervalTmr             500
    ...    srsStaticUeDoublePeriodicity      false
    ...    volThresDiscardDlMacSdu           8000
    ...    volThresDiscardDlPdcpPdu5GLeg     8000
    ...    volThresDiscardDlPdcpPduLteLeg    8000
    ...    actDlTxResumeOnPdcpStatRep        false
    ...    durationThresDiscardDl            40
    ...    durationThresDiscardUl            20
    ...    volThresDiscardDl                 8000
    ...    volThresDiscardUl                 800
    ...    maxForwardTimeLimitXx             50
    ...    minForwardTputXx                  100
        Set Element   dist_name=${distName_NRDRB18}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName_NRDRB18}  list_name=cellAggrLevel
    ${param_list}=    create list    Not FR1 CA eligible
    scf.add_elements_to_list    dist_name=${distName_NRDRB18}    list_name=cellAggrLevel    elements=${param_list}


Configure new NRDRB-19
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB19}=  Set variable  ${distName_NRBTS[0]}/NRDRB-19
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB
    ...           dist_name=${distName_NRDRB19}
    ...           version=NRBTSCL25R3_2506_102
    FOR    ${p_name}    ${value}    IN
    ...    actOptDataFlowRateEst             false
    ...    actDddsReduction                  false
    ...    actLostPduFastRetx                false
    ...    allowedPdcchPowerBoostALDueCce    none
    ...    allowedPdcchPowerBoostALDueCfg    None
    ...    caPduReSendingDelayMargin         2
    ...    discardTimer                      infinity
    ...    dlAllowMinDelayLinkXxCalib        false
    ...    dlFlowControlAlgo                 3gppFlowControl
    ...    dscp                              0
    ...    durationThresDiscardDlMacSdu      40
    ...    durationThresDiscardDlPdcpPdu5GLeg     40
    ...    durationThresDiscardDlPdcpPduLteLeg    40
    ...    endMarkerTimer                    2000
    ...    maxDataRateGbrDl                  1000
    ...    maxDataRateGbrUl                  1000
    ...    maxDddsPeriodCpuOvld              40
    ...    maxRlcQueueingDelayGbr            20
    ...    maxTransferDelayGbr               20
    ...    nrDrbMacDN                        MRBTS-1/NRBTS-1/NRDRB_MAC-2
    ...    nrDrbPdcpDN                       MRBTS-1/NRBTS-1/NRDRB_PDCP-2
    ...    nrDrbRlcAmDN                      MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
    ...    nrDrxDN                           MRBTS-1/NRBTS-1/NRDRX-1
    ...    numSduDiscard                     1
    ...    queuingDelayDiscarding            Disabled
    ...    queuingDelaySduDiscardThreshold   750
    ...    queuingDelayDiscardStart          5
    ...    resType                           nonGBR
    ...    rlcMode                           RLC_AM
    ...    rlcPduDelayThCa                   30
    ...    schedulWeight                     1
    ...    sduDiscardIntervalTmr             500
    ...    srsStaticUeDoublePeriodicity      false
    ...    volThresDiscardDlMacSdu           8000
    ...    volThresDiscardDlPdcpPdu5GLeg     8000
    ...    volThresDiscardDlPdcpPduLteLeg    8000
    ...    actDlTxResumeOnPdcpStatRep        false
    ...    durationThresDiscardDl            40
    ...    durationThresDiscardUl            20
    ...    volThresDiscardDl                 8000
    ...    volThresDiscardUl                 800
    ...    maxForwardTimeLimitXx             50
    ...    minForwardTputXx                  100
        Set Element   dist_name=${distName_NRDRB19}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName_NRDRB19}  list_name=cellAggrLevel
    ${param_list}=    create list    FR1 CA eligible
    scf.add_elements_to_list    dist_name=${distName_NRDRB19}    list_name=cellAggrLevel    elements=${param_list}


Configure new 5QI-7 and set it to 2 and connect it to NRDRB-16
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
	${distName_NRDRB5QI7}=  Set variable  ${distName_NRBTS[0]}/NRDRB_5QI-7
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_5QI
    ...           dist_name=${distName_NRDRB5QI7}
    ...           version=NRBTSCL23R3_2305_100
    Set Element   dist_name=${distName_NRDRB5QI7}  p_name=nrDrbDN                           value=MRBTS-1/NRBTS-1/NRDRB-16
    Set List      dist_name=${distName_NRDRB5QI7}  list_name=fiveqiValueList
    ${param_list}=    create list  2
    scf.add_elements_to_list  dist_name=${distName_NRDRB5QI7}  list_name=fiveqiValueList   elements=${param_list}
    Set Element   dist_name=${distName_NRDRB5QI7}    p_name=dataForwarding    value=IRATDataFwd


Configure new 5QI-8 and set it to 3 and connect it to NRDRB-17
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
	${distName_NRDRB5QI8}=  Set variable  ${distName_NRBTS[0]}/NRDRB_5QI-8
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_5QI
    ...           dist_name=${distName_NRDRB5QI8}
    ...           version=NRBTSCL23R3_2305_100
    Set Element   dist_name=${distName_NRDRB5QI8}  p_name=nrDrbDN                           value=MRBTS-1/NRBTS-1/NRDRB-17
    Set List      dist_name=${distName_NRDRB5QI8}  list_name=fiveqiValueList
    ${param_list}=    create list  3
    scf.add_elements_to_list  dist_name=${distName_NRDRB5QI8}  list_name=fiveqiValueList   elements=${param_list}
    Set Element   dist_name=${distName_NRDRB5QI8}    p_name=dataForwarding    value=IRATDataFwd


Configure new 5QI-9 and set it to 71 and connect it to NRDRB-18
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB5QI9}=  Set variable  ${distName_NRBTS[0]}/NRDRB_5QI-9
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_5QI
    ...           dist_name=${distName_NRDRB5QI9}
    ...           version=NRBTSCL23R3_2305_100
    Set Element   dist_name=${distName_NRDRB5QI9}  p_name=nrDrbDN                           value=MRBTS-1/NRBTS-1/NRDRB-18
    Set List      dist_name=${distName_NRDRB5QI9}  list_name=fiveqiValueList
    ${param_list}=    create list  71
    scf.add_elements_to_list  dist_name=${distName_NRDRB5QI9}  list_name=fiveqiValueList   elements=${param_list}
    Set Element   dist_name=${distName_NRDRB5QI9}    p_name=dataForwarding    value=IRATDataFwd


Configure new 5QI-10 and set it to 80 and connect it to NRDRB-19
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB5QI10}=  Set variable  ${distName_NRBTS[0]}/NRDRB_5QI-10
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_5QI
    ...           dist_name=${distName_NRDRB5QI10}
    ...           version=NRBTSCL23R3_2305_100
    Set Element   dist_name=${distName_NRDRB5QI10}  p_name=nrDrbDN                           value=MRBTS-1/NRBTS-1/NRDRB-19
    Set List      dist_name=${distName_NRDRB5QI10}  list_name=fiveqiValueList
    ${param_list}=    create list  80
    scf.add_elements_to_list  dist_name=${distName_NRDRB5QI10}  list_name=fiveqiValueList   elements=${param_list}
    Set Element   dist_name=${distName_NRDRB5QI10}    p_name=dataForwarding    value=IRATDataFwd


Configure new MAC-5
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
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
        Set Element   dist_name=${distName_NRDRBMAC5}    p_name=${p_name}    value=${value}
    END

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
