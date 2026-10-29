*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4P    release-SBTS17A
...               team-DevHZ5_SG_OPS    owner-chao.3.zhang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=1403
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=1404
@{ENABLE_1942_multi_LNHOIF_01}
...    LNBTS:actSelMobPrf=true
...    LNBTS:actIfHo=enabled
...    LNCEL-1:actInterFreqLB=true
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=10
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL-1:iFLBLoadThresholds:iFLBBearCheckTimer=0
...    LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=10
...    LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=10
...    LNCEL-1:loadSettings:targetLoadPdcch=1
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=85
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadPdcch=95
...    LNCEL-2:intraFreqLbLoadThresholds:highLoadPdcch=90
...    LNCEL-2:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-2:loadSettings:targetLoadPdcch=90
...    LNCEL-2:intraFreqLbLoadThresholds:highLoadNonGbrDl=75
...    LNCEL-2:intraFreqLbLoadThresholds:hysteresisLoadPdcch=80
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1402
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19402
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1402
...    LNBTS/MODPR-0:autoAdapt=true
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFLBFilter=-140
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-100
...    LNCEL-1:iFLBA4ActLim=20
...    LNCEL-1:actServRlqInterFreqLB=false
...    LNBTS/MODPR-0:freqLayListDedVoLteHo=1402
...    LNBTS/MODPR-0:freqLayListLte=1402

*** Test Case ***
LTE1942_A_b_01_Elimination_of_Unsuitable_Target_cells_in_Load_Based_HO
    [Tags]    CDRT    RAN_4G    RAN_4G_FDD
    Delta Commission Parameters    ${ENABLE_1942_multi_LNHOIF_01}
    Cells Should Be OnAir
    Start Data With QCI5 To Reach A4 Threshold
    UE Sends A4 Measurement Report And Wait For IFA4HO

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets/bearer_set_2
    ...    - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...    - {qci: 1, preprovisioned: on, default: off, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, filter: 1, precedence: 1, pdn: 1}
    ...    - {qci: 5, preprovisioned: on, default: off, pdn: 1, filter: 6, precedence: 6}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2

    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.3
    ...    cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}

Start Data With QCI5 To Reach A4 Threshold
    [Arguments]    ${ue_id}=1
    Execute Egate Command    mme_param id=1 attach_cb_integrated=on
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (eventA4 is present)
    ...    alias=event_A4    overall_timeout=20
    Execute Uex Command    ue_attach id=${ue_id} cell=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp Mbps=1 qci=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=ul protocol=udp Mbps=100 qci=5
    #sleep    20s    #wait for traffic
    Flow Occurred As Expected    alias=event_A4

UE Sends A4 Measurement Report And Wait For IFA4HO
    [Arguments]    ${ue_id}=1
    ${IFA4HO_query}     catenate
    ...    mobilityControlInfo contains (targetPhysCellId eq 2) and
    ...    securityConfigHO contains (integrityProtAlgorithm eq 'eia0-v920')
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${IFA4HO_query})
    ...    alias=IFA4HO    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A4 phycell_id=2 nrsrp=76 nrsrq=23
    Flow Occurred As Expected    alias=IFA4HO
