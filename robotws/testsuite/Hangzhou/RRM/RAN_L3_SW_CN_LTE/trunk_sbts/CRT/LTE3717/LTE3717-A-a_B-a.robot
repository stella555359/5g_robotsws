*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...                 release-SBTS19A    team-CN3ET    owner-jun.15.zhang,annie.nie
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{RELATION_ERROR}
...    LNBTS/MODPR-0:autoAdapt=true
...    LNCEL:actInterFreqLB=true
...    LNCEL-1/LNCEL_TDD-0:earfcn=38100
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=10
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=10
...    LNCEL-1:loadSettings:targetLoadPdcch=1
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=10
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL-2:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...    LNCEL-2:loadSettings:targetLoadNonGbrDl=10
...    LNCEL-2:loadSettings:targetLoadPdcch=1
...    LNCEL-3:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=10
...    LNCEL-3:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL-3:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...    LNCEL-3:loadSettings:targetLoadNonGbrDl=10
...    LNCEL-3:loadSettings:targetLoadPdcch=1
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=38000
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFLBFilter=-140
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-100
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=3
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-2:loadSettings:mlbEicicOperMode=nonGbrOnly
...    LNCEL-3:loadSettings:mlbEicicOperMode=nonGbrOnly
...    @{X2_LINK}
@{X2_LINK}
...    LNBTS/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-1:adjEnbId=2
...    LNBTS/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    LNBTS/LNADJ-1/LNADJL-1:fDlEarfcn=38000
...    LNBTS/LNADJ-1/LNADJL-1:phyCellId=31
...    LNBTS/LNADJ-1/LNADJL-1:tac=33
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-3:ecgiLcrId=1
...    LNCEL-1/LNREL-3:handoverAllowed=allowed
...    LNCEL-1/LNREL-3:removeAllowed=false
...    LNCEL-1/LNREL-3:cellIndOffNeigh=0dB
${INTRA_ENB_IEF_LB_HO_PREP}    M8071C24
${INTRA_ENB_IEF_LB_HO_ATT}    M8071C25
${INTRA_ENB_IEF_LB_HO_SUCC}    M8071C26
${INTER_ENB_IEF_LB_X2_HO_PREP}    M8072C28
${INTER_ENB_IEF_LB_X2_HO_ATT}    M8072C29
${INTER_ENB_IEF_LB_X2_HO_SUCC}    M8072C30
@{pm_counters_Aa01}
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${INTRA_ENB_IEF_LB_HO_PREP}=2
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${INTRA_ENB_IEF_LB_HO_ATT}=2
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${INTRA_ENB_IEF_LB_HO_SUCC}=2
...    LNCEL-1:LTE_Inter_eNB_via_X2_Handover:${INTER_ENB_IEF_LB_X2_HO_PREP}=0
...    LNCEL-1:LTE_Inter_eNB_via_X2_Handover:${INTER_ENB_IEF_LB_X2_HO_ATT}=0
...    LNCEL-1:LTE_Inter_eNB_via_X2_Handover:${INTER_ENB_IEF_LB_X2_HO_SUCC}=0
@{pm_counters_Ba01}
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${INTRA_ENB_IEF_LB_HO_PREP}=0
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${INTRA_ENB_IEF_LB_HO_ATT}=0
...    LNCEL-1:LTE_Intra_eNB_Handover_Extension:${INTRA_ENB_IEF_LB_HO_SUCC}=0
...    LNCEL-1:LTE_Inter_eNB_via_X2_Handover:${INTER_ENB_IEF_LB_X2_HO_PREP}=2
...    LNCEL-1:LTE_Inter_eNB_via_X2_Handover:${INTER_ENB_IEF_LB_X2_HO_ATT}=2
...    LNCEL-1:LTE_Inter_eNB_via_X2_Handover:${INTER_ENB_IEF_LB_X2_HO_SUCC}=2
@{RELATION_ERROR}
...    LNCEL:actServRlqInterFreqLB=false
...    LNCEL:iFLBA4ActLim=20
...    LNCEL:intraFreqLbLoadThresholds:highLoadNonGbrDl=10
...    LNCEL/LNCEL_TDD-0:actServRlqTputInterFreqLB=false

${PM_COUNTER_INTERVAL}    1min

${A4_EVENT}
...    eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0)) and measId eq 31

${mobilty_info}
...    mobilityControlInfo contains (targetPhysCellId eq 2 and
...    carrierFreq contains (dl-CarrierFreq eq 38000))
${x2_mobility_info}
...    mobilityControlInfo contains (targetPhysCellId eq 31 and carrierFreq contains (dl-CarrierFreq eq 38000 and ul-CarrierFreq eq 38000))
*** Test Cases ***
LTE3717-A_a_01-Counter Updated After Intra-eNB Inter-Frequency Load Balancing Handover Finish
    [Documentation]    step1: attach UE to CELL and start traffic lead CELL over load
    ...    step2: rrc reconfig with A4 measurement sent to UE
    ...    step3: UE report A4 MR with target CELL
    ...    step4: UE HO to target CELL
    [Tags]
    Start Rtpm Counter
    UEs Attach eNB1 CELL1 With NonGBR
    UEs Start Traffic lead eNB1 CELL1 Enter High Load
    UEs Trigger A4 MR With Intra eNB And Wait Handover
    Check Rtpm Counters    ${pm_counters_Aa01}

LTE3717-B_a_01-Counter Updated After Inter-eNB Inter-Frequency Load Balancing X2 Handover Finish
    [Documentation]    step1: attach UE to CELL and start traffic lead CELL over load
    ...      step2: rrc reconfig with A4 measurement sent to UE
    ...      step3: UE report A4 MR with target CELL
    ...      step4: UE HO to target CELL
    [Tags]
    Start Rtpm Counter
    UEs Attach eNB1 CELL1 With NonGBR
    UEs Start Traffic lead eNB1 CELL1 Enter High Load
    UEs Trigger A4 MR With Inter eNB And Wait Handover
    Check Rtpm Counters    ${pm_counters_Ba01}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    3CELLs
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    execute egate command    trace_sim on mme=1 protocol=s1

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      cells:
    ...        - {id: 1, technology: lte, tac: 33, pci: '10:1', earfcn: '38000:38000', bw: 20}

UEs Attach eNB1 CELL1 With NonGBR
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=attach_flow    overall_timeout=20
    execute uex command    ue_attach id=1-3 cell=1
    flow occurred as expected    alias=attach_flow
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 5)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 5)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (e-RAB-ID eq 6 and qCI eq 5)
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=ue123_qci5    overall_timeout=20
    execute uex command    bearer_add ue=1 qci=5
    execute uex command    bearer_add ue=2 qci=5
    execute uex command    bearer_add ue=3 qci=5
    flow occurred as expected    alias=ue123_qci5

UEs Start Traffic lead eNB1 CELL1 Enter High Load
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_1:RRC_RRCConnectionReconfigurationComplete
    ...    UE_2:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    UE_3:RRC_RRCConnectionReconfiguration (${A4_EVENT})
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=A4_event    overall_timeout=20
    execute uex command    trf_data_start ue=1 dir=dl Mbps=100 protocol=udp
    execute uex command    trf_data_start ue=2 dir=dl kbps=300 protocol=udp
    execute uex command    trf_data_start ue=3 dir=dl kbps=300 protocol=udp
    flow occurred as expected    alias=A4_event

UEs Trigger A4 MR With Intra eNB And Wait Handover
    expect message flow
    ...    UE_2:RRC_MeasurementReport (measId eq 31 and physCellId eq 2)
    ...    UE_2:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    UE_3:RRC_MeasurementReport (measId eq 31 and physCellId eq 2)
    ...    UE_3:RRC_RRCConnectionReconfiguration (${mobilty_info})
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue23_ho    overall_timeout=20
    execute uex command    ue_measurement_send id=2 event=A4 srsrp=30 srsrq=15 phycell_id=2 nrsrp=80 nrsrq=34
    execute uex command    ue_measurement_send id=3 event=A4 srsrp=31 srsrq=12 phycell_id=2 nrsrp=85 nrsrq=34
    flow occurred as expected    alias=ue23_ho

UEs Trigger A4 MR With Inter eNB And Wait Handover
    expect message flow
    ...    UE_2:RRC_MeasurementReport (measId eq 31 and physCellId eq 31)
    ...    ENB_1:X2AP_HandoverRequest
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    UE_2:RRC_RRCConnectionReconfiguration (${x2_mobility_info})
    ...    UE_2:RRC_RRCConnectionReconfigurationComplete
    ...    UE_3:RRC_MeasurementReport (measId eq 31 and physCellId eq 31)
    ...    ENB_1:X2AP_HandoverRequest
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    UE_3:RRC_RRCConnectionReconfiguration (${x2_mobility_info})
    ...    UE_3:RRC_RRCConnectionReconfigurationComplete
    ...    alias=ue23_x2_ho    overall_timeout=20
    execute uex command    ue_measurement_send id=3 event=A4 srsrp=31 srsrq=12 phycell_id=31 nrsrp=85 nrsrq=34
    execute uex command    ue_measurement_send id=2 event=A4 srsrp=30 srsrq=15 phycell_id=31 nrsrp=80 nrsrq=34
    flow occurred as expected    alias=ue23_x2_ho

