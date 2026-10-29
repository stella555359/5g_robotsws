*** Settings ***
Suite Setup       Common Suite Setup And Setup 2CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_2xAPO_2CUS    CRT
...               DevHZ5_SG4    release-xL18    owner-bob.song    owner-eric.jiang
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_A3A5}
...    @{PARAMS_FOR_LNADJ}
...    @{PARAMS_FOR_LTE439_V_002_02}
...    @{PARAMS_FOR_LTE1617_RLF_TRIGGERED_HO}
...    LNBTS-1:actMultBearers=true
...    LNBTS-1:actMultGbrBearers=true
...    LNBTS-1:act8EpsBearers=true
...    LNBTS-1:actEnhAcAndGbrServices=true
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-1:actRrcConnNoActivity=true
...    LNCEL-1:t301Guard=100
...    LNCEL-2:t301Guard=100
...    LNCEL-3:t301Guard=100
...    LNCEL-1:inactivityTimer=180
...    LNCEL-2:inactivityTimer=180
...    LNCEL-3:inactivityTimer=180
...    LNCEL-1:qci1ProtectionTimer=180
...    LNCEL-2:qci1ProtectionTimer=180
...    LNCEL-3:qci1ProtectionTimer=180
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnEarfcn=1400
...    LNBTS-1:actCellTrace=true
...    GTPU-1:gtpuN3Reqs=5
...    GTPU-1:gtpuPathSupint=60
...    GTPU-1:gtpuT3Resp=2
...    GTPU-1:sgwIpAddressList:transportNwId=0|sgwIpAddress=10.0.1.31
...    GTPU-1:sgwIpAddressList:transportNwId=0|sgwIpAddress=10.0.1.32
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
@{PARAMS_FOR_LNADJ}
...    LNADJ-254:cPlaneIpAddrCtrl=oamControlled
...    LNADJ-254:cPlaneIpAddr=10.0.1.4
...    LNADJ-254:adjEnbId=2
...    LNADJ-254:plmnId:mcc=262
...    LNADJ-254:plmnId:mnc=3
...    LNADJ-254:plmnId:mncLength=2
...    LNADJ-254:rlfBasedRCRsupported=true
@{PARAMS_FOR_LTE1617_RLF_TRIGGERED_HO}
...    LNBTS:actRLFbasedRCR=true
...    LNBTS:rlfBasedRCRdefault=true
@{PARAMS_FOR_LTE439_V_002_02}
...    LNCEL-1:inactivityTimer=30
...    LNCEL-1:qci1ProtectionTimer=40
...    LNCEL-2:inactivityTimer=30
...    LNCEL-2:qci1ProtectionTimer=40
...    LNCEL-3:inactivityTimer=30
...    LNCEL-3:qci1ProtectionTimer=40
@{PARAMS_IN_SCF_ENB2}
...    @{PARAMS_FOR_A3A5}
...    @{PARAMS_FOR_LTE1617_RLF_TRIGGERED_HO}
...    LNBTS-2:actMultBearers=true
...    LNBTS-2:actMultGbrBearers=true
...    LNBTS-2:act8EpsBearers=true
...    LNBTS-2:actEnhAcAndGbrServices=true
...    LNBTS-2/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-2:actRrcConnNoActivity=true
...    LNCEL-1:t301Guard=100
...    LNCEL-2:t301Guard=100
...    LNCEL-3:t301Guard=100
...    LNCEL-1:inactivityTimer=180
...    LNCEL-2:inactivityTimer=180
...    LNCEL-3:inactivityTimer=180
...    LNCEL-1:qci1ProtectionTimer=180
...    LNCEL-2:qci1ProtectionTimer=180
...    LNCEL-3:qci1ProtectionTimer=180
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnEarfcn=1400
...    LNBTS-2:actCellTrace=true
...    GTPU-1:gtpuN3Reqs=5
...    GTPU-1:gtpuPathSupint=60
...    GTPU-1:gtpuT3Resp=2
...    GTPU-1:sgwIpAddressList:transportNwId=0|sgwIpAddress=10.0.1.32
...    GTPU-1:sgwIpAddressList:transportNwId=0|sgwIpAddress=10.0.1.31
@{rtpm_counters}                             # PM Counters LTE439 SGW relocation with X2 connection:
...    LNCEL-1:LTE_EPS_Bearer:M8006C277=7    # M8006C277:EPC initiated E-RAB releases due to Path Switch
...    LNCEL-1:LTE_EPS_Bearer:M8006C278=2    # M8006C278:EPC initiated QCI1 E-RAB releases due to Path Switch

*** Test Cases ***
LTE439_V_002_02_X2 HO With ERAB Release For Multiple Bearers
    [Documentation]    [2][1.0] CPLN_LTE439_X2_handover_with_ERAB_release_other_cases
    ...    Release of multiple bearers
    [Tags]   
    Start Rtpm Counter
    UE Attach To ENB2 Cell1
    Add 7 Bearers
    Configure Bearers To Be Released In Path Switch Ack
    Perform RLF Triggered HO To ENB1
    Detach UE
    Check Rtpm Counters    ${rtpm_counters}

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Setup 2CUS Env    tl_type=3CELLs_FDD    tl_type_enb2=3CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=10.0.1.2    id_type=real
    Create Enb Alias    alias=ENB_2    enb_id=10.0.1.4    id_type=real
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Update Yaml    UEs/bearer_sets/bearer_set_1/4
    ...    qci: 3
    ...    gbr_ul: 64
    ...    gbr_dl: 64
    ...    mbr_ul: 64
    ...    mbr_dl: 64
    ...    pdn: 1
    Update Yaml    UEs/bearer_sets/bearer_set_1/5
    ...    qci: 4
    ...    gbr_ul: 32
    ...    gbr_dl: 128
    ...    mbr_ul: 32
    ...    mbr_dl: 128
    ...    pdn: 1
    Update Yaml    UEs/bearer_sets/bearer_set_1/10
    ...    qci: 5
    ...    default: on
    ...    pdn: 2
    ...    trf_type: external
    Update Yaml    UEs/bearer_sets/bearer_set_1/11
    ...    qci: 1
    ...    gbr_ul: 31
    ...    gbr_dl: 31
    ...    mbr_ul: 31
    ...    mbr_dl: 31
    ...    pdn: 2
    Update Yaml    EPC/SGW/1
    ...      id: 1
    ...      daemon: '127.0.0.1:10000'
    ...      s1u: '10.0.1.31:2152'
    ...      s11: '10.0.1.33:2152'
    Add Yaml    EPC/SGW
    ...    - id: 2
    ...      type: 'simulated'
    ...      daemon: '127.0.0.1:10000'
    ...      s1u: '10.0.1.32:2152'
    ...      s11: '10.0.1.34:2152'

UE Attach To ENB2 Cell1
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=859FF0300308040E1F8BFC3E17F87E2FF0FC5FDFF367A822040088239920
    ...    ${selected_plmn}=262:03
    ${message}=    catenate
    ...    MME_1:S1AP_InitialContextSetupRequest (
    ...    (UERadioCapability is not present) and
    ...    (E-RABToBeSetupListCtxtSUReq contains (((e-RAB-ID eq 5) and (qCI eq 8)))))
    Expect Message Flow
    ...    ${message}
    ...    UE_GROUP_1:RRC_UECapabilityEnquiry
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=UE_Attach_Flow    overall_timeout=20
    Execute Uex Command    ue_param id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ue_id} enb=2 cell=51 selected_plmn=${selected_plmn}
    Flow Occurred As Expected    alias=UE_Attach_Flow

Add 7 Bearers
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 8 and qCI eq 3))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 9 and qCI eq 6))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 10 and qCI eq 7))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 11 and qCI eq 9))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 12 and qCI eq 1))
    ...    alias=UE_Add_QCIs    overall_timeout=20
    Execute Uex Command    ue_pdn_connect id=1 apn=nokia_2.net
    Execute Uex Command    bearer_add ue=1 qci=1 apn=nokia_1.net gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31    # apn1-qci1-ebi7
    Execute Uex Command    bearer_add ue=1 qci=3 apn=nokia_1.net gbr_ul=64 gbr_dl=128 mbr_ul=64 mbr_dl=128    # apn1-qci3-ebi8
    Execute Uex Command    bearer_add ue=1 qci=6 apn=nokia_1.net    # apn1-qci6-ebi9
    Execute Uex Command    bearer_add ue=1 qci=7 apn=nokia_2.net    # apn1-qci7-ebi10
    Execute Uex Command    bearer_add ue=1 qci=9 apn=nokia_2.net    # apn1-qci9-ebi11
    Execute Uex Command    bearer_add ue=1 qci=1 apn=nokia_2.net gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31    # apn2-qci1-ebi12
    Flow Occurred As Expected    alias=UE_Add_QCIs
    Execute Egate Command    ue_disp id=1
    Execute Egate Command    ue_disp id=1 at=pgw

Configure Bearers To Be Released In Path Switch Ack
    Execute Egate Command    ue_mme_param id=1 ebi_to_be_released=6,7,8,9,10,11,12
    Sleep    5s

Perform RLF Triggered HO To ENB1
    [Arguments]    ${ue_id}=1
    ${ENB2_send}=    catenate
    ...    X2AP_HandoverRequest (e-RABs-ToBeSetup-List contains (
    ...    e-RAB-ID eq 5 and qCI eq 8,
    ...    e-RAB-ID eq 6 and qCI eq 5,
    ...    e-RAB-ID eq 7 and qCI eq 1,
    ...    e-RAB-ID eq 8 and qCI eq 3,
    ...    e-RAB-ID eq 9 and qCI eq 6,
    ...    e-RAB-ID eq 10 and qCI eq 7,
    ...    e-RAB-ID eq 11 and qCI eq 9,
    ...    e-RAB-ID eq 12 and qCI eq 1))
    ${MME1_send}=    catenate
    ...    S1AP_PathSwitchRequestAcknowledge (E-RABList contains (
    ...    e-RAB-ID eq 6,
    ...    e-RAB-ID eq 7,
    ...    e-RAB-ID eq 8,
    ...    e-RAB-ID eq 9,
    ...    e-RAB-ID eq 10,
    ...    e-RAB-ID eq 11,
    ...    e-RAB-ID eq 12))
    Expect Message Flow
    ...    ENB_1:X2AP_RLFIndication
    ...    ENB_2:${ENB2_send}
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    MME_1:${MME1_send}
    ...    ENB_2:X2AP_SNStatusTransfer
    ...    ENB_1:X2AP_UEContextRelease   
    ...    alias=RLF_HO    overall_timeout=20
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} enb=1 cell=1
    sleep    50s    #UE should release due to inactivity during this period
    Flow Occurred As Expected    alias=RLF_HO

Detach UE
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionRelease
    ...    alias=Detach_UE_Flow    overall_timeout=5
    Execute Uex Command    ue_detach id=${ue_id}
    Flow Occurred As Expected    alias=Detach_UE_Flow
