*** Settings ***
Documentation     Note:
...     1. original \ Error indication comand
...     ${HEX_01_01} \ \ \ \ \ 0003401C00000400094002000000054002038000114003701B40010840020001
...     ${HEX_01_02} \ \ \ \ \ 0003401C00000400094002000100054002038000114003701B40010840020001
...     ${HEX_03_01} \ \ \ \ \ 0003401C00000400094002000200054002028000114003701B40010840020003
...     ${HEX_03_02} \ \ \ \ \ 0003401C00000400094002000300054002028000114003701B40010840020004
...     ${HEX_05_01} \ \ \ \ \ 0003401C00000400094002000400054002028000114003701B40010840020005
...     ${HEX_06_01} \ \ \ \ \ 0003401C00000400094002000500054002030000114003701B40010840020006
...     ${HEX_06_02} \ \ \ \ \ 0003401C00000400094002000600054002136000114003701B40010840020007
...     2. send_hex source=gnb:7 target=enb:1 hex=${HEX}
...     3. if case B1 not created, please check \ wireshark file "ENDCX2SetupResponse" ----> carrierFreq 's vaule
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO    team-SG4
...               owner-rebecca.zhong    release-SBTS20B
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN531000}    531040
@{PARAMS_IN_SCF}
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51\
...    LNBTS/NRDCDPR-0:tPeriodicPhr=200sf
...    delete:LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    @{x2link}
...    @{Handover}
...    @{LTE4088}
@{x2link}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=132354
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNBTS/LNADJ-1:cPlaneIpAddr=10.0.1.32
...    LNBTS/LNADJ-1/LNADJL-1:fDlEarfcn=1450
...    LNBTS/LNADJ-1/LNADJL-1:ecgiLcrId=1
...    LNBTS/LNADJ-1/LNADJL-1:phyCellId=101
...    LNBTS/LNADJ-1/LNADJL-1:tac=33
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNBTS/LNADJGNB-2:adjGnbId=8
...    LNBTS/LNADJGNB-2:adjGnbIdLength=22
@{Handover}
...    LNBTS-1:actHoWoSnChg=intraEnbHoEnabled
...    LNBTS-1:actIfHo=enabled
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1450
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-1:threshold2InterFreq=65
...    LNCEL-1:threshold1=90
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNCEL:defaultLnRelGnbCellId=1
@{Param_actLteNrDualConnectivity}
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNBTS/NRMEASPR-0:cellList=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased
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
...    LNBTS/NRDCPR-0:enDCpMaxEUTRApowerOffset=4
...    LNBTS/NRDCPR-0:enDCpMaxNRpowerOffset=5
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=100
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrq=-87
@{Param_dynTriggerLteNrDcConfList}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN531000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
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
@{LTE4531_enable}
...    LNBTS:actMultiSCGSplit=true
...    LNBTS:actStepAddBearENDC=true
...    LNBTS:actMultiSCGSplitwoeLcId=true
@{LTE4531_disable}
...    LNBTS:actMultiSCGSplit=false
...    LNBTS:actStepAddBearENDC=false
...    LNBTS:actMultiSCGSplitwoeLcId=false
@{qciTab7}
...    LNBTS:qciTab7:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{qciTab8}
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}    0108040160401C06000000000400020101002004
@{Param_01_01}
...    @{Param_actLteNrDualConnectivity}
...    @{qciTab8}
...    @{qciTab7}
...    @{LTE4531_enable}
...    delete:LNBTS:qciTab6:nrPdcpProfIdx
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled
@{Param_05_02}
...    @{Param_dynTriggerLteNrDcConfList}
...    @{qciTab8}
...    @{LTE4531_disable}
...    LNBTS:qciTab7:lteNrDualConnectSupport=disabled
...    delete:LNBTS:qciTab7:nrPdcpProfIdx
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled
...    delete:LNBTS:qciTab6:nrPdcpProfIdx

${wait Error Indication sucess}    5s
${unknown-new-eNB-UE-X2AP-ID}    unknown-new-eNB-UE-X2AP-ID
${unknown-pair-of-UE-X2AP-ID}    unknown-pair-of-UE-X2AP-ID
${unknown-old-eNB-UE-X2AP-ID}    unknown-old-eNB-UE-X2AP-ID
${unknown-old-en-gNB-UE-X2AP-ID}    unknown-old-en-gNB-UE-X2AP-ID
${V1}
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

*** Test Cases ***
LTE4488-R-a_01_01_Menb received ERROR INDICATION after SGNB Blind addition with completed in two UECs
    [Tags]
    OnlineParamChange    ${Param_01_01}
    Set ue parameters before attach    ue_id=1    cell_id=1
    UE attach and ADD NR-PDCP bearer and Get connections APID with Blind ENDC    ue_id=1    ue_nr_capabilities=${ue_nr_capabilities}    cell_id=1
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Set ue parameters before attach    ue_id=2    cell_id=2
    UE attach and ADD NR-PDCP bearer and Get connections APID with Blind ENDC    ue_id=2    ue_nr_capabilities=${ue_nr_capabilities}    cell_id=2
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}    UE-X2AP-ID=1    SgNB-UE-X2AP-ID=2
    Trigger GNB-7 send ERROR INDICATION For Ue1    ue_id=2    ue_x2ap_id=0    sgnb_ue_x2ap_id=1
    Trigger GNB-7 send ERROR INDICATION For Ue2    ue_id=2    ue_x2ap_id=1    sgnb_ue_x2ap_id=2

LTE4488-R-a_05_02_Menb received ERROR INDICATION from Gnb2 with Gnb1 APIDs
    [Tags]
    OnlineParamChange    ${Param_05_02}
    Set ue parameters before attach    ue_id=5    cell_id=1
    UE attach and ADD NR-PDCP bearer and Get connections APID with Dynamic ENDC    ue_id=5    ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Trigger GNB-7 send ERROR INDICATION from Gnb2 with Gnb1 APIDs    ue_id=5    ue_x2ap_id=2    sgnb_ue_x2ap_id=3

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    execute cmd on pc    sudo ifconfig eth4:1 add 10.0.2.11
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    execute egate command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create Enb Alias    GNB_8    enb_id=8    id_type=wts
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
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 7, pdn: 1}
    ...     - {qci: 9, pdn: 1}
    FOR    ${ue_id}    IN RANGE    1    50
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
        Update Yaml    UEs/UE_sets/${ue_id}     capability: ${V1}
    END
    add yaml    EPC
    ...    UEC:
    ...    - id: 1
    ...    peer_uplane: '10.0.2.11:2152'

Set ue parameters before attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${nr_supported_bands}=7
    execute egate command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on scg_dl_dist_percent=0
    execute uex command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=${nr_supported_bands}
    execute egate command    gnb_endc_param id=8 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    execute uex command    ue_cqi_param id=${ue_id} scell=0-3 rank=4 cell=target
    execute uex command    ue_cqi_param id=${ue_id} scell=0-3 rank=4 cell=current
    execute egate command    trace_sim enb=42 protocol=x2 on
    execute egate command    enb_param id=42 endc_capable_qci=all
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE attach and ADD NR-PDCP bearer and Get connections APID with Blind ENDC
    [Arguments]    ${ue_nr_capabilities}    ${ue_eutra_nr_capabilities}    ${ue_eutra_capabilities}=${empty}    ${ue_id}=1    ${cell_id}=1
    ...    ${UE-X2AP-ID}=0    ${SgNB-UE-X2AP-ID}=1
    execute egate command    trace enb=7 protocol=x2 on
    expect message flow
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(UE-X2AP-ID eq ${UE-X2AP-ID} and SgNB-UE-X2AP-ID eq ${SgNB-UE-X2AP-ID})
    ...    alias=ue${ue_id}endc    overall_timeout=30
    ${V2}    catenate
    ...    ue_attach id=${ue_id} enb=1 cell=${cell_id} ue_eutra_capabilities=${V1} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    execute uex command    ${V2}
    sleep    1s     # in order to avoid collision with check endcbearer after attach completion
    execute uex command    bearer_add ue=${ue_id} qci=8
    flow occurred as expected    alias=ue${ue_id}endc

UE attach and ADD NR-PDCP bearer and Get connections APID with Dynamic ENDC
    [Arguments]    ${ue_nr_capabilities}    ${ue_eutra_nr_capabilities}    ${ue_eutra_capabilities}=${empty}    ${ue_id}=1
    execute egate command    trace enb=7 protocol=x2 on
    ${V4}    catenate
    ...    ue_attach id=${ue_id} enb=1 cell=1 ue_eutra_capabilities=${V1}
    ...    ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    execute uex command    ${V4}
    expect message flow
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(UE-X2AP-ID eq 2 and SgNB-UE-X2AP-ID eq 3)
    ...    alias=ue${ue_id}endc    overall_timeout=30
    expect message flow
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(UE-X2AP-ID eq 0 and SgNB-UE-X2AP-ID eq 1)
    ...    alias=ue${ue_id}endc1    overall_timeout=30
    execute uex command    bearer_add ue=${ue_id} qci=8
    execute uex command    ue_measurement_send id=${ue_id} meas_id_blacklist=18 event=B1_NR phycell_id=1 nrsrp=60
    verify at least one flow occurs as expected    ue${ue_id}endc    ue${ue_id}endc1

Trigger GNB-7 send ERROR INDICATION For Ue1
    [Arguments]    ${ue_id}=1    ${ue_x2ap_id}=None    ${sgnb_ue_x2ap_id}=None
    expect message flow
    ...    ENB_1:X2AP_ErrorIndication(radioNetwork eq 'unknown-pair-of-UE-X2AP-ID')
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge(UE-X2AP-ID eq ${ue_x2ap_id} and SgNB-UE-X2AP-ID eq ${sgnb_ue_x2ap_id})
    ...    alias=error${ue_id}endc    overall_timeout=20
    execute egate command    send_hex source=gnb:7 target=enb:1 hex=0003401c00000400094002000000054002038000114003701B40010840020001
    sleep    ${wait Error Indication sucess}
    flow occurred as expected    alias=error${ue_id}endc

Trigger GNB-7 send ERROR INDICATION For Ue2
    [Arguments]    ${ue_id}=1    ${ue_x2ap_id}=None    ${sgnb_ue_x2ap_id}=None
    expect message flow
    ...    ENB_1:X2AP_ErrorIndication(radioNetwork eq 'unknown-new-eNB-UE-X2AP-ID')
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge(UE-X2AP-ID eq ${ue_x2ap_id} and SgNB-UE-X2AP-ID eq ${sgnb_ue_x2ap_id})
    ...    alias=error${ue_id}endc    overall_timeout=20
    execute egate command    send_hex source=gnb:7 target=enb:1 hex=0003401c00000400094002000100054002028000114003701B40010840020002
    sleep    ${wait Error Indication sucess}
    flow occurred as expected    alias=error${ue_id}endc

Trigger GNB-7 send ERROR INDICATION from Gnb2 with Gnb1 APIDs
    [Arguments]    ${ue_id}=1    ${ue_x2ap_id}=None    ${sgnb_ue_x2ap_id}=None
    expect message flow
    ...    ENB_1:X2AP_ErrorIndication(UE-X2AP-ID eq ${ue_x2ap_id} and SgNB-UE-X2AP-ID eq ${sgnb_ue_x2ap_id})
    ...    alias=errorindication    overall_timeout=30
    expect message will not occur
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge(UE-X2AP-ID eq ${ue_x2ap_id} and SgNB-UE-X2AP-ID eq ${sgnb_ue_x2ap_id})
    ...    alias=error${ue_id}endc    overall_timeout=10
    execute egate command    send_hex source=gnb:8 target=enb:1 hex=0003401c00000400094002000200054002028000114003701B40010840020003
    sleep    ${wait Error Indication sucess}
    flow not occurred for message    alias=error${ue_id}endc
    flow occurred as expected    alias=errorindication


