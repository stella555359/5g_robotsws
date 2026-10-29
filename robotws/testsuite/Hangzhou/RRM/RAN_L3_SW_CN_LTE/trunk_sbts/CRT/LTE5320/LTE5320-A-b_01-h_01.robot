*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               owner-shelly.song    team-DEVHZ5_SG2    release-SBTS20A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_LTE5320}
...    @{PARAMS_FOR_Cell}
...    @{PARAMS_FOR_CatM}
...    @{PARAMS_FOR_EMERGENCY}
...    @{PARAMS_FOR_Neighbor}
@{PARAMS_FOR_LTE5320}
...    LNCEL-1/CATMCEL-0:actRaiCatM=true
...    LNCEL-2/CATMCEL-0:actRaiCatM=false
...    LNCEL-3/CATMCEL-0:actRaiCatM=true
@{PARAMS_FOR_Cell}
...    LNBTS-1:actRLFbasedRCR=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1/CATMPR-1:qciForVoLTECatM=255
...    LNBTS-1/CATMPR-1:srbInactivityTimerCatM=60
...    LNBTS-1/CATMBPR-1:inactivityTimerModeBCatM=180
...    LNBTS-1/CATMBPR-1:cpInactivityTimerModeBCatM=180
...    LNBTS-1/CATMBPR-1:maxNumRrcModeBCatM=2
...    LNBTS-1/CATMBPR-1:defaultPagCeModeBCatM=n1
...    LNBTS-1/CATMPR-1:raPreGrCSizeCatM=5
...    LNBTS-1/CATMPR-1:minNumRrcCatM=0
...    LNBTS-1/LNADJ-255:rlfBasedRCRsupported=true
...    LNBTS-1/CATMPR-1:catMVoLTETab:maxGbrDlQci1CatM=80
...    LNBTS-1/CATMPR-1:catMVoLTETab:maxGbrUlQci1CatM=80
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL/CATMCEL-0:threshold2CatM=42
...    LNCEL/CATMCEL-0:hysThreshold2CatM=0
...    LNCEL/CATMCEL-0:a2TimeToTriggerCatM=480ms
...    LNCEL/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL/CATMCEL-0:actConvVoiceCatM=true
...    LNCEL:iniMcsUl=4
...    LNCEL:threshold1=75
...    LNCEL:threshold2InterFreq=40
...    LNCEL:threshold2a=67
...    LNCEL:threshold2aQci1=67
...    LNCEL:hysThreshold2InterFreq=0
...    LNCEL:cellResourceGroupPrId=1
...    LNCEL:inactivityTimerPubSafety=2000
...    LNCEL:iFServiceBasedHoRetryTimer=60
...    LNCEL:threshold2GERANQci1=25
...    LNCEL:threshold2InterFreqQci1=35
...    LNCEL:threshold2InterFreqHpue=40
...    LNCEL:a2TimeToTriggerActWcdmaMeas=0ms
...    LNCEL/SIB-0:siWindowLen=20ms
...    LNCEL:a2TimeToTriggerActInterFreqMeas=100ms
...    LNCEL:t301Guard=100
...    LNCEL:tac=33
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    delete:LNCEL/CATMCEL-0:threshServingLowQR9CatM
...    delete:LNBTS-1/PSGRP-1
...    delete:LNCEL/CATMCEL-0:acbPlmnNumStepsCatM
...    delete:LNCEL/CATMCEL-0:acbPrimaryPlmnProfileIdCatM
@{PARAMS_FOR_CatM}
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/LNCEL_FDD-0:catMProfId=1
...    LNCEL/CATMCEL-0:numCELevelCatM=2
...    LNCEL/CATMCEL-0:siNarBandSelectionCatM=ModeA
...    LNCEL/CATMCEL-0:actEDrxIdleCatM=true
...    LNCEL:dlsDciCch=DCI format 1A
...    LNCEL/CATMCEL-0:prachRsrpThrCatM=-60
...    LNCEL/CATMCEL-0:prachRsrpThr1CatM=-70
...    LNCEL/CATMCEL-0:prachRsrpThr2CatM=-80
...    LNCEL/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-1:actOtdoa=false
...    LNBTS-1:actMBMS=false
...    LNCEL-1/CATMCEL-0:actSf9InvalidLVRBCatM=false
@{PARAMS_FOR_EMERGENCY}
...    LNBTS-1/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNBTS-1:actEnhAcAndGbrServices=true
...    LNBTS-1:imsEmerPlmnConfig:emerSessArpPrioLev=1
...    LNBTS-1/CATMPR-1:maxNumRrcCatM=9
...    LNBTS-1/CATMPR-1:minNumRrcCatM=2
...    LNBTS-1/CATMPR-1:catMVoLTETab:dlMaxHarqTxQci1CatM=4
...    LNBTS-1/CATMPR-1:catMVoLTETab:tDiscardPdcpQci1CatM=infinity
...    LNBTS-1/CATMPR-1:catMVoLTETab:ulMaxHarqTxQci1CatM=1
...    LNBTS-1/CATMPR-1:maxNumQci1DrbCatM=2
...    LNBTS-1/CATMPR-1:maxNumRrcEmergencyCatM=9
...    LNBTS-1/CATMPR-1:maxNumQci1DrbEmergCatM=6
...    LNBTS-1/CATMPR-1:maxNumActDrbCatM=10
...    LNCEL/CATMCEL-0:actIMSEmerSessCatM=true
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=14
...    LNCEL/LNCEL_FDD-0:maxNumActDrb=21
...    LNCEL/LNCEL_FDD-0:maxNumQci1Drb=5
...    LNCEL/LNCEL_FDD-0:maxNumActUE=14
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=14
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:addEmergencySessions=0
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:minNumEmergencySessions=0
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:addAUeRrHo=0
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:addAUeTcHo=0
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrcNoDrb=0
...    LNCEL/LNCEL_FDD-0:addNumQci1DrbRadioReasHo=0
...    LNCEL/LNCEL_FDD-0:addNumDrbTimeCriticalHo=0
...    LNCEL/LNCEL_FDD-0:addNumDrbRadioReasHo=0
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=0
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=0
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=0
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=0
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=0
...    LNCEL/LNCEL_FDD-0:addNumQci1DrbTimeCriticalHo=0
...    LNCEL/LNCEL_FDD-0:maxNumCaConfUe=0
...    LNCEL/LNCEL_FDD-0:maxNumCaConfUe3c=0
...    LNCEL/LNCEL_FDD-0:maxNumCaConfUeDc=0
@{PARAMS_FOR_Neighbor}
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-3:handoverAllowed=allowed
...    LNCEL-1/LNREL-3:ecgiLcrId=3
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:handoverAllowed=allowed
...    LNCEL-2/LNREL-2:ecgiLcrId=1
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-3:handoverAllowed=allowed
...    LNCEL-2/LNREL-3:ecgiLcrId=3
...    LNCEL-2/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-2:handoverAllowed=allowed
...    LNCEL-3/LNREL-2:ecgiLcrId=1
...    LNCEL-3/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-3:handoverAllowed=allowed
...    LNCEL-3/LNREL-3:ecgiLcrId=2
...    LNCEL-3/LNREL-3:ecgiAdjEnbId=1
@{delta_param_A_b}
...    LNCEL/CATMCEL-0:actRaiCatM=true
...    LNBTS-1/CATMPR-1:inactivityTimerCatM=8
...    LNBTS-1/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=10
...    LNBTS-1/CATMPR-1:cpInactivityTimerCatM=60
...    LNCEL:inactivityTimer=1000
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1500
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=1450
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-2/LNHOIF-3:eutraCarrierInfo=1450
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=1500
...    LNCEL-3/LNHOIF-3:eutraCarrierInfo=1450
${ONLINE_CHANGE_PARAMETER_actRaiCatM_true}    LNCEL-1/CATMCEL-0:actRaiCatM=true
${ONLINE_CHANGE_PARAMETER_actRaiCatM_false}    LNCEL-1/CATMCEL-0:actRaiCatM=false
${UE_EUTRA_CAPABILITIES_CATMA_RAI_CAPABLE}
...    DA28030300082100C1F83F07E0FFFC3062FF282008800886400C08216A7008047480003184000AEC04390A6A03AA149180020004040080
# CATM FGI3,7,20 set as 1,enable ROHC,enable rai-Support-r14
${QCI_8_1}
    ...    E-RABToBeSetupListCtxtSUReq contains ( qCI eq 8, qCI eq 1 )
    ...    and
    ...    length(E-RABToBeSetupListCtxtSUReq) eq 2
${no_rai-Activation-r14}
...    rai-Activation-r14 is not present
${rai-Activation-r14}
...    rai-Activation-r14 eq "true"

*** Test Cases ***
LTE5320-A-b_01_01_eNB_configures_RAI_activation_to_UE_during_ICS_procedure_and_releases_UE_when_receive_BSR_equal_0
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT    owner-xu.wang
    OnlineParamChange     ${delta_param_A_b}
    3 CatM UEs attach to eNB1 cell1
    OnlineParamChange     ${ONLINE_CHANGE_PARAMETER_actRaiCatM_false}
    CAT-M CE-Level 1 RAI capable UE attached eNB1 cell1     ue_id=4    emergency=off    reconfig=${no_rai-Activation-r14}
    Trigger UE UL Data transfer     ue_id=4    qci=8
    Add non-emregency bearer for UE     ue_id=4    qci=6    reconfig=${no_rai-Activation-r14}
    OnlineParamChange     ${ONLINE_CHANGE_PARAMETER_actRaiCatM_true}
    Release QCI1 bearer and start traffic on default bearer for UE     ue_id=2    reconfig=${rai-Activation-r14}
    Trigger 2 UEs RCR to serving cell1
    Stop data traffic for 3UEs detects data inactivity and there will be no traffic in UL in future    ue_id_1st=1    ue_id_2nd=2    ue_id_3rd=3

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=10
    Execute Egate Command    mme_timer T_S1APInitialContextSetup=8000ms    #avoid the UE attach failure issue caused by network issue
    Execute Egate Command    uec_cell_param id=1 ul_rand_noise=on    #avoid ghost ue
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=10    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Update Yaml    EPC/PGW/2    emergency: on

    Add Yaml    UEs/bearer_sets
    ...    bearer_set_11:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, pdn: 1}
    ...      - {qci: 6, pdn: 1}
     ...     - {qci: 5, default: on, pdn: 2, priority: 1}
    ...      - {qci: 1, pdn: 2, priority: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, preprovisioned: on, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, priority: 1, filter: 1, precedence: 1}
     ...     - {qci: 5, default: on, pdn: 2, priority: 1}
    ...      - {qci: 1, pdn: 2, priority: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, pdn: 1, priority: 1}
     ...     - {qci: 5, default: on, pdn: 2, priority: 1}
    ...      - {qci: 1, pdn: 2, priority: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 7, preprovisioned: on, pdn: 1, filter: 7, precedence: 7}
     ...     - {qci: 5, default: on, pdn: 2, priority: 1}
    ...      - {qci: 1, pdn: 2, priority: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_5:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, preprovisioned: on, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, pdn: 1, filter: 1, precedence: 1}
     ...     - {qci: 5, default: on, pdn: 2, priority: 1}
    ...      - {qci: 1, pdn: 2, priority: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_6:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
     ...     - {qci: 5, default: on, pdn: 2, priority: 1}
    ...      - {qci: 1, pdn: 2, priority: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_7:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 6, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, priority: 1}
     ...     - {qci: 5, default: on, pdn: 2, priority: 1}
    ...      - {qci: 1, pdn: 2, priority: 1, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_11
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_11
    Update Yaml    UEs/UE_sets/4    bearer: bearer_set_11
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/5    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/6    bearer: bearer_set_4
    Update Yaml    UEs/UE_sets/7    bearer: bearer_set_5
    Update Yaml    UEs/UE_sets/8    bearer: bearer_set_6
    Update Yaml    UEs/UE_sets/9    bearer: bearer_set_6
    Update Yaml    UEs/UE_sets/10    bearer: bearer_set_7

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

CAT-M CE-Level 0 RAI capable UE attached eNB1 cell1
    [Arguments]    ${ue_id}=1    ${reconfig}=${rai-Activation-r14}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${reconfig})
    ...    alias=attach    overall_timeout=30
    Execute Uex Command    ue_param id=${ue_id} rai_support_r14=true
    Execute Uex Command    ue_param id=${ue_id} release=14 category=4
    Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATMA_RAI_CAPABLE}
    Flow Occurred As Expected    alias=attach

CAT-M CE-Level 1 RAI capable UE attached eNB1 cell1
    [Arguments]    ${ue_id}=1    ${emergency}=off    ${reconfig}=${rai-Activation-r14}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${reconfig})
    ...    alias=attach    overall_timeout=30
    Execute Uex Command    ue_param id=${ue_id} rai_support_r14=true
    Execute Uex Command    ue_ul_power_control id=${ue_id} pathloss=75
    Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATMA_RAI_CAPABLE} emergency=${emergency}
    Flow Occurred As Expected    alias=attach

CAT-M CE-Level 0 RAI capable UE attached eNB1 cell1 with QCI1 bearer
    [Arguments]    ${ue_id}=1    ${ICS}=${ICS}    ${reconfig}=${rai-Activation-r14}
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${ICS})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${reconfig})
    ...    alias=attach    overall_timeout=30
    Execute Uex Command    ue_param id=${ue_id} rai_support_r14=true
    Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATMA_RAI_CAPABLE}
    Flow Occurred As Expected    alias=attach

3 CatM UEs attach to eNB1 cell1
    CAT-M CE-Level 0 RAI capable UE attached eNB1 cell1    ue_id=1    reconfig=${rai-Activation-r14}
    Trigger UE DL And UL Data transfer     ue_id=1    qci=8
    CAT-M CE-Level 0 RAI capable UE attached eNB1 cell1 with QCI1 bearer    ue_id=2    ICS=${QCI_8_1}    reconfig=${no_rai-Activation-r14}
    Trigger UE DL And UL Data transfer     ue_id=2    qci=1
    CAT-M CE-Level 1 RAI capable UE attached eNB1 cell1     ue_id=3    emergency=on    reconfig=${no_rai-Activation-r14}
    Trigger UE DL And UL Data transfer     ue_id=3    qci=5

Trigger UE DL And UL Data transfer
    [Arguments]    ${ue_id}=1    ${qci}=8
    execute uex command    trf_data_start ue=${ue_id} qci=${qci} dir=dl_and_ul kbps=80 protocol=udp

Trigger UE UL Data transfer
    [Arguments]    ${ue_id}=1    ${qci}=8
    execute uex command    trf_data_start ue=${ue_id} qci=${qci} dir=ul kbps=80 protocol=udp

Add non-emregency bearer for UE
    [Arguments]    ${ue_id}=1    ${qci}=8    ${reconfig}=${rai-Activation-r14}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${reconfig})
    ...    alias=bearer_add    overall_timeout=30
    execute uex command    bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=bearer_add

Release one bearer for UE
    [Arguments]    ${ue_id}=1    ${qci}=1    ${reconfig}=${rai-Activation-r14}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${reconfig})
    ...    alias=bearer_del    overall_timeout=30
    execute uex command    bearer_del ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=bearer_del

Release QCI1 bearer and start traffic on default bearer for UE
    [Arguments]    ${ue_id}=1    ${reconfig}=${rai-Activation-r14}
    Release one bearer for UE    ue_id=${ue_id}    qci=1    reconfig=${reconfig}
    Trigger UE DL And UL Data transfer     ue_id=${ue_id}    qci=8
    sleep    10

Trigger 2 UEs RCR to serving cell1
    Trigger UE RRC Connection Reestablishment to serving cell1    ue_id=1    reconfig=${rai-Activation-r14}    qci=8
    Trigger UE RRC Connection Reestablishment to serving cell1    ue_id=3    reconfig=${no_rai-Activation-r14}    qci=5

Trigger UE RRC Connection Reestablishment to serving cell1
    [Arguments]    ${ue_id}=1    ${reconfig}=${rai-Activation-r14}    ${qci}=8
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${reconfig})
    ...    alias=RCR    overall_timeout=30
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} enb=1 cell=1
    Flow Occurred As Expected    alias=RCR
    Trigger UE UL Data transfer    ue_id=${ue_id}    qci=${qci}
    sleep    5

Stop data traffic for 3UEs detects data inactivity and there will be no traffic in UL in future
    [Arguments]    ${ue_id_1st}=1    ${ue_id_2nd}=1    ${ue_id_3rd}=1
    UE Activate RAI Function Released Immediately     ue_id=1    qci=8
    UE Activate RAI Function Released Immediately     ue_id=2    qci=8
    UE Activate RAI Function Not Released Immediately     ue_id=3    qci=5

UE Activate RAI Function Released Immediately
    [Arguments]    ${ue_id}=1    ${qci}=8
    execute uex command    trf_data_stop ue=${ue_id} qci=${qci}
    expect message flow
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq "user-inactivity")
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=release    overall_timeout=5
    flow occurred as expected    alias=release

UE Activate RAI Function Not Released Immediately
    [Arguments]    ${ue_id}=1    ${qci}=8
    Expect Message Will Not Occur
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq "user-inactivity")
    ...    alias=not_release_immediately    overall_timeout=5
    execute uex command    trf_data_stop ue=${ue_id} qci=${qci}
    Flow Not Occurred For Message    alias=not_release_immediately
