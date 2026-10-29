*** Settings ***
Documentation    Scenario specific keywords for subfeature CB008409-B of "PowerBoostVoNR_and_SRB_transmissions"

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    taf.config.scf                       WITH NAME   scf
Library    ../../../../L2/libraries/tools.py


*** Keywords ***

#-----------For SCF.xml Changes on suite setup---------------------------------------------------------------------------------------[150 characters]

Change Reporting Interval for CB008409
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality
    ...                                 miNrDlHarq  miNrUlHarq
    ...                                 miNrDlHarqLowSEMCS  miNrUlHarqLowSEMCS  miNrSignalQualityLowSEMCS
    ...                                 miNrPdcch  miNrResourceUtilizationPerCell
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm

Disable UL & DL 256QAM on all Cells
    ${distName_NRCELL}=    Get distNames from Local SCF File   scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        Set Element    dist_name=${dist_name}    p_name=actDl256Qam               value=false
        Set Element    dist_name=${dist_name}    p_name=actDlLaDynBlerTarget      value=false
        Set Element    dist_name=${dist_name}    p_name=actUl256Qam               value=false
    END


Disable some Functionality according to CFAM
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        tools.Set Element    dist_name=${dist_name}    p_name=actDlMuMimo                        value=false
        tools.Set Element    dist_name=${dist_name}    p_name=actAdaptiveReTxResMcs              value=false
        tools.Set Element    dist_name=${dist_name}    p_name=actAdaptiveReTxResMcsEnh           value=false
        tools.Set Element    dist_name=${dist_name}    p_name=actEnhancedPDSCHSchSplSlot         value=false
        tools.Set Element    dist_name=${dist_name}    p_name=maxNumPdschAllocationPerSlot       value=12
        tools.Set Element    dist_name=${dist_name}    p_name=actPdcchSharingWithPdsch           value=false
    END


Configure bbmodBoardConfigType on ABIP
    ${distName_BBMOD}=    Get distNames from Local SCF File   scf_path=${original_gnb_scf}    regex=MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    FOR  ${dist_name}  IN  @{distName_BBMOD}
        Set Element    dist_name=${dist_name}    p_name=bbmodBoardConfigType        value=NRFDD_NRTDD
    END

Configure Prioritised bitrate on MAC-3
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRDRB_MAC-3}=  set variable  ${distName_NRBTS[0]}/NRDRB_MAC-3
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_MAC
    ...           dist_name=${distName_NRDRB_MAC-3}
    ...           version=NRBTSCL24R3_2413_101
    FOR    ${p_name}    ${value}    IN
    ...    prioritisedBitRate                      1024kBps
        Set Element   dist_name=${distName_NRDRB_MAC-3}    p_name=${p_name}    value=${value}
    END

Activate CB008409-B
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------Powerboost initially disabled and is enabled only on required cell during runtime---------------------------------------[150 characters]
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        ${cellTechnology}=    scf.Get_Value_From_Scf    dist_name=${distName}   p_name=cellTechnology
        IF  '${cellTechnology}' == 'FDD'
            tools.Set Element    dist_name=${dist_name}     p_name=actCsiImRandomizationFddNonDss    value=true         #enable CB008409-A
            tools.Set Element    dist_name=${dist_name}     p_name=actDlForceRankDowng               value=dlNonGbrBrOnly
            tools.Set Element    dist_name=${dist_name}     p_name=shortTermBlerThreshold1           value=12
            tools.Set Element    dist_name=${dist_name}     p_name=shortTermBlerThreshold2           value=10
        END
        tools.Set Element    dist_name=${dist_name}     p_name=actPdschAllocAroundSsb                       value=true
        tools.Set Element    dist_name=${dist_name}     p_name=actPdschAtSsbSlots                           value=true
        tools.Set Element    dist_name=${dist_name}     p_name=actPdschRmCsirsForTracking                   value=true
        tools.Set Element    dist_name=${dist_name}     p_name=actDlPowerBoost                              value=disabled
        tools.Set Element    dist_name=${dist_name}     p_name=actShortBsrLimitAdaptation                   value=true
        Set List       dist_name=${dist_name}     list_name=dlRetxPowerBoostCtl
        ${dlRetxPowerBoostCtl_item}=  create dictionary
        ...    maxPrbsIncludingPowerBoostPrbs           100
        ...    numTxThreshForPowerBoost                 1
        ...    powerBoostScalingFactor                  20
        scf.add_item_to_list    dist_name=${dist_name}   list_name=dlRetxPowerBoostCtl   elements=${dlRetxPowerBoostCtl_item}
    END

Activate Pooling on FDD and TDD Cells
    ${distName_NRBTS}=    Get distNames from Local SCF File   scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRDU}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDU-[0-9]+
    FOR  ${dist_name}  IN  @{distName_NRBTS}
        Set Element    dist_name=${dist_name}    p_name=actConnRrcPooling                   value=true
        Set Element    dist_name=${dist_name}    p_name=actScheUePooling                    value=true
        Set Element    dist_name=${dist_name}    p_name=actSlowPrbPooling                   value=true
        Set Element    dist_name=${dist_name}    p_name=actSlowPrbPoolingFddFr1Enh          value=true
        Set Element    dist_name=${dist_name}    p_name=actBbPoolExtensionTddFr1            value=true
        Set Element    dist_name=${dist_name}    p_name=actBbPoolTddFr1                     value=true
        Set Element    dist_name=${dist_name}    p_name=actBbPoolTddFr1AlgEnh               value=true
        Set Element    dist_name=${dist_name}    p_name=actBbPoolTddFr1Enh                  value=true
    END
    FOR  ${dist_name}  IN  @{distName_NRDU}
        Set Element    dist_name=${dist_name}    p_name=flexibleCAMode                      value=NumberCellAmount
    END


Activate Rat1Alloc on all Cells
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        tools.Set Element    dist_name=${dist_name}    p_name=actRat1Alloc                        value=true
        tools.Set Element    dist_name=${dist_name}    p_name=actEnhancedVoNR                     value=true
        tools.Set Element    dist_name=${dist_name}    p_name=percRedSEDlRat1VoNR                 value=0
    END


Activate Enhanced_MU-MIMO
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                            ${value}    IN
    ...    actDlMuMimoEnh           			true
    ...    actDlMuMimo                          false
    ...    actDlSrsBm                           true
	...    actUlSrsBm                           true
    ...    dftBeamDiffThresholdH                15
    ...    dftBeamDiffThresholdV                15
    ...    mMimoAntArrayMode	                Full 64TRX Array (4x8x2)
        Set Element   dist_name=${distName_NRCELL[0]}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRCELL[0]}  list_name=srsForBeamMgmt
    ${srsForBeamMgmt_item}=  create dictionary
    ...    bSRS			2
    ...    comb       comb2
    ...    cSRS        42
    ...    srsPowerThresholdForDlBm    			-1200
    ...    srsPowerThresholdForUlBm        		-1320
    ...    srsTypeAllocForDlBm        			antenna switching or codebook
    ...    srsUePeriodicity        				slots40
    scf.add_item_to_list    dist_name=${distName_NRCELL[0]}   list_name=srsForBeamMgmt   elements=${srsForBeamMgmt_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDLMUMIMO-1}=  set variable  ${distName_NRCELL[0]}/NRDLMUMIMO-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRDLMUMIMO
    ...           dist_name=${distName_NRCELL[0]}/NRDLMUMIMO-1
    ...           version=NRBTSCL24R3_2413_101
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}    ${value}    IN
    ...    actExcludeLowBufferUser					false
    ...    actMuAwareTdSch            				false
    ...    dlMuAwareCorrThd         	   			1
    ...    dlMuAwarePrbRatio   	   					100
    ...    dlMuMaxNumLayerPerMuRbg         	   		8
    ...    dlMuMimoCorrThd             	   			100
    ...    dlMuMimoCqiThd                	   		0
    ...    dlMuMimoRankAdaption              	   	disabled
    ...    dlMuMimoSpectralEffThd              	   	0
    ...    dlMuMimoTaperingH              	   		NoTapering
    ...    dlMuMimoTaperingV              	   		NoTapering
    ...    dlMuPairingPrbRatio              	   	100
    ...    nrDlMuMimoId              	   			1
        Set Element   dist_name=${distName_NRDLMUMIMO-1}    p_name=${p_name}    value=${value}
    END


Activate PRB Blanking
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                            ${value}    IN
    ...    actPRBBlanking                             true
    ...    nbrOfBlankedPRBsHighEdgeDL                 10
    ...    nbrOfBlankedPRBsHighEdgeUL                 10
    ...    nbrOfBlankedPRBsLowEdgeDL                  8
    ...    nbrOfBlankedPRBsLowEdgeUL                  8
        Set Element   dist_name=${distName_NRCELL[3]}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRCELL[3]}  list_name=cellBwpList
    ${cellBwpList_item1}=  create dictionary
    ...    actPdcchCceFragmentControl       false
    ...    actUpperThrAckNackFiltering      false
    ...    actUpperThrAckNackHrFiltering    false
    ...    bwpDN                            MRBTS-1/NRBTS-1/BWP_PROFILE-133
    ...    cellBwpId                        0
    ...    pdcchResourcePreference          peakRate
    scf.add_item_to_list    dist_name=${distName_NRCELL[3]}   list_name=cellBwpList   elements=${cellBwpList_item1}
	${cellBwpList_item2}=  create dictionary
    ...    actPdcchCceFragmentControl       false
    ...    actUpperThrAckNackFiltering      true
    ...    actUpperThrAckNackHrFiltering    false
    ...    bwpDN                            MRBTS-1/NRBTS-1/BWP_PROFILE-130
    ...    cellBwpId                        1
    ...    pdcchBlockingThresholdDL         30
    ...    pdcchBlockingThresholdUL         30
    ...    pdcchFreeThresholdDL             50
    ...    pdcchFreeThresholdUL             50
    ...    pdcchResourcePreference          peakRate
    scf.add_item_to_list    dist_name=${distName_NRCELL[3]}   list_name=cellBwpList   elements=${cellBwpList_item2}
    Configure BWP_PROFILE-130
    Configure BWP_PROFILE-133
    Configure BWP Profile    profile_id=BWP_PROFILE-0    periodicity_value=sl20  slot_offset_value=5
    Configure BWP Profile    profile_id=BWP_PROFILE-44   periodicity_value=sl20  slot_offset_value=5


Configure BWP_PROFILE-130
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distName_BWP_PROFILE-130}=  set variable  ${distName_NRBTS[0]}/BWP_PROFILE-130
    Set Object    class_name=com.nokia.srbts.nrbts:BWP_PROFILE
    ...           dist_name=${distName_NRBTS[0]}/BWP_PROFILE-130
    ...           version=NRBTSCL24R3_2413_101
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_BWP_PROFILE-130}= 	Create Dictionary
    ...           dist_name=${distName_NRBTS[0]}/BWP_PROFILE-130
    ...           operation=update
    Set Element   dist_name=${distName_NRBTS[0]}/BWP_PROFILE-130    p_name=bwpType    value=dedicated
    Set List      dist_name=${distName_NRBTS[0]}/BWP_PROFILE-130  list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl_item}=  create dictionary
    ...          cRbSizeDl      allRb
    ...          cRbStartDl     crb0
	scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-130   list_name=locationAndBandwidthDl
    ...           elements=${locationAndBandwidthDl_item}
    Set List      dist_name=${distName_NRBTS[0]}/BWP_PROFILE-130  list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl_item}=  create dictionary
    ...          cRbSizeUl      allRb
    ...          cRbStartUl     crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-130   list_name=locationAndBandwidthUl
    ...           elements=${locationAndBandwidthUl_item}
    ${distName_BWP_PROFILE-130_PDCCH-1}=  set variable  ${distName_NRBTS[0]}/BWP_PROFILE-130/PDCCH-1
    Set Object    class_name=com.nokia.srbts.nrbts:PDCCH
    ...           dist_name=${distName_BWP_PROFILE-130_PDCCH-1}
    ...           version=NRBTSCL24R3_2413_101
    FOR    ${p_name}    ${value}    IN
    ...    alSelection						       dynamic
    ...    dciDedicatedAggregationLevel            AL4
    ...    dciPagingAggregationLevel         	   AL4
    ...    dciRaCompletionAggregationLevel   	   AL4
    ...    dciRaMsg2AggregationLevel         	   AL4
    ...    dciSiAggregationLevel             	   AL4
    ...    downgradeAL16toAL8                	   notAllowed
    ...    downgradeALProactive              	   false
        Set Element   dist_name=${distName_BWP_PROFILE-130_PDCCH-1}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_BWP_PROFILE-130_PDCCH-1}  list_name=dynamicAggregationLevelSet
    ${dynamicAggregationLevelSet_item}=  create dictionary
	...          aggregationLevelList             AL1_AL2_AL4_AL8
    ...          cqiCorrectionUp                  8
    ...          cqiDciCssAl1                     101
    ...          cqiDciCssAl16                    0
    ...          cqiDciCssAl2                     69
    ...          cqiDciCssAl4                     33
    ...          cqiDciCssAl8                     10
    ...          highOlcCqiOffset                 100
    ...          lowOlcCqiOffset                  1100
    ...          pCqiErasureActTimer              160
    ...          pCqiErasureReduction             10
    scf.add_item_to_list    dist_name=${distName_BWP_PROFILE-130_PDCCH-1}   list_name=dynamicAggregationLevelSet
    ...          elements=${dynamicAggregationLevelSet_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_COMMON-1}= 	set variable  ${distName_NRBTS[0]}/BWP_PROFILE-130/PDCCH-1/PDCCH_CONFIG_COMMON-1
    Set Object    class_name=com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON
    ...           dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_COMMON-1}
    ...           version=NRBTSCL24R3_2413_101
    Set List      dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_COMMON-1}   list_name=searchSpaceCommon
    ${searchSpaceCommon_item1}=  Create Dictionary
    ...           coresetId                    0
    ...           dciFormat                    formats0-0-And-1-0
    ...           duration                     1
    ...           monitoringSymbolWithinSlot   symbol_0
    ...           numOfPdcchCandidatesInAL16   n0
    ...           numOfPdcchCandidatesInAL2    n0
    ...           numOfPdcchCandidatesInAL4    n2
    ...           numOfPdcchCandidatesInAL8    n0
    ...           periodicity                  sl1
    ...           searchSpaceId                4
    ...           searchSpaceType              Type0A
	...           slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_COMMON-1}  list_name=searchSpaceCommon
    ...           elements=${searchSpaceCommon_item1}
    ${searchSpaceCommon_item2}=  Create Dictionary
    ...           coresetId                    0
    ...           dciFormat                    formats0-0-And-1-0
    ...           duration                     1
    ...           monitoringSymbolWithinSlot   symbol_0_1
    ...           numOfPdcchCandidatesInAL16   n0
    ...           numOfPdcchCandidatesInAL2    n0
    ...           numOfPdcchCandidatesInAL4    n2
    ...           numOfPdcchCandidatesInAL8    n0
    ...           periodicity                  sl1
    ...           searchSpaceId                5
    ...           searchSpaceType              Type1
	...           slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_COMMON-1}  list_name=searchSpaceCommon
    ...           elements=${searchSpaceCommon_item2}
    ${searchSpaceCommon_item3}=  Create Dictionary
    ...           coresetId                    0
    ...           dciFormat                    formats0-0-And-1-0
    ...           duration                     1
    ...           monitoringSymbolWithinSlot   symbol_0
    ...           numOfPdcchCandidatesInAL16   n0
    ...           numOfPdcchCandidatesInAL2    n0
    ...           numOfPdcchCandidatesInAL4    n2
    ...           numOfPdcchCandidatesInAL8    n0
    ...           periodicity                  sl1
    ...           searchSpaceId                6
    ...           searchSpaceType              Type2
	...           slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_COMMON-1}  list_name=searchSpaceCommon
    ...           elements=${searchSpaceCommon_item3}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_DEDICATED-1}=  set variable
    ...           ${distName_NRBTS[0]}/BWP_PROFILE-130/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    Set Object    class_name=com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED
    ...           dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_DEDICATED-1}
    ...           version=NRBTSCL24R3_2413_101
    Set List      ${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_DEDICATED-1}   list_name=coresetDedicated
    ${coresetDedicated_item}     Create Dictionary
    ...           cceToRegMapping              interleaved
    ...           coresetId                    1
    ...           cRbStart                     12
    ...           duration                     1
    ...           interleaverSize              n3
    ...           regBundleSize                n2
    ...           size                         84
    scf.add_item_to_list  dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_DEDICATED-1}  list_name=coresetDedicated
    ...           elements=${coresetDedicated_item}

    Set List      ${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_DEDICATED-1}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}     Create Dictionary
    ...           coresetId                    1
    ...           dciFormat                    formats0-0-And-1-0
    ...           duration                     1
    ...           monitoringSymbolWithinSlot   symbol_0
    ...           numOfPdcchCandidatesInAL1    n0
    ...           numOfPdcchCandidatesInAL16   n0
    ...           numOfPdcchCandidatesInAL2    n0
    ...           numOfPdcchCandidatesInAL4    n2
    ...           numOfPdcchCandidatesInAL8    n1
    ...           periodicity                  sl1
    ...           searchSpaceId                7
    ...           searchSpaceType              Type3
    ...           slotOffset                   0
	scf.add_item_to_list  dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_DEDICATED-1}  list_name=searchSpaceDedicated
    ...  elements=${searchSpaceDedicated_item1}

    ${searchSpaceDedicated_item2}=  create dictionary
    ...           coresetId                    1
    ...           dciFormat                    formats0-1-And-1-1
    ...           duration                     1
    ...           monitoringSymbolWithinSlot   symbol_0
    ...           numOfPdcchCandidatesInAL1    n2
    ...           numOfPdcchCandidatesInAL16   n0
    ...           numOfPdcchCandidatesInAL2    n2
    ...           numOfPdcchCandidatesInAL4    n2
    ...           numOfPdcchCandidatesInAL8    n2
    ...           periodicity                  sl1
    ...           searchSpaceId                8
    ...           searchSpaceType              UE-Specific
    ...           slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_DEDICATED-1}  list_name=searchSpaceDedicated
    ...  elements=${searchSpaceDedicated_item2}

    ${searchSpaceDedicated_item3}=  Create Dictionary
    ...           coresetId                    1
    ...           dciFormat                    formats0-0-And-1-0
    ...           duration                     1
    ...           monitoringSymbolWithinSlot   symbol_1
    ...           numOfPdcchCandidatesInAL1    n0
    ...           numOfPdcchCandidatesInAL16   n0
    ...           numOfPdcchCandidatesInAL2    n0
    ...           numOfPdcchCandidatesInAL4    n2
    ...           numOfPdcchCandidatesInAL8    n1
    ...           periodicity                  sl1
    ...           searchSpaceId                9
    ...           searchSpaceType              Type3
    ...           slotOffset                   0
    scf.Add_Item_To_List  dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_DEDICATED-1}  list_name=searchSpaceDedicated
    ...  elements=${searchSpaceDedicated_item3}

    ${searchSpaceDedicated_item4}=  Create Dictionary
    ...           coresetId                    1
    ...           dciFormat                    formats0-1-And-1-1
    ...           duration                     1
    ...           monitoringSymbolWithinSlot   symbol_1
    ...           numOfPdcchCandidatesInAL1    n1
    ...           numOfPdcchCandidatesInAL16   n0
    ...           numOfPdcchCandidatesInAL2    n1
    ...           numOfPdcchCandidatesInAL4    n1
    ...           numOfPdcchCandidatesInAL8    n1
    ...           periodicity                  sl1
    ...           searchSpaceId                10
    ...           searchSpaceType              UE-Specific
    ...           slotOffset                   0
    scf.Add_Item_To_List  dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_DEDICATED-1}  list_name=searchSpaceDedicated
    ...  elements=${searchSpaceDedicated_item4}

    ${searchSpaceDedicated_item5}=  Create Dictionary
    ...           coresetId                    1
    ...           dciFormat                    formats0-1-And-1-1
    ...           duration                     19
    ...           monitoringSymbolWithinSlot   symbol_2
    ...           numOfPdcchCandidatesInAL1    n1
    ...           numOfPdcchCandidatesInAL16   n0
    ...           numOfPdcchCandidatesInAL2    n1
    ...           numOfPdcchCandidatesInAL4    n1
    ...           numOfPdcchCandidatesInAL8    n0
    ...           periodicity                  sl20
    ...           searchSpaceId                11
    ...           searchSpaceType              UE-Specific
    ...           slotOffset                   1
    scf.Add_Item_To_List  dist_name=${distName_BWP_PROFILE-130_PDCCH-1_PDCCH_CONFIG_DEDICATED-1}  list_name=searchSpaceDedicated
    ...  elements=${searchSpaceDedicated_item5}

    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_BWP_PROFILE-130_PDSCH-1}=  set variable
    ...           ${distName_NRBTS[0]}/BWP_PROFILE-130/PDSCH-1
    Set Object    class_name=com.nokia.srbts.nrbts:PDSCH
    ...           dist_name=${distName_BWP_PROFILE-130_PDSCH-1}
    ...           version=NRBTSCL24R3_2413_101
    Set Element   dist_name=${distName_BWP_PROFILE-130_PDSCH-1}    p_name=pdschRat0RbgConfig    value=config1


Configure BWP_PROFILE-133
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distName_BWP_PROFILE-133}=  set variable  ${distName_NRBTS[0]}/BWP_PROFILE-133
    Set Object    class_name=com.nokia.srbts.nrbts:BWP_PROFILE
    ...           dist_name=${distName_NRBTS[0]}/BWP_PROFILE-133
    ...           version=NRBTSCL24R3_2413_101
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_BWP_PROFILE-133}= 	Create Dictionary
    ...           distName=${distName_NRBTS[0]}/BWP_PROFILE-133
    ...           operation=update
    Set Element   dist_name=${distName_NRBTS[0]}/BWP_PROFILE-133    p_name=bwpType    value=initial
    Set List      dist_name=${distName_NRBTS[0]}/BWP_PROFILE-133  list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl_item}=  create dictionary
    ...          cRbSizeDl      coreset0
    ...          cRbStartDl     coreset0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-133   list_name=locationAndBandwidthDl
    ...         elements=${locationAndBandwidthDl_item}
    Set List      dist_name=${distName_NRBTS[0]}/BWP_PROFILE-133  list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl_item}=  create dictionary
    ...          cRbSizeUl      n88
    ...          cRbStartUl     crb8
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-133   list_name=locationAndBandwidthUl
    ...         elements=${locationAndBandwidthUl_item}
    ${distName_BWP_PROFILE-133_PDCCH-1}=  set variable  ${distName_NRBTS[0]}/BWP_PROFILE-133/PDCCH-1
    Set Object    class_name=com.nokia.srbts.nrbts:PDCCH
    ...           dist_name=${distName_BWP_PROFILE-133_PDCCH-1}
    ...           version=NRBTSCL24R3_2413_101
    FOR    ${p_name}    ${value}    IN
    ...           alSelection                       static
    ...           dciDedicatedAggregationLevel      AL4
    ...           dciPagingAggregationLevel         AL4
    ...           dciRaCompletionAggregationLevel   AL4
    ...           dciRaMsg2AggregationLevel         AL4
    ...           dciSiAggregationLevel             AL4
    ...           downgradeAL16toAL8                notAllowed
    ...           downgradeALProactive              false
    Set Element   dist_name=${distName_BWP_PROFILE-133_PDCCH-1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_BWP_PROFILE-133_PDCCH-1_PDCCH_CONFIG_COMMON-1}=  set variable  ${distName_NRBTS[0]}/BWP_PROFILE-133/PDCCH-1/PDCCH_CONFIG_COMMON-1
    Set Object    class_name=com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON
    ...           dist_name=${distName_BWP_PROFILE-133_PDCCH-1_PDCCH_CONFIG_COMMON-1}
    ...           version=NRBTSCL24R3_2413_101
    Set List      dist_name=${distName_BWP_PROFILE-133_PDCCH-1_PDCCH_CONFIG_COMMON-1}   list_name=searchSpaceCommon
    ${searchSpaceCommon_item1}=  Create Dictionary
    ...           coresetId                         0
    ...           dciFormat                         formats0-0-And-1-0
    ...           duration                          1
    ...           monitoringSymbolWithinSlot        symbol_0
    ...           numOfPdcchCandidatesInAL16        n0
    ...           numOfPdcchCandidatesInAL2         n0
    ...           numOfPdcchCandidatesInAL4         n2
    ...           numOfPdcchCandidatesInAL8         n0
    ...           periodicity                       sl1
    ...           searchSpaceId                     1
    ...           searchSpaceType                   Type0A
    ...           slotOffset                        0
    scf.add_item_to_list  dist_name=${distName_BWP_PROFILE-133_PDCCH-1_PDCCH_CONFIG_COMMON-1}  list_name=searchSpaceCommon
    ...  elements=${searchSpaceCommon_item1}
    ${searchSpaceCommon_item2}=  Create Dictionary
    ...           coresetId                    0
    ...           dciFormat                    formats0-0-And-1-0
    ...           duration                     1
    ...           monitoringSymbolWithinSlot   symbol_0_1
    ...           numOfPdcchCandidatesInAL16   n0
    ...           numOfPdcchCandidatesInAL2    n0
    ...           numOfPdcchCandidatesInAL4    n2
    ...           numOfPdcchCandidatesInAL8    n0
    ...           periodicity                  sl1
    ...           searchSpaceId                2
    ...           searchSpaceType              Type1
	...           slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_BWP_PROFILE-133_PDCCH-1_PDCCH_CONFIG_COMMON-1}  list_name=searchSpaceCommon
    ...  elements=${searchSpaceCommon_item2}
    ${searchSpaceCommon_item3}=  Create Dictionary
    ...           coresetId                    0
    ...           dciFormat                    formats0-0-And-1-0
    ...           duration                     1
    ...           monitoringSymbolWithinSlot   symbol_0
    ...           numOfPdcchCandidatesInAL16   n0
    ...           numOfPdcchCandidatesInAL2    n0
    ...           numOfPdcchCandidatesInAL4    n2
    ...           numOfPdcchCandidatesInAL8    n0
    ...           periodicity                  sl1
    ...           searchSpaceId                3
    ...           searchSpaceType              Type2
	...           slotOffset                   0
    scf.add_item_to_list  dist_name=${distName_BWP_PROFILE-133_PDCCH-1_PDCCH_CONFIG_COMMON-1}  list_name=searchSpaceCommon
    ...  elements=${searchSpaceCommon_item3}


Configure BWP Profile
    [Arguments]    ${profile_id}    ${periodicity_value}    ${slot_offset_value}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/${profile_id}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify_scf_element
    ...    value=${periodicity_value}
    ...    dist_name=${dist_name}
    ...    list_name=searchSpaceCommon
    ...    p_name=periodicity
    ...    index=2
    scf.modify_scf_element
    ...    value=${slot_offset_value}
    ...    dist_name=${dist_name}
    ...    list_name=searchSpaceCommon
    ...    p_name=slotOffset
    ...    index=2
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]

Configure GBR for SA UEs in SCF File
    ${distName_NRCELL}=    Get distNames from Local SCF File   scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        Set Element    dist_name=${dist_name}    p_name=actGBRAdmissionControl              value=GBRService
        Set Element    dist_name=${dist_name}    p_name=actVoNR                             value=true
        Set Element    dist_name=${dist_name}    p_name=actEnhancedVoNR                     value=true
        Set Element    dist_name=${dist_name}    p_name=actNonVoNRGbrService                value=true
        Set Element    dist_name=${dist_name}    p_name=actGbrRacTdEnhResourcePriority      value=false
        Set Element    dist_name=${dist_name}    p_name=maxNumOfGBRBearersSA                value=30
        Set Element    dist_name=${dist_name}    p_name=actVoNRIncCodingGain                value=false
    END
