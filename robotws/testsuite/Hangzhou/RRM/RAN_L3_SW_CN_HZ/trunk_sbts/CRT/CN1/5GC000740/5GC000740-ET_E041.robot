*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...               owner-HuiBo.Miao    release-5G20A
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:amfIPAddress=10.0.1.1
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.102
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
...    MRBTS-1/NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-1:sd=13714341
...    MRBTS-1/NRBTS-1/SNSSAI-1:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/SNSSAI-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-3:sd=13714343
...    MRBTS-1/NRBTS-1/SNSSAI-3:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS-1/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=5min
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=true

*** Test Cases ***
5GC000740-ET-E041_Verify_NG-C_link_with_AMF_is_re-established_after_NG_Full_Reset_AMF_Initiated_for_uplink_NGAP_UE-associated_message_to_send
    [Documentation]
    ...    1. This case was designed to verify AMF Initiated NG Full Reset procedure.
    ...    2. This case was designed to verify the AMF selection after UE rrc reestablishment.
    [Tags]    5GC000740-C-ET041    QC_47209
    Update AMF Parameters ET-E041
    Check BackupAMF
    Act RRC Reestablishment viaRRCSetup
    UE1 Register To AMF1 With registered_amf With nwslice And Pdu Setup Without nwslice
    AMF1 Was Selected Again By Gnb After RRC Reestablishment
    UE2 Register To AMF2 Without registered_amf With nwslice And Pdu Setup Without nwslice
    AMF2 Re-established After Trigger NG Full Reset
    release ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    ${match_string}    Create List    AMF-1: AMF - IP:10.0.1.2 NG link is Up    AMF-2: AMF - IP:10.0.1.2 NG link is Up
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=${match_string}
    execute egate command    sim_trace amf=1,2 protocol=ng on

Modify Cfg
    update cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1 name=SimModeAMF1
    update cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=1 pointer=2 name=SimModeAMF2
    update cfg    set_backup_amf main=1 backup_amfs=2
    update cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=on
    update cfg    amf_ng_setup_param id=2 relative_capacity=100

Make Sure AMF Active
    wait until keyword succeeds    1 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    wait until keyword succeeds    1 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Update AMF Parameters ET-E041
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 guami=311:489-1:1:1 backup_amf=SimModeAMF2 nwslice=1,2 relative_capacity=50
    ...    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,3 relative_capacity=100 amfi=1:1:2
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2
    Make Sure AMF Active

Check BackupAMF
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:guAMI:backupAmfName=SimModeAMF2

Act RRC Reestablishment viaRRCSetup
    delta commission parameters    MRBTS-1/NRBTS-1:rrcReestabTypeSA=viaRRCSetup

Set Registered AMF To Ue
    [Arguments]    ${ue_id}=1    ${registered_amf}=${EMPTY}
    execute egate command    ue_nr_rrc_param_setup id=${ue_id} registered_amf=${registered_amf}

Register Ue With nwslice
    [Arguments]    ${ue_id}=1    ${nwslice}=${EMPTY}    ${pass_regexp}=NG RM Registered
    execute egate command    ue_register id=${ue_id} nwslice=${nwslice}    pass_regexp=${pass_regexp}

Setup PDU Session Without nwslice
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${EMPTY}
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} gw=${gw}    ${pass_regexp}

UE1 Register To AMF1 With registered_amf With nwslice And Pdu Setup Without nwslice
    Set Registered AMF To Ue    ue_id=1    registered_amf=311:489|1:1:1
    Register Ue With nwslice    ue_id=1    nwslice=1,3
    Setup PDU Session Without nwslice    ue_id=1    pdu=1    gw=1    pass_regexp=AMF-1: Initial Context Setup Successful

AMF1 Was Selected Again By Gnb After RRC Reestablishment
    execute egate command    ue_rrc_reestablish id=1 gnb=2 cell=1    AMF-1: Initial Context Setup Successful

UE2 Register To AMF2 Without registered_amf With nwslice And Pdu Setup Without nwslice
    Set Registered AMF To Ue    ue_id=2    registered_amf=none
    Register Ue With nwslice    ue_id=2    nwslice=1,3
    Setup PDU Session Without nwslice    ue_id=2    pdu=1    gw=2    pass_regexp=AMF-2: Initial Context Setup Successful

UE3 Register To AMF2 Without registered_amf With nwslice And Pdu Setup Without nwslice
    Set Registered AMF To Ue    ue_id=3    registered_amf=none
    Register Ue With nwslice    ue_id=3    nwslice=1,3
    Setup PDU Session Without nwslice    ue_id=3    pdu=1    gw=3    pass_regexp=AMF-2: Initial Context Setup Successful

AMF2 Re-established After Trigger NG Full Reset
    Stop Capture BTS UdpLogs
    Stop Capture Wireshark Log
    Start To Capture BTS UdpLogs    ngreset
    Start To Capture Wireshark Log    ngreset
    execute egate command    link_ng_reset by=amf:2    Received NG Reset Acknowledge from GNB-2
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active
    UE3 Register To AMF2 Without registered_amf With nwslice And Pdu Setup Without nwslice
    Stop Capture BTS UdpLogs    ngreset
    file should contain strings    ${SAVE LOG DIRECTORY}${/}btslog_ngreset.LOG    Finished bulk release
    Check WireShark Log    a2a_ini_file=${CURDIR}${/}A2A_ET-E041${/}a2a_ngreset.ini    name=ngreset
    ...    wait_string=NGResetAcknowledge::1