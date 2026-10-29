*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CIT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC001630    5GC001468_A    CDRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

${GNB_BIP_FLAG}    True
${DEBUG_LOG_LEVEL}    0
#${UTE_WIRESHARK_FLAG}    True

@{PARAMS_IN_SCF}    @{RanSharing}    @{MultiAMF}    @{MultiPLMN}    @{NRPLMNSET_SA_NSA}    @{SNSSAI}    @{TRACKINGAREA}    @{5GC001468}
@{PARAMS_IN_SWCONFIG}
...    0x340002=1
...    0x340006=55139
@{RanSharing}
...    NRBTS-1:actRanSharing=true

...    NRBTS-1:actNgcFlexSaMode=true
...    delete:NRCELL:configuredEpsTac
...    delete:NRCELL:trackingAreaDN

@{MultiAMF}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SERVEDAMF-3:amfIPAddress=10.0.1.103

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402
...    NRPLMN-2:mncLength=3

@{NRPLMNSET_SA_NSA}
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

@{5GC001468}
...    NRCELL-1/NRREDRT-0:redirPrio=1
...    NRCELL-1/NRREDRT-0:redirRat=nr
...    NRCELL-1/NRREDRT-0:redirFreqNr=633372
...    NRCELL-1/NRREDRT-0:redirSsbScs=30 KHz
...    NRCELL-1/NRREDRT-1:redirPrio=2
...    NRCELL-1/NRREDRT-1:redirRat=eutra
...    NRCELL-1/NRREDRT-1:redirFreqEutra=19000
...    NRCELL-1/NRREDRT-2:redirPrio=3
...    NRCELL-1/NRREDRT-2:redirRat=eutra
...    NRCELL-1/NRREDRT-2:redirFreqEutra=1300
...    NRBTS-1:actEmergencyFallback=true
...    NRCELL-1:emergencyFBMode=redirection
...    NRCELL-2:emergencyFBMode=disabled
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirSsbScs
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirSsbScs

@{PM_Counters_Check}
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_NGBR_DRB_SETUP_SA_PLMN}=2
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-402:${SUCC_NGBR_DRB_SETUP_SA_PLMN}=1
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_SETUP_USER_SA_PLMN}=2
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-402:${SUCC_SETUP_USER_SA_PLMN}=1
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_SDU_USDAT_NUM_DL_PLMN}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-402:${PDCP_SDU_USDAT_NUM_DL_PLMN}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489:${PDCP_SDU_USDAT_NUM_UL_PLMN}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-402:${PDCP_SDU_USDAT_NUM_UL_PLMN}>0
...    NRCELL-1:NRRCC:${NRRCC_RRC_RELEASE_REDIR_LTE}=1
...    NRCELL-1:NRRCC:${NR_RRC_RELEASE_REDIR_EF_LTE}=1
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_STP_REQ_RECD}=4
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_STP_RESP_SENT}=4
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_STP_REQ_EF_RECD}=1
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_STP_RESP_EF_SENT}=1
${SUCC_NGBR_DRB_SETUP_SA_PLMN}    M55145C00220    #Nbr of successfully established non-GBR DRBs upon PDU session estab or mod for SA user per PLMN-ID
${SUCC_SETUP_USER_SA_PLMN}    M55145C00223    #The number of UEs successfully established for SA user per PLMN-ID
${PDCP_SDU_USDAT_NUM_DL_PLMN}    M55326C01001    #DL PDCP user data SDUs transmitted per PLMN-ID
${PDCP_SDU_USDAT_NUM_UL_PLMN}    M55326C01002    #UL PDCP user data SDUs received per PLMN-ID
${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C01502    #Number of RRC Releases with LTE frequency redirection information
${NR_RRC_RELEASE_REDIR_EF_LTE}    M55124C03501    #Number of RRC Releases with LTE frequency redirection information for emergency fallback
${NNGCC_UE_CTXT_STP_REQ_RECD}    M55125C02501    #Number of INITIAL CONTEXT SETUP REQUEST received
${NNGCC_UE_CTXT_STP_RESP_SENT}    M55125C02502    #Number of INITIAL CONTEXT SETUP RESPONSE sent
${NNGCC_UE_CTXT_STP_REQ_EF_RECD}    M55125C03001    #Number of INITIAL CONTEXT SETUP REQUEST for emergency fallback received
${NNGCC_UE_CTXT_STP_RESP_EF_SENT}    M55125C03002    #Number of INITIAL CONTEXT SETUP RESPONSE for emergency fallback sent

${Capa_emergency_fallback}    01200000010900000004D010000100078000000000000115000000000000015084000100

@{UE_idle}
...    UE4: IS IDLE
...    UE Context Release Complete

@{emergency_fallback}
...    establishmentCause emergency
...    UE_NAS_5GS_MM_SERVICE_REQUEST_INITIATED
...    UE Context Release Complete

*** Test Cases ***
5GSW-CP-CIT013_Verify_Classical_SA_TDD_cmWave_3UE_L3_call_setup_with_flexi_NG-C_and_multi_PLMNs_are_successful
    [Documentation]
    ...    0. 5GSW-CP-CIT008_Verify_Classical_SA_TDD_cmWave_emergency_call_setup_from_idle_then_redicted_to_LTE_for_not_optimized_ICS_is_successful
    ...    This Test case is to verify emergency services fallback with redirection would be successful, when ICS contains
    ...    1. This user scenario describes successful NR RAN Sharing start-up with multiple-PLMN SA configured in one PLMNSET
    ...    AMF1: TAC200, PLMN1
    ...    AMF2: TAC200, PLMN1
    ...    AMF3: TAC200, PLMN2
    ...    TAC200: SNSSAI-1
    ...    SNSSAI-1: PLMN1/PLMN2
    ...    real gNB2 CELL1: PLMN1/PLMN2, SNSSAI-1
    ...    UE1/UE2: PLMN1
    ...    UE3: PLMN2
    [Tags]    QC_61708
    Check all NG links is up
    all ue register and traffic should be ok
    release ues    ue_type=all
    To Access RRC IDLE without PDU without UECapbility
    Perform IDLE UE ServiceRequest
    Check Counters    ${PM_Counters_Check}
    Get the value of RAN_UE_NGAP_ID
    Check Wireshark Log    ${CURDIR}/a2a_cit013/a2a.ini

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=200 plmn=311:489
    Update Cfg    set_amf_region id=2 tac_list=200 plmn=311:489
    Update Cfg    set_amf_region id=3 tac_list=200 plmn=311:402
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=2 pointer=2
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=2 set_id=2 pointer=2
    Update Cfg    set_amf id=3 daemon=10.0.2.1:22222 ng=10.0.1.103:38412 region=3 set_id=2 pointer=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1-3 default=on ue=1-30
    Update Cfg Param    amf_param id=3 emergency_service_fallback=on target_cn=epc
    Update Cfg Param    set_ue simulated id=1 suci=0:311:489:0000:0:0:021645400
    Update Cfg Param    set_ue simulated id=2 suci=0:311:489:0000:0:0:021645401
    Update Cfg Param    set_ue simulated id=3 suci=0:311:402:0000:0:0:021645402
    Update Cfg Param    set_ue simulated id=4 suci=0:311:402:0000:0:0:021645403
    Update Cfg Param    ue_param id=4 ue_nr_capabilities=${Capa_emergency_fallback}
    Update Cfg    set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

Check all NG links is up
    object should exist    SERVEDAMF-1:ngLinkStatus=Active
    object should exist    SERVEDAMF-2:ngLinkStatus=Active
    object should exist    SERVEDAMF-3:ngLinkStatus=Active

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${cmd_regexp}=NG RM Registered
    ...    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${ue_id}    ${cmd_pdu_regexp}

all ue register and traffic should be ok
    FOR    ${ue_id}    IN RANGE    1    4
        sa ue register and pdu setup    ue_id=${ue_id}
        traffic should be ok    ue_id=${ue_id}    type=SA
    END

To Access RRC IDLE without PDU without UECapbility
    [Arguments]    ${ue_id}=4
    Execute Egate Command    amf_ue_ics_param id=3 reset
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered state
    Execute Egate Command    ue_im_entry id=${ue_id} by=ue    ${UE_idle}    #Entry UE IDLE mode
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency    #Set RRC param with emergency
    Execute Egate Command    amf_ue_ics_param id=3 emergency_fb=on target_cn=epc include_ue_capabilities=on
    ...    UE ICS Param has been successfully reset    #Set ICS Param with emergencyFB and ueCapability

Perform IDLE UE ServiceRequest
    Execute Egate Command    ue_im_exit id=4 by=ue service_type=emergency_services_fallback    ${emergency_fallback}

Get the value of RAN_UE_NGAP_ID
    ${rrc_content}    Run    cat /opt/iphy/latest/rrc.log | grep "INITIAL CONTEXT SETUP RESPONSE" | grep "RAN_UE_NGAP_ID"
    ${RAN_UE_NGAP_ID_list}    Get Regexp Matches    ${rrc_content}    RAN_UE_NGAP_ID=(\\d+)    1
    # LO have 2 cpuepool and the scope of the pool is set in: cp_ue.enb_conf.ini:maxNumOfUsersCpUe
    # cpuepool1=0~x, cpuepool2=x~x+x. cpuepool1 and cpuepool2 will be sorted alternately.
#    ${list1}    create list    0    x    1
#    ${list2}    create list    x    0    x+1
#    Should Be True    ${RAN_UE_NGAP_ID_list}==${list1} or ${RAN_UE_NGAP_ID_list}==${list2}
    Set Test Variable    ${RAN_UE1_NGAP_ID}    ${RAN_UE_NGAP_ID_list}[0]
    Set Test Variable    ${RAN_UE2_NGAP_ID}    ${RAN_UE_NGAP_ID_list}[1]
    Set Test Variable    ${RAN_UE3_NGAP_ID}    ${RAN_UE_NGAP_ID_list}[2]
    # verify that the UE is not the same
    Should Be True    ${RAN_UE1_NGAP_ID}!=${RAN_UE2_NGAP_ID} and ${RAN_UE1_NGAP_ID}!=${RAN_UE3_NGAP_ID} and ${RAN_UE2_NGAP_ID}!=${RAN_UE3_NGAP_ID}
