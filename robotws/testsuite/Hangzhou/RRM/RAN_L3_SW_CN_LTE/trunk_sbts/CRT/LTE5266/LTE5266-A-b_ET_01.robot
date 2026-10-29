*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...                 team-CN3ET    owner-lixia.zhou,annie.nie    release-SBTS19B
Resource          ../../../resources/DevHZ5_resource.robot
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{Enable_Feature}
...    @{Cell1_Configuration}
...    @{Cell2_Configuration}
...    @{loadSettings}
...    @{iFLBLoadThresholds}
...    @{LNHOIF}
...    @{FIX_RELATION_ERROR}
@{FIX_RELATION_ERROR}
...    LNCEL-1/LNCEL_TDD-0:actServRlqTputInterFreqLB=false
...    LNCEL-2/LNCEL_TDD-0:actServRlqTputInterFreqLB=false
@{Enable_Feature}
...    LNCEL-1:actAmle=false
...    LNCEL-2:actAmle=false
...    LNCEL-1:actInterFreqLB=false
...    LNCEL-2:actInterFreqLB=false
...    LNBTS:actMultBearers=true
...    LNBTS/MODPR-0:autoAdapt=true
...    LNBTS:actIfHo=enabled
...    LNBTS:actLTES1Ho=true
...    LNCEL-1/LNCEL_TDD-0:earfcn=38000
...    LNCEL-2/LNCEL_TDD-0:earfcn=38100
...    LNBTS-1:qciTab5:schedulWeight=5
@{Cell1_Configuration}
...    LNCEL-1/AMLEPR-0:deltaCac=1
...    LNCEL-1/AMLEPR-0:cacHeadroom=0
...    LNCEL-1/AMLEPR-0:targetCarrierFreq=38100
...    LNCEL-1/AMLEPR-0:maxCacThreshold=100
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
...    LNCEL-1:actServRlqInterFreqLB=false
@{Cell2_Configuration}
...    LNCEL-2/AMLEPR-0:deltaCac=1
...    LNCEL-2/AMLEPR-0:cacHeadroom=0
...    LNCEL-2/AMLEPR-0:targetCarrierFreq=38000
...    LNCEL-2/AMLEPR-0:maxCacThreshold=100
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
...    LNCEL-2:actServRlqInterFreqLB=false
...    LNCEL-2:iFLBA4ActLim=40
@{iFLBLoadThresholds}
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=40
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL-1:iFLBLoadThresholds:iFLBBearCheckTimer=12
...    LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=10
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=40
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadPdcch=3
...    LNCEL-2:iFLBLoadThresholds:iFLBBearCheckTimer=12
...    LNCEL-2:iFLBLoadThresholds:iFLBRetryTimer=60
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
@{loadSettings}
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=40
...    LNCEL-1:loadSettings:targetLoadPdcch=1
...    LNCEL-1:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-1:loadSettings:cellCapClass=100
...    LNCEL-1:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-1:loadSettings:nomNumPrbNonGbr=10
...    LNCEL-1:loadSettings:targetLoadGbrDl=40
...    LNCEL-2:loadSettings:targetLoadNonGbrDl=40
...    LNCEL-2:loadSettings:targetLoadPdcch=3
...    LNCEL-2:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-2:loadSettings:cellCapClass=100
...    LNCEL-2:loadSettings:mlbEicicOperMode=nonGbrOnly
...    LNCEL-2:loadSettings:nomNumPrbNonGbr=5
...    LNCEL-2:loadSettings:targetLoadGbrDl=55
@{LNHOIF}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=38100
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFLBFilter=-140
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-100
...    LNCEL-2/LNHOIF-1:thresholdRsrpIFLBFilter=-140
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=38000
@{LB_ENABLE}
...    LNCEL-1:actInterFreqLB=true
...    LNCEL-2:actInterFreqLB=true
@{LB_PARA}
...    @{LB_ENABLE}
...    LNCEL-1:iFLBA4ActLim=50
${LB_HO_PREPARE}    M8071C24
${LB_HO_ATTEMPT}    M8071C25
${LB_HO_SUCCESS}    M8071C26
${AVA_HO_ATTEMPT_PER_SEC}    M8021C52
${AVA_HO_SUCCESS_PER_SEC}    M8021C53
${MAX_HO_ATTEMPT_PER_SEC}    M8021C54
${MAX_HO_SUCCESS_PER_SEC}    M8021C55
@{PM_COUNTERS_LB}
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${LB_HO_PREPARE}=4
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${LB_HO_ATTEMPT}=4
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${LB_HO_SUCCESS}=4
...    LNCEL-1:LTE_Handover:${AVA_HO_ATTEMPT_PER_SEC}>=1
...    LNCEL-1:LTE_Handover:${AVA_HO_SUCCESS_PER_SEC}>=1
...    LNCEL-1:LTE_Handover:${MAX_HO_ATTEMPT_PER_SEC}>=1
...    LNCEL-1:LTE_Handover:${MAX_HO_SUCCESS_PER_SEC}>=1
...    LNCEL-1:LTE_Handover:${AVA_HO_ATTEMPT_PER_SEC}<=3
...    LNCEL-1:LTE_Handover:${AVA_HO_SUCCESS_PER_SEC}<=3
...    LNCEL-1:LTE_Handover:${MAX_HO_ATTEMPT_PER_SEC}<=3
...    LNCEL-1:LTE_Handover:${MAX_HO_SUCCESS_PER_SEC}<=3
${A4_EVENT}
...    eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0))
...    and measIdToAddModList contains (measId eq 31)
${mobilty_info}
...    mobilityControlInfo contains (targetPhysCellId eq 2 and carrierFreq contains
...    (dl-CarrierFreq eq 38100))
${PM_COUNTER_INTERVAL}    1min
*** Test Cases ***
LTE5266-A_b_01-Counter Updated After Intra-eNB Inter-Frequency Load Balance Handover Finish
    [Tags]
    Start Rtpm Counter
    Delta Commission Parameters    ${LB_PARA}
    5UEs Attach eNB1 CELL1 For LB
    3UEs Start Traffic lead eNB1 CELL1 Enter LB
    3UEs Trigger A4 MR With Intra eNB And Wait Handover For LB
    UE5 Trigger A4 MR With Intra eNB And Wait Handover
    Check Rtpm Counters    ${PM_COUNTERS_LB}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS ENV    tl_type=3CELLs
    Create Alias
    execute egate command    sim_trace uec=1 protocol=rrc on

create alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

5UEs Attach eNB1 CELL1 For LB
    FOR    ${ue_id}    IN RANGE    1    6
        expect message flow
        ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
        ...    MME_1:S1AP_InitialContextSetupResponse
        ...    alias=ue_${ue_id}_attach    overall_timeout=20
    END
    FOR    ${ue_id}    IN RANGE    1    6
        execute egate command    ue_param id=${ue_id} csfb_rat=utran_geran voice_domain_preference=lte_preferred
        execute uex command    ue_attach id=${ue_id} selected_plmn=262:03 cell=1
    END
    FOR    ${ue_id}    IN RANGE    1    6
        flow occurred as expected    ue_${ue_id}_attach
    END
    5UEs Add Bearer

5UEs Add Bearer
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 6))
    ...    MME_1:S1AP_E-RABSetupResponse (e-RAB-ID eq 6)
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 6))
    ...    MME_1:S1AP_E-RABSetupResponse (e-RAB-ID eq 6)
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 6))
    ...    MME_1:S1AP_E-RABSetupResponse (e-RAB-ID eq 6)
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 1)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 6)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=qci6_qci1    overall_timeout=20
    execute uex command    bearer_add ue=1 qci=6
    execute uex command    bearer_add ue=2 qci=6
    execute uex command    bearer_add ue=3 qci=6
    execute uex command    bearer_add ue=4 qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    execute uex command    bearer_add ue=5 qci=6
    flow occurred as expected    alias=qci6_qci1

3UEs Start Traffic lead eNB1 CELL1 Enter LB
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_2:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    UE_3:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue123_A4_event    overall_timeout=20
    execute uex command    trf_data_start ue=${UE1} dir=dl kbps=10 protocol=udp
    execute uex command    trf_data_start ue=${UE2} dir=dl kbps=10 protocol=udp
    execute uex command    trf_data_start ue=${UE3} dir=dl kbps=10 protocol=udp
    execute uex command    trf_data_start ue=${UE4} dir=dl Mbps=100 protocol=udp
    flow occurred as expected    alias=ue123_A4_event

3UEs Trigger A4 MR With Intra eNB And Wait Handover For LB
    expect message flow
    ...    UE_1:RRC_MeasurementReport (measId eq 31 and physCellId eq 2)
    ...    UE_2:RRC_MeasurementReport (measId eq 31 and physCellId eq 2)
    ...    UE_3:RRC_MeasurementReport (measId eq 31 and physCellId eq 2)
    ...    UE_1:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_2:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_3:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue123_handover    overall_timeout=20
    execute uex command    ue_measurement_send id=${UE1} event=A4 srsrp=30 srsrq=15 phycell_id=2 nrsrp=80 nrsrq=34
    execute uex command    ue_measurement_send id=${UE2} event=A4 srsrp=30 srsrq=15 phycell_id=2 nrsrp=80 nrsrq=34
    execute uex command    ue_measurement_send id=${UE3} event=A4 srsrp=31 srsrq=12 phycell_id=2 nrsrp=85 nrsrq=34
    flow occurred as expected    alias=ue123_handover

UE5 Trigger A4 MR With Intra eNB And Wait Handover
    expect message flow
    ...    UE_5:RRC_MeasurementReport (measId eq 31 and physCellId eq 2)
    ...    UE_5:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_5:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue5_ho    overall_timeout=20
    execute uex command    ue_measurement_send id=${UE5} event=A4 srsrp=30 srsrq=15 phycell_id=2 nrsrp=80 nrsrq=34
    flow occurred as expected    alias=ue5_ho

