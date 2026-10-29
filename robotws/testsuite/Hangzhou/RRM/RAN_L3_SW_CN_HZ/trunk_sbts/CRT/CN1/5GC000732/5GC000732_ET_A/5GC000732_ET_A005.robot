*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_BOO_AP_LOO    team-SG2
...    owner-ying.chen    release-5G20A    5GC000732
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{5GC000732_Base}    
@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:tWaitingRlRecover=4000ms

@{PM_Counters_Check_5GC000732A005}
...    ${F1_UE_CTXT_MOD_FAIL_SENT}=0                            #M55117C00003
...    ${NF1CD_DL_RRC_MSG_TRANSFER}=18                          #M55117C02001
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2                        #M55127C00503
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2                           #M55127C00512
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=2                  #M55124C00505
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=2                     #M55124C00512
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=2                   #M55124C00516
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}=4      #M55139C00004
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REL}=4                    #M55139C00012
...    NRCELL-1:${SA_DU_GBR_DRB_REL}=0                          #M55139C00509
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}=2         #M55117C01009

${F1_UE_CTXT_MOD_FAIL_SENT}    M55117C00003    #Number of outgoing UE CONTEXT MODIFICATION FAILURE sent to gNB-CU
${NF1CD_DL_RRC_MSG_TRANSFER}    M55117C02001    #Number of F1AP: UE Context Release Command messages received in gNB-DU
${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503    #Number of RRC Re-establishment Request caused by other failure
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512    #Number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505    #RRC_REESTAB_OTHER_FAILURE:If reestablishmentCause IE is otherFailure
${REESTAB_ACC_OTHER_FAIL}    M55124C00512    #number of admission controls triggered in CU by RRC reestablishment procedure
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516    #number of radio admission requests for SA user. Updated in the DU when RRC resources are requested
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}    M55139C00004    #The number of radio admitted non-GBR DRBs for SA user in DU
${SGNB_SA_DU_NGBR_DRB_REL}    M55139C00012    #The number of non-GBR DRB radio admission releases for SA user in DU
${SA_DU_GBR_DRB_REL}    M55139C00509
#Number of RoHC contexts configured for the DRBs for which RoHC compression is requested by gNB-CU-CP from gNB-CU-UP.
${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}    M55117C01009    #Number of Ue Context Release Command received

*** Test Cases ***
5GC000732-ET-A005_RRC_reestablish_succ_to_ori_cell_due_to_cause2_with_valid_UE_context_multi_Ues
    [Documentation]    This user scenario describes the behaviour, when UEs in RRC_CONNECTED state re-establishes RRC Connection to the selected
    ...    cell (serving cell or the other cell) in serving gNB-DU with valid UEs context.
    ...    Case steps:
    ...        1.Two UEs register to cell-1
    ...        2.Trigger normal call
    ...        3.Trgger RRC reestablish
    ...        4.check cause otherFailure in rrcReestablishmentRequest wiresahrk msg and DRB,SRB,cellgroup should be recovered
    ...        5.check counter
    ...         M55117C00003 Number of outgoing UE CONTEXT MODIFICATION FAILURE sent to gNB-CU.
    ...         M55117C02001 Number of DL RRC Message Transfer received.
    ...         M55127C00503 Number of RRC Re-establishment Request caused by other failure
    ...         M55127C00512 Number of accepted RRC Re-establishment when reestablishment cause is other failure
    ...         M55124C00505 Number of RRC Re-establishment Request caused by other failure
    ...         M55124C00512 Number of accepted RRC Re-establishment when reestablishment cause is other failure
    ...         M55124C00516 Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...         M55139C00004 The number of radio admitted non-GBR DRBs for SA user in DU
    ...         M55139C00012 The number of non-GBR DRB radio admission releases for SA user in DU
    ...         M55139C00509 The number of GBR DRB radio admission releases for SA user in DU
    ...         M55117C01009 Number of Ue Context Release Command received
    [Tags]    QC_142239   A005
    Clear Counter Files
    Ue Attach to Cell1    81    1
    Ue Attach to Cell1    82    2
    Verify Throughput    81    sleep_time=5s
    Verify Throughput    82    sleep_time=5s
    Trigger RRC Reestablish with cause    otherFailure
    Verify Throughput    81    sleep_time=15s
    Verify Throughput    82
    Release Ues    ue_type=all
    Check Counters    ${PM_Counters_Check_5GC000732A005}
    Check Wireshark Log    ${CURDIR}${/}a2a_A005${/}a2a.ini    wait_string=UEContextReleaseComplete::8


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F_2N78_2N41_N66_N71

Modify Cfg
    ${set_ue82}    catenate
    ...    set_ue simulated id=82 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645482 enb=2 cell=1 mode=nr
    Update Cfg    ${set_ue82}

Ue Attach to Cell1
    [Arguments]    ${ue_id}    ${gw_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${ue_id}    ${Tput_dl}=60    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger RRC Reestablish with cause
    [Arguments]    ${cause}
    Execute Egate Command    ue_rrc_reestablish id=81,82 gnb=2 cell=1 cause=${cause}
    ...    UE82: NR RRC Reestablishment sucessfully completed    timeout=20s
    rrc Should Contain    UE81: NR RRC Reestablishment sucessfully completed


