*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD
...    owner-xianjiao.xie    release-5G20B    team-SG2
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1:gNbCuType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=true
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-3:sd=13714343
...    MRBTS-1/NRBTS-1/SNSSAI-3:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.9
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=false
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:amfIPAddress=10.0.1.10
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:defaultAMF=false
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=30
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=50
...    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=239        #modified
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac
...    @{modify_relation_error}
@{modify_relation_error}
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac

@{Delete_Useless_Cell}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2
...    delete:MRBTS-1/NRBTS-1/NRCELLGRP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
...    NRDU-1:refNrCellGroup=0
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
@{Change_param}
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=180
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpChunkBundlingEnabled=false
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpHeartbeatInterval=20
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpMaxBurst=4
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpMaxPayloadSize=1395
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpMaxTimeSctpSetup=60
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpPathMaxRetrans=7
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpRandomTimeInitSeqRetry=10
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpProfileId=1
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpRtoInit=3000
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpRtoMax=60000
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpRtoMin=1000
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpSackDelay=200
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpSackFreq=2
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpValidCookieLife=60000
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=120
${Update_Cfg_1}    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22
...    daemon=10.0.2.1:22222 xn=10.0.1.2 x2_peers=none amf=1-2
${Update_Cfg_2}    set_cell id=1 gnb=2 tac=788 nrci=0x01 eci=0x000021f tdd_cell=on
...    proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
${Update_Cfg_3}    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.9:38412 region=2 set_id=2 pointer=2
${Update_Cfg_4}    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.10:38412 region=3 set_id=2 pointer=2
${Update_Cfg_5}    set_nwslice id=2 snssai=0x01:0xD143A6 ue=1 amf=1
${Update_Cfg_6}    set_nwslice id=3 snssai=0x01:0xD143A7 ue=1 amf=1
${Update_Cfg_21}    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1
${Update_Cfg_22}    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1 relative_capacity=100 amfi=1:1:1,1:1:2
${Update_Cfg_23}    amf_config_update id=3 name=SimModeAMF3 plmn=311:489 nwslice=1 relative_capacity=10 amfi=1:1:1,1:1:3


*** Test Cases ***
5GC002478-ET-B005_Verify_AMF_reselection_fails_due_to_candidate_AMF_NG-C_link_locked
    [Documentation]
    ...    [purpose]it will cover case 5GC002478-B005 and 5GC002478-B009
    ...    it will cover AMF reselection fails due to candidate AMF NG-C link locked, verify GNB states from Onair to configured and cell state is
    ...    change to "Idle,Disabled,unbarred"; as well cover before NGInducedCellDeactDelayTimer time out, NGlink will result to Active
    [Tags]    QC_60836
    Precondition for case B005
    L3 call is successful
    Lock NG link2 and NG link3
    Set SCTP failure on NGlink1 and check 1st
    Wait SCTP on NGlink and check result
    delta commission parameters    ${Change_param}
    Set SCTP failure on NGlink1 and check 2nd
    Wait SCTP on NGlink and check result
    Deregister UEs
    Check Wireshark Log    ${CURDIR}${/}A2A_B005${/}a2a.ini    name=tocheck    wait_string=UEContextReleaseComplete::1


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    ue_count=10
    Comment    Debug Enter Into Egate

Modify Cfg
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    ${Update_Cfg_3}
    Update Cfg    ${Update_Cfg_4}
    Update Cfg    ${Update_Cfg_5}
    Update Cfg    ${Update_Cfg_6}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1-3
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    set_amf_region id=1 tac_list=0,100,258,200,788 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,258,200,788 plmn=311:489
    Update Cfg    set_amf_region id=3 tac_list=0,100,258,200,788 plmn=311:489
    Update Cfg    set_backup_amf main=1 backup_amfs=2,3
    update cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=off
    update cfg    amf_ng_setup_param id=2 relative_capacity=100
    update cfg    amf_ng_setup_param id=3 relative_capacity=100

Precondition for case B005
    Delta commission parameters    ${Delete_Useless_Cell}
    Cells should be onair    check_sib=${False}
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    Update all amf parameters

Update all amf parameters
    Execute Egate Command    ${Update_Cfg_21}    pass_regexp=Send Amf Configuration Update Command to GNB-2 successful
    Execute Egate Command    ${Update_Cfg_22}    pass_regexp=Send Amf Configuration Update Command to GNB-2 successful
    Execute Egate Command    ${Update_Cfg_23}    pass_regexp=Send Amf Configuration Update Command to GNB-2 successful

L3 call is successful
    Execute Egate Command    ue_register id=1    NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1    Initial Context Setup Successful
    Traffic should be ok    ue_id=1    type=SA

Lock NG link2 and NG link3
    Disable NG Link2        #monitor NG LINK can recover
    Disable NG Link3

Set SCTP failure on NGlink1 and check 1st
    Execute Egate Command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=abort    NG Link Drop
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Inactive
    Check BTS state
    Check cell state as expected    operationalState=enabled    barringStatus=barred
    Wait for GNB state change    wait_time=50
    Check BTS state    operationalState=configured
    UE should be released
    Check cell state as expected    operationalState=disabled    barringStatus=unbarred
    Check Alarm 7304 Raised

Set SCTP failure on NGlink1 and check 2nd
    Stop capture wireshark log
    Start To Capture Wireshark Log    tocheck
    Execute Egate Command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=abort    NG Link Drop
    Check BTS state
    Check Alarm 7304 Raised
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Inactive
    Check cell state as expected    operationalState=enabled    barringStatus=barred
    Wait for UE released


Wait SCTP on NGlink and check result
    Wait for SCTP on NGLINK up
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Active
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    Check BTS state
    Check Alarm 7304 cleared
    L3 call is successful

Check cell state as expected
    [Arguments]    ${operationalState}    ${barringStatus}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=${operationalState}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=${barringStatus}

Check BTS state
    [Arguments]    ${operationalState}=onAir
    Object Should Exist    NRBTS:operationalState=${operationalState}

Wait for GNB state change
    [Arguments]    ${wait_time}
    sleep    ${wait_time}

UE should be released
    execute egate command    ue_disp id=1 state=OFF     pass_regexp=OFF

Check Alarm 7304 Raised
    ${fault7304}    create list    fault_id=7304
    fm fault should be raised    ${fault7304}

Check Alarm 7304 cleared
    ${fault7304}    create list    fault_id=7304
    fm fault should be cleared    ${fault7304}

Deregister UEs
  [Arguments]    ${ue_id}=1
  Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Wait for SCTP on NGLINK up
    sleep    120

Wait for UE released
    sleep    62
    UE should be released
