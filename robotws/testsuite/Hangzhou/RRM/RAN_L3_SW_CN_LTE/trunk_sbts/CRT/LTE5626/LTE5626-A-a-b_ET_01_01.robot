*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...                   CLOUD_R4LAPO_CUS    team-CN3ET    owner-junmei.shao,annie.nie    release-SBTS21A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-100
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFLBFilter=-140
...    LNCEL-1/AMLEPR-0:deltaCac=20
...    LNCEL-1/AMLEPR-0:cacHeadroom=10
...    LNCEL-1/AMLEPR-0:targetCarrierFreq=${earfcnDL2}
...    LNCEL-1/AMLEPR-0:maxCacThreshold=80
...    LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=10
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=60
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL-1:iFLBLoadThresholds:iFLBBearCheckTimer=12
...    LNCEL-1:loadSettings:cellCapClass=100
...    LNCEL-1:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-1:loadSettings:nomNumPrbNonGbr=10
...    LNCEL-1:loadSettings:targetLoadGbrDl=40
...    LNCEL-1:iFLBA4ActLim=20
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=40
...    LNCEL-1:loadSettings:targetLoadPdcch=1
...    LNCEL-1:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadGbrDl=60
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadNonGbrDl=60
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadPdcch=60
...    LNCEL-1/LNREL-1:amleAllowed=true
...    LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:nrControl=automatic
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...    LNCEL-1/LNREL-2:ecgiLcrId=3
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=${earfcnDL1}
...    LNCEL-2/LNHOIF-1:thresholdRsrpIFLBFilter=-140
...    LNCEL-2/AMLEPR-0:deltaCac=20
...    LNCEL-2/AMLEPR-0:cacHeadroom=10
...    LNCEL-2/AMLEPR-0:targetCarrierFreq=${earfcnDL1}
...    LNCEL-2/AMLEPR-0:maxCacThreshold=100
...    LNCEL-2:iFLBLoadThresholds:iFLBRetryTimer=60
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=60
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadPdcch=60
...    LNCEL-2:iFLBLoadThresholds:iFLBBearCheckTimer=12
...    LNCEL-2:loadSettings:cellCapClass=100
...    LNCEL-2:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-2:loadSettings:nomNumPrbNonGbr=5
...    LNCEL-2:iFLBA4ActLim=20
...    LNCEL-2:loadSettings:targetLoadGbrDl=55
...    LNCEL-2:loadSettings:targetLoadNonGbrDl=40
...    LNCEL-2:loadSettings:targetLoadPdcch=55
...    LNCEL-2:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-2:intraFreqLbLoadThresholds:highLoadGbrDl=60
...    LNCEL-2:intraFreqLbLoadThresholds:highLoadNonGbrDl=60
...    LNCEL-2:intraFreqLbLoadThresholds:highLoadPdcch=60
...    LNCEL-2/LNREL-1:amleAllowed=true
...    LNCEL-2/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-2/LNREL-1:handoverAllowed=allowed
...    LNCEL-2/LNREL-1:ecgiLcrId=1
...    LNCEL-2/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-1:nrControl=automatic
...    LNCEL-2/LNREL-1:removeAllowed=false
...    LNCEL-2/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-2:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...    LNBTS:actMultBearers=true
...    LNBTS/MODPR-0:autoAdapt=true
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1500
...    LNBTS:actIfHo=enabled
...    LNBTS:actLTES1Ho=true
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=${earfcnDL2}
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19450
...    LNCEL-3:iFLBA4ActLim=20
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19500
...    LNBTS-1:qciTab5:schedulWeight=5
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${earfcnDL2}
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=${earfcnDL1}
...    LNCEL-2:actServRlqInterFreqLB=false
...    @{LTE5626_PARAM_ENABLE}
@{LTE5626_PARAM_ENABLE}
...    LNCEL-1:actServRlqInterFreqLB=true
...    LNCEL-1/LNHOIF-1:thresholdRsrpServIFLBFilter=-120
...    LNCEL-1/LNHOIF-1:thresholdRsrqServIFLBFilter=-150
#RsrpThreshold=21,RsrqThreshold=10
@{LTE5626_PARAM_DISABLE}
...    LNCEL-1:actServRlqInterFreqLB=false
@{IFLB_ENABLE_LTE5626_DISABLE}
...    LNCEL-1:actAmle=false
...    LNCEL-2:actAmle=false
...    LNCEL-1:actInterFreqLB=true
...    LNCEL-2:actInterFreqLB=true
...    @{LTE5626_PARAM_DISABLE}
${earfcnDL1}      1400
${earfcnDL2}      1450
${qci5_setup}    E-RABToBeSetupItemBearerSUReq contains
...    (e-RAB-ID eq 6 and e-RABlevelQoSParameters contains (qCI eq 5))
${qci6_setup}    E-RABToBeSetupItemBearerSUReq contains
...    (e-RAB-ID eq 6 and e-RABlevelQoSParameters contains (qCI eq 6))
${qci7_setup}    E-RABToBeSetupItemBearerSUReq contains
...    (e-RAB-ID eq 6 and e-RABlevelQoSParameters contains (qCI eq 7))
${A4_EVENT}
...    eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0))
...    and measIdToAddModList contains (measId eq 31)
${mobilty_info}
...    mobilityControlInfo contains (targetPhysCellId eq 2 and
...    carrierFreq contains (
...    dl-CarrierFreq eq 1450 and ul-CarrierFreq eq 19450))
*** Test Cases ***
LTE5626-A-a-b_ET_01_01_Feature Active Deactive Intra-eNB Inter-Frequency Load Balancing Handover Function Test
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Delta Commission Parameters    ${IFLB_ENABLE_LTE5626_DISABLE}
    UEs Attach eNB1 CELL1 and Start Traffic to Lead CELL1 Enter High Load
    UE Send A4 MR And Perform Handover Even If sRSRP and sRSRQ Bigger Than Threshold
    release all ues
    Delta Commission Parameters    ${LTE5626_PARAM_ENABLE}
    UEs Attach eNB1 CELL1 and Start Traffic to Lead CELL1 Enter High Load
    UE Send A4 MR And Excluded for Handover when sRSRP and sRSRQ Bigger Than Threshold
    UE Send A4 MR And Perform Handover when sRSRP and sRSRQ Equal To Threshold

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env
    create alias
    execute egate command    trace_sim on mme=1 protocol=s1
create alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

UEs Attach eNB1 CELL1 and Start Traffic to Lead CELL1 Enter High Load
    FOR    ${ue_id}    IN RANGE    1    4
        expect message flow
        ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
        ...    MME_1:S1AP_InitialContextSetupResponse
        ...    alias=UE${ue_id}_attach_flow     overall_timeout=20
    END
    execute uex command    ue_attach id=1-3 cell=1
    FOR    ${ue_id}    IN RANGE    1    4
        flow occurred as expected    alias=UE${ue_id}_attach_flow
    END
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (${qci5_setup})
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (${qci6_setup})
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (${qci7_setup})
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=bearer_setup    overall_timeout=20
    execute uex command    bearer_add ue=1 qci=5
    execute uex command    bearer_add ue=2 qci=6
    execute uex command    bearer_add ue=3 qci=7
    flow occurred as expected    alias=bearer_setup
    Start Traffic to trigger A4 event Reconfig

Start Traffic to trigger A4 event Reconfig
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_2:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    UE_3:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=A4_event    overall_timeout=20
    execute uex command    trf_data_start ue=${UE1} dir=dl protocol=udp Mbps=10 qci=5
    execute uex command    trf_data_start ue=${UE2} dir=dl protocol=udp kbps=300 qci=6
    execute uex command    trf_data_start ue=${UE3} dir=dl protocol=udp kbps=300 qci=7
    flow occurred as expected    alias=A4_event

UE Send A4 MR And Perform Handover Even If sRSRP and sRSRQ Bigger Than Threshold
    ${ret}    execute uex command    get_ue_meas_config id=3
    expect message flow
    ...    UE_3:RRC_MeasurementReport (measId eq 31 and physCellId eq 2)
    ...    UE_3:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    alias=ho_pci2    overall_timeout=20
    execute uex command    ue_measurement_send id=${UE3} event=A4 srsrp=31 srsrq=12 phycell_id=2 nrsrp=85 nrsrq=34
    flow occurred as expected    alias=ho_pci2

UE Send A4 MR And Excluded for Handover when sRSRP and sRSRQ Bigger Than Threshold
    expect message flow
    ...    UE_3:RRC_MeasurementReport (measId eq 31 and physCellId eq 2)
    ...    UE_3:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (31))
    ...    alias=a4_no_ho    overall_timeout=20
    expect message will not occur
    ...    UE_3:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    alias=no_ho    overall_timeout=20
    execute uex command    ue_measurement_send id=${UE3} event=A4 srsrp=31 srsrq=12 phycell_id=2 nrsrp=85 nrsrq=34
    flow occurred as expected    alias=a4_no_ho
    flow not occurred for message    alias=no_ho

UE Send A4 MR And Perform Handover when sRSRP and sRSRQ Equal To Threshold
    expect message flow
    ...    UE_3:RRC_MeasurementReport (measId eq 31 and physCellId eq 2)
    ...    UE_3:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    alias=ho_pci2_again    overall_timeout=20
    execute uex command    ue_measurement_send id=${UE3} event=A4 srsrp=21 srsrq=10 phycell_id=2 nrsrp=85 nrsrq=34
    flow occurred as expected    alias=ho_pci2_again