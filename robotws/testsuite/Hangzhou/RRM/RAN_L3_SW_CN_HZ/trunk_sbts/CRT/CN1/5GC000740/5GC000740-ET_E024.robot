*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
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
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:amfIPAddress=10.0.1.103
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:defaultAMF=true
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
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=5min
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=false
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=240
@{PM_Counters_ET-E024}
...    NRCELL-1:NGCFB:${AMF_SELECTION_ATT}=20
...    NRCELL-1:NGCFB:${AMF_SELECTION_SUCC}=20
${AMF_SELECTION_ATT}    M55155C00001
${AMF_SELECTION_SUCC}    M55155C00003

*** Test Cases ***
5GC000740-ET-E024_Verify_AMF_2_more_likely_selected_when_ng_inactive_but_have_2_backupAMF
    [Documentation]    This case is to verify the load balance btween 2 backup AMF when main amf is inactive.
    [Tags]    5GC000740-E-ET024    QC_60775
    [Timeout]    60 min
    clear counter files
    Update AMF Parameters ET-E024
    Set Registered AMF To Ue    registered_amf=311:489|1:2:3
    Inactive AMF1
    Register UE With nwslice Repeatly And Compare
    Check Counters    ${PM_Counters_ET-E024}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    ${match_string}    Create List    AMF-1: AMF - IP:10.0.1.2 NG link is Up    AMF-2: AMF - IP:10.0.1.2 NG link is Up
    ...    AMF-3: AMF - IP:10.0.1.2 NG link is Up
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=${match_string}
    execute egate command    sim_trace amf=1,2,3 protocol=ng on

Modify Cfg
    update cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=1,2,3 name=SimModeAMF1
    update cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=1 name=SimModeAMF2
    update cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=2 pointer=2 name=SimModeAMF3
    update cfg    set_backup_amf main=1 backup_amfs=2,3
    update cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=on
    update cfg    amf_ng_setup_param id=2 relative_capacity=100
    update cfg    amf_ng_setup_param id=3 relative_capacity=10

Make Sure AMF Active
    [Documentation]    sctpWaitTimeInitSeqRetry=240s,sctp reinitialize will start at 4mins after AMF inactive
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-3:ngLinkStatus=Active

Update AMF Parameters ET-E024
    Make Sure AMF Active
    ${amf_config_update}    catenate    amf_config_update id=1 guami=311:489-1:2:1 backup_amf=SimModeAMF2 guami=311:489-1:2:2 backup_amf=SimModeAMF3
    ...    guami=311:489-1:2:3
    execute egate command    ${amf_config_update}    AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=2:2:1
    ...    AMF-2.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=3 name=SimModeAMF3 plmn=311:489 nwslice=1,2,3 relative_capacity=10 amfi=3:2:2
    ...    AMF-3.*Received AMF Configuration Acknowledge from GNB-2
    Make Sure AMF Active

Set Registered AMF To Ue
    [Arguments]    ${ue_id}=1    ${registered_amf}=${EMPTY}
    execute egate command    ue_nr_rrc_param_setup id=${ue_id} registered_amf=${registered_amf}

Inactive AMF1
    execute egate command    link_drop link=ng by=amf:1 to=gnb:2 msg_type=shutdown    All NG links are down
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive

Register UE With nwslice Repeatly And Compare
    [Arguments]    ${ue_id}=1    ${register_times}=20
    set test variable    ${AMF2_count}    0
    set test variable    ${AMF3_count}    0
    FOR    ${index}    IN RANGE    ${register_times}
        ${return}=    execute egate command    ue_register id=${ue_id} nwslice=1,2,3    NG RM Registered
        ${return}=    Remove String    ${return}    \n    \r
        ${AMF2_count}=    evaluate    ${AMF2_count} + "${return}".count('AMF-2: INITIAL UE MESSAGE')
        ${AMF3_count}=    evaluate    ${AMF3_count} + "${return}".count('AMF-3: INITIAL UE MESSAGE')
        execute egate command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE Context Release Complete
    END
    should be true    ${AMF3_count} < ${AMF2_count}
    should be true    ${${AMF3_count}+${AMF2_count}} == 20
