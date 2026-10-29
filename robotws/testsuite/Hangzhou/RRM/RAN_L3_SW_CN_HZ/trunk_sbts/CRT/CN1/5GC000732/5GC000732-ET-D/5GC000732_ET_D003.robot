*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    team-SG2
...    owner-ying.chen    release-5G20A    5GC000732
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{5GC000732_Base}    
@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:tWaitingRlRecover=4000ms
@{PM_Counters_Check_D003}
...    NRDU-1:${RRC_REESTAB_RECONF_FAILURE_DU}=4
...    NRCELL-1:${RRC_REESTAB_FALLBACK}=4
...    NRCELL-1:${RRC_REESTAB_RECONF_FAILURE}=4
...    NRCELL-1:${REESTAB_ACC_FALLBACK}=4

${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501    #Number of RRC Re-establishment Request caused by reconfiguration failure
${RRC_REESTAB_FALLBACK}             M55124C00502    #Number of fallbacks to RRC Setup procedure during RRC Re-establishment procedure
${RRC_REESTAB_RECONF_FAILURE}       M55124C00503    #Number of RRC Re-establishment Request caused by reconfiguration failure
${REESTAB_ACC_FALLBACK}             M55124C00515    #Number of fallback RRCSetup successful as response to RRCReestablishmentReq


*** Test Cases ***
5GC000732-ET-D003_RRC_reestablish_to_different_gNB_fallback
    [Documentation]    This case will test UE re-establish to different gNB,
    ...    the gNB will response with an RRCSetup in case of RRC reestablishment failure.
    ...    if the shortMAC-I is invalid or crnti is unknown during UE re-establish within the same gNB-DU,
    ...    the gNB will response with an RRCSetup in case of RRC reestablishment failure.
    ...    Case steps:
    ...    1.UE attached to sim_gNB3
    ...    2.Trigger reestablishment(Fallback From SimGnb to RealGnb) to gNB2
    ...    3.Trigger reestablishment(Fallback From SimGnb to RealGnb) with invalid shortMAC-I or unknown C-RNTI
    ...    Counter:
    ...    M55127C00501:The number of the RRCReestablishmentRequest with the reestablishmentCause of reconfigurationFailure
    ...    M55124C00502:The number of RRCSetup is performed as response for RRCReestablishmentRequest
    ...    M55124C00503:The number of the RRCReestablishmentRequest with the reestablishmentCause of reconfigurationFailure
    ...    M55124C00515:The number of fallback RRCSetup successful as response to RRCReestablishmentRequest
    [Tags]    QC_160913   D003
    Clear Counter Files
    Ue Attach to Sim Cell    81    1
    Trigger reestablishment and fallback to gNB2    81
    Trigger reestablishment with any cause    81    invalid_short_mac_i
    Ue Attach to Sim Cell    82    2
    Trigger reestablishment and fallback to gNB2    82
    Trigger reestablishment with any cause    82    invalid_crnti
    Check Counters    ${PM_Counters_Check_D003}
    Check Wireshark Log    ${CURDIR}${/}a2a_D003${/}a2a.ini      wait_string=UEContextReleaseComplete::8
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/L1B/6cells_2T4F

Modify Cfg
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=40
    ${set_ue1}    catenate
    ...    set_ue simulated id=81 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645481 enb=3 cell=1 mode=nr
    Update Cfg    ${set_ue1}
    ${set_ue2}    catenate
    ...    set_ue simulated id=82 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645482 enb=3 cell=1 mode=nr
    Update Cfg    ${set_ue2}

Ue Attach to Sim Cell
    [Arguments]    ${ue_id}    ${gw_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=QoS Routing Table

Trigger reestablishment and fallback to gNB2
    [Arguments]    ${ue_id}    ${cmd_regexp}=QoS Routing Table
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=reconfigurationFailure    ${cmd_regexp}

Trigger reestablishment with any cause
    [Arguments]    ${ue_id}    ${cause}    ${cmd_regexp}=QoS Routing Table
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=reconfigurationFailure action=${cause}    ${cmd_regexp}
