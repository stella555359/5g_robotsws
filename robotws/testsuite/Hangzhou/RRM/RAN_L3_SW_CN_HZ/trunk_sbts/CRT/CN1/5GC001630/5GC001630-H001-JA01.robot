*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC001630
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
${GNB_BIP_FLAG}    True
${DEBUG_LOG_LEVEL}    0
${AP_UDPLOG_LEVEL}    1

@{PARAMS_IN_SCF}    @{RanSharing_HO}    @{MultiAMF}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}    @{NRREL}    @{A3_event}

@{RanSharing_HO}
...    NRBTS-1:actRanSharing=true
...    NRBTS:actRanSharingEnh=max_10_PLMNs
...    NRBTS-1:actNgcFlexSaMode=true
...    NRBTS-1:actConflictConfiguration=false
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac

@{MultiAMF}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-3:amfIPAddress=10.0.1.103
...    SERVEDAMF-4:amfIPAddress=10.0.1.104

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3
...    NRPLMN-3:mcc=311
...    NRPLMN-3:mnc=403
...    NRPLMN-3:mncLength=3
...    NRPLMN-4:mcc=311
...    NRPLMN-4:mnc=404
...    NRPLMN-4:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_2}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=100
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-300:fiveGsTac=200
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

@{NRREL}
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{A3_event}
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:absThreshSsbRsrpConsolidation=0
...    NRCELL-1:absThreshSsbRsrqConsolidation=2
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:absThreshSsbRsrpConsolidation=0
...    NRCELL-2:absThreshSsbRsrqConsolidation=2
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3,MRBTS-1/NRBTS-1/NRPLMN-4
${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3
${NRPLMNDNLIST_2}    MRBTS-1/NRBTS-1/NRPLMN-2,MRBTS-1/NRBTS-1/NRPLMN-3,MRBTS-1/NRBTS-1/NRPLMN-4

@{PM_Counters_Check}
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-402:${ATT_INTRA_DU_HO_SA_PLMN}=1
...    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-402:${SUCC_INTRA_DU_HO_SA_PLMN}=1
...    MRBTS-1/NRBTS-1/NRCELL-2/PLMN-PLMN/MCC-311/MNC-402:${ATT_INTRA_DU_HO_SA_PLMN}=1
...    MRBTS-1/NRBTS-1/NRCELL-2/PLMN-PLMN/MCC-311/MNC-402:${SUCC_INTRA_DU_HO_SA_PLMN}=1
...    MRBTS-1/NRBTS-1/NRCELL-2/PLMN-PLMN/MCC-311/MNC-402:${FAI_INTRA_DU_HO_PR_AC_SA_PLMN}=1
...    MRBTS-1/NRBTS-1/NRCELL-2/PLMN-PLMN/MCC-311/MNC-402:${FAI_INTRA_DU_HO_PR_OR_SA_PLMN}=0

${ATT_INTRA_DU_HO_SA_PLMN}    M55145C00301    #The number of intra-frequency intra-DU HO attempts for SA per PLMN-ID
${SUCC_INTRA_DU_HO_SA_PLMN}    M55145C00302    #The number of successful intra-frequency intra-DU HOs for SA per PLMN-ID
${FAI_INTRA_DU_HO_PR_AC_SA_PLMN}    M55145C00303    #The number of intra-freq intra-DU HO prep failures due to Admission Control for SA per PLMN-ID
${FAI_INTRA_DU_HO_PR_OR_SA_PLMN}    M55145C00304    #The number of intra-freq intra-DU HO prep failures due to Other Reasons for SA per PLMN-ID

@{fault_7101}    fault_id=7101    fault_name=gNB CpCell configuration update failure
@{fault_4592}    fault_id=4592    fault_name=BTS Reset Cause    severity=transient

*** Test Cases ***
5GC001630-ET-H001_verify_intra-gNB_HO_for_SA_user_in_shared_gNB_without_PLMN_change
    [Documentation]
    ...    1. This user scenario describes gNB behaviour when intra-gNB handover procedure is performed for SA user in shared gNB
    ...       (NR RAN Sharing is enabled). PLMN ID selected for UE is not changed due to HO procedure.
    ...    2. SA user intra-freq intra-DU handover failed with no resources found in targt cell and counters are updated
    ...    3. Test Case Steps:
    ...       a. set all NG link setup
    ...       b. SA UE2 register and do traffic
    ...       c. UE2 tigger Intra-gnb HO from CELL2 to CELL1
    ...       d. UE2 tigger Intra-gnb HO from CELL1 to CELL2
    ...       e. set Cell1 No Resources and UE2 Tirgger Intra-Frequency Intra-DU HO from CELL2 to CELL1
    ...       f. set AMF2 MISC_unknown_PLMN and reset gNB
    ...       g. SA UE2 re-register
    ...    4. Expected Results:
    ...       a. All NG link is up
    ...       b. UE2 register is successful and traffic should be ok
    ...       c. UE2 HO successful and updated related counters
    ...       d. UE2 HO successful and updated related counters
    ...       e. HO fails due to targt Cell1 No Resources and updated related counters
    ...       f1. AMF2 NGlink rejected once because gNB is not sending all PLMNs on first NGSetupRequest Message sent to AMF2
    ...       f2. AMF2 NGsetuprequest will be sent again and it will succeed. All NGlink is up
    ...       f3. All PLMNs Are Broadcasted In SIB1
    ...       e. UE2 register is successful and traffic should be ok
    [Tags]    QC_47204    EDA-PR549154    EDA-02432695    JA01
    Check All NG links is up
    UE2 Register Successful and traffic ok
    UE2 Tirgger Intra-Freq Intra-DU intra-plmn HO from Cell2 to Cell1
    UE2 Tirgger Intra-Freq Intra-DU intra-plmn HO from Cell1 To Cell2
    UE2 Tirgger Intra-Freq Intra-DU intra-plmn HO Fails Due To Targt Cell1 No Resources
    check counters    ${PM_Counters_Check}
    Tirgger gNB Reset and NGSetupFailure
    UE2 Register Successful and traffic ok
    check wireshark log    ${CURDIR}/a2a_H001/a2a_gNB_reset.ini    name=gnb_reset    wait_string=InitialContextSetupResponse

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=0,100,200 plmn=311:402
    Update Cfg    set_amf_region id=3 tac_list=0,100,200 plmn=311:403
    Update Cfg    set_amf_region id=4 tac_list=0,100,200 plmn=311:404
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=1 name=SimModeAMF2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=3 pointer=1 name=SimModeAMF3
    Update Cfg    set_amf id=4 daemon=10.0.2.1:22222 ng=10.0.1.104:38412 region=4 set_id=4 pointer=1 name=SimModeAMF4
    Update Cfg Param    set_ue simulated id=2 suci=0:311:402:0000:0:0:021645401 enb=2 cell=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-4 default=on ue=all

Check All NG links is up
    FOR    ${amf_id}    IN RANGE    1    5
        object should exist    SERVEDAMF-${amf_id}:ngLinkStatus=Active
    END

UE2 Register Successful and traffic ok
    SA UE Register and PDU Setup    ue_id=2    cmd_regexp=AMF-2:.*NG RM Registered
    Traffic Should Be OK    ue_id=2    type=SA    timeout=10

SA UE Register and PDU Setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table

UE2 Tirgger Intra-Freq Intra-DU intra-plmn HO from Cell2 to Cell1
    ${measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${measid} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=20
    ...    Intra-eNB handover

UE2 Tirgger Intra-Freq Intra-DU intra-plmn HO from Cell1 To Cell2
    ${measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${measid} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=20
    ...    Intra-eNB handover

UE2 Tirgger Intra-Freq Intra-DU intra-plmn HO Fails Due To Targt Cell1 No Resources
    delta commission parameters    NRCELL-1:maxNumOfRrcSA=0
    ${measid}    get nr meas id for specific type and frequency    ue_id=2    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=2 meas_id=${measid} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=20
    ...    fail_regexp=Intra-eNB handover
    #CPUE log: Received cplane_cell::AdmissionResp not OK, result is {Status:notOk, Cause:noFreeCapacity}
    #M55145C00303 update

Tirgger gNB Reset and NGSetupFailure
    stop capture wireshark log
    Execute Egate Command    amf_ng_setup_param id=2 gnb=2 action=force_failure cause=MISC_unknown_PLMN
    Reset Site
    start to capture wireshark log    gnb_reset
#    start to capture ap bip log
    Cells Should Be Onair
#    start to capture gnb bip log
    Check All NG links is up
    Fm Fault Should Be Cleared    ${fault_7101}
    Fm Fault Should Be Raised    ${fault_4592}
