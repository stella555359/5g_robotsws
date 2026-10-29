*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4xAPO_CUS    release-24R2
...               team-SG8    owner-zhiguo.li
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  LNBTS-1:actSelMobPrf=true
...  LNBTS-1:moProfileSelect=combined
...  LNBTS-1:immciAtTauS1RelCauses=nas_normal_release
...  LNBTS-1/MODPR-0:immciAtTau=selected_layers
...  LNBTS-1/MODPR-0:freqLayListImmciAtTau=3100
...  LNBTS-1/MOPR-1:immciAtTau=enabled_layers
...  LNBTS-1/MOPR-1:freqLayListImmciAtTau=3000
...  LNBTS-1/MOPR-2:immciAtTau=disabled
...  LNBTS-1/MOPR-3:immciAtTau=selected_layers
...  LNBTS-1/MOPR-3:freqLayListImmciAtTau=1700,3000
...  LNCEL-2:tac=33
...  LNCEL-2:actImmciAtTau=true
...  LNCEL-2:moPrMappingList:lteNrDualConnectSupport=all|moPrId=1
...  LNCEL-2:moPrMappingList:mnc=3|moPrId=1
...  LNCEL-2:moPrMappingList:spid=1|moPrId=1
...  LNCEL-2:moPrMappingList:spidLast=${EMPTY}|moPrId=1
...  LNCEL-2:moPrMappingList:lteNrDualConnectSupport=EN-DC_not_capable|moPrId=2
...  LNCEL-2:moPrMappingList:mnc=3|moPrId=2
...  LNCEL-2:moPrMappingList:spid=2|moPrId=2
...  LNCEL-2:moPrMappingList:spidLast=${EMPTY}|moPrId=2
...  LNCEL-2:moPrMappingList:lteNrDualConnectSupport=EN-DC_capable|moPrId=3
...  LNCEL-2:moPrMappingList:mnc=3|moPrId=3
...  LNCEL-2:moPrMappingList:spid=2|moPrId=3
...  LNCEL-2:moPrMappingList:spidLast=${EMPTY}|moPrId=3
...  LNCEL-2/LNCEL_FDD-0:earfcnDL=1700
...  LNCEL-2/LNCEL_FDD-0:earfcnUL=19700
...  LNCEL-3:tac=33
...  LNCEL-3:actImmciAtTau=true
...  LNCEL-3:moPrMappingList:lteNrDualConnectSupport=all|moPrId=1
...  LNCEL-3:moPrMappingList:mnc=3|moPrId=1
...  LNCEL-3:moPrMappingList:spid=1|moPrId=1
...  LNCEL-3:moPrMappingList:spidLast=${EMPTY}|moPrId=1
...  LNCEL-3:moPrMappingList:lteNrDualConnectSupport=EN-DC_not_capable|moPrId=2
...  LNCEL-3:moPrMappingList:mnc=3|moPrId=2
...  LNCEL-3:moPrMappingList:spid=2|moPrId=2
...  LNCEL-3:moPrMappingList:spidLast=${EMPTY}|moPrId=2
...  LNCEL-3:moPrMappingList:lteNrDualConnectSupport=EN-DC_capable|moPrId=3
...  LNCEL-3:moPrMappingList:mnc=3|moPrId=3
...  LNCEL-3:moPrMappingList:spid=2|moPrId=3
...  LNCEL-3:moPrMappingList:spidLast=${EMPTY}|moPrId=3
...  LNCEL-3/LNCEL_FDD-0:earfcnDL=1700
...  LNCEL-3/LNCEL_FDD-0:earfcnUL=19700
...  LNCEL-4:tac=33
...  LNCEL-4:actImmciAtTau=true
...  LNCEL-4:moPrMappingList:lteNrDualConnectSupport=all|moPrId=1
...  LNCEL-4:moPrMappingList:mnc=3|moPrId=1
...  LNCEL-4:moPrMappingList:spid=1|moPrId=1
...  LNCEL-4:moPrMappingList:spidLast=${EMPTY}|moPrId=1
...  LNCEL-4:moPrMappingList:lteNrDualConnectSupport=EN-DC_not_capable|moPrId=2
...  LNCEL-4:moPrMappingList:mnc=3|moPrId=2
...  LNCEL-4:moPrMappingList:spid=2|moPrId=2
...  LNCEL-4:moPrMappingList:spidLast=${EMPTY}|moPrId=2
...  LNCEL-4:moPrMappingList:lteNrDualConnectSupport=EN-DC_capable|moPrId=3
...  LNCEL-4:moPrMappingList:mnc=3|moPrId=3
...  LNCEL-4:moPrMappingList:spid=2|moPrId=3
...  LNCEL-4:moPrMappingList:spidLast=${EMPTY}|moPrId=3
...  LNCEL-4/LNCEL_FDD-0:earfcnDL=1700
...  LNCEL-4/LNCEL_FDD-0:earfcnUL=19700
...  LNCEL-5:tac=34
...  LNCEL-5:actImmciAtTau=false
...  LNCEL-5:moPrMappingList:lteNrDualConnectSupport=all|moPrId=1
...  LNCEL-5:moPrMappingList:mnc=3|moPrId=1
...  LNCEL-5:moPrMappingList:spid=1|moPrId=1
...  LNCEL-5:moPrMappingList:spidLast=${EMPTY}|moPrId=1
...  LNCEL-5:moPrMappingList:lteNrDualConnectSupport=EN-DC_not_capable|moPrId=2
...  LNCEL-5:moPrMappingList:mnc=3|moPrId=2
...  LNCEL-5:moPrMappingList:spid=2|moPrId=2
...  LNCEL-5:moPrMappingList:spidLast=${EMPTY}|moPrId=2
...  LNCEL-5/LNCEL_FDD-0:earfcnDL=3000
...  LNCEL-5/LNCEL_FDD-0:earfcnUL=21000
...  LNCEL-6:tac=34
...  LNCEL-6:actImmciAtTau=false
...  LNCEL-6:moPrMappingList:lteNrDualConnectSupport=all|moPrId=1
...  LNCEL-6:moPrMappingList:mnc=3|moPrId=1
...  LNCEL-6:moPrMappingList:spid=1|moPrId=1
...  LNCEL-6:moPrMappingList:spidLast=${EMPTY}|moPrId=1
...  LNCEL-6:moPrMappingList:lteNrDualConnectSupport=EN-DC_not_capable|moPrId=2
...  LNCEL-6:moPrMappingList:mnc=3|moPrId=2
...  LNCEL-6:moPrMappingList:spid=2|moPrId=2
...  LNCEL-6:moPrMappingList:spidLast=${EMPTY}|moPrId=2
...  LNCEL-6/LNCEL_FDD-0:earfcnDL=3000
...  LNCEL-6/LNCEL_FDD-0:earfcnUL=21000
...  LNCEL-7:tac=35
...  LNCEL-7:actImmciAtTau=false
...  LNCEL-7:moPrMappingList:lteNrDualConnectSupport=all|moPrId=1
...  LNCEL-7:moPrMappingList:mnc=3|moPrId=1
...  LNCEL-7:moPrMappingList:spid=1|moPrId=1
...  LNCEL-7:moPrMappingList:spidLast=${EMPTY}|moPrId=1
...  LNCEL-7:moPrMappingList:lteNrDualConnectSupport=EN-DC_not_capable|moPrId=2
...  LNCEL-7:moPrMappingList:mnc=3|moPrId=2
...  LNCEL-7:moPrMappingList:spid=2|moPrId=2
...  LNCEL-7:moPrMappingList:spidLast=${EMPTY}|moPrId=2
...  LNCEL-7/LNCEL_FDD-0:earfcnDL=3000
...  LNCEL-7/LNCEL_FDD-0:earfcnUL=21000
...  LNCEL:inactivityTimer=10
...  LNBTS-1:actIdleLB=false
...  LNBTS-1:actIdleLBCaAware=false
...  LNBTS-1:actIdleLBCaAwareAdv=false
...  LNBTS-1:actIdleLBTM9aware=false
...  LNBTS-1:actIdleLBEnDcAware=false
...  LNBTS-1:actIdleLBNrAware=false
...  LNBTS-1:actB1NrBasedImlb=false
...  LNBTS-1:actB1NrBasedImlb5GSa=false
#...  LNBTS-1/MODPR-0:autoAdapt=true
#...  LNBTS-1/MODPR-0:autoAdaptIMLB=true
@{set_S1RelCauses_immciAtTau}
...  LNBTS-1:immciAtTauS1RelCauses=all_S1_release_causes
...  LNBTS-1/MODPR-0:immciAtTau=enabled_layers
@{recover_S1RelCauses_immciAtTau}
...  LNBTS-1:immciAtTauS1RelCauses=nas_normal_release
...  LNBTS-1/MODPR-0:immciAtTau=selected_layers
${eutra_capabilities}    SEPARATOR=${SPACE}
...  release=15 category=5 supported_bands=1,3,7,28,41 pdcp_sn_extension=on ca_supported_bands=7:a:a+3::a|3:a:a+7::a
...  supported_bands_nr_sa=78 supported_bands_nr=78 extended_lcid=on
...  feature_sets_ul=0 feature_sets_ul_per_cc=ul_256qam_r15
...  feature_sets_dl=0 feature_sets_dl_per_cc=4layer_tm3_tm4
${eutra_nr_capabilities}    type=mrdc supported_bands_combination=7:a:a+n78:a:a&0|3:a:a+n78:a:a&0 fset_comb=eutra|1:1+nr|1:1
${nr_capabilities}    type=nr release=15 supported_bands=78
${RRC_CONN_REL_IMMCI_TAU_IDLE}    M8008C53
@{rtpm_counters}
...    LNCEL-2:${RRC_CONN_REL_IMMCI_TAU_IDLE}=1
...    LNCEL-3:${RRC_CONN_REL_IMMCI_TAU_IDLE}=0
...    LNCEL-4:${RRC_CONN_REL_IMMCI_TAU_IDLE}=1
...    LNCEL-5:${RRC_CONN_REL_IMMCI_TAU_IDLE}=0
...    LNCEL-6:${RRC_CONN_REL_IMMCI_TAU_IDLE}=0
...    LNCEL-7:${RRC_CONN_REL_IMMCI_TAU_IDLE}=0

*** Test Cases ***
CB008656_01_Sending IMMCI in RRCConnectionRelease after TAU procedure
    [Tags]    TC01
    [Documentation]
    ...    TEST SCENARIO:
    ...    1. UEs 1, 4 and 6 are attached to cell-5 and UEs 3 and 5 to cell-6
    ...    2. After some time, MME_1 sends to eNB_1 S1AP:UEContextReleaseCommand for UE_5 with Cause:radioNetwork:user-inactivity
    ...    3. eNB_1 sends to UE_5 RRC:RRCConnectionRelease without IMMCI @ TAU
    ...    4. UE_5 is detached. eNB_1 sends to UE_5 RRC:RRCConnectionRelease without IMMCI @ TAU, as Cause in S1AP:
    ...       UEContextReleaseCommand is 'nas:detach'
    ...    5. UEs 1, 3, 4 and 6 go to idle mode
    ...    6. UE_1 is moved to area of cell-2. TAU procedure is executed. eNB_1 sends to UE_1 RRC:RRCConnectionRelease
    ...       with IMMCI @ TAU container, which is included in IdleModeMobilityControlInfo and composed of
    ...       t320 equal to LNCEL-2.t320 (min180) and freqPriorityListEutra containing
    ...       carrierFreq equal to LNCEL-2.earfcnDL (1700) and cellReselectionPriority equal to 7. This is the result
    ...       of UE_1 being mapped to MOPR-1, where immciAtTau = enabled_layers
    ...    7. UE_3 is moved to area of cell-3. TAU procedure is executed. eNB_1 sends to UE_3 RRC:RRCConnectionRelease
    ...       without IMMCI @ TAU container. This is the result of UE_3 being mapped to MOPR-2, where immciAtTau = disabled
    ...    8. UE_4 is moved to area of cell-4. TAU procedure is executed. eNB_1 sends to UE_4 RRC:RRCConnectionRelease
    ...       without IMMCI @ TAU container. This is the result of UE_4 being mapped to MODPR, whre immciAtTau = selected_layers
    ...       and freqLayListImmciAtTau contains 3100, while LNCEL-4.earfcnDL = 1700
    ...    9. UE_6 is moved to area of cell-7. TAU procedure is initiated but failes because MME_1 sends to eNB_1 S1AP:DLNASTransport
    ...       with TAU reject and Cause: 'iilegal UE'. eNB_1 sends to UE_6 RRC:RRCConnectionRelease without IMMCI @ TAU container
    ...       due to the failed TAU procedure
    ...    10. LNBTS-1.immciAtTauS1RelCauses is changed to 'all_S1_release_causes' and MODPR.immciAtTau is changed to 'enabled_layers'
    ...    11. UE_5 is attached to cell-4
    ...    12. UE_5 goes to idle mode
    ...    13. UE_5 is detached. eNB_1 sends to UE_5 RRC:RRCConnectionRelease with IMMCI @ TAU container,
    ...        which is included in IdleModeMobilityControlInfo and composed of
    ...        t320 equal to LNCEL-4.t320 (min180) and freqPriorityListEutra containing
    ...        carrierFreq equal to LNCEL-4.earfcnDL (1700) and cellReselectionPriority equal to 7. This is the result of
    ...        UE_5 being mapped to MODPR, where immciAtTau = enabled_layers, and LNBTS-1.immciAtTauS1RelCauses being
    ...        set to all_s1_release_causes
    ...    14. Verify that counter M8008C53 is incremented only in cells 2 and 4
    Start Rtpm Counter
    UE5 Attach with Mo-Signaling And Release Wo IMMCI
    UE1 UE3 UE4 UE6 Attach Then Enter Idle Mode
    UE1 UE3 UE4 UE6 Start TAU Then Detach
    Configure Enb    ${set_S1RelCauses_immciAtTau}
    UE5 Attach Again And Release With IMMCI
    Check Rtpm Counters    ${rtpm_counters}
    [Teardown]    Recover Enb    ${recover_S1RelCauses_immciAtTau}

CB008656_02_delay of S1AP UEContextReleaseCommand during TAU
    [Tags]    TC02
    [Documentation]
    ...    TEST SCENARIO:
    ...    1. Attach UE_11 to cell-5 and wait until UE enters IDLE mode
    ...    2. Move UE_11 to area of cell-2 with different TA
    ...    3. Verify that UE starts TAU by sending RRC: RRC CONNECTION REQUEST message with Cause value mo-signalling
    ...    4. Verify that eNB_1 sends to MME_1 S1AP:INITIAL UE MESSAGE with TAU request
    ...    5. Verify that eNB_1 receives S1AP: DL NAS TRANSPORT message from MME_1 with SPID: 1
    ...    6. Verify that eNB_1 sends to UE_1 RRC: DL INFORMATION TRANSFER message
    ...    7. Verify that eNB_1 does not receive S1AP: UE CONTEXT RELEASE COMMAND for 60s
    ...    8. Verify that eNB_1 sends to MME_1 S1AP: UE CONTEXT RELEASE REQUEST with Cause:radioNetwork:released-due-to-eutran-generated-reason
    ...    9. Verify that after 5s eNB sends to UE_1 RRC: RRC CONNECTION RELEASE without IMMCI @ TAU container
    UE11 Attach Then Enter Idle Mode
    Configure MME Timer
    UE11 Start TAU Then Detach
    [Teardown]    Recover MME Timer

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=9CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=30    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=10.0.1.2    id_type=real
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,s1,x2 on
    Execute Egate Command    ue_mme_param id=1,5,6,11 spid=1 include_spid_in_dlnas=true
    Execute Egate Command    ue_mme_param id=3 spid=2 include_spid_in_dlnas=true

Modify Yaml
    Update Yaml    EPC/MME_POOL_AREA/1    tac_list: '33,34'
    Add Yaml    EPC/MME_POOL_AREA
    ...    - {id: 2, plmn: '262:04', mmegi: 2, tac_list: '33,34'}
    Update Yaml    BASE_STATIONS/1/cells/5    tac: 34    
    Update Yaml    BASE_STATIONS/1/cells/6    tac: 34
    Update Yaml    BASE_STATIONS/1/cells/7    tac: 35
    FOR    ${ue_id}    IN RANGE    1    16
        Update Yaml    UEs/UE_sets/${ue_id}
        ...    mcc: 262
        ...    mnc: 04
        ...    category: 5
        ...    capability: ${eutra_capabilities}
        ...    capability_mrdc: ${eutra_nr_capabilities}
        ...    capability_nr: ${nr_capabilities}
    END

UE5 Attach with Mo-Signaling And Release Wo IMMCI
    Expect Message Flow
    ...    UE_GROUP_5:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_5:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (carrierFreq eq 3000))
    ...    UE_GROUP_5:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    UE_GROUP_5:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_5:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    alias=UE5_flow    overall_timeout=30
    Execute Uex Command    ue_attach id=5 cell=6
    Sleep    2
    Execute Egate Command    ue_s1_ctx_release id=5 cause_rnl=user_inactivity
    Sleep    2
    Execute Uex Command    ue_detach id=5
    Flow Occurred As Expected    alias=UE5_flow

UE1 UE3 UE4 UE6 Attach Then Enter Idle Mode
    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_1:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (carrierFreq eq 3000))
    ...    UE_GROUP_1:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    UE_GROUP_3:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_3:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (carrierFreq eq 3000))
    ...    UE_GROUP_3:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    UE_GROUP_4:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_4:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (carrierFreq eq 3000))
    ...    UE_GROUP_4:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    UE_GROUP_6:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_6:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (carrierFreq eq 3000))
    ...    UE_GROUP_6:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    alias=UE1346_flow    overall_timeout=30
    Execute Uex Command    ue_attach id=1 cell=5
    Execute Uex Command    ue_attach id=3 cell=6
    Execute Uex Command    ue_attach id=4 cell=5
    Execute Uex Command    ue_attach id=6 cell=5
    Flow Occurred As Expected    alias=UE1346_flow

UE1 UE3 UE4 UE6 Start TAU Then Detach
    Expect Message Flow
    ...    UE_GROUP_1:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_1:RRC_RRCConnectionRelease (carrierFreq eq 1700 and cellReselectionPriority eq 7)
    ...    UE_GROUP_1:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_1:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    UE_GROUP_3:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_3:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    UE_GROUP_3:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_3:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    UE_GROUP_4:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_4:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    UE_GROUP_4:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_4:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    UE_GROUP_6:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_6:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    alias=UE1346_tau_flow    overall_timeout=30
    Run Keyword And Ignore Error    Execute Uex Command    ue_change_location id=1 enb=1 cell=2
    Run Keyword And Ignore Error    Execute Uex Command    ue_change_location id=3 enb=1 cell=3
    Run Keyword And Ignore Error    Execute Uex Command    ue_change_location id=4 enb=1 cell=4
    Run Keyword And Ignore Error    Execute Uex Command    ue_change_location id=6 enb=1 cell=7
    Execute Uex Command    ue_detach id=1
    Execute Uex Command    ue_detach id=3
    Execute Uex Command    ue_detach id=4
    Flow Occurred As Expected    alias=UE1346_tau_flow

UE5 Attach Again And Release With IMMCI
    Expect Message Flow
    ...    UE_GROUP_5:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_5:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    alias=UE5_idle_flow    overall_timeout=30
    Execute Uex Command    ue_attach id=5 cell=4
    Flow Occurred As Expected    alias=UE5_idle_flow
    Expect Message Flow
    ...    UE_GROUP_5:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_5:RRC_RRCConnectionRelease (carrierFreq eq 1700 and cellReselectionPriority eq 7)
    ...    alias=UE5_detach_flow    overall_timeout=30
    Execute Uex Command    ue_detach id=5
    Flow Occurred As Expected    alias=UE5_detach_flow

UE11 Attach Then Enter Idle Mode
    Expect Message Flow
    ...    UE_GROUP_11:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_11:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (carrierFreq eq 3000))
    ...    UE_GROUP_11:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    alias=UE11_flow    overall_timeout=30
    Execute Uex Command    ue_attach id=11 cell=5
    Flow Occurred As Expected    alias=UE11_flow

UE11 Start TAU Then Detach
    Expect Message Flow
    ...    UE_GROUP_11:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq "release-due-to-eutran-generated-reason")
    ...    UE_GROUP_11:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    alias=UE11_tau_flow    overall_timeout=70
    Execute Uex Command    ue_change_location id=11 enb=1 cell=2
    Flow Occurred As Expected    alias=UE11_tau_flow
    Execute Egate Command    mme_timer T_UeCtxReleaseCommandDelay=0s
    Expect Message Flow
    ...    UE_GROUP_11:RRC_RRCConnectionRequest (establishmentCause eq "mo-Signalling")
    ...    UE_GROUP_11:RRC_RRCConnectionRelease (idleModeMobilityControlInfo is not present)
    ...    alias=UE11_detach_flow    overall_timeout=30
    Execute Uex Command    ue_detach id=11
    Flow Occurred As Expected    alias=UE11_detach_flow

Configure Enb
    [Arguments]    ${param}
    Delta Commission Parameters    ${param}

Recover Enb
    [Arguments]    ${param}
    Delta Commission Parameters    ${param}
    Common Test Teardown And Stop Capture Logs

Configure MME Timer
    Execute Egate Command    mme_timer T_UeCtxReleaseCommandDelay=80s

Recover MME Timer
    Execute Egate Command    mme_timer T_UeCtxReleaseCommandDelay=0s
    Common Test Teardown And Stop Capture Logs
