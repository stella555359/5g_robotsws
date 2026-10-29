*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_FDD    SBTS00    team-Rock_SGT&A    owner-jing.ye
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    5GC000732-E    release-5G22R2
...    STATE_CONFIGURED    RAN_5G
Resource  ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=4000ms
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{New_PLMN_Configuration}

@{New_PLMN_Configuration}
...    NRBTS-1:actRanSharing=true
...    NRBTS-1:actNgcFlexSaMode=true
...    NRBTS-1:gNbCuType=SA
...    NRBTS-1:x2LinkSupervisionTmr=0
...    delete:NRBTS-1/NRCELL-1:configuredEpsTac
...    delete:NRBTS-1/NRCELL-2:configuredEpsTac
...    delete:NRBTS-1/NRCELL-1:trackingAreaDN
...    delete:NRBTS-1/NRCELL-2:trackingAreaDN
...    NRBTS-1/TRACKINGAREA-201
...    NRBTS-1/TRACKINGAREA-201:fiveGsTac=1
...    NRBTS-1/TRACKINGAREA-201:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS-1/TRACKINGAREA-200:fiveGsTac=0
...    NRBTS-1/NRPLMN-2
...    NRBTS-1/NRPLMN-2:mcc=311
...    NRBTS-1/NRPLMN-2:mnc=402
...    NRBTS-1/NRPLMN-2:mncLength=3
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRCELL-1:cellDepType=SA
...    NRBTS-1/NRCELL-2:cellDepType=SA
...    NRBTS-1/NRCELL-1/NRPLMNSET_SA-1
...    NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS-1/NRCELL-2/NRPLMNSET_SA-2
...    NRBTS-1/NRCELL-2/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRCELL-2/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-201

@{PM_Counters_Check_5GC000732E001}
...    NRDU-1:${RRC_REESTAB_HO_FAILURE_DU}=2
...    NRCELL-2:${RRC_REESTAB_HO_FAILURE}=2
...    NRCELL-1:${NNGCC_UE_CTXT_REL_REQ_SENT}=1
...    NRCELL-2:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_CMD_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_CMP_SENT}=1  
...    NRCELL-2:${NNGCC_UE_CTXT_REL_CMD_RECD}=1
...    NRCELL-2:${NNGCC_UE_CTXT_REL_CMP_SENT}=1
...    NRBTS-1:${NE1CS_CTXT_REL_CMD_SENT}=2
...    NRBTS-1:${NE1CS_CTXT_REL_CMP_RECD}=2
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL}=1
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}=2
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMPSENT}=2

${RRC_REESTAB_HO_FAILURE_DU}                 M55127C00502  #Number of RRC Re-establishment Request caused by handover failure
${RRC_REESTAB_HO_FAILURE}                    M55124C00504  #Number of RRC Re-establishment Request caused by handover failure
${NNGCC_UE_CTXT_REL_REQ_SENT}                M55125C01001  #Number of UE Context Release Request sent         
${REESTAB_ADMISSION_CRTL}                    M55124C00519  #Number of admission control triggerd in CU by RRC reestablishment procedure
${NNGCC_UE_CTXT_REL_CMD_RECD}                M55125C00501  #Number of UE CONTEXT RELEASE COMMAND received
${NNGCC_UE_CTXT_REL_CMP_SENT}                M55125C00502  #Number of UE CONTEXT RELEASE COMPLETE sent
${NE1CS_CTXT_REL_CMD_SENT}                   M55135C00001  #Number of BEARER CONTEXT RELEASE COMMAND sent
${NE1CS_CTXT_REL_CMP_RECD}                   M55135C00002  #Number of BEARER CONTEXT RELEASE COMPLETE received 
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL}   M55139C00012  #The number of non-GBR DRB radio admission releases for SA user in DU 
${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}  M55117C01009  #Number of Ue Context Release Command received
${EPmCounterId_5G_NF1CD_UECTXT_REL_CMPSENT}  M55117C01010  #Number of Ue Context Release Complete sent

${HandoverFailure}     handoverFailure
${ue_id}   1
${pdu_id}  1
${gw_id}   1

*** Test Cases ***
5GC000732_ET_E001_RRC_reestablish_fail_to_new_cell_with_different_PLMN
    [Documentation]
    ...    1. This user scenario describes the 5GNB behavior, where gNB-CU-CP does not accept
    ...       the RRCReestablishmentRequest due to failures in gNB-CU-CP, e.g. lack of resource.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1
    ...         b. PDU session is setup successfully
    ...         c. Trigger RRC reestablishment request to cell2
    ...         d. RRC reestablish fail, trigger fallback
	[Tags]    QC_167443    E001
    Clear Counter Files
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger RRC Reestablish to New Cell Should Be Failed    ${HandoverFailure}
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732E001${/}a2a.ini
    Check Counters    ${PM_Counters_Check_5GC000732E001}  
  
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=9
	
Modify Cfg
    ${C_1}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=1 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=636666:636666 
    ...    gscn=7880 mandatory_for_activation=off
    Update Cfg    ${C_1}
    Update Cfg    set_amf_region id=1 tac_list=0,1,100,258,788 plmn=311:489,311:402
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1 default=on ue=1-30 amf_region_id=1 plmn_list=311:489,311:402
    
UE Attach To Cell1
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
	Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
	Execute Egate Command    amf_mobility_restriction_list_param id=1 equiv_plmn=311:402 sa_plmn=311:489 allowed_tacs=0,1
	Execute Egate Command    amf_ue_ics_param id=1 ue=${ue_id} mobility_restriction_list_id=1
	Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered 
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id}	   QoS Routing Table
  
Trigger RRC Reestablish to New Cell Should Be Failed
    [Arguments]    ${HandoverFailure}   
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=2 cause=${HandoverFailure}  
	...    QoS Routing Table    timeout=20s
    Check Specific UE State    ue_id=${ue_id}    state=Active
	    Execute Egate Command    ue_pdu_session_release ue=1 pdu=1
	sleep    2s
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off
	sleep    5s
	
