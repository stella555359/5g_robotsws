*** Settings ***
Documentation
...   Test Suite Purpose:
...   Feature 5GC0000937-A BandWidth Saving Testing
...   DESCRIPTION:Feature 5GC0000937-A automated regression testing
...   AUTHOR (mmW&SC Pz NPS 4 SG):          I_MNP_5G_NPS_IVU_SISO_MOBILITY@nokia.com

Resource                                    ../resources/common_settings.robot
Resource      taf/rfrl/common_resources/common_step/interface.robot


Force Tags      			    CA_RAN_PZ_NPS   QCD_MN_RAN   QCP_RAN_ST   SBTS00

Suite Setup                                 Preconditions of Suite Scenario 5GC000937_A_2
Suite Teardown                              Postconditions of Suite Scenario 5GC000937_A_2

*** Variables ***
# Logical mapping
# ${source_enb_id}                          1            # <give source enb_id, for example 0>
# ${source_enb_vlan_id}                     3002         # <give source_enb_vlan_id for exemple 3006>
${source_gnb_id}                            0            # <give soruce gnb_id, for example 0>
# ${source_du_id}                                        # <give source gnb_id du_id (cloud gnb), for example 0>
${source_distName}                          NRCELL-1     # <give source nrcell, for example NRCELL-1>
#${source_distName}                          NRCELL-2     # <give source nrcell, for example NRCELL-2>
# ${source_distName_enb}                    LNCEL-1      # <give source enb cell for exemple LNCEL-1
# ${source_distName_du}                                  # <give source nrcell_id in DU (cloud gnb), for example NRCELL-1>
${nrcellgrp_source_distName}                NRCELLGRP-0  # <give source nrcellgrp_id, for example NRCELLGRP-0>

${ue_id}     UE_1

*** Test Cases ***
[1][1.0] 5GC000937_A_21_Check_5GC000937_Deactivation_on_WebEM
    [Setup]	  Run Keywords    preconditions.Get Scout Bts Name    Preconditions of Test Scenario 5GC000937_A_2
    [Timeout]                         30min

    update actPowerSavingBWP flag   ${gnb_${source_gnb_id}_bts_distName}/${source_distName}   ${source_gnb_id}   false
    Wait until coam gNB to be onair state and cells enabled ext01   gnb_id=${source_gnb_id}   num_of_disabled_cells=0
    Run keyword and ignore error    Perform Attach Ue And Check Nr5g Bearer Is Up    trace_duration=20s    ue_alias=${ue_id}
    Analysis step1

    [Teardown]    Run Keywords    preconditions.Set Scout Confid Id    Postconditions of Test Scenario 5GC000937_A_2


*** Keywords ***
Preconditions of Suite Scenario 5GC000937_A_2
    Run     rm /tmp/5GC000937A0*
    Create Test Suite Folders
    keywordbook-480_ext01.Get test variables and upload start SCF Ext01
    ${source_cellId}       Extract cellIndex from cellDistName ext01    ${source_distName}
    ${source_physCellId}   Get physCellId from SCF ext01     gnb_id=${source_gnb_id}  cellDistName=${source_distName}
    Set Suite Variable    ${source_cellId}
    Set Suite Variable    ${source_physCellId}
    Run Keyword if    '${DEBUG}'=='False'    Hytem Initialization
    Attach QCAT 5G Licence with LK

Preconditions of Test Scenario 5GC000937_A_2
    Create a Test Scenario Folder
    Run Keyword if    '${DEBUG}'=='False'    Set Hytem Attenuations for gNB 0 cell ${source_cellId}    value=0000
    Prepare counters and expected values 5GC000937_A_2
    Ue Initialization    ue_alias=${ue_id}    capabilities=REAL_UE

Postconditions of Test Scenario 5GC000937_A_2
    #Run keyword and ignore error    Wait ULDL UDP over and Verify Tput
    Run Keyword If    '${TEST_STATUS}'=='PASS'    Run    touch /tmp/5GC000937A021_success
    Run Keyword if    '${DEBUG}'=='False'   Report test result to reporting portal    log_dir=${OUTPUT DIR}     gnb_id=${source_gnb_id}

Postconditions of Suite Scenario 5GC000937_A_2
    Run keyword and ignore error    Perform Detach Ue
    Run keyword and ignore error    Detach QCAT 5G Licence with LK
    Run Keyword if    '${DEBUG}'=='False' and '${SUITE STATUS}'=='FAIL'    Collect snapshot coam ext01    gnb_id=${source_gnb_id}
    Run Keyword if    '${DEBUG}'=='False' and '${SUITE STATUS}'=='FAIL' and '${NO_ENB}'=='False'  Collect snapshot enb    enb_id=${source_enb_id}
    restore parameter values with full commissioning ext01
    Wait until coam gNB to be onair state and cells enabled ext01   gnb_id=${source_gnb_id}   num_of_disabled_cells=0
    interface.Common step trigger


Prepare counters and expected values 5GC000937_A_2
    # Source gNB:
    # -----------
    # distName="MRBTS-xxx/NRBTS-yyy"
    set test variable    @{actCarrierAggregation}               ${source_gnb_id}   false
    set test variable    @{cbraPreamblesPerSsb}                 ${source_gnb_id}   n32
    set test variable    @{dlBufferEmptyRatioFromPsBwp}         ${source_gnb_id}   40              # list name="powerSavingBwpSwitching
    set test variable    @{dlBufferEmptyRatioToPsBwp}           ${source_gnb_id}   90              # list name="powerSavingBwpSwitching
    set test variable    @{dlRateThresholdFromPsBwp}            ${source_gnb_id}   35              # list name="powerSavingBwpSwitching
    set test variable    @{dlRateThresholdToPsBwp}              ${source_gnb_id}   30              # list name="powerSavingBwpSwitching
    set test variable    @{measurementDurationFromPsBwp}        ${source_gnb_id}   40              # list name="powerSavingBwpSwitching
    set test variable    @{measurementDurationToPsBwp}          ${source_gnb_id}   160             # list name="powerSavingBwpSwitching
    set test variable    @{ulRateThresholdNoVoNRFromPsBwp}      ${source_gnb_id}   10              # list name="powerSavingBwpSwitching
    set test variable    @{ulRateThresholdNoVoNRToPsBwp}        ${source_gnb_id}   5               # list name="powerSavingBwpSwitching
    set test variable    @{ulRateThresholdVoNRFromPsBwp}        ${source_gnb_id}   35              # list name="powerSavingBwpSwitching
    set test variable    @{ulRateThresholdVoNRToPsBwp}          ${source_gnb_id}   30              # list name="powerSavingBwpSwitching

    # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51"
    set test variable    @{bwpType}                             ${source_gnb_id}   powerSaving
    set test variable    @{cRbSizeDl}                           ${source_gnb_id}   n106            # list name="locationAndBandwidthDl
    set test variable    @{cRbStartDl}                          ${source_gnb_id}   crb0            # list name="locationAndBandwidthDl
    set test variable    @{cRbSizeUl}                           ${source_gnb_id}   n106            # list name="locationAndBandwidthUl
    set test variable    @{cRbStartUl}                          ${source_gnb_id}   sameAsDl        # list name="locationAndBandwidthUl

    # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51/PDCCH-1"
    set test variable    @{alSelection}                         ${source_gnb_id}   static</p>
    set test variable    @{dciDedicatedAggregationLevel}        ${source_gnb_id}   AL4
    set test variable    @{dciPagingAggregationLevel}           ${source_gnb_id}   AL4
    set test variable    @{dciRaCompletionAggregationLevel}     ${source_gnb_id}   AL4
    set test variable    @{dciRaMsg2AggregationLevel}           ${source_gnb_id}   AL4
    set test variable    @{dciSiAggregationLevel}               ${source_gnb_id}   AL4
    set test variable    @{downgradeAL16toAL8}                  ${source_gnb_id}   notAllowed
    set test variable    @{aggregationLevelList}                ${source_gnb_id}   AL2_AL4         # list name="dynamicAggregationLevelSet
    set test variable    @{cqiCorrectionUp}                     ${source_gnb_id}   10              # list name="dynamicAggregationLevelSet
    set test variable    @{cqiDciCssAl1}                        ${source_gnb_id}   159             # list name="dynamicAggregationLevelSet
    set test variable    @{cqiDciCssAl16}                       ${source_gnb_id}   159             # list name="dynamicAggregationLevelSet
    set test variable    @{cqiDciCssAl2}                        ${source_gnb_id}   159             # list name="dynamicAggregationLevelSet
    set test variable    @{cqiDciCssAl4}                        ${source_gnb_id}   159             # list name="dynamicAggregationLevelSet
    set test variable    @{cqiDciCssAl8}                        ${source_gnb_id}   159             # list name="dynamicAggregationLevelSet
    set test variable    @{highOlcCqiOffset}                    ${source_gnb_id}   1               # list name="dynamicAggregationLevelSet
    set test variable    @{lowOlcCqiOffset}                     ${source_gnb_id}   1               # list name="dynamicAggregationLevelSet
    set test variable    @{pCqiErasureActTimer}                 ${source_gnb_id}   0               # list name="dynamicAggregationLevelSet
    set test variable    @{pCqiErasureReduction}                ${source_gnb_id}   0               # list name="dynamicAggregationLevelSet

    # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_COMMON-1
    set test variable    @{coresetId}                           ${source_gnb_id}   0               # list name="searchSpaceCommon item0
    set test variable    @{dciFormat}                           ${source_gnb_id}   formats0-0-And-1-0  # list name="searchSpaceCommon item0
    set test variable    @{duration}                            ${source_gnb_id}   3               # list name="searchSpaceCommon item0
    set test variable    @{monitoringSymbolWithinSlot}          ${source_gnb_id}   symbol_0        # list name="searchSpaceCommon item0
    set test variable    @{numOfPdcchCandidatesInAL16}          ${source_gnb_id}   n0              # list name="searchSpaceCommon item0
    set test variable    @{numOfPdcchCandidatesInAL2}           ${source_gnb_id}   n0              # list name="searchSpaceCommon item0
    set test variable    @{numOfPdcchCandidatesInAL4}           ${source_gnb_id}   n2              # list name="searchSpaceCommon item0
    set test variable    @{numOfPdcchCandidatesInAL8}           ${source_gnb_id}   n1              # list name="searchSpaceCommon item0
    set test variable    @{periodicity}                         ${source_gnb_id}   sl5             # list name="searchSpaceCommon item0
    set test variable    @{searchSpaceId}                       ${source_gnb_id}   9               # list name="searchSpaceCommon item0
    set test variable    @{searchSpaceType}                     ${source_gnb_id}   Type0A          # list name="searchSpaceCommon item0
    set test variable    @{slotOffset}                          ${source_gnb_id}   0               # list name="searchSpaceCommon item0
    set test variable    @{coresetId}                           ${source_gnb_id}   0               # list name="searchSpaceCommon item1
    set test variable    @{dciFormat}                           ${source_gnb_id}   formats0-0-And-1-0  # list name="searchSpaceCommon item1
    set test variable    @{duration}                            ${source_gnb_id}   1               # list name="searchSpaceCommon item1
    set test variable    @{monitoringSymbolWithinSlot}          ${source_gnb_id}   symbol_0_1      # list name="searchSpaceCommon item1
    set test variable    @{numOfPdcchCandidatesInAL16}          ${source_gnb_id}   n0              # list name="searchSpaceCommon item1
    set test variable    @{numOfPdcchCandidatesInAL2}           ${source_gnb_id}   n0              # list name="searchSpaceCommon item1
    set test variable    @{numOfPdcchCandidatesInAL4}           ${source_gnb_id}   n2              # list name="searchSpaceCommon item1
    set test variable    @{numOfPdcchCandidatesInAL8}           ${source_gnb_id}   n0              # list name="searchSpaceCommon item1
    set test variable    @{periodicity}                         ${source_gnb_id}   sl1             # list name="searchSpaceCommon item1
    set test variable    @{searchSpaceId}                       ${source_gnb_id}   10              # list name="searchSpaceCommon item1
    set test variable    @{searchSpaceType}                     ${source_gnb_id}   Type1           # list name="searchSpaceCommon item1
    set test variable    @{slotOffset}                          ${source_gnb_id}   0               # list name="searchSpaceCommon item1
    set test variable    @{coresetId}                           ${source_gnb_id}   0               # list name="searchSpaceCommon item2
    set test variable    @{dciFormat}                           ${source_gnb_id}   formats0-0-And-1-0  # list name="searchSpaceCommon item2
    set test variable    @{duration}                            ${source_gnb_id}   3               # list name="searchSpaceCommon item2
    set test variable    @{monitoringSymbolWithinSlot}          ${source_gnb_id}   symbol_0        # list name="searchSpaceCommon item2
    set test variable    @{umOfPdcchCandidatesInAL16}           ${source_gnb_id}   n0              # list name="searchSpaceCommon item2
    set test variable    @{numOfPdcchCandidatesInAL2}           ${source_gnb_id}   n0              # list name="searchSpaceCommon item2
    set test variable    @{numOfPdcchCandidatesInAL4}           ${source_gnb_id}   n2              # list name="searchSpaceCommon item2
    set test variable    @{numOfPdcchCandidatesInAL8}           ${source_gnb_id}   n1              # list name="searchSpaceCommon item2
    set test variable    @{periodicity}                         ${source_gnb_id}   sl5             # list name="searchSpaceCommon item2
    set test variable    @{searchSpaceId}                       ${source_gnb_id}   11              # list name="searchSpaceCommon item2
    set test variable    @{searchSpaceType}                     ${source_gnb_id}   Type2           # list name="searchSpaceCommon item2
    set test variable    @{slotOffset}                          ${source_gnb_id}   0               # list name="searchSpaceCommon item2

    # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    set test variable    @{cceToRegMapping}                     ${source_gnb_id}   nonInterleaved  # list name="coresetDedicated
    set test variable    @{coresetId}                           ${source_gnb_id}   4               # list name="coresetDedicated
    set test variable    @{cRbStart}                            ${source_gnb_id}   0               # list name="coresetDedicated
    set test variable    @{duration}                            ${source_gnb_id}   1               # list name="coresetDedicated
    set test variable    @{interleaverSize}                     ${source_gnb_id}   none            # list name="coresetDedicated
    set test variable    @{regBundleSize}                       ${source_gnb_id}   n6              # list name="coresetDedicated
    set test variable    @{size}                                ${source_gnb_id}   96              # list name="coresetDedicated
    set test variable    @{coresetId}                           ${source_gnb_id}   0               # list name="searchSpaceDedicated item0
    set test variable    @{dciFormat}                           ${source_gnb_id}   formats0-0-And-1-0  # list name="searchSpaceDedicated item0
    set test variable    @{duration}                            ${source_gnb_id}   1               # list name="searchSpaceDedicated item0
    set test variable    @{monitoringSymbolWithinSlot}          ${source_gnb_id}   symbol_0_1      # list name="searchSpaceDedicated item0
    set test variable    @{numOfPdcchCandidatesInAL1}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item0
    set test variable    @{numOfPdcchCandidatesInAL16}          ${source_gnb_id}   n0              # list name="searchSpaceDedicated item0
    set test variable    @{numOfPdcchCandidatesInAL2}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item0
    set test variable    @{numOfPdcchCandidatesInAL4}           ${source_gnb_id}   n2              # list name="searchSpaceDedicated item0
    set test variable    @{numOfPdcchCandidatesInAL8}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item0
    set test variable    @{periodicity}                         ${source_gnb_id}   sl1             # list name="searchSpaceDedicated item0
    set test variable    @{searchSpaceId}                       ${source_gnb_id}   12              # list name="searchSpaceDedicated item0
    set test variable    @{searchSpaceType}                     ${source_gnb_id}   Type3           # list name="searchSpaceDedicated item0
    set test variable    @{slotOffset}                          ${source_gnb_id}   0               # list name="searchSpaceDedicated item0
    set test variable    @{coresetId}                           ${source_gnb_id}   4               # list name="searchSpaceDedicated item1
    set test variable    @{dciFormat}                           ${source_gnb_id}   formats0-1-And-1-1  # list name="searchSpaceDedicated item1
    set test variable    @{duration}                            ${source_gnb_id}   1               # list name="searchSpaceDedicated item1
    set test variable    @{monitoringSymbolWithinSlot}          ${source_gnb_id}   symbol_0_1      # list name="searchSpaceDedicated item1
    set test variable    @{numOfPdcchCandidatesInAL1}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item1
    set test variable    @{numOfPdcchCandidatesInAL16}          ${source_gnb_id}   n0              # list name="searchSpaceDedicated item1
    set test variable    @{numOfPdcchCandidatesInAL2}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item1
    set test variable    @{numOfPdcchCandidatesInAL4}           ${source_gnb_id}   n2              # list name="searchSpaceDedicated item1
    set test variable    @{numOfPdcchCandidatesInAL8}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item1
    set test variable    @{periodicity}                         ${source_gnb_id}   sl1             # list name="searchSpaceDedicated item1
    set test variable    @{searchSpaceId}                       ${source_gnb_id}   13              # list name="searchSpaceDedicated item1
    set test variable    @{searchSpaceType}                     ${source_gnb_id}   UE-Specific     # list name="searchSpaceDedicated item1
    set test variable    @{slotOffset}                          ${source_gnb_id}   0               # list name="searchSpaceDedicated item1

    # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51/PDSCH-1
    set test variable    @{pdschRat0RbgConfig}                  ${source_gnb_id}   config1

    # distName="MRBTS-xxx/NRBTS-yyy/NRCELL-z"
    set test variable    @{actCDrx}                             ${source_gnb_id}   false
    set test variable    @{cellDepType}                         ${source_gnb_id}   SA
    set test variable    @{cellTechnology}                      ${source_gnb_id}   TDD
    set test variable    @{chBw}                                ${source_gnb_id}   100MHz
    set test variable    @{nrarfcn}                             ${source_gnb_id}   663334          # il faut aussi regarder NRCELL-2 !!!
    set test variable    @{frameStructureType}                  ${source_gnb_id}   semiStatic      # list name="tddFrameStructure
    set test variable    @{guardPeriodLength}                   ${source_gnb_id}   2Symbols        # list name="tddFrameStructure
    set test variable    @{ulDlDataSlotRatio}                   ${source_gnb_id}   1/4             # list name="tddFrameStructure
    set test variable    @{actPRBBlanking}                      ${source_gnb_id}   false
    set test variable    @{lteNrDssMode}                        ${source_gnb_id}   none
    set test variable    @{actPowerSavingBWP}                   ${source_gnb_id}   true
    set test variable    @{actPdschAtSsbSlots}                  ${source_gnb_id}   false
    set test variable    @{actPdschRmCsirsForTracking}          ${source_gnb_id}   false
    set test variable    @{actpucchModeSelect}                  ${source_gnb_id}   longPucch
    set test variable    @{bwpDN_0}                             ${source_gnb_id}   BWP_PROFILE-5   # list name="cellBwpList item0
    set test variable    @{cellBwpId_0}                         ${source_gnb_id}   0               # list name="cellBwpList item0
    set test variable    @{bwpDN_1}                             ${source_gnb_id}   BWP_PROFILE-54  # list name="cellBwpList item1
    set test variable    @{cellBwpId_1}                         ${source_gnb_id}   1               # list name="cellBwpList item1
    set test variable    @{bwpDN_2}                             ${source_gnb_id}   BWP_PROFILE-51  # list name="cellBwpList item2
    set test variable    @{cellBwpId_2}                         ${source_gnb_id}   2               # list name="cellBwpList item2


    set test variable    @{M55351C00001_src}    MAX_UE_ACTIVE_PWR_SAVING_BWP      1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C01001_src}    MAX_UE_CONFIG_2BWP                1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C00002_src}    AVG_UE_ACTIVE_PWR_SAVING_BWP      1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C01002_src}    AVG_UE_CONFIG_2BWP                1    ${source_gnb_id}   ${source_distName}   DBWP   egal

Check nrcell cellBwpList info
    [Arguments]      ${dist_name}     ${gnb_id}
    set test variable    ${scfini}    ${resultBaseDir}/SCFC_start_gnb_${gnb_id}.xml
    load_scf    ${scfini}
    ${l_cellBwpId}     scf.get_all_values_from_scf    dist_name=${dist_name}   list_name=cellBwpList   p_name=cellBwpId
    ${l_bwpDN}         scf.get_all_values_from_scf    dist_name=${dist_name}   list_name=cellBwpList   p_name=bwpDN
    ${length1} = 	Get Length 	${l_cellBwpId}
    Should Be Equal As Integers 	${length1} 	3
    ${length2} = 	Get Length 	${l_BwpDN}
    Should Be Equal As Integers 	${length2} 	3
    Log to console    \nl_cellBwpId is :\n${l_cellBwpId}
    Log to console      l_bwpDN is :\n${l_bwpDN}

    ${l_bwpType_values}   create list
    FOR    ${i}   IN RANGE    ${length2}
        # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51"
        ${value}   scf.get_all_values_from_scf
        ...    dist_name=${l_bwpDN}[${i}]
        ...    p_name=bwpType
        Append To List    ${l_bwpType_values}    ${value}[0]
    END
    Log to console    \n
    Log to console    -------------------- l_bwpType_values --------------------------
    Log to console    ${l_bwpType_values}
    Log to console    ----------------------------------------------------------------
    Should Contain 	  ${l_bwpType_values} 	${bwpType}[1] 	msg=ERROR: No Power Saving BW PROFILE detected in scf !!!
    Log to console    Power Saving BW PROFILE detection in scf OK\n

Update actPowerSavingBWP flag
    [Arguments]      ${dist_name}     ${gnb_id}    ${status}=false
    set test variable   ${nrcell_dist}     ${gnb_${gnb_id}_bts_distName}/${source_distName}
    Check nrcell cellBwpList info     ${nrcell_dist}     ${gnb_id}

    ${actPowerSavingBWP_mo}      create dictionary
    ...    dist_name    ${distName}
    ...    parameter    actPowerSavingBWP
    ...    value        ${status}
    ${param_list}     Create List
    ...    ${actPowerSavingBWP_mo}
    json delta commissioning coam ext01       ${param_list}    ${gnb_id}

Start Bidirectional Traffic
    Log To Console    \nStart Traffic Bidirectional Started
    Start ULDL UDP    UE
    Log to console    Bidirectional Traffic UDP, Wait 3 seconds rampup before proceed next step\n
    Sleep   3s

Analysis step1
    # In Ue logs check rrcReconf DO NOT reconfigure Ue with a Power Saving BWP
    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCReconfiguration    ${dlBwpId1}    100000000000
    Should Be True    '${status}' == 'True'   Error : dlBwpId1 : ${dlBwpId1} NOT FOUND !!!
    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCReconfiguration    ${ulBwpId1}    100000000000
    Should Be True    '${status}' == 'True'   Error : ulBwpId1 : ${ulBwpId1} NOT FOUND !!!
    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCReconfiguration    ${dlBwpId2}    100000000000
    Should Be True   '${status}' == 'False'   Error : dlBwpId2 : ${dlBwpId2} FOUND !!!
    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCReconfiguration    ${ulBwpId2}    100000000000
    Should Be True    '${status}' == 'False'   Error : ulBwpId2 : ${ulBwpId2} FOUND !!!
