*** Settings ***
Documentation
...    Suite documentation
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-L3CN3_SG2    owner-yili.chen@nokia-sbell.com
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    STATE_CONFIGURED    RAN_5G    release-5G21A

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{amf_list}    1    2    3    4
@{sctp_enb_list}    1    11    12
${AP_BIP_FLAG}  True
${GNB_BIP_FLAG}  True
@{PARAMS_IN_SCF}    @{multi_AMF}    @{sctpTimeRetry}    @{barringTimer}
@{multi_AMF}
...    MRBTS-1/NRBTS-1:actRanSharing=true
...    MRBTS-1/NRBTS-1:actRanSharingEnh=max_10_PLMNs
...    MRBTS-1/NRBTS-1:actNgcFlexSaMode=true
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3,MRBTS-1/NRBTS-1/NRPLMN-4
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-210
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-3,MRBTS-1/NRBTS-1/NRPLMN-4
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:configuredEpsTac=4580
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-5,MRBTS-1/NRBTS-1/NRPLMN-6
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-3:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-3:mnc=403
...    MRBTS-1/NRBTS-1/NRPLMN-3:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-4:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-4:mnc=404
...    MRBTS-1/NRBTS-1/NRPLMN-4:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-5:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-5:mnc=405
...    MRBTS-1/NRBTS-1/NRPLMN-5:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-6:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-6:mnc=406
...    MRBTS-1/NRBTS-1/NRPLMN-6:mncLength=3
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:amfIPAddress=10.0.1.102
...    MRBTS-1/NRBTS-1/SERVEDAMF-3:amfIPAddress=10.0.1.103
...    MRBTS-1/NRBTS-1/SERVEDAMF-4:amfIPAddress=10.0.1.104
...    MRBTS-1/NRBTS-1/TRACKINGAREA-210:fiveGsTac=210
...    MRBTS-1/NRBTS-1:ngInducedCellDeactDelayTimer=10
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL-2:trackingAreaDN
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:configuredEpsTac=4580
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-5,MRBTS-1/NRBTS-1/NRPLMN-6
@{sctpTimeRetry}
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=239
@{barringTimer}
...    MRBTS-1/NRBTS-1:waitForRecovBeforeCellBarringTimer=10
...    MRBTS-1/NRBTS-1:shutdownNoX2TrafficTmr=1
# OnlineParam for NG lock
@{Nglink_lock}
...    SERVEDAMF-1:administrativeState=Locked
...    SERVEDAMF-2:administrativeState=Locked
...    SERVEDAMF-3:administrativeState=Locked
...    SERVEDAMF-4:administrativeState=Locked
# OnlineParam for NG unlock
@{Nglink_UNlock}
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:administrativeState=Unlocked
...    SERVEDAMF-3:administrativeState=Unlocked
...    SERVEDAMF-4:administrativeState=Unlocked

${UE5_NR_Capa}
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C0203014002A36266B04050D012CB2898183D6C10101
...    070EF1C39061C00103278FAB80027800E0009E00001809B01301C01C020227B09801800140E0A00E0600F007000683E0000000000000E54D00
...    0100000965950034AAA82807000B000000040080118B130001020304050607080B101112131921252627284A0
${UE5_RESULT}    Initial Context Setup Failure
${UE5_RESULT2}    cause RAN failure in radio interface procedure
#Description': 'supportedBandListNR:n77,supportedBandCombinationList:no,appliedFreqBandListFilter:n78,n77'


${UE6_NR_Capa}
...    SEPARATOR=
...    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A36266B04050D012CB2898183D6C101010
...    70EF1C39061C00103278FAB80027800E0009E0000841C4C000000006026C04C07007008089EC260060005038280381803C01C001A0F80000000
...    00000394B40004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${UE6_RESULT}    Initial Context Setup Failure
${UE6_RESULT2}    cause RAN radio resources not available
#Description': 'supportedBandListNR:n77,supportedBandCombinationList:n77,appliedFreqBandListFilter:n78,n77,supportedBandwidthDL fr1:mhz80'},

*** Test Cases ***
CB007077-ET-A005_Verify_X2_link_unavailable_as_no_x2_traffic cell_is_changed_from_mixed_to_SA
    [Documentation]    Verify NG link unavailable as SCTP failure then X2 lock cell is deactive
    ...    1. Verify cell status and L3 call when change the mixed mode cell from mixed operational mode to NSA
    ...    operational mode only, all the associated NG links sctp are down, but at least one X2 link is available
    ...    2. Verify cell status and L3 call when all the associated NG links are down and all X2 link down.
    ...    3. Verify cell status and L3 call when NG recover.
    ...    4, Verify cell status and L3 call when X2 recover.
    ...    CB007077-A-ET005    & CB007077-A-ET005/009/012    CNI-60420
    [Teardown]    Common Test Setup And Stop To Capture Logs On 7077
    [Tags]    QC_47231
    Case Precondition
    X2 SCTP Down And Check
    Ng lock And Check
    Recover x2 And Check
    Recover Ng and Check

CB007077-ET-A007_Verify_NG_link_unavailable_as_SCTP_failure_then_X2_lock_cell_is_deactive
    [Documentation]    Verify NG link unavailable as SCTP failure then X2 lock cell is deactive
    ...    1. Verify cell status and L3 call when change the mixed mode cell from mixed operational mode to NSA
    ...    operational mode only, all the associated NG links sctp are down, but at least one X2 link is available
    ...    2. Verify cell status and L3 call when all the associated NG links are down and all X2 link down.
    ...    3. Verify cell status and L3 call when NG recover.
    ...    4, Verify cell status and L3 call when X2 recover.
    ...    5GC007077-A-007    5GC007077-A-001    5GC007077-A-03    5GC007077-A-010
    [Tags]    QC_47232
    Case Precondition
    Ng Down And Check
    X2 Lock And Check
    Ng Recover And Check
    X2 Recover And Check
*** Keywords ***
#common suite keyword
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri  ue_count=15
#    Debug Enter Into Egate

Common Test Setup And Stop To Capture Logs On 7077
    Delta Commission Parameters    ${Nglink_unlock}
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    ${V1}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.137 enb_id_macro=0x12347 daemon=$CONTAINER_IP:$EDAEMON_PORT
    ...    x2=10.0.1.138 x2u=10.0.1.139 type=simulated x2_peers=none
    ${V2}    catenate
    ...    set_cell id=11 enb=11 eci=0x1234701 pci=4:2 tac=222 proxy=$CONTAINER_IP:12220 earfcn=2000:20000
    ...    tdd_cell=on mandatory_for_activation=off
    ${V3}    catenate
    ...    set_enb id=12 plmn=311:489 s1=10.0.1.147 enb_id_macro=0x12348 daemon=$CONTAINER_IP:$EDAEMON_PORT
    ...    x2=10.0.1.148 x2u=10.0.1.149 type=simulated x2_peers=none
    ${V4}    catenate
    ...    set_cell id=12 enb=12 eci=0x1234801 pci=5:2 tac=222 proxy=$CONTAINER_IP:12221 earfcn=2000:20000
    ...    tdd_cell=on mandatory_for_activation=off
    Update Cfg    ${V1}
    Update Cfg    enb_param id=11 drb_id_begin=6 endc_capable_qci=9
    Update Cfg    ${V2}
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    Update Cfg    ${V3}
    Update Cfg    enb_param id=12 drb_id_begin=9 endc_capable_qci=9
    Update Cfg    ${V4}
    Update Cfg    enb_endc_param id=12 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    Update Cfg    enb_timer T_ShutdownNoX2TrafficTimer=none
    Update Cfg    mme_pool_area id=2 mmegi=2 plmn=311:405 tac_list=200,777,111,222,444,333,210
    Update Cfg    mme_pool_area id=3 mmegi=3 plmn=311:406 tac_list=200,777,111,222,444,333,210
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,200,210,258,788 plmn=311:402
    Update Cfg    set_amf_region id=3 tac_list=0,100,200,210,258,788 plmn=311:403
    Update Cfg    set_amf_region id=4 tac_list=0,100,200,210,258,788 plmn=311:404
    Update Cfg    set_amf id=1 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF_NG_ADDR:38412 region=1 set_id=2 pointer=2 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF2_NG_ADDR:38412 region=2 set_id=2 pointer=2 name=SimModeAMF2
    Update Cfg    set_amf id=3 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF3_NG_ADDR:38412 region=3 set_id=2 pointer=2 name=SimModeAMF3
    Update Cfg    set_amf id=4 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF4_NG_ADDR:38412 region=4 set_id=2 pointer=2 name=SimModeAMF4
    Update Cfg    set_amf id=5 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF5_NG_ADDR:38412 region=5 set_id=2 pointer=2 name=SimModeAMF5
    Update Cfg    set_amf id=6 daemon=$SERVER_IP:$EDAEMON_PORT ng=$AMF6_NG_ADDR:38412 region=6 set_id=2 pointer=2 name=SimModeAMF6
#common keyword
Case Precondition
    x2 link setup
    sa ue register and pdu setup    ue_id=1
    traffic should be ok    ue_id=1    type=SA
    nsa ue register and ENDC setup    ue_id=16
    traffic should be ok    ue_id=16    type=NSA
    register ue with ue_cap    ue_id=5
    register ue with ue_cap    ue_id=6

register ue with ue_cap
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE${ue_id}_NR_Capa}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered    timeout=20s
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=${UE${ue_id}_RESULT}
    Should Contain    ${ret1}    ueCapabilityEnquiry
    Should Contain    ${ret1}    ueCapabilityInformation
    Should Contain    ${ret1}    ${UE${ue_id}_RESULT2}

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${ue_id}    ${cmd_pdu_regexp}

nsa ue register and ENDC setup
    [Arguments]    ${ue_id}=16    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity

SA UE attach failed
    [Arguments]    ${ue}=1
    ${cmd}    Catenate    ue_register id=${ue}
    Execute Egate Command    ${cmd}    pass_regexp=UE${ue}: detached

NSA UE call failed
    [Arguments]    ${ue}=1
    ${cmd1}    Catenate    ue_attach id=${ue}
    Execute Egate Command    ${cmd1}    pass_regexp=UE IS ACTIVE
    ${cmd2}    Catenate    ue_dc_enb_start ue=${ue} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    Execute Egate Command    ${cmd2}    pass_regexp=no active gNB-X2 link

SA UE detach and OFF
    [Arguments]    ${ue}=1
    ${cmd1}    Catenate    ue_deregister id=${ue}
    Execute Egate Command    ${cmd1}
    ${cmd2}    Catenate    ue_disp id=${ue}
    Wait Until Keyword Succeeds    3min    10s    Execute Egate Command
    ...    ${cmd2}    pass_regexp=OFF    timeout=10s

NSA UE detach and OFF
    [Arguments]    ${ue}=1
    ${cmd1}    Catenate    ue_detach id=${ue}
    Execute Egate Command    ${cmd1}
    ${cmd2}    Catenate    ue_disp id=${ue}
    Wait Until Keyword Succeeds    3min    10s    Execute Egate Command
    ...    ${cmd2}    pass_regexp=OFF    timeout=10s

Ng Down And Check
    amf1 ng down    ${amf_list}
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=barred
    Check ue status    ue=16    status=ACTIVE
    nsa ue register and ENDC setup    ue_id=17
    traffic should be ok    ue_id=17    type=NSA
    SA UE attach failed    ue=2

amf1 ng down
    [Arguments]    ${amf_list}
    FOR    ${amf}    IN    @{amf_list}
        ${cmd1}    Catenate    link_drop link=ng by=amf:${amf} to=gnb:2 msg_type=abort
        Execute Egate Command    ${cmd1}
    END

X2 sctp down
    FOR    ${enb}    IN    @{sctp_enb_list}
        ${cmd1}    Catenate    link_drop link=x2 by=enb:${enb} to=gnb:2 msg_type=abort
        Execute Egate Command    ${cmd1}
    END

Check ue status
    [Arguments]    ${ue}=1    ${status}=ACTIVE
    ${cmd1}    Catenate    ue_disp id=${ue}
    Wait Until Keyword Succeeds    3min    10s    Execute Egate Command
    ...    ${cmd1}    pass_regexp=${status}    timeout=10s

x2 link setup
    Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=is up
    Execute Egate Command    enb_x2_link_up enb=11 target=2    pass_regexp=is up
    Execute Egate Command    enb_x2_link_up enb=12 target=2    pass_regexp=is up

#teststep keyword
X2 Lock And Check
    ${LTEENB_1}   object should exist   LTEENB:ipAddr=10.0.1.12
    ${LTEENB_2}   object should exist   LTEENB:ipAddr=10.0.1.138
    ${LTEENB_3}   object should exist   LTEENB:ipAddr=10.0.1.148
    Delta commission parameters    ${LTEENB_1}:x2LinkLock=locked
    Delta commission parameters    ${LTEENB_2}:x2LinkLock=locked
    Delta commission parameters    ${LTEENB_3}:x2LinkLock=locked
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=disabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=unbarred
    NSA UE detach and OFF    ue=16
    NSA UE detach and OFF    ue=17
    NSA UE call failed    ue=16

Ng Recover And Check
    Wait Until Keyword Succeeds    10min    10s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    Wait Until Keyword Succeeds    10min    10s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active
    Wait Until Keyword Succeeds    10min    10s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-3:ngLinkStatus=Active
    Wait Until Keyword Succeeds    10min    10s    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-4:ngLinkStatus=Active
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=unbarred
    Cells Should Be Onair    check_sib=${True}
    sa ue register and pdu setup    ue_id=2
    traffic should be ok    ue_id=2    type=SA
    NSA UE call failed    ue=17

X2 Recover And Check
    ${LTEENB_1}   object should exist   LTEENB:ipAddr=10.0.1.12
    ${LTEENB_2}   object should exist   LTEENB:ipAddr=10.0.1.138
    ${LTEENB_3}   object should exist   LTEENB:ipAddr=10.0.1.148
    Delta commission parameters    ${LTEENB_1}:x2LinkLock=unlocked
    Delta commission parameters    ${LTEENB_2}:x2LinkLock=unlocked
    Delta commission parameters    ${LTEENB_3}:x2LinkLock=unlocked
    x2 link setup
    Object Should Exist    ${LTEENB_1}:x2LinkStatus=available
    Object Should Exist    ${LTEENB_2}:x2LinkStatus=available
    Object Should Exist    ${LTEENB_3}:x2LinkStatus=available
    NSA UE detach and OFF    ue=16
    nsa ue register and ENDC setup    ue_id=16
    traffic should be ok    ue_id=16    type=NSA
    sa ue register and pdu setup    ue_id=1
    traffic should be ok    ue_id=1    type=SA

X2 SCTP Down And Check
    X2 sctp down
    Object Should Exist    MRBTS-1/NRBTS-1/LTEENB-0:x2LinkStatus=unavailable
    Object Should Exist    MRBTS-1/NRBTS-1/LTEENB-1:x2LinkStatus=unavailable
    Object Should Exist    MRBTS-1/NRBTS-1/LTEENB-2:x2LinkStatus=unavailable
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=unbarred
    Check ue status    ue=1    status=ACTIVE
    sa ue register and pdu setup    ue_id=2
    traffic should be ok    ue_id=2    type=SA
    NSA UE detach and OFF    ue=16
    NSA UE call failed    ue=16
    sleep    60s    #wait for x2LinkReestabTmr timed out and CPIF delete ENB MOC

Ng lock And Check
    Delta Commission Parameters    ${Nglink_lock}
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-3:ngLinkStatus=Inactive
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-4:ngLinkStatus=Inactive
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=disabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=unbarred
    SA UE attach failed    ue=3
    NSA UE detach and OFF    ue=16
    NSA UE call failed    ue=16

Recover x2 And Check
    x2 link setup
    Object Should Exist    MRBTS-1/NRBTS-1/LTEENB-0:x2LinkStatus=available
    Object Should Exist    MRBTS-1/NRBTS-1/LTEENB-1:x2LinkStatus=available
    Object Should Exist    MRBTS-1/NRBTS-1/LTEENB-2:x2LinkStatus=available
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=barred
    NSA UE detach and OFF    ue=16
    nsa ue register and ENDC setup    ue_id=16
    traffic should be ok    ue_id=16    type=NSA
    SA UE attach failed   ue=3

Recover Ng and Check
    Delta Commission Parameters    ${Nglink_unlock}
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-3:ngLinkStatus=Active
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-4:ngLinkStatus=Active
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:operationalState=enabled
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-1:barringStatus=unbarred
    sa ue register and pdu setup    ue_id=1
    traffic should be ok    ue_id=1    type=SA
