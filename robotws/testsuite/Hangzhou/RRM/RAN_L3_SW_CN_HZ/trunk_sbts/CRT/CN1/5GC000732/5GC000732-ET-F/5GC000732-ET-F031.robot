*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    CRT    SBTS00
...               owner-fan.jolin    owner-mao.cathy    team-SG2    release-SBTS22R2    5GC000732
...               CLOUD_5G_I_BOO_AP_LOO
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F

@{PARAMS_IN_SCF}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:caConfigurationSupport=none
...    delete:sCellActivationMethod
...    NRBTS-1:actMultipleDedicatedBWPs=true
...    NRBTS-1:actCarrierAggregation=false
...    NRBTS-1:tWaitingRlRecover=4000ms
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=17|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=17
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n4|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=18|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=18
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=9|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n2|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n0|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n4|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl10|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=19|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=4|searchSpaceId=19
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cceToRegMapping=nonInterleaved
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:coresetId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:cRbStart=0
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:duration=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:interleaverSize=none
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:regBundleSize=n6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n4|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=20|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=20
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=4|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:duration=1|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL1=n0|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL16=n0|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL2=n0|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL4=n2|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:numOfPdcchCandidatesInAL8=n5|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:periodicity=sl1|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=21|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=21
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:slotOffset=0|searchSpaceId=21
...    NRPMRNL-1:miNrPowerSavingBwp=5min
...    NRCELL-2:actPowerSavingBWP=true
...    NRCELL-2:pucchModeSelect=longPucch
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDSCH-1:pdschRat0RbgConfig=config1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7:bwpType=powerSaving
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7:locationAndBandwidthDl:cRbSizeDl=n106
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7:locationAndBandwidthDl:cRbStartDl=crb0
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7:locationAndBandwidthUl:cRbSizeUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7:locationAndBandwidthUl:cRbStartUl=sameAsDl
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1:alSelection=static
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1:dciDedicatedAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1:dciRaCompletionAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1:dciRaMsg2AggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1:dciSiAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1:downgradeAL16toAL8=notAllowed
...    NRCELL-1:pucchModeSelect=longPucch
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3|cellBwpId=0
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=1
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7|cellBwpId=2

@{Delta_Scf_F031}
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-3|cellBwpId=0
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=1
...    MRBTS-1/NRBTS-1/NRCELL-2:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-7|cellBwpId=2

@{PM_COUNTER_CHECK}
...    ${RRC_REESTAB_OTHER_FAILURE_DU}=2
...    NRCELL-2:${RRC_REESTAB_OTHER_FAILURE}=2
...    NRCELL-2:${REESTAB_ACC_OTHER_FAIL}=2
...    ${REESTAB_ACC_OTHER_FAIL_DU}=2
...    ${REESTAB_RRCRECONFIG_SUCC}=2

${RRC_REESTAB_OTHER_FAILURE_DU}    M55127C00503
${RRC_REESTAB_OTHER_FAILURE}    M55124C00505
${REESTAB_ACC_OTHER_FAIL}    M55124C00512
${REESTAB_ACC_OTHER_FAIL_DU}    M55127C00512
${REESTAB_RRCRECONFIG_SUCC}    M55124C00516

*** Test Cases ***
5GC000732-ET-F031_RRC_reestablish_succ_with_937_from_powersaving_bwp_to_powersaving_bwp
    [Documentation]    This user scenario describes the UE initiated RRC reestablishment for a UE config with both large and power saving BWP.
    ...    Case steps:
    ...        1.configure Cell-2 with powersaving bwp(related IE in wireshark nr-rrc.locationAndBandwidth:28875)
    ...        2.Trigger normal call to cell-2 successsfully
    ...        3.Trgger RRC reestablish to cell-2 successfully
    ...        4.Trgger RRC reestablish to cell-2 second time successfully
    ...        5.check cause otherFailure in rrcReestablishmentRequest wiresahrk msg
    ...          and DRB,SRB,cellgroup should be recovered
    ...        6.check counter
    ...        M55127C00503: RRC_REESTAB_OTHER_FAILURE_DU
    ...        M55124C00505: RRC_REESTAB_OTHER_FAILURE
    ...        M55127C00512: REESTAB_ACC_OTHER_FAIL_DU
    ...        M55124C00512: REESTAB_ACC_OTHER_FAIL
    ...        M55124C00516: REESTAB_RRCRECONFIG_SUCC
    [Tags]    F031    QC_134371
    [Timeout]     60 min
    Before_ue_attach_F031
    UE Attach and L3 Normal Call
    Verify SA DL and UL Traffic
    Reestablish from Cell_2 to Cell_2 and Check Traffic
    Reestablish from Cell_2 to Cell_2 and Check Traffic
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}/a2a_F031/a2a.ini    wait_string=UEContextReleaseComplete::4
    Check Counters    ${PM_COUNTER_CHECK}

*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=4
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1 qos_flows=1,2,3,4 qos_rules=1,2,3

Before_ue_attach_F031
    Delta Commission Parameters     ${Delta_Scf_F031}
    Execute Egate Command    ue_change_location id=81 enb=2 cell=2
    Clear Counter Files
    Start RRC Log    F031

UE Attach and L3 Normal Call
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id} request_type=initial-emergency-request
    ...                      pass_regexp=Initial Context Setup Successful
    Execute Egate Command    qosflow_disp
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Execute Egate Command    qosflow_modify qos_flow=3 priority=15
    Start Traffic    ${ue_id}    ${pdu_gw_id}

Start Traffic
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=2
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=3
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=dl mbps=100 trf_id=4
    ...    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} qfi=1 dir=ul mbps=10
    ...    pass_regexp=UE ${ue_id}: UDP UL

Verify SA DL and UL Traffic
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1
    Builtin.sleep    15s
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_gw_id}    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>270

Trigger UE RRC Reestablish to Cell
    [Arguments]    ${tgt_cell_id}    ${ue_id}=81
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${tgt_cell_id} cause=otherFailure
    ...    pass_regexp=UE81: NR RRC Reestablishment sucessfully completed
    Check Specific Ue State    ${ue_id}    ACTIVE
    ${enb_id}    ${cell_id}    Get UE Location    ${ue_id}
    Should Be Equal    ${enb_id}    2
    Should Be Equal    ${cell_id}    ${tgt_cell_id}

Reestablish from Cell_2 to Cell_2 and Check Traffic
    Trigger UE RRC Reestablish to Cell    tgt_cell_id=2
    Verify SA DL and UL Traffic
