*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for 5GC000707 commissioning


*** Variables ***

${SCF}                           scfc.xml
${DELTA_SCF}                     delta_scfc.json
${NIDD_VERSION}                  NRBTSCL5G21B_2104_100
${CELL_TECHNOLOGY}               TDD
${ENB_ID}                        18
${EPS_TAC}                       222
${LTE_PCI_1}                     11
${LTE_LCI_1}                     1
${LTE_PCI_2}                     22
${LTE_LCI_2}                     2
${EARFCN}                        1
${IRAT_DATA_FWD_METHOD}          indirectDataFwd

@{nrhoirDNList}=                 MRBTS-1/NRBTS-1/NRHOIR-1
@{raTypeList}=                   nr  eutra
@{reportList}=                   miNrRRCC  miNrNGCC  miNrNREMO
...                              miNrNAECL  miNrNgUReport  miNrMacSduReport
...                              miNrPDCP1Report  miNrPDCP2Report  miNrHighRlcReport
...                              miNrLowRlcReport  miNrF1CC  miNrSlicingCuCp


&{actInterRatHoSA}=              dist_name=NRBTS-1           p_name=actInterRatHoSA    value=true
&{a1MeashoEnabledSA}=            dist_name=NRBTS-1/NRCELL-1  p_name=a1MeashoEnabledSA  value=rsrp
&{a2MeashoEnabledSA}=            dist_name=NRBTS-1/NRCELL-1  p_name=a2MeashoEnabledSA  value=rsrp
&{b2MeashoEnabled}=              dist_name=NRBTS-1/NRHOIR-1  p_name=b2MeashoEnabled    value=rsrq


&{sa_plmn}=                      mcc=311  mnc=489  mncLength=3
&{equiv_plmn}=                   mcc=250  mnc=255  mncLength=3

&{eutraB2MeashoRsrp}=
...                              b2HysteresishoRsrp=5
...                              b2Threshold2hoRsrp=18
...                              b2TimeToTriggerhoRsrp=ms480
...                              b2HysteresishoRsrpVoNr=0
...                              b2Threshold2hoRsrpVoNr=18
...                              b2TimeToTriggerhoRsrpVoNr=ms480

&{eutraB2MeashoRsrq}=
...                              b2HysteresishoRsrq=0
...                              b2Threshold2hoRsrq=18
...                              b2TimeToTriggerhoRsrq=ms480
...                              b2HysteresishoRsrqVoNr=0
...                              b2Threshold2hoRsrqVoNr=2
...                              b2TimeToTriggerhoRsrqVoNr=ms480

&{a1MeashoSsbRsrpSA}=
...                              a1HysteresishoSsbRsrpSA=0
...                              a1ThresholdhoSsbRsrpSA=38
...                              a1TimeToTriggerhoSsbRsrpSA=ms480

&{a2MeashoSsbRsrpSA}=
...                              a2HysteresishoSsbRsrpSA=0
...                              a2ThresholdhoSsbRsrpSA=36
...                              a2TimeToTriggerhoSsbRsrpSA=ms480

&{a3MeasSsbRsrp}=
...                              a3HysteresisSsbRsrp=0
...                              a3OffsetSsbRsrp=30
...                              a3TimeToTriggerSsbRsrp=ms480

&{nrDrx}=
...                              drxOnDurationTimer=10ms
...                              drxInactivityTimer=40ms
...                              drxRetransTimerDl=16slot
...                              drxRetransTimerUl=16slot
...                              drxLongCycle=40ms
...                              drxHarqRttTimerDl=0symbols
...                              drxHarqRttTimerUl=0symbols

&{nrhoir1}=
...                              allowedMeasBandwidth=mbw50
...                              eutraFreqQOffsetRange=24
...                              widebandRsrqMeas=true


*** Keywords ***

Commissioning
    scf.load_scf                 ${P_ORIG_SCF}
    Add NRADJECELL-1 to NRBTS-1
    Add NRHOIR-1 to NRBTS-1
    Add NRRELE-1 to NRCELL       cell_id=1
    #Add NRRELE-1 to NRCELL       cell_id=3
    Update Params in NRCELL      cell_id=1
    #Update Params in NRCELL      cell_id=3
    Update Params in NRPMRNL-1
    Update Params in NRBTS-1

    # Feat: CB009109_UE_Power_Saving_-_Service_DRX
    # 5G_CP_ARC_ALG_13621  Determination of DRX profile for SA call nonGBR DRBs
    Update Params in NRDRX       cell_id=1

    IF  "${SUITE NAME}" == "5GC000707-D"
        Apply Config For 5GC000707-D
    ELSE IF   "${SUITE NAME}" == "5GC000707-A"
        Apply Config For Intra-frequency Intra-DU Intra-gNB Handover  cell_id=4
    END

    Set Element                  dist_name=MRBTS-1/MNL-1/AMGR-1/LUAC-1          p_name=webEMSessionLogoutTimer   value=7200
    Set Element                  dist_name=MRBTS-1/MNL-1/MNLENT-1/PMCADM-1      p_name=reportingIntervalPm       value=5min
    # disable CB008239 ANR for SA, due to ECs and consecHoFailThresEutra=3  :
    Set Element                  dist_name=MRBTS-1/NRBTS-1                      p_name=actSaUeBasedAnrEutra      value=false

    ${ts_conf_dir}=              Get Test Suite Config Directory
    scf.save_scf                 ${ts_conf_dir}/${SCF}
    Execute full commissioning   gnb_id=0    scf_path=${ts_conf_dir}/${SCF}


Apply Config for 5GC000707-D
    Add NRADJECELL-2 to NRBTS-1
    Add NRRELE-2 to NRCELL

Apply Config for Intra-frequency Intra-DU Intra-gNB Handover
    [Arguments]    ${cell_id}=2
    ${mo_exist}=              scf.is_object_in_scf      dist_name=NRBTS-1/NRCELL-${cell_id}
    IF   not ${mo_exist}
        Log  message=NO 2nd Cell !!!   level=WARN
        RETURN
    END
    Add NRREL-1 to NRCELL          cell_id=${cell_id}  lcrId=3
    Update 707-A Params in NRCELL  cell_id=${cell_id}
    Activate IntraFreqHO

Add NRADJECELL-1 to NRBTS-1
    ${dist_name}=             Set Variable              NRBTS-1/NRADJECELL-1
    Set Object                dist_name=${dist_name}    class_name=NRADJECELL

    scf.add_element_to_scf    dist_name=${dist_name}    p_name=eNodeBId                    value=${ENB_ID}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=ePSTrackingAreaCode         value=${EPS_TAC}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=earfcnValue                 value=${EARFCN}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=lcrId                       value=${LTE_LCI_1}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=physCellId                  value=${LTE_PCI_1}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=iRatDataForwardingMethod    value=${IRAT_DATA_FWD_METHOD}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=eUtraMultibandInfoList
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=eUtraMultibandInfoList   elements=1
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=ecgiPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=ecgiPlmn                 elements=${sa_plmn}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=enbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=enbPlmn                  elements=${sa_plmn}

Add NRADJECELL-2 to NRBTS-1
    ${dist_name}=             Set Variable              NRBTS-1/NRADJECELL-2
    Set Object                dist_name=${dist_name}    class_name=NRADJECELL

    scf.add_element_to_scf    dist_name=${dist_name}    p_name=eNodeBId                    value=${ENB_ID}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=ePSTrackingAreaCode         value=${EPS_TAC}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=earfcnValue                 value=${EARFCN}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=lcrId                       value=${LTE_LCI_2}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=physCellId                  value=${LTE_PCI_2}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=iRatDataForwardingMethod    value=${IRAT_DATA_FWD_METHOD}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=eUtraMultibandInfoList
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=eUtraMultibandInfoList   elements=1
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=ecgiPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=ecgiPlmn                 elements=${equiv_plmn}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=enbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=enbPlmn                  elements=${equiv_plmn}

Add NRHOIR-1 to NRBTS-1
    ${dist_name}=             Set Variable              NRBTS-1/NRHOIR-1
    Set Object                dist_name=${dist_name}    class_name=NRHOIR

    scf.add_element_to_scf    dist_name=${dist_name}    p_name=allowedMeasBandwidth        value=mbw50
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=b2MeashoEnabled             value=${b2MeashoEnabled['value']}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=b2Threshold1hoRsrp          value=35
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=b2Threshold1hoRsrq          value=50
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=b1MeasRedirectEnabled       value=none
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=earfcnValue                 value=1
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=eutraFreqQOffsetRange       value=0dB
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=presenceAntennaPort1        value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=reportAmount                value=r8
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=reportInterval              value=ms240
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=widebandRsrqMeas            value=true
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=eutraB2MeashoRsrp
    scf.add_item_to_list      dist_name=${dist_name}    list_name=eutraB2MeashoRsrp        elements=${eutraB2MeashoRsrp}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=eutraB2MeashoRsrq
    scf.add_item_to_list      dist_name=${dist_name}    list_name=eutraB2MeashoRsrq        elements=${eutraB2MeashoRsrq}


Add NRRELE-1 to NRCELL
    [Arguments]    ${cell_id}=1
    ${dist_name}=             Set Variable              NRBTS-1/NRCELL-${cell_id}/NRRELE-1
    Set Object                dist_name=${dist_name}    class_name=NRRELE

    scf.add_element_to_scf    dist_name=${dist_name}    p_name=cellIndividualOffset    value=0dB
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=eNodeBId                value=${ENB_ID}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=eutranCellExcluded      value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=removeNotAllowed        value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=lcrId                   value=1
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=ecgiPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=ecgiPlmn             elements=${sa_plmn}

Add NRRELE-2 to NRCELL
    [Arguments]    ${cell_id}=1
    ${dist_name}=             Set Variable              NRBTS-1/NRCELL-${cell_id}/NRRELE-2
    Set Object                dist_name=${dist_name}    class_name=NRRELE

    scf.add_element_to_scf    dist_name=${dist_name}    p_name=cellIndividualOffset    value=0dB
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=eNodeBId                value=${ENB_ID}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=eutranCellExcluded      value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=removeNotAllowed        value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=lcrId                   value=2
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=ecgiPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=ecgiPlmn             elements=${equiv_plmn}

Update Params in NRCELL
    [Arguments]    ${cell_id}=1
    ${dist_name}=             Set Variable              NRBTS-1/NRCELL-${cell_id}

    Set Element               dist_name=${dist_name}    p_name=measGapSelectionSA      value=favourUeThroughput

    Set Element               dist_name=${dist_name}    p_name=a1MeashoEnabledSA       value=${a1MeashoEnabledSA['value']}
    ${list_name}=             Set Variable              a1MeashoSsbRsrpSA
    Set List                  dist_name=${dist_name}    list_name=${list_name}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}         elements=${a1MeashoSsbRsrpSA}

    Set Element               dist_name=${dist_name}    p_name=a2MeashoEnabledSA       value=${a2MeashoEnabledSA['value']}
    ${list_name}=             Set Variable              a2MeashoSsbRsrpSA
    Set List                  dist_name=${dist_name}    list_name=${list_name}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}         elements=${a2MeashoSsbRsrpSA}

    # to be removed: CB009109
    ${list_name}=             Set Variable              drxProfile1
    Set List                  dist_name=${dist_name}    list_name=${list_name}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}         elements=${nrDrx}

    ${list_name}=             Set Variable              nrhoirDNList
    Set List                  dist_name=${dist_name}    list_name=${list_name}
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=${list_name}         elements=${nrhoirDNList}


Update Params in NRBTS-1
    ${dist_name}=             Set Variable              NRBTS-1
    Set Element               dist_name=${dist_name}    p_name=actInterRatHoSA                    value=${actInterRatHoSA['value']}
#    Set Element               dist_name=${dist_name}    p_name=earfcnValue                       value=0
    Set Element               dist_name=${dist_name}    p_name=actMFBIEutra                       value=true
    Set Element               dist_name=${dist_name}    p_name=excludedEutranCellPeriod           value=10
    Set Element               dist_name=${dist_name}    p_name=excludedEutranCellThreshold        value=5
    Set Element               dist_name=${dist_name}    p_name=excludedEutranCellTimeWindow       value=10
    Set Element               dist_name=${dist_name}    p_name=drbInactivityTimerSA               value=600
    Set Element               dist_name=${dist_name}    p_name=srbInactivityTimerSA               value=600

Modifiy raTypeList
    [Arguments]               ${dist_name}
    ${list_name}=             Set Variable              raTypeList
    Set List                  dist_name=${dist_name}    list_name=${list_name}
    scf.add_elements_to_list  dist_name=${dist_name}    list_name=${list_name}           elements=${raTypeList}


Update Params in NRPMRNL-1
    ${dist_name}=             Set Variable              NRBTS-1/NRPMRNL-1
    FOR   ${report}  IN  @{reportList}
        Set Element           dist_name=${dist_name}    p_name=${report}               value=5min
    END

Add NRREL-1 to NRCELL
    [Documentation]   with 4 Cells Configuration, FDD with cell_id=4 lcrId=3
    ...    TDD with cell_id=2 lcrID=1
    [Arguments]    ${cell_id}=2    ${lcrId}=1
    ${dist_name}=             Set Variable              NRBTS-1/NRCELL-${cell_id}/NRREL-1
    Set Object                dist_name=${dist_name}    class_name=NRREL

    scf.add_element_to_scf    dist_name=${dist_name}    p_name=cellIndividualSsbRsrpOffset    value=0dB
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=cellIndividualSsbRsrqOffset    value=0dB
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=gNbId                          value=1
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=gNbIdLength                    value=22
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=lcrId                          value=${lcrId}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=removeNotAllowed               value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=handoverAllowedSA              value=allowed
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn                     elements=${sa_plmn}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=nrDcAllowed                    value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=handoverAllowedSARedCap  value=forbidden
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=isRplCellForPSCell            value=false

Update 707-A Params in NRCELL
    [Arguments]    ${cell_id}=2
    ${dist_name}=             Set Variable              NRBTS-1/NRCELL-${cell_id}

    Set Element               dist_name=${dist_name}    p_name=a3MeasEnabled           value=rsrp
    ${list_name}=             Set Variable              a3MeasSsbRsrp
    Set List                  dist_name=${dist_name}    list_name=${list_name}
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}         elements=${a3MeasSsbRsrp}

#    Set Element               dist_name=${dist_name}    p_name=a5MeasEnabled                      value=none
    Set Element               dist_name=${dist_name}    p_name=absThreshSsbRsrpConsolidation      value=0
    Set Element               dist_name=${dist_name}    p_name=sMeasConfigSsbRsrp                 value=0

Activate IntraFreqHO
    Set Element               dist_name=NRBTS-1            p_name=actIntraFreqHoSA                value=true
    Set Element               dist_name=NRBTS-1            p_name=timerXnDataFwdGuard             value=250
    Set Element               dist_name=NRBTS-1/NRPMRNL-1  p_name=miNrRelReportCu                 value=5min

Set List
    [Arguments]      ${dist_name}   ${list_name}
    ${list_exist}=            scf.is_list_in_object    dist_name=${dist_name}   list_name=${list_name}
    IF   ${list_exist}   scf.Remove List From SCF      dist_name=${dist_name}   list_name=${list_name}
    scf.add_list_to_scf       dist_name=${dist_name}   list_name=${list_name}

Update Params in NRDRX
    [Arguments]    ${cell_id}=1
    ${nonGbrNrDrxDN}=         scf.get_value_from_scf       dist_name=NRBTS-1/NRCELL-${cell_id}    p_name=nonGbrNrDrxDN
    FOR   ${p_name}               ${value}      IN
    ...   drxOnDurationTimer      ${nrDrx['drxOnDurationTimer']}
    ...   drxInactivityTimer      ${nrDrx['drxInactivityTimer']}
    ...   drxLongCycle            ${nrDrx['drxLongCycle']}
    ...   drxRetransTimerDl       ${nrDrx['drxRetransTimerDl']}
    ...   drxRetransTimerUl       ${nrDrx['drxRetransTimerUl']}
    ...   drxHarqRttTimerDl       ${nrDrx['drxHarqRttTimerDl']}
    ...   drxHarqRttTimerUl       ${nrDrx['drxHarqRttTimerUl']}
    Set Element               dist_name=${nonGbrNrDrxDN}   p_name=${p_name}   value=${value}
    END
