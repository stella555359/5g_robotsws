*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-Tingjian.Mao    team-SGT&A    release-SBTS23R4
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{beamswitch}
...    @{5GC000732_Base}
...    @{5GC000740_flag}
...    @{32SSB}

@{32SSB}
...    NRCELL:actBeamforming=true
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=251

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB

@{5GC000740_flag}
...    NRBTS-1:actNgcFlexSaMode=true
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    MRBTS-1/NRBTS-1/SERVEDAMF-1:defaultAMF=true
...    SERVEDAMF-1:administrativeState=Unlocked
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    MRBTS-1/NRBTS-1/SERVEDAMF-2:defaultAMF=true
...    SERVEDAMF-2:administrativeState=Unlocked
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:sst=1
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:sst=1
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-3:administrativeState=Unlocked
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:sst=1
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=5min
...    MRBTS-1/NRBTS-1:ngUeRetentionEnabled=false
...    MRBTS-1/NRBTS-1/NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=240
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=600
...    NRBTS:drbInactivityTimerSA=600

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1

@{beamswitch}
...    NRCELL:actRrcReconfigAtBeamSwitch=true

@{pass_regexp_ue1}
...    UE1: NR RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete

@{pass_regexp_ue1_ue2}
...    UE1: NR RRC Reestablishment sucessfully completed
...    UE2: NR RRC Reestablishment sucessfully completed
...    rrcReconfigurationComplete

${Lock_AMF1}    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Locked
${Lock_AMF2}    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Locked
${Unlock_AMF2}    MRBTS-1/NRBTS-1/SERVEDAMF-2:administrativeState=Unlocked
${Unlock_AMF1}    MRBTS-1/NRBTS-1/SERVEDAMF-1:administrativeState=Unlocked

@{PM_Counters_Check_B001}
...    NRDU-1:${RRC_REESTAB_RECONF_FAILURE_DU}=5
...    NRDU-1:${REESTAB_ACC_RECONF_FAIL_DU}=5
...    NRCELL-1:${RRC_REESTAB_RECONF_FAILURE}=5
...    NRCELL-1:${REESTAB_ACC_RECONF_FAIL}=5
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=5
...    NRCELL-1:${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}=23
...    NRCELL-1:${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}=23
...    NRCELL-1:${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}=12
...    NRCELL-1:${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}=12
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ}=6
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC}=6
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ}=6
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}=6
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}=16
...    NRBTS-1:${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}=16
...    NRCELL-1:${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}=24

${RRC_REESTAB_RECONF_FAILURE_DU}    M55127C00501    #Number of RRC Re-establishment Request caused by reconfiguration failure
${REESTAB_ACC_RECONF_FAIL_DU}    M55127C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${RRC_REESTAB_RECONF_FAILURE}       M55124C00503    #Number of RRC Re-establishment Request caused by reconfiguration failure
${REESTAB_ACC_RECONF_FAIL}          M55124C00510    #Number of accepted RRC Re-establishment when reestablishment cause is reconfiguration failure
${EPmCounterId_5G_F1_UE_CTXT_MOD_RESP_RECEIVED}    M55113C00002    #Number of incoming UE CONTEXT MODIFICATION RESPONSE received from gNB-DU
${EPmCounterId_5G_NF1CC_DL_RRC_MSG_TRANSFER}    M55113C00501    #Number of DL RRC Message Transfer sent.
${EPmCounterId_5G_NF1CC_UL_RRC_MSG_TRANSFER}    M55113C00502    #Number of UL RRC Message Transfer received.
${EPmCounterId_5G_NRRCC_RRC_RECONF_SENT}    M55124C03001    #Number of RRC RECONFIGURATION sent
${EPmCounterId_5G_NRRCC_RRC_RECONF_CMP_RECD}    M55124C03002    #Number of RRC RECONFIGURATION COMPLETE received
${EPmCounterId_5G_NE1CS_CTXT_MOD_REQ_SENT}    M55135C00505    #Number of Bearer Context Modification Request sent by gNB-CU-CP
${EPmCounterId_5G_NE1CS_CTXT_MOD_RSP_RECD}    M55135C00506    #Number of Bearer Context Modification Response received at gNB-CU-CP
${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_REQ}    M55139C00001    #The number of radio admission requests for SA user in DU
${EPmCounterId_5G_SGNB_SA_DU_ADMISSION_SUCC}    M55139C00002    #The number of radio admitted UEs for SA user in DU
${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_REQ}    M55139C00003    #The number of non-GBR DRB radio admission requests for SA user in DU

@{PM_Counters_Check_B002}
...    ${F1_UE_CTXT_MOD_FAIL_SENT}=0                            #M55117C00003
...    ${NF1CD_DL_RRC_MSG_TRANSFER}=22                          #M55117C02001
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2                        #M55127C00503
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2                           #M55127C00512
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=2                  #M55124C00505
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=2                     #M55124C00512
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=2                   #M55124C00516
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}=4      #M55139C00004
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REL}=2                    #M55139C00012
...    NRCELL-1:${SA_DU_GBR_DRB_REL}=0                          #M55139C00509
...    NRDU-1:${EPmCounterId_5G_NF1CD_UECTXT_REL_CMDRECD}=0         #M55117C01009

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

@{PM_Counters_ET-B007}
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_ATT}=1
...    NRCELL-1:NGCFB:${AMF_RESELECTION_GNB_SUCC}=1
${AMF_RESELECTION_GNB_ATT}    M55155C00004
${AMF_RESELECTION_GNB_SUCC}    M55155C00006

@{PM_Counters_B005}
...    NRCELL-1:${NNGCC_INIT_UE_MSG_SENT}=12
...    NRCELL-1:${NNGCC_UE_CTXT_STP_REQ_RECD}=12
...    NRCELL-1:${NNGCC_UE_CTXT_STP_RESP_SENT}=12
${NNGCC_INIT_UE_MSG_SENT}    M55125C00001    #Number of INITIAL UE MESSAGE sent
${NNGCC_UE_CTXT_STP_REQ_RECD}    M55125C02501    #Number of INITIAL CONTEXT SETUP REQUEST received
${NNGCC_UE_CTXT_STP_RESP_SENT}    M55125C02502    #Number of INITIAL CONTEXT SETUP RESPONSE sent

*** Test Cases ***
CB008285-ET-B001_5GC000732_A001_RRC_reestablish_succ_to_ori_cell_due_to_reconfigFailure_with_valid_UE_context_one_DRB
    [Documentation]
    ...    1. This user scenario describes This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...    This user scenario describes the behaviour, when a UE in RRC_CONNECTED state re-establishes RRC Connection to
    ...    the selected cell (serving cell or the other cell) in serving gNB-DU with valid UE context.
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    3. Test Case Steps:
    ...        1.UE register to cell-1
    ...        2.Trigger normal call and Verify Throughput
    ...        3.Trgger RRC reestablish in original cell and Verify Throughput
    ...        4.check counter
    ...    4. Expected Results:
    ...        1.UE register to cell-1 succeed
    ...        2.Trigger normal call succeed and Verify Throughput normal
    ...        3.Trigger RRC reestablish successfully in original cell and Verify Throughput normal
    ...        4.check counter succeed
    [Tags]    QC_302800    B001
    Clear Counter Files    ${False}
    Ue Attach to Cell1    ue_id=1    gw_id=1
    Verify Throughput    ue_id=1    sleep_time=5s
    repeat keyword    5    repeat Reestablish 5 times
    Verify Throughput    ue_id=1    sleep_time=15s
    Check Counters    ${PM_Counters_Check_B001}
    Release Ues    ue_type=1
    Check Wireshark Log    ${CURDIR}${/}a2a_B001${/}a2a.ini    wait_string=UEContextModificationResponse::46

CB008285-ET-B002_5GC000732_A005_RRC_reestablish_succ_to_ori_cell_due_to_cause2_with_valid_UE_context_multi_Ues
    [Documentation]
    ...    1. This user scenario describes This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...    This user scenario describes the behaviour, when a UE in RRC_CONNECTED state re-establishes RRC Connection to
    ...    the selected cell (serving cell or the other cell) in serving gNB-DU with valid UE context.
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    3. Test Case Steps:
    ...        1.Two UEs register to cell-1
    ...        2.Trigger normal call and Verify Throughput
    ...        3.Trgger RRC reestablish in original cell and Verify Throughput
    ...        4.check counter
    ...    4. Expected Results:
    ...        1.Two UEs register to cell-1 succeed
    ...        2.Trigger normal call succeed and Verify Throughput normal
    ...        3.Trigger RRC reestablish successfully in original cell and Verify Throughput normal
    ...        4.check counter succeed
    [Tags]    QC_302802    B002
    Clear Counter Files
    Ue Attach to Cell1    ue_id=1    gw_id=1
    Ue Attach to Cell1    ue_id=2    gw_id=1
    Verify Throughput    ue_id=1    sleep_time=5s
    Verify Throughput    ue_id=2    sleep_time=5s
    Trigger RRC Reestablish with cause    ue_id=1,2    cause=otherFailure    pass_regexp=${pass_regexp_ue1_ue2}
    Verify Throughput    ue_id=1    sleep_time=15s
    Verify Throughput    ue_id=2
    Check Counters    ${PM_Counters_Check_B002}
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_B002${/}a2a.ini    wait_string=UEContextReleaseComplete::8

CB008285-ET-B005_5GC000740-ET-C01-C02-C03-C04-C05_Verify_default_AMF_is_selected_when_UE_sends_RRC_setup_complete
    [Documentation]
    ...    1. This user scenario describes This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...       In this case the UE provides no 5G-S-TMSI nor registeredAMF nor the requested NSSAI. The AMF selection will rely on AMF
    ...       default information set in NIDD.
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    3. Test Case Steps:
    ...       1. Amf1 will be selected as it's default amf
    ...          The 'default' AMF can be configured on SCF, and this parameter 'default' can be set for every AMF
    ...       2. Amf1 will be selected as it's default amf but capacity is 0
    ...          If AMF1 is the only one AMF that selected by gnb, it will be used even AMF's capacity is 0
    ...       3. Amf2 will be selected as amf1's capacity is 0
    ...          One AMF's capacity is 0,and another AMF's capacity is not 0, the AMF that capacity is not 0 will be used finally
    ...       4. The probability of selecting AMF1 is greater than AMF2 as its capacity is greater
    ...          If gnb selected 2 AMFs and both of these AMF's capacity is not 0, the AMF with bigger capacity will have more chance to be used
    ...       5. No amf will be selected as all capacities are 0
    ...          If gnb selected 2 AMFs, but both of these AMF's capactity is 0, the UE will be released by gnb fianally
    ...    4. Expected Results:
    ...       1. Online Modify AMF succeed,AMF Config update succeed
    ...       2. Ue uses amf1 to establish normal calls
    ...       3. AMF Config update succeed,Ue uses amf2 to establish normal calls
    ...       4. AMF Config update succeed,UE uses AMF1 to establish normal calls more times than AMF2
    ...       5. UE failed to establish a normal call
    [Tags]    QC_302798    B005
    Clear Counter Files
    Online Modify AMF to Default    amf1_default=true    amf2_default=false
    AMF Config update    amf1_cap=0    amf2_cap=100
    AMF1 will be selected due to it is the default AMF even AMF1 capacity is 0
    Online Modify AMF to Default    amf1_default=true    amf2_default=true
    AMF2 will be selected due to AMF1 capacity is 0 when all AMFs is default
    AMF Config update    amf1_cap=100    amf2_cap=15
    Register UE Repeatedly And Compare The Probability Of AMF    nwslice=none
    No amf will be selected as all capacities are 0
    Check Counters    ${PM_Counters_B005}

CB008285-ET-B006_5GC000740_C006_Verify_the_S-NSSAI_matched_AMF_is_selected_when_UE_sends_RRC_setup_complete
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with FR2 SA Cells.In this case the UE provides no
    ...    5G-S-TMSI nor registeredAMF but the requested NSSAI
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    3. Test Case Steps:
    ...       1. slice matched AMF1 will be selected, even if cap is 0
    ...       2. no AMF will be selected as all capacities are 0 but all slices matched
    ...       3. the probability of selecting AMF1 is greater than AMF2 as its capacity is greater with same slice
    ...       4. default AMF2 will be selected when no slice matches
    ...    4. Expected Results:
    ...       1. UE selects AMF2 for the first registration and AMF1 for the second registration
    ...       2. UE failed to establish a normal call
    ...       3. UE uses AMF1 to establish normal calls more times than AMF2
    ...       4. UE Select AMF2 to set up a normal call
    [Tags]    QC_302791    B006
    Check All NG links is up
    Online Modify AMF to Default    amf1_default=true    amf2_default=true
    Select AMF based on requested S-NSSAI
    No amf will be selected as all capacities are 0 but all slices matched
    AMF Config update    amf1_cap=100    amf1_nwslice=1,2,3    amf2_cap=10    amf2_nwslice=1,2,3
    Register UE Repeatedly And Compare The Probability Of AMF    nwslice=1,2,3
    Online Modify AMF to Default    amf1_default=false    amf2_default=true
    default AMF2 will be selected when no slice matches
    Online Modify AMF to Default

CB008285-ET-B007_5GC000740_E028_Verify_AMF_reselection_due_to_NG-C_lock_for_uplink_NGAP_UE-associated_message_with_Backup_AMF
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...       This case is to verify reselection by gnb when UL NAS message received and former amf was locked
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    3. Test Case Steps:
    ...       1.Lock AMF2,Ue register to amf1 without nwlice
    ...       2.Unlock AMF2,lock AMF1
    ...       3.Ue Reselect AMF2 By PduSessionModification
    ...       4.check counters
    ...    4. Expected Results:
    ...       1.Lock AMF2 succeed,Ue register to amf1 without nwlice succeed
    ...       2.Unlock AMF2 succeed,lock AMF1 succeed
    ...       3.Ue Reselect AMF2 By PduSessionModification succeed
    ...       4.check counters succeed
    [Tags]    QC_302797    B007
    Clear Counter Files
    Update AMF Parameters
    Check BackupAMF
    Lock AMF2
    Ue Register To AMF1 Without registered_amf Without nwslice And Pdu Setup
    Unlock AMF2
    Lock AMF1 And Reselect AMF2 By PduSessionModification
    check counters    ${PM_Counters_ET-B007}
    Unlock AMF1
    release ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_ecpri

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Update Cfg    set_amf_region id=1 tac_list=200 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1 name=SimModeAMF1
    Update Cfg    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.1.102:38412 region=1 set_id=2 pointer=2 name=SimModeAMF2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 ue=all amf=1-2 default=on
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1-2
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 ue=all amf=1-2
    Update Cfg    amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc
    update cfg    amf_ng_setup_param id=1 relative_capacity=100 include_backup_amf_name=on
    update cfg    amf_ng_setup_param id=2 relative_capacity=100
    update cfg    set_backup_amf main=1 backup_amfs=2
    Update Cfg    set_qosflow id=2 5qi=7 default=off
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2

Check All NG links is up
    ${status}    create list    SERVEDAMF-1:ngLinkStatus=Active    SERVEDAMF-2:ngLinkStatus=Active
    object should exist    ${status}

Make Sure AMF Active
    [Documentation]    sctpWaitTimeInitSeqRetry=240s,sctp reinitialize will start at 4mins after AMF inactive
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    wait until keyword succeeds    5 min    5 sec        object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Update AMF Parameters
    Make Sure AMF Active
    execute egate command    amf_config_update id=1 name=SimModeAMF1 plmn=311:489 nwslice=1,2,3 relative_capacity=50 amfi=1:1:1 backup_amfs=2
    ...    pass_regexp=AMF-1.*Received AMF Configuration Acknowledge from GNB-2
    execute egate command    amf_config_update id=2 name=SimModeAMF2 plmn=311:489 nwslice=1,2,3 relative_capacity=100 amfi=1:1:1
    ...    pass_regexp=AMF-2.*Received AMF Configuration Acknowledge from GNB-2

Lock AMF1
    delta commission parameters    ${Lock_AMF1}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Lock AMF2
    delta commission parameters    ${Lock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive

Unlock AMF2
    delta commission parameters    ${Unlock_AMF2}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Unlock AMF1
    delta commission parameters    ${Unlock_AMF1}
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Active
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Active

Check BackupAMF
    object should exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:guAMI:backupAmfName=SimModeAMF2

repeat Reestablish 5 times
    Trigger RRC Reestablish with cause    ue_id=1    cause=reconfigurationFailure    pass_regexp=${pass_regexp_ue1}
    sleep    2s    #Wait for stability

Ue Register To AMF1 Without registered_amf Without nwslice And Pdu Setup
    Set Registered AMF To Ue    registered_amf=none
    Register Ue Without nwslice
    Setup PDU Session    pass_regexp=AMF-1: Initial Context Setup Successful

Set Registered AMF To Ue
    [Arguments]    ${ue_id}=1    ${registered_amf}=${EMPTY}
    execute egate command    ue_nr_rrc_param_setup id=${ue_id} registered_amf=${registered_amf}

Register Ue Without nwslice
    [Arguments]    ${ue_id}=1    ${pass_regexp}=NG RM Registered
    execute egate command    ue_register id=${ue_id}    pass_regexp=${pass_regexp}

Setup PDU Session
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=${EMPTY}
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    execute egate command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}    ${pass_regexp}

Lock AMF1 And Reselect AMF2 By PduSessionModification
    Lock AMF1
    execute egate command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=ue
    ...    pass_regexp=AMF-2: GNB-2:.*Pdu Session Resource Modify Response.*handled successfully

Online Modify AMF to Default
    [Arguments]    ${amf1_default}=true    ${amf2_default}=true
    ${params}    create list    SERVEDAMF-1:defaultAMF=${amf1_default}    SERVEDAMF-2:defaultAMF=${amf2_default}
    delta commission parameters    ${params}

Select AMF based on requested S-NSSAI
    AMF Config update    amf1_cap=0    amf1_nwslice=1,2,3    amf2_cap=100    amf2_nwslice=1,2
    SA UE Register and PDU Setup    ue_id=1    nwslice=none    cmd_pdu_regexp=AMF-2: Initial Context Setup Successful
    Release Ues    ue_type=all
    SA UE Register and PDU Setup    ue_id=1    nwslice=1,2,3    cmd_pdu_regexp=AMF-1: Initial Context Setup Successful
    Release Ues    ue_type=all

SA UE Register and PDU Setup
    [Arguments]    ${ue_id}=1    ${nwslice}=none    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id} nwslice=${nwslice}    pass_regexp=NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${cmd_pdu_regexp}

No AMF will be selected as all capacities are 0 but all slices matched
    AMF Config update    amf1_cap=0    amf1_nwslice=1,2,3    amf2_cap=0    amf2_nwslice=1,2,3
    Execute Egate Command    ue_register id=1 nwslice=1,2,3    pass_regexp=RRC Release

AMF Config update
    [Arguments]    ${amf1_cap}=50    ${amf1_nwslice}=1    ${amf2_cap}=50    ${amf2_nwslice}=1
    ...    ${cmd_regexp}=Received AMF Configuration Acknowledge
    Execute Egate Command    amf_config_update id=1 nwslice=${amf1_nwslice} relative_capacity=${amf1_cap} amfi=1:1:1    pass_regexp=${cmd_regexp}
    Execute Egate Command    amf_config_update id=2 nwslice=${amf2_nwslice} relative_capacity=${amf2_cap} amfi=1:2:2    pass_regexp=${cmd_regexp}

Register UE Repeatedly And Compare The Probability Of AMF
    [Arguments]    ${register_times}=10    ${nwslice}=none
    start rrc log    probability
    FOR    ${index}    IN RANGE    ${register_times}
        SA UE Register and PDU Setup    ue_id=1    nwslice=${nwslice}
        Release Ues    ue_type=all
    END
    get rrc log
    ${AMF1_counter}    Run    grep 'AMF-1: Initial Context Setup Successful' ${TEST_LOG_DIR}/rrc_probability.log | wc -l
    ${AMF2_counter}    Run    grep 'AMF-2: Initial Context Setup Successful' ${TEST_LOG_DIR}/rrc_probability.log | wc -l
    should be true    ${AMF1_counter}>${AMF2_counter}

default AMF2 will be selected when no slice matches
    AMF Config update    amf1_cap=100    amf1_nwslice=1,2    amf2_cap=50    amf2_nwslice=1,3
    SA UE Register and PDU Setup    ue_id=1    nwslice=1,2,3    cmd_pdu_regexp=AMF-2: Initial Context Setup Successful
    Release Ues    ue_type=all

Ue Attach to Cell1
    [Arguments]    ${ue_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=170 trf_id=3    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=100 trf_id=1    pass_regexp=Started Uplink

Verify Throughput
    [Arguments]    ${ue_id}    ${Tput_dl}=100    ${Tput_ul}=30    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger RRC Reestablish with cause
    [Arguments]    ${ue_id}    ${cause}    ${pass_regexp}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${cause}
    ...    pass_regexp=${pass_regexp}

AMF1 will be selected due to it is the default AMF even AMF1 capacity is 0
    SA UE Register and PDU Setup    ue_id=1    cmd_pdu_regexp=AMF-1: Initial Context Setup Successful
    Release Ues    ue_type=all

AMF2 will be selected due to AMF1 capacity is 0 when all AMFs is default
    SA UE Register and PDU Setup    ue_id=1    cmd_pdu_regexp=AMF-2: Initial Context Setup Successful
    Release Ues    ue_type=all

No amf will be selected as all capacities are 0
    AMF Config update    amf1_cap=0    amf2_cap=0
    Execute Egate Command    ue_register id=1    pass_regexp=RRC Release
