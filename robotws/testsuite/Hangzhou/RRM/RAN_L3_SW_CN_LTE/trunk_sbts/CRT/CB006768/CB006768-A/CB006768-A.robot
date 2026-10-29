*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT
...               CLOUD_R4LAPO_CUS    team-DevHZ5_SG1    owner-zhijian.tong    release-SBTS23R2
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_LTE4551}
...    @{PARAMS_FOR_EARFCN}
...    @{PARAMS_FOR_CB006768}
@{PARAMS_FOR_LTE4551}
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0:catMProfId=1
...    LNCEL/SIB-0:siWindowLen=40ms
...    LNCEL/SIB-0:threshServingLowQR9=0
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL:inactivityTimerQci5Sign=150
...    LNCEL:qci1ProtectionTimer=100
...    LNBTS:qciTab5:schedulType=SIGNALLING
...    LNBTS:qciTab5:lcgid=0
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNBTS:actRrcConnNoActivity=true
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-2/IAFIM-1:intrFrBCList:startIntraPci=120
...    LNCEL-2/IAFIM-1:intrFrNCList:physCellIdNcl=0
...    LNCEL-2/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...    LNCEL-2:inactivityTimerQci5Sign=150
...    LNCEL-2:iniMcsUl=4
...    LNCEL-2:mbrSelector=ueCapability
...    LNCEL-2:harqMaxMsg3=3
...    LNCEL-2:phyCellId=2
...    LNCEL-2:caPoolId=1
...    LNCEL-2:dlTargetBler=100
...    LNCEL-2:assignedVoLteQualProfile=1
...    LNCEL-2:eIcicMaxNumPartners=10
...    LNCEL-2:prsBandwidth=6 PRB
...    LNCEL-2/SLMEAS-0:hysThreshold2Sidelink=4
...    LNCEL-2/SLMEAS-0:threshold2Sidelink=21
...    LNCEL-2/SLMEAS-0:a2TimeToTriggerActSL=480ms
...    LNCEL-2/IRFIM-1:dlCarFrqEut=21000
...    LNCEL-2/IRFIM-1:intFrBCList:startInterPci=0
...    LNCEL-3/IRFIM-1:dlCarFrqEut=21000
...    LNCEL-3/IRFIM-1:intFrBCList:startInterPci=0
...    LNCEL-3/IAFIM-1:intrFrBCList:startIntraPci=120
...    LNCEL-3/IAFIM-1:intrFrNCList:physCellIdNcl=0
...    LNCEL-3/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...    LNBTS/CATMPR-1:inactivityTimerCatM=60
...    LNBTS/CATMPR-1:cpInactivityTimerCatM=60
...    LNBTS/CATMPR-1:raPreGrCSizeCatM=7
...    LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=70
...    LNBTS/LNCEL/CATMCEL-0:cellReSelPrioCatM=7
...    LNCEL-1:tac=33
...    LNCEL-2:tac=34
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB4
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB4
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB5
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...    LNCEL-1/CATMCEL-0/CATMIRFIM-1:dlCarFrqEut=1500
@{PARAMS_FOR_EARFCN}
...    LNCEL/LNCEL_FDD-0:ulChBw=3 MHz
...    LNCEL/LNCEL_FDD-0:dlChBw=3 MHz
@{PARAMS_FOR_CB006768}
...    LNCEL/LNCEL_FDD-0:maxNumActUE=100
...    LNCEL:dlsDciCch=DCI format 1A
...    LNBTS/CATMPR-1:maxNumActDrbCatM=75
...    LNCEL:inactivityTimer=100
...    delete:LNCEL/LNHOX-1
...    LNCEL:redBwRbUlConfig:redBwMaxRbUl=15
...    LNCEL/CATMCEL-0:dlsUsePartPrbCatM=sf0 and sf5 used as invalid subframe
...    delete:LNCEL-1/CDFIM-1:csfbRegParam1xRtt
...    LNBTS/CATMPR-1:mibRepEnabledCatM=false
...    LNBTS/CATMPR-1:defPagCycCatM=rf32
...    LNBTS/CATMPR-1:siWindowLenCatM=40ms
...    LNCEL/LNCEL_FDD-0:earfcnDL=1400
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=3 MHz
...    LNBTS/CATMPR-1:inactivityTimerCatM=170
...    LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=180

@{delta_para_A_a_1_initial}
...    LNCEL-1/CATMCEL-0:ueCapInfoRequestCatM=true
...    LNCEL-1/CATMCEL-0:actLteMIndicationCatM=false
@{delta_para_A_b_3_initial}
...    LNCEL-1/CATMCEL-0:ueCapInfoRequestCatM=true
...    LNCEL-1/CATMCEL-0:actLteMIndicationCatM=true

*** Test Cases ***
CB006768-A-a_ET_01_01_Enb will Trigger UE Capability Transfer when receive DOWNLINK NAS TRANSPORT
    [Tags]
    Preparation for A-a-01-01
    Set UE1 and MME Parameters Before Register
    CATM UE1 attach and check logs
    Set UE2 and MME Parameters Before Register
    Online disable ueCapInfoRequestCatM
    CATM UE2 attach and check logs
    Release All UEs

CB006768-A-b_ET_01_03_Enb will send UE CAPABILITY INFO INDICATION to MME with LTE-M indication
    [Tags]
    Preparation for A-b-01-03
    Set UE3 and MME Parameters Before Register
    CATM UE3 attach and check logs
    Release All UEs

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=3    id_type=cus
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Preparation for A-a-01-01
    Delta Commission Parameters    ${delta_para_A_a_1_initial}

Online disable ueCapInfoRequestCatM
    Delta Commission Parameters    LNCEL-1/CATMCEL-0:ueCapInfoRequestCatM=false

Set UE1 and MME Parameters Before Register
    Execute Egate Command    ue_mme_param id=1 ue_capa_attach=on
    Execute Egate Command    ue_mme_param id=1 ue_capa_info_req_in_dl_nas=on

Set UE2 and MME Parameters Before Register
    Execute Egate Command    ue_mme_param id=2 ue_capa_attach=on
    Execute Egate Command    ue_mme_param id=2 ue_capa_info_req_in_dl_nas=on

Set UE3 and MME Parameters Before Register
    Execute Egate Command    ue_mme_param id=3 ue_capa_attach=on
    Execute Egate Command    ue_mme_param id=3 ue_capa_info_req_in_dl_nas=on

Preparation for A-b-01-03
    Delta Commission Parameters    ${delta_para_A_b_3_initial}

CATM UE1 attach and check logs
    Expect Message Flow
    ...    MME_1:S1AP_DownlinkNASTransport(UECapabilityInfoRequest eq "requested")
    ...    UE_GROUP_1:RRC_UECapabilityEnquiry
    ...    MME_1:S1AP_UECapabilityInfoIndication(LTE-M-Indication is not present)
    ...    MME_1:S1AP_InitialContextSetupRequest(UERadioCapability is present)
    ...    alias=attach_flow_1    overall_timeout=20
    Execute UEx Command    ue_attach id=1 cell=1 ue_eutra_capabilities=560000008000001000C041440084800157010640
    Flow Occurred As Expected    alias=attach_flow_1

CATM UE2 attach and check logs
    Expect Message Flow
    ...    MME_1:S1AP_DownlinkNASTransport (UECapabilityInfoRequest eq "requested")
    ...    MME_1:S1AP_InitialContextSetupRequest (UERadioCapability is not present)
    ...    UE_GROUP_2:RRC_UECapabilityEnquiry
    ...    MME_1:S1AP_UECapabilityInfoIndication(LTE-M-Indication is not present)
    ...    alias=attach_flow_2    overall_timeout=20
    Expect Message Flow
    ...    UE_GROUP_2:RRC_UECapabilityEnquiry
    ...    UE_GROUP_2:RRC_UECapabilityEnquiry
    ...    alias=attach_flow_3    overall_timeout=20
    Execute UEx Command    ue_attach id=2 cell=1 ue_eutra_capabilities=560000008000001000C041440084800157010640
    Flow Occurred As Expected    alias=attach_flow_2
    ${status}    run keyword and return status    Flow Occurred As Expected    alias=attach_flow_3
    should not be true    ${status}

CATM UE3 attach and check logs
    Expect Message Flow
    ...    MME_1:S1AP_DownlinkNASTransport(UECapabilityInfoRequest eq "requested")
    ...    UE_GROUP_3:RRC_UECapabilityEnquiry
    ...    MME_1:S1AP_UECapabilityInfoIndication (LTE-M-Indication is present)
    ...    MME_1:S1AP_InitialContextSetupRequest(UERadioCapability is present)
    ...    alias=attach_flow_3    overall_timeout=20
    Execute UEx Command    ue_attach id=3 cell=1 ue_eutra_capabilities=560000008000001000C041440084800157010640
    Flow Occurred As Expected    alias=attach_flow_3

