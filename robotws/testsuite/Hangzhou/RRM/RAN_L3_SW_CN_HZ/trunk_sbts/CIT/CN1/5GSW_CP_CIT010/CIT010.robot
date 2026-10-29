*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CIT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G19B    5GC001008    CDRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

${GNB_BIP_FLAG}    True
${DEBUG_LOG_LEVEL}    0
${UTE_WIRESHARK_FLAG}    True
#@{PARAMS_IN_SWCONFIG}    0x10041=5    0x10040=1    0x1003F=1    0x340002=1    0x340006=55328

@{PARAMS_IN_SCF}    @{SNSSAI}    @{TRACKINGAREA}    @{PLMN}

@{SNSSAI}
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{PM_Counters_Check}
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_REQ_SLICE}=1
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${SA_NGBR_DRB_REQ_SLICE}=1
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_SUCC_SLICE}=1
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${SA_NGBR_DRB_SUCC_SLICE}=1
...    last NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${MEAS_PERIOD_NR_PDCP_SLICE}=${60*${PM_COUNTER_INTERVAL[:-3]}}
...    last NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${MEAS_PERIOD_NR_PDCP_SLICE}=${60*${PM_COUNTER_INTERVAL[:-3]}}
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_NUM_UL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_NUM_UL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_VOL_UL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_VOL_UL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_NUM_DL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_NUM_DL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_VOL_DL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_VOL_DL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_CU_SUCC_SLICE}=1
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${SA_NGBR_DRB_CU_SUCC_SLICE}=1
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${NUMBER_OF_SA_SLICE_USERS}=1
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${NUMBER_OF_SA_SLICE_USERS}=1
${SA_NGBR_DRB_REQ_SLICE}    M55149C00002    #The number of non-GBR DRB radio admission requests for SA user, per PLMN, per slice
${SA_NGBR_DRB_SUCC_SLICE}    M55149C00003    #The number of radio admitted non-GBR DRBs for SA user, per PLMN, per slice
${MEAS_PERIOD_NR_PDCP_SLICE}    M55328C00001    #Duration of the measurement period for the NR PDCP Slice
${PDCP_SDU_DATA_NUM_DL_SLICE}    M55328C00002    #DL PDCP SDUs transmitted per Slice per PLMN
${PDCP_SDU_DATA_VOL_DL_SLICE}    M55328C00003    #DL PDCP SDUs transmitted volume per Slice per PLMN
${PDCP_SDU_DATA_NUM_UL_SLICE}    M55328C00004    #UL PDCP SDUs received per Slice per PLMN
${PDCP_SDU_DATA_VOL_UL_SLICE}    M55328C00005    #UL PDCP SDUs received volume per Slice per PLMN
${SA_NGBR_DRB_CU_SUCC_SLICE}    M55149C00020    #Number of non-GBR DRB established on successful PDU session establishment for SA user
${NUMBER_OF_SA_SLICE_USERS}    M55149C00022    #The number of UEs successfully established for SA user per PLMN, per slice

*** Test Cases ***
5GSW-CP-CIT010_Verify_Classical_SA_TDD_cmWave_L3_call_setup_with_2_slices_for_2_PDU_is_successful
    [Documentation]
    ...    1. This user scenario describes Initial Context Setup procedure where AMF requests one or more PDU sessions with slicing.
    ...    And describes PDU Session Resource Setup procedure where AMF requests subsequent PDU session with slicing.
    ...    gNB uses this procedure for DRB and PDU session establishment, SDAP configuration.
    ...    The subsequent PDU session is associated to a different S-NSSAI from previous established PDU session.
    ...    2. Test Case Steps:
    ...         a. SA UE1 register
    ...         b. setup 2 PDU for 2 slice on UE1
    ...         c. verity traffic
    ...    3. Expected Results:
    ...         a: SA UE1 register successful
    ...         b: 2 PDUs are setup on 2 slices successfully (PDU1 setup with ICS, PDU2 setup without ICS)
    ...         c: 2PDU traffic should be ok
    ...    other: UE1 setup 2 PDU session
    ...           pdu1_nwslice1(sd:13714341=d143a5)
    ...           pdu2_nwslice2(sd:13714342=d143a6)
    [Tags]    QC_61712
    Clear Counter files    ${False}
    SA UE1 register
    setup 2 slices for 2 PDU on UE1
    traffic should be ok    ue_id=1    pdu=1    type=SA
    traffic should be ok    ue_id=1    pdu=2    type=SA
    Check Counters    ${PM_Counters_Check}
    Check Wireshark Log    ${CURDIR}/a2a_cit010/a2a.ini

*** Keywords ***
Modify Cfg
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 amf=1 ue=1
    Update Cfg    set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

SA UE1 register
    Execute Egate Command    ue_register id=1    NG RM Registered

setup 2 slices for 2 PDU on UE1
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1    QoS Routing Table
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=2 nwslice=2 gw=2    QoS Routing Table