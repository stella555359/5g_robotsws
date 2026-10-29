# robocop: off
*** Settings ***
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         taf.collectors.pmcounters  WITH NAME  pm
Library         taf.collectors.btslog  WITH NAME   btslog
Library         taf.ue
Library         SSHLibrary
Library         Collections
Library         DateTime
Library         OperatingSystem
Resource        testsuite/Wroclaw/RRM/resources/connections.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/math.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot

*** Variables ***
${GNB_ALIAS}        cOAM
${MRBTS_5G_ID}=     ${tl.gnbs[0].instance_id}
${SCF_7090}=  ${EXECDIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB007090/resources/SCFs/${MRBTS_5G_ID}

*** Keywords ***
Feature off
    [Arguments]   ${pdcchBlockingThreshold}   ${pdcchFreeThreshold}
    ${first_cell_id}   Get global cell id of first cell
    Initialise delta store
    &{test}    create dictionary
    ...    actDynPdcchTd=false
    ...    pdcchBlockingThreshold=${pdcchBlockingThreshold}
    ...    pdcchFreeThreshold=${pdcchFreeThreshold}
    Add list parameters to delta    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${first_cell_id}    dynPdcchTdMgt    &{test}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Connect with runtime release  bts
    coam.reset site   timeout=10m    connection=bts
    coam.teardown  bts
    sleep   15 min


Perform commissioning 7090
    [Arguments]     ${chBw}=10MHz
    ...             ${type0CoresetConfigurationIndex}=6
    ...             ${type0SearchSpaceConfigurationIndex}=6
    ...             ${nrcelltype}=4DL4UL
    ...             ${actFdmScheduling}=true
    ...             ${msg1freq}=5
    ...             ${dciDedicatedAggregationLevel}=AL2
    ...             ${actPdschAtSsbSlots}=true
    ...             ${actPdschRmCsirsForTracking}=true
    ...             ${ssPbchBlockPower}=8
    ...             ${miNrPdcch}=5min
    ...             ${pucchModeSelect}=longPucch
    ...             ${alSelection}=dynamic
    ...             ${actDynPdcchTd}=true
    # FIRST BWP PROFILE
    ...             ${bwpType_1}=initial
    ...             ${dciDedicatedAggregationLevel_1}=AL2
    ...             ${dciPagingAggregationLevel_1}=AL4
    ...             ${dciRaMsg2AggregationLevel_1}=AL4
    ...             ${dciRaCompletionAggregationLevel_1}=AL4
    ...             ${dciSiAggregationLevel_1}=AL4
    ...             ${downgradeAL16toAL8_1}=notAllowed
    ...             ${cRbSizeDl_1}=coreset0
    ...             ${cRbStartDl_1}=coreset0
    ...             ${cRbStartUl_1}=crb0
    ...             ${cRbSizeUl_1}=allRb
    ...             ${alSelection_1}=static
    # SECOND BWP PROFILE
    ...             ${bwpType_2}=dedicated
    ...             ${dciDedicatedAggregationLevel_2}=AL2
    ...             ${dciPagingAggregationLevel_2}=AL4
    ...             ${dciRaMsg2AggregationLevel_2}=AL4
    ...             ${dciRaCompletionAggregationLevel_2}=AL4
    ...             ${dciSiAggregationLevel_2}=AL4
    ...             ${downgradeAL16toAL8_2}=notAllowed
    ...             ${cRbSizeDl_2}=coreset0
    ...             ${cRbStartDl_2}=coreset0
    ...             ${cRbStartUl_2}=crb0
    ...             ${cRbSizeUl_2}=allRb
    ...             ${alSelection_2}=dynamic
    Log to console      __Perform commissioning with given parameters.
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}   Get from list  ${nrbts_dist}   0
    ${nrpmrnl_dist}        Get list of specific object dist name  class_name=NRPMRNL_A
    ${nrpmrnl_path}   Get from list  ${nrpmrnl_dist}   0
    ${first_cell_id}   Get global cell id of first cell
    Initialise delta store
    Add param to delta    MRBTS-${bts_id}/NRBTS-${bts_id}/NRPMRNL-1    miNrPdcch          value=${miNrPdcch}
#    #cell 10Mhz
    &{test}    create dictionary
    ...    actDynPdcchTd=${actDynPdcchTd}
    ...    pdcchBlockingThreshold=0
    ...    pdcchFreeThreshold=0
    Add list parameters to delta    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-1    dynPdcchTdMgt    &{test}
    ${cell_dists}       Get cells distname list
    FOR  ${cell}  IN  @{cell_dists}
         ${cell_dist}         Set variable    ${nrbts_path}/${cell}
         Add param to delta   ${cell_dist}                msg1FrequencyStart               value=${msg1freq}
         Add param to delta   ${cell_dist}                type0CoresetConfigurationIndex   value=${type0CoresetConfigurationIndex}
         Add param to delta   ${cell_dist}/NRCELL_FDD-1   chBwDl                           value=${chBw}
         Add param to delta   ${cell_dist}/NRCELL_FDD-1   chBwUl                           value=${chBw}
         Add param to delta   ${cell_dist}               actPdschAtSsbSlots                value=${actPdschAtSsbSlots}
         Add param to delta   ${cell_dist}       actPdschRmCsirsForTracking                value=${actPdschRmCsirsForTracking}
         Add param to delta   ${cell_dist}       ssPbchBlockPower                          value=${ssPbchBlockPower}
         Add param to delta   ${cell_dist}       pucchModeSelect                           value=${pucchModeSelect}
    END
#    bwp first profile
    ${first_bwp}    set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/BWP_PROFILE-2
    &{locationAndBandwidthDl_1}    create dictionary
    ...     cRbSizeDl=${cRbSizeDl_1}
    ...     cRbStartDl=${cRbStartDl_1}
    &{locationAndBandwidthUl_1}    create dictionary
    ...     cRbSizeUl=${cRbSizeUl_1}
    ...     cRbStartUl=${cRbStartUl_1}
    Add list parameters to delta  ${first_bwp}     locationAndBandwidthDl            &{locationAndBandwidthDl_1}
    Add list parameters to delta  ${first_bwp}     locationAndBandwidthUl            &{locationAndBandwidthUl_1}
    Add param to delta    ${first_bwp}          bwpType        value=${bwpType_1}
    Add param to delta    ${first_bwp}/PDCCH-1            dciDedicatedAggregationLevel        value=${dciDedicatedAggregationLevel_1}
    Add param to delta    ${first_bwp}/PDCCH-1            dciPagingAggregationLevel           value=${dciPagingAggregationLevel_1}
    Add param to delta    ${first_bwp}/PDCCH-1            dciRaMsg2AggregationLevel           value=${dciRaMsg2AggregationLevel_1}
    Add param to delta    ${first_bwp}/PDCCH-1            dciRaCompletionAggregationLevel     value=${dciRaCompletionAggregationLevel_1}
    Add param to delta    ${first_bwp}/PDCCH-1            dciSiAggregationLevel               value=${dciSiAggregationLevel_1}
    Add param to delta    ${first_bwp}/PDCCH-1            downgradeAL16toAL8                  value=${downgradeAL16toAL8_1}
    Add param to delta    ${first_bwp}/PDCCH-1            alSelection                         value=${alSelection_1}
#    #bwp second profile
    ${second_bwp}    set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/BWP_PROFILE-20
    # in WEB EM some values are multiplied by 100
    &{dynamicAggregationLevelSet}    Create dictionary
    ...    aggregationLevelList=AL1_AL2_AL4_AL8
    ...    cqiCorrectionUp=5
    ...    cqiDciCssAl1=159
    ...    cqiDciCssAl16=0
    ...    cqiDciCssAl2=159
    ...    cqiDciCssAl4=159
    ...    cqiDciCssAl8=10
    ...    highOlcCqiOffset=1
    ...    lowOlcCqiOffset=1
    ...    pCqiErasureActTimer=160
    ...    pCqiErasureReduction=10
    &{locationAndBandwidthDl_2}    create dictionary
    ...     cRbSizeDl=${cRbSizeDl_2}
    ...     cRbStartDl=${cRbStartDl_2}
    &{locationAndBandwidthUl_2}    create dictionary
    ...     cRbSizeUl=${cRbSizeUl_2}
    ...     cRbStartUl=${cRbStartUl_2}
    &{searchSpaceCommon}    create dictionary
    ...      coresetId=0
    ...      dciFormat=formats0-0-And-1-0
    ...      duration=1
    ...      monitoringSymbolWithinSlot=symbol_0_1
    ...      numOfPdcchCandidatesInAL2=n0
    ...      numOfPdcchCandidatesInAL4=n2
    ...      numOfPdcchCandidatesInAL8=n1
    ...      numOfPdcchCandidatesInAL16=n0
    ...      periodicity=sl1
    ...      searchSpaceId=1
    ...      searchSpaceType=Type1
    ...      slotOffset=0
     &{coresetDedicated}    create dictionary
    ...      cceToRegMapping=interleaved
    ...      coresetId=4
    ...      cRbStart=0
    ...      duration=1
    ...      interleaverSize=n3
    ...      regBundleSize=n2
    ...      size=48
    &{searchSpaceDedicated_1}    create dictionary
    ...      coresetId=0
    ...      dciFormat=formats0-0-And-1-0
    ...      duration=1
    ...      monitoringSymbolWithinSlot=symbol_0_1
    ...      numOfPdcchCandidatesInAL1=n0
    ...      numOfPdcchCandidatesInAL2=n2
    ...      numOfPdcchCandidatesInAL4=n2
    ...      numOfPdcchCandidatesInAL8=n1
    ...      numOfPdcchCandidatesInAL16=n0
    ...      periodicity=sl1
    ...      searchSpaceId=4
    ...      searchSpaceType=Type3
    ...      slotOffset=0
    &{searchSpaceDedicated_2}    create dictionary
    ...      coresetId=0
    ...      dciFormat=formats0-1-And-1-1
    ...      duration=1
    ...      monitoringSymbolWithinSlot=symbol_0_1
    ...      numOfPdcchCandidatesInAL1=n1
    ...      numOfPdcchCandidatesInAL2=n4
    ...      numOfPdcchCandidatesInAL4=n2
    ...      numOfPdcchCandidatesInAL8=n1
    ...      numOfPdcchCandidatesInAL16=n1
    ...      periodicity=sl1
    ...      searchSpaceId=5
    ...      searchSpaceType=UE-Specific
    ...      slotOffset=0
    &{searchSpaceDedicated_3}    create dictionary
    ...      coresetId=4
    ...      dciFormat=formats0-0-And-1-0
    ...      duration=1
    ...      monitoringSymbolWithinSlot=symbol_2
    ...      numOfPdcchCandidatesInAL1=n0
    ...      numOfPdcchCandidatesInAL2=n1
    ...      numOfPdcchCandidatesInAL4=n1
    ...      numOfPdcchCandidatesInAL8=n0
    ...      numOfPdcchCandidatesInAL16=n0
    ...      periodicity=sl1
    ...      searchSpaceId=6
    ...      searchSpaceType=Type3
    ...      slotOffset=0
     &{searchSpaceDedicated_4}    create dictionary
    ...      coresetId=4
    ...      dciFormat=formats0-1-And-1-1
    ...      duration=1
    ...      monitoringSymbolWithinSlot=symbol_2
    ...      numOfPdcchCandidatesInAL1=n0
    ...      numOfPdcchCandidatesInAL2=n1
    ...      numOfPdcchCandidatesInAL4=n1
    ...      numOfPdcchCandidatesInAL8=n1
    ...      numOfPdcchCandidatesInAL16=n0
    ...      periodicity=sl1
    ...      searchSpaceId=7
    ...      searchSpaceType=UE-Specific
    ...      slotOffset=0
    ${dynamicAggregationLevelSet_list}    create list    ${dynamicAggregationLevelSet}
    Add list parameters to delta  ${second_bwp}     locationAndBandwidthDl            &{locationAndBandwidthDl_2}
    Add list parameters to delta  ${second_bwp}     locationAndBandwidthUl            &{locationAndBandwidthUl_2}
    Add list parameters to delta   ${second_bwp}/PDCCH-1     dynamicAggregationLevelSet                                &{dynamicAggregationLevelSet}
    Add list parameters to delta   ${second_bwp}/PDCCH-1/PDCCH_CONFIG_COMMON-1       searchSpaceCommon                 &{searchSpaceCommon}
    Add list parameters to delta   ${second_bwp}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1    coresetDedicated                  &{coresetDedicated}
    Add list parameters to delta   ${second_bwp}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1    searchSpaceDedicated              &{searchSpaceDedicated_1}
    Add list parameters to delta   ${second_bwp}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1    searchSpaceDedicated              &{searchSpaceDedicated_2}
    Add list parameters to delta   ${second_bwp}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1    searchSpaceDedicated              &{searchSpaceDedicated_3}
    Add list parameters to delta   ${second_bwp}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1    searchSpaceDedicated              &{searchSpaceDedicated_4}
    add list of dictionaries to delta  ${second_bwp}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1    searchSpaceDedicated
    ...    ${searchSpaceDedicated_1}
    ...    ${searchSpaceDedicated_2}
    ...    ${searchSpaceDedicated_3}
    ...    ${searchSpaceDedicated_4}
    Add param to delta    ${second_bwp}          bwpType        value=${bwpType_2}
    Add param to delta    ${second_bwp}/PDCCH-1            dciDedicatedAggregationLevel        value=${dciDedicatedAggregationLevel_2}
    Add param to delta    ${second_bwp}/PDCCH-1            dciPagingAggregationLevel           value=${dciPagingAggregationLevel_2}
    Add param to delta    ${second_bwp}/PDCCH-1            dciRaMsg2AggregationLevel           value=${dciRaMsg2AggregationLevel_2}
    Add param to delta    ${second_bwp}/PDCCH-1            dciRaCompletionAggregationLevel     value=${dciRaCompletionAggregationLevel_2}
    Add param to delta    ${second_bwp}/PDCCH-1            dciSiAggregationLevel               value=${dciSiAggregationLevel_2}
    Add param to delta    ${second_bwp}/PDCCH-1            downgradeAL16toAL8                  value=${downgradeAL16toAL8_2}
    Add param to delta    ${second_bwp}/PDCCH-1            alSelection                         value=${alSelection_2}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Verify if all cells are onair
    Log to console   __Locking unnecessary cells
    Lock all cells except first
    Log to console   __Cells locked

Lock all cells except first
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}   Get from list  ${nrbts_dist}   0
    ${first_cell_id}   Get global cell id of first cell
    ${first_cell}=   Set variable   '${nrbts_path}/NRCELL-${first_cell_id}'
    ${nrcell_dists}   Get list of specific object dist name  class_name=NRCELL_A
    Connect with runtime release   cOAM
    FOR  ${cell}  IN  @{nrcell_dists}
        ${result}=   Evaluate   ${first_cell} != '${cell}'
        Run keyword if   ${result} == True   coam.lock   dist_name=${cell}   connection=cOAM  timeout=300
    END
    coam.teardown  cOAM

Unlock all locked cells
    ${nrcell_dists}   Get list of specific object dist name  class_name=NRCELL_A
    Connect with runtime release   cOAM
    FOR  ${cell}  IN  @{nrcell_dists}
        ${status}   coam.get cell specific info   cell_id=${cell}   connection=cOAM
        ${cell_status}   set variable   '${status['status']['administrativeState']}'
        Run keyword if   ${cell_status} == 'Locked'   coam.unlock   dist_name=${cell}   connection=cOAM  timeout=300
    END
    coam.teardown  cOAM

Start low ULDL tput
    [Documentation]  Used Only by max tputu testing
    [Arguments]  ${protocol}
    ...          ${ue_alias}=UE_1
    ...          ${tput_duration}=60s
    ...          ${tput_DL_bandwidth}=200 kbits/sec
    ...          ${tput_UL_bandwidth}=400 kbits/sec
    ...          ${packet_size}=1400
    ...          ${dt_DL_name}=DT_DL_7090_UE_1
    ...          ${dt_UL_name}=DT_UL_7090_UE_1
    taf.ue.Start Data Transfer  dt_name=${dt_DL_name}  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwidth}              protocol=${protocol}       packet_size=${packet_size}
    ...                  max_segment_size=536
    taf.ue.Start Data Transfer   dt_name=${dt_UL_name}   ue_alias=${ue_alias}   direction=ul   duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    ...                  max_segment_size=536

Detach and attach 2 UEs
    taf.ue.Detach Ue   UE_1
    taf.ue.Detach Ue   UE_2
    taf.ue.Attach Ue   UE_1
    taf.ue.Attach Ue   UE_2

Start different ULDL tput on all UEs
    FOR  ${i}  IN RANGE  1  3
        Start low ULDL tput     ue_alias=UE_2   protocol=udp    tput_duration=3600s   tput_DL_bandwidth=2 Mbits/sec
        ...                     tput_UL_bandwidth=200 kbits/sec   dt_DL_name=DT_DL_UE_${i}   dt_UL_name=DT_UL_UE_${i}
    END
    FOR  ${i}  IN RANGE  3  5
        Start low ULDL tput     ue_alias=UE_2   protocol=udp    tput_duration=3600s   tput_DL_bandwidth=200 Mbits/sec
        ...                     tput_UL_bandwidth=2000 kbits/sec   dt_DL_name=DT_DL_UE_${i}   dt_UL_name=DT_UL_UE_${i}
    END

Get average throughputs with feature on
    FOR  ${i}  IN RANGE  1  5
        ${var}   taf.ue.Get Average Throughput   dt_name=DT_DL_UE_${i}
        Set test variable   ${average_DL_feature_ON_${i}}   ${var}
        ${var}   taf.ue.Get Average Throughput   dt_name=DT_UL_UE_${i}
        Set test variable   ${average_UL_feature_ON_${i}}   ${var}
    END

Get average throughputs with feature off
    FOR  ${i}  IN RANGE  1  5
        ${var}   taf.ue.Get Average Throughput   dt_name=DT_DL_UE_${i}
        Set test variable   ${average_DL_feature_OFF_${i}}   ${var}
        ${var}   taf.ue.Get Average Throughput   dt_name=DT_UL_UE_${i}
        Set test variable   ${average_UL_feature_OFF_${i}}   ${var}
    END

Compare throughputs
    FOR  ${i}  IN RANGE  1  5
        Should be true   abs(${average_DL_feature_OFF_${i}} - ${average_DL_feature_ON_${i}}) < 10
        Should be true   abs(${average_UL_feature_OFF_${i}} - ${average_UL_feature_ON_${i}}) < 5
    END

Compare high throughputs
    FOR  ${i}  IN RANGE  1  5
        Should be true   abs(${average_DL_feature_OFF_${i}} - ${average_DL_feature_ON_${i}}) < 2000
        Should be true   abs(${average_UL_feature_OFF_${i}} - ${average_UL_feature_ON_${i}}) < 20
    END

Compare different throughputs
    FOR  ${i}  IN RANGE  1  3
        Should be true   abs(${average_DL_feature_OFF_${i}} - ${average_DL_feature_ON_${i}}) < 20
        Should be true   abs(${average_UL_feature_OFF_${i}} - ${average_UL_feature_ON_${i}}) < 2
    END
    FOR  ${i}  IN RANGE  3  5
        Should be true   abs(${average_DL_feature_OFF_${i}} - ${average_DL_feature_ON_${i}}) < 2000
        Should be true   abs(${average_UL_feature_OFF_${i}} - ${average_UL_feature_ON_${i}}) < 20
    END

Perform 7090 SCF commissioning
    [Arguments]                  ${TC}
    Log to console               Performing 7090 SCF commissioning
    Connect with runtime release  ${GNB_ALIAS}
    coam.perform commissioning   ${MRBTS_5G_ID}  ${SCF_7090}/7090_${TC}_${MRBTS_5G_ID}.xml  ${True}  ${True}  600  ${GNB_ALIAS}
    Wait until keyword succeeds  10min   1min   Verify all cells are onair with admin
    coam.teardown  ${GNB_ALIAS}

Check counters value 7090-C-B1_1 feature on
    Should be true   ${M55335C05001}>0
    Should be true   ${M55335C05002}>0
    Should be true   ${M55335C05006}>0
    Should be true   ${M55335C05007}>0
    Should be true   ${M55335C05006}>${M55335C05007}
    Should be true   ${M55335C05008}==0

Check counters value 7090-C-B1_1 feature off
    Should be true   ${M55335C05001}==0
    Should be true   ${M55335C05002}==0
    Should be true   ${M55335C05006}==0
    Should be true   ${M55335C05007}>0
    Should be true   ${M55335C05008}==0

Check counters value 7090-C-B2_3_NSA feature on
    Should be true   ${M55335C05001}==0
    Should be true   ${M55335C05002}==0
    Should be true   ${M55335C05006}==0
    Should be true   ${M55335C05007}>0
    Should be true   ${M55335C05008}>0

Check counters value 7090-C-B2_3_NSA feature off
    Should be true   ${M55335C05001}==0
    Should be true   ${M55335C05002}==0
    Should be true   ${M55335C05006}==0
    Should be true   ${M55335C05007}>0
    Should be true   ${M55335C05008}==0

Check counters value 7090-C-B1_2 feature on
    Should be true   ${M55335C05006}>0
    Should be true   ${M55335C05007}>0
    Should be true   ${M55335C05006}>${M55335C05007}
    Should be true   ${M55335C05008}==0

Check counters value 7090-C-B1_2 & 7090-C-B2_3_SA feature off
    Should be true   ${M55335C05001}<${M55335C05001_ON}
    Should be true   ${M55335C05002}<${M55335C05002_ON}
    Should be true   ${M55335C05006}==0
    Should be true   ${M55335C05007}>0
    Should be true   ${M55335C05008}==0

Check counters value 7090-C-B2_3_SA feature on
    Should be true   ${M55335C05006}>0
    Should be true   ${M55335C05007}>0
    Should be true   ${M55335C05008}>0
