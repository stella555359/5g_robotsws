*** Settings ***
Documentation    Common keywords for Transversal Robustness Test Cases helping to change SCF.xml

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Change Reporting Interval
    [Arguments]    ${interval_duration}
    Log  Changing Reporting Interval in scf.xml  console=yes
    ${distName_NRPMRNL}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality
    ...                                 miNrDlHarq  miNrUlHarq
    ...                                 miNrDlHarqLowSEMCS  miNrUlHarqLowSEMCS  miNrSignalQualityLowSEMCS
    ...                                 miNrPdcch  miNrResourceUtilizationPerCell   miNrPdcch2
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate Beamforming if needed
    IF   'CA FDD' in '${SUITE_NAME}'   RETURN    # <--- mixed-cell-setup
    Log  Activating Beamforming in scf.xml  console=yes
    ${distName_NRCELL}=       Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distName_NRCELLGRP}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELLGRP-[0-9]+
    Sort list   ${distName_NRCELL}
    Sort list   ${distName_NRCELLGRP}
    scf.modify scf element    dist_name=${distName_NRCELL[0]}      p_name=actBeamforming    value=true
    scf.modify scf element    dist_name=${distName_NRCELL[0]}      p_name=basicBeamSet      value=beamSet_6
    scf.modify scf element    dist_name=${distName_NRCELL[0]}      p_name=numberOfRxBeamforming      value=4Rx
    scf.modify scf element    dist_name=${distName_NRCELLGRP[0]}   p_name=ssBurstSetPeriod  value=20
    scf.modify scf element    dist_name=${distName_NRCELLGRP[0]}   p_name=numberOfTransmittedSsBlocks  value=6 beams


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate CB007449 if needed
    IF   'CA FDD' in '${SUITE_NAME}'   RETURN    # <--- mixed-cell-setup
    Log  Activating CB007449 in scf.xml  console=yes
    ${distName_NRBTS}=     Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distName_NRSYSINFO_PROFILE}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}
    ...                                                                    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRSYSINFO_PROFILE-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}    ${value}    IN
    ...    actSecDataUsageRep                    true
    ...    srbInactivityTimerSA                  600
    ...    saCellActivationAlarmTimer            600
    ...    t311                                  30000ms
    ...    tDCoverall                            5000
    ...    actFdmScheduling                      true
    ...    actFdmEnhancedScheduling              true
        Set Element   dist_name=${distName_NRBTS[0]}    p_name=${p_name}    value=${value}
    END
    Set Element    dist_name=${distName_NRSYSINFO_PROFILE[0]}     p_name=systemInformationTargetRate  value=0
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${NRCELL}    IN    @{distName_NRCELL}
        Configure Cell for CB007449 Feature   ${NRCELL}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_PROFILE_X}=   Get distNames from Local SCF File   scf_path=${original_gnb_scf}   regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{1}
    ${distName_PROFILE_XY}=  Get distNames from Local SCF File   scf_path=${original_gnb_scf}   regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}
    Configure PROFILE XY for CB007449 Feature   ${distName_PROFILE_XY[0]}
    ${isObject}=    scf.is_object_in_scf    ${distName_PROFILE_X[0]}
    IF   ${isObject}   Configure PROFILE X for CB007449 Feature   ${distName_PROFILE_X[0]}


Configure Cell for CB007449 Feature
    [Arguments]  ${distName}
    FOR    ${p_name}    ${value}    IN
    ...    dlMimoMode                            4x4 or 4x2 Open Loop Spatial Multiplexing
    ...    nrCellType                            4DL4UL
    ...    actSpeculativeDtx                     disabled
    ...    actPerCsiReportBundlingTddFr1         true
    ...    actPrachMultiplexing                  true
    ...    actIncreasedFdmUsersPerSlot           true
    ...    actLongPucchPhase2                    true
    ...    maxNumPdschAllocationPerSlot          8
    ...    maxNumPuschAllocationPerSlot          8
    ...    msg1FrequencyStart                    26
    ...    pucchModeSelect                       longPucch
    ...    reqMinNumPuschPrb                     221
    ...    ssPbchBlockPower                      7
    ...    prachConfigurationIndex               92
    ...    pucchF3MaxCodeRate                    zeroDot25
    ...    pucchF3ModulationScheme               pi2bpsk
    ...    reqMinNumPuschPrb                     13
    ...    srPeriodicity                         slots20
    ...    csiReportPeriodicity                  slots40
        Set Element   dist_name=${distName}    p_name=${p_name}    value=${value}
    END


Configure PROFILE X for CB007449 Feature
    [Arguments]  ${distName_PROFILE_4}
    ${distName_PROFILE_4_PDCCH_CONFIG_COMMON}=   Set variable  ${distName_PROFILE_4}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    Set List   dist_name=${distName_PROFILE_4_PDCCH_CONFIG_COMMON}   list_name=searchSpaceCommon
    ${searchSpaceCommon_item1}=  create dictionary
    ...    coresetId                    0
    ...    dciFormat                    formats0-0-And-1-0
    ...    duration                     3
    ...    monitoringSymbolWithinSlot   symbol_0
    ...    numOfPdcchCandidatesInAL16   n0
    ...    numOfPdcchCandidatesInAL2    n0
    ...    numOfPdcchCandidatesInAL4    n2
    ...    numOfPdcchCandidatesInAL8    n0
    ...    periodicity                  sl5
    ...    searchSpaceId                1
    ...    searchSpaceType              Type0A
    ...    slotOffset                   0
    ${searchSpaceCommon_item2}=  create dictionary
    ...    coresetId                    0
    ...    dciFormat                    formats0-0-And-1-0
    ...    duration                     1
    ...    monitoringSymbolWithinSlot   symbol_0_1
    ...    numOfPdcchCandidatesInAL16   n0
    ...    numOfPdcchCandidatesInAL2    n0
    ...    numOfPdcchCandidatesInAL4    n4
    ...    numOfPdcchCandidatesInAL8    n0
    ...    periodicity                  sl1
    ...    searchSpaceId                2
    ...    searchSpaceType              Type1
    ...    slotOffset                   0
    ${searchSpaceCommon_item3}=  create dictionary
    ...    coresetId                    0
    ...    dciFormat                    formats0-0-And-1-0
    ...    duration                     3
    ...    monitoringSymbolWithinSlot   symbol_0
    ...    numOfPdcchCandidatesInAL16   n0
    ...    numOfPdcchCandidatesInAL2    n0
    ...    numOfPdcchCandidatesInAL4    n2
    ...    numOfPdcchCandidatesInAL8    n0
    ...    periodicity                  sl5
    ...    searchSpaceId                3
    ...    searchSpaceType              Type2
    ...    slotOffset                   0
    scf.add_item_to_list    dist_name=${distName_PROFILE_4_PDCCH_CONFIG_COMMON}   list_name=searchSpaceCommon   elements=${searchSpaceCommon_item1}
    scf.add_item_to_list    dist_name=${distName_PROFILE_4_PDCCH_CONFIG_COMMON}   list_name=searchSpaceCommon   elements=${searchSpaceCommon_item2}
    scf.add_item_to_list    dist_name=${distName_PROFILE_4_PDCCH_CONFIG_COMMON}   list_name=searchSpaceCommon   elements=${searchSpaceCommon_item3}


Configure PROFILE XY for CB007449 Feature
    [Arguments]  ${distName_PROFILE_44}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=${distName_PROFILE_44}/PDCCH-1   p_name=dciDedicatedAggregationLevel          value=AL2
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_PROFILE_44_PDCCH_CONFIG_COMMON}=  Set variable  ${distName_PROFILE_44}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    Set List   dist_name=${distName_PROFILE_44_PDCCH_CONFIG_COMMON}   list_name=searchSpaceCommon
    ${searchSpaceCommon_item1}=  create dictionary
    ...    coresetId                    0
    ...    dciFormat                    formats0-0-And-1-0
    ...    duration                     3
    ...    monitoringSymbolWithinSlot   symbol_0
    ...    numOfPdcchCandidatesInAL16   n0
    ...    numOfPdcchCandidatesInAL2    n0
    ...    numOfPdcchCandidatesInAL4    n2
    ...    numOfPdcchCandidatesInAL8    n0
    ...    periodicity                  sl5
    ...    searchSpaceId                4
    ...    searchSpaceType              Type0A
    ...    slotOffset                   0
    ${searchSpaceCommon_item2}=  create dictionary
    ...    coresetId                    0
    ...    dciFormat                    formats0-0-And-1-0
    ...    duration                     1
    ...    monitoringSymbolWithinSlot   symbol_0_1
    ...    numOfPdcchCandidatesInAL16   n0
    ...    numOfPdcchCandidatesInAL2    n0
    ...    numOfPdcchCandidatesInAL4    n4
    ...    numOfPdcchCandidatesInAL8    n0
    ...    periodicity                  sl1
    ...    searchSpaceId                5
    ...    searchSpaceType              Type1
    ...    slotOffset                   0
    ${searchSpaceCommon_item3}=  create dictionary
    ...    coresetId                    0
    ...    dciFormat                    formats0-0-And-1-0
    ...    duration                     3
    ...    monitoringSymbolWithinSlot   symbol_0
    ...    numOfPdcchCandidatesInAL16   n1
    ...    numOfPdcchCandidatesInAL2    n0
    ...    numOfPdcchCandidatesInAL4    n2
    ...    numOfPdcchCandidatesInAL8    n0
    ...    periodicity                  sl5
    ...    searchSpaceId                6
    ...    searchSpaceType              Type2
    ...    slotOffset                   0
    scf.add_item_to_list    dist_name=${distName_PROFILE_44_PDCCH_CONFIG_COMMON}   list_name=searchSpaceCommon   elements=${searchSpaceCommon_item1}
    scf.add_item_to_list    dist_name=${distName_PROFILE_44_PDCCH_CONFIG_COMMON}   list_name=searchSpaceCommon   elements=${searchSpaceCommon_item2}
    scf.add_item_to_list    dist_name=${distName_PROFILE_44_PDCCH_CONFIG_COMMON}   list_name=searchSpaceCommon   elements=${searchSpaceCommon_item3}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_PROFILE_44_PDCCH_DEDICATED}=  Set variable  ${distName_PROFILE_44}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    Set List   dist_name=${distName_PROFILE_44_PDCCH_DEDICATED}   list_name=coresetDedicated
    ${coresetDedicated_item}=  create dictionary
    ...    cceToRegMapping              nonInterleaved
    ...    coresetId                    1
    ...    cRbStart                     0
    ...    duration                     1
    ...    interleaverSize              none
    ...    regBundleSize                n6
    ...    size                         120
    scf.add_item_to_list  dist_name=${distName_PROFILE_44_PDCCH_DEDICATED}  list_name=coresetDedicated  elements=${coresetDedicated_item}
    Set List   dist_name=${distName_PROFILE_44_PDCCH_DEDICATED}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}=  create dictionary
    ...    coresetId                        0
    ...    dciFormat                        formats0-0-And-1-0
    ...    duration                         1
    ...    monitoringSymbolWithinSlot       symbol_0_1
    ...    numOfPdcchCandidatesInAL1        n0
    ...    numOfPdcchCandidatesInAL16       n0
    ...    numOfPdcchCandidatesInAL2        n4
    ...    numOfPdcchCandidatesInAL4        n2
    ...    numOfPdcchCandidatesInAL8        n0
    ...    periodicity                      sl1
    ...    searchSpaceId                    7
    ...    searchSpaceType                  Type3
    ...    slotOffset                       0
    ${searchSpaceDedicated_item2}=  create dictionary
    ...    coresetId                        1
    ...    dciFormat                        formats0-1-And-1-1
    ...    duration                         1
    ...    monitoringSymbolWithinSlot       symbol_0_1
    ...    numOfPdcchCandidatesInAL1        n0
    ...    numOfPdcchCandidatesInAL16       n0
    ...    numOfPdcchCandidatesInAL2        n8
    ...    numOfPdcchCandidatesInAL4        n5
    ...    numOfPdcchCandidatesInAL8        n0
    ...    periodicity                      sl1
    ...    searchSpaceId                    8
    ...    searchSpaceType                  UE-Specific
    ...    slotOffset                       0
    scf.add_item_to_list  dist_name=${distName_PROFILE_44_PDCCH_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}
    scf.add_item_to_list  dist_name=${distName_PROFILE_44_PDCCH_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate 4DL4UL if needed
    IF   'CA FDD' in '${SUITE_NAME}'   RETURN    # <--- mixed-cell-setup
    Log  Activating 4DL4UL in scf.xml  console=yes
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR    ${NRCELL}    IN    @{distName_NRCELL}
        Configure each Cell for 4DL4UL     ${NRCELL}
        ${cellNumber}=    get substring    ${NRCELL}    -1
        Modify CHANNELGROUP-1 for 4DL4UL   ${cellNumber}
    END


Configure each Cell for 4DL4UL
    [Arguments]  ${distName}
    FOR    ${p_name}    ${value}    IN
    ...    dlMimoMode                            4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    nrCellType                            4DL4UL
        Set Element   dist_name=${distName}    p_name=${p_name}    value=${value}
    END


Modify CHANNELGROUP-1 for 4DL4UL
    [Arguments]  ${cellNumber}
    FOR  ${channelId}  IN RANGE  1   5
        ${distName_CHANNEL}=  Set variable  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellNumber}/CHANNELGROUP-1/CHANNEL-${channelId}
        Set Object    class_name=com.nokia.srbts.mnl:CHANNEL
        ...           dist_name=${distName_CHANNEL}
        ...           version=NRBTSCL23R3_2305_100
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=direction
        ...           value=TX
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=resourceDN
        ...           value=MRBTS-1/EQM-1/APEQM-1/RMOD-${cellNumber}/PHYANT-1
    END
    FOR  ${channelId}  IN RANGE  5   9
        ${distName_CHANNEL}=  Set variable  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellNumber}/CHANNELGROUP-1/CHANNEL-${channelId}
        Set Object    class_name=com.nokia.srbts.mnl:CHANNEL
        ...           dist_name=${distName_CHANNEL}
        ...           version=NRBTSCL23R3_2305_100
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=direction
        ...           value=RX
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=resourceDN
        ...           value=MRBTS-1/EQM-1/APEQM-1/RMOD-${cellNumber}/PHYANT-1
    END


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
