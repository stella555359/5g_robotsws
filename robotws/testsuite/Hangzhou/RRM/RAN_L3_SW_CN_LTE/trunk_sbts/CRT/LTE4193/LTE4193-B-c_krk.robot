*** Settings ***
Documentation     LTE4193-B-c Test Suite
...               INTRODUCTION: LTE4193 Dynamic Trigger for LTE-5G IWK Option 3X feature supports the ability to select neighbor
...               NR cell based on cell strength using UE_1 measurements to start LTE-NR Dual Connectivity (EN-DC)
...               functionality on NR-PDCP bearer in eNB (MeNB).
...
...               The base functionality to support EN-DC has been added in LTE4088 LTE-NR Dual Connectivity Option 3X feature.
...               LTE4088 is the main pre-requisite for this feature. It is expected that LTE4088 functionality is available by
...               the time LTE4193 is supported.
...
...               Common preconditions :
...               - NR Status of two LNRELGBNBCELL is set to available:
...               LNCEL-11/LNRELGNBCELL-0: frequency: 524000, nRcellIdentifier: 294913
...               LNCEL-11/LNRELGNBCELL-1: frequency: 185000, nRcellIdentifier: 294914
...               LNCEL-11/LNRELGNBCELL-3: frequency: 185000, nRcellIdentifier: 311299
...               LNCEL-11/LNRELGNBCELL-4: frequency: 524000, nRcellIdentifier: 311300
...               LNCEL-11/LNRELGNBCELL-5: frequency: 524000, nRcellIdentifier: 311301
...               LNCEL-12/LNRELGNBCELL-0: frequency: 524000, nRcellIdentifier: 294913
...               LNCEL-12/LNRELGNBCELL-1: frequency: 185000, nRcellIdentifier: 294914
...               LNCEL-12/LNRELGNBCELL-2: frequency: 173800, nRcellIdentifier: 294918
...               LNCEL-12/LNRELGNBCELL-3: frequency: 185000, nRcellIdentifier: 311299
...               LNCEL-12/LNRELGNBCELL-4: frequency: 524000, nRcellIdentifier: 311300
...               LNCEL-12/LNRELGNBCELL-5: frequency: 524000, nRcellIdentifier: 311301
...               - Handover Restriction List does NOT restrict usage of NR
...               - UE_1 supports EN-DC
...               - EN-DC support lteNrDualConnectSupport and NR PDCP Profile index nrPdcpProfIdx parameters
...               qciTab6:
...               lteNrDualConnectSupport: EN-DC
...               nrPdcpProfIdx: '1001'
...               - C-Plane is NOT in OVL2 state
...               - LTE4088 and LTE4193 is enabled:
...               LNBTS-1/actLteNrDualConnectivity: true
...               LNBTS-1/actDynTrigLteNrDualConnectivity: true
...               - ssbPeriodicity is set to 10ms
...               NRDCDPR-0:
...               dlPathlossChg: 3 db
...               dynTriggerLteNrDcConfList:
...               lcrId: '11'
...               method: coverageBased
...               enDCpMaxEUTRApowerOffset: '0'
...               enDCpMaxNRpowerOffset: '0'
...               nrDcMeasConfig:
...               - b1ThresholdNrRsrp: '-70'
...               b1TimeToTriggerRsrp: 256ms
...               b1TimeToTriggerRsrq: 256ms
...               b1TriggerQuantity: RSRP
...               carrierFreqNrCell: '524000'
...               hysB1ThresholdRsrp: '2'
...               hysB1ThresholdRsrq: '2'
...               quantityConfigId: '0'
...               ssbDuration: sf1
...               ssbOffset: '0'
...               ssbPeriodicity: sf10-r15
...               ssbSubcarrierSpacing: 15kHz
...               - b1ThresholdNrRsrp: '-60'
...               b1TimeToTriggerRsrp: 256ms
...               b1TimeToTriggerRsrq: 256ms
...               b1TriggerQuantity: RSRP
...               carrierFreqNrCell: '185000'
...               hysB1ThresholdRsrp: '2'
...               hysB1ThresholdRsrq: '2'
...               quantityConfigId: '0'
...               ssbDuration: sf1
...               ssbOffset: '0'
...               ssbPeriodicity: sf10-r15
...               ssbSubcarrierSpacing: 15kHz
...               nrDcQuantityConfig:
...               filterCoefficientRsrp: fc4
...               filterCoefficientRsrq: fc4
...               quantityConfigId: '0'
...
...               Setup:
...               MeNB:
...               CELL-11:
...               lcrId:11
...               CELL-12:
...               lcrId:12
...               CELL-13:
...               lcrId:13
...               eNB (Simulated):
...               CELL-1
...               CELL-2
...               CELL-3
...               SgNB_1:
...               - ID: '1' LNADJGNB-1
...               administrativeState: unlocked
...               cPlaneIpAddr: 10.0.1.25
...               CELL-21:
...               earfcnDl: 524000
...               PCI: 381
...               nRcellIdentifier: 294913
...               CELL-22:
...               earfcnDl: 185000
...               PCI: 381
...               nRcellIdentifier: 294914
...               CELL-23:
...               earfcnDl: 173800
...               PCI: 381
...               nRcellIdentifier: 294918
...               SgNB_2:
...               - ID: '2' LNADJGNB-2
...               administrativeState: unlocked
...               cPlaneIpAddr: 10.0.1.26
...               CELL-31:
...               earfcnDl: 185000
...               PCI: 385
...               nRcellIdentifier: 311299
...               CELL-32:
...               earfcnDl: 524000
...               PCI: 385
...               nRcellIdentifier: 311300
...               CELL-33:
...               earfcnDl: 524000
...               PCI: 386
...               nRcellIdentifier: 311301
...
...               TEST SET NAME: LTE4193-B-c Incoming HO with EN-DC and coverage based trigger.
...
...               TESTING SPLIT: LTE4193-B-c Incoming HO with EN-DC and coverage based trigger.
...
...               CONTACTS: Lapa, Maciej (Nokia - PL/Krakow) <maciej.lapa@nokia.com>
...               I_EXT_LTE_ETK1_GMS <I_EXT_LTE_ETK1@internal.nsn.com>
...
...               REFERENCES: LTE4193 CFAMTEST SET NAME
...
...               HISTORY:
...               [30.11.2018] - First draft (Maciej Lapa)
...               [13.02.2019] - Review closed: (http://reviews.emea.nsn-net.net/r/45321/#review114236)
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LP12_CUS
...               team-SG4    release-SBTS23R4    owner-xu.wang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{NRDCPR}
...    @{LNCEL-2}

@{LNCEL-2}
...    LNCEL-2/LNRELGNBCELL-0:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-0:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-0:nrCellId=294913
...    LNCEL-2/LNRELGNBCELL-0:nrCgiPlmnId:mcc=250
...    LNCEL-2/LNRELGNBCELL-0:nrCgiPlmnId:mnc=555
...    LNCEL-2/LNRELGNBCELL-0:nrCgiPlmnId:mncLength=3
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=294914
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=250
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=555
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=3
...    LNCEL-2/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-3:nrCellId=311299
...    LNCEL-2/LNRELGNBCELL-3:nrCgiPlmnId:mcc=250
...    LNCEL-2/LNRELGNBCELL-3:nrCgiPlmnId:mnc=555
...    LNCEL-2/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=3
...    LNCEL-2/LNRELGNBCELL-4:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-4:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-4:nrCellId=311300
...    LNCEL-2/LNRELGNBCELL-4:nrCgiPlmnId:mcc=250
...    LNCEL-2/LNRELGNBCELL-4:nrCgiPlmnId:mnc=555
...    LNCEL-2/LNRELGNBCELL-4:nrCgiPlmnId:mncLength=3
...    LNCEL-2/LNRELGNBCELL-5:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-5:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-5:nrCellId=311301
...    LNCEL-2/LNRELGNBCELL-5:nrCgiPlmnId:mcc=250
...    LNCEL-2/LNRELGNBCELL-5:nrCgiPlmnId:mnc=555
...    LNCEL-2/LNRELGNBCELL-5:nrCgiPlmnId:mncLength=3
...    LNCEL-2/LNRELGNBCELL-6:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-6:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-6:nrCellId=294918
...    LNCEL-2/LNRELGNBCELL-6:nrCgiPlmnId:mcc=250
...    LNCEL-2/LNRELGNBCELL-6:nrCgiPlmnId:mnc=555
...    LNCEL-2/LNRELGNBCELL-6:nrCgiPlmnId:mncLength=3
@{NRDCPR}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=12
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1NrReportInterval=60min
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=86
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=524000
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf3
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf10-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:nrCarPrio=1

...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1NrReportInterval=60min
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1ThresholdNrRsrp=96
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:carrierFreqNrCell=173800
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=5
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbDuration=sf3
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbOffset=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbPeriodicity=sf10-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:nrCarPrio=1

...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc5
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc5
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0

${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A0000
...    0001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074000000
...    03A00000001D00000000E800000007400000003A00000001D00000001BFBFFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118
...    000238000480000920001280002580004C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A74000
...    00003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000
...    007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A0000000141000000F
...    3A00000000000000000000000000000000000000000000000000000000000202388425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C28040300E023C00000180000
...    008
${ue_nr_capabilities}    SEPARATOR=
...    000000000101004000004000003000001C040360401C04000E03000701C0000000
${ue_eutra_nr_capabilities}    SEPARATOR=
...    0108040360401C04000E03000701C000000003000080404008010100200404008010

*** Test Cases ***
LTE4193_B_c_6 - intra-eNB Handover - Both NR-ARFCNs supported of the two configured - MeasObject installed with different frequency
    [tags]
    [Documentation]    DESCRIPTION:
    ...    == Info==
    ...    UE is attached to simulated enb with NR-PDCP bearer configured.
    ...    MeasObject installed for LNCEL-11 contains different optional parametrs values.
    ...    MeNB configures the NR-PDCP configuration for bearer EN-DC eligible bearer after Intra eNB Handover.
    ...    SgNB addition procedure is successfully completed with the NR cells reported by the UE_1 in B1-NR measurement report.
    ...
    ...    == Precondition: ==
    ...    - Common preconditions
    ...    - VoLTE Call steering is disabled
    ...    - UE supports bands 5, 7, 8
    ...    NRDCPR-0:
    ...    dlPathlossChg: 3 db
    ...    dynTriggerLteNrDcConfList:
    ...    lcrId: '12'
    ...    method: coverageBased
    ...    enDCpMaxEUTRApowerOffset: '0'
    ...    enDCpMaxNRpowerOffset: '0'
    ...    nrDcMeasConfig:
    ...    - b1ThresholdNrRsrp: '-70'
    ...    b1TimeToTriggerRsrp: 256ms
    ...    b1TimeToTriggerRsrq: 256ms
    ...    b1TriggerQuantity: RSRP
    ...    carrierFreqNrCell: '173800'
    ...    hysB1ThresholdRsrp: '2'
    ...    hysB1ThresholdRsrq: '2'
    ...    quantityConfigId: '0'
    ...    ssbDuration: sf3
    ...    ssbOffset: '1'
    ...    ssbPeriodicity: sf10-r15
    ...    ssbSubcarrierSpacing: 15kHz
    ...    - b1ThresholdNrRsrp: '-70'
    ...    b1TimeToTriggerRsrp: 256ms
    ...    b1TimeToTriggerRsrq: 256ms
    ...    b1TriggerQuantity: RSRP
    ...    carrierFreqNrCell: '524000'
    ...    hysB1ThresholdRsrp: '2'
    ...    hysB1ThresholdRsrq: '2'
    ...    quantityConfigId: '0'
    ...    ssbDuration: sf3
    ...    ssbOffset: '1'
    ...    ssbPeriodicity: sf10-r15
    ...    ssbSubcarrierSpacing: 15kHz
    ...    nrDcQuantityConfig:
    ...    filterCoefficientRsrp: fc5
    ...    filterCoefficientRsrq: fc5
    ...    quantityConfigId: '0'
    ...
    ...    TESTING TOOLS: IPHY, EPCSIM, EMSSIM, UTE
    ...
    ...    TEST ENVIRONMENT:
    ...    HARDWARE ID: FXEA
    ...
    ...    REQUIRED LOGS: RRC, X2, S1 pcap
    ...
    ...    CONTACTS: Lapa, Maciej (Nokia - PL/Krakow) <maciej.lapa@nokia.com>
    ...    I_EXT_LTE_ETK1_GMS <I_EXT_LTE_ETK1@internal.nsn.com>
    ...
    ...    REFERENCES: LTE4193 CFAM
    ...
    ...    HISTORY:
    ...    [30.11.2018] - First draft (Maciej Lapa)
    ...    [7.01.2019] - Second draft (Gabriela Stasiuk)
    ...    [13.02.2019] - Review closed: (http://reviews.emea.nsn-net.net/r/45321/#review114236)
    delta commission parameters    ${PARAMS_IN_SCF}
    Prepare test environment for B_c_6
    Attach UE_1 to MeNB LNCEL-11
    UE_1 sends measurementReport to trigger Intra-eNB Handover to MeNB LNCEL-12
    UE_1 sends MeasurementReport with PCI=381,385,386 and RSRP values=120,100,110 above b1ThresholdNrRsrp

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=LTE4193    cfg=cus.yaml
    Create UE Alias    UE_1    ue_id=1    id_type=rtg
    create mme alias    MME_1    mme_id=1    id_type=wts
    create enb alias    MeNB    enb_id=1    id_type=wts
    create enb alias    SgNB_1    enb_id=2    id_type=wts
    create enb alias    SgNB_2    enb_id=3    id_type=wts
    create enb alias    eNB_4    enb_id=4    id_type=wts
    Execute Egate Command    enb_param, id=4, send_x2_setup=on
    Execute Egate Command    enb_x2_link_up enb=4 target=1
    Execute Egate Command    gnb_endc_param id=2 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=3 include_reestablish_pdcp=on
    Execute Egate Command    mme_param id=1 s1_hb_interval=120
    Execute Egate Command    trace_sim on mme=1 enb=1,2,3,4 uec=1 protocol=x2,s1,rrc on
    Execute Egate Command    enb_timer T_ShutdownNoX2TrafficTimer=500

Prepare test environment for B_c_6
    ${ue_param}    catenate    ue_param id=1 dl_256QAM_supported=on category-dl=14 ategory-ul=8 release=15 pdcp_sn_extension=on dual_conn=eutra_nr
    ...    nr_supported_bands=7 ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    execute uex command    ue_param id=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    execute uex command    ue_param id=1 ue_nr_capabilities=${ue_nr_capabilities}
    execute uex command    ue_param id=1 ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}

Attach UE_1 to MeNB LNCEL-11
    ${measObjectId_2}    catenate
    ...    measObjectId eq 2 and carrierFreq-r15 eq 524000 and quantityConfigSet-r15 eq 1 and periodicityAndOffset-r15 contains (sf10-r15 eq 0 )
    ...    and ssb-Duration-r15 eq 'sf1' and subcarrierSpacingSSB-r15 eq 'kHz15' and bandNR-r15 contains (setup eq 7)
    ${measObjectId_3}    catenate
    ...    measObjectId eq 3 and carrierFreq-r15 eq 185000 and quantityConfigSet-r15 eq 1 and periodicityAndOffset-r15 contains (sf10-r15 eq 0 )
    ...    and ssb-Duration-r15 eq 'sf1' and subcarrierSpacingSSB-r15 eq 'kHz15' and bandNR-r15 contains (setup eq 8)
    ${reportConfigId_5}    catenate
    ...    reportConfigId eq 5 and reportConfigInterRAT contains (b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 86)
    ...    and hysteresis eq 4 and timeToTrigger eq 'ms256') and maxReportCells eq 8 and reportInterval eq 'min60' and reportAmount eq 'r1'
    ${reportConfigId_6}    catenate
    ...    reportConfigId eq 6 and reportConfigInterRAT contains (b1-ThresholdNR-r15 contains (nr-RSRP-r15 eq 96)
    ...    and hysteresis eq 4 and timeToTrigger eq 'ms256') and maxReportCells eq 8 and reportInterval eq 'min60' and reportAmount eq 'r1'
    ${reconf}    catenate
    ...    measObjectToAddModList contains ( ${measObjectId_2} ,${measObjectId_3})
    ...    and reportConfigToAddModList contains ( ${reportConfigId_5},${reportConfigId_6})
    ...    and measIdToAddModList contains
    ...    ( measId eq 17 and measObjectId eq 2 and reportConfigId eq 5,measId eq 18 and measObjectId eq 3 and reportConfigId eq 6)

    Expect message flow
    ...    UE_1:RRC_RRCConnectionRequest
    ...    UE_1:RRC_RRCConnectionSetup
    ...    UE_1:RRC_RRCConnectionSetupComplete
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 6))
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_1:RRC_RRCConnectionReconfiguration (${reconf})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_ATTACH   overall_timeout=30
    execute uex command    ue_attach id=1 cell=11
    flow occurred as expected  alias=UE_ATTACH

UE_1 sends measurementReport to trigger Intra-eNB Handover to MeNB LNCEL-12
    ${measObjectId_2}    catenate
    ...    measObjectId eq 2 and carrierFreq-r15 eq 524000 and quantityConfigSet-r15 eq 1 and periodicityAndOffset-r15 contains (sf10-r15 eq 1 )
    ...    and ssb-Duration-r15 eq 'sf3' and subcarrierSpacingSSB-r15 eq 'kHz15'
    ${measObjectId_4}    catenate
    ...    measObjectId eq 4 and carrierFreq-r15 eq 173800 and quantityConfigSet-r15 eq 1 and periodicityAndOffset-r15 contains (sf10-r15 eq 1 )
    ...    and ssb-Duration-r15 eq 'sf3' and subcarrierSpacingSSB-r15 eq 'kHz15' and bandNR-r15 contains (setup eq 5)
    ${reconf}    catenate
    ...    measObjectToAddModList contains ( ${measObjectId_2} ,${measObjectId_4})
    ...    and measIdToAddModList contains
    ...    ( measId eq 17 and measObjectId eq 2 and reportConfigId eq 5,measId eq 18 and measObjectId eq 4 and reportConfigId eq 6)
    ...    and quantityConfig contains (measQuantityCellNR-r15 contains (filterCoeff-RSRP-r15 eq 'fc5'))

    Expect message flow
    ...    UE_1:RRC_MeasurementReport
    ...    UE_1:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 12))
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_1:RRC_RRCConnectionReconfiguration (${reconf})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    alias=INTRAENB_HO   overall_timeout=10
    Run UEx command    ue_ho    id=1    cell=12
    flow occurred as expected  alias=INTRAENB_HO

UE_1 sends MeasurementReport with PCI=381,385,386 and RSRP values=120,100,110 above b1ThresholdNrRsrp
    [Documentation]  Keyword can be used to report max RSRP/RSRQ values when is in form:
    ...     UE_1 sends MeasurementReport with PCI=385,381,386 and RSRP value above b1ThresholdNrRsrp
    ...     or with user specified RSRP/RSRQ values:
    ...     UE_1 sends MeasurementReport with PCI=381,385,386 and RSRP values=90,100,110 above b1ThresholdNrRsrp

    ${reconf}    catenate
    ...    measIdToRemoveList contains (17,18) and measGapConfig contains (release is present)
    ...    and spCellConfig contains ( physCellId eq 381 ) and length(spCellConfig) eq 1
    Expect message flow
    ...    UE_1:RRC_MeasurementReport (rsrpResult-r15 is present)
    ...    SgNB_1:X2AP_SgNBAdditionRequest
    ...    SgNB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_1:RRC_RRCConnectionReconfiguration (${reconf})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    SgNB_1:X2AP_SgNBReconfigurationComplete
    ...    alias=SCG_split_1    overall_timeout=20

    Expect Message Will Not Occur
    ...     SgNB_2:X2AP_SgNBAdditionRequest
    ...     alias=NO_SCG_split_2    overall_timeout=10

    ${cmd}    catenate
    ...    ue_measurement_send id=1 event=B1_NR phycell_id=381 nrsrp=120 phycell_id=385 nrsrp=100 phycell_id=386 nrsrp=110 srsrp=97 srsrq=34
    execute uex command    ${cmd}
    flow occurred as expected  alias=SCG_split_1
    flow not occurred for message    alias=NO_SCG_split_2