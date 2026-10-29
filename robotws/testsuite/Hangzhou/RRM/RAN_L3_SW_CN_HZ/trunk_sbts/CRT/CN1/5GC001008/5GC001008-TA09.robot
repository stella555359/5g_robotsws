*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC001008
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{SNSSAI}    @{PLMN}    @{TRACKINGAREA}

@{SNSSAI}
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sst=1
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1

@{PM_Counters_Check}
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_CU_SUCC_SLICE}=1
...    MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${NUMBER_OF_SA_SLICE_USERS}=1

${SA_NGBR_DRB_CU_SUCC_SLICE}    M55149C00020    #Number of non-GBR DRB established on successful PDU session establishment for SA user
${NUMBER_OF_SA_SLICE_USERS}    M55149C00022    #The number of UEs successfully established for SA user per PLMN, per slice

*** Test Cases ***
5GC001008-ET-TA09_PD056_Verifiy_SA_NGBR_DRB_CU_SUCC_SLICE_NUMBER_OF_SA_SLICE_USERS_when_ICS_with_one_PDU
    [Documentation]
    ...    1. This user scenario describes Initial Context Setup Successful with one PDU with slice1
    ...    2. This user scenario describes the unsuccessful PDU Session Resource Setup procedure with one (subsequent) PDU Session where gNB-CU-CP
    ...       rejects the configuration due to invalid S-NSSAI (not consistent with the Allowed NSSAI of the UE context in the gNB)
    ...    3. TAC-200: SLICE1
    ...       AMF-1: SLICE1/SLICE2
    [Tags]    QC_61969    PD056    5GC002145-I008
    clear counter files    ${False}
    Trigger ICS Successful with one PDU
    check wireshark log    ${CURDIR}/a2a_TA09/a2a_pdu.ini    wait_string=PDUSessionResourceSetupResponse::3
    check counters    ${PM_Counters_Check}

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1

Trigger ICS Successful with one PDU
    Execute Egate Command    ue_register id=1 nwslice=1    UE now in NG RM Registered
    PDU session setup on UE    ue_id=1    pdu=1    nwslice=1    cmd_pdu_regexp=Initial Context Setup Successful
    PDU session setup on UE    ue_id=1    pdu=2    nwslice=2    cmd_pdu_regexp=RAN slice not supported

PDU session setup on UE
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${cmd_pdu_regexp}=QoS Routing Table
    ${cmd_pdu_param}    Catenate    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    ${cmd_pdu_session}    Catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${pdu}
    Execute Egate Command    ${cmd_pdu_param}
    Execute Egate Command    ${cmd_pdu_session}    ${cmd_pdu_regexp}
