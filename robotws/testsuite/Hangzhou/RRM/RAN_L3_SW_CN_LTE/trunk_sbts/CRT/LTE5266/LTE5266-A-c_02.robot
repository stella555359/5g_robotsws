*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-CN3ET    owner-lixia.zhou,annie.nie    release-SBTS19B
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS/MODPR-0:autoAdapt=true
...    LNCEL-1:actInterFreqLB=true
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=${earfcnDL1}
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=${earfcnUL1}
...    LNCEL-1:actServRlqInterFreqLB=true
...    LNCEL-1/LNHOIF-1:thresholdRsrpServIFLBFilter=-100
...    LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${earfcnDL2}
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFLBFilter=-140
...    LNCEL-1:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-1:loadSettings:nomNumPrbNonGbr=10
...    LNCEL-1:loadSettings:targetLoadGbrDl=5
...    LNCEL-1:iFLBA4ActLim=10
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-100
...    LNCEL-1/AMLEPR-0:deltaCac=1
...    LNCEL-1/AMLEPR-0:cacHeadroom=10
...    LNCEL-1/AMLEPR-0:targetCarrierFreq=${earfcnDL2}
...    LNCEL-1/AMLEPR-0:maxCacThreshold=99
...    LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=10
...    LNBTS:actMultBearers=true
...    LNBTS:actIfHo=enabled
...    LNBTS:actSelMobPrf=false
...    LNBTS-1:qciTab5:schedulWeight=5
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=10
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL-1:iFLBLoadThresholds:iFLBBearCheckTimer=12
...    LNCEL-1:loadSettings:cellCapClass=100
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=10
...    LNCEL-1:loadSettings:targetLoadPdcch=1
...    LNCEL-1:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadGbrDl=5
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadNonGbrDl=60
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadPdcch=60
...    @{X2_LINK}
...    delete:LNCEL-1/MBSFNCEL-0
@{X2_LINK}
...    delete:LNADJ-1/LNADJL-255
...    LNBTS/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    LNBTS/LNADJ-1:adjEnbId=2
...    LNBTS/LNADJ-1/LNADJL-1:lnAdjlId=1
...    LNBTS/LNADJ-1/LNADJL-1:ecgiLcrId=1
...    LNBTS/LNADJ-1/LNADJL-1:phyCellId=31
...    LNBTS/LNADJ-1/LNADJL-1:tac=33
...    LNBTS/LNADJ-1/LNADJL-1:fDlEarfcn=${earfcnDL2}
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-1:ecgiLcrId=1
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:amleAllowed=true
...    LNCEL-1/LNREL-1:nrControl=automatic
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
@{ET3}
...    LNCEL-1:actIntraFreqLoadBal=true
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-140
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=60
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=60
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=40
...    LNCEL-1:loadSettings:targetLoadPdcch=55
...    LNCEL-1:actAmle=true
...    LNCEL-1:actInterFreqLB=false
...    LNCEL-1:iFLBA4ActLim=5
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1:loadSettings:targetLoadGbrDl=40
...    LNCEL-1:intraFreqLbLoadThresholds:highLoadGbrDl=60
${earfcnDL1}      1450
${earfcnDL2}      1400
${earfcnUL1}      19450
${AVA_HO_ATTEMPT_PER_SEC}    M8021C52
${AVA_HO_SUCCESS_PER_SEC}    M8021C53
${MAX_HO_ATTEMPT_PER_SEC}    M8021C54
${MAX_HO_SUCCESS_PER_SEC}    M8021C55
@{PM_COUNTERS_ET}
...    LNCEL-1:LTE_Handover:${AVA_HO_ATTEMPT_PER_SEC}>=1
...    LNCEL-1:LTE_Handover:${AVA_HO_SUCCESS_PER_SEC}>=1
...    LNCEL-1:LTE_Handover:${MAX_HO_ATTEMPT_PER_SEC}>=1
...    LNCEL-1:LTE_Handover:${MAX_HO_SUCCESS_PER_SEC}>=1
...    LNCEL-1:LTE_Handover:${AVA_HO_ATTEMPT_PER_SEC}<=2
...    LNCEL-1:LTE_Handover:${AVA_HO_SUCCESS_PER_SEC}<=2
...    LNCEL-1:LTE_Handover:${MAX_HO_ATTEMPT_PER_SEC}<=2
...    LNCEL-1:LTE_Handover:${MAX_HO_SUCCESS_PER_SEC}<=2
${PM_COUNTER_INTERVAL}    1min
${A4_EVENT}
...    eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0))
...    and measIdToAddModList contains (measId eq 31)
${mobilty_info}
...    mobilityControlInfo contains (targetPhysCellId eq 31 and carrierFreq contains
...    (dl-CarrierFreq eq 1400 and ul-CarrierFreq eq 19400))
*** Test Cases ***
LTE5266-A_c_02-Counter Updated After Inter-eNB Inter-Frequency Load Equalization Handover Finish via X2
    [Tags]
    Delta Commission Parameters    ${ET3}
    Start Rtpm Counter
    4UEs Attach to CELL1
    Setup Dedicate Bearer For All UE
    Send Traffic And Wait A4 For UEs
    A4 Event And Wait Ho For UEs
    Send Traffic And Wait A4 For UE5
    Check Rtpm Counters    ${PM_COUNTERS_ET}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env
    create alias
    execute egate command    sim_trace uec=1 protocol=rrc on
    Execute Egate Command    trace_sim enb=1,2 protocol=x2,s1 on

create alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    create mme alias    MME_1    mme_id=1    id_type=wts

Perform Steps After Onair
    Object Should Exist    LNADJ-1:x2LinkStatus=available

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      bts_param: {mlb_feature_flag: 'on', mlbSupportedRelease: 'r9'}
    ...      cells:
    ...        - {id: 1, technology: lte, tac: 33, pci: '10:1', earfcn: '1400:19400', bw: 20}

4UEs Attach to CELL1
    FOR    ${ue_id}    IN RANGE    1    5
        expect message flow
        ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
        ...    MME_1:S1AP_InitialContextSetupResponse
        ...    alias=ue_${ue_id}_attach    overall_timeout=20
    END
    FOR    ${ue_id}    IN RANGE    1    5
        execute uex command    ue_attach id=${ue_id} selected_plmn=262:03 cell=1
    END
    FOR    ${ue_id}    IN RANGE    1    5
        flow occurred as expected    ue_${ue_id}_attach
    END

Setup Dedicate Bearer For All UE
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 5))
    ...    MME_1:S1AP_E-RABSetupResponse (e-RAB-ID eq 6)
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 5))
    ...    MME_1:S1AP_E-RABSetupResponse (e-RAB-ID eq 6)
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 5))
    ...    MME_1:S1AP_E-RABSetupResponse (e-RAB-ID eq 6)
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 1)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=qci6_qci1    overall_timeout=20
    execute uex command    bearer_add ue=1 qci=5
    execute uex command    bearer_add ue=2 qci=5
    execute uex command    bearer_add ue=3 qci=5
    execute uex command    bearer_add ue=4 qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    flow occurred as expected    alias=qci6_qci1

Send Traffic And Wait A4 For UEs
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_2:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    UE_3:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue123_A4    overall_timeout=20
    execute uex command    trf_data_start ue=1 dir=dl protocol=udp kbps=300
    execute uex command    trf_data_start ue=2 dir=dl protocol=udp kbps=300
    execute uex command    trf_data_start ue=3 dir=dl protocol=udp kbps=300
    execute uex command    trf_data_start ue=4 dir=dl protocol=udp Mbps=100
    flow occurred as expected    alias=ue123_A4

A4 Event And Wait Ho For UEs
    expect message flow
    ...    UE_1:RRC_MeasurementReport (measId eq 31 and physCellId eq 31)
    ...    ENB_1:X2AP_HandoverRequest (radioNetwork contains ("reduce-load-in-serving-cell"))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge (HandoverCommand contains (targetPhysCellId eq 31))
    ...    UE_1:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_2:RRC_MeasurementReport (measId eq 31 and physCellId eq 31)
    ...    ENB_1:X2AP_HandoverRequest (radioNetwork contains ("reduce-load-in-serving-cell"))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge (HandoverCommand contains (targetPhysCellId eq 31))
    ...    UE_2:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    UE_3:RRC_MeasurementReport (measId eq 31 and physCellId eq 31)
    ...    ENB_1:X2AP_HandoverRequest (radioNetwork contains ("reduce-load-in-serving-cell"))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge (HandoverCommand contains (targetPhysCellId eq 31))
    ...    UE_3:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue123_handover    overall_timeout=20
    execute uex command    ue_measurement_send event=A4 id=1 srsrp=30 srsrq=15 phycell_id=31 nrsrp=80 nrsrq=34
    execute uex command    ue_measurement_send event=A4 id=2 srsrp=30 srsrq=15 phycell_id=31 nrsrp=80 nrsrq=34
    execute uex command    ue_measurement_send event=A4 id=3 srsrp=30 srsrq=15 phycell_id=31 nrsrp=80 nrsrq=34
    flow occurred as expected    alias=ue123_handover

Send Traffic And Wait A4 For UE5
    execute uex command    ue_attach id=5 cell=1
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 5))
    ...    MME_1:S1AP_E-RABSetupResponse (e-RAB-ID eq 6)
    ...    alias=ue5_attach    overall_timeout=20
    execute uex command    bearer_add ue=5 qci=5
    flow occurred as expected    alias=ue5_attach
    expect message flow
    ...    UE_5:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_5:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue5_A4    overall_timeout=20
    execute uex command    trf_data_start ue=5 dir=dl protocol=udp Mbps=100
    flow occurred as expected    alias=ue5_A4
    expect message flow
    ...    UE_5:RRC_MeasurementReport (measId eq 31 and physCellId eq 31)
    ...    ENB_1:X2AP_HandoverRequest (radioNetwork contains ("reduce-load-in-serving-cell"))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge (HandoverCommand contains (targetPhysCellId eq 31))
    ...    UE_5:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_5:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue5_ho    overall_timeout=20
    execute uex command    ue_measurement_send event=A4 id=5 srsrp=30 srsrq=15 phycell_id=31 nrsrp=80 nrsrq=34
    flow occurred as expected    alias=ue5_ho
