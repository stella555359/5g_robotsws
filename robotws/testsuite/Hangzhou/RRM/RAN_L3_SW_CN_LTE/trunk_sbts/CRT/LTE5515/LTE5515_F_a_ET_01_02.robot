*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4P6
...               release-SBTS20A    owner-joy.dong    team-DEVHZ5_SG6
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE4549}
...    @{LTE5515}
...    @{PARAMS_FIX_RELATION_ERROR}

@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1:enableBwCombCheck=false
...    LNCEL-1/CAREL-1:lcrId=5
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=forbidden
...    LNCEL-1/CAREL-2:lcrId=8
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=forbidden
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=7
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=7
...    LNCEL:caPoolId=1
...    LNCEL:maxNumScells=3
...    LNBTS-1:actFlexScellSelect=true
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=300
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=18300
...    LNCEL-5/LNCEL_FDD-0:earfcnDL=3000
...    LNCEL-5/LNCEL_FDD-0:earfcnUL=21000
...    LNCEL-8/LNCEL_FDD-0:earfcnDL=9410
...    LNCEL-8/LNCEL_FDD-0:earfcnUL=27410
...    LNCEL:actFlowCtrlEnh=false
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    delete:LNBTS-1/LNADJ-255
...    LNCEL-1/CAREL-1:scellPrio=1
...    LNCEL-1/CAREL-2:scellPrio=2
...    delete:LNCEL-1/CAREL-1:beamformingInScellAllowed
...    delete:LNCEL-1/CAREL-2:beamformingInScellAllowed
...    LNBTS-1:actFlexCaMgmt=true
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=20
...    LNCEL-1/LNCEL_FDD-0:dlChBw=15 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=15 MHz
...    LNCEL-5/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL-5/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL-8/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-8/LNCEL_FDD-0:ulChBw=10 MHz
...    delete:LNCEL:t301Guard
...    delete:LNCEL-1/CAPR-2
...    delete:LNCEL-1/CAPR-3
...    delete:LNCEL-1/CAPR-4
...    delete:LNCEL-1/CAPR-6
...    delete:LNCEL-1/CAPR-7
...    delete:LNCEL-1/CAPR-9
...    LNCEL-1/CAPR-5:earfcnDL=3000
...    LNCEL-1/CAPR-5:sFreqPrio=1
...    LNCEL-1/CAPR-8:earfcnDL=9410
...    LNCEL-1/CAPR-8:sFreqPrio=2

@{x2link}
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-3/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-4/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-4/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-4/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-4/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-4/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-4/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

@{LTE4088}
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:tLteNrDualConnectPrep=8000
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNCEL-3:defaultLnRelGnbCellId=1
...    LNCEL-2:defaultLnRelGnbCellId=1
...    LNCEL-4:defaultLnRelGnbCellId=1

@{LTE4193}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNBTS-1/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS-1/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS-1/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS-1/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS-1/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=0sf
...    LNCEL-4/LNCEL_FDD-0:actAutoPucchAlloc=true


@{PARAMS_FIX_RELATION_ERROR}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:enableNonCompBcsChkEnDc=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:tS1eRABModInd=2000
...    LNCEL:eTputFilterConfig=51
...    LNCEL:eTputInitMcs=20
...    delete:LNCEL/MBSFNCEL-.*

${ue_eutra_capabilities}
...  SEPARATOR=
...  DD9800408300086C204F84F84F84F84FBF06EC4D00141BB8CBF06EC4D2F0C808BDF837626AD9400C208428210C1082080304218018018200C1
...  00608430030022104008400821040042004108000C1082084104018210410820803042082104108208030420821041006084104208200C1082
...  084104018210410060841040182104108208030030025A7D546140E0E00401016C2005801004046080B61002C00802021040460800E0040101
...  18200580100408608218200600209B0801C2080206D8401001C2080206D840101902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E
...  0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC5000019B29F827E09F827E09F827E09F
...  8027E09F809F827E09F827E09F827E09F827E09F827E09F804FC13F04FC13F0000027E0E0C00002040411019A000F9C7800081018203038589
...  8D8E0EA0FDFF12D6980642FF37A80018036C9000020000104B8E03000010080309826850F00DFF000003A00000061000

${ue_nr_capabilities}    CE00000001C8F5C0302800001939980000CC00100002600001349880000018060010000001

${ue_eutra_nr_capabilities}
...  SEPARATOR=
...  C10060B71B02004040C180389A0000000FD00000000081B8981002060E2680000103F400000000206E360000C18018D8071340000101FC0000
...  000010371302004081C4D00000607E80000000040DC4C080103070080000201FA0000000010201401006009013600101B01060001008000402
...  000100808010022000080400020101002004600010080004020001008080100220000804000201010020044000100800040202004008

@{pcellswap}
...    LNBTS-1:actPcellSwap=true
...    LNBTS-1:actIfHo=enabled
...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=5|puschLoadIndexThr=0.01
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL:loadSettings:targetLoadGbrDl=50
...    LNCEL:loadSettings:targetLoadNonGbrDl=75
...    LNCEL:loadSettings:targetLoadPdcch=90
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulStaticCac=100
...    LNCEL-2:pcellSwapConfig:numCaUeThreshold=10|puschLoadIndexThr=10
...    LNCEL-3:pcellSwapConfig:numCaUeThreshold=10|puschLoadIndexThr=10
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-1:scellPrio=3
...    LNCEL-3/CAREL-2:lcrId=2
...    LNCEL-3/CAREL-2:lnBtsId=1
...    LNCEL-3/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-2:scellPrio=3
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL-3:dlCaMinPcellCqi=0
...    LNCEL-3:dlCaMinPcellCqiQci1=0
...    LNCEL-3:ulCaMinPcellSinr=0
...    LNCEL-3:ulCaMinPcellSinrQci1=0

@{MFBI}
...    LNBTS-1:actMFBI=true
...    LNBTS-1:caIntraCellHoMode=moreDLCACapacity
...    LNBTS-1/MFBIPR-0:addFreqBandInd=66
...    LNBTS-1/MFBIPR-0:addSpectrEmissReq=2
...    LNBTS-1/MFBIPR-0:eutraCarrierFreq=2000
...    LNBTS-1/MFBIPR-0:freqBandIndPrio=broadcasted

@{TMO}
...    LNBTS-1:tmpActFeat1=4

@{LTE4549}
...    LNBTS-1:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS-1:enableBwCombCheck=false
...    LNBTS-1/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS-1/NRDCDPR-0:allowedBcSelectMethod=no preference

@{LTE5515}
...    LNBTS-1:actEnhFlexCaWithEnDc=true
...    LNBTS-1:enableBwComSetChkEnDc=true

${addscell_1}
...    sCellToAddModList-r10 contains (
...      sCellIndex-r10 eq 1 and
...      cellIdentification-r10 contains (physCellId-r10 eq 8 and dl-CarrierFreq-r10 eq 9410)
...    )

${addscell_2}
...    sCellToAddModList-r10 contains (
...      sCellIndex-r10 eq 1,
...      sCellIndex-r10 eq 2 and cellIdentification-r10 contains (
...      physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 3000)
...    )

${SgNBAddition}
...    nonCriticalExtension contains (
...      sCellToReleaseList-r10 contains ( 2 ) and
...      sCellToAddModList-r10 contains (sCellIndex-r10 eq 1)
...    )

@{Scell_partial_C93_C94}
...    LNCEL-1/MCC-262/MNC-03:${CA_SCELL_DECONFIG_PR_ATT_SCG}=3
...    LNCEL-1/MCC-262/MNC-03:${CA_SCELL_DECONFIG_PR_SUCC_SCG}=3
...    LNCEL-1/MCC-262/MNC-03:${DL_CA_SCELL_DECONFIG_ATT}=3
...    LNCEL-1/MCC-262/MNC-03:${DL_CA_SCELL_DECONFIG_SUCC}=3
...    LNCEL-1/MCC-262/MNC-03:${DL_CA_SCELL_DECONFIG_ATT_SCG}=0
...    LNCEL-1/MCC-262/MNC-03:${DL_CA_SCELL_DECONFIG_SUCC_SCG}=0

${DL_CA_SCELL_DECONFIG_ATT}         M8011C213
${DL_CA_SCELL_DECONFIG_SUCC}        M8011C214
${DL_CA_SCELL_DECONFIG_ATT_SCG}     M8011C292
${DL_CA_SCELL_DECONFIG_SUCC_SCG}    M8011C293
${CA_SCELL_DECONFIG_PR_ATT_SCG}     M8080C93
${CA_SCELL_DECONFIG_PR_SUCC_SCG}    M8080C94

*** Test Cases ***
LTE5515-F-a_01-01 M8080C93 M8080C94 will update due to Scell partial release during SgNB addition procedure
    [Tags]
    Start Rtpm Counter
    UE attach to cell1    ue_number=4
    3UEs Start DL Data to trigger 3CC
    3UEs Trigger ENDC setup
    Check Rtpm Counters    ${Scell_partial_C93_C94}


*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=9CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Set Ue Parameters Before Attach

Set Ue Parameters Before Attach
    Execute Uex Command    ue_param id=1-3 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1-3 nr_supported_bands=78
    Execute Egate Command    trace_sim enb=7 protocol=x2,s1 on
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=3:1
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms
    Execute Egate Command    ue_enb_param id=1-3 ue_config_release_r9=rel15
    Execute Egate Command    enb_x2_link_up enb=7 target=1    X2 link with eNB-1 is activated already

Modify Yaml
    ${GNB7_CELL1}    catenate
    ...    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501',
    ...    nr_arfcn: '630000:630000', meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz15,
    ...    ssb_mtc_periodicity_and_offset: 'sf5:1', ssb_mtc_duration: 'sf1', tdd_cell: yes}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}

Perform Steps After Onair
    @{LNADJGNB7}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.11    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${LNADJGNB7}

UE attach to cell1
    [Arguments]    ${ue_number}=4
    FOR    ${UE_ID}    IN RANGE    1    ${ue_number}
        ${V_UE}    catenate
        ...    ue_attach id=${UE_ID} cell=1
        ...    ue_eutra_capabilities=${ue_eutra_capabilities}
        ...    ue_nr_capabilities=${ue_nr_capabilities}
        ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
        Execute Uex Command    ${V_UE}
    END

3UEs Start DL Data to trigger 3CC
    Start DL Data to trigger 3CC    UE_ID=1
    Start DL Data to trigger 3CC    UE_ID=2
    Start DL Data to trigger 3CC    UE_ID=3

Start DL Data to trigger 3CC
    [Arguments]    ${UE_ID}=1
    Expect Message Flow
    ...    UE_${UE_ID}:RRC_RRCConnectionReconfiguration (${addscell_1})
    ...    UE_${UE_ID}:RRC_RRCConnectionReconfiguration (${addscell_2})
    ...    alias=Scell_addition    overall_timeout=30
    Execute Uex Command    trf_data_start ue=${UE_ID} dir=dl Mbps=120 protocol=udp trf_id=1
    Flow Occurred As Expected    alias=Scell_addition

3UEs Trigger ENDC setup
    Trigger ENDC setup    UE_ID=1
    Trigger ENDC setup    UE_ID=2
    Trigger ENDC setup    UE_ID=3

Trigger ENDC setup
    [Arguments]    ${UE_ID}=1
    Expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest (E-RABs-ToBeAdded-SgNBAddReqList contains (qCI eq 8))
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_${UE_ID}:RRC_RRCConnectionReconfiguration (${SgNBAddition})
    ...    alias=ENDC_setup    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${UE_ID} event=B1_NR phycell_id=1 nrsrp=58
    Flow Occurred As Expected    alias=ENDC_setup



