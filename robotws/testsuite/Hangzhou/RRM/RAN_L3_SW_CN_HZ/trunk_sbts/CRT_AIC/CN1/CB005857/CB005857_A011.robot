*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    vDUCNF00    RAN_5G    RAN_Aic    CRT    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD    team-L3SWCN1_SG14    owner-jun.3.ye    release-5G22R2
Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
#${SNAPSHOT_FLAG}     pass:True,fail:True
#${SOS_REPORT_FLAG}    pass:True,fail:True

@{PARAMS_IN_SCF_CU}    @{5GC005857}    @{MultiAMF}    @{NRPLMNSET_TRACKINGAREA}    @{MultiPLMN}    @{SNSSAI}
...    @{e1setup_timer}

@{PARAMS_IN_SCF_DU1}    @{MultiPLMN}    @{SNSSAI}    @{DU_CELLs}    @{NRPLMNSET_TRACKINGAREA}

@{5GC005857}
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRBTS:actNgcFlexSaMode=true
...    delete:NRCELL:trackingAreaDN
...    NRPMRNL-1:miNrRelReportCu=5min

@{MultiAMF}
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-1:amfIPAddress=10.0.11.1
...    SERVEDAMF-2:administrativeState=Unlocked
...    SERVEDAMF-2:amfIPAddress=10.0.11.2
...    SERVEDAMF-3:administrativeState=Unlocked
...    SERVEDAMF-3:amfIPAddress=10.0.11.3
...    SERVEDAMF-4:administrativeState=Unlocked
...    SERVEDAMF-4:amfIPAddress=10.0.11.4
...    SERVEDAMF-5:administrativeState=Unlocked
...    SERVEDAMF-5:amfIPAddress=10.0.11.5
...    SERVEDAMF-6:administrativeState=Unlocked
...    SERVEDAMF-6:amfIPAddress=10.0.11.6

@{NRPLMNSET_TRACKINGAREA}
...    TRACKINGAREA-1:fiveGsTac=100
...    TRACKINGAREA-1:snssaiList:snssaiDN=${snssaiDNList}
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=TRACKINGAREA-1
...    TRACKINGAREA-2:fiveGsTac=200
...    TRACKINGAREA-2:snssaiList:snssaiDN=${snssaiDNList}
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_2}
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=TRACKINGAREA-2
#SWFH to DC adapt
...    TRACKINGAREA-3:fiveGsTac=280
...    TRACKINGAREA-3:snssaiList:snssaiDN=${snssaiDNList}
...    NRCELL-3/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}
...    NRCELL-3/NRPLMNSET_SA-1:trackingAreaDN=TRACKINGAREA-3
...    NRCELL-4/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}
...    NRCELL-4/NRPLMNSET_SA-1:trackingAreaDN=TRACKINGAREA-3
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{DU_CELLs}
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    delete:NRCELL:configuredEpsTac
...    delete:NRCELL:trackingAreaDN

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=490
...    NRPLMN-2:mncLength=3
...    NRPLMN-3:mcc=311
...    NRPLMN-3:mnc=491
...    NRPLMN-3:mncLength=3
...    NRPLMN-4:mcc=311
...    NRPLMN-4:mnc=492
...    NRPLMN-4:mncLength=3
...    NRPLMN-5:mcc=311
...    NRPLMN-5:mnc=493
...    NRPLMN-5:mncLength=3
...    NRPLMN-6:mcc=311
...    NRPLMN-6:mnc=494
...    NRPLMN-6:mncLength=3

@{SNSSAI}
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:sst=1

@{e1setup_timer}
...    NRBTS-1:e1SetupTimeToWait=10s
...    NRCUUP-1:e1NbSetupRetryForFault=1

${NRPLMNDNLIST}    SEPARATOR=,
...    MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRPLMN-3
...    MRBTS-1/NRBTS-1/NRPLMN-4
...    MRBTS-1/NRBTS-1/NRPLMN-5
...    MRBTS-1/NRBTS-1/NRPLMN-6
${NRPLMNDNLIST_1}    NRPLMN-1,NRPLMN-2,NRPLMN-3
${NRPLMNDNLIST_2}    NRPLMN-1,NRPLMN-2,NRPLMN-4,NRPLMN-5,NRPLMN-6
${snssaiDNList}    MRBTS-1/NRBTS-1/SNSSAI-1

@{lock_amf2}
...    SERVEDAMF-2:administrativeState=Locked

@{lock_amf1_amf3}
...    SERVEDAMF-1:administrativeState=Locked
...    SERVEDAMF-3:administrativeState=Locked

@{unlock_amf1_to_amf3}
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:administrativeState=Unlocked
...    SERVEDAMF-3:administrativeState=Unlocked

@{restart}    cpif    #upue    cpnrt
@{resources_release}    cpif    cpnrt    cpue    #cpcl    cpnb

@{fault_7702}    fault_id=7702    fault_name=E1 Setup Failure Response after retries
${e1setup_retries_expire}    60s

*** Test Cases ***
CB005857-ET-A011_5GC001630-ET-A016_Available_PLMNs_change_and_Cell_barring_status_change_of_two_cells
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This user scenario describes failure scenario for NR RAN Sharing when AMF(s) handling fully one of configured PLMNs becomes unavailable.
    ...    2. Test Case Steps:
    ...       a. after cell on air, lock amf2
    ...       b. lock amf1, amf3
    ...       c. unlock all amf
    ...       d. UEs register with difference AMF
    ...       e. Lock Cell2
    ...       f. Unlock Cell2
    ...    3. Expected Results:
    ...       a: plmn2 not broadcasted in cell 1 and cell 2
    ...       b: cell1 become barred
    ...       c: cell1 become unbarred, AMF1,2,3 broadcasted in Cell 1 and AMF2 broadcasted in Cell2
    ...       d: register with difference AMF. UE1~UE3 register on CELL1. UE4~UE7 register on Cell2
    ...       e: UE4~UE7 detached
    ...       f: UE4~UE7 re-register successful
    [Tags]    QC_46982    EDA-PR727827
    Check all NGlink is up
    Lock AMF1 to AMF3 separately and Check Cells Barring Status
    Unlock AMF1 to AMF3 and Check Cells Barring Status
    Trigger UEs register with difference AMF
    UEs is released After Lock Cell2
    Unlock Cell2 And Re-register UEs
#    Check Wireshark Log Aic    ${CURDIR}${/}a2a_CB005857_A11${/}a2a.ini    wait_string=UEContextReleaseComplete::12
    Kill process and no new active faultid vCU
    Restart Pod and no new active faultid vCU

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    set_amf_region id=1 tac_list=100,200,280 plmn=311:489
    Update Cfg Aic    set_amf_region id=2 tac_list=100,200,280 plmn=311:490
    Update Cfg Aic    set_amf_region id=3 tac_list=100,200,280 plmn=311:491
    Update Cfg Aic    set_amf_region id=4 tac_list=100,200,280 plmn=311:492
    Update Cfg Aic    set_amf_region id=5 tac_list=100,200,280 plmn=311:493
    Update Cfg Aic    set_amf_region id=6 tac_list=100,200,280 plmn=311:494
    Update Cfg Aic    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.11.2:38412 region=2 set_id=1 pointer=1 type=simulated name=SimModeAMF2
    Update Cfg Aic    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.11.3:38412 region=3 set_id=1 pointer=1 type=simulated name=SimModeAMF3
    Update Cfg Aic    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.11.4:38412 region=4 set_id=1 pointer=1 type=simulated name=SimModeAMF4
    Update Cfg Aic    set_amf id=5 daemon=10.0.2.1:22222 ng=10.0.11.5:38412 region=5 set_id=1 pointer=1 type=simulated name=SimModeAMF5
    Update Cfg Aic    set_amf id=6 daemon=10.0.2.1:22222 ng=10.0.11.6:38412 region=6 set_id=1 pointer=1 type=simulated name=SimModeAMF6
    ${set_AMF2}    catenate
    ...    amf_param id=2 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g
    ${set_AMF3}    catenate
    ...    amf_param id=3 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g
    ${set_AMF4}    catenate
    ...    amf_param id=4 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g
    ${set_AMF5}    catenate
    ...    amf_param id=5 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g
    ${set_AMF6}    catenate
    ...    amf_param id=6 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g
    Update Cfg Aic    ${set_AMF2}
    Update Cfg Aic    ${set_AMF3}
    Update Cfg Aic    ${set_AMF4}
    Update Cfg Aic    ${set_AMF5}
    Update Cfg Aic    ${set_AMF6}
    ${set_UE2_PLMN}    catenate
    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:490:0000:0:0:021645401 enb=2 mode=nr cell=1
    ${set_UE3_PLMN}    catenate
    ...    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:491:0000:0:0:021645402 enb=2 mode=nr cell=1
    ${set_UE4_PLMN}    catenate
    ...    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:492:0000:0:0:021645403 enb=2 mode=nr cell=2
    ${set_UE5_PLMN}    catenate
    ...    set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:493:0000:0:0:021645404 enb=2 mode=nr cell=2
    ${set_UE6_PLMN}    catenate
    ...    set_ue simulated id=6 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:494:0000:0:0:021645404 enb=2 mode=nr cell=2
    ${set_UE7_PLMN}    catenate
    ...    set_ue simulated id=7 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:490:0000:0:0:021645405 enb=2 mode=nr cell=2
    Update Cfg Aic    ${set_UE2_PLMN}
    Update Cfg Aic    ${set_UE3_PLMN}
    Update Cfg Aic    ${set_UE4_PLMN}
    Update Cfg Aic    ${set_UE5_PLMN}
    Update Cfg Aic    ${set_UE6_PLMN}
    Update Cfg Aic    ${set_UE7_PLMN}
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-6 default=on ue=all
    Update Cfg Aic    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg Aic    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

Check all NGlink is up
    ${links_status}    create list    SERVEDAMF-1:ngLinkStatus=Active    SERVEDAMF-2:ngLinkStatus=Active    SERVEDAMF-3:ngLinkStatus=Active
    ...        SERVEDAMF-4:ngLinkStatus=Active    SERVEDAMF-5:ngLinkStatus=Active    SERVEDAMF-6:ngLinkStatus=Active
    object should exist in cu    ${links_status}

Lock AMF1 to AMF3 separately and Check Cells Barring Status
    Delta Commission Parameters Cu    ${lock_amf2}
    Delta Commission Parameters Cu    ${lock_amf1_amf3}
    object should exist in cu    NRCELL-1:barringStatus=barred
    object should exist in cu    NRCELL-2:barringStatus=unbarred

Unlock AMF1 to AMF3 and Check Cells Barring Status
    Delta Commission Parameters Cu    ${unlock_amf1_to_amf3}
    object should exist in cu    NRCELL-1:barringStatus=unbarred
    object should exist in cu    NRCELL-2:barringStatus=unbarred

SA UE register and PDU setup
    [Arguments]    ${ue_id}=1    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1     ${cmd_pdu_regexp}

Trigger UEs register with difference AMF
    FOR    ${ue_id}    IN RANGE    1    7
        SA UE register and PDU setup    ue_id=${ue_id}    cmd_pdu_regexp=AMF-${ue_id}: Initial Context Setup Successful
        traffic should be ok    ue_id=${ue_id}    type=SA    timeout=10    thresh=0.8
    END
    SA UE register and PDU setup    ue_id=7    cmd_pdu_regexp=AMF-2: Initial Context Setup Successful
    traffic should be ok    ue_id=7    type=SA    timeout=10    thresh=0.8

UEs is released After Lock Cell2
    Delta Commission Parameters Cu    NRCELL-2:administrativeState=Locked
    Execute Egate Command    disp_ue id=4    OFF
    Execute Egate Command    disp_ue id=5    OFF
    Execute Egate Command    disp_ue id=6    OFF
    Execute Egate Command    disp_ue id=7    OFF

Unlock Cell2 And Re-register UEs
    Delta Commission Parameters Cu    NRCELL-2:administrativeState=Unlocked
    cells should be onair du
    FOR    ${ue_id}    IN RANGE    4    7
        SA UE register and PDU setup    ue_id=${ue_id}    cmd_pdu_regexp=AMF-${ue_id}: Initial Context Setup Successful
        traffic should be ok    ue_id=${ue_id}    type=SA    timeout=10    thresh=0.8
    END
    SA UE register and PDU setup    ue_id=7    cmd_pdu_regexp=AMF-2: Initial Context Setup Successful
    traffic should be ok    ue_id=7    type=SA    timeout=10    thresh=0.8
    release ues    ue_type=all

Stop Wireshark Log
    [Arguments]    ${tag}=none
    Stop To Capture Wireshark Log Vcu    tag=${tag}
    Stop To Capture Wireshark Log Vdu    tag=${tag}

Kill process on vcu
    [Arguments]    ${pod}=none
    ${pod_full_name}    Find Pod Fullname In Aic vCU    ${pod}
    ${container_full_name}    Find Container Fullname In Aic vCU    ${pod}    ${pod}
    execute cmd on vcu    kubectl exec -it ${pod_full_name} -c ${container_full_name} -n ${VCU_NAMESPACE} -- killall bash
    wait until keyword succeeds    5s    1s    execute cmd on vcu    oc get pods -n ${VCU_NAMESPACE} | grep "${pod_full_name}.*s ago"
    Wait All Pods Running Vcu    ${VCU_NAMESPACE}

Kill process and no new active faultid vCU
    FOR    ${pods}    IN    @{resources_release}
        Trigger UEs register with difference AMF
#        Start To Capture Wireshark Log Aic    tag=kill_${pods}
        Kill process on vcu    ${pods}
        cells should be onair du
        Check all NGlink is up
        check no new active faults
        check resources leakage aic
        release ues    ue_type=all
#        Stop Wireshark Log    tag=kill_${pods}
    END

Restart Pod and no new active faultid vCU
    FOR    ${pods}    IN    @{restart}
        Trigger UEs register with difference AMF
#        Start To Capture Wireshark Log Aic    tag=restart_${pods}
        Restart Pod And Check All Pod Is Running In Aic vCU    ${pods}
        sleep    ${e1setup_retries_expire}
        cells should be onair du    timeout=300
        Check all NGlink is up
        check no new active faults
        check resources leakage aic
        Trigger UEs register with difference AMF
        release ues    ue_type=all
#        Stop Wireshark Log    tag=restart_${pods}
    END
