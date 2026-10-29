*** Settings ***
Documentation
...   Test Suite Purpose:
...   Feature 5GC0000937-A BandWidth Saving Testing
...   DESCRIPTION:Feature 5GC0000937-A automated regression testing
...   AUTHOR :          nadine.crasnier@nokia.com
...   date starting    : 22/08/2023
...   just started  ;  test writing is on going


Resource          ../resources/common_settings.robot
Resource          taf/rfrl/common_resources/common_step/interface.robot
Resource          ${CURDIR}/../resources/keywordbook-937A053.robot

#Force Tags      			    CA_RAN_PZ_NPS   QCD_MN_RAN   QCP_RAN_ST   SBTS00

Suite Setup                                 Preconditions of Test Suite 5GC000937_A_3
Suite Teardown                              Postconditions of Test Suite 5GC000937_A_3


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

${DEBUG_MODE_CONSOLE}=       True
${GN_WEBUI[0]}=              10.14.49.77
#${scf_file_937_CA}           ${CURDIR}/../scf/scf_CV307_CA_20230822.xml
#${scf_file_937_CA}           ${CURDIR}/../scf/scf_CV307_CA_24R3_20240718.xml
#${scf_file_937_CA}           ${CURDIR}/../scf/scf_cv307_CA_25R1_20250224.xml
${scf_file_937_CA}           ${CURDIR}/../scf/scf_cv307_CA_25R2_20250220.xml
${btsName937CA}              5G_CV307_ASIB_ABIO_AZQO_ARPA_Classical_gNB_SA_2S_1CC_eCPRI


*** Test Cases ***
[1][1.0] 5GC000937_A_53_Check_SingleUE_Switch_to_psBWP_on_lowDlUl_traffic_With_CA_FDD_TDD
    [Setup]	  Run Keywords    preconditions.Get Scout Bts Name    Preconditions of Test Scenario 5GC000937_A_3
    [Timeout]     60min

    Wait until coam gNB to be onair state and cells enabled ext01   gnb_id=${source_gnb_id}   num_of_disabled_cells=0

    # Step1 : check that cell TDD only can do Power Saving
    # Configure attenuators to make only cell TDD visible for the UE
    # Start call
    # Establish UL lesser tput than Power Saving BWP thresold trigger
    # Wait for next measurement period
    Set Hytem Attenuations for gNB 0 cell 0    value=0000
    Set Hytem Attenuations for gNB 0 cell 1    value=9300
    #wait until keyword succeeds  1200s  30s  Start Call
    Perform Attach Ue
    Sleep    60s
    ute_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_id}  direction=ul  duration=660s
    ...    throughput=10 Kbits/sec    protocol=${protocol}	  packet_size=${Packet_Size}    qci=${qci_ul}
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_UL

    # Step2:
    # Check counters from previous pm period should indicate power saving BWP
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_UL
    Log to console   \n------------------------------------------------------------------------------------
    Log to console    Analyse step2:
    Log to console    Check pm obs counter matche PS BWD relative to previous measurement interval
    Log to console   ------------------------------------------------------------------------------------\n
    Collect pm file    gnb_id=${source_gnb_id}
    Analyse step2

    # Step3:
    # stop UL traffic
    # detach UE
    # Configure attenuators to attach on cell FDD only
    # Start call
    # Configure attenuators to do CA FDD-TDD
    # Establish DL to make CA traffic
    # Wait for next measurement period
    # stop UL traffic
    ute_ue .Stop Data Transfer  dt_name=DT_UL
    Sleep    30s
    Perform Detach Ue
    Sleep    30s
    Set Hytem Attenuations for gNB 0 cell 0    value=9000
    Set Hytem Attenuations for gNB 0 cell 1    value=0000
    #wait until keyword succeeds  1200s  30s  Start Call
    Perform Attach Ue
    Sleep    60s
    Set Hytem Attenuations for gNB 0 cell 0    value=2000
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_id}  direction=dl  duration=660s
    ...    throughput=120 Mbits/sec    protocol=${protocol}	  packet_size=${Packet_Size}    qci=${qci_ul}
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_DL

    # Step4:
    # Check counters from previous pm period should indicate power saving BWP
    wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    ute_ue.Check Data Transfer Is Alive    dt_name=DT_DL
    Log to console   \n------------------------------------------------------------------------------------
    Log to console    Analyse step4:
    Log to console    Check pm obs counter matche dedicated BWD relative to previous measurement interval
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
#    Setup Testline Suite Variables

Preconditions of Test Scenario 5GC000937_A_3
    Create a Test Scenario Folder
#    Run Keyword if    '${DEBUG}'=='False'    Set Hytem Attenuations for gNB 0 cell 0    value=2000
#    Run Keyword if    '${DEBUG}'=='False'    Set Hytem Attenuations for gNB 0 cell 1    value=0000
    Prepare counters and expected values 5GC000937_A_3
#    update gnb parameter values with delta commissioning     gnb_id=${source_gnb_id}
#    Attach QCAT 5G Licence with LK
    Ue Initialization    ue_alias=${ue_id}    capabilities=REAL_UE
    Get btsNameScf from SCF      ${source_gnb_id}
    Log to console    Loading SCF CA
    Run keyword if  '${btsName937CA}' != '${btsNameScf}'     Commissioning.Do Commissioning      ${scf_file_937_CA}      gNB=${source_gnb_id}
#    keywordbook-480_ext01.get scf coam ext01    scf=SCF_CA_start_gnb_${source_gnb_id}.xml
#    Update gnb parameter values with full commissioning coam source gnb for 937A053
# to add : re load SW, needed for RU ARPA ? to check


Postconditions of Test Scenario 5GC000937_A_3
    ute_ue.Await Data Transfer Finish                 dt_name=DT_DL
#    ute_ue.Await Data Transfer Finish                 dt_name=DT_UL
    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=120 Mbits/sec   deviation=${tput_deviation}
#    ute_ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=10 Kbits/sec    deviation=${tput_deviation}
#    Run Keyword if    '${DEBUG}'=='False'   Report test result to reporting portal    log_dir=${OUTPUT DIR}     gnb_id=${source_gnb_id}
    Run Keyword if    '${DEBUG}'=='False'    Set Hytem Attenuations for gNB 0 cell 0    value=9350
    Run Keyword if    '${DEBUG}'=='False'    Set Hytem Attenuations for gNB 0 cell 1    value=0000


Postconditions of Test Suite 5GC000937_A_3
    Run keyword and ignore error    Perform Detach Ue
#    Run keyword and ignore error    Detach QCAT 5G Licence with LK
#    Run Keyword if    '${DEBUG}'=='False' and '${SUITE STATUS}'=='FAIL'    Collect snapshot coam ext01    gnb_id=${source_gnb_id}
    Run Keyword if    '${DEBUG}'=='False'    restore parameter values with full commissioning ext01
    Wait until coam gNB to be onair state and cells enabled ext01   gnb_id=${source_gnb_id}   num_of_disabled_cells=0
    interface.Common step trigger


Get btsNameScf from SCF
    [Arguments]           ${gNB}=0
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${resultBaseDir}/SCFC_start_gnb_${gNB}.xml
#   MRBTS-307  =   ${gnb_${gNB}_mrbts_distName}
    ${dist_name}=      set variable       ${gnb_${gNB}_mrbts_distName}
    scf.load_scf    ${current_scf_fullname}
    ${btsNameScf}    scf.get_value_from_scf   p_name=btsName
    ...              dist_name=${dist_name}
    set suite variable         ${btsNameScf}


Prepare counters and expected values 5GC000937_A_3
    # Source gNB:
    # -----------
    # distName="MRBTS-xxx/NRBTS-yyy"
    set test variable    @{srb3SupportEnabled_src}              ${source_gnb_id}   false
    set test variable    @{actCarrierAggregation_src}           ${source_gnb_id}   false
    set test variable    @{dlBufferEmptyRatioFromPsBwp}         ${source_gnb_id}   40              # list name="powerSavingBwpSwitching
    set test variable    @{dlBufferEmptyRatioToPsBwp}           ${source_gnb_id}   90              # list name="powerSavingBwpSwitching
    set test variable    @{dlRateThresholdFromPsBwp}            ${source_gnb_id}   35              # list name="powerSavingBwpSwitching
    set test variable    @{dlRateThresholdToPsBwp}              ${source_gnb_id}   30              # list name="powerSavingBwpSwitching
    set test variable    @{measurementDurationFromPsBwp}        ${source_gnb_id}   40              # list name="powerSavingBwpSwitching
    set test variable    @{measurementDurationToPsBwp}          ${source_gnb_id}   160             # list name="powerSavingBwpSwitching
    set test variable    @{ulRateThresholdNoVoNRFromPsBwp}      ${source_gnb_id}   20              # list name="powerSavingBwpSwitching
    set test variable    @{ulRateThresholdNoVoNRToPsBwp}        ${source_gnb_id}   15               # list name="powerSavingBwpSwitching
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
    set test variable    @{actPdschAtSsbSlots}                  ${source_gnb_id}   false
    set test variable    @{actPdschRmCsirsForTracking}          ${source_gnb_id}   false
    set test variable    @{actpucchModeSelect}                  ${source_gnb_id}   longPucch
    set test variable    @{bwpDN_0}                             ${source_gnb_id}   BWP_PROFILE-5   # list name="cellBwpList item0
    set test variable    @{cellBwpId_0}                         ${source_gnb_id}   0               # list name="cellBwpList item0
    set test variable    @{bwpDN_1}                             ${source_gnb_id}   BWP_PROFILE-54  # list name="cellBwpList item1
    set test variable    @{cellBwpId_1}                         ${source_gnb_id}   1               # list name="cellBwpList item1
    set test variable    @{bwpDN_2}                             ${source_gnb_id}   BWP_PROFILE-51  # list name="cellBwpList item2
    set test variable    @{cellBwpId_2}                         ${source_gnb_id}   2               # list name="cellBwpList item2
    set test variable    @{actPowerSavingBWP_src}               ${source_gnb_id}   true
    set test variable    @{actCDrx_src}                         ${source_gnb_id}   false
    set test variable    @{cbraPreamblesPerSsb_src}             ${source_gnb_id}   n64

    set test variable    ${measurement_period_in_min}                              5
    set test variable    @{M55351C00001_0_src}      MAX_UE_ACTIVE_PWR_SAVING_BWP   0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C00001_1_src}      MAX_UE_ACTIVE_PWR_SAVING_BWP   1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C01001_0_src}      MAX_UE_CONFIG_2BWP             0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C01001_1_src}      MAX_UE_CONFIG_2BWP             1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C00002_0_src}      AVG_UE_ACTIVE_PWR_SAVING_BWP   0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C00002_1_src}      AVG_UE_ACTIVE_PWR_SAVING_BWP   1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C01002_0_src}      AVG_UE_CONFIG_2BWP             0    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55351C01002_1_src}      AVG_UE_CONFIG_2BWP             1    ${source_gnb_id}   ${source_distName}   DBWP   egal
    set test variable    @{M55316C03001_300_src}    PSCELL_UE_1_ACT_SCELL_DL     300    ${source_gnb_id}   ${source_distName}   DBWP   egal


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
    # Step1 :  check distName="MRBTS-xxx/NRBTS-yyy/NRCELL-z" cellBwpList items if  any items with cellBwpId=2 exists
    #         then check and updates paramters of associated profile
    #         else power saving profile must be created
    set test variable   ${nrcell_dist}     ${gnb_${gnb_id}_bts_distName}/${source_distName}

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

    ${param_list}     Create List
    ...    ${d_srb3SupportEnabled}
    ...    ${d_actCarrierAggregation}
    ...    ${d_cbraPreamblesPerSsb}
    ...    ${d_actCDrx}
    ...    ${d_actPowerSavingBWP}
    BuiltIn.Log To Console    \ndelta commissioning started
    json delta commissioning coam ext01       ${param_list}    ${gnb_id}
    BuiltIn.Log To Console    \ndelta commissioning finished

Start Call
    Wait for next measurement interval ext01
    ...    additional-waiting-time=3s
    ...    is_reduce_waiting-time=false
    #Perform Attach Ue And Check Nr5g Bearer Is Up  trace_duration=20s  isStartDataTransfert=false  ue_alias=${ue_id}
    Run keyword and ignore error
    ...   Perform Attach Ue And Check Nr5g Bearer Is Up    isStartDataTransfert=false  ue_alias=${ue_id}     trace_duration=20s  ue_alias=${ue_id}


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
    Verify counter values 5GC000937A ps bwp state   gnb_id=${source_gnb_id}
    #Verify counter not CA


Analyse step4
    Verify counter values 5GC000937A dedicated bwp state during CA state  gnb_id=${source_gnb_id}
    Verify counter value 5GC000937A M55316C03001 during CA state NRCELL-3


Verify counter value 5GC000937A M55316C03001 during CA state NRCELL-3
    # M55316C03001 =  number of P(S)Cell UEs with 1 activated SCell in DL
    # Check PM counter M55316C03001 value From PM file
    # It should be equal to 300 in 5 mn period when UE is in CA state
    #${cell}      Evaluate   '${source_distName}'[-1:]
    #Log to console      cell : ${cell}

    ${pi_dict}=     get_pi_value_for_one_cell_from_file
    ...             pi_dir=${resultDir}/counter_gNB${source_gnb_id}
    ...             pi_name=M55316C03001
    ...             file_name=pm.xml
       ...          cell=3

    ${log}=     CATENATE    SEPARATOR=
    ...    \ncounter M55316C03001 "${M55316C03001_300_src[0]}" for ${M55316C03001_300_src[3]}
    ...    value=${pi_dict} expected: ${M55316C03001_300_src[1]}
    Log to console    ${log}
#    should be true     ${pi_dict} == ${M55316C03001_300_src[1]}
    should be true     abs( ${pi_dict} - ${M55316C03001_300_src[1]} ) < 2


Verify counter values 5GC000937A dedicated bwp state during CA state
    [Arguments]    ${gnb_id}=0    ${du_id}=0
    Run Keyword If        '${gnb_${gnb_id}_oam_type}' == 'coam'
    ...        Verify counter values coam 5GC000937A dedicated bwp state during CA state   gnb_id=${gnb_id}   du_id=${du_id}
  # ...    ELSE
  # ...        Verify counter v coaaluesm CU DU 5GC002056_AIAB_04   gnb_id=${gnb_id}   du_id=${du_id}


Verify counter values coam 5GC000937A dedicated bwp state during CA state
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
    #bypass robocop
    ${du_id}=    Set Variable     ${du_id}
    Sleep   15s
    Wait Until Keyword Succeeds   2x   20s   Collect PM Counters ext01   gnb_id=${gnb_id}
