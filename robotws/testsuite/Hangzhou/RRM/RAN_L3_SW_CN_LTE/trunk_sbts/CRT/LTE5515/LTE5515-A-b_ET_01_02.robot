*** Settings ***
Suite Setup    Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...    owner-jun.3.ye    owner-yin.zhang    release-SBTS20A    team-DEVHZ5_SG6
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE4549}
...    @{LTE5515}
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=7
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=7
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=3870
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=4070
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=21870
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=22070
...    LNCEL-2/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=10 MHz
...    @{PARAMS_FIX_RELATION_ERROR}
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=1
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL-1:maxNumScells=2
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=10
...    LNCEL:caPoolId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNBTS:sCellDeactivationTimereNB=rf128
...    LNBTS-1:actAdvStepwiseScellAdd=buffer-based
@{x2link}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference

${ue_nr_capabilities}    C000613613060000020E6268000003F40035555535555500
${ue_eutra_nr_capabilities}
...    SEPARATOR=
...    C10060F61302004101C4D00000007F00000000040D82C080389A0000040FE00000000081B05840071340000101FC0000000010361302204101
...    C4D00000607E40000000040D84C080104134D0000807E40000000040D86C08010102080E2680000503F8000000002040360400820104071340
...    000300400402202680000803080002010000804040080108000402020040084000201010020044000100800040202004008800020100008040
...    40080100300402008040100C0080118000402000100800040202004008
${ue_eutra_capabilities}
...    SEPARATOR=
...    DD980010840205C1705DF837626800A0DDC25F83762697864045EFC1BB1356CA0060050420821041006084300300304018200C108600600442
...    080108010420800840082100018210410820803042082104100608410420821041006084104208200C10820841040182104108208030420820
...    0C108208030420821041006006004B43EAA30A06070820080901001C2080242404007080010320001202C20004042080901002C20004048080
...    901000C200040032000101902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B8
...    2E0B82E0B82E0B82E0B82E0B82E0B82E0B82EFC5000019B2FD00000003F40000000FD000000021E1E1E2E11FC5C87878787878787878787871
...    0F0F0F0E00008BF62000008808200202080000028080A0202000000A0280860018004004004004004004002008020080200802008020080200
...    80200802008020080200802008020080200800004D020000F9E78000810182030385898D8E0EA0FDFF1280200003E80000000015A60190BFCD
...    EA10060C0801000003E800000000001B6481001000058000000005010001802C0412E380E000040200C2609A14010F00DFF000003A00000061
...    0000
@{LTE5515}
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:enableBwComSetChkEnDc=true

@{PARAMS_FIX_RELATION_ERROR}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:actFlexCaMgmt=false
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:enableNonCompBcsChkEnDc=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:tS1eRABModInd=2000
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:eTputFilterConfig=51
...    LNCEL:eTputInitMcs=20
...    delete:LNCEL/MBSFNCEL-.*

*** Test Cases ***
LTE5515-A-b_01_02_Bandwidth combination set checking with LTE part is not defined during inter-band EN-DC setup
    [Documentation]    cell1 band3, cell2+cell3 band 9, enb not support band3+band9 ca
    [Tags]
    UE Attach With 3A_9A capability
    Start traffic And No CA configured
    UE Trigger Dynamic ENDC And Failed
    Check Current Throughput    ue_id=1    target=11.5

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=4    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Set ue parameters before attach

Perform Steps After Onair
    @{lnadjgnb7}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.11    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${lnadjgnb7}

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '630000:630000',
    ...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz15,
    ...    ssb_mtc_periodicity_and_offset: 'sf5:1', ssb_mtc_duration: 'sf1'}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2u: 10.0.1.12
    ...    x2_peers: none
    ...    cells:
    ...       ${GNB7_CELL1}

Set ue parameters before attach
    Execute Uex Command    ue_param id=1-4 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=78
    Execute Uex Command    ue_cqi_param id=1-4 scell=0-3 rank=4 ri_i1=18
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms T_DC_Overall=5000ms

UE Attach With 3A_9A capability
    [Arguments]    ${ue}=1
    ${attach_cmd}    catenate
    ...    ue_attach id=${ue} cell=1 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ${attach_cmd}

Start traffic And No CA configured
    [Arguments]    ${ue}=1
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (sCellIndex-r10 is present)
    ...    alias=ca_flow    overall_timeout=20
    Execute Uex Command    trf_data_start ue=${ue} Mbps=150 dir=dl protocol=udp
    Flow Not Occurred For Message    alias=ca_flow

UE Trigger Dynamic ENDC And Failed
    [Arguments]    ${ue}=1
    ${DC_3A_N78_BCS0}    Catenate    allowedBC-ListMRDC contains (bandCombinationIndex eq 2) and length(allowedBC-ListMRDC) eq 1
    ${DC_3A_9A_N78A}    Catenate    1:1
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${DC_3A_9A_N78A}
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest (${DC_3A_N78_BCS0})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReleaseRequest (Cause contains (radioNetwork eq "value-out-of-allowed-range"))
    ...    ENB_1:X2AP_UEContextRelease
    ...    alias=b1_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue} event=B1_NR phycell_id=1 nrsrp=62
    Flow Occurred As Expected    alias=b1_flow

