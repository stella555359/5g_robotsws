*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-VRF3_8    owner-Chendong.He
...    CLOUD_5G_I_LO_AP_LO    release-SBTS25R2    STATE_CONFIGURED
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{8195_parameters}
...    @{SA_mode}
...    @{8225_parameters}
...    @{UEAssistanceInformation_para}
...    @{5GC000732}
...    @{5GC000876}

@{5GC000876}
# cell1 RAC parameter
...    NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=275
...    NRCELL-1:maxNumOfRrcSA=5
...    NRCELL-1:maxNumOfSCellAlloc=5
# cell2 RAC parameter
...    NRBTS-1/NRCELLGRP-1:maxNumOfRrcCGRPSA=275
...    NRCELL-2:maxNumOfRrcSA=275
...    NRCELL-2:maxNumOfSCellAlloc=250

@{SA_mode}
...    MRBTS-1/NRBTS-1:gNbCuType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA
...    MRBTS-1/NRBTS-1:x2LinkSupervisionTmr=0
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac

@{8195_parameters}
...    NRBTS:actSliceAwareAdmissionCtrl=true
...    NRCELL-1:sliceAwareAdmissionCtrlEnabled=true
...    NRCELL-2:sliceAwareAdmissionCtrlEnabled=true
...    @{irrelevant_paramaters}
...    NRCELL-1:nrResourceGroupProfileRacDN=MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-1
...    NRCELL-2:nrResourceGroupProfileRacDN=MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:applyCellRacForPrivilegedUE=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=30
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=10
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:minQuota=20
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:applyCellRacForPrivilegedUE=0
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgNsaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2:defaultRgSaList:nrResourceGroupId=1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-1:racParams:minQuota=30
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-2:racParams:minQuota=10
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:nrResourceList:resourceDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:racParams:maxQuota=40
...    NRBTS/NRRESOURCEGROUP_PROFILE-2/NRRESOURCEGROUP-3:racParams:minQuota=20
...    NRBTS/NRPMRNL-1:miNrCellUtilPerNrg=5min
...    @{Slice_config}

@{irrelevant_paramaters}
...    NRCELL-1:actPriorityAccess=false
...    NRCELL-1:actEmergencyCall=false
...    NRCELL-2:actPriorityAccess=false
...    NRCELL-2:actEmergencyCall=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false

@{8225_parameters}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:maxUeRrcInactTime=4     # ue will release after UE in inactive timeout
...    NRBTS:outOfConnectedPreference=idle
...    NRBTS:srbInactivityTimerSA=30
...    NRBTS:t380=10min
...    NRBTS:act3gppBL23R1=true
...    NRCELL:ranAC=0

@{UEAssistanceInformation_para}
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:timerReleasePreferenceProhibit=s5

@{Slice_config}
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST_1}
...    SNSSAI-3:sst=1
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST_1}
...    @{TRACKINGAREA}

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3

@{5GC000732}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:tWaitingRlRecover=4000ms

${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    nextHopChainingCount
...    t380
...    NR_RRC_INACTIVE
...    Is INACTIVE

@{Resume_regexp_with_mo_Data}
...    rrcResumeRequest1
...    resumeCause mo-Data
...    rrcResume
...    rrcResumeComplete
...    rrcReconfigurationComplete
...    pcid:50, scellIdx:0

@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported    

#supported UE Power Saving's releasePreference-r16
${SA_Capa_UAI_Inactive}    SEPARATOR=
...    E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700CA8D851AC101434
...    04B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36266B04050D01
...    2CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89BAC10143404B
...    2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A36276B04050D012CB
...    28986801EB608080838778E1C830E0008193C7D54000014000000420E26800000001013454000
...    3804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A5
...    5542C007000B00000004008011AB130001020304050607080B101112131921252627284A052880001080

@{disable_8195}
...    NRCELL-1:sliceAwareAdmissionCtrlEnabled=false
...    delete:NRCELL-1:nrResourceGroupProfileRacDN

${loop_time}    2

*** Test Cases ***
CB008195-A-B1_ET_02_01_SA RRC connection admission for resumed UE context
    [Documentation]
    ...    The test scenario is intended to verify SA RRC connection admission for resumed UE context.
    ...    2. Configuration
    ...       a.SA,TDD+TDD, CA(band 78+band 78)
    ...    3. Test Case Steps:
    ...       a.Set UE2 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...         And trigger UE2 register to Cell1.
    ...       Expected result:UE2 registers successfully to Cell1.
    ...       b.UE2 wait srbInactivityTimerSA
    ...       Expected result:UE2 release to RRC_INACTIVITE UE Assistance Information.
    ...       c.UE1 and UE3 Register to Cell1.
    ...       Expected result:UE1/3 Register successfully.
    ...       d.UE2 Send ResumeRequest1 to RRC_ACTIVE state
    ...       Expected result: UE2 stay in RRC_connection state
#    ...       e. disable sliceAwareAdmissionCtrlEnable and repeat above steps
#    ...       Expected result:all work and no abnormality.
    [Tags]    owner-chendong.he
    Register UE2 at Cell1
    Wait UE2 for srbInactivityTimerSA expired
    Register UE1 and UE3 at Cell1
    Make UE2 send ResumeRequest1
    Release Ues    ue_type=sa    ue_id=1-3
#    Disable Cell1 sliceAwareAdmissionCtrlEnabled
#    Repeat Above Steps If Need

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=10

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=8 default=on
    Update Cfg    set_qosflow id=2 5qi=7 ue=all
    Update Cfg    set_qosflow id=3 5qi=6 ue=all
    Update Cfg    set_qosflow id=4 5qi=9 ue=all
    Update Cfg    set_qosflow id=5 5qi=5 ue=all
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 ue=all amf=1 default=on
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1 qos_flows=2 default=off
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf=1 qos_flows=3 default=off

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Register UE2 at Cell1
    UE attach with UAI    ue_id=2    target_cell_id=1    plmn=489    tac=200    gw1=2    nwslice1=2    amf_id=1

Register UE5 at Cell2
    UE attach with UAI    ue_id=5    target_cell_id=2    plmn=489    tac=200    gw1=5    nwslice1=2    amf_id=1

Register UE4 Reject at Cell1
    UE attach    ue_id=4    target_cell_id=1    plmn=489    tac=200    gw1=4    nwslice1=1    amf_id=1    pass_regexp=RRC Reject was received

Register UE8 Successfully at Cell2
    UE attach    ue_id=8    target_cell_id=2    plmn=489    tac=200    gw1=8    nwslice1=1    amf_id=1

Wait UE2 for srbInactivityTimerSA expired
    Execute Egate Command    Wait UE2 for srbInactivityTimerSA expired    pass_regexp=${INACTIVE_check}    timeout=31s

Register UE1 and UE3 at cell1
    UE attach    ue_id=1    target_cell_id=1    plmn=489    tac=200    gw1=1    amf_id=1    nwslice1=1
    UE attach    ue_id=3    target_cell_id=1    plmn=489    tac=200    gw1=3    amf_id=1    nwslice1=2

Register UE6 and UE7 at Cell2
    UE attach    ue_id=6    target_cell_id=2    plmn=489    tac=200    gw1=6    amf_id=1    nwslice1=1
    UE attach    ue_id=7    target_cell_id=2    plmn=489    tac=200    gw1=7    amf_id=1    nwslice1=2

Make UE2 send ResumeRequest1
    Trigger UE resume    ue_id=2    cell_id=1    cause=mo_Data    pass_regexp=${Resume_regexp_with_mo_Data}

Make UE5 Reestablish at Cell2
    Execute Egate Command    ue_rrc_reestablish id=5 gnb=2 cell=2 cause=otherFailure    pass_regexp=RRC Reestablishment sucessfully completed

UE attach with UAI
    [Arguments]    ${ue_id}=1    ${target_cell_id}=1    ${plmn}=489    ${tac}=200     ${gw1}=1
    ...    ${nwslice1}=1    ${amf_id}=1    ${pass_regexp}=UE now in NG RM Register
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_UAI_Inactive}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell_id}
    ${set_ics_param}    catenate     amf_ue_ics_param id=${amf_id} core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...     ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:${plmn} tac_id=${tac}   
    Execute Egate Command    ${set_ics_param}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw1} nwslice=${nwslice1}    pass_regexp=${releasePreference_check}

UE attach
    [Arguments]    ${ue_id}=1    ${target_cell_id}=1    ${plmn}=489    ${tac}=200     ${gw1}=1
    ...    ${nwslice1}=1    ${amf_id}=1    ${pass_regexp}=UE now in NG RM Register
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${SA_Capa_UAI_Inactive}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=${pass_regexp}

Trigger UE resume
   [Arguments]    ${ue_id}=1    ${cell_id}=1    ${cause}=mo_Data    ${pass_regexp}=${Resume_regexp_with_mo_Data}    
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause} 
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}     pass_regexp=${pass_regexp}

Online Param Change
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Disable Cell1 sliceAwareAdmissionCtrlEnabled
    Online Param Change    ${disable_8195}

Repeat Above Steps If Need
    Repeat Keyword    ${${loop_time}-1}    Case Repetive Steps

Case Repetive Steps
    Register UE2 at Cell1
    Wait UE2 for srbInactivityTimerSA expired
    Register UE1 and UE3 at Cell1
    Make UE2 send ResumeRequest1
    Release Ues    ue_type=sa    ue_id=1-3