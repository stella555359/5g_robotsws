*** Settings ***
Documentation
...   Test Suite Purpose:
...   Feature 5GC0000937-A BandWidth Saving Testing
...   DESCRIPTION:Feature 5GC0000937-A automated regression testing
...   AUTHOR nadine.crasnier@nokia.com


Resource                                    ../resources/common_settings.robot
Resource      taf/rfrl/common_resources/common_step/interface.robot

Force Tags      			    CA_RAN_PZ_NPS   QCD_MN_RAN   QCP_RAN_ST   SBTS00

Suite Setup       Preconditions of Test Suite 5GC000937_A_3
Suite Teardown    Postconditions of Test Suite 5GC000937_A_3


*** Variables ***
# Logical mapping
# ${source_enb_id}                          1            # <give source enb_id, for example 0>
# ${source_enb_vlan_id}                     3002         # <give source_enb_vlan_id for exemple 3006>
${source_gnb_id}                            0            # <give source gnb_id, for example 0>
# ${source_du_id}                                        # <give source gnb_id du_id (cloud gnb), for example 0>
#${source_distName}                          NRCELL-1     # <give source nrcell, for example NRCELL-1>
${source_distName}                          NRCELL-2     # <give source nrcell, for example NRCELL-2>
# ${source_distName_enb}                    LNCEL-1      # <give source enb cell for exemple LNCEL-1
# ${source_distName_du}                                  # <give source nrcell_id in DU (cloud gnb), for example NRCELL-1>
${nrcellgrp_source_distName}                NRCELLGRP-0  # <give source nrcellgrp_id, for example NRCELLGRP-0>

${ue_id}     UE_1

*** Test Cases ***
[1][1.0] 5GC000937_A_33_Check_SingleUE_Switch_to_psBWP_on_lowDlUl_traffic_with_AL8
    [Setup]	  Run Keywords    preconditions.Get Scout Bts Name    Preconditions of Test Scenario 5GC000937_A_3
    [Timeout]     45min
    Wait until coam gNB to be onair state and cells enabled ext01   gnb_id=${source_gnb_id}   num_of_disabled_cells=0
  # Run keyword and ignore error   Perform Attach Ue And Check Nr5g Bearer Is Up    trace_duration=20s   isStartDataTransfert=false
    wait until keyword succeeds  1200s  30s  Start Call
    Log to console  \n------------------------------------------------------------------------------------
    Log to console    Analyse step1:
    Log to console    Check in ue traces that RRC configure power saving bwp-Id2
    Log to console  ------------------------------------------------------------------------------------\n
#    Analyse step1

    # Step1 Initialization:
    # Establish Ul lesser tput than   Decicated BWP -> Power Saving BWP thresold trigger
    # Establish Dl upper tput than   Decicated BWP -> Power Saving BWP thresold trigger

    # From this point gNB/UE should use Power Saving BWP and DT_UL start time should be synchronized with pm obs period
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_id}  direction=ul  duration=1260s
    ...    throughput=10 Kbits/sec    protocol=${protocol}	  packet_size=${Packet_Size}    qci=${qci_ul}
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_id}  direction=dl  duration=660s
    ...    throughput=100 Kbits/sec     protocol=${protocol}  packet_size=${Packet_Size}    qci=${qci_dl}

    # Step2: Downsize BWP on DT_DL termination
    #        Check counters from previous measurement interval, it should indicate large BWP
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_UL
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_DL

    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_UL
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_DL
    Log to console   \n------------------------------------------------------------------------------------
    Log to console    Analyse step2:
    Log to console    Check pm obs counter matches dedicated BWP relative to previous measurement interval
    Log to console   ------------------------------------------------------------------------------------\n
    Collect pm file    gnb_id=${source_gnb_id}
    Analyse step2

    # Step3: Check counters from previous period should indicate swith from large Dedicated BWP to Power Saving BWP
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_UL
    Log to console   \n------------------------------------------------------------------------------------
    Log to console    Analyse step3:
    Log to console    Check pm obs counter matches power saving BWP relative to previous measurement interval
    Log to console   ------------------------------------------------------------------------------------\n
    Collect pm file    gnb_id=${source_gnb_id}
    Analyse step3

    # Step4: Check counters from previous period should indicate power saving BWP
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_UL
    Log to console   \n------------------------------------------------------------------------------------
    Log to console    Analyse step4:
    Log to console    Check pm obs counter matches power saving BWP relative to previous measurement interval
    Log to console   ------------------------------------------------------------------------------------\n
    Collect pm file    gnb_id=${source_gnb_id}
    Analyse step4

    [Teardown]    Run Keywords    preconditions.Set Scout Confid Id    Postconditions of Test Scenario 5GC000937_A_3


*** Keywords ***
Preconditions of Test Suite 5GC000937_A_3
    Create Test Suite Folders
    keywordbook-480_ext01.Get test variables and upload start SCF Ext01
    ${source_cellId}       Extract cellIndex from cellDistName ext01    ${source_distName}
    ${source_physCellId}   Get physCellId from SCF ext01     gnb_id=${source_gnb_id}  cellDistName=${source_distName}
    Set Suite Variable    ${source_cellId}
    Set Suite Variable    ${source_physCellId}
    Run Keyword if    '${DEBUG}'=='False'    Hytem Initialization

Preconditions of Test Scenario 5GC000937_A_3
    Create a Test Scenario Folder
    Run Keyword if    '${DEBUG}'=='False'    Set Hytem Attenuations for gNB 0 cell ${source_cellId}    value=0000
    Prepare counters and expected values 5GC000937_A_3
    Update gnb parameter values with full commissioning coam source gnb for 937A033
    Attach QCAT 5G Licence with LK
    Ue Initialization    ue_alias=${ue_id}    capabilities=REAL_UE

Postconditions of Test Scenario 5GC000937_A_3
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_DL    tput=100 Kbits/sec    deviation=${tput_deviation}
    ute_ue.Verify Average Throughput With Deviation    dt_name=DT_UL    tput=10 Kbits/sec     deviation=${tput_deviation}
    Run keyword and ignore error    Perform Detach Ue
    Run Keyword if    '${DEBUG}'=='False'    Report test result to reporting portal    log_dir=${OUTPUT DIR}    gnb_id=${source_gnb_id}


Postconditions of Test Suite 5GC000937_A_3
    Run keyword and ignore error    Detach QCAT 5G Licence with LK
    Run Keyword if    '${DEBUG}'=='False' and '${SUITE STATUS}'=='FAIL'    Collect snapshot coam ext01    gnb_id=${source_gnb_id}
    Run Keyword if    '${DEBUG}'=='False' and '${SUITE STATUS}'=='FAIL' and '${NO_ENB}'=='False'  Collect snapshot enb    enb_id=${source_enb_id}
    Run Keyword if    '${DEBUG}'=='False'    restore parameter values with full commissioning ext01
    Wait until coam gNB to be onair state and cells enabled ext01   gnb_id=${source_gnb_id}   num_of_disabled_cells=0
    interface.Common step trigger


Prepare counters and expected values 5GC000937_A_3
    # Source gNB:
    # -----------
    # distName="MRBTS-xxx/NRBTS-yyy"
    set suite variable    @{srb3SupportEnabled_src}              ${source_gnb_id}   false
    set suite variable    @{actCarrierAggregation_src}           ${source_gnb_id}   false
    set suite variable    @{actNrNgHoSA_src}                     ${source_gnb_id}   false
    set suite variable    @{dlBufferEmptyRatioFromPsBwp}         ${source_gnb_id}   40              # list name="powerSavingBwpSwitching
    set suite variable    @{dlBufferEmptyRatioToPsBwp}           ${source_gnb_id}   90              # list name="powerSavingBwpSwitching
    set suite variable    @{dlRateThresholdFromPsBwp}            ${source_gnb_id}   35              # list name="powerSavingBwpSwitching
    set suite variable    @{dlRateThresholdToPsBwp}              ${source_gnb_id}   30              # list name="powerSavingBwpSwitching
    set suite variable    @{measurementDurationFromPsBwp}        ${source_gnb_id}   40              # list name="powerSavingBwpSwitching
    set suite variable    @{measurementDurationToPsBwp}          ${source_gnb_id}   160             # list name="powerSavingBwpSwitching
    set suite variable    @{ulRateThresholdNoVoNRFromPsBwp}      ${source_gnb_id}   10              # list name="powerSavingBwpSwitching
    set suite variable    @{ulRateThresholdNoVoNRToPsBwp}        ${source_gnb_id}   5               # list name="powerSavingBwpSwitching
    set suite variable    @{ulRateThresholdVoNRFromPsBwp}        ${source_gnb_id}   35              # list name="powerSavingBwpSwitching
    set suite variable    @{ulRateThresholdVoNRToPsBwp}          ${source_gnb_id}   30              # list name="powerSavingBwpSwitching


    # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51"
    set suite variable    @{bwpType}                             ${source_gnb_id}   powerSaving
    set suite variable    @{cRbSizeDl}                           ${source_gnb_id}   n106            # list name="locationAndBandwidthDl
    set suite variable    @{cRbStartDl}                          ${source_gnb_id}   crb0            # list name="locationAndBandwidthDl
    set suite variable    @{cRbSizeUl}                           ${source_gnb_id}   n106            # list name="locationAndBandwidthUl
    set suite variable    @{cRbStartUl}                          ${source_gnb_id}   sameAsDl        # list name="locationAndBandwidthUl

    # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51/PDCCH-1"
    set suite variable    @{alSelection}                         ${source_gnb_id}   static</p>
    set suite variable    @{dciDedicatedAggregationLevel}        ${source_gnb_id}   AL4
    set suite variable    @{dciPagingAggregationLevel}           ${source_gnb_id}   AL4
    set suite variable    @{dciRaCompletionAggregationLevel}     ${source_gnb_id}   AL4
    set suite variable    @{dciRaMsg2AggregationLevel}           ${source_gnb_id}   AL4
    set suite variable    @{dciSiAggregationLevel}               ${source_gnb_id}   AL4
    set suite variable    @{downgradeAL16toAL8}                  ${source_gnb_id}   notAllowed
    set suite variable    @{aggregationLevelList}                ${source_gnb_id}   AL2_AL4         # list name="dynamicAggregationLevelSet
    set suite variable    @{cqiCorrectionUp}                     ${source_gnb_id}   10              # list name="dynamicAggregationLevelSet
    set suite variable    @{cqiDciCssAl1}                        ${source_gnb_id}   159             # list name="dynamicAggregationLevelSet
    set suite variable    @{cqiDciCssAl16}                       ${source_gnb_id}   159             # list name="dynamicAggregationLevelSet
    set suite variable    @{cqiDciCssAl2}                        ${source_gnb_id}   159             # list name="dynamicAggregationLevelSet
    set suite variable    @{cqiDciCssAl4}                        ${source_gnb_id}   159             # list name="dynamicAggregationLevelSet
    set suite variable    @{cqiDciCssAl8}                        ${source_gnb_id}   159             # list name="dynamicAggregationLevelSet
    set suite variable    @{highOlcCqiOffset}                    ${source_gnb_id}   1               # list name="dynamicAggregationLevelSet
    set suite variable    @{lowOlcCqiOffset}                     ${source_gnb_id}   1               # list name="dynamicAggregationLevelSet
    set suite variable    @{pCqiErasureActTimer}                 ${source_gnb_id}   0               # list name="dynamicAggregationLevelSet
    set suite variable    @{pCqiErasureReduction}                ${source_gnb_id}   0               # list name="dynamicAggregationLevelSet

    # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_COMMON-1
    set suite variable    @{coresetId}                           ${source_gnb_id}   0               # list name="searchSpaceCommon item0
    set suite variable    @{dciFormat}                           ${source_gnb_id}   formats0-0-And-1-0  # list name="searchSpaceCommon item0
    set suite variable    @{duration}                            ${source_gnb_id}   3               # list name="searchSpaceCommon item0
    set suite variable    @{monitoringSymbolWithinSlot}          ${source_gnb_id}   symbol_0        # list name="searchSpaceCommon item0
    set suite variable    @{numOfPdcchCandidatesInAL16}          ${source_gnb_id}   n0              # list name="searchSpaceCommon item0
    set suite variable    @{numOfPdcchCandidatesInAL2}           ${source_gnb_id}   n0              # list name="searchSpaceCommon item0
    set suite variable    @{numOfPdcchCandidatesInAL4}           ${source_gnb_id}   n2              # list name="searchSpaceCommon item0
    set suite variable    @{numOfPdcchCandidatesInAL8}           ${source_gnb_id}   n1              # list name="searchSpaceCommon item0
    set suite variable    @{periodicity}                         ${source_gnb_id}   sl5             # list name="searchSpaceCommon item0
    set suite variable    @{searchSpaceId}                       ${source_gnb_id}   9               # list name="searchSpaceCommon item0
    set suite variable    @{searchSpaceType}                     ${source_gnb_id}   Type0A          # list name="searchSpaceCommon item0
    set suite variable    @{slotOffset}                          ${source_gnb_id}   0               # list name="searchSpaceCommon item0
    set suite variable    @{coresetId}                           ${source_gnb_id}   0               # list name="searchSpaceCommon item1
    set suite variable    @{dciFormat}                           ${source_gnb_id}   formats0-0-And-1-0  # list name="searchSpaceCommon item1
    set suite variable    @{duration}                            ${source_gnb_id}   1               # list name="searchSpaceCommon item1
    set suite variable    @{monitoringSymbolWithinSlot}          ${source_gnb_id}   symbol_0_1      # list name="searchSpaceCommon item1
    set suite variable    @{numOfPdcchCandidatesInAL16}          ${source_gnb_id}   n0              # list name="searchSpaceCommon item1
    set suite variable    @{numOfPdcchCandidatesInAL2}           ${source_gnb_id}   n0              # list name="searchSpaceCommon item1
    set suite variable    @{numOfPdcchCandidatesInAL4}           ${source_gnb_id}   n2              # list name="searchSpaceCommon item1
    set suite variable    @{numOfPdcchCandidatesInAL8}           ${source_gnb_id}   n0              # list name="searchSpaceCommon item1
    set suite variable    @{periodicity}                         ${source_gnb_id}   sl1             # list name="searchSpaceCommon item1
    set suite variable    @{searchSpaceId}                       ${source_gnb_id}   10              # list name="searchSpaceCommon item1
    set suite variable    @{searchSpaceType}                     ${source_gnb_id}   Type1           # list name="searchSpaceCommon item1
    set suite variable    @{slotOffset}                          ${source_gnb_id}   0               # list name="searchSpaceCommon item1
    set suite variable    @{coresetId}                           ${source_gnb_id}   0               # list name="searchSpaceCommon item2
    set suite variable    @{dciFormat}                           ${source_gnb_id}   formats0-0-And-1-0  # list name="searchSpaceCommon item2
    set suite variable    @{duration}                            ${source_gnb_id}   3               # list name="searchSpaceCommon item2
    set suite variable    @{monitoringSymbolWithinSlot}          ${source_gnb_id}   symbol_0        # list name="searchSpaceCommon item2
    set suite variable    @{umOfPdcchCandidatesInAL16}           ${source_gnb_id}   n0              # list name="searchSpaceCommon item2
    set suite variable    @{numOfPdcchCandidatesInAL2}           ${source_gnb_id}   n0              # list name="searchSpaceCommon item2
    set suite variable    @{numOfPdcchCandidatesInAL4}           ${source_gnb_id}   n2              # list name="searchSpaceCommon item2
    set suite variable    @{numOfPdcchCandidatesInAL8}           ${source_gnb_id}   n1              # list name="searchSpaceCommon item2
    set suite variable    @{periodicity}                         ${source_gnb_id}   sl5             # list name="searchSpaceCommon item2
    set suite variable    @{searchSpaceId}                       ${source_gnb_id}   11              # list name="searchSpaceCommon item2
    set suite variable    @{searchSpaceType}                     ${source_gnb_id}   Type2           # list name="searchSpaceCommon item2
    set suite variable    @{slotOffset}                          ${source_gnb_id}   0               # list name="searchSpaceCommon item2

    # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    set suite variable    @{cceToRegMapping}                     ${source_gnb_id}   nonInterleaved  # list name="coresetDedicated
    set suite variable    @{coresetId}                           ${source_gnb_id}   4               # list name="coresetDedicated
    set suite variable    @{cRbStart}                            ${source_gnb_id}   0               # list name="coresetDedicated
    set suite variable    @{duration}                            ${source_gnb_id}   1               # list name="coresetDedicated
    set suite variable    @{interleaverSize}                     ${source_gnb_id}   none            # list name="coresetDedicated
    set suite variable    @{regBundleSize}                       ${source_gnb_id}   n6              # list name="coresetDedicated
    set suite variable    @{size}                                ${source_gnb_id}   96              # list name="coresetDedicated
    set suite variable    @{coresetId}                           ${source_gnb_id}   0               # list name="searchSpaceDedicated item0
    set suite variable    @{dciFormat}                           ${source_gnb_id}   formats0-0-And-1-0  # list name="searchSpaceDedicated item0
    set suite variable    @{duration}                            ${source_gnb_id}   1               # list name="searchSpaceDedicated item0
    set suite variable    @{monitoringSymbolWithinSlot}          ${source_gnb_id}   symbol_0_1      # list name="searchSpaceDedicated item0
    set suite variable    @{numOfPdcchCandidatesInAL1}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item0
    set suite variable    @{numOfPdcchCandidatesInAL16}          ${source_gnb_id}   n0              # list name="searchSpaceDedicated item0
    set suite variable    @{numOfPdcchCandidatesInAL2}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item0
    set suite variable    @{numOfPdcchCandidatesInAL4}           ${source_gnb_id}   n2              # list name="searchSpaceDedicated item0
    set suite variable    @{numOfPdcchCandidatesInAL8}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item0
    set suite variable    @{periodicity}                         ${source_gnb_id}   sl1             # list name="searchSpaceDedicated item0
    set suite variable    @{searchSpaceId}                       ${source_gnb_id}   12              # list name="searchSpaceDedicated item0
    set suite variable    @{searchSpaceType}                     ${source_gnb_id}   Type3           # list name="searchSpaceDedicated item0
    set suite variable    @{slotOffset}                          ${source_gnb_id}   0               # list name="searchSpaceDedicated item0
    set suite variable    @{coresetId}                           ${source_gnb_id}   4               # list name="searchSpaceDedicated item1
    set suite variable    @{dciFormat}                           ${source_gnb_id}   formats0-1-And-1-1  # list name="searchSpaceDedicated item1
    set suite variable    @{duration}                            ${source_gnb_id}   1               # list name="searchSpaceDedicated item1
    set suite variable    @{monitoringSymbolWithinSlot}          ${source_gnb_id}   symbol_0_1      # list name="searchSpaceDedicated item1
    set suite variable    @{numOfPdcchCandidatesInAL1}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item1
    set suite variable    @{numOfPdcchCandidatesInAL16}          ${source_gnb_id}   n0              # list name="searchSpaceDedicated item1
    set suite variable    @{numOfPdcchCandidatesInAL2}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item1
    set suite variable    @{numOfPdcchCandidatesInAL4}           ${source_gnb_id}   n2              # list name="searchSpaceDedicated item1
    set suite variable    @{numOfPdcchCandidatesInAL8}           ${source_gnb_id}   n0              # list name="searchSpaceDedicated item1
    set suite variable    @{periodicity}                         ${source_gnb_id}   sl1             # list name="searchSpaceDedicated item1
    set suite variable    @{searchSpaceId}                       ${source_gnb_id}   13              # list name="searchSpaceDedicated item1
    set suite variable    @{searchSpaceType}                     ${source_gnb_id}   UE-Specific     # list name="searchSpaceDedicated item1
    set suite variable    @{slotOffset}                          ${source_gnb_id}   0               # list name="searchSpaceDedicated item1

    # distName="MRBTS-xxx/NRBTS-yyy/BWP_PROFILE-51/PDSCH-1
    set suite variable    @{pdschRat0RbgConfig}                  ${source_gnb_id}   config1

    # distName="MRBTS-xxx/NRBTS-yyy/NRCELL-z"
    set suite variable    @{cellDepType_src}                         ${source_gnb_id}   SA
    set suite variable    @{cellTechnology_src}                      ${source_gnb_id}   TDD
    set suite variable    @{chBw_src}                                ${source_gnb_id}   100MHz
    set suite variable    @{nrarfcn_src}                             ${source_gnb_id}   663334          # il faut aussi regarder NRCELL-2 !!!
    set suite variable    @{frameStructureType_src}                  ${source_gnb_id}   tdLte           # list name="tddFrameStructure
    set suite variable    @{guardPeriodLength_src}                   ${source_gnb_id}   4Symbols        # list name="tddFrameStructure
    set suite variable    @{lteToNrFrameShift_src}                   ${source_gnb_id}   0ms             # list name="tddFrameStructure
    set suite variable    @{tdLteUlDlConfig_src}                     ${source_gnb_id}   tdLteConfig2    # list name="tddFrameStructure
    set suite variable    @{ulDlDataSlotRatio_src}                   ${source_gnb_id}   2/8             # list name="tddFrameStructure
    set suite variable    @{prachConfigurationIndex_src}             ${source_gnb_id}   97
    set suite variable    @{actPRBBlanking_src}                      ${source_gnb_id}   false
    set suite variable    @{lteNrDssMode_src}                        ${source_gnb_id}   none
    set suite variable    @{actPdschAtSsbSlots_src}                  ${source_gnb_id}   false
    set suite variable    @{actPdschRmCsirsForTracking_src}          ${source_gnb_id}   false
    set suite variable    @{actpucchModeSelect_src}                  ${source_gnb_id}   longPucch
    set suite variable    @{bwpDN_0_src}                             ${source_gnb_id}   BWP_PROFILE-5   # list name="cellBwpList item0
    set suite variable    @{cellBwpId_0_src}                         ${source_gnb_id}   0               # list name="cellBwpList item0
    set suite variable    @{bwpDN_1_src}                             ${source_gnb_id}   BWP_PROFILE-54  # list name="cellBwpList item1
    set suite variable    @{cellBwpId_1_src}                         ${source_gnb_id}   1               # list name="cellBwpList item1
    set suite variable    @{bwpDN_2_src}                             ${source_gnb_id}   BWP_PROFILE-51  # list name="cellBwpList item2
    set suite variable    @{cellBwpId_2_src}                         ${source_gnb_id}   2               # list name="cellBwpList item2
    set suite variable    @{actPowerSavingBWP_src}                   ${source_gnb_id}   true
    set suite variable    @{actCDrx_src}                             ${source_gnb_id}   false
    set suite variable    @{cbraPreamblesPerSsb_src}                 ${source_gnb_id}   n64

    # PM Counters:
    set suite variable    ${measurement_period_in_min}                              5
    set suite variable    @{M55351C00001_0_src}      MAX_UE_ACTIVE_PWR_SAVING_BWP   0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set suite variable    @{M55351C00001_1_src}      MAX_UE_ACTIVE_PWR_SAVING_BWP   1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set suite variable    @{M55351C01001_0_src}      MAX_UE_CONFIG_2BWP             0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set suite variable    @{M55351C01001_1_src}      MAX_UE_CONFIG_2BWP             1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set suite variable    @{M55351C00002_0_src}      AVG_UE_ACTIVE_PWR_SAVING_BWP   0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set suite variable    @{M55351C00002_1_src}      AVG_UE_ACTIVE_PWR_SAVING_BWP   1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set suite variable    @{M55351C01002_0_src}      AVG_UE_CONFIG_2BWP             0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set suite variable    @{M55351C01002_1_src}      AVG_UE_CONFIG_2BWP             1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set suite variable    @{M55335C06004_min_src}    UL_GRANT_AL8_CBWP2           850    ${source_gnb_id}   ${source_distName}   PDCCH   upper
    set suite variable    @{M55335C06004_src}        UL_GRANT_AL8_CBWP2          1200    ${source_gnb_id}   ${source_distName}   PDCCH   upper

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
    set suite variable   ${nrcell_dist}     ${gnb_${gnb_id}_bts_distName}/${source_distName}

    Check nrcell cellBwpList info     ${nrcell_dist}     ${gnb_id}
    ${d_srb3SupportEnabled}      create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}
    ...    parameter    srb3SupportEnabled
    ...    value        ${srb3SupportEnabled_src[1]}
    ${d_actCarrierAggregation}      create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}
    ...    parameter    actCarrierAggregation
    ...    value        ${actCarrierAggregation_src[1]}
    ${d_cbraPreamblesPerSsb}      create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/${source_distName}
    ...    parameter    cbraPreamblesPerSsb
    ...    value        ${cbraPreamblesPerSsb_src[1]}
    ${d_actCDrx}    create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/${source_distName}
    ...    parameter    actCDrx
    ...    value        ${actCDrx_src[1]}
    ${d_actPowerSavingBWP}    create dictionary
    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/${source_distName}
    ...    parameter    actPowerSavingBWP
    ...    value        ${actPowerSavingBWP_src[1]}
#    ${d_dciDedicatedAggregationLevel_BWP_PROFILE-5}    create dictionary
#    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/BWP_PROFILE-5/PDCCH-1
#    ...    parameter    dciDedicatedAggregationLevel
#    ...    value        AL8
#    ${d_numOfPdcchCandidatesInAL8_searchSpaceCommon_BWP_PROFILE-5}    create dictionary
#    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1
#    ...    parameter    searchSpaceCommon
#    ...    value        {numOfPdcchCandidatesInAL8, n2}
#    ${d_numOfPdcchCandidatesInAL8_searchSpaceCommon_BWP_PROFILE-5}    create dictionary
#    ...    dist_name    ${gnb_${gnb_id}_bts_distName}/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1
#    ...    parameter    numOfPdcchCandidatesInAL8
#    ...    value        n2

    ${param_list}     Create List
    ...    ${d_srb3SupportEnabled}
    ...    ${d_actCarrierAggregation}
    ...    ${d_cbraPreamblesPerSsb}
    ...    ${d_actCDrx}
    ...    ${d_actPowerSavingBWP}
    ...    ${d_dciDedicatedAggregationLevel_BWP_PROFILE-5}

    BuiltIn.Log To Console    \ndelta commissioning started
    json delta commissioning coam ext01       ${param_list}    ${gnb_id}
    BuiltIn.Log To Console    \ndelta commissioning finished


Start Call
    Wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    #Perform Attach Ue And Check Nr5g Bearer Is Up  trace_duration=20s  isStartDataTransfert=false  ue_alias=${ue_id}
    Run keyword and ignore error
    ...   Perform Attach Ue And Check Nr5g Bearer Is Up    isStartDataTransfert=false  ue_alias=${ue_id}  trace_duration=20s  ue_alias=${ue_id}


Check nrcell cellBwpList info
    [Arguments]      ${dist_name}     ${gnb_id}
    set suite variable    ${scfini}    ${resultBaseDir}/SCFC_start_gnb_${gnb_id}.xml
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


Analyse step1
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


Analyse step2
    Verify counter values 5GC000937A dedicated bwp state   gnb_id=${source_gnb_id}


Analyse step3
    Verify counter values 5GC000937A bwp switching   gnb_id=${source_gnb_id}


Analyse step4
    Verify counter values 5GC000937A ps bwp state   gnb_id=${source_gnb_id}
    Verify counter value 5GC000937A M55335C06004 during ps bwp state


Verify counter value 5GC000937A M55335C06004 during ps bwp state
    # Check PM counter M55335C06004 value From PM file
    # 07/08/2023  : NRCELL-1 has RU AZQO, NRCELL-2 has RU AZQS
    # With NRCELL-1 , counter M55335C06004 has value around 1200 in 5mn interval with PS and no traffic
    # With NRCELL-2 , counter M55335C06004 has value around 900 in 5mn interval with PS and no traffic
    # that is why tolerance has been set to value 40% to cover the two cases
    ${cell}      Evaluate   '${source_distName}'[-1:]
    Log to console      cell : ${cell}

    ${pi_dict}=     get_pi_value_for_one_cell_from_file
    ...             pi_dir=${resultDir}/counter_gNB${source_gnb_id}
    ...             pi_name=M55335C06004
    ...             file_name=pm.xml
       ...          cell=${cell}
    Log to console   \ncounter M555335C06004 "${M55335C06004_src[0]}" for ${M55335C06004_src[3]} value=${pi_dict} expected: ${M55335C06004_src[1]}
    ${tolerance}            Evaluate       (${M55335C06004_src[1]}*0.4)
    Log to console              tolerance=${tolerance}
    should be true     abs(${pi_dict} - ${M55335C06004_src[1]}) < ${tolerance}


Verify counter values 5GC000937A dedicated bwp state
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    Run Keyword If        '${gnb_${gnb_id}_oam_type}' == 'coam'
    ...        Verify counter values coam 5GC000937A dedicated bwp state    gnb_id=${gnb_id}   du_id=${du_id}
  # ...    ELSE
  # ...        Verify counter v coaaluesm CU DU 5GC002056_AIAB_04   gnb_id=${gnb_id}   du_id=${du_id}


Verify counter values coam 5GC000937A dedicated bwp state
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


Verify counter values 5GC000937A ps bwp state
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    Run Keyword If        '${gnb_${gnb_id}_oam_type}' == 'coam'
    ...        Verify counter values coam 5GC000937A ps bwp state    gnb_id=${gnb_id}   du_id=${du_id}
  # ...    ELSE
  # ...        Verify counter values coam CU DU 5GC002056_AIAB_04   gnb_id=${gnb_id}   du_id=${du_id}


Verify counter values coam 5GC000937A ps bwp state
    [Arguments]    ${gnb_id}=0      ${du_id}=0
    ${parsed_xml}    parse xml      ${pmCounter_xml_file_gNB${gnb_id}}
    &{dict}    Run keyword if       '${gnb_id}' == '${source_gnb_id}'
    ...        Create Dictionary    M55351C00001     ${M55351C00001_1_src}   M55351C01001     ${M55351C01001_1_src}
    ...                             M55351C00002     ${M55351C00002_1_src}   M55351C01002     ${M55351C01002_1_src}
    Log Dictionary                  ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter ext01    ${counter}    ${counterList}    ${parsed_xml}     du_id=${du_id}    gnb_id=${gnb_id}
    END


Verify counter values 5GC000937A bwp switching
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    Run Keyword If        '${gnb_${gnb_id}_oam_type}' == 'coam'
    ...        Verify counter values coam 5GC000937A bwp switching    gnb_id=${gnb_id}   du_id=${du_id}
  # ...    ELSE
  # ...        Verify counter values coam CU DU 5GC002056_AIAB_04   gnb_id=${gnb_id}   du_id=${du_id}


Verify counter values coam 5GC000937A bwp switching
    [Arguments]    ${gnb_id}=0      ${du_id}=0
    ${parsed_xml}    parse xml      ${pmCounter_xml_file_gNB${gnb_id}}
    &{dict}    Run keyword if       '${gnb_id}' == '${source_gnb_id}'
    ...        Create Dictionary    M55351C00001    ${M55351C00001_1_src}    M55351C01001    ${M55351C01001_1_src}
    ...                             M55351C00002    ${M55351C00002_0_src}    M55351C01002    ${M55351C01002_1_src}
    Log Dictionary                  ${dict}
    @{dict_keys}    Get Dictionary Keys    ${dict}
    FOR    ${counter}    IN     @{dict_keys}
        @{counterList}    Get From Dictionary    ${dict}    ${counter}
        Verify Counter ext01    ${counter}    ${counterList}    ${parsed_xml}     du_id=${du_id}    gnb_id=${gnb_id}
    END



Collect pm file
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    Sleep   15s
    Wait Until Keyword Succeeds   2x   20s   Collect PM Counters ext01   gnb_id=${gnb_id}
