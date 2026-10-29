*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        SBTS00    QCD_MN_RAN    QCP_RAN_ET    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    owner-ye.selena    release-5G20A    CIT    CDRT    team-L3CN3_SG2    5GC000704    5GC000732    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
@{PARAMS_IN_SCF}    @{A5_PARAMS}    @{HO_PARAMS}    @{5GC000732_Base}
@{A5_PARAMS}
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRCELL:a5MeasSsbRsrq:a5Threshold1SsbRsrq=75
...    NRCELL:a5MeasSsbRsrq:a5Threshold2SsbRsrq=85
...    NRCELL:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms0

@{HO_PARAMS}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actInterFreqHoSA=true
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS:timerXnDataFwdGuard=250
...    NRCELL:cbraPreamblesPerSsb=n64
...    NRCELL:a5MeasEnabled=rsrp

@{5GC000732_Base}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:tWaitingRlRecover=4000ms

@{PM_Counters_Check_704}
...    NRBTS-1/NRCELL-1:${TOT_INTRA_FREQ_HO_DECISION_A5S}=${HO_LOOP}
...    NRBTS-1/NRCELL-2:${TOT_INTRA_FREQ_HO_DECISION_A5S}=${HO_LOOP}
...    NRBTS-1/NRCELL-1/PLMN-PLMN/NRCI-16386/PLMN-PLMN/MCC-311/MNC-489:${SUCC_HO_NRREL}=${HO_LOOP}
...    NRBTS-1/NRCELL-2/PLMN-PLMN/NRCI-16385/PLMN-PLMN/MCC-311/MNC-489:${SUCC_HO_NRREL}=${HO_LOOP}
...    NRBTS-1/NRCELL-1/PLMN-PLMN/NRCI-16386/PLMN-PLMN/MCC-311/MNC-489:${ATT_HO_NRREL}=${HO_LOOP}
...    NRBTS-1/NRCELL-2/PLMN-PLMN/NRCI-16385/PLMN-PLMN/MCC-311/MNC-489:${ATT_HO_NRREL}=${HO_LOOP}

${TOT_INTRA_FREQ_HO_DECISION_A5S}    M55147C00002
${SUCC_HO_NRREL}    M55153C00002
${ATT_HO_NRREL}    M55153C00001

@{PM_Counters_Check_5GC000732}
...    ${F1_UE_CTXT_MOD_FAIL_SENT}=0                            #M55117C00003
...    ${NF1CD_DL_RRC_MSG_TRANSFER}=9                          #M55117C02001
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=1                        #M55127C00503
...    ${REESTAB_ACC_OTHER_FAIL_DU}=1                           #M55127C00512
...    NRCELL-1:${RRC_REESTAB_OTHER_FAILURE}=1                  #M55124C00505
...    NRCELL-1:${REESTAB_ACC_OTHER_FAIL}=1                     #M55124C00512
...    NRCELL-1:${REESTAB_RRCRECONFIG_SUCC}=1                   #M55124C00516
...    NRCELL-1:${EPmCounterId_5G_SGNB_SA_DU_NGBR_DRB_SUCC}=2      #M55139C00004
...    NRCELL-1:${SGNB_SA_DU_NGBR_DRB_REL}=1                    #M55139C00012
...    NRCELL-1:${SA_DU_GBR_DRB_REL}=0                          #M55139C00509

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

${HO_LOOP}     3

*** Test Cases ***
5GSW-CP-CIT021_Verify_Classical_SA_TDD_cmWave-intrafreq_intragNB_HO_with_A5_RSRP_CBRA_is_successful_TestCase
    [Documentation]
    ...    This case verify 
	...    1. when UE in RRC_CONNECTED re-establishes RRC Connection to the selected cell in serving gNB-DU with valid UE context (5GC000732)
	...    2. successful handover based on A5 measurements when a5MeasEnabled is rsrp.
    ...    M55117C00003 Number of outgoing UE CONTEXT MODIFICATION FAILURE sent to gNB-CU.
    ...    M55117C02001 Number of DL RRC Message Transfer received.
    ...    M55127C00503 Number of RRC Re-establishment Request caused by other failure
    ...    M55127C00512 Number of accepted RRC Re-establishment when reestablishment cause is other failure
    ...    M55124C00505 Number of RRC Re-establishment Request caused by other failure
    ...    M55124C00512 Number of accepted RRC Re-establishment when reestablishment cause is other failure
    ...    M55124C00516 Number of RRC reconfiguration successful in RRC reestablishment procedure
    ...    M55139C00004 The number of radio admitted non-GBR DRBs for SA user in DU
    ...    M55139C00012 The number of non-GBR DRB radio admission releases for SA user in DU
    ...    M55139C00509 The number of GBR DRB radio admission releases for SA user in DU
    ...    M55147C00002 Total Intra-Frequency Handover decisions due to A5 Measurement Report TOT_INTRA_FREQ_HO_DECISION_A5S
    ...    M55153C00001 HO Attempts per neighbour cell relation ATT_HO_NRREL
    ...    M55153C00002 HO Success per neighbour cell relation SUCC_HO_NRREL
    [Tags]    QC_61698
    Clear Counter files    wait=${False}
    UE Attach To Cell1
    Trigger RRC Reestablish with cause    otherFailure
    Check Throughput and counter after Reestablish
	Clear Counter files
    Trigger Handover
    Check Throughput and counter and wireshark after Handover

*** Keywords ***
UE Attach To Cell1
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${gw_id} nwslice=1    pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink
    Verify Throughput

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=60    ${Tput_ul}=8.5    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Check Throughput and counter after Reestablish
    Verify Throughput
    Check Counters    ${PM_Counters_Check_5GC000732}

Check Throughput and counter and wireshark after Handover
    Verify Throughput
	Check Counters    ${PM_Counters_Check_704}
    UE Deregister From Cell1 
    Check Wireshark Log    ${CURDIR}/a2a/a2a.ini

Trigger Handover
    FOR    ${index}    IN RANGE    0    ${HO_LOOP}
        Handover From Cell1 to Cell2 Should be Success
        Handover From Cell2 to Cell1 Should be Success
    END
		
Handover From Cell1 to Cell2 Should be Success
    UE Handover    target_cell=2    source_cell=1    A5_id=1    pci=51

Handover From Cell2 to Cell1 Should be Success
    UE Handover    target_cell=1    source_cell=2    A5_id=1    pci=50

UE Handover
    [Arguments]    ${target_cell}    ${source_cell}    ${A5_id}    ${pci}
    trigger A5 event    meas_id=${A5_id}    phycell_id=${pci}    sourcecell_id=${source_cell}    targetcell_id=${target_cell}
    sleep    2s    reason=wait related output to be finished

trigger A5 event
    [Arguments]    ${meas_id}=1    ${phycell_id}=51    ${sourcecell_id}=1    ${targetcell_id}=2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A5 srsrp_nr=20 srsrq_nr=20 phycell_id=${phycell_id} nrsrp_nr=61 nrsrq_nr=61
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.${sourcecell_id} to EXT_ENB-2.${targetcell_id} performed
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measObjectToAddModList
    Should Contain    ${ret1}    measObject measObjectNR
    Should Contain    ${ret1}    physCellId ${phycell_id}
    Should Contain    ${ret1}    CBRA
    Should Not Contain    ${ret1}    cfra

Trigger RRC Reestablish with cause
    [Arguments]    ${cause}
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=${cause}
    ...    UE1: NR RRC Reestablishment sucessfully completed    timeout=20s
    rrc Should Contain    UE1: NR RRC Reestablishment sucessfully completed

UE Deregister From Cell1
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    UE${ue_id}: detached
