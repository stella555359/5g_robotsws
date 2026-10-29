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
@{PARAMS_IN_SCF_ENB2}
...    @{PARAMS_FOR_LTE1617_RLF_TRIGGERED_HO}
...    LNBTS-2:actMultBearers=true
...    LNBTS-2:actMultGbrBearers=true
...    LNBTS-2:act8EpsBearers=true
...    LNBTS-2:actEnhAcAndGbrServices=true
...    LNBTS-2:actRedirect=disabled
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
...    GTPU-1:gtpuN3Reqs=5
...    GTPU-1:gtpuPathSupint=60
...    GTPU-1:gtpuT3Resp=2
...    GTPU-1:sgwIpAddressList:transportNwId=0|sgwIpAddress=10.0.1.32
...    GTPU-1:sgwIpAddressList:transportNwId=0|sgwIpAddress=10.0.1.31
@{PARAMS_FOR_LTE1617_RLF_TRIGGERED_HO}
...    LNBTS:actRLFbasedRCR=true
...    LNBTS:rlfBasedRCRdefault=true

*** Test Cases ***
LTE439_V_001_02_X2 HO With SGW Relocation For Multiple Bearers
    [Documentation]    [2][1.0] CPLN_LTE439_X2_handover_with_SGW_Relocation_other_cases
    ...    X2 handover with SGW relocation for multiple bearers
    [Tags]
    Enable Inter SGW X2 HO And Assign UE1 To SGW1
    UE Attach And Start DL Data
    Add 7 Bearers And Start Data
    Normal X2 HO To ENB2 Cell1
    Delete QCI3 QCI7 Bearers
    Perform RLF Triggered HO To ENB1
    Stop Data And Detach UE

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Setup 2CUS Env    tl_type=3CELLs_FDD    tl_type_enb2=3CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=10.0.1.2    id_type=real
    Create Enb Alias    alias=ENB_2    enb_id=10.0.1.4    id_type=real
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
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

Enable Inter SGW X2 HO And Assign UE1 To SGW1
    Execute Egate Command    ue_mme_param id=1 sim_inter_sgw_x2_ho=on s1u_ul_ip_change_for_x2_ho=on
    Execute Egate Command    ue_mme_param id=1 sgw_id=1

UE Attach And Start DL Data
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=859FF0300308040E1F8BFC3E17F87E2FF0FC5FDFF367A822040088239920
    ${message}=    catenate
    ...    S1AP_InitialContextSetupRequest (
    ...    (UERadioCapability is not present) and
    ...    (E-RABToBeSetupListCtxtSUReq contains (((e-RAB-ID eq 5) and (qCI eq 8)))))
    Expect Message Flow
    ...    MME_1:${message}
    ...    UE_GROUP_1:RRC_UECapabilityEnquiry
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=UE_Attach_Flow    overall_timeout=20
    Execute Uex Command    ue_param id=${ue_id} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    Execute Uex Command    ue_param id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ue_id} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_Attach_Flow
    Start QCI8 DL Data
    Display UE Status

Start QCI8 DL Data
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} qci=8 apn=nokia_1.net dir=dl protocol=udp Mbps=1
    Execute Egate Command    ue_disp id=${ue_id}

Display UE Status
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_disp id=${ue_id} at=mme
    Execute Egate Command    ue_disp id=${ue_id} at=sgw
    Execute Egate Command    bearer_disp ue=${ue_id} at=mme
    Execute Egate Command    bearer_disp ue=${ue_id} at=sgw
    [Teardown]

Add 7 Bearers And Start Data
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 8 and qCI eq 2))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 9 and qCI eq 3))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 10 and qCI eq 6))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 11 and qCI eq 7))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 12 and qCI eq 9))
    ...    alias=UE_Add_QCIs    overall_timeout=20
    Execute Uex Command    ue_pdn_connect id=1 apn=nokia_2.net
    Execute Uex Command    trf_data_start ue=1 qci=8 apn=nokia_2.net dir=dl protocol=udp size=1250 Mbps=10 stats=true
    Execute Uex Command    bearer_add ue=1 qci=1 apn=nokia_1.net gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31
    Execute Uex Command    bearer_add ue=1 qci=2 apn=nokia_1.net gbr_ul=144 gbr_dl=144 mbr_ul=144 mbr_dl=144
    Execute Uex Command    bearer_add ue=1 qci=3 apn=nokia_1.net gbr_ul=64 gbr_dl=128 mbr_ul=64 mbr_dl=128
    Execute Uex Command    bearer_add ue=1 qci=6 apn=nokia_2.net
    Execute Uex Command    bearer_add ue=1 qci=7 apn=nokia_2.net
    Execute Uex Command    bearer_add ue=1 qci=9 apn=nokia_2.net
    Execute Uex Command    trf_data_start ue=1 qci=1 dir=dl protocol=udp size=1250 Mbps=10 stats=true
    Execute Uex Command    trf_data_start ue=1 qci=2 dir=dl protocol=udp size=1250 Mbps=10 stats=true
    Execute Uex Command    trf_data_start ue=1 qci=3 dir=dl protocol=udp size=1250 Mbps=10 stats=true
    Execute Uex Command    trf_data_start ue=1 qci=6 dir=dl protocol=udp size=1250 Mbps=10 stats=true
    Execute Uex Command    trf_data_start ue=1 qci=7 dir=dl protocol=udp size=1250 Mbps=10 stats=true
    Execute Uex Command    trf_data_start ue=1 qci=9 dir=dl protocol=udp size=1250 Mbps=10 stats=true
    Flow Occurred As Expected    alias=UE_Add_QCIs

Normal X2 HO To ENB2 Cell1
    [Arguments]    ${ue_id}=1
    ${ENB1_send}=    catenate
    ...    X2AP_HandoverRequest (e-RABs-ToBeSetup-List contains (
    ...    e-RAB-ID eq 5 and qCI eq 8 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 6 and qCI eq 8 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 7 and qCI eq 1 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 8 and qCI eq 2 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 9 and qCI eq 3 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 10 and qCI eq 6 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 11 and qCI eq 7 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 12 and qCI eq 9 and transportLayerAddress eq "0b00001010000000000000000100011111"))
    ${MME1_send}=    catenate
    ...    S1AP_PathSwitchRequestAcknowledge (
    ...    E-RABToBeSwitchedULList contains (e-RAB-ID eq 5 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 6 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 7 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 8 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 9 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 10 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 11 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 12 and transportLayerAddress eq "0b00001010000000000000000100011111"))
    Expect Message Flow
    ...    ENB_1:${ENB1_send}
    ...    ENB_2:X2AP_HandoverRequestAcknowledge
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    ENB_2:X2AP_UEContextRelease
    ...    MME_1:${MME1_send}
    ...    alias=Inter_SGW_X2_Handover_1_2    overall_timeout=60
    Execute Uex Command   ue_ho id=1 enb=2 cell=51
    Flow Occurred As Expected    alias=Inter_SGW_X2_Handover_1_2
    sleep    30s    #UE should not release due to inactivity during this period
    Display UE Status

Delete QCI3 QCI7 Bearers
    [Arguments]    ${ue_id}=1
    Execute Uex Command    bearer_del ue=${ue_id} qci=3
    Execute Uex Command    bearer_del ue=${ue_id} qci=7

Perform RLF Triggered HO To ENB1
    [Arguments]    ${ue_id}=1
    ${ENB2_send}=    catenate
    ...    X2AP_HandoverRequest (e-RABs-ToBeSetup-List contains (
    ...    e-RAB-ID eq 5 and qCI eq 8 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 6 and qCI eq 8 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 7 and qCI eq 1 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 8 and qCI eq 2 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 10 and qCI eq 6 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 12 and qCI eq 9 and transportLayerAddress eq "0b00001010000000000000000100011111"))
    ${MME1_send}=    catenate
    ...    S1AP_PathSwitchRequestAcknowledge ( E-RABToBeSwitchedULList contains (
    ...    e-RAB-ID eq 5 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 6 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 7 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 8 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 10 and transportLayerAddress eq "0b00001010000000000000000100011111",
    ...    e-RAB-ID eq 12 and transportLayerAddress eq "0b00001010000000000000000100011111"))
    Expect Message Flow
    ...    ENB_1:X2AP_RLFIndication
    ...    ENB_2:${ENB2_send}
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    MME_1:${MME1_send}
    ...    ENB_2:X2AP_SNStatusTransfer
    ...    ENB_1:X2AP_UEContextRelease
    ...    alias=Inter_SGW_X2_Handover_2_1    overall_timeout=20
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} enb=1 cell=1
    sleep    30s    #UE should not release due to inactivity during this period
    Flow Occurred As Expected    alias=Inter_SGW_X2_Handover_2_1

Stop Data And Detach UE
    [Arguments]    ${ue_id}=1
    Display UE Status
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionRelease
    ...    alias=Detach_UE_Flow    overall_timeout=5
    Execute Uex Command    trf_data_stop ue=${ue_id}
    Execute Egate Command    ue_disp id=${ue_id}
    Execute Uex Command    ue_detach id=${ue_id}
    Flow Occurred As Expected    alias=Detach_UE_Flow
