*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC000740
Resource    ../../../../resources/DevHZ5_resource.robot


Documentation    Suite description
...   author:      Yuhua Zhu
...   contact:     yuhua.zhu@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     5GC000740


*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{5GC000740_flag}    @{MultiAMF}    @{PLMN}    @{SNSSAI}    @{TRACKINGAREA}    @{timer}

@{5GC000740_flag}
...    NRBTS-1:actNgcFlexSaMode=true

@{MultiAMF}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-2:administrativeState=Unlocked

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{SNSSAI}
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:sst=1
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:sst=1
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-3:administrativeState=Unlocked
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:sst=1
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3

@{timer}
...    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=239
...    delete:NRBTS-1:ngInducedCellDeactDelayTimer

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1

@{PM_Counters}
...    NRCELL-1:${NNGCC_INIT_UE_MSG_SENT}=12
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_RECD}=12
...    NRCELL-1:${NNGCC_UE_CTXT_STP_RESP_SENT}=12

${NNGCC_INIT_UE_MSG_SENT}    M55125C00001    #Number of INITIAL UE MESSAGE sent
${NNGCC_UE_CTXT_STP_REQ_RECD}    M55125C02501    #Number of INITIAL CONTEXT SETUP REQUEST received
${NNGCC_UE_CTXT_STP_RESP_SENT}    M55125C02502    #Number of INITIAL CONTEXT SETUP RESPONSE sent

@{PM_Counters_5GC000638}
...    NRBTS-1:${NG_CU_RESET_REQ_SENT}=2
...    NRBTS-1:${NG_CU_RESET_ACK_RCV}=2

${NG_CU_RESET_REQ_SENT}    M55119C00011    #Number of NGAP:NG Reset messages sent by gNB-CU
${NG_CU_RESET_ACK_RCV}    M55119C00014    #Number of NGAP:NG Reset Acknowledge messages received by gNB-CU

@{fault_7312}    fault_id=7312    fault_name=NgGnbInitFullReset    severity=transient    #This fault is no longer used due to PR757429
@{fault_7303}    fault_id=7303    fault_name=F1 SCTP endpoint in CU

*** Test Cases ***
5GC000740-ET-C01-C02-C03-C04-C05_Verify_default_AMF_is_selected_when_UE_sends_RRC_setup_complete
    [Documentation]    In this case the UE provides no 5G-S-TMSI nor registeredAMF nor the requested NSSAI. The AMF selection will rely on AMF
    ...    default information set in NIDD.
    ...    1. Amf1 will be selected as it's default amf
    ...       The 'default' AMF can be configured on SCF, and this parameter 'default' can be set for every AMF
    ...    2. Amf1 will be selected as it's default amf but capacity is 0
    ...       If AMF1 is the only one AMF that selected by gnb, it will be used even AMF's capacity is 0
    ...    3. Amf2 will be selected as amf1's capacity is 0
    ...       One AMF's capacity is 0, and another AMF's capacity is not 0), the AMF that capacity is not 0 will be used finally
    ...    4. The probability of selecting AMF1 is greater than AMF2 as its capacity is greater
    ...       If gnb selected 2 AMFs and both of these AMF's capacity is not 0, the AMF with bigger capacity will have more chance to be used
    ...    5. No amf will be selected as all capacities are 0
    ...       If gnb selected 2 AMFs, but both of these AMF's capactity is 0, the UE will be released by gnb fianally
    [Tags]    QC_60745    5GC000740-C-ET001    5GC000740-C-ET002    5GC000740-C-ET003    5GC000740-C-ET004    5GC000740-C-ET005
    Clear Counter Files    ${False}
    Online Modify AMF to Default    amf1_default=true    amf2_default=false
    AMF Config update    amf1_cap=0    amf2_cap=100
    AMF1 will be selected due to it is the default AMF even AMF1 capacity is 0
    Online Modify AMF to Default    amf1_default=true    amf2_default=true
    AMF2 will be selected due to AMF1 capacity is 0 when all AMFs is default
    AMF Config update    amf1_cap=100    amf2_cap=15
    Register UE Repeatedly And Compare The Probability Of AMF    nwslice=none
    No amf will be selected as all capacities are 0
    Check Counters    ${PM_Counters}

5GC000740-ET-C06-C07-C08-C09-C10-C36-C38_Verify_the_S-NSSAI_matched_AMF_is_selected_when_UE_sends_RRC_setup_complete
    [Documentation]    In this case the UE provides no 5G-S-TMSI nor registeredAMF but the requested NSSAI
    ...    1. slice matched AMF1 will be selected, even if cap is 0
    ...    2. no AMF will be selected as all capacities are 0 but all slices matched
    ...    3. the probability of selecting AMF1 is greater than AMF2 as its capacity is greater with same slice
    ...    4. default AMF2 will be selected when no slice matches
    ...    5. no AMF will be selected as syntex error exist: protocol errors on registeredAMF and guami
    ...    6. no AMF will be selected as syntex error exist with 5G-S-TMSI: protocol errors on ng-5G-S-TMSI
    [Tags]    QC_60752    5GC000740-C-ET006    5GC000740-C-ET007    5GC000740-C-ET008    5GC000740-C-ET009    5GC000740-C-ET010
    ...    5GC000740-C-ET036    5GC000740-C-ET038
    Check All NG links is up
    Online Modify AMF to Default    amf1_default=true    amf2_default=true
    Select AMF based on requested S-NSSAI
    No amf will be selected as all capacities are 0 but all slices matched
    AMF Config update    amf1_cap=100    amf1_nwslice=1,2,3    amf2_cap=10    amf2_nwslice=1,2,3
    Register UE Repeatedly And Compare The Probability Of AMF    nwslice=1,2,3
    Online Modify AMF to Default    amf1_default=false    amf2_default=true
    default AMF2 will be selected when no slice matches
    rrc release due to syntex error

5GC000740-ET-C046_Verify_NG_links_are_active_and_cell_is_active_after_NG_Full_Reset_gNB_initiated_with_multi_AMFs_in_SA_cells_with_SA_call
    [Documentation]    This case was designed to verify the gNB initiated full reset procedure.
    [Tags]    QC_47208    5GC000740-C-ET046    5GC000638
    Clear Counter Files    ${False}
    Online Modify AMF to Default    amf1_default=true    amf2_default=true
    AMF Config update    amf1_cap=50    amf1_nwslice=1,2,3    amf2_cap=100    amf2_nwslice=1,2,3
    Set UE to specific AMF
    register SA UE with all AMFs
    Drop F1 SCTP Trigger Full Reset
    Restore F1 SCTP
    register SA UE with all AMFs
    check wireshark log    ${CURDIR}${/}a2a_C046${/}a2a.ini    wait_string=NGResetAcknowledge::4
    Check Counters    ${PM_Counters_5GC000638}

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=200 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=2 pointer=2 name=SimModeAMF2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 ue=all amf=1-2 default=on
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1-2
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 ue=all amf=1-2

Check All NG links is up
    ${status}    create list    SERVEDAMF-1:ngLinkStatus=Active    SERVEDAMF-2:ngLinkStatus=Active
    object should exist    ${status}

Online Modify AMF to Default
    [Arguments]    ${amf1_default}=true    ${amf2_default}=true
    ${params}    create list    SERVEDAMF-1:defaultAMF=${amf1_default}    SERVEDAMF-2:defaultAMF=${amf2_default}
    delta commission parameters    ${params}

Select AMF based on requested S-NSSAI
    AMF Config update    amf1_cap=0    amf1_nwslice=1,2,3    amf2_cap=100    amf2_nwslice=1,2
    #UE provides no 5G-S-TMSI nor registeredAMF nor the requested NSSAI
    SA UE Register and PDU Setup    ue_id=1    nwslice=none    cmd_pdu_regexp=AMF-2: Initial Context Setup Successful
    Release Ues    ue_type=all
    #UE provides no 5G-S-TMSI nor registeredAMF but the requested NSSAI
    SA UE Register and PDU Setup    ue_id=1    nwslice=1,2,3    cmd_pdu_regexp=AMF-1: Initial Context Setup Successful
    Release Ues    ue_type=all

default AMF2 will be selected when no slice matches
    AMF Config update    amf1_cap=100    amf1_nwslice=1,2    amf2_cap=50    amf2_nwslice=1,3
    SA UE Register and PDU Setup    ue_id=1    nwslice=1,2,3    cmd_pdu_regexp=AMF-2: Initial Context Setup Successful
    Release Ues    ue_type=all

No AMF will be selected as all capacities are 0 but all slices matched
    AMF Config update    amf1_cap=0    amf1_nwslice=1,2,3    amf2_cap=0    amf2_nwslice=1,2,3
    Execute Egate Command    ue_register id=1 nwslice=1,2,3    RRC Release

rrc release due to syntex error
    protocol errors on registeredAMF and without guami
    protocol errors on ng-5G-S-TMSI

protocol errors on registeredAMF and without guami
    Execute Egate Command    ue_register id=1 nwslice=none    AMF-2:.*NG RM Registered
    Execute Egate Command    ue_ng_ctx_release id=1 cause=NAS_normal_release    IS IDLE
    #remove guami_type
    Execute Egate Command    ue_nr_rrc_setup_param id=1 registered_amf=311:489|1:2:2 if_contains=any action=override_ie guami_type=remove
    #ue exit idle failed
    Execute Egate Command    ue_im_exit id=1    RrcRelease is received
    Release Ues    ue_type=all

protocol errors on ng-5G-S-TMSI
    Execute Egate Command    ue_register id=1 nwslice=none    AMF-2:.*NG RM Registered
    Execute Egate Command    ue_nr_rrc_setup_param id=1 registered_amf=311:489|1:2:2 s_tmsi_format=part1:part2:100|50    present together  #both IE
    Execute Egate Command    ue_ng_ctx_release id=1 cause=NAS_normal_release    IS IDLE
    Execute Egate Command    ue_im_exit id=1    RrcRelease is received    #ue exit idle failed

AMF Config update
    [Arguments]    ${amf1_cap}=50    ${amf1_nwslice}=1    ${amf2_cap}=50    ${amf2_nwslice}=1
    ...    ${cmd_regexp}=Received AMF Configuration Acknowledge
    Execute Egate Command    amf_config_update id=1 nwslice=${amf1_nwslice} relative_capacity=${amf1_cap} amfi=1:1:1    ${cmd_regexp}
    Execute Egate Command    amf_config_update id=2 nwslice=${amf2_nwslice} relative_capacity=${amf2_cap} amfi=1:2:2    ${cmd_regexp}

Register UE Repeatedly And Compare The Probability Of AMF
    [Arguments]    ${register_times}=10    ${nwslice}=none
    start rrc log    probability
    FOR    ${index}    IN RANGE    ${register_times}
        SA UE Register and PDU Setup    ue_id=1    nwslice=${nwslice}
        Release Ues    ue_type=all
    END
    get rrc log
    ${AMF1_counter}    Run    grep 'AMF-1: Initial Context Setup Successful' ${TEST_LOG_DIR}/rrc_probability.log | wc -l
    ${AMF2_counter}    Run    grep 'AMF-2: Initial Context Setup Successful' ${TEST_LOG_DIR}/rrc_probability.log | wc -l
    should be true    ${AMF1_counter}>${AMF2_counter}

AMF1 will be selected due to it is the default AMF even AMF1 capacity is 0
    SA UE Register and PDU Setup    ue_id=1    cmd_pdu_regexp=AMF-1: Initial Context Setup Successful
    Release Ues    ue_type=all

AMF2 will be selected due to AMF1 capacity is 0 when all AMFs is default
    SA UE Register and PDU Setup    ue_id=1    cmd_pdu_regexp=AMF-2: Initial Context Setup Successful
    Release Ues    ue_type=all

No amf will be selected as all capacities are 0
    AMF Config update    amf1_cap=0    amf2_cap=0
    Execute Egate Command    ue_register id=1    RRC Release

Set UE to specific AMF
    Execute Egate Command    ue_nr_rrc_param_setup id=1 registered_amf=311:489|1:1:1
    Execute Egate Command    ue_nr_rrc_param_setup id=2 registered_amf=311:489|1:2:2

register SA UE with all AMFs
    SA UE Register and PDU Setup    ue_id=1    cmd_pdu_regexp=AMF-1: Initial Context Setup Successful
    SA UE Register and PDU Setup    ue_id=2    cmd_pdu_regexp=AMF-2: Initial Context Setup Successful

Drop F1 SCTP Trigger Full Reset
    ${sctp_timer}    Create List    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=10    NRSCTP-1:sctpProfile:sctpMaxTimeSctpSetup=30
    ...    NRSCTP-1:sctpProfile:sctpAssocMaxRetrans=7
    delta commission parameters    ${sctp_timer}
    # Trigger lastF1LinkFailure
    Execute Command On Enb    ip6tables -t filter -A OUTPUT -p sctp --dport 38472 -j DROP
    fm fault should be raised    ${fault_7303}    timeout=300
    Sleep    10s

Restore F1 SCTP
    Execute Command On Enb    ip6tables -t filter -D OUTPUT -p sctp --dport 38472 -j DROP
    Cells Should Be Onair
    ${status}    create list    SERVEDAMF-1:ngLinkStatus=Active    SERVEDAMF-2:ngLinkStatus=Active
    object should exist    ${status}
    Sleep    30s

SA UE Register and PDU Setup
    [Arguments]    ${ue_id}=1    ${nwslice}=none    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id} nwslice=${nwslice}    NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    ${cmd_pdu_regexp}
