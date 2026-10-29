*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_FDD    SBTS00    team-Rock_SGT&A    owner-liupei.fang
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    5GC000732-E    release-5G22R2
...    STATE_CONFIGURED    RAN_5G    5GC000732-D

Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=10000ms
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{OnlineParam_E002}
...    NRBTS-1/NRCELL-2:maxNumOfNonGBRBearersSA=0

@{OnlineParam_E002_Recover}
...    NRBTS-1/NRCELL-2:maxNumOfNonGBRBearersSA=550

@{PM_Counters_Check_5GC000732D001D002}
...    NRDU-1:${RRC_REESTAB_RECONF_FAILURE_DU}=1
...    NRCELL-1:${RRC_REESTAB_FALLBACK}=1
...    NRCELL-1:${RRC_REESTAB_RECONF_FAILURE}=1
...    NRCELL-1:${REESTAB_ACC_FALLBACK}=1
...    NRCELL-1:${NRRCC_RRC_STPSUCC_TOT}=0
...    NRDU-1:${REESTAB_ACC_RECONF_FAIL_DU}=0
...    NRCELL-1:${REESTAB_ACC_RECONF_FAIL}=0

@{PM_Counters_Check_5GC000732E002}
...    NRDU-1:${RRC_REESTAB_HO_FAILURE_DU}=2
...    NRCELL-2:${RRC_REESTAB_HO_FAILURE}=2
...    NRCELL-1:${NNGCC_UE_CTXT_REL_REQ_SENT}=1
...    NRCELL-2:${REESTAB_ADMISSION_CRTL}=1
...    NRCELL-2:${NNGCC_UE_CTXT_REL_CMD_RECD}=1
...    NRBTS-1:${NE1CS_CTXT_REL_CMD_SENT}=1
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL}=1
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}=2
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMPSENT}=2

@{PM_Counters_Check_5GC000732E003}
...    NRDU-1:${RRC_REESTAB_HO_FAILURE_DU}=1
...    NRCELL-1:${RRC_REESTAB_HO_FAILURE}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_REQ_SENT}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_CMD_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_CMP_SENT}=1
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}=1
...    NRBTS-1:${NE1CS_CTXT_REL_CMD_SENT}=1
...    NRBTS-1:${NE1CS_CTXT_REL_CMP_RECD}=1
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMPSENT}=1

@{PM_Counters_Check_5GC000732E004}
...    NRDU-1:${RRC_REESTAB_HO_FAILURE_DU}=1
...    NRCELL-1:${RRC_REESTAB_HO_FAILURE}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_REQ_SENT}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_CMD_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_CMP_SENT}=1
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}=1
...    NRBTS-1:${NE1CS_CTXT_REL_CMD_SENT}=1
...    NRBTS-1:${NE1CS_CTXT_REL_CMP_RECD}=1
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMPSENT}=1

@{PM_Counters_Check_5GC000732E005}
...    NRDU-1:${RRC_REESTAB_HO_FAILURE_DU}=1
...    NRDU-1:${REESTAB_ACC_HO_FAIL_DU}=1
...    NRCELL-1:${RRC_REESTAB_HO_FAILURE}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_REQ_SENT}=1
...    NRCELL-1:${REESTAB_ACC_HO_FAIL}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_CMD_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_CMP_SENT}=1
...    NRCELL-1:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_TMR}=1
...    NRCELL-1:${EPmCounterId_5G_NRRCC_RRC_RELEASE_SENT}=1
...    NRBTS-1:${NE1CS_CTXT_REL_CMD_SENT}=1
...    NRBTS-1:${NE1CS_CTXT_REL_CMP_RECD}=1
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}=1
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMPSENT}=1

@{PM_Counters_Check_5GC000732E006}
...    NRDU-1:${RRC_REESTAB_HO_FAILURE_DU}=1
...    NRDU-1:${REESTAB_ACC_HO_FAIL_DU}=1
...    NRCELL-1:${RRC_REESTAB_HO_FAILURE}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_REQ_SENT}=1
...    NRCELL-1:${REESTAB_ACC_HO_FAIL}=1
...    NRCELL-1:${REESTAB_RRCRECONFIG_UNSUCC}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_CMD_RECD}=1
...    NRCELL-1:${NNGCC_UE_CTXT_REL_CMP_SENT}=1
...    NRCELL-1:${EPmCounterId_5G_NRRCC_RRC_RELEASE_SENT}=1
...    NRBTS-1:${NE1CS_CTXT_REL_CMD_SENT}=1
...    NRBTS-1:${NE1CS_CTXT_REL_CMP_RECD}=1
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}=1
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMPSENT}=1

${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501    #Number of RRC Re-establishment Request caused by reconfiguration failure
${RRC_REESTAB_FALLBACK}             M55124C00502    #Number of fallbacks to RRC Setup procedure during RRC Re-establishment procedure
${RRC_REESTAB_RECONF_FAILURE}       M55124C00503    #Number of RRC Re-establishment Request caused by reconfiguration failure
${REESTAB_ACC_FALLBACK}             M55124C00515    #Number of fallback RRCSetup successful as response to RRCReestablishmentReq
${NRRCC_RRC_STPSUCC_TOT}            M55124C01031    #Number of RRC CONNECTION Attempts that were completed successfully
${REESTAB_ACC_RECONF_FAIL_DU}       M55127C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${REESTAB_ACC_RECONF_FAIL}          M55124C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${RRC_REESTAB_HO_FAILURE_DU}                 M55127C00502  #Number of RRC Re-establishment Request caused by handover failure
${REESTAB_ACC_HO_FAIL_DU}                    M55127C00511  #Number of accepted RRC Re-establishment when reestablishment cause is  handover failure
${REESTAB_ACC_HO_FAIL}                       M55124C00511  #Number of accepted RRC Re-establishment when reestablishment cause is  handover failure
${RRC_REESTAB_HO_FAILURE}                    M55124C00504  #Number of RRC Re-establishment Request caused by handover failure
${NNGCC_UE_CTXT_REL_REQ_SENT}                M55125C01001  #Number of UE Context Release Request sent
${REESTAB_ADMISSION_CRTL}                    M55124C00519  #Number of admission control triggerd in CU by RRC reestablishment procedure
${REESTAB_RRCRECONFIG_UNSUCC}                M55124C00517  #Number of RRC reconfiguration unsuccessful in RRC reestablishment procedure
${NNGCC_UE_CTXT_REL_CMD_RECD}                M55125C00501  #Number of UE CONTEXT RELEASE COMMAND received
${NNGCC_UE_CTXT_REL_CMP_SENT}                M55125C00502  #Number of UE CONTEXT RELEASE COMPLETE sent
${NE1CS_CTXT_REL_CMD_SENT}                   M55135C00001  #Number of BEARER CONTEXT RELEASE COMMAND sent
${NE1CS_CTXT_REL_CMP_RECD}                   M55135C00002  #Number of BEARER CONTEXT RELEASE COMPLETE received
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REL}   M55139C00012  #The number of non-GBR DRB radio admission releases for SA user in DU
${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}  M55117C01009  #Number of Ue Context Release Command received
${EPmCounterId_5G_NF1CD_UECTXT_REL_CMPSENT}  M55117C01010  #Number of Ue Context Release Complete sent
${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_TMR}  M55124C03006  #Number of RRC RECONFIGURATION COMPLETE not received on time
${EPmCounterId_5G_NRRCC_RRC_RELEASE_SENT}    M55124C00001  #Number of RRC RELEASE Messages sent

#${EPmCounterId_5G_NRRCD_RRC_RELEASE_SENT}    M55127C01001  #Number of RRC RELEASE Messages sent  not used

${ReconfigurationFailure}     reconfigurationFailure
@{fallback_action}    invalid_short_mac_i    invalid_crnti
${HandoverFailure}     handoverFailure
${ue_id}   1
${pdu_id}  1
${gw_id}   1

${SCENARIO}    ${EMPTY}
@{SCENARIO_LIST}    E002    E003    E004    E005    E006

*** Test Cases ***
5GC000732-ET-D002_RRC_reestablish_with_unknown_C-RNTI_fallback
    [Documentation]
    ...    1. This user scenario describes the 5GNB behavior,
    ...    	  if the shortMAC-I is invalid or crnti is unknown during UE re-establish within the same gNB-DU,
    ...       the gNB will response with an RRCSetup in case of RRC reestablishment failure.
    ...    2. Case steps:
    ...       a.UE attached to cell1
    ...       b.Start traffic
    ...       c.Trigger reestablishment(fallback) with invalid shortMAC-I(same old c-RNTI)  or unknown C-RNTI (different c-RNTI)
    ...       d.Check traffic is OK(some traffic will drop during fallback, it should be OK if recovered in 5s.)
    ...       e.UE Deregister
    ...       f.D001_D002_RRC_reestablish_with_invalid_shortMAC-I_or_invalid_crnti_fallback
    [Tags]    QC_160914    owner-jing.ye    D002
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Clear Counter Files
    Iperf Send DL UL Traffic
    Get Random Fallback Action
    Trigger RRC Reestablish with invalid shortMAC-I or invalid crnti    ${ReconfigurationFailure}    ${random_fallback_action}
    Iperf DL UL Traffic Should Be OK
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732D001${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${PM_Counters_Check_5GC000732D001D002}

5GC000732_ET_Error_Scenario_TestCase
    [Documentation]
    ...    E002_RRC_reestablish_fail_due_to_lack_of_resource
    ...    1. This user scenario describes the 5GNB behavior, where gNB-CU-CP does not accept
    ...       the RRCReestablishmentRequest due to failures in gNB-CU-CP, e.g. lack of resource.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1
    ...         b. PDU session is setup successfully
    ...         c. Trigger RRC reestablishment request to cell2
    ...         d. RRC reestablish fail, UE in RRC idle state.
    ...    E003_RRC_reestablish_fail_due_to_lack_of_RRCReestablishmentComplete_from_UE
    ...    1. This user scenario describes the 5GNB behavior, UE will be released if RRCReestablishmentComplete is not received by gNB from UE.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1
    ...         b. PDU session is setup successfully
    ...         c. Set precondition to make RRCReestablishmentComplete to be dropped
    ...         d. Trigger RRC reestablishment request to cell1
    ...         e. RRC reestablish fail, UE in RRC idle state
    ...    E004_RRC_reestablish_fail_due_to_Invalid_RRCReestablishmentComplete_from_UE
    ...    1. This user scenario describes the 5GNB behavior, UE will be released if RRCReestablishmentComplete is received by gNB with invalid tid
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1
    ...         b. PDU session is setup successfully
    ...         c. Set precondition to make RRCReestablishmentComplete with in valid tid
    ...         d. Trigger RRC reestablishment request to cell1
    ...         e. RRC reestablish fail, UE in RRC idle state.
    ...    E005_RRC_reestablish_fail_due_to_Lack_of_RRCReconfigurationComplete_from_UE
    ...    1. This user scenario describes the 5GNB behavior, UE will be released if RRCReconfigurationComplete is not received by gNB from UE.
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1
    ...         b. PDU session is setup successfully
    ...         c. Set precondition to make RRCReconfigurationComplete to be dropped
    ...         d. Trigger RRC reestablishment request to cell1
    ...         e. RRC reestablish fail, UE in RRC idle state.
    ...    E006_RRC_reestablish_fail_due_to_Invalid_RRCReconfigurationComplete_from_UE
    ...    1. This user scenario describes the 5GNB behavior, UE will be released if RRCReconfigurationComplete is received by gNB with invalid tid
    ...    2. Test Case Steps:
    ...         a. UE registers successfully on cell 1
    ...         b. PDU session is setup successfully
    ...         c. Set precondition to make RRCReconfigurationComplete with in valid tid
    ...         d. Trigger RRC reestablishment request to cell1
    ...         e. RRC reestablish fail, UE in RRC idle state.
    [Tags]    QC_46919    E002
    ${random_scenario}    get_random_string    ${SCENARIO_LIST}
    Log To Console    ${random_scenario}
    ${final_select}    set variable if    "${SCENARIO}" == "${EMPTY}"    ${random_scenario}    ${SCENARIO}
    Log To Console    ${random_scenario}
    run keyword    5GC000732_ET_${final_select}

*** Keywords ***
5GC000732_ET_E002
    OnlineParamChange    ${OnlineParam_E002}
    Clear Counter Files
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger RRC Reestablish fail due to lack of resource    ${HandoverFailure}
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732E002${/}a2a.ini    wait_string=UEContextRelease::21
    Check Counters    ${PM_Counters_Check_5GC000732E002}
    OnlineParamChange    ${OnlineParam_E002_Recover}

5GC000732_ET_E003
    Clear Counter Files
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger RRC Reestablish fail due to Lack of RRCReestablishmentComplete    ${HandoverFailure}
    Check Counters    ${PM_Counters_Check_5GC000732E003}
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732E003${/}a2a.ini    wait_string=UEContextRelease::4

5GC000732_ET_E004
    Clear Counter Files
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger RRC Reestablish fail due to Invalid RRCReestablishmentComplete    ${HandoverFailure}
    Check Counters    ${PM_Counters_Check_5GC000732E004}
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732E004${/}a2a.ini    wait_string=UEContextRelease::4

5GC000732_ET_E005
    Clear Counter Files
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger RRC Reestablish fail due to Lack of RRCReconfigurationComplete    ${HandoverFailure}
    Check Counters    ${PM_Counters_Check_5GC000732E005}
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732E005${/}a2a.ini    wait_string=UEContextRelease::4

5GC000732_ET_E006
    Clear Counter Files
    UE Attach To Cell1    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger RRC Reestablish fail due to Invalid RRCReconfigurationComplete    ${HandoverFailure}
    Check Counters    ${PM_Counters_Check_5GC000732E006}
    Check Wireshark Log    ${CURDIR}${/}a2a_5GC000732E006${/}a2a.ini    wait_string=UEContextRelease::4

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Attach To Cell1
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id}	   QoS Routing Table

Trigger RRC Reestablish with invalid shortMAC-I or invalid crnti
    [Arguments]    ${cause}    ${action}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${cause} action=${action}
    ...    QoS Routing Table    timeout=20s
    Check Specific UE State    ue_id=${ue_id}    state=Active

Get Random Fallback Action
    ${random_fallback_action}    Evaluate    random.choice(${fallback_action})    random
    Set Test Variable    \${random_fallback_action}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE${ue_id}: detached

Iperf Send DL UL Traffic
    ${dl_send_file}    ${dl_receive_file}    Iperf Send Dl Traffic    ue_id=${ue_id}    bandwith='70M'
    ${ul_send_file}    ${ul_receive_file}    Iperf Send Ul Traffic    ue_id=${ue_id}    bandwith='10M'
    Sleep    2s    #wait for traffic stable
    Set Test Variable    \${dl_send_file}
    Set Test Variable    \${dl_receive_file}
    Set Test Variable    \${ul_send_file}
    Set Test Variable    \${ul_receive_file}

Iperf DL UL Traffic Should Be OK
    Sleep    15s    #wait for traffic stable
    Iperf Traffic Should Be Ok    send_traffic_file=${dl_send_file}    received_traffic_file=${dl_receive_file}    diff_amount=5    bw_thresh=85
    Iperf Traffic Should Be Ok    send_traffic_file=${ul_send_file}    received_traffic_file=${ul_receive_file}    diff_amount=5    bw_thresh=85

Trigger RRC Reestablish fail due to lack of resource
    [Arguments]    ${HandoverFailure}
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=2 cause=${HandoverFailure}
    ...    UE${ue_id}: Released PDU session    timeout=20s
    Wait Until Keyword Succeeds    5s    1s    Check Specific UE State    ue_id=${ue_id}    state=OFF

Trigger RRC Reestablish fail due to Lack of RRCReestablishmentComplete
    [Arguments]    ${HandoverFailure}
    Execute Egate Command    ue_rrc_reestablish_param id=${ue_id} if_contains=any action=drop
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${HandoverFailure}
    ...    UE${ue_id}: IS IDLE    timeout=20s
    Should Contain    ${ret1}    UE${ue_id}: NrRrcReestablishmentComplete is not sent
    Wait Until Keyword Succeeds    5s    1s    Check Specific UE State    ue_id=${ue_id}    state=IDLE

Trigger RRC Reestablish fail due to Invalid RRCReestablishmentComplete
    [Arguments]   ${HandoverFailure}
    Execute Egate Command    ue_rrc_reestablish_param id=${ue_id} if_contains=any action=invalid_tid
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${HandoverFailure}
    ...    UE${ue_id}: IS IDLE    timeout=20s
    Should Contain    ${ret1}    UE${ue_id}: NrRrcReestablishmentComplete is sent with invalid Transaction ID
    Wait Until Keyword Succeeds    5s    1s    Check Specific UE State    ue_id=${ue_id}    state=IDLE

Trigger RRC Reestablish fail due to Lack of RRCReconfigurationComplete
    [Arguments]    ${HandoverFailure}
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${HandoverFailure}
    ...    UE Context Release Complete    timeout=20s
    Should Contain    ${ret1}    Hit on error cases
    Should Contain    ${ret1}    UE${ue_id}: IS IDLE
    Wait Until Keyword Succeeds    5s    1s    Check Specific UE State    ue_id=${ue_id}    state=IDLE

Trigger RRC Reestablish fail due to Invalid RRCReconfigurationComplete
    [Arguments]   ${HandoverFailure}
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=invalid_tid
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${HandoverFailure}
    ...    UE Context Release Complete    timeout=20s
    Should Contain    ${ret1}    Hit on error cases
    Wait Until Keyword Succeeds    5s    1s    Check Specific UE State    ue_id=${ue_id}    state=IDLE
