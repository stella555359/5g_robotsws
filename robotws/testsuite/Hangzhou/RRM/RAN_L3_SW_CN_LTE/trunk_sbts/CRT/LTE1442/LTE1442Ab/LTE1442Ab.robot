*** Settings ***
Suite Setup       Common Suite Setup And Setup 2CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_2xAPO_2CUS
...               team-DevHZ5_SG4    DevHZ5_SG4    owner-bob.song    owner-eric.jiang    release-xxx
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_EARFCN}
...    @{PARAMS_FOR_LNADJ}
...    @{PARAMS_FOR_LNREL}
...    @{PARAMS_FOR_HOIF}
...    @{PARAMS_FOR_MODPR}
...    @{PARAMS_FOR_LNHENB}
...    @{PARAMS_FOR_A3A5}
...    LNCEL-1:blacklistHoL:blacklistTopo=allEqual|freqEutra=1800
...    LNCEL-1:blacklistHoL:phyCellIdStart=5|freqEutra=1800
...    LNCEL-1:blacklistHoL:phyCellIdRange=n4|freqEutra=1800
...    LNBTS-1:actHeNBMobility=true
...    LNBTS-1:actIfHo=enabled
...    LNCEL-1:t301Guard=100
...    LNCEL-2:t301Guard=100
...    LNCEL-3:t301Guard=100
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnEarfcn=1700
@{PARAMS_FOR_LNREL}
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-1:ecgiLcrId=1
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:amleAllowed=false
...    LNCEL-1/LNREL-1:cellIndOffNeigh=-1dB
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:nrControl=automatic
...    LNCEL-1/LNREL-1:removeAllowed=false
@{PARAMS_FOR_EARFCN}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19700
@{PARAMS_FOR_HOIF}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1800
...    LNCEL-1/LNHOIF-1:a5ReportIntervalInterFreq=240ms
...    LNCEL-1/LNHOIF-1:a5TimeToTriggerInterFreq=256ms
...    LNCEL-1/LNHOIF-1:offsetFreqInter=0dB
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw50
...    LNCEL-1/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-1/LNHOIF-1:interPresAntP=true
...    LNCEL-1/LNHOIF-1:hysThreshold3InterFreq=0
...    LNCEL-1/LNHOIF-1:threshold3InterFreq=60
...    LNCEL-1/LNHOIF-1:threshold3aInterFreq=26
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=0
...    LNCEL-1/LNHOIF-1:a3ReportIntervalRsrpInterFreq=240ms
...    LNCEL-1/LNHOIF-1:a3TimeToTriggerRsrpInterFreq=320ms
...    LNCEL-1/LNHOIF-1:hysA3OffsetRsrpInterFreq=0
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-100
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFLBFilter=-120
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFSBFilter=-100
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFSBFilter=-100
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=2690
...    LNCEL-1/LNHOIF-2:a5ReportIntervalInterFreq=240ms
...    LNCEL-1/LNHOIF-2:a5TimeToTriggerInterFreq=256ms
...    LNCEL-1/LNHOIF-2:offsetFreqInter=0dB
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw50
...    LNCEL-1/LNHOIF-2:measQuantInterFreq=rsrp
...    LNCEL-1/LNHOIF-2:interPresAntP=true
...    LNCEL-1/LNHOIF-2:hysThreshold3InterFreq=0
...    LNCEL-1/LNHOIF-2:threshold3InterFreq=60
...    LNCEL-1/LNHOIF-2:threshold3aInterFreq=26
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreq=0
...    LNCEL-1/LNHOIF-2:a3ReportIntervalRsrpInterFreq=240ms
...    LNCEL-1/LNHOIF-2:a3TimeToTriggerRsrpInterFreq=320ms
...    LNCEL-1/LNHOIF-2:hysA3OffsetRsrpInterFreq=0
...    LNCEL-1/LNHOIF-2:thresholdRsrpIFLBFilter=-100
...    LNCEL-1/LNHOIF-2:thresholdRsrqIFLBFilter=-120
...    LNCEL-1/LNHOIF-2:thresholdRsrpIFSBFilter=-100
...    LNCEL-1/LNHOIF-2:thresholdRsrqIFSBFilter=-100
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=400
...    LNCEL-1/LNHOIF-3:a5ReportIntervalInterFreq=240ms
...    LNCEL-1/LNHOIF-3:a5TimeToTriggerInterFreq=256ms
...    LNCEL-1/LNHOIF-3:offsetFreqInter=0dB
...    LNCEL-1/LNHOIF-3:measurementBandwidth=mbw50
...    LNCEL-1/LNHOIF-3:measQuantInterFreq=rsrp
...    LNCEL-1/LNHOIF-3:interPresAntP=true
...    LNCEL-1/LNHOIF-3:hysThreshold3InterFreq=0
...    LNCEL-1/LNHOIF-3:threshold3InterFreq=60
...    LNCEL-1/LNHOIF-3:threshold3aInterFreq=26
...    LNCEL-1/LNHOIF-3:a3OffsetRsrpInterFreq=0
...    LNCEL-1/LNHOIF-3:a3ReportIntervalRsrpInterFreq=240ms
...    LNCEL-1/LNHOIF-3:a3TimeToTriggerRsrpInterFreq=320ms
...    LNCEL-1/LNHOIF-3:hysA3OffsetRsrpInterFreq=0
...    LNCEL-1/LNHOIF-3:thresholdRsrpIFLBFilter=-100
...    LNCEL-1/LNHOIF-3:thresholdRsrqIFLBFilter=-120
...    LNCEL-1/LNHOIF-3:thresholdRsrpIFSBFilter=-100
...    LNCEL-1/LNHOIF-3:thresholdRsrqIFSBFilter=-100
@{PARAMS_FOR_A3A5}
...    LNCEL-1:enableBetterCellHo=true
...    LNCEL-1:a3Offset=4
...    LNCEL-1:hysA3Offset=0
...    LNCEL-1:a3TimeToTrigger=480ms
...    LNCEL-1:a3ReportInterval=240ms
...    LNCEL-1:enableCovHo=true
...    LNCEL-1:threshold3=42
...    LNCEL-1:threshold3a=45
...    LNCEL-1:hysThreshold3=0
...    LNCEL-1:a5TimeToTrigger=480ms
...    LNCEL-1:a5ReportInterval=240ms
...    LNCEL-1:a2TimeToTriggerActWcdmaMeas=0ms
...    LNCEL-1:threshold2Wcdma=65
...    LNCEL-1:threshold2a=70
...    LNCEL-1:threshold2aQci1=70
@{PARAMS_FOR_LNADJ}
...    LNADJ-254:cPlaneIpAddrCtrl=oamControlled
...    LNADJ-254:cPlaneIpAddr=10.0.1.4
...    LNADJ-254:adjEnbId=2
...    LNADJ-254:plmnId:mcc=262
...    LNADJ-254:plmnId:mnc=3
...    LNADJ-254:plmnId:mncLength=2
...    LNADJ-254:rlfBasedRCRsupported=false
@{PARAMS_IN_SCF_ENB2}
...    @{PARAMS_FOR_EARFCN}
...    @{PARAMS_FOR_A3A5}
...    @{PARAMS_FOR_HOIF}
...    @{PARAMS_FOR_MODPR}
...    @{PARAMS_FOR_LNHENB}
...    LNBTS-2:actHeNBMobility=true
...    LNBTS-2:actIfHo=enabled
...    LNCEL-1:blacklistHoL:blacklistTopo=allEqual|freqEutra=1800
...    LNCEL-1:blacklistHoL:phyCellIdStart=1|freqEutra=1800
...    LNCEL-1:blacklistHoL:phyCellIdRange=n4|freqEutra=1800
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiLcrId=1
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:amleAllowed=false
...    LNCEL-1/LNREL-1:cellIndOffNeigh=1dB
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:nrControl=automatic
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1:t301Guard=100
...    LNCEL-2:t301Guard=100
...    LNCEL-3:t301Guard=100
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnEarfcn=1700
@{PARAMS_FOR_LNHENB}
...    LNHENB-0:freqEutra=2690
...    LNHENB-0:enbIdSize=28
...    LNHENB-0:cellIndOff=1dB
...    LNHENB-0:pciFirst=1
...    LNHENB-0:pciLast=32
...    LNHENB-1:freqEutra=1800
...    LNHENB-1:enbIdSize=28
...    LNHENB-1:cellIndOff=0dB
...    LNHENB-1:pciFirst=1
...    LNHENB-1:pciLast=8
...    LNHENB-2:freqEutra=400
...    LNHENB-2:enbIdSize=28
...    LNHENB-2:cellIndOff=24dB
...    LNHENB-2:pciFirst=1
...    LNHENB-2:pciLast=1
@{PARAMS_FOR_MODPR}
...    LNBTS/MODPR-0:autoAdapt=true
...    LNBTS/MODPR-0:autoAdaptIMLB=false
...    LNBTS/MODPR-0:targetSelMethod=SIB_based
@{DELTA_COMMISSION_FOR_ENB2}
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=30
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreq=30
...    LNCEL-1/LNHOIF-3:a3OffsetRsrpInterFreq=30
...    LNHENB-2:cellIndOff=0dB
${V_1}    SEPARATOR=
...    C9B80484001040A20204F84F84F84F84FBF87EE5100100382C0000000005C40802000004200008800011
...    400024000204F84F84F84F84F94100000000

*** Test Cases ***
LTE1442Ab Measurement Configuration For Home eNBs During Handover
    [Documentation]    [1][1.0] C-Pln_LTE1442 Measurement Configuration for Home eNBs during handover
    [Tags]
    Delta Commission For Enb2
    UE Attach To Enb1 Cell1    ue_id=1    ue_eutra_capabilities=${V1}
    Trigger A2 Event ENB1   ue_id=1
    Handover to ENB2 Cell1    ue_id=1    phycell_id=51
    Trigger A2 Event ENB2   ue_id=1
    Detach UE    ue_id=1

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Setup 2CUS Env    tl_type=3CELLs_FDD    tl_type_enb2=3CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=10.0.1.2    id_type=real
    Create Enb Alias    alias=ENB_2    enb_id=10.0.1.4    id_type=real
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Delta Commission For Enb2
    Delta Commission Parameters Enb2    ${DELTA_COMMISSION_FOR_ENB2}
    Cells Should Be OnAir eNB2

UE Attach To Enb1 Cell1
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=${V1}
    ${message1}=    catenate
    ...    MME_1:S1AP_InitialContextSetupRequest (
    ...    (UERadioCapability is not present) and
    ...    (E-RABToBeSetupListCtxtSUReq contains (((e-RAB-ID eq 5) and (qCI eq 8)))))
    ${message2}=    catenate
    ...    UE_GROUP_1:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (measObjectId eq 1 and carrierFreq eq 1700))
    Expect Message Flow
    ...    ${message1}
    ...    UE_GROUP_1:RRC_UECapabilityEnquiry
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    ${message2}
    ...    alias=UE_Attach_Flow    overall_timeout=20
    Execute Uex Command    ue_param id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1 selected_plmn=262:03
    Flow Occurred As Expected    alias=UE_Attach_Flow

Trigger A2 Event ENB1
    [Arguments]    ${ue_id}=1
    ${message}=    catenate
    ...    RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (
    ...    (measObjectId eq 2 and carrierFreq eq 1800 and cellIndex eq 1 and start eq 5),
    ...    (measObjectId eq 3 and carrierFreq eq 2690 and cellsToAddModList contains ((cellIndex eq 31 and cellIndividualOffset eq "dB1"),
    ...    (cellIndex eq 32 and cellIndividualOffset eq "dB1"))),
    ...    (measObjectId eq 4 and carrierFreq eq 400 and cellIndex eq 1 and cellIndividualOffset eq "dB24")))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:${message}
    ...    alias=A2_ENB1_Flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=60 srsrq=30
    Flow Occurred As Expected    alias=A2_ENB1_Flow
    Execute Egate Command    ue_stats id=1
    Execute Egate Command    ue_disp id=1
    sleep    2s

Handover To Enb2 Cell1
    [Arguments]    ${ue_id}=1    ${phycell_id}=51
    ${x2ap_handoverRequest}=    catenate
    ...    X2AP_HandoverRequest (
    ...    e-RABs-ToBeSetup-List contains (e-RAB-ID eq 5 and qCI eq 8) and
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 1700, 
    ...    carrierFreq eq 1800 and cellIndex eq 1 and start eq 5,
    ...    carrierFreq eq 2690 and cellsToAddModList contains (cellIndex eq 32 and cellIndividualOffset eq "dB1"),
    ...    carrierFreq eq 400 and cellsToAddModList contains (cellIndex eq 1 and cellIndividualOffset eq "dB24")))
    ${x2ap_handoverRequestAcknowledge}=    catenate
    ...    X2AP_HandoverRequestAcknowledge (E-RABs-Admitted-List contains (e-RAB-ID eq 5) and
    ...    mobilityControlInfo contains (targetPhysCellId eq 51))
    ${rrcConnectionReconfiguration}=    catenate
    ...    RRC_RRCConnectionReconfiguration (
    ...    measObjectToAddModList contains (measObjectId eq 1 and carrierFreq eq 1700
    ...    and cellsToAddModList contains (cellIndex eq 1 and cellIndividualOffset eq "dB1")))
    Expect Message Flow
    ...    ENB_1:${x2ap_handoverRequest}
    ...    ENB_2:${x2ap_handoverRequestAcknowledge}
    ...    UE_GROUP_1:${rrcConnectionReconfiguration}
    ...    alias=Handover_Flow    overall_timeout=40
    Execute Uex Command    ue_measurement_send id=${ue_id} id=1 event=A3 srsrp=69 srsrq=30 phycell_id=${phycell_id} nrsrp=75 nrsrq=30
    Flow Occurred As Expected    alias=Handover_Flow

Trigger A2 Event ENB2
    [Arguments]    ${ue_id}=1
    ${message}=    catenate
    ...    RRC_RRCConnectionReconfiguration (
    ...    (measObjectToAddModList contains (
    ...    (measObjectId eq 2 and carrierFreq eq 1800 and cellIndex eq 1 and start eq 1),
    ...    (measObjectId eq 4 and carrierFreq eq 400 and cellsToRemoveList contains (1)))) and
    ...    (reportConfigToAddModList contains (a3-Offset eq 30)))
    Expect Message Flow
    ...    UE_GROUP_1:${message}
    ...    alias=A2_ENB2_Flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=60 srsrq=30
    Flow Occurred As Expected    alias=A2_ENB2_Flow
    Execute Egate Command    ue_stats id=1
    Execute Egate Command    ue_disp id=1

Detach UE
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionRelease
    ...    alias=Detach_UE_Flow    overall_timeout=5
    Execute Egate Command    ue_disp id=${ue_id}
    Execute Uex Command    ue_detach id=${ue_id}
    Flow Occurred As Expected    alias=Detach_UE_Flow
