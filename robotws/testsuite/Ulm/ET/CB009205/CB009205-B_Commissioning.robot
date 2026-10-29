*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description:

Resource          ../resources/SQD65/sqd65_commissioning.robot

*** Variables ***

${SCF}                           scfc_${FEATURE}.xml
${NIDD_VERSION}                  NRBTSCL22R4_2210_100
${cellTechnology}                TDD
${NRCELL-1.nrarfcn_gscn}         636576   # gscn: 7880
${NRCELL-2.gscn}                 7995
${NRCELL-2.nrarfcn}              647666

${ssbFrequency_nrhoif-1}         633408
${prio_ssbFreq_nrhoif-1}         1
${ssbFrequency_nrhoif-2}         643296
${prio_ssbFreq_nrhoif-2}         10

@{CASupportList}=                ca_Fr1Tdd_Sa
@{allowUnsuppBcOrBcsList}        accept unknown BCSs

&{a4MeasSsbRsrp}=                a4HysteresisSsbRsrp=0
...                              a4ThresholdSsbRsrp=34
...                              a4TimeToTriggerSsbRsrp=ms40

&{a4PeriodicMeasControlSA}       a4Fr1SupervisionTimer=4000
...                              a4Fr2SupervisionTimer=6000
...                              a4MeasMaxNumber=5
...                              a4RetryTimer=10
...                              a4MeasActBlockTimer=60

&{a1MeashoPrefNRLayerSsbRsrpSA}  a1HysteresisSsbRsrp=0
...                              a1ThresholdhoSsbRsrp=60
...                              a1TimeToTriggerhoSsbRsrp=ms40

&{a1MeashoPrefNRLayerSsbRsrqSA}  a1HysteresisSsbRsrq=0
...                              a1ThresholdhoSsbRsrq=63
...                              a1TimeToTriggerhoSsbRsrq=ms40

&{a4PeriodicMeasControlSA_B5}    a4Fr1SupervisionTimer=5000
...                              a4Fr2SupervisionTimer=5000
...                              a4MeasMaxNumber=5
...                              a4RetryTimer=5
...                              a4MeasActBlockTimer=60
${a4MeasHigherPrioFreqMaxReactSA_B5}  1

*** Keywords ***

Commissioning
    scf.load_scf              ${P_ORIG_SCF}
    Get Value from SCF

    ${sw_branch}=    testline.Get gNB SW Branch
    IF    '${sw_branch}' in ['SBTS00', 'SBTS25R2']
        Set To Dictionary    ${a4PeriodicMeasControlSA}   a4RetryTimerMultCa=5
        Set To Dictionary    ${a4PeriodicMeasControlSA_B5}   a4RetryTimerMultCa=5
    END

    FOR          ${dist_name}             ${p_name}                          ${value}      IN
    ...          MNL-1/AMGR-1/LUAC-1      webEMSessionLogoutTimer            7200
    ...          MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm                5min
    ...          NRBTS-1/NRPMRNL-1        miNrRelReportCu                    5min
    ...          NRBTS-1/NRCELL-1         measGapSelectionSA                 favourUeThroughput
    ...          NRBTS-1                  actInterFreqHoSA                   true
    ...          NRBTS-1                  timerXnDataFwdGuard                250
    ...          NRBTS-1                  actHigherPrioFreqHo                SA
    ...          NRBTS-1                  actA1HoPrefNRLayer                 SA
    ...          NRBTS-1                  actCarrierAggregation              true
    ...          NRBTS-1                  caConfigurationSupport             2CCDL_2CCUL
    ...          NRBTS-1                  actUeCapaEnquiryHoCa               false
    ...          NRBTS-1                  actIntraNrNgHo                     sourceAndTarget
    ...          NRBTS-1                  suppCnPartialAdNgHo                false
    ...          NRBTS-1                  tNgRelocExecDeltN                  3000
    ...          NRBTS-1                  tNgRelocCancelN                    2000
    ...          NRBTS-1                  tNgRelocOverallN                   2000
    ...          NRBTS-1                  tNgRelocPrepN                      2000
    ...          NRBTS-1                  actIntraFreqHoSA                   true
    ...          NRBTS-1                  rrcReestabTypeSA                   sameGNB
    ...          NRBTS-1                  tWaitingRlRecover                  4000ms
    ...          NRBTS-1                  tWaitingRlRecoverSA                4000ms
    ...          NRBTS-1                  actOverheatingAssistance           false
    Set Element  dist_name=${dist_name}   p_name=${p_name}   value=${value}
    END

    ${list_elements}=            Create dictionary                             a1HysteresisSsbRsrq=0
    ...                                                                        a1ThresholdhoSsbRsrq=63
    ...                                                                        a1TimeToTriggerhoSsbRsrq=ms40
    Set New List                 dist_name=MRBTS-1/NRBTS-1/NRCELL-1            list_name=a1MeashoPrefNRLayerSsbRsrqSA
    scf.add_item_to_list         dist_name=MRBTS-1/NRBTS-1/NRCELL-1            list_name=a1MeashoPrefNRLayerSsbRsrqSA
    ...                                                                        elements=${list_elements}

    FOR    ${cell_id}    IN RANGE    1    5
        Set New List          dist_name=NRBTS-1/NRCELL-${cell_id}  list_name=a4PeriodicMeasControlSA
        scf.add_item_to_list  dist_name=NRBTS-1/NRCELL-${cell_id}  list_name=a4PeriodicMeasControlSA  elements=${a4PeriodicMeasControlSA}
    END


    Add a1MeashoPrefNRLayerEnabledSA to Cell                  dist_name=NRBTS-1/NRCELL-1
    Add a1MeashoPrefNRLayerEnabledSA to Cell                  dist_name=NRBTS-1/NRCELL-2

    Prepare CA
    Add NRHOIF    id=1
    Update NRHOIF-1
    Add Trace Control Entity
    Add Radio CU Trace Session
    Enable PCDM and Cell Trace
    Prepare Mobility Profile

    ${ts_conf_dir}=               Get Test Suite Config Directory
    Set Suite Variable            ${SCF}     ${ts_conf_dir}/${SCF}
    scf.save_scf                  ${SCF}
    Execute full commissioning    gnb_id=0    scf_path=${SCF}

Get Value from SCF
    ${nrarfcn}=  IF           '${cellTechnology}' == 'TDD'
    ...                      scf.get_value_from_scf        dist_name=NRBTS-1/NRCELL-1                p_name=nrarfcn
    ...          ELSE
    ...                      scf.get_value_from_scf        dist_name=NRBTS-1/NRCELL-1/NRCELL_FDD-1   p_name=nrarfcnDl
    Set Suite Variable       ${nrarfcn}
    ${freqBandIndicatorNR}=  scf.get_value_from_scf        dist_name=NRBTS-1/NRCELL-1                p_name=freqBandIndicatorNR
    Set Suite Variable       ${freqBandIndicatorNR}
    ${physCellId1}=          scf.get_value_from_scf        dist_name=NRBTS-1/NRCELL-1                p_name=physCellId
    Set Suite Variable       ${physCellId1}
    ${trackingAreaList}=     scf.get_all_values_from_scf_by_pattern  dist_name=NRBTS-1/TRACKINGAREA-*      p_name=fiveGsTac
    ${trackingArea}=         Get From List   ${trackingAreaList}  0
    Set Suite Variable       ${trackingArea}

Prepare CA
    Set Element   dist_name=NRBTS-1/NRCELL-2     p_name=nrarfcn                     value=${NRCELL-2.nrarfcn}
    Set Element   dist_name=NRBTS-1/NRCELL-2     p_name=gscnOrSsPbchArfcn           value=${NRCELL-2.gscn}

    Set Element   dist_name=NRBTS-1              p_name=maxNumScellsDl              value=1
    Set Element   dist_name=NRBTS-1              p_name=maxNumScellsUl              value=1
    Set Element   dist_name=NRBTS-1              p_name=sCellActivationMethod       value=blind

    ${list_name}=             Set Variable              carrierAggregationSupportList
    ${dist_name}=             Set Variable              NRBTS-1/NRDU-1
    Set New List              dist_name=${dist_name}    list_name=${list_name}
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=${list_name}       elements=${CASupportList}

    FOR  ${id}  IN RANGE  1  5
        ${dist_name}=             Set Variable               NRBTS-1/NRCELL-${id}
        Set Element               dist_name=${dist_name}     p_name=sCellDeactivationTimerGNB   value=infinity
        Set Element               dist_name=${dist_name}     p_name=actK1Opt                    value=intra-gNB
        Set New List              dist_name=${dist_name}     list_name=allowUnsuppBcOrBcs
        scf.add_elements_to_list  dist_name=${dist_name}     list_name=allowUnsuppBcOrBcs       elements=${allowUnsuppBcOrBcsList}
    END
    Add NRREL-1 to NRCELL-1

Add NRREL-1 to NRCELL-1
    ${dist_name}=             Set Variable              NRBTS-1/NRCELL-1/NRREL-1
    Set Object                dist_name=${dist_name}    class_name=NRREL

    Set Element               dist_name=${dist_name}    p_name=cellIndividualSsbRsrpOffset    value=0dB
    Set Element               dist_name=${dist_name}    p_name=cellIndividualSsbRsrqOffset    value=0dB
    Set Element               dist_name=${dist_name}    p_name=gNbId                          value=1
    Set Element               dist_name=${dist_name}    p_name=gNbIdLength                    value=22
    Set Element               dist_name=${dist_name}    p_name=lcrId                          value=2
    Set New List              dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn                     elements=${PLMN}
    Set Element               dist_name=${dist_name}    p_name=handoverAllowedSA              value=allowed
    Set Element               dist_name=${dist_name}    p_name=nrDcAllowed                    value=false
    Set Element               dist_name=${dist_name}    p_name=removeNotAllowed               value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=handoverAllowedSARedCap        value=forbidden
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=isRplCellForPSCell             value=false

Update NRHOIF-1
    ${dist_name}=             Set Variable              NRBTS-1/NRCELL-1/NRHOIF-1

    Set Element               dist_name=${dist_name}    p_name=ssbFrequency                   value=${ssbFrequency_nrhoif-1}
    Set Element               dist_name=${dist_name}    p_name=a4PriorityForHigherPrioFreqHo  value=${prio_ssbFreq_nrhoif-1}
    Set Element               dist_name=${dist_name}    p_name=a4MeasHigherPrioFreqEnabled    value=rsrp
    Set New List              dist_name=${dist_name}    list_name=a4MeasSsbRsrp
    scf.add_item_to_list      dist_name=${dist_name}    list_name=a4MeasSsbRsrp               elements=${a4MeasSsbRsrp}

Add a1MeashoPrefNRLayerEnabledSA to Cell
    [Arguments]           ${dist_name}=NRBTS-1/NRCELL-1
    Set Element           dist_name=${dist_name}          p_name=a1MeashoPrefNRLayerEnabledSA       value=rsrp
    Set Element           dist_name=${dist_name}          p_name=a4MeasHigherPrioFreqMaxReactSA     value=0

    Set New List          dist_name=${dist_name}          list_name=a1MeashoPrefNRLayerSsbRsrpSA
    scf.add_item_to_list  dist_name=${dist_name}          list_name=a1MeashoPrefNRLayerSsbRsrpSA    elements=${a1MeashoPrefNRLayerSsbRsrpSA}

    Set New List          dist_name=${dist_name}          list_name=a1MeashoPrefNRLayerSsbRsrqSA
    scf.add_item_to_list  dist_name=${dist_name}          list_name=a1MeashoPrefNRLayerSsbRsrqSA    elements=${a1MeashoPrefNRLayerSsbRsrqSA}

Prepare Mobility Profile
    Set Element               dist_name=MRBTS-1/NRBTS-1                  p_name=actMobilityProfile               value=false
    Set Element               dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-1      p_name=a1MeashoPrefNRLayerEnabledSA     value=rsrp

    FOR  ${id}  IN RANGE  1  5
       Set Element            dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}     p_name=cellDepType                      value=SA
       Set Element            dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}     p_name=nrDefMoPrSaDN
       ...                                                               value=MRBTS-1/NRBTS-1/NRMOPR_SA-1
       Set Element            dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}     p_name=actDynUlDataSplitMode            value=false
       Set Element            dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}     p_name=actSib1ForNsaCell                value=false

       Remove Object          NRBTS-1/NRCELL-${id}/NRPLMNSET_NSA-1
    END
    Set Element               dist_name=MNL-1/MNLENT-1/FEATCADM-1        p_name=actNrAutDegAdmCtrlSlCellDetRec   value=false
    Set Element               dist_name=MNL-1/MNLENT-1/FEATCADM-1        p_name=actNrAutSgnbAddCplSlCellDetRec   value=false
    Set Element               dist_name=MNL-1/MNLENT-1/FEATCADM-1        p_name=actNrAutUeCtxStpRtSlCellDetRec   value=false

Enable PCDM and Cell Trace
    Set Element              dist_name=NRBTS-1                            p_name=actPCMDReport         value=true
    Set Element              dist_name=NRBTS-1                            p_name=actCellTraceReport    value=true

    @{tracePCMDSetting}       Create List                                  all
    Set New List              dist_name=NRBTS-1/NRCTRLTS-1/NRMTRACECU-1    list_name=tracePCMDSetting
    scf.add_elements_to_list  dist_name=NRBTS-1/NRCTRLTS-1/NRMTRACECU-1    list_name=tracePCMDSetting   elements=${tracePCMDSetting}

Enable Additional Configuration for CNI_88822_PR669502
    # Performing delta commissioning for CNI88822 as per test procedure in Quality Centre
    ${scf_file}=              Load current SCF
    Update Params in NRCELL-1 and NRCELL-2
    Add NRADJNRCELL-1 and NRADJNRCELL-2 in NRCELL-1
    Update Params of NRREL-1 in NRCELL-1 and Add NRREL-1 to NRCELL-2
    Add and Modify NRHOIF-2 in NRCELL-1
    Apply Delta SCF          ${scf_file}  scf_CNI_88822_PR669502

Update Params in NRCELL-1 and NRCELL-2
    # Modify a4PeriodicMeasControlSA params in NRCELL-1 and NRCELL-2 as per the test procedure in Quality Centre for CNI88822
    FOR    ${index}    IN RANGE    1    3
        scf.modify_scf_element    dist_name=MRBTS-1/NRBTS-1/NRCELL-${index}    p_name=a4MeasHigherPrioFreqMaxReactSA    value=1
        scf.modify_scf_element    dist_name=MRBTS-1/NRBTS-1/NRCELL-${index}    p_name=a4Fr1SupervisionTimer             value=5000
        scf.modify_scf_element    dist_name=MRBTS-1/NRBTS-1/NRCELL-${index}    p_name=a4Fr2SupervisionTimer             value=5000
        scf.modify_scf_element    dist_name=MRBTS-1/NRBTS-1/NRCELL-${index}    p_name=a4MeasMaxNumber                   value=5
        scf.modify_scf_element    dist_name=MRBTS-1/NRBTS-1/NRCELL-${index}    p_name=a4RetryTimer                      value=5
    END

Add NRADJNRCELL-1 and NRADJNRCELL-2 in NRCELL-1
    [Arguments]
    # Add NRADJNRCELL-1 and NRADJNRCELL-2 in NRCELL-1 as per the test procedure in Quality Centre for CNI88822
    ${ssb_freq}=    Create List    633372   643332
    FOR    ${index}    IN RANGE    1    3
        ${dist_name}=    Set Variable    NRBTS-1/NRADJNRCELL-${index}
        ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
        IF    ${mo_exist}   RETURN
        scf.add_object_to_scf     class_name=com.nokia.srbts.nrbts:NRADJNRCELL    dist_name=${dist_name}    version=${NIDD_VERSION}
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=cellReservedForOperatorUse         value=notReserved
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=cellDepType        value=SA
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=gNbId              value=3
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=gNbIdLength        value=22
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=lcrId              value=${index}
        IF  ${index} == 1
        ...            scf.add_element_to_scf    dist_name=${dist_name}    p_name=nrarfcn            value=633372
        ...    ELSE
        ...            scf.add_element_to_scf    dist_name=${dist_name}    p_name=nrarfcn            value=643332
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=physCellId         value=48
        scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
        scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn         elements=${plmn}
        scf.add_element_to_scf    dist_name=${dist_name}    p_name=ssbFrequency    value=${ssb_freq[${${index}-1}]}
    END

Update Params of NRREL-1 in NRCELL-1 and Add NRREL-1 to NRCELL-2
    # Modifying the params of NRREL-1 in NRCELL-1 as per test procedure in Quality Centre for CNI88822
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1/NRREL-1    p_name=gNbId              value=3
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1/NRREL-1    p_name=lcrId              value=1

    # Add NRREL-1 to NRCELL-2 as per test procedure in Quality Centre for CNI88822
    ${dist_name}=             Set Variable              NRBTS-1/NRCELL-2/NRREL-1
    Set Object                class_name=com.nokia.srbts.nrbts:NRREL    dist_name=${dist_name}
    FOR    ${p_name}                      ${value}    IN
    ...    cellIndividualSsbRsrpOffset    0dB
    ...    cellIndividualSsbRsrqOffset    0dB
    ...    gNbId                          3
    ...    gNbIdLength                    22
    ...    lcrId                          2
    ...    handoverAllowedSA              allowed
    ...    nrDcAllowed                    false
    ...    removeNotAllowed               false
    ...    handoverAllowedSARedCap        forbidden
    ...    isRplCellForPSCell             false
        Set Element           dist_name=${dist_name}    p_name=${p_name}                      value=${value}
    END
    Set New List              dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn                     elements=${plmn}

Add and Modify NRHOIF-2 in NRCELL-1
    # Add NRHOIF-2 in NRCELL-1 as per the test procedure in Quality Centre for CNI88822
    Add NRHOIF                cell_id=1      id=2
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1/NRHOIF-2    p_name=a4MeasHigherPrioFreqEnabled      value=rsrp
    scf.add_element_to_scf    dist_name=NRBTS-1/NRCELL-1/NRHOIF-2    p_name=a4PriorityForHigherPrioFreqHo    value=10
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1/NRHOIF-2    p_name=ssbFrequency                     value=643296
    ${list_elements}=        Create dictionary          a4HysteresisSsbRsrp             0
    ...                                                 a4ThresholdSsbRsrp              49
    ...                                                 a4TimeToTriggerSsbRsrp          ms40
    Set New List             dist_name=NRBTS-1/NRCELL-1/NRHOIF-2    list_name=a4MeasSsbRsrp
    scf.add_item_to_list     dist_name=NRBTS-1/NRCELL-1/NRHOIF-2    list_name=a4MeasSsbRsrp               elements=${list_elements}
