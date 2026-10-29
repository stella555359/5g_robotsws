*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-CN3ET    release-SBTS20A    owner-zhijian.tong
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${SIM_GNB7_CELL_1_NRARFCN_531000}    531040    #531008
${SIM_GNB8_CELL_1_NRARFCN_188500}    188512    #188480

@{PARAMS_IN_SCF}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=10 MHz
...    @{LTE4088}
...    @{LTE4193}
...    @{CA}
...    @{LTE4549}
...    @{NRDCDPR}
...    @{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1:actFlowCtrlEnh=true
...    LNCEL-2:actFlowCtrlEnh=true
...    LNCEL-3:actFlowCtrlEnh=true
...    LNBTS:actMultBearers=true
...    LNCEL-1:tac=33
...    LNCEL-2:tac=33
...    LNCEL-3:tac=33
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
...    LNBTS:actRedirect=disabled
...    LNBTS:actCsfbPsHoToUtra=false
...    LNBTS:act1xCsfb=false
...    LNBTS:actDualRx1xCsfb=false
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=132354
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-1/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-3:nrCellId=132355
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2
...    LNCEL-1:actModulationSchemeDl=64QAM
...    LNCEL-2:actModulationSchemeDl=64QAM
...    LNCEL-3:actModulationSchemeDl=64QAM
...    LNBTS/LNBTS_FDD-0:numTxWithHighNonGbr=200
...    LNBTS:actAdvStepwiseScellAdd=off

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz

@{NRDCDPR}
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${SIM_GNB7_CELL_1_NRARFCN_531000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${SIM_GNB8_CELL_1_NRARFCN_188500}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=8
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNBTS:qciTab6:nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS:pdcpProf1001:pdcpProfileId=1001
...    LNBTS:pdcpProf1001:snSizeDl=18bit
...    LNBTS:pdcpProf1001:snSizeUl=18bit
...    LNBTS:pdcpProf1001:statusRepReq=0
...    LNBTS:pdcpProf1001:tDiscard=300ms

@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1:defaultLnRelGnbCellId=1

@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference

${ue_eutra_capabilities}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400003840000210002C20000108008400010C0002200004500008C00011C0002400004
...    900009400012C0002600004D0000A0000144000290000530000A80001540002B0000570000B00001640002D00005B0000BA000178000368000
...    7F001D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000740000
...    0003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000740000000
...    3A00000001D00000000E800000007400000003A00000001D00000000A080000079D00000000000000000000000000000000000000000000000
...    0000000000001011C421298061CFFFFFFFFFFFFFFFA15000300452E000040000209614010180778000003000000100

${ue_nr_capabilities}    00000000010100200000600000380802C080380C000000
${ue_eutra_nr_capabilities}    01080803604008081010701800000006C08010102020E038000000006000100800040200010080801002

@{CA}
...    LNBTS:actDLCAggr=true
...    LNBTS:actAdvScellMeas=true
...    LNBTS:enableBwCombCheck=true
...    LNBTS:actFlexScellSelect=true
...    LNCEL-1:actScellConfigForHiDemand=true
...    LNCEL-2:actScellConfigForHiDemand=true
...    LNBTS/LNBTS_FDD-0:numTxWithHighNonGbr=10
...    LNBTS:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL-1:maxNumScells=3
...    LNCEL-2:maxNumScells=3
...    LNCEL-3:maxNumScells=3
...    LNCEL-1:actCaArchEnhImp=off
...    LNCEL-2:actCaArchEnhImp=off
...    LNCEL-3:actCaArchEnhImp=off
...    LNCEL:caPoolId=1
...    LNCEL-1:dlScellConfigLevel=20
...    LNCEL-1/CAPR-1:earfcnDL=1500
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNBTS/CADPR-0:maxNumMimoLayerFdd=16
...    LNBTS:actFlexCaMgmt=true
...    LNCEL-2:dlScellConfigLevel=20
...    LNCEL-2/CAPR-1:earfcnDL=1500
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:lcrId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1:scellFastSchedulingSelect=normal
...    LNCEL-2:scellFastSchedulingSelect=normal
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL-1:dlCaMinPcellCqi=0
...    LNCEL-2:dlCaMinPcellCqiQci1=0
...    LNCEL-2:ulCaMinPcellSinrQci1=0
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-2:ulCaMinPcellSinr=0
...    LNCEL-3:dlCaMinPcellCqiQci1=0
...    LNCEL-3:dlCaMinPcellCqi=0

@{Delete_QCI6_Support_ENDC_And_QCI5_support_ENDC}
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled
...    LNBTS:qciTab5:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab5:nrPdcpProfIdx=1001

@{Delete_QCI5_Support_ENDC_And_QCI6_support_ENDC}
...    LNBTS:qciTab5:lteNrDualConnectSupport=disabled
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab6:nrPdcpProfIdx=1001

${B1NRActivation}
...    measObjectToAddModList contains (carrierFreq-r15 eq 531040, carrierFreq-r15 eq 188512) and
...    b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 90) and
...    reportOnLeave-r15 eq 'TRUE'

${B1NRActivation_1}
...    measObjectToAddModList contains (carrierFreq-r15 eq 531040) and
...    b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 90) and
...    reportOnLeave-r15 eq 'TRUE'

${scell_addition_physCellId_2}
...    sCellIndex-r10 eq 1 and
...    physCellId-r10 eq 2 and
...    dl-CarrierFreq-r10 eq 1500

${bear_setup_S1}    SEPARATOR=
    ...    E-RABToBeSetupItemCtxtSUReq contains ((
    ...    e-RAB-ID eq 5) 
    ...    and e-RABlevelQoSParameters contains (
    ...    qCI eq 6))

@{Online commision for A-d-1-1}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased

@{Online commision for A-d-1-3}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased

*** Test Cases ***
LTE5003-A-d_01_03_Reconfiguration from coverageBased to coverageAndBufferBased after B1-NR reported
    [Documentation]    this case verifies that Reconfiguration of the EN-DC setup mode from coverageBased to coverageAndBufferBased after B1-NR 
    ...    reported with CA
    ...    postcoditions:
    ...    activate B1-NR with reportonleave=false
    ...    Ue1 establish ENDC between ENB1 Cell1 and GNB1 CellC after received B1-NR and data buffer overflow indication
    [Tags]
    Precondition for case A-d-1-3
    UE Attach with EN-DC eligiable bearer to eNB1 Cell1    ue_id=1
    UE report B1-NR to ENB1 Cell1 and ENDC setup    ue_id=1    phycell_id=2
    Online change EN-DC setup method from coverageBased to coverageAndBufferBased
    EN-DC is released due to timer expired for UE    ue_id=1
    UE report B1-NR to ENB1 Cell1 again    ue_id=1    phycell_id=2
    Start data traffic for NR PDCP bearer till Data buffer overflow and trigger UE ENDC establish    ue_id=1
    Start data traffic for NR PDCP bearer till Data buffer overflow and trigger CA establish for UE    ue_id=1

LTE5003-A-e_01_07_B1-NR activated with HRL before B1-MR reported in ICS-ENDC setup not triggered
    [Documentation]    This case verifies that B1-NR measurement still activated with Handover Restriction List handling before B1 MR reported in ICS
    ...    ,and ENDC setup not triggered
    [Tags]
    Change Qci5 As NR-PDCP bearer
    Preset Restrict_nr_access Off Of Handover Restriction List handling On CUS Egate Side
    UE Attach to eNB1 Cell1 with LTE-PDCP    ue_id=2
    Setup Erab With NR-PDCP And B1 is activated in the UE    ue_id=2
    Preset Restrict_nr_access On Of Handover Restriction List handling On CUS Egate Side    ue_id=2
    UE report B1-NR to ENB1 Cell1    ue_id=2    blacklist_measureid=18    phycell_id=1
    Set UE Tau COMBINED_TA_LA_UPDATING And Trigger NRrestriction is updated for UE via S1AP_DownlinkNASTransport message    ue_id=2
    Start data traffic for NR PDCP bearer till Data buffer overflow and No ENDC establish but trigger CA establish    ue_id=2    qci_id=5

LTE5003-A-e_01_09_B1-NR measurement still activated with Handover Restriction List handling after B1 MR reported in ICS-ENDC setup not triggered
    [Documentation]    This case verifies that B1-NR measurement still activated with Handover Restriction List handling after B1 MR reported in ICS
    ...    ,and ENDC setup not triggered
    [Tags]
    Change Qci6 As NR-PDCP bearer
    Preset Restrict_nr_access Off Of Handover Restriction List handling On CUS Egate Side
    UE Attach to eNB1 Cell1 with NR-PDCP    ue_id=3
    UE report B1-NR to ENB1 Cell1    ue_id=3    blacklist_measureid=18    phycell_id=1
    Preset Restrict_nr_access On Of Handover Restriction List handling On CUS Egate Side    ue_id=3
    Set UE Tau COMBINED_TA_LA_UPDATING And Trigger NRrestriction is updated for UE via S1AP_DownlinkNASTransport message    ue_id=3
    Start data traffic for NR PDCP bearer till Data buffer overflow and No ENDC establish but trigger CA establish    ue_id=3    qci_id=6

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_ABIO
    Set UE parameters for ENDC capability
    Create Alias

Set UE parameters for ENDC capability
    Execute UEx Command    ue_param id=1-2 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute UEx Command    ue_param id=1-2 nr_supported_bands=7
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms
    Set GNB parameters for ENDC setup

Set GNB parameters for ENDC setup
    execute egate command    gnb_endc_param id=7 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true
    execute egate command    gnb_endc_param id=8 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true
    execute egate command    gnb_endc_param id=7 scg_dl_dist_percent=0
    execute egate command    gnb_endc_param id=8 scg_dl_dist_percent=0

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create Enb Alias    GNB_8    enb_id=8    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '507000:531000'}    #531040
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr, tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '179500:188500'}    #188512
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...      gnb_id: '0x00008'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.12
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB8_CELL1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    Update Yaml    UEs/UE_sets/1     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3     bearer: bearer_set_2

UE Attach with EN-DC eligiable bearer to eNB1 Cell1
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${B1NRActivation})
    ...    MME_1:S1AP_InitialContextSetupRequest(${bear_setup_S1})
    ...    alias=UE_${ue_id}_attach    overall_timeout=30
    Execute UEx Command    ue_param id=${ue_id} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    ${V_2}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute UEx Command    ${V_2}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach

UE Attach to eNB1 Cell1 with LTE-PDCP
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (reportConfigToAddModList contains (eventB1-NR-r15 is present))
    ...    alias=UE_${ue_id}_attach_with_LTE-PDCP    overall_timeout=30
    Execute UEx Command    ue_param id=${ue_id} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    ${V_3}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute UEx Command    ${V_3}
    Flow Not Occurred For Message    alias=UE_${ue_id}_attach_with_LTE-PDCP

UE Attach to eNB1 Cell1 with NR-PDCP
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${B1NRActivation_1})
    ...    MME_1:S1AP_InitialContextSetupRequest(${bear_setup_S1})
    ...    alias=UE_${ue_id}_attach_with_NR-PDCP    overall_timeout=30
    Execute UEx Command    ue_param id=${ue_id} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    ${V_4}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=${cell_id}
    Execute UEx Command    ${V_4}
    Flow Occurred As Expected    alias=UE_${ue_id}_attach_with_NR-PDCP

Precondition for case A-d-1-3
    Delta Commission Parameters    ${Online commision for A-d-1-1}
    Cells Should Be OnAir

UE report B1-NR to ENB1 Cell1
    [Arguments]    ${ue_id}=1    ${blacklist_measureid}=18    ${phycell_id}=1
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    alias=noendcsetup    overall_timeout=30
    Execute UEx Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${phycell_id} nrsrp=100 meas_id_blacklist=${blacklist_measureid}
    Flow Not Occurred For Message    alias=noendcsetup

UE report B1-NR to ENB1 Cell1 again
    [Arguments]    ${ue_id}=1    ${phycell_id}=2    ${blacklist_measureid}=17
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    alias=UE_${ue_id}_no_endc_setup    overall_timeout=30
    Execute UEx Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${phycell_id} nrsrp=100 meas_id_blacklist=${blacklist_measureid}
    Flow Not Occurred For Message    alias=UE_${ue_id}_no_endc_setup

UE report B1-NR to ENB1 Cell1 and ENDC setup
    [Arguments]    ${ue_id}=1    ${phycell_id}=2    ${blacklist_measureid}=17
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    GNB_8:X2AP_SgNBAdditionRequestAcknowledge
    ...    alias=ENDC_for_UE_${ue_id}    overall_timeout=30
    ${endc_messsage}    catenate
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17))
    Execute UEx Command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${phycell_id} nrsrp=100 meas_id_blacklist=${blacklist_measureid}
    Flow Occurred As Expected    alias=ENDC_for_UE_${ue_id}

Online change EN-DC setup method from coverageBased to coverageAndBufferBased
    Delta Commission Parameters    ${Online commision for A-d-1-3}
    Cells Should Be OnAir

EN-DC is released due to timer expired for UE
    [Arguments]    ${ue_id}=1
    ${SNSstatus_1}    catenate
    ...    E-RABs-SubjectToStatusTransfer-Item contains (
    ...    iE-Extensions contains (
    ...    ((id eq 151) and
    ...    (COUNTvaluePDCP-SNlength18 contains (pDCP-SNlength18 eq 0))),
    ...    ((id eq 152) and
    ...    (COUNTvaluePDCP-SNlength18 contains (pDCP-SNlength18 eq 0))))
    ...    )
    Expect Message Flow
    ...    GNB_8:X2AP_SgNBReleaseRequired
    ...    ENB_1:X2AP_SgNBReleaseConfirm
    ...    GNB_8:X2AP_SNStatusTransfer (${SNSstatus_1})
    ...    ENB_1:X2AP_UEContextRelease
    ...    MME_1:S1AP_E-RABModificationIndication (E-RABToBeModifiedListBearerModInd contains (e-RAB-ID eq 5))
    ...    MME_1:S1AP_E-RABModificationConfirm (E-RABModifyListBearerModConf contains (e-RAB-ID eq 5))
    ...    alias=UE_${ue_id}_ENDC_released    overall_timeout=30
    execute egate command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}    pass_regexp=UEContextRelease
    Flow Occurred As Expected    alias=UE_${ue_id}_ENDC_released

Start data traffic for NR PDCP bearer till Data buffer overflow and trigger UE ENDC establish
    [Arguments]    ${ue_id}=1
    ${SNSstatus_2}    catenate
    ...    E-RABs-SubjectToStatusTransfer-Item contains (
    ...    iE-Extensions contains (
    ...    ((id eq 151) and
    ...    (COUNTvaluePDCP-SNlength18 contains (pDCP-SNlength18 eq 0))),
    ...    ((id eq 152) and
    ...    (COUNTvaluePDCP-SNlength18 contains (pDCP-SNlength18 is present))))
    ...    )
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    GNB_8:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (drb-ToAddModList contains (eps-BearerIdentity eq 5))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    ENB_1:X2AP_SgNBReconfigurationComplete (success-SgNBReconfComp is present)
    ...    GNB_8:X2AP_SNStatusTransfer (${SNSstatus_2})
    ...    MME_1:S1AP_E-RABModificationIndication (E-RABToBeModifiedListBearerModInd contains (e-RAB-ID eq 5))
    ...    MME_1:S1AP_E-RABModificationConfirm (E-RABModifyListBearerModConf contains (e-RAB-ID eq 5))
    ...    alias=UE_${ue_id}_ENDC_establish    overall_timeout=30
    Execute UEx Command    trf_data_start qci=6 ue=${ue_id} dir=dl protocol=udp Mbps=50 trf_id=1
    Flow Occurred As Expected    alias=UE_${ue_id}_ENDC_establish
    Execute UEx Command    trf_data_stop qci=6 ue=${ue_id}

Start data traffic for NR PDCP bearer till Data buffer overflow and trigger CA establish for UE
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${scell_addition_physCellId_2})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ue_id}_CA_establish    overall_timeout=30
    Execute UEx Command    trf_data_start qci=6 ue=${ue_id} dir=dl protocol=udp Mbps=130 trf_id=1
    Flow Occurred As Expected    alias=UE_${ue_id}_CA_establish
    Execute UEx Command    trf_data_stop qci=6 ue=${ue_id}

Start data traffic for NR PDCP bearer till Data buffer overflow and No ENDC establish but trigger CA establish
    [Arguments]    ${ue_id}=1    ${qci_id}=1
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    alias=UE_${ue_id}_No_ENDC_establish    overall_timeout=30
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${scell_addition_physCellId_2})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_${ue_id}_CA_establish    overall_timeout=30
    Execute UEx Command    trf_data_start qci=${qci_id} ue=${ue_id} dir=dl protocol=udp Mbps=120 trf_id=1
    Flow Not Occurred For Message    alias=UE_${ue_id}_No_ENDC_establish
    Flow Occurred As Expected    alias=UE_${ue_id}_CA_establish
    Execute UEx Command    trf_data_stop qci=${qci_id} ue=${ue_id}

Change Qci5 As NR-PDCP bearer
    Delta Commission Parameters    ${Delete_QCI6_Support_ENDC_And_QCI5_support_ENDC}
    Cells Should Be OnAir

Change Qci6 As NR-PDCP bearer
    Delta Commission Parameters    ${Delete_QCI5_Support_ENDC_And_QCI6_support_ENDC}
    Cells Should Be OnAir

Preset Restrict_nr_access Off Of Handover Restriction List handling On CUS Egate Side
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Execute Egate Command    mme_ho_restriction_list id=1 restrict_nr_access=off

Preset Restrict_nr_access On Of Handover Restriction List handling On CUS Egate Side
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Execute Egate Command    mme_ho_restriction_list id=1 restrict_nr_access=on
    Execute Egate Command    ue_mme_param id=${ue_id} ho_restrictions=nr_eps ho_restriction_list_id=1 hrl_dl_nas=on

Set UE Tau COMBINED_TA_LA_UPDATING And Trigger NRrestriction is updated for UE via S1AP_DownlinkNASTransport message
    [Arguments]    ${ue_id}=1
    ${HandoverRestrictionList}    catenate
    ...    HandoverRestrictionList contains (NRrestrictioninEPSasSecondaryRAT eq "nRrestrictedinEPSasSecondaryRAT")
    Expect Message Flow
    ...    MME_1:S1AP_DownlinkNASTransport (${HandoverRestrictionList})
    ...    alias=UE_${ue_id}_Have_NRrestrictionin    overall_timeout=30
    Execute UEx Command    get_ue_info id=${ue_id}
    Execute UEx Command    ue_im_entry id=${ue_id}
    Execute UEx Command    ue_tau id=${ue_id}
    sleep    2s    Wait UE change to idle
    Execute UEx Command    ue_im_exit id=${ue_id}
    Execute UEx Command    get_ue_info id=${ue_id}
    flow occurred as expected    alias=UE_${ue_id}_Have_NRrestrictionin

Setup Erab With NR-PDCP And B1 is activated in the UE
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${B1NRActivation})
    ...    MME_1:S1AP_E-RABSetupResponse(e-RAB-ID eq 6)
    ...    alias=UE_${ue_id}_B1_activate    overall_timeout=30
    Execute UEx Command    bearer_add ue=${ue_id} qci=5
    flow occurred as expected    alias=UE_${ue_id}_B1_activate
