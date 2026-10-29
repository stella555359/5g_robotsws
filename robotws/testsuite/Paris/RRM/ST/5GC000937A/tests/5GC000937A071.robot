*** Settings ***
Documentation
...   Test Suite Purpose:
...   Feature 5GC0000937-A BandWidth Saving Testing
...   DESCRIPTION:Feature 5GC0000937-A automated regression testing
...   AUTHOR (mmW&SC Pz NPS 4 SG):          I_MNP_5G_NPS_IVU_SISO_MOBILITY@nokia.com

Resource                                    ../resources/common_settings.robot
Force Tags                                  QCD_MN_5G    QCP_5G     CA_5G_IVPS

Suite Setup                                 Preconditions of Suite Scenario 5GC000937A7
Suite Teardown                              Postconditions of Suite Scenario 5GC000937A7


*** Variables ***
# Logical mapping
# ${source_enb_id}                                       # <give source enb_id, for example 0>
# ${source_enb_vlan_id}                                  # <give source_enb_vlan_id for exemple 3006>
${source_gnb_id}                            0            # <give soruce gnb_id, for example 0>
${source_du_id}                             0            # <give source gnb_id du_id (cloud gnb), for example 0>
${source_distName}                          NRCELL-2     # <give source nrcell, for example NRCELL-2>
# ${source_distName_enb}                                 # <give source enb cell for exemple LNCEL-1
# ${source_distName_du}                                  # <give source nrcell_id in DU (cloud gnb), for example NRCELL-1>
${nrcellgrp_source_distName}                NRCELLGRP-0  # <give source nrcellgrp_id, for example NRCELLGRP-0>

# ${target_enb_id}                                       # <give target enb_id, for example 0>
# ${target_enb_vlan_id}                                  # <give source_enb_vlan_id for exemple 3006>
${target_gnb_id}                            0            # <give target gnb_id, for example 0>
${target_du_id}                             0            # <give target gnb_id du_id (cloud gnb), for example 0>
${target_distName}                          NRCELL-1     # <give target nrcell, for example NRCELL-2>
# ${target_distName_enb}                                 # <give target enb cell for exemple LNCEL-1
# ${target_distName_du}                                  # <give target nrcell_id in DU (cloud gnb), for example NRCELL-1>
${nrcellgrp_target_distName}                NRCELLGRP-1  # <give target nrcellgrp_id, for example NRCELLGRP-0>

${ue_id}     UE_1

*** Test Cases ***
[1]5GC000937-A_7_Verify_SingleUE_intraGnb_interFreq_HO_with_UE_in_the_large_BWP
    [Setup]	  Run Keywords    preconditions.Get Scout Bts Name    Preconditions of Test Scenario 5GC000937A7
    [Timeout]     60min

    # Step1: Call Setup on source_cell
    # --------------------------------
    Wait until coam gNB to be onair state and cells enabled ext01   gnb_id=${source_gnb_id}   num_of_disabled_cells=0
    wait until keyword succeeds  1200s  30s  Start Call
    Analyse step1
    # From this point gNB/UE should use Power Saving BWP and DT_UL start time should be synchronized with pm obs period
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    Sleep    200s
    ute_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_id}  direction=ul  duration=1260s
    ...    throughput=10 Kbits/sec    protocol=${protocol}	  packet_size=${Packet_Size}    qci=${qci_ul}
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_id}  direction=dl  duration=1260s
    ...    throughput=300 Kbits/sec     protocol=${protocol}  packet_size=${Packet_Size}    qci=${qci_dl}

    # Step2: Data Transfer DL/UL then Ping Inter Freq Intra gNB Mobility
    # ------------------------------------------------------------------
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    run Keyword    Set Hytem Attenuations for gNB ${source_gnb_id} cell ${source_cellId}    value=5000
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_UL
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_DL

    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_UL
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_DL
    Start Ue Tracing
    Hytem Adjust To Trigger Ping Inter Freq Intra gNB Mobility
    Sleep    10s      # Wait for Ping intra freq inter gNB Mobility before to stop wireshark LTE capture
    Stop Ue Tracing
    Set Environment Variable   UE_LOG_FILES    /tmp/mobile/Ping_intraFreq_interGnb_mobility.txt
    Move File    /tmp/mobile/*.txt    %{UE_LOG_FILES}
    Collect pm file    gnb_id=${source_gnb_id}
    Analyse step2

    # Step2is: Ping HO Checks
    # -----------------------
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    Sleep    10S
    Collect pm file    gnb_id=${source_gnb_id}
    Analyse step2bis

    # Step3: Post Ping HO Checks
    # --------------------------
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_UL
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_DL
    Sleep    10s
    Collect pm file    gnb_id=${source_gnb_id}
    Analyse step3

    [Teardown]    Run Keywords    preconditions.Set Scout Confid Id    Postconditions of Test Scenario 5GC000937A7


*** Keywords ***
Preconditions of Suite Scenario 5GC000937A7
    Create Test Suite Folders
    keywordbook-480_ext01.Get test variables and upload start SCF Ext01
    ${source_cellId}       Extract cellIndex from cellDistName ext01    ${source_distName}
    ${target_cellId}       Extract cellIndex from cellDistName ext01    ${target_distName}
    ${source_physCellId}   Get physCellId from SCF ext01     gnb_id=${source_gnb_id}  cellDistName=${source_distName}
    ${target_physCellId}   Get physCellId from SCF ext01     gnb_id=${target_gnb_id}  cellDistName=${target_distName}
    Set Suite Variable    ${source_cellId}
    Set Suite Variable    ${target_cellId}
    Set Suite Variable    ${source_physCellId}
    Set Suite Variable    ${target_physCellId}
    Run Keyword if    '${DEBUG}'=='False'    Hytem Initialization

Preconditions of Test Scenario 5GC000937A7
    Create a Test Scenario Folder
    Run Keyword if    '${DEBUG}'=='False'    Set Hytem Attenuations for gNB ${source_gnb_Id} cell ${source_cellId}    value=0000
    Prepare counters and expected values 5GC000937A7
    update gnb parameter values with delta commissioning     gnb_id=${source_gnb_id}
    Attach QCAT 5G Licence with LK
    Ue Initialization    ue_alias=${ue_id}    capabilities=REAL_UE

Postconditions of Test Scenario 5GC000937A7
    ute_ue.Await Data Transfer Finish                 dt_name=DT_DL
    ute_ue.Await Data Transfer Finish                 dt_name=DT_UL
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=300 Kbits/sec   deviation=${tput_deviation}
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=10 Kbits/sec    deviation=${tput_deviation}
    Run Keyword if    '${DEBUG}'=='False'   Report test result to reporting portal    log_dir=${OUTPUT DIR}     gnb_id=${source_gnb_id}

Postconditions of Suite Scenario 5GC000937A7
    Run keyword and ignore error    Perform Detach Ue
    Run keyword and ignore error    Detach QCAT 5G Licence with LK
    Run Keyword if    '${DEBUG}'=='False' and '${SUITE STATUS}'=='FAIL'    Collect snapshot coam ext01    gnb_id=${source_gnb_id}
    Run Keyword if    '${DEBUG}'=='False' and '${SUITE STATUS}'=='FAIL' and '${NO_ENB}'=='False'  Collect snapshot enb    enb_id=${source_enb_id}
    Run Keyword if    '${DEBUG}'=='False'    restore parameter values with full commissioning ext01
    Wait until coam gNB to be onair state and cells enabled ext01   gnb_id=${source_gnb_id}   num_of_disabled_cells=0

Prepare counters and expected values 5GC000937A7
    # Source gNB:
    # -----------
    # distName="MRBTS-xxx/NRBTS-yyy"
    set test variable    @{actInterFreqHoSA_src}                ${source_gnb_id}   true
    set test variable    @{srb3SupportEnabled_src}              ${source_gnb_id}   false
    set test variable    @{actCarrierAggregation_src}           ${source_gnb_id}   false
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
    set test variable    @{cellDepType_src}                         ${source_gnb_id}   SA
    set test variable    @{cellTechnology_src}                      ${source_gnb_id}   TDD
    set test variable    @{chBw_src}                                ${source_gnb_id}   100MHz
    set test variable    @{nrarfcn_src}                             ${source_gnb_id}   663334          # il faut aussi regarder NRCELL-2 !!!
    set test variable    @{frameStructureType_src}                  ${source_gnb_id}   semiStatic      # list name="tddFrameStructure
    set test variable    @{guardPeriodLength_src}                   ${source_gnb_id}   2Symbols        # list name="tddFrameStructure
    set test variable    @{ulDlDataSlotRatio_src}                   ${source_gnb_id}   1/4             # list name="tddFrameStructure
    set test variable    @{actPRBBlanking_src}                      ${source_gnb_id}   false
    set test variable    @{lteNrDssMode_src}                        ${source_gnb_id}   none
    set test variable    @{actPdschAtSsbSlots_src}                  ${source_gnb_id}   false
    set test variable    @{actPdschRmCsirsForTracking_src}          ${source_gnb_id}   false
    set test variable    @{actpucchModeSelect_src}                  ${source_gnb_id}   longPucch
    set test variable    @{bwpDN_0_src}                             ${source_gnb_id}   BWP_PROFILE-5   # list name="cellBwpList item0
    set test variable    @{cellBwpId_0_src}                         ${source_gnb_id}   0               # list name="cellBwpList item0
    set test variable    @{bwpDN_1_src}                             ${source_gnb_id}   BWP_PROFILE-54  # list name="cellBwpList item1
    set test variable    @{cellBwpId_1_src}                         ${source_gnb_id}   1               # list name="cellBwpList item1
    set test variable    @{bwpDN_2_src}                             ${source_gnb_id}   BWP_PROFILE-51  # list name="cellBwpList item2
    set test variable    @{cellBwpId_2_src}                         ${source_gnb_id}   2               # list name="cellBwpList item2
    set test variable    @{actPowerSavingBWP_src}                   ${source_gnb_id}   true
    set test variable    @{actCDrx_src}                             ${source_gnb_id}   false
    set test variable    @{cbraPreamblesPerSsb_src}                 ${source_gnb_id}   n64
    set test variable    @{actPowerSavingBWP_dst}                   ${target_gnb_id}   true
    set test variable    @{actCDrx_dst}                             ${target_gnb_id}   false
    set test variable    @{cbraPreamblesPerSsb_dst}                 ${target_gnb_id}   n64

    # PM Counters:
    set test variable    ${measurement_period_in_min}                              5
    set test variable    @{M55351C00001_0_src}      MAX_UE_ACTIVE_PWR_SAVING_BWP   0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C00001_1_src}      MAX_UE_ACTIVE_PWR_SAVING_BWP   1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C01001_0_src}      MAX_UE_CONFIG_2BWP             0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C01001_1_src}      MAX_UE_CONFIG_2BWP             1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C00002_0_src}      AVG_UE_ACTIVE_PWR_SAVING_BWP   0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C00002_1_src}      AVG_UE_ACTIVE_PWR_SAVING_BWP   1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C01002_0_src}      AVG_UE_CONFIG_2BWP             0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C01002_1_src}      AVG_UE_CONFIG_2BWP             1    ${source_gnb_id}   ${source_distName}   DBWP   egal

    set test variable    @{M55351C00001_0_dst}      MAX_UE_ACTIVE_PWR_SAVING_BWP   0    ${source_gnb_id}   ${target_distName}   DBWP   egal
    set test variable    @{M55351C00001_1_dst}      MAX_UE_ACTIVE_PWR_SAVING_BWP   1    ${source_gnb_id}   ${target_distName}   DBWP   egal
    set test variable    @{M55351C01001_0_dst}      MAX_UE_CONFIG_2BWP             0    ${source_gnb_id}   ${target_distName}   DBWP   egal
    set test variable    @{M55351C01001_1_dst}      MAX_UE_CONFIG_2BWP             1    ${source_gnb_id}   ${target_distName}   DBWP   egal
    set test variable    @{M55351C00002_0_dst}      AVG_UE_ACTIVE_PWR_SAVING_BWP   0    ${source_gnb_id}   ${target_distName}   DBWP   egal
    set test variable    @{M55351C00002_1_dst}      AVG_UE_ACTIVE_PWR_SAVING_BWP   1    ${source_gnb_id}   ${target_distName}   DBWP   egal
    set test variable    @{M55351C01002_0_dst}      AVG_UE_CONFIG_2BWP             0    ${source_gnb_id}   ${target_distName}   DBWP   egal
    set test variable    @{M55351C01002_1_dst}      AVG_UE_CONFIG_2BWP             1    ${source_gnb_id}   ${target_distName}   DBWP   egal

update gnb parameter values with delta commissioning
    [Arguments]         ${gnb_id}
    Run Keyword If         '${gnb_${gnb_id}_oam_type}' == 'coam'
    ...    update gnb parameter values with delta commissioning coam     gnb_id=${gnb_id}
  # Kw to be added in case of gNB cloud_coam
  # ...    ELSE
  # ...    update gnb parameter values with delta commissioning CU DU    gnb_id=${gnb_id}

update gnb parameter values with delta commissioning coam
    [Arguments]    ${gnb_id}=0
    Run keyword if     '${gnb_id}' == '${source_gnb_id}'
    ...       update gnb parameter values with delta commissioning coam source gnb    ${gnb_id}
  # ...   ELSE
  # ...       update gnb parameter values with delta commissioning coam target gnb    ${gnb_id}

update gnb parameter values with delta commissioning coam source gnb
    [Arguments]    ${gnb_id}=0
    Check nrcell cellBwpList info     ${gnb_${gnb_id}_bts_distName}/${source_distName}     ${gnb_id}
  # Check nrcell cellBwpList info     ${gnb_${gnb_id}_bts_distName}/${target_distName}     ${gnb_id}

    ${d_actInterFreqHoSA}        create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}
    ...    parameter    actInterFreqHoSA
    ...    value        ${actInterFreqHoSA_src[1]}
    ${d_srb3SupportEnabled}      create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}
    ...    parameter    srb3SupportEnabled
    ...    value        ${srb3SupportEnabled_src[1]}
    ${d_actCarrierAggregation}      create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}
    ...    parameter    actCarrierAggregation
    ...    value        ${actCarrierAggregation_src[1]}
    ${d_cbraPreamblesPerSsb_src}      create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/${source_distName}
    ...    parameter    cbraPreamblesPerSsb
    ...    value        ${cbraPreamblesPerSsb_src[1]}
    ${d_actCDrx_src}    create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/${source_distName}
    ...    parameter    actCDrx
    ...    value        ${actCDrx_src[1]}
    ${d_actPowerSavingBWP_src}    create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/${source_distName}
    ...    parameter    actPowerSavingBWP
    ...    value        ${actPowerSavingBWP_src[1]}

    ${d_cbraPreamblesPerSsb_dst}      create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/${target_distName}
    ...    parameter    cbraPreamblesPerSsb
    ...    value        ${cbraPreamblesPerSsb_dst[1]}
    ${d_actCDrx_dst}    create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/${target_distName}
    ...    parameter    actCDrx
    ...    value        ${actCDrx_dst[1]}
    ${d_actPowerSavingBWP_dst}    create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/${target_distName}
    ...    parameter    actPowerSavingBWP
    ...    value        ${actPowerSavingBWP_dst[1]}

    ${param_list}     Create List
    ...    ${d_actInterFreqHoSA}
    ...    ${d_srb3SupportEnabled}
    ...    ${d_actCarrierAggregation}
    ...    ${d_cbraPreamblesPerSsb_src}
    ...    ${d_actCDrx_src}
    ...    ${d_actPowerSavingBWP_src}
    ...    ${d_cbraPreamblesPerSsb_dst}
    ...    ${d_actCDrx_dst}
    ...    ${d_actPowerSavingBWP_dst}
    BuiltIn.Log To Console    \ndelta commissioning started
    json delta commissioning coam ext01       ${param_list}    ${gnb_id}
    BuiltIn.Log To Console    \ndelta commissioning finished

Start Call
    Wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    Perform Attach Ue And Check Nr5g Bearer Is Up  trace_duration=20s  isStartDataTransfert=false  ue_alias=${ue_id}

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
    Log to console    \n\n
    Log to console    -------------------- l_bwpType_values --------------------------
    Log to console    ${l_bwpType_values}
    Log to console    ----------------------------------------------------------------
    Should Contain 	  ${l_bwpType_values} 	${bwpType}[1] 	msg=ERROR: No Power Saving BW PROFILE detected in scf !!!
    Log to console    Power Saving BW PROFILE detected in scf OK\n\n

Hytem Adjust To Trigger Ping Inter Freq Intra gNB Mobility
    Log to console               \nHytem Adjust To Trigger Ping Intra Freq Inter gNB Mobility started
    run Keyword    Set Hytem Attenuations for gNB ${target_gnb_id} cell ${target_cellId}    value=0000
    run Keyword    Set Hytem Attenuations for gNB ${source_gnb_id} cell ${source_cellId}    value=9350
    Log to console               Hytem Adjust To Trigger Ping Intra Freq Inter gNB Mobility finished

Hytem Adjust To Trigger Pong Intra Freq Inter gNB Mobility
    Log to console               \nHytem Adjust To Trigger Pong Intra Freq Inter gNB Mobility started
    run Keyword    Set Hytem Attenuations for gNB ${source_gnb_id} cell ${source_cellId}    value=0000
    run Keyword    Set Hytem Attenuations for gNB ${target_gnb_id} cell ${target_cellId}    value=9350
    Log to console               Hytem Adjust To Trigger Pong Intra Freq Inter gNB Mobility finished

Analyse step1
    Log to console     \nAnalyse Step1 Started
    Log to console     ---- Check ue traces
    Log to console     ---- DEBUG : UE_LOG_FILES ENV VARIABLE is: %{UE_LOG_FILES}
    # In Ue logs check rrcReconf DO reconfigure Ue with a Power Saving BWP
    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCReconfiguration    ${dlBwpId1}    100000000000
    Should Be True    '${status}' == 'True'   Error : dlBwpId1 : ${dlBwpId1} NOT FOUND !!!
    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCReconfiguration    ${ulBwpId1}    100000000000
    Should Be True    '${status}' == 'True'   Error : ulBwpId1 : ${ulBwpId1} NOT FOUND !!!
    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCReconfiguration    ${dlBwpId2}    100000000000
    Should Be True    '${status}' == 'True'   Error : dlBwpId2 : ${dlBwpId2} NOT FOUND !!!
    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCReconfiguration    ${ulBwpId2}    100000000000
    Should Be True    '${status}' == 'True'   Error : ulBwpId2 : ${ulBwpId2} NOT FOUND !!!
    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCConfiguration Complete   ${rrcConfComp}   100000000000
    Should Be True    '${status}' == 'True'   Error : rrcConfComp NOT FOUND !!!

    Log to console     ---- Check f1ap pcap traces
  # To Be done !!!

    Log to console     Analyse Step1 Endeded

Analyse step2
    Log to console     \nAnalyse Step2 Started
    Log to console     ---- Check ue traces
    Log to console     ---- DEBUG : UE_LOG_FILES ENV VARIABLE is: %{UE_LOG_FILES}

    ${status}   Run Keyword And Return Status
    ...  Is Ue Log Message Contain   NR5G:RRC OTA Packet:MeasurementReport   ${measRepPCell3}   100000000000
    ${status}        Run Keyword And Return Status
    ...     Should Be True    '${status}' == 'True'   Error : measRepPCell3 NOT FOUND !!!

    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCReconfiguration    ${dlBwpId2}    100000000000
    ${status}        Run Keyword And Return Status
    ...   Should Be True    '${status}' == 'True'   Error : dlBwpId2 NOT FOUND !!!

    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCReconfiguration    ${ulBwpId2}    100000000000
    ${status}        Run Keyword And Return Status
    ...   Should Be True    '${status}' == 'True'   Error : ulBwpId2 NOT FOUND !!!

    ${status}  Run keyword and return status
    ...    Is Ue Log Message Contain   NR5G:RRC OTA Packet:RRCConfiguration Complete   ${rrcConfComp}     100000000000
    ${status}        Run Keyword And Return Status
    ...   Should Be True    '${status}' == 'True'   Error : rrcConfComp NOT FOUND !!!

    Log to console     ---- Check pm ctrs from previous observation period
    Verify counter values 5GC000937A dedicated bwp state step2   gnb_id=${source_gnb_id}
    Log to console     ---- Check f1ap pacap traces
  # To Be done !!!
    Log to console     Analyse Step2 Endeded

Verify counter values 5GC000937A dedicated bwp state step2
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    Run Keyword If        '${gnb_${gnb_id}_oam_type}' == 'coam'
    ...        Verify counter values coam 5GC000937A dedicated bwp state step2   gnb_id=${gnb_id}   du_id=${du_id}
  # ...    ELSE
  # ...        Verify counter v coaaluesm CU DU 5GC002056_AIAB_04   gnb_id=${gnb_id}   du_id=${du_id}

Verify counter values coam 5GC000937A dedicated bwp state step2
    [Arguments]    ${gnb_id}=0      ${du_id}=0
    ${parsed_xml}    parse xml      ${pmCounter_xml_file_gNB${gnb_id}}
    &{dict}    Run keyword if       '${gnb_id}' == '${source_gnb_id}'
    ...        Create Dictionary    M55351C00001     ${M55351C00001_0_src}   M55351C01001     ${M55351C01001_1_src}
    ...                             M55351C00002     ${M55351C00002_0_src}   M55351C01002     ${M55351C01002_1_src}
    Log Dictionary                  ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter ext01    ${counter}    ${counterList}    ${parsed_xml}     du_id=${du_id}    gnb_id=${gnb_id}
    END

    &{dict}    Run keyword if       '${gnb_id}' == '${source_gnb_id}'
    ...        Create Dictionary    M55351C00001     ${M55351C00001_0_dst}   M55351C01001     ${M55351C01001_0_dst}
    ...                             M55351C00002     ${M55351C00002_0_dst}   M55351C01002     ${M55351C01002_0_dst}
    Log Dictionary                  ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter ext01    ${counter}    ${counterList}    ${parsed_xml}     du_id=${du_id}    gnb_id=${gnb_id}
    END

Analyse step2bis
   Log to console     \nAnalyse Step2bis Started
   Log to console     ---- Check pm ctrs from previous observation period
   Verify counter values 5GC000937A dedicated bwp state step2bis   gnb_id=${source_gnb_id}
   Log to console     Analyse Step2bis Endeded

Verify counter values 5GC000937A dedicated bwp state step2bis
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    Run Keyword If        '${gnb_${gnb_id}_oam_type}' == 'coam'
    ...        Verify counter values coam 5GC000937A dedicated bwp state step2bis   gnb_id=${gnb_id}   du_id=${du_id}
  # ...    ELSE
  # ...        Verify counter v coaaluesm CU DU 5GC002056_AIAB_04   gnb_id=${gnb_id}   du_id=${du_id}

Verify counter values coam 5GC000937A dedicated bwp state step2bis
    [Arguments]    ${gnb_id}=0      ${du_id}=0
    ${parsed_xml}    parse xml      ${pmCounter_xml_file_gNB${gnb_id}}
    &{dict}    Run keyword if       '${gnb_id}' == '${source_gnb_id}'
    ...        Create Dictionary    M55351C00001     ${M55351C00001_0_src}   M55351C01001     ${M55351C01001_1_src}
    ...                             M55351C00002     ${M55351C00002_0_src}   M55351C01002     ${M55351C01002_0_src}
    Log Dictionary                  ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter ext01    ${counter}    ${counterList}    ${parsed_xml}     du_id=${du_id}    gnb_id=${gnb_id}
    END

    &{dict}    Run keyword if       '${gnb_id}' == '${source_gnb_id}'
    ...        Create Dictionary    M55351C00001     ${M55351C00001_0_dst}   M55351C01001     ${M55351C01001_1_dst}
    ...                             M55351C00002     ${M55351C00002_0_dst}   M55351C01002     ${M55351C01002_1_dst}
    Log Dictionary                  ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter ext01    ${counter}    ${counterList}    ${parsed_xml}     du_id=${du_id}    gnb_id=${gnb_id}
    END

Analyse step3
    Log to console     \nAnalyse Step3 Started
    Log to console     ---- Check pm ctrs from previous observation period
    Verify counter values 5GC000937A dedicated bwp state step3   gnb_id=${source_gnb_id}
    Log to console     Analyse Step3 Endeded

Verify counter values 5GC000937A dedicated bwp state step3
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    Run Keyword If        '${gnb_${gnb_id}_oam_type}' == 'coam'
    ...        Verify counter values coam 5GC000937A dedicated bwp state step3   gnb_id=${gnb_id}   du_id=${du_id}
  # ...    ELSE
  # ...        Verify counter v coaaluesm CU DU 5GC002056_AIAB_04   gnb_id=${gnb_id}   du_id=${du_id}

Verify counter values coam 5GC000937A dedicated bwp state step3
    [Arguments]    ${gnb_id}=0      ${du_id}=0
    ${parsed_xml}    parse xml      ${pmCounter_xml_file_gNB${gnb_id}}
    &{dict}    Run keyword if       '${gnb_id}' == '${source_gnb_id}'
    ...        Create Dictionary    M55351C00001     ${M55351C00001_0_src}   M55351C01001     ${M55351C01001_0_src}
    ...                             M55351C00002     ${M55351C00002_0_src}   M55351C01002     ${M55351C01002_0_src}
    Log Dictionary                  ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter ext01    ${counter}    ${counterList}    ${parsed_xml}     du_id=${du_id}    gnb_id=${gnb_id}
    END

    &{dict}    Run keyword if       '${gnb_id}' == '${source_gnb_id}'
    ...        Create Dictionary    M55351C00001     ${M55351C00001_0_dst}   M55351C01001     ${M55351C01001_1_dst}
    ...                             M55351C00002     ${M55351C00002_0_dst}   M55351C01002     ${M55351C01002_1_dst}
    Log Dictionary                  ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter ext01    ${counter}    ${counterList}    ${parsed_xml}     du_id=${du_id}    gnb_id=${gnb_id}
    END

Collect pm file
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    Wait Until Keyword Succeeds   2x   20s   Collect PM Counters ext01   gnb_id=${gnb_id}
