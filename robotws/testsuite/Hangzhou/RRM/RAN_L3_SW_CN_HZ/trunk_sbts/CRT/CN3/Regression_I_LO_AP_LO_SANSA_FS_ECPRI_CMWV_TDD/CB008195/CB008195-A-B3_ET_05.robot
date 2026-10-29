*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-VRF3_8    owner-kexin.zhou
...    CLOUD_5G_I_LO_AP_LO    release-SBTS25R2
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CB008195}
...    @{NRRESOURCEGROUP_PROFILE}
...    @{SNSSAI}
...    @{TAC}
...    @{onlySA}
...    @{CB008225}
...    @{other_resource_reserve}
...    @{limit_maxNumOfRrcSA}
...    @{limit_maxNumOfUsersPerNRCell}


@{CB008195}
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRCELL:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-1:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-1
...    NRCELL-2:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-2
...    NRCELL-3:nrResourceGroupProfileRacDN=NRRESOURCEGROUP_PROFILE-3
...    NRBTS:actAdditionalSliceSupport=true
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min

@{NRRESOURCEGROUP_PROFILE}
#NRRESOURCEGROUP_PROFILE-0 - PLMN1-SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:maxQuota=60
...    NRBTS/NRRESOURCEGROUP_PROFILE-0/NRRESOURCEGROUP-1:racParams:minQuota=0

#NRRESOURCEGROUP_PROFILE-1 - PLMN1-SNSSAI-1,2,3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=50
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=20
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-3|resourceDN=SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=60
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=30

##NRRESOURCEGROUP_PROFILE-2 - PLMN1-SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=80
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=20

#NRRESOURCEGROUP_PROFILE-3 - PLMN1-SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:racParams:maxQuota=80
...    NRBTS/NRRESOURCEGROUP_PROFILE-3/NRRESOURCEGROUP-1:racParams:minQuota=30

@{SNSSAI}
#SNSSAI-1
...    NRBTS/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-1:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-1:sd=13714341

#SNSSAI-2
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-2:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-2:sd=13714342

#SNSSAI-3
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-3:drbInactivityTimerSA=10
...    NRBTS/SNSSAI-3:sd=13714343

@{TAC}
...    NRBTS/TRACKINGAREA-200:fiveGsTac=200
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3

@{CB008225}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:act3gppBL23R1=true
...    NRCELL:ranAC=0
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:maxUeRrcInactTime=20         # ue will release after UE in inactive timeout
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
...    NRBTS:srbInactivityTimerSA=30


@{other_resource_reserve}
...    NRCELL-1:actPriorityAccess=false
...    NRCELL:actEmergencyCall=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRCELL:numOfRadioResReservForTempUse=1
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRCELL:numOfRadioResReservForPa=1

@{limit_maxNumOfRrcSA}
...    NRCELL:maxNumOfRrcSA=10
...    NRBTS/NRCELLGRP-0:maxNumOfRrcCGRPSA=9
...    NRCELL-2:maxNumOfNonGBRBearersSA=8

@{onlySA}
...    NRCELL:cellDepType=SA
...    delete:NRBTS/NRCELL:configuredEpsTac

@{limit_maxNumOfUsersPerNRCell}
...    NRCELL-1:maxNumOfUsersPerNRCell=275
...    NRCELL:maxNumOfUsersPerCell=9
...    NRCELL:maxNumOfCaUsersNRCell=9
...    NRCELL:maxNumOfNrDcSnUsers=9
...    NRCELL:maxNumOfSCellAlloc=9


##supported UE Power Saving's releasePreference-r16
${ue_nr_capabilities}    SEPARATOR=
...    E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700CA8D851AC101434
...    04B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36266B04050D01
...    2CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89BAC10143404B
...    2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB
...    28986801EB608080838778E1C830E0008193C7D54000014000000420E26800000001013454000
...    3804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A5
...    5542C007000B00000004008011AB130001020304050607080B101112131921252627284A052880001080

#check msg
@{Resume_regexp_with_mo_Data}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResume
...    rrcResumeComplete

@{INACTIVE_check}
...    t380
...    NR_RRC_INACTIVE
...    Is INACTIVE

*** Test Cases ***
CB008195-A-B3_ET_05_01_SA non-GBR DRB admission static cell limits check for resumed UE
    [Documentation]
    ...    The test scenario is intended to verify SA UE context admission static cell limits check for resumed UE.
    ...    Test Case Steps:
    ...       Step1. ICS UE2, UE4 at cell1 with default PDU session
    ...             Expected result:UE2, UE4 stays in RRC_CONNECTED state with default PDU session.
    ...       Step2. Wait for drbRrcInactInactivityTimerSA expired
    ...             Expected result:Wait for drbRrcInactInactivityTimerSA expired
    ...       Step3. ICS UE1, UE3, UE5, UE6 at cell1 with default PDU session
    ...             Expected result:UE1, UE3, UE5, UE6 stays in RRC_CONNECTED state with default PDU session.
    ...       Step4. Make UE2 send ResumeRequest1
    ...             Expected result: UE2 stays in RRC_CONNECTED state with default PDU session, within RG dedicated pool
    ...                              (due to no counter mapping to it only message or log can be checked)
    ...       Step5. Make UE4 send ResumeRequest1
    ...             Expected result: UE4 stays in RRC_CONNECTED state with default PDU session, within RG dedicated pool
    ...                              (due to no counter mapping to it only message or log can be checked)
    ...       Step6. SA UE7 (nwslice2) Register and ICS PDU to cell1 (extend step)
    ...             Expected result: UE7 stays in RRC_CONNECTED state with default PDU session, within RG dedicated pool
    ...                              (maxNumOfRrcSA=10, 10*0.3<=slice3<=10*0.6)
    ...       Step7. SA UE8 (nwslice2) Register and ICS PDU (extend step)
    ...             Expected result: UE8 PDU setup failed because RRC connect = 7 > 8*0.8
    ...                              (maxNumOfNonGBRBearersSA=8, 8*0.2<=slice1,2<=8*0.8)
    [Tags]    owner-kexin.zhou
    SA UE Register and ICS PDU    ue_id=2    cell_id=2    nwslice=1
    Wait UE for srbInactivityTimerSA expired
    SA UE Register and ICS PDU    ue_id=4    cell_id=2    nwslice=2
    Wait UE for srbInactivityTimerSA expired
    SA 4UEs Register and ICS PDU
    Trigger UE resume    ue_id=2    cell_id=2
    Trigger UE resume    ue_id=4    cell_id=2
    SA UE Register and ICS PDU    ue_id=7    cell_id=1    nwslice=2
    SA UE Register and ICS PDU fail    ue_id=8    cell_id=2    nwslice=2
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri

Modify Cfg
    Set PDU Session in WTS
    Set AMF config
    Set UE config

Set AMF config
    Update Cfg    set_amf_region id=1 tac_list=100,200,300 plmn=311:489
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2 name=SimModeAMF1
    Update Cfg    amf_ng_setup_param id=1 relative_capacity=10 include_backup_amf_name=on ue_retention=on retention_time=indefinite
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on qos_flows=7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a6 amf=1 qos_flows=7,6,5,4,3,2,1 qos_rules=1,2 ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 amf=1 qos_flows=7,6,5,4,3,2,1 qos_rules=1,2 ue=all

Set PDU Session in WTS
    Update Cfg    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=3 priority=3 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=4 5qi=4 priority=4 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=5 5qi=5 default=on priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=6 5qi=6 priority=6 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=7 5qi=7 priority=7 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2

Set UE config
    Update Cfg    ue_nr_capabilities id=1-9 voice_over_nr=on:on:off
    Update Cfg    ue_param id=1-9 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}

SA 4UEs Register and ICS PDU
    SA UE Register and ICS PDU    ue_id=1    cell_id=2    nwslice=1
    SA UE Register and ICS PDU    ue_id=3    cell_id=2    nwslice=2
    SA UE Register and ICS PDU    ue_id=5    cell_id=2    nwslice=3
    SA UE Register and ICS PDU    ue_id=6    cell_id=2    nwslice=3

SA UE Register and ICS PDU
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${nwslice}=1    ${qos_flow}=5
    ...    ${plmn}=489
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:${plmn} tac_id=200
    Execute Egate Command    ${cmd}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE Register To GNB    ue_id=${ue_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    UE PDU Session Setup    ue_id=${ue_id}    nwslice=${nwslice}

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 5 qfi 1

Trigger UE resume
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${cause}=mo_Data    ${pass_regexp}=${Resume_regexp_with_mo_Data}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}     pass_regexp=${pass_regexp}

Wait UE for srbInactivityTimerSA expired
    Execute Egate Command    Wait UE for srbInactivityTimerSA expired    pass_regexp=${INACTIVE_check}    timeout=31s

SA UE Register and ICS PDU fail
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${nwslice}=1    ${qos_flow}=5
    ...    ${plmn}=489
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:${plmn} tac_id=200
    Execute Egate Command    ${cmd}
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    UE Register To GNB    ue_id=${ue_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    UE PDU Session Setup fail    ue_id=${ue_id}    nwslice=${nwslice}

UE PDU Session Setup fail
    [Arguments]    ${ue_id}=1    ${nwslice}=1
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=${nwslice} gw=${ue_id}
    ...    pass_regexp=RAN radio resources not available