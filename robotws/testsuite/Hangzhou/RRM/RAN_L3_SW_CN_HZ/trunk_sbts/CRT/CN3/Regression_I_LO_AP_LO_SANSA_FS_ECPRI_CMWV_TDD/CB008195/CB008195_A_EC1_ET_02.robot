*** Settings ***
Documentation
...    author: kang.xiang
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO    team-VRF3_SG8    owner-lola
...    release-SBTS24R3    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CB008195}
...    @{SNSSAI}
...    @{NRRESOURCEGROUP_PROFILE}
...    @{TAC}
...    @{CB008195-A-EC1_ET_02}
@{CB008195}
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-1:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
...    NRCELL-2:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-2:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
...    NRCELL-3:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-3:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
...    NRBTS:actAdditionalSliceSupport=true
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min

@{NRRESOURCEGROUP_PROFILE}
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1

...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=60
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=60

...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=10
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=10

...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:nrResourceList:resourceDN=SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:minQuota=30
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:maxQuota=30

@{SNSSAI}
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-1:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-1:sd=13714341
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-2:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-2:sd=13714342
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-3:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-3:sd=13714343
...    NRBTS:actAdditionalSliceSupport=true
@{TAC}
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
@{CB008195-A-EC1_ET_02}
...    NRCELL-1:cellDepType=SA
...    NRCELL-2:cellDepType=SA
...    NRCELL-3:cellDepType=SA
...    NRCELL-1:maxNumOfRrcSA=100
...    NRCELL-2:maxNumOfRrcSA=100
...    NRCELL-3:maxNumOfRrcSA=100
...    NRCELL-1:maxNumOfSCellAlloc=100
...    NRCELL-2:maxNumOfSCellAlloc=100
...    NRCELL-3:maxNumOfSCellAlloc=100
...    NRDU-1:maxNumOfRrcConUEsPerDU=6
...    @{CB008225}
...    delete:NRCELL:configuredEpsTac
@{CB008225}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:act3gppBL23R1=true
...    NRCELL:ranAC=0
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS:drbRrcInactInactivityTimerSA=30
...    NRBTS:maxUeRrcInactTime=2         # ue will release after UE in inactive timeout
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:outOfConnectedPreference=inactive
...    NRBTS:timerReleasePreferenceProhibit=s5
...    NRBTS:tRanPagingGuard=4
...    NRBTS:t380=10min
...    NRBTS:actPaging=true
...    NRBTS:ranPagingCycle=v32
...    NRBTS:activityNotificationLevelSA=ue

${ue_nr_capabilities}    SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC2200782E0203C127BE7FFFFF800F00C6FBE00050370101F8E0155DF0A3FE2F08762F82087F540A083D951D2206
...    24FAC41E420F081425BE7E57771DF001DDC77C000CC005000742AEF851FF17843B17C1043FAA05041ECA8E9103127D620F2107840A12DF3F3
...    3BB8EF800EEE3BE000660028003A1577C4DFF8BC21D8BE0821FD502820F65474881893EB1079083C205096F9F95DFC7FC0077F1FF00033001
...    4001D00650389A000000C40A83C4D000C2680004C40AC1C4D080004620540E268400033102B070A0200021881507850001828000298810090
...    0A2026C04605000C2508206811B649F0214285B24F810236C93E04085B24F810276C93E042853B649F000160C318C631BFFFE000138036002
...    800301C1401C0C4270070007000603E0488200000041000002208004000004100080000882001004001040020080220800402008410008040
...    188200100C021040020180601B072F2A2B072F2A28060800004B2CA82000032CB2A0800014B2CA02000072CB2801A83D5D2AAAA0F174AA283
...    839804F9BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C0
...    700001400600400C010020808020040200801001C0180180400300A00A01801001C0180380400700A01201802001C0380180800301200A028
...    01041C0080180100300400A0080103801001004002004004010001AB0602072125262728770000000361781C06000601A
${srbInactivityTimerSA}
...    31s
${maxUeRrcInactTime}
...    2min

@{FAULTS_EXCLUDED_CHECKING}    7300

*** Test Cases ***
CB008195-A-EC1_ET_02_01_SA UE RRC connection reject for resumed UE
    [Documentation]
    ...    this case focus on DU level limit: maxNumOfRrcConUEsPerDU
    ...    and it will trigger scaling factor for each cell (5G_CP_ARC_ALG_14406).
    ...       scalingFactor=6/(100+100+100)=0.02
    ...    for cell-1 RG1: ROUNDDOWN(minQuotaResources(‘multicell group type’, ‘resource type’, cellId, resourceGroupId)=60
    ...    then minQuotaResources(‘multicell group type’, ‘resource type’, cellId, resourceGroupId)
    ...    = ROUNDDOWN(minQuotaResources(‘multicell group type’, ‘resource type’, cellId, resourceGroupId)
    ...        x scalingFactor(‘multicell group type’, ‘resource type’))
    ...    =ROUNDDOWN (60*0.02)=1
    ...    for cell-2 RG1 and cell-3 RG1, also reserve 1 RRC in DU level
    [Tags]
    Pre-condition for UEs location
    UE1 use one RRC in DU then released but enter into NR_RRC_INACTIVE
    UE2_3_4_5_6_7 use 6 RRC in DU
    UE1 RRC resume will be reject due to DU RRC limit reach
    Release UEs include inactive UE

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri    ue_count=9
    Execute Egate Command    trace_sim protocol=xn uec=1 amf=1 enb=3 on

Modify Cfg
    Set PDU Session in WTS
    Set AMF config
    Set UE config

Set AMF config
    Update Cfg    set_amf_region id=1 tac_list=100,200,300 plmn=311:489
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2 name=SimModeAMF1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=10 include_backup_amf_name=on ue_retention=on retention_time=indefinite
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=off qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a6 amf=1 default=on qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 amf=1 default=off qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 ue=all

Set PDU Session in WTS
    Update Cfg    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=3 priority=3 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=4 5qi=4 priority=4 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=5 5qi=5 priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=6 5qi=6 priority=6 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=7 5qi=7 default=on priority=7 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=8 5qi=8 priority=8 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=9 5qi=9 priority=9 pci=may_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2

Set UE config
    Update Cfg    ue_nr_capabilities id=1-9 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-9 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}

UE Register To GNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    pass_regexp=UE now in NG RM Regist

Pre-condition for UEs location
    Execute Egate Command    ue_change_location id=1,2,3 enb=2 cell=1
    Execute Egate Command    ue_change_location id=4,5,6 enb=2 cell=2
    Execute Egate Command    ue_change_location id=7 enb=2 cell=3

UE1 use one RRC in DU then released but enter into NR_RRC_INACTIVE
    ${set_ics_param}    catenate     amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...     ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${set_ics_param}
    UE Register To GNB    ue_id=1
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 nwslice=2 gw=1    QoS Routing Table
    sleep    ${srbInactivityTimerSA}

UE2_3_4_5_6_7 use 6 RRC in DU
    UE Register To GNB    ue_id=2
    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=2    QoS Routing Table
    UE Register To GNB    ue_id=3
    Execute Egate Command    ue_pdu_session_setup ue=3 pdu=1 nwslice=1 gw=3    QoS Routing Table
    UE Register To GNB    ue_id=4
    UE Register To GNB    ue_id=5
    UE Register To GNB    ue_id=6
    UE Register To GNB    ue_id=7

UE1 RRC resume will be reject due to DU RRC limit reach
    Execute Egate Command    ue_nr_rrc_resume id=1    rrcReject

Release UEs include inactive UE
    sleep    ${maxUeRrcInactTime}
    Release UEs    ue_type=all
