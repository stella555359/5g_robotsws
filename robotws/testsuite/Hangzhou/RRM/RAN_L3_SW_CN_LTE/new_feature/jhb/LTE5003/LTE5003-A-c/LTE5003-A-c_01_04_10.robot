*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               DevHZ5_SG3    release-SBTS20A    owner-zhijian.tong
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN531000}  531040
@{PARAMS_IN_SCF}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:actTransmittedBelowGap=false
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
...    LNCEL-1/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-3:nrCellId=132355
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2
...    LNCEL-3:actModulationSchemeDl=64QAM
...    LNCEL-2:actModulationSchemeDl=64QAM
...    LNCEL-1:actModulationSchemeDl=64QAM
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
@{NRDCPR}
...    LNBTS/NRDCPR-0:measGapEnableB1NR=true
...    LNBTS/NRMEASPR-0:cellList=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=${NRARFCN531000}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
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
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN531000}
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
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=531020
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=10000
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
...    0000000000001011C421298061CFFFFFFFFFFFFFFFA15000300452E00004000020961400019E000000C0000004
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    010804036040080810107018000000003000080400020100008040400801
@{SharedPlmnList}
...    262:03
@{CA}
...    LNBTS:actDLCAggr=true
...    LNBTS:actAdvScellMeas=true
...    LNBTS:enableBwCombCheck=true
...    LNBTS:actFlexScellSelect=true
...    LNCEL-1:actScellConfigForHiDemand=true
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
...    LNCEL-1:scellFastSchedulingSelect=normal
...    LNCEL-2:scellFastSchedulingSelect=normal
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL-1:dlCaMinPcellCqi=0
...    LNCEL-2:dlCaMinPcellCqiQci1=0
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-3:dlCaMinPcellCqiQci1=0
...    LNCEL-3:dlCaMinPcellCqi=0
@{Delete_QCI6_Support_ENDC_And_QCI5_support_ENDC}
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled
...    LNBTS:qciTab5:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab5:nrPdcpProfIdx=1001
@{Add_QCI6_Support_ENDC_And_QCI5_not_support_ENDC}
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab5:lteNrDualConnectSupport=disabled
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRQ
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN531000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRQ
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=531020
${V_1}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080
${B1NRActivation}
...    measObjectToAddModList contains (carrierFreq-r15 eq 531020) and
...    b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 90) and
...    reportOnLeave-r15 eq 'TRUE'
${scelladdition}
...    sCellIndex-r10 eq 1 and
...    physCellId-r10 eq 2 and
...    dl-CarrierFreq-r10 eq 1500

*** Test Cases ***
LTE5003-A-c_01_04_coverageAndBufferBased EN-DC setup in E-RAB setup before 2cc setup
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT    QC_25932
    Change Qci5 As NR-PDCP bearer
    UE1 Attach to eNB1 Cell1 and no B1 activated in the UE    ${ue_eutra_capabilities}
    Setup Erab With NR-PDCP And B1 is activated in the UE
    Ue1 report B1-NR to ENB1 Cell1    17    2
    Ue1 report B1-NR to ENB1 Cell1    18    1
    Start data traffic for NR PDCP bearer till Data buffer overflow and trigger ENDC establish
    Start data traffic for NR PDCP bearer till Data buffer overflow and trigger CA establish

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD_ABIO
    Set UE parameters for ENDC capability
    Create Alias

Set UE parameters for ENDC capability
    execute egate command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    execute egate command    trace_sim enb=42 protocol=x2,s1 on
    execute uex command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    execute uex command    ue_param id=1 nr_supported_bands=7
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms
    Set GNB parameters for ENDC setup

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '507000:531000'}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr, tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '507020:531020'}
    ${GNB8_CELL2}    catenate    - {id: 82, technology: nr, tac: 33, pci: '1:0', nrci: '0x0000503', nr_arfcn: '507020:531000'}
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...      gnb_id: '0x00008'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.12
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB8_CELL1}
    ...        ${GNB8_CELL2}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    Update Yaml    UEs/UE_sets/1     bearer: bearer_set_2


UE1 Attach to eNB1 Cell1 and no B1 activated in the UE
    [Arguments]    ${uecapability_for_LTE5003}    ${ue_id}=1    ${cell_id_number}=1
    expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 90))
    ...    alias=noB1activate    overall_timeout=30
    ${V_2}  catenate  ue_attach id=${ue_id} ue_eutra_capabilities=${uecapability_for_LTE5003} ue_nr_capabilities=${ue_nr_capabilities}
    ...  ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} enb=1 cell=1
    execute uex command    ${V_2}
    flow not occurred for message    alias=noB1activate

Ue1 report B1-NR to ENB1 Cell1                             #LTE5003-A-c_01_04
    [Arguments]    ${blacklist_measureid}=18    ${phycell_id}=1
    expect message will not occur
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    alias=noendcsetup    overall_timeout=30
    execute uex command  ue_measurement_send id=1 event=B1_NR phycell_id=${phycell_id} nrsrp=100 meas_id_blacklist=${blacklist_measureid}
    flow not occurred for message    alias=noendcsetup

Start data traffic for NR PDCP bearer till Data buffer overflow and trigger ENDC establish
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    alias=endcsetup    overall_timeout=30
    execute uex command  trf_data_start ue=1 qci=5 Mbps=50 dir=dl protocol=udp trf_id=1
    flow occurred as expected    alias=endcsetup
    execute uex command    trf_data_stop ue=1 qci=5

Setup Erab With NR-PDCP And B1 is activated in the UE
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${b1nractivation})
    ...    MME_1:S1AP_E-RABSetupResponse(e-RAB-ID eq 6)
    ...    alias=B1activate    overall_timeout=30
    execute uex command    bearer_add ue=${ue_id} qci=5
    flow occurred as expected    alias=B1activate

Start data traffic for NR PDCP bearer till Data buffer overflow and trigger CA establish
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${scelladdition})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=caactivate    overall_timeout=30
    execute uex command    trf_data_start qci=5 ue=1 Mbps=120 dir=dl protocol=udp trf_id=1
    flow occurred as expected    alias=caactivate
    execute uex command    trf_data_stop ue=1 qci=5

Change Qci5 As NR-PDCP bearer
    Delta Commission Parameters    ${Delete_QCI6_Support_ENDC_And_QCI5_support_ENDC}
    Cells Should Be OnAir

Set GNB parameters for ENDC setup
    execute egate command    gnb_endc_param id=7 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true
    execute egate command    gnb_endc_param id=8 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true
    execute egate command    gnb_endc_param id=7 scg_dl_dist_percent=0
    execute egate command    gnb_endc_param id=8 scg_dl_dist_percent=0

