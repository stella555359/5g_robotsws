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
...    MRBTS-1/NRBTS-1:actRanSharing=true

...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1:gNbCuType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=true
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=30
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=60
...    MRBTS-1/NRBTS-1/SNSSAI-1:sd=13714341
...    MRBTS-1/NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-1:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.9
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:trackingAreaDN
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac
...    @{MODIFY_RELATION_ERROR}
@{MODIFY_RELATION_ERROR}
...    delete:NRCELL-2:trackingAreaDN
...    delete:NRCELL-2:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
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
@{Lock_one_AMF}
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Locked
${Update_Cfg_1}    set_gnb id=2 type=external plmn=311:489 s1u=10.0.1.2 x2=10.0.1.2:36422 ng=10.0.1.2 gnb_id=0x1:22
...    daemon=10.0.2.1:22222 xn=10.0.1.2 x2_peers=none amf=1-2
${Update_Cfg_2}    set_cell id=1 gnb=2 tac=788 nrci=0x01 eci=0x000021f tdd_cell=on
...    proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
${Update_Cfg_3}    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.9:38412 region=2 set_id=2 pointer=2


*** Test Cases ***
5GC002478-ET-B002_Verify_the_AMF_reselection_successful_based_on_same_PLMN_successfully_when_original_AMF_inactive
    [Documentation]
    ...    [purpose]it will cover AMF reselection successful based on same PLMN when one NG link lock with RanSharing, meanwhil everify gNB
    ...    and cell state is not change
	[Tags]    QC_60835
    Delta commission parameters    ${Delete_Useless_Cell}
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    Two L3 call is successful
    Lock NG link1 and check
    UE Deregister From GNB

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    ue_count=10
    Comment    Debug Enter Into Egate

Modify Cfg
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    ${Update_Cfg_3}
    Update Cfg    set_qosflow id=1 5qi=8 default=on
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1-2
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    Update Cfg    set_amf_region id=1 tac_list=0,100,258,200,788 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,258,200,788 plmn=311:489,311:402
    update cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=off
    update cfg    amf_ng_setup_param id=2 relative_capacity=100

Check cell state as expected
    [Arguments]    ${operationalState}    ${barringStatus}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=${operationalState}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=${barringStatus}

Two L3 call is successful
    Execute Egate Command    ue_register id=1    NG RM Registered
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1    Initial Context Setup Successful
    Execute Egate Command    ue_change_location id=2 enb=2 cell=1
    Execute Egate Command    ue_register id=2    NG RM Registered
    Execute Egate Command    set_pdu_param ue=2 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=1 nwslice=1 gw=2    Initial Context Setup Successful
    Traffic should be ok    ue_id=1    type=SA
    Traffic should be ok    ue_id=2    type=SA

Lock NG link1 and check
    Check BTS state
    delta commission parameters    ${Lock_one_AMF}
    Object Should Exist    SERVEDAMF-1:ngLinkStatus=Inactive
    Check cell state as expected    operationalState=enabled    barringStatus=unbarred
    Check BTS state    operationalState=onAir
    Wait to check UE state
    Two UEs Should not be Released

Check BTS state
    [Arguments]    ${operationalState}=onAir
    Object Should Exist    NRBTS:operationalState=${operationalState}

Two UEs Should not be Released
    execute egate command    ue_disp id=1 state=ACTIVE     pass_regexp=ACTIVE
    execute egate command    ue_disp id=2 state=ACTIVE     pass_regexp=ACTIVE

UE Deregister From GNB
  Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    detached
  Execute Egate Command    ue_deregister id=2 ue_deregister_type=switch_off    detached

Wait to check UE state
    sleep    5
