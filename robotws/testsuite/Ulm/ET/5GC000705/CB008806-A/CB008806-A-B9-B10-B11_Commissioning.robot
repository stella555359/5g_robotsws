*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description:

*** Variables ***

${FEATURE}                   CB008806-A
${SCF}                       scfc_${FEATURE}.xml
${NIDD_VERSION}              NRBTSCL22R2_2112_100

${NRREL_ID}                  2

&{TDD_PCELL}                 lcrId=3  physCellId=52  ssbFrequency=639936  freqBandIndicatorNR=78
&{TDD_SCELL}                 lcrId=3  physCellId=52  ssbFrequency=639936  freqBandIndicatorNR=78
&{FDD_PCELL}                 lcrId=1  physCellId=50  ssbFrequency=425070  freqBandIndicatorNR=66
&{FDD_SCELL}                 lcrId=4  physCellId=54  ssbFrequency=176210  freqBandIndicatorNR=5

@{carrierAggregationSupportList}        ca_Fdd_Fdd  ca_Fdd_Fr1Tdd_Sa  ca_Fr1Tdd_Fdd_Sa

&{a1MeasSCellAddSsbRsrp}
...                          a1HysteresisSCellAddSsbRsrp=0
...                          a1ThresholdSCellAddSsbRsrpFDD=10
...                          a1ThresholdSCellAddSsbRsrpTDD=10
...                          a1TimeToTriggerSCellAddSsbRsrp=320ms

&{a2MeasPCellSwitchSsbRsrq}
...                          a2HysteresisPCellSwitchSsbRsrq=0
...                          a2ThresholdPCellSwitchSsbRsrq=10
...                          a2TimeToTriggerPCellSwitchSsbRsrq=480ms
...                          pCellSwitchOffsetSsbRsrq=0

*** Keywords ***

Commissioning
    scf.load_scf              ${P_ORIG_SCF}

    FOR   ${dist_name}                                          ${p_name}                         ${value}    IN
    ...   NRBTS-1                                               actInterFreqHoSA                  true
    ...   NRBTS-1                                               actIntraFreqHoSA                  true
    ...   NRBTS-1                                               timerXnDataFwdGuard               250
    ...   MRBTS-1/MNL-1/AMGR-1/LUAC-1                           webEMSessionLogoutTimer           7200
    ...   MRBTS-1/MNL-1/MNLENT-1/PMCADM-1                       reportingIntervalPm               5min
    ...   NRBTS-1/NRPMRNL-1                                     miNrRelReportCu                   5min
    ...   NRBTS-1/NRDU-1                                        actConnectedModeMobilityCA        true
    ...   NRBTS-1/NRDU-1                                        flexibleCAMode                    ConfigurationIndependent
    ...   NRBTS-1/NRCELL-${FDD_PCELL.lcrId}                     measGapSelectionSA                favourUeThroughput
    ...   NRBTS-1/NRCELL-${FDD_SCELL.lcrId}                     actCsiMeasEthFlowControl          CSIMeasBasedAllUe
    ...   NRBTS-1/NRCELL-${TDD_PCELL.lcrId}                     measGapSelectionSA                favourUeThroughput
    ...   NRBTS-1/NRCELL-${TDD_PCELL.lcrId}                     measGapSelection                  favourUeThroughput
    ...   NRBTS-1/NRCELL-${TDD_PCELL.lcrId}                     actK1Opt                          intra-gNB
    ...   NRBTS-1/NRCELL-${FDD_SCELL.lcrId}                     actK1Opt                          intra-gNB
    ...   NRBTS-1/NRCELL-${TDD_PCELL.lcrId}                     ifhoSsbSmtcOffset                 0
    ...   NRBTS-1/NRCELL-${FDD_PCELL.lcrId}/NRREL-${NRREL_ID}   handoverAllowedSA                 allowed
    ...   NRBTS-1/NRCELL-${FDD_PCELL.lcrId}/NRREL-${NRREL_ID}   lcrId                             ${TDD_SCELL.lcrId}
    ...   NRBTS-1/NRCELL-${FDD_PCELL.lcrId}/NRREL-${NRREL_ID}   sCellAdditionMethod               covBasedA1
          Set Element    ${dist_name}                           ${p_name}                         ${value}
    END

    Set New List              dist_name=NRBTS-1/NRDU-1           list_name=carrierAggregationSupportList
    scf.add_elements_to_list  dist_name=NRBTS-1/NRDU-1           list_name=carrierAggregationSupportList
    ...                                                          elements=${carrierAggregationSupportList}

    Enable A1 Scell Measurement             cell_id=${FDD_PCELL.lcrId}
    Enable A1 Scell Measurement             cell_id=${TDD_PCELL.lcrId}
    Enable A2 PCell Measurement             cell_id=${TDD_PCELL.lcrId}

    Add NRREL to TDD_PCELL
    Add NRHOIF to FDD_PCELL
    Add NRHOIF to TDD_PCELL

    Config PCell Switch        cell_id=${TDD_SCELL.lcrId}
    Apply Delta SCF            ${P_ORIG_SCF}    scfc_${FEATURE}

Add NRHOIF to FDD_PCELL
    Add NRHOIF                              cell_id=${FDD_PCELL.lcrId}
    FOR   ${p_name}                         ${value}    IN
    ...   a1BasedPCellSwitchEnabled         true
    ...   ssbFrequency                      ${TDD_SCELL.ssbFrequency}            # 5G_CP_ARC_ALG_1557: nrarfcn for ssbFrequency of SCell (3)
    ...   freqBandIndicatorNR               ${TDD_SCELL.freqBandIndicatorNR}     # SCELL (3)
    ...   ifhoSsbScs                        30 KHz
    ...   ifhoSsbSmtcDuration               sf5
    ...   ifhoSsbSmtcPeriodicity            sf10
    ...   a3MeasEnabled                     none
    ...   a5MeasEnabled                     none
          Set Element                       NRBTS-1/NRCELL-${FDD_PCELL.lcrId}/NRHOIF-1  ${p_name}  ${value}
    END

Add NRHOIF to TDD_PCELL
    Add NRHOIF                              cell_id=${TDD_PCELL.lcrId}
    FOR   ${p_name}                         ${value}    IN
    ...   a2BasedPCellSwitchEnabled         true
    ...   a2BasedPCellSwitchPriority        1
    ...   ssbFrequency                      ${FDD_SCELL.ssbFrequency}          # 5G_CP_ARC_ALG_1557: nrarfcn for ssbFrequency of SCell (4)
    ...   freqBandIndicatorNR               ${FDD_SCELL.freqBandIndicatorNR}   # SCELL (4)
    ...   ifhoSsbScs                        15KHz
    ...   ifhoSsbSmtcDuration               sf5
    ...   ifhoSsbSmtcPeriodicity            sf10
    ...   a3MeasEnabled                     none
    ...   a5MeasEnabled                     none
    ...   thresholdPCellSwitchTargetRsrp    0
    ...   thresholdPCellSwitchTargetRsrq    0
          Set Element                       NRBTS-1/NRCELL-${TDD_PCELL.lcrId}/NRHOIF-1  ${p_name}  ${value}
    END

Add NRREL to TDD_PCELL
    ${mo_exist}=                            scf.is_object_in_scf      dist_name=NRBTS-1/NRCELL-${TDD_PCELL.lcrId}/NRREL-${NRREL_ID}
    IF   ${mo_exist}            scf.remove_mo_with_descendant_mos  dist_name=NRBTS-1/NRCELL-${TDD_PCELL.lcrId}/NRREL-${NRREL_ID}
    scf.clone_mo_with_descendant_mos        source_mo_dist_name=NRBTS-1/NRCELL-${FDD_PCELL.lcrId}/NRREL-${NRREL_ID}
    ...                                     target_mo_dist_name=NRBTS-1/NRCELL-${TDD_PCELL.lcrId}/NRREL-${NRREL_ID}
    Set Element                             dist_name=NRBTS-1/NRCELL-${TDD_PCELL.lcrId}/NRREL-${NRREL_ID}  p_name=lcrId  value=${FDD_SCELL.lcrId}

Enable A1 SCell Measurement
    [Arguments]   ${cell_id}
    Set Element            dist_name=NRBTS-1/NRCELL-${cell_id}  p_name=a1MeasSCellAddEnabled          value=rsrp
    Set New List           dist_name=NRBTS-1/NRCELL-${cell_id}  list_name=a1MeasSCellAddSsbRsrp
    scf.add_item_to_list   dist_name=NRBTS-1/NRCELL-${cell_id}  list_name=a1MeasSCellAddSsbRsrp       elements=${a1MeasSCellAddSsbRsrp}

Enable A2 PCell Measurement
    [Arguments]   ${cell_id}=${TDD_PCELL.lcrId}
    Set Element            dist_name=NRBTS-1/NRCELL-${cell_id}  p_name=a2MeasPCellSwitchEnabled          value=rsrq
    Set New List           dist_name=NRBTS-1/NRCELL-${cell_id}  list_name=a2MeasPCellSwitchSsbRsrq
    scf.add_item_to_list   dist_name=NRBTS-1/NRCELL-${cell_id}  list_name=a2MeasPCellSwitchSsbRsrq       elements=${a2MeasPCellSwitchSsbRsrq}

Config PCell Switch
    [Arguments]   ${cell_id}
    ${dist_name}=          Set Variable                NRBTS-1/NRCELL-${cell_id}
    Set Element            dist_name=${dist_name}      p_name=filterCoeffSsbRsrp                 value=fc4
    Set Element            dist_name=${dist_name}      p_name=filterCoeffSsbRsrq                 value=fc4
    Set Element            dist_name=${dist_name}      p_name=a1MeasPCellSwitchEnabled           value=rsrq

    ${list_elements}=      Create dictionary           a1HysteresisPCellSwitchSsbRsrq=0
    ...                                                a1ThresholdPCellSwitchSsbRsrq=30
    ...                                                a1TimeToTriggerPCellSwitchSsbRsrq=480ms
    Set New List           dist_name=${dist_name}      list_name=a1MeasPCellSwitchSsbRsrq
    scf.add_item_to_list   dist_name=${dist_name}      list_name=a1MeasPCellSwitchSsbRsrq
    ...                                                elements=${list_elements}
