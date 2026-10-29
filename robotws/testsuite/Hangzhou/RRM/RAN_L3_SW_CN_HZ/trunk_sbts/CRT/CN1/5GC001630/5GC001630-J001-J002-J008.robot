*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A     5GC001630
Resource  ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{RanSharing}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}    @{NRREL}    @{event_A3}
...    @{NRDRB}

@{RanSharing}
...    NRBTS-1:actRanSharing=true

...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true
...    delete:NRCELL:configuredEpsTac
...    delete:NRCELL:trackingAreaDN

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=460
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

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

@{event_A3}
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasEnabled=rsrp

@{NRDRB}
...    NRDRB-6:pmCounterGroup=9
...    NRDRB_QCI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-6
...    NRDRB_QCI-5:qciValueList=9

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

${during_stop_traffic}    15s

@{PM_Counters_Check}
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${ATT_INTRA_DU_HO_NSA_PLMN}=1
...    NRCELL-2/PLMN-PLMN/MCC-460/MNC-402:${FAI_INTRA_DU_HO_PR_NSA_PLMN}=1

@{traffic_pmCounterGroup_9}
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_SDU_USDAT_NUM_DL_PLMN}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_SDU_USDAT_NUM_DL_PLMN}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_SDU_USDAT_NUM_UL_PLMN}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_SDU_USDAT_NUM_UL_PLMN}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_VOL_DL_PLMN_QOS_GRP_09}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_VOL_DL_PLMN_QOS_GRP_09}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_VOL_UL_PLMN_QOS_GRP_09}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_VOL_UL_PLMN_QOS_GRP_09}>0

@{traffic_stop_pmCounterGroup_9}
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_SDU_USDAT_NUM_DL_PLMN}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_SDU_USDAT_NUM_DL_PLMN}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_SDU_USDAT_NUM_UL_PLMN}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_SDU_USDAT_NUM_UL_PLMN}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_VOL_DL_PLMN_QOS_GRP_09}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_VOL_DL_PLMN_QOS_GRP_09}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_VOL_UL_PLMN_QOS_GRP_09}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_VOL_UL_PLMN_QOS_GRP_09}=0

@{traffic_pmCounterGroup_6}
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_SDU_USDAT_NUM_DL_PLMN}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_SDU_USDAT_NUM_DL_PLMN}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_SDU_USDAT_NUM_UL_PLMN}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_SDU_USDAT_NUM_UL_PLMN}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_VOL_DL_PLMN_QOS_GRP_06}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_VOL_DL_PLMN_QOS_GRP_06}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_VOL_UL_PLMN_QOS_GRP_06}>0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_VOL_UL_PLMN_QOS_GRP_06}>0

@{traffic_stop_pmCounterGroup_6}
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_SDU_USDAT_NUM_DL_PLMN}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_SDU_USDAT_NUM_DL_PLMN}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_SDU_USDAT_NUM_UL_PLMN}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_SDU_USDAT_NUM_UL_PLMN}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_VOL_DL_PLMN_QOS_GRP_06}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_VOL_DL_PLMN_QOS_GRP_06}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_VOL_UL_PLMN_QOS_GRP_06}=0
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-460/MNC-402:${PDCP_VOL_UL_PLMN_QOS_GRP_06}=0

${ATT_INTRA_DU_HO_NSA_PLMN}    M55145C00111    #The number of intra-frequency intra-DU PS-Cell change attempts for NSA 3x per PLMN-ID
${FAI_INTRA_DU_HO_PR_NSA_PLMN}    M55145C00113    #Nbr of intra-freq intra-DU PSCell change prep failures due resource failure for NSA 3x per PLMN-ID

${PDCP_SDU_USDAT_NUM_DL_PLMN}    M55326C01001    #DL PDCP user data SDUs transmitted per PLMN-ID
${PDCP_SDU_USDAT_NUM_UL_PLMN}    M55326C01002    #UL PDCP user data SDUs received per PLMN-ID
${PDCP_VOL_DL_PLMN_QOS_GRP_09}    M55326C02009    #PDCP SDU user DL data volume per PLMN-ID - QoS Group 09
${PDCP_VOL_UL_PLMN_QOS_GRP_09}    M55326C03009    #PDCP SDU user UL data volume per PLMN-ID - QoS Group 09
${PDCP_VOL_DL_PLMN_QOS_GRP_06}    M55326C02006    #PDCP SDU user DL data volume per PLMN-ID - QoS Group 06
${PDCP_VOL_UL_PLMN_QOS_GRP_06}    M55326C03006    #PDCP SDU user UL data volume per PLMN-ID - QoS Group 06

*** Test Cases ***
5GC001630-ET-J008_Verify_the_Uplane_PM_counters
    [Documentation]
    ...    1. "NR RAN Sharing UP" PM counters M55326C01001 M55326C01002; M55326C02009 in gourp (M55326C02001...M55326C02020);
    ...    M55326C03009 in gourp (M55326C03001...M55326C03020)
    ...    2. Test Case Steps:
    ...         a. NSA UE31/UE32 attach and do traffic
    ...         b. detach all UEs
    ...         c. online modify pmCounterGroup=6
    ...         d. NSA UE31/UE32 register and do traffic
    ...    3. Expected Results:
    ...         a1: UEs attach successful and traffic should be ok
    ...         a2: Update traffic related counters / Update traffic stop related counters
    ...         b: UEs detached successfully
    ...         c: delta commission pmCounterGroup=6
    ...         d1: UEs attach successful and traffic should be ok
    ...         d2: Update traffic related counters / Update traffic stop related counters
    [Tags]    j008    QC_60722
    clear counter files    ${False}
    Attach UEs to target cell and traffic should be ok
    check counters    ${traffic_pmCounterGroup_9}
    check traffic stop counters    ${traffic_stop_pmCounterGroup_9}
    Release Ues    ue_type=all
    delta commission parameters    NRDRB-6:pmCounterGroup=6
    Attach UEs to target cell and traffic should be ok
    check counters    ${traffic_pmCounterGroup_6}
    check traffic stop counters    ${traffic_stop_pmCounterGroup_6}

5GC001630-ET-J001-J002_Verify_NSA_user_intra-frequency_intra-DU_intra-PLMN_PS-Cell_change
    [Documentation]
    ...    1. NSA user intra-freq intra-DU intra-PLMN handover successfully and counters are updated
    ...       NSA user intra-freq intra-DU intra-PLMN handover failed with no resources found in targt cell and counters are updated
    ...    2. Test Case Steps:
    ...         a. NSA UE31/UE32 register to target cell and do traffic
    ...         b. UE31 Intra-Frequency Intra-DU HO To Cell2
    ...         c. online modify Cell1 no resource
    ...         d. UE32 Intra-Frequency Intra-DU HO To Cell1 Failed Due to No Resource
    ...    3. Expected Results:
    ...         a: UE31 attach on cell1 and UE32 attach on cell2 and traffic should be ok
    ...         b1: UE31 Intra-Frequency Intra-DU HO from Cell1 to Cell2 successful
    ...         b2: Update ATT_INTRA_DU_HO_NSA_PLMN counters
    ...         c: delta commission maxNumOfSCellAlloc=0/maxNumOfUsersPerCell=0, Cell1 no resource
    ...         d1: UE32 Intra-Frequency Intra-DU HO from Cell2 to Cell1 failed
    ...         d2: Update FAI_INTRA_DU_HO_PR_NSA_PLMN counters
    [Tags]    j001_j002    QC_60720
    clear counter files    ${False}
    Attach UEs to target cell and traffic should be ok
    UE31 Intra-Frequency Intra-DU HO from Cell1 to Cell2 Successfully
    UE32 Intra-Frequency Intra-DU HO from Cell2 to Cell1 Failed Due to No Resource
    Check Wireshark Log    ${CURDIR}/a2a_J001_J002/a2a.ini    wait_string=SgNBModificationConfirm
    Check Counters    ${PM_Counters_Check}

*** Keywords ***
Modify Cfg
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=9
    ${set_ue31}    catenate    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=311:489:21645400
    ${set_ue32}    catenate    set_ue simulated id=32 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc imsi=460:402:21645401
    Update Cfg    ${set_ue31}
    Update Cfg    ${set_ue32}

NSA UE attach
    [Arguments]  ${ue_id}=31    ${selected_plmn}=311:489    ${target_cells}=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_endc_param id=1 selected_plmn=${selected_plmn}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    UE${ue_id}: Proxy \\(eNB 2 cell ${target_cells}\\) reported successful RA

Attach UEs to target cell and traffic should be ok
    NSA UE attach    ue_id=31    selected_plmn=311:489    target_cells=1
    NSA UE attach    ue_id=32    selected_plmn=460:402    target_cells=2
    traffic should be ok    ue_id=31    type=NSA
    traffic should be ok    ue_id=32    type=NSA

UE31 Intra-Frequency Intra-DU HO from Cell1 to Cell2 Successfully
    ${cmd}    Catenate    ue_measurement_send_nr id=31 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=20
    ${result}    Execute Egate Command    ${cmd}    UE31: Proxy \\(eNB 2 cell 2\\) reported successful RA
    should contain    ${result}    SgNBModificationRequired

UE32 Intra-Frequency Intra-DU HO from Cell2 to Cell1 Failed Due to No Resource
    ${NRCELL1_no_resource}    create list    NRCELL-1:maxNumOfSCellAlloc=0    NRCELL-1:maxNumOfUsersPerCell=0
    delta commission parameters    ${NRCELL1_no_resource}
    ${cmd}    Catenate    ue_measurement_send_nr id=32 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=20
    Execute Egate Command    ${cmd}    fail_regexp=SgNBModificationRequired
    #CPUE log: Received cplane_cell::AdmissionResp not OK, result is {Status:notOk, Cause:noFreeCapacity}
    #M55145C00113 update

check traffic stop counters
    [Arguments]    ${counter_list}
    clear counter files    ${False}
    sleep    ${during_stop_traffic}
    check counters    ${counter_list}