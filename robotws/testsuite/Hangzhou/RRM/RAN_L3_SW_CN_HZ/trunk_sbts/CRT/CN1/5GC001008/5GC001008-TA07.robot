*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC001008
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
${PARAMS_IN_CP_UE_RD}    rdUeContextRequest=True    #ICS without PDU Suite Setup

@{PARAMS_IN_SCF}    @{SNSSAI}    @{PLMN}    @{TRACKINGAREA}

@{SNSSAI}
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sst=1
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:sst=1
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1

@{PM_Counters_Check}
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${NUMBER_OF_SA_SLICE_USERS}=1
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${NUMBER_OF_SA_SLICE_USERS}=1
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_REQ_SLICE}=2
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${SA_NGBR_DRB_REQ_SLICE}=1
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_CU_SUCC_SLICE}=2
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${SA_NGBR_DRB_CU_SUCC_SLICE}=1
    ...    last MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${MEAS_PERIOD_NR_PDCP_SLICE}=300    #60/min
    ...    last MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${MEAS_PERIOD_NR_PDCP_SLICE}=300
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_NUM_UL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_NUM_UL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_VOL_UL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_VOL_UL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DELAY_UL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DELAY_UL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_NUM_DL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_NUM_DL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_VOL_DL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_VOL_DL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DELAY_DL_SLICE}>0
    ...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DELAY_DL_SLICE}>0

${SA_NGBR_DRB_REQ_SLICE}    M55149C00002    #The number of non-GBR DRB radio admission requests for SA user, per PLMN, per slice
${SA_NGBR_DRB_CU_SUCC_SLICE}    M55149C00020    #Number of non-GBR DRB established on successful PDU session establishment for SA user
${MEAS_PERIOD_NR_PDCP_SLICE}    M55328C00001    #Duration of the measurement period for the NR PDCP Slice
${PDCP_SDU_DATA_NUM_UL_SLICE}    M55328C00004    #UL PDCP SDUs received per Slice per PLMN
${PDCP_SDU_DATA_VOL_UL_SLICE}    M55328C00005    #UL PDCP SDUs received volume per Slice per PLMN
${PDCP_SDU_DELAY_DL_SLICE}    M55328C00006    #DL PDCP SDU delay per Slice per PLMN
${PDCP_SDU_DELAY_UL_SLICE}    M55328C00007    #UL PDCP SDU delay per Slice per PLMN
${PDCP_SDU_DATA_NUM_DL_SLICE}    M55328C00002    #DL PDCP SDUs transmitted per Slice per PLMN
${PDCP_SDU_DATA_VOL_DL_SLICE}    M55328C00003    #DL PDCP SDUs transmitted volume per Slice per PLMN
${NUMBER_OF_SA_SLICE_USERS}    M55149C00022    #The number of UEs successfully established for SA user per PLMN, per slice

*** Test Cases ***
5GC001008-ET-TA07_Verify_CP_and_UP_counters_when_ICS_without_PDU_and_two_PDUs_associated_to_a_specific_slice
    [Documentation]
    ...    1. This user scenario describes Initial Context Setup Successful without PDU and two PDU setup with specific slices
    ...    2. This user scenario describes Initial Context Setup Successful without PDU and two PDU setup with slice1
    ...    3. TAC-200: SLICE1/SLICE2
    ...       AMF-1: SLICE1/SLICE2
    [Tags]    QC_46843    PD008    PD009    PD010    PD052    PD054    PD058-TA08
    clear counter files    ${False}
    Trigger PDUs setup with specific slice
    Trigger traffic for all PDUs
    check wireshark log    ${CURDIR}/a2a_TA07/a2a_pdu.ini    wait_string=pDUSessionResourceSetupResponse::12
    Check counters    ${PM_Counters_Check}

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1

Trigger PDUs setup with specific slice
    Execute Egate Command    ue_register id=1 nwslice=1,2    UE now in NG RM Registered
    PDU session setup on UE    ue_id=1    pdu=1    nwslice=1
    PDU session setup on UE    ue_id=1    pdu=2    nwslice=1
    PDU session setup on UE    ue_id=1    pdu=3    nwslice=2

PDU session setup on UE
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1
    ${cmd_pdu_param}    Catenate    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${cmd_pdu_session}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${pdu}
    Execute Egate Command    ${cmd_pdu_param}
    Execute Egate Command    ${cmd_pdu_session}    QoS Routing Table

Trigger traffic for all PDUs
    Traffic Should Be OK    ue_id=1    pdu=1    type=sa
    Traffic Should Be OK    ue_id=1    pdu=2    type=sa
    Traffic Should Be OK    ue_id=1    pdu=3    type=sa
