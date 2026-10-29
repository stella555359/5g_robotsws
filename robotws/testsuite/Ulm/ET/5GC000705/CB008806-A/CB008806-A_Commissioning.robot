*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for 5GC000705-A commissioning

Resource    ../CB008806-B/CB008806-B_Keywords.robot
Resource    ../../resources/SQD65/sqd65_commissioning.robot
*** Variables ***

${CB008806-A_SCF}                scfc_8806-A.xml
${NIDD_VERSION}                  NRBTSCL22R2_2112_100

&{plmn}=                         mcc=311  mnc=489  mncLength=3
${cellTechnology}                TDD

*** Keywords ***


Commissioning for NG HO
    scf.load_scf        ${P_ORIG_SCF}
    Update Parameter in NRCELL  cell_id=1
    Update Parameter in NRCELL  cell_id=2
    Add A1Measurement to Nrcell
    Add A2Measurement to Nrcell
    Add Emergency in Nrcell    cell_id=1
    Add Emergency in Nrcell    cell_id=2
    Get Val from SCF
    Add NRREL1 to SCF
    Add NRREL2 to SCF
    Add NRADJNRCELL1 to SCF
    Add NRADJNRCELL2 to SCF
    Add NRHOIF to SCF
    Add NRPMQAP to SCF
    Add NRDRB16 to SCF
    Add NRDRB17 to SCF
    Add NRDRB5QI7 to SCF
    Add NRDRBRMAC4 to SCF
    Add NRDRBRMAC5 to SCF
    Add Trace Control Entity
    Add Radio CU Trace Session
    Enable PCMD and Cell Trace

    FOR   ${dist_name}                                              ${p_name}                       ${value}      IN
    ...   MRBTS-1/MNL-1/AMGR-1/LUAC-1                               webEMSessionLogoutTimer         7200
    ...   MRBTS-1/MNL-1/MNLENT-1/PMCADM-1                           reportingIntervalPm             5min
    ...   NRBTS-1                                                   tNgRelocExecDeltN               3000
    ...   NRBTS-1                                                   tNgRelocPrepN                   2000
    ...   NRBTS-1                                                   tNgRelocOverallN                5000
    ...   NRBTS-1                                                   tNgRelocCancelN                 2000
    ...   NRBTS-1/NRCELL-1                                          reportIntervalSA                ms120
    ...   NRBTS-1                                                   actCoverageNonCoherentUes       true
    ...   NRBTS-1                                                   actNgcFlexSaMode                true
    ...   NRBTS-1/NRCELL-1                                          actCDrx                         true
    ...   NRBTS-1/NRCELL-1                                          actVoNR                         true
    ...   NRBTS-1/NRCELL-2                                          actVoNR                         true
    ...   NRBTS-1                                                   actIntraNrNgHo                  sourceAndTarget
    ...   NRBTS-1                                                   actIntraFreqHoSA                true
    ...   NRBTS-1                                                   actInterFreqHoSA                true
    ...   NRBTS-1                                                   actNrpmqapProfiles              true
    ...   NRBTS-1                                                   act3gppBL23R1                   false
    ...   NRBTS-1/NRDRB-10                                          nrDrbMacDN                      MRBTS-1/NRBTS-1/NRDRB_MAC-5
    ...   NRBTS-1/NRDRB_5QI-4                                       nrDrbDN                         MRBTS-1/NRBTS-1/NRDRB-17
    ...   NRBTS-1/NRDRB_5QI-5                                       nrDrbDN                         MRBTS-1/NRBTS-1/NRDRB-17
    ...   NRBTS-1/NRPMRNL-1                                         miNrRelReportCu                 5min
    ...   NRBTS-1/NRPMRNL-1                                         miNrNGCC                        5min
    ...   NRBTS-1/NRPMRNL-1                                         miNrNRPFW                       5min
    ...   NRBTS-1/NRPMRNL-1                                         miNrMobilityReportCu            5min
    ...   NRBTS-1/NRPMRNL-1                                         miNrSlicingCuCp                 5min
    ...   NRBTS-1/NRPMRNL-1                                         miNrNgInterfaceNrpmqap          5min
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

    IF   'SBTS24R3' != '${sw_branch}'
    ...    Set Element               dist_name=MRBTS-1/NRBTS-1     p_name=act3gppBL23R1         value=true

    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1             p_name=timerXnDataFwdGuard
    IF    not ${element_exist}
    ...    scf.add_element_to_scf    dist_name=NRBTS-1             p_name=timerXnDataFwdGuard   value=250
    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1/NRCELL-1    p_name=measGapSelectionSA
    IF    not ${element_exist}
    ...    scf.add_element_to_scf    dist_name=NRBTS-1/NRCELL-1    p_name=measGapSelectionSA    value=favourUeThroughput
    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1/NRCELL-1    p_name=mgta
    IF    not ${element_exist}
    ...    scf.add_element_to_scf    dist_name=NRBTS-1/NRCELL-1    p_name=mgta                  value=ms0dot5
    ${element_exist}=         scf.is_element_in_object  dist_name=NRBTS-1             p_name=suppCnPartialAdNgHo
    IF    not ${element_exist}
    ...    scf.add_element_to_scf    dist_name=NRBTS-1             p_name=suppCnPartialAdNgHo   value=false

    # B61 specific
    scf.modify_scf_element    dist_name=NRBTS-1    p_name=actAmfPlannedRemoval   value=true
    scf.add_element_to_scf    dist_name=NRBTS-1    p_name=amfPlannedRemovalTimer   value=80
    Add SERVEDAMF2 to SCF   # ip 10.0.1.10
    scf.modify_scf_element    dist_name=NRBTS-1/NRPMRNL-1    p_name=miNrNgcFlexInterface    value=5min

    ${ts_conf_dir}=          Get Test Suite Config Directory
    scf.save_scf             ${ts_conf_dir}/${CB008806-A_SCF}
    Execute full commissioning    gnb_id=0    scf_path=${ts_conf_dir}/${CB008806-A_SCF}


Get Val from SCF
    ${nrarfcn}=  IF           '${cellTechnology}' == 'TDD'
    ...                     scf.get_value_from_scf         dist_name=NRBTS-1/NRCELL-1                p_name=nrarfcn
    ...          ELSE
    ...                     scf.get_value_from_scf         dist_name=NRBTS-1/NRCELL-1/NRCELL_FDD-1   p_name=nrarfcnDl
    Set Suite Variable       ${nrarfcn}
    ${freqBandIndicatorNR}=  scf.get_value_from_scf        dist_name=NRBTS-1/NRCELL-1                p_name=freqBandIndicatorNR
    Set Suite Variable       ${freqBandIndicatorNR}

Add Emergency in Nrcell
    [Arguments]    ${cell_id}=1
    FOR   ${dist_name}                                              ${p_name}                       ${value}      IN
    ...   NRBTS-1/NRCELL-${cell_id}                                 actEmergencyCall                true
    ...   NRBTS-1/NRCELL-${cell_id}                                 emergencyCallLimServ            true
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    ${list_exist}=             scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-${cell_id}     list_name=emergencyCallRestrictions
    IF            ${list_exist}==True
    ...                       scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=emergencyCallRestrictions
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-${cell_id}    list_name=emergencyCallRestrictions
    ${ec_restriction}=        Create dictionary         emergencyCallMrListIgnore           true
    ...                                                 emergencyCallPlmnHoAllowed          true
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=emergencyCallRestrictions   elements=${ec_restriction}


Update Parameter in NRCELL
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    not ${mo_exist}     RETURN

    scf.modify_scf_element    dist_name=${dist_name}    p_name=filterCoeffSsbRsrp     value=fc4
    ${element_exist}=         scf.is_element_in_object  dist_name=${dist_name}        p_name=sMeasConfigSsbRsrp
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf        dist_name=${dist_name}    p_name=sMeasConfigSsbRsrp              value=0
    ${element_exist}=         scf.is_element_in_object  dist_name=${dist_name}        p_name=absThreshSsbRsrpConsolidation
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf        dist_name=${dist_name}    p_name=absThreshSsbRsrpConsolidation   value=0

    Add A3Measurement to Nrcell        ${cell_id}
    Add A5Measurement to Nrcell        ${cell_id}

Add A1Measurement to Nrcell
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}
    scf.modify_scf_element    dist_name=${dist_name}    p_name=a1MeashoEnabledSA     value=rsrp
    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-${cell_id}     list_name=a1MeashoSsbRsrpSA
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a1MeashoSsbRsrpSA
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-${cell_id}    list_name=a1MeashoSsbRsrpSA
    ${a1Meas_rsrp}=           Create dictionary         a1HysteresishoSsbRsrpSA       20
    ...                                                 a1ThresholdhoSsbRsrpSA        80
    ...                                                 a1TimeToTriggerhoSsbRsrpSA    ms480
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a1MeashoSsbRsrpSA   elements=${a1Meas_rsrp}


Add A2Measurement to Nrcell
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}
    scf.modify_scf_element    dist_name=${dist_name}    p_name=a2MeashoEnabledSA     value=rsrp
    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-${cell_id}     list_name=a2MeashoSsbRsrpSA
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a2MeashoSsbRsrpSA
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-${cell_id}    list_name=a2MeashoSsbRsrpSA
    ${a2Meas_rsrp}=           Create dictionary         a2HysteresishoSsbRsrpSA           26
    ...                                                 a2ThresholdhoSsbRsrpSA            80
    ...                                                 a2TimeToTriggerhoSsbRsrpSA        ms40
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a2MeashoSsbRsrpSA   elements=${a2Meas_rsrp}

Add A3Measurement to Nrcell
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}
    scf.modify_scf_element    dist_name=${dist_name}    p_name=a3MeasEnabled     value=rsrp
    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-${cell_id}     list_name=a3MeasSsbRsrp
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a3MeasSsbRsrp
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-${cell_id}    list_name=a3MeasSsbRsrp
    ${a3Meas_rsrp}=           Create dictionary         a3HysteresisSsbRsrp           0
    ...                                                 a3OffsetSsbRsrp               3
    ...                                                 a3TimeToTriggerSsbRsrp        ms64
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a3MeasSsbRsrp   elements=${a3Meas_rsrp}

Add A5Measurement to Nrcell
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}
    scf.modify_scf_element    dist_name=${dist_name}    p_name=a5MeasEnabled     value=rsrp
    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-${cell_id}     list_name=a5MeasSsbRsrp
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a5MeasSsbRsrp
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-${cell_id}    list_name=a5MeasSsbRsrp
    ${a5Meas_rsrp}=           Create dictionary         a5HysteresisSsbRsrp           10
    ...                                                 a5Threshold1SsbRsrp           70
    ...                                                 a5Threshold2SsbRsrp           40
    ...                                                 a5TimeToTriggerSsbRsrp        ms5120
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a5MeasSsbRsrp   elements=${a5Meas_rsrp}


Add NRADJNRCELL1 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRADJNRCELL-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRADJNRCELL    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   cellDepType                       SA
    ...   fiveGsTac                         200
    ...   freqBandIndicatorNR               78
    ...   gNbId                             3
    ...   gNbIdLength                       22
    ...   lcrId                             1
    ...   nrarfcn                           636666
    ...   physCellId                        48
    ...   ssbFrequency                      636576
    ...   cellReservedForOperatorUse        notReserved
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn         elements=${plmn}


Add NRADJNRCELL2 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRADJNRCELL-2
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRADJNRCELL    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   cellDepType                       SA
    ...   fiveGsTac                         200
    ...   freqBandIndicatorNR               ${freqBandIndicatorNR}
    ...   gNbId                             3
    ...   gNbIdLength                       22
    ...   lcrId                             2
    ...   nrarfcn                           633372
    ...   physCellId                        49
    ...   ssbFrequency                      633408
    ...   cellReservedForOperatorUse        notReserved
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn         elements=${plmn}


Add NRHOIF to SCF
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}/NRHOIF-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRHOIF    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   a1BasedPCellSwitchEnabled         false
    ...   a2BasedPCellSwitchEnabled         false
    ...   a3MeasEnabled                     rsrp
    ...   a4MeasEnDcSteeringEnabled         none
    ...   a4MeasHigherPrioFreqEnabled       none
    ...   a5MeasEnabled                     rsrp
    ...   cellDepType                       SA
    ...   freqBandIndicatorNR               ${freqBandIndicatorNR}
    ...   ifhoSsbScs                        30 KHz
    ...   ifhoSsbSmtcDuration               sf3
    ...   ifhoSsbSmtcPeriodicity            sf10
    ...   numberOfTransmittedSsBlocks       1 beam
    ...   scs                               30 KHz
    ...   ssBurstSetPeriod                  20
    ...   ssbFrequency                      633408
    ...   a4MeasNrDcEnabled                 none
    ...   a4MeasSCellAddEnabled             none
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-${cell_id}/NRHOIF-1    list_name=a3MeasSsbRsrp
    ${a3Meas_rsrp}=           Create dictionary         a3HysteresisSsbRsrp           0
    ...                                                 a3OffsetSsbRsrp               3
    ...                                                 a3TimeToTriggerSsbRsrp        ms64
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-${cell_id}/NRHOIF-1   list_name=a3MeasSsbRsrp   elements=${a3Meas_rsrp}
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-${cell_id}/NRHOIF-1    list_name=a5MeasSsbRsrp
    ${a5Meas_rsrp}=           Create dictionary         a5HysteresisSsbRsrp           10
    ...                                                 a5Threshold1SsbRsrp           70
    ...                                                 a5Threshold2SsbRsrp           40
    ...                                                 a5TimeToTriggerSsbRsrp        ms5120
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-${cell_id}/NRHOIF-1   list_name=a5MeasSsbRsrp   elements=${a5Meas_rsrp}

Add NRREL1 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-1/NRREL-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRREL          dist_name=${dist_name}                version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   cellIndividualSsbRsrpOffset       0dB
    ...   cellIndividualSsbRsrqOffset       0dB
    ...   gNbId                             3
    ...   gNbIdLength                       22
    ...   handoverAllowedSA                 XnHoNotAllowed
    ...   lcrId                             1
    ...   removeNotAllowed                  false
    ...   nrDcAllowed                       false
    ...   handoverAllowedSARedCap           forbidden
    ...   isRplCellForPSCell                false
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn                     elements=${plmn}

Add NRREL2 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-1/NRREL-2
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRREL          dist_name=${dist_name}                version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   cellIndividualSsbRsrpOffset       0dB
    ...   cellIndividualSsbRsrqOffset       0dB
    ...   gNbId                             3
    ...   gNbIdLength                       22
    ...   handoverAllowedSA                 XnHoNotAllowed
    ...   lcrId                             2
    ...   removeNotAllowed                  false
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn                     elements=${plmn}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=nrDcAllowed                    value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=handoverAllowedSARedCap        value=forbidden
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=isRplCellForPSCell             value=false

Add NRPMQAP to SCF
    ${dist_name}=    Set Variable           NRBTS-1/NRPMRNL-1/NRPMQAP-1
    Set Object       class_name=NRPMQAP     dist_name=${dist_name}

    FOR   ${p_name}                         ${value}      IN
    ...   cfg5qiRange                       1-7
    ...   cfgArpRange                       1-15
    ...   cfgProfType                       SA
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

    scf.add_list_to_scf       dist_name=${dist_name}   list_name=cfgPlmnId
    scf.add_item_to_list      dist_name=${dist_name}   list_name=cfgPlmnId       elements=${plmn}
    scf.add_list_to_scf       dist_name=${dist_name}   list_name=cfgSliceId
    ${cfgSliceId}=            Create dictionary        sd           13714341
    ...                                                sst          1
    scf.add_item_to_list      dist_name=${dist_name}   list_name=cfgSliceId      elements=${cfgSliceId}

    IF   'SBTS24R3' != '${sw_branch}'
        Set Element    dist_name=${dist_name}   p_name=actCplaneCounters          value=true
        Set Element    dist_name=${dist_name}   p_name=actUPlaneGroup1Counters    value=false
        Set Element    dist_name=${dist_name}   p_name=actUPlaneGroup2Counters    value=false
        Set Element    dist_name=${dist_name}   p_name=cfgUECategoryFR1           value=All UEs
        Set Element    dist_name=${dist_name}   p_name=cfgUECategoryFR2           value=All UEs
    END

Add NRDRB16 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB-16
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}
    scf.add_object_to_scf    class_name=NRDRB    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                               ${value}                   IN
    ...   discardTimer                            1500ms
    ...   actDddsReduction                        false
    ...   dlFlowControlAlgo                       3gppFlowControl
    ...   dscp                                    0
    ...   maxDddsPeriodCpuOvld                    40
    ...   nrDrbMacDN                              MRBTS-1/NRBTS-1/NRDRB_MAC-4
    ...   nrDrbPdcpDN                             MRBTS-1/NRBTS-1/NRDRB_PDCP-3
    ...   nrDrbRlcUmDN                            MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...   numSduDiscard                           1
    ...   queuingDelayDiscardStart                5
    ...   queuingDelayDiscarding                  Disabled
    ...   queuingDelaySduDiscardThreshold         750
    ...   resType                                 GBR
    ...   maxDataRateGbrDl                        1000
    ...   maxDataRateGbrUl                        1000
    ...   l2OHFactorDl                            16
    ...   l2OHFactorUl                            35
    ...   rlcMode                                 RLC_UM
    ...   schedulWeight                           1
    ...   sduDiscardIntervalTmr                   500
    ...   actLostPduFastRetx                      false
    ...   maxRlcQueueingDelayGbr                  20
    ...   maxTransferDelayGbr                     20
    ...   endMarkerTimer                          2000
    ...   actDlTxResumeOnPdcpStatRep              false
    ...   durationThresDiscardDl                  40
    ...   durationThresDiscardUl                  20
    ...   volThresDiscardDl                       8000
    ...   volThresDiscardUl                       800
    ...   caPduReSendingDelayMargin               2
    ...   rlcPduDelayThCa                         30
    ...   durationThresDiscardDlMacSdu            40
    ...   durationThresDiscardDlPdcpPdu5GLeg      40
    ...   durationThresDiscardDlPdcpPduLteLeg     40
    ...   volThresDiscardDlMacSdu                 8000
    ...   volThresDiscardDlPdcpPdu5GLeg           8000
    ...   volThresDiscardDlPdcpPduLteLeg          8000
    ...   dlAllowMinDelayLinkXxCalib              false
    ...   actOptDataFlowRateEst                   false
    ...   nrDrxDN                                 MRBTS-1/NRBTS-1/NRDRX-4
        Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=cellAggrLevel
    ${param_list}=            create list               Not FR1 CA eligible
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=cellAggrLevel  elements=${param_list}

    IF    'SBTS24R3' != '${sw_branch}'
        sqd65_commissioning.Set Element    dist_name=${dist_name}   p_name=allowedPdcchPowerBoostALDueCce    value=none
        sqd65_commissioning.Set Element    dist_name=${dist_name}   p_name=allowedPdcchPowerBoostALDueCfg    value=None
    END
    IF    'SBTS25R2' == '${sw_branch}'
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=maxForwardTimeLimitX2    value=50
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=minForwardTputX2         value=100
    ELSE IF    '${sw_branch}' in ['SBTS00', 'SBTS25R3', 'SBTS26R1']
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=maxForwardTimeLimitXx    value=50
    END

Add NRDRB17 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB-17
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}
    scf.add_object_to_scf    class_name=NRDRB    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                               ${value}                   IN
    ...   discardTimer                            infinity
    ...   actDddsReduction                        false
    ...   dlFlowControlAlgo                       3gppFlowControl
    ...   dscp                                    0
    ...   maxDddsPeriodCpuOvld                    40
    ...   nrDrbMacDN                              MRBTS-1/NRBTS-1/NRDRB_MAC-2
    ...   nrDrbPdcpDN                             MRBTS-1/NRBTS-1/NRDRB_PDCP-3
    ...   nrDrbRlcAmDN                            MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
    ...   nrDrbRlcUmDN                            MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...   l2OHFactorDl                            16
    ...   l2OHFactorUl                            35
    ...   numSduDiscard                           1
    ...   queuingDelayDiscardStart                5
    ...   queuingDelayDiscarding                  Disabled
    ...   queuingDelaySduDiscardThreshold         750
    ...   resType                                 nonGBR
    ...   rlcMode                                 RLC_UM
    ...   schedulWeight                           1
    ...   sduDiscardIntervalTmr                   500
    ...   actLostPduFastRetx                      false
    ...   maxRlcQueueingDelayGbr                  20
    ...   maxTransferDelayGbr                     20
    ...   endMarkerTimer                          2000
    ...   actDlTxResumeOnPdcpStatRep              false
    ...   durationThresDiscardDl                  40
    ...   durationThresDiscardUl                  20
    ...   volThresDiscardDl                       8000
    ...   volThresDiscardUl                       800
    ...   caPduReSendingDelayMargin               2
    ...   rlcPduDelayThCa                         30
    ...   durationThresDiscardDlMacSdu            40
    ...   durationThresDiscardDlPdcpPdu5GLeg      40
    ...   durationThresDiscardDlPdcpPduLteLeg     40
    ...   volThresDiscardDlMacSdu                 8000
    ...   volThresDiscardDlPdcpPdu5GLeg           8000
    ...   volThresDiscardDlPdcpPduLteLeg          8000
    ...   dlAllowMinDelayLinkXxCalib              false
    ...   actOptDataFlowRateEst                   false
    ...   nrDrxDN                                 MRBTS-1/NRBTS-1/NRDRX-4
        Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=cellAggrLevel
    ${param_list}=            create list               Not FR1 CA eligible
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=cellAggrLevel  elements=${param_list}
    IF    'SBTS24R3' != '${sw_branch}'
        sqd65_commissioning.Set Element    dist_name=${dist_name}   p_name=allowedPdcchPowerBoostALDueCce    value=none
        sqd65_commissioning.Set Element    dist_name=${dist_name}   p_name=allowedPdcchPowerBoostALDueCfg    value=None
    END
    IF    'SBTS25R2' == '${sw_branch}'
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=maxForwardTimeLimitX2    value=50
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=minForwardTputX2         value=100
    ELSE IF    '${sw_branch}' in ['SBTS00', 'SBTS25R3', 'SBTS26R1']
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=maxForwardTimeLimitXx    value=50
    END

Add NRDRB5QI7 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_5QI-7
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}
    scf.add_object_to_scf    class_name=NRDRB_5QI    dist_name=${dist_name}    version=${NIDD_VERSION}
    ${param_list}=    Create List  2
    scf.add_list_to_scf    dist_name=${dist_name}    list_name=fiveqiValueList
    scf.add_elements_to_list  dist_name=${dist_name}  list_name=fiveqiValueList   elements=${param_list}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=nrDrbDN    value=MRBTS-1/NRBTS-1/NRDRB-16
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=dataForwarding    value=IRATDataFwd

Add NRDRBRMAC4 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_MAC-4
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}
    scf.add_object_to_scf    class_name=NRDRB_MAC    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                               ${value}                   IN
    ...   delayTarget                             50
    ...   lcgid                                   5
    ...   schedulPrio                             12
    ...   schedulBSD                              100ms
    ...   prioritisedBitRate                      16kBps
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Add NRDRBRMAC5 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_MAC-5
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}
    scf.add_object_to_scf    class_name=NRDRB_MAC    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                               ${value}                   IN
    ...   delayTarget                             50
    ...   lcgid                                   0
    ...   schedulPrio                             4
    ...   schedulBSD                              50ms
    ...   prioritisedBitRate                      16kBps
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Add NRDRBPDCP3 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_PDCP-3
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB_PDCP    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                               ${value}                   IN
    ...   cuFlowControlProfId                     1
    ...   maxCidAllowed                           4
    ...   pdcpBufDiscardEnabled                   false
    ...   pdcpBufDiscardThreshold                 20000
    ...   tReorderingDl                           ms300
    ...   tReorderingUl                           ms300
    ...   pdcpDelayThreshRetxMode                 disabled
    ...   x2FlowControlProfIdForCu                1
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Add NRDRBPDCP4 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_PDCP-4
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB_PDCP    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                               ${value}                   IN
    ...   cuFlowControlProfId                     1
    ...   maxCidAllowed                           4
    ...   pdcpBufDiscardEnabled                   false
    ...   pdcpBufDiscardThreshold                 20000
    ...   tReorderingDl                           ms300
    ...   tReorderingUl                           ms300
    ...   pdcpDelayThreshRetxMode                 disabled
    ...   x2FlowControlProfIdForCu                1
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Add NRDRBRLCUM1 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_RLC_UM-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB_RLC_UM    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                               ${value}                   IN
    ...   dlTReassemblyUm                         ms40
    ...   rlcUMDrbSNLength                        rlcUm12bitSN
    ...   ulTReassemblyUm                         ms40
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Add SERVEDAMF2 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/SERVEDAMF-2
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}
    scf.add_object_to_scf    class_name=SERVEDAMF    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                               ${value}                   IN
    ...   administrativeState                     Unlocked
    ...   amfIPAddress                            10.0.1.10
    ...   defaultAMF                              false
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    IF       'SBTS24R3' != '${sw_branch}'
    ...                  Set Element         dist_name=${dist_name}      p_name=amfIPAddressTTL    value=5

Delete NRREL1 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-1/NRREL-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}

Delete NRADJNRCELL1 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRADJNRCELL-1
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF   ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}

Apply SCF Configuration for EDA_04087344 Test Scenario
    [Arguments]
    ${log_dir}=               Get Testcase Log Directory
    ${scf_file}=              Load current SCF
    Add New Radio PLMN
    Add New Radio PLMN Set for Adjacent Neighboring SA NR Cell
    FOR   ${dist_name}                               ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                            actSliceAwareScheduler                  false
    ...   MRBTS-1/NRBTS-1                            actSliceAwareSchedulerUlAndEnh          false
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/SNSSAI-1
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-2
    scf.add_elements_to_list        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}
    FOR    ${id}    IN RANGE    1    5
        sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}    p_name=actEnhDtxOptimizedScheduler    value=false
        scf.add_elements_to_list     dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}/NRPLMNSET_SA-1    list_name=nrPlmnDNList    elements=${nrPlmnDNList_list}
    END
    scf.remove_element_from_scf    dist_name=${dist_name}       p_name=sd
    scf.save_scf                    ${log_dir}/scf_EDA_04087344.xml
    commissioning.Execute full commissioning      ${log_dir}/scf_EDA_04087344.xml

Add New Radio PLMN
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRPLMN-2
    Set Object    class_name=NRPLMN    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}             ${value}      IN
    ...   mcc                   311
    ...   mnc                   488
    ...   mncLength             3
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add New Radio PLMN Set for Adjacent Neighboring SA NR Cell
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1
    Set Object    class_name=ADJ_NRPLMNSET_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                      ${value}      IN
    ...   fiveGsTac                      200
    ...   cellReservedForOperatorUse     notReserved
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}      list_name=nrPlmnDNList
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-1
    scf.add_elements_to_list        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-2
    scf.add_elements_to_list        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}
    scf.remove_element_from_scf    dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-1       p_name=fiveGsTac
